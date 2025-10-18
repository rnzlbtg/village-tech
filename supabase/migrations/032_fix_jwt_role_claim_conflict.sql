-- Migration: 032_fix_jwt_role_claim_conflict.sql
-- Description: Fix JWT hook to use app_role instead of role to avoid PostgreSQL role conflict
-- Author: JWT Fix
-- Date: 2025-10-14

-- Update the custom access token hook to use 'app_role' instead of 'role'
CREATE OR REPLACE FUNCTION custom_access_token_hook(event JSONB)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
DECLARE
  claims JSONB;
  user_role RECORD;
BEGIN
  -- Initialize claims from the event
  claims := event->'claims';

  -- Fetch active role for the user
  SELECT role, tenant_id
  INTO user_role
  FROM public.user_roles
  WHERE user_id = (event->>'user_id')::UUID
    AND is_active = true
  LIMIT 1;

  -- If user has a role, add it to claims as 'app_role' (not 'role' to avoid PostgreSQL role conflict)
  IF FOUND THEN
    claims := jsonb_set(claims, '{app_role}', to_jsonb(user_role.role));

    -- Add tenant_id if not NULL (super_admins have NULL tenant_id)
    IF user_role.tenant_id IS NOT NULL THEN
      claims := jsonb_set(claims, '{tenant_id}', to_jsonb(user_role.tenant_id::TEXT));
    END IF;
  ELSE
    -- Default role if no role is assigned
    claims := jsonb_set(claims, '{app_role}', '"authenticated"');
  END IF;

  -- Update the event with modified claims
  event := jsonb_set(event, '{claims}', claims);

  RETURN event;
END;
$$;

-- Update RLS policies to use 'app_role' instead of 'role'
DROP POLICY IF EXISTS "Super admins manage all properties" ON properties;
DROP POLICY IF EXISTS "Admins manage tenant properties" ON properties;
DROP POLICY IF EXISTS "Household heads read tenant properties" ON properties;
DROP POLICY IF EXISTS "Guards read tenant properties" ON properties;

CREATE POLICY "Super admins manage all properties"
ON properties
FOR ALL
TO authenticated
USING ((auth.jwt() ->> 'app_role') = 'super_admin')
WITH CHECK ((auth.jwt() ->> 'app_role') = 'super_admin');

CREATE POLICY "Admins manage tenant properties"
ON properties
FOR ALL
TO authenticated
USING (
  tenant_id = (auth.jwt() ->> 'tenant_id')::UUID
  AND (auth.jwt() ->> 'app_role') = ANY(ARRAY['admin_head', 'admin_officer'])
)
WITH CHECK (
  tenant_id = (auth.jwt() ->> 'tenant_id')::UUID
  AND (auth.jwt() ->> 'app_role') = ANY(ARRAY['admin_head', 'admin_officer'])
);

CREATE POLICY "Household heads read tenant properties"
ON properties
FOR SELECT
TO authenticated
USING (
  tenant_id = (auth.jwt() ->> 'tenant_id')::UUID
  AND (auth.jwt() ->> 'app_role') = 'household_head'
);

CREATE POLICY "Guards read tenant properties"
ON properties
FOR SELECT
TO authenticated
USING (
  tenant_id = (auth.jwt() ->> 'tenant_id')::UUID
  AND (auth.jwt() ->> 'app_role') = 'guard'
);

-- Comments
COMMENT ON FUNCTION custom_access_token_hook IS 'Custom Access Token Hook: Injects user app_role and tenant_id into JWT claims for RLS enforcement (fixed role conflict)';
COMMENT ON POLICY "Super admins manage all properties" ON properties IS 'Platform super admins can manage all tenant properties';
COMMENT ON POLICY "Admins manage tenant properties" ON properties IS 'Tenant admins can CRUD properties within their tenant';
COMMENT ON POLICY "Household heads read tenant properties" ON properties IS 'Household heads can view property structure';
COMMENT ON POLICY "Guards read tenant properties" ON properties IS 'Guards can view property structure';
