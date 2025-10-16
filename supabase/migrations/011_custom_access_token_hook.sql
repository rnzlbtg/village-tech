-- Migration: 011_custom_access_token_hook.sql
-- Description: Create Custom Access Token Hook function to inject tenant_id and role into JWT
-- Author: Platform App Implementation
-- Date: 2025-10-10
-- Reference: https://supabase.com/docs/guides/auth/auth-hooks/custom-access-token-hook

-- Create the hook function
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

  -- If user has a role, add it to claims
  IF FOUND THEN
    claims := jsonb_set(claims, '{role}', to_jsonb(user_role.role));

    -- Add tenant_id if not NULL (super_admins have NULL tenant_id)
    IF user_role.tenant_id IS NOT NULL THEN
      claims := jsonb_set(claims, '{tenant_id}', to_jsonb(user_role.tenant_id::TEXT));
    END IF;
  ELSE
    -- Default role if no role is assigned
    claims := jsonb_set(claims, '{role}', '"authenticated"');
  END IF;

  -- Update the event with modified claims
  event := jsonb_set(event, '{claims}', claims);

  RETURN event;
END;
$$;

-- Grant necessary permissions
GRANT EXECUTE ON FUNCTION public.custom_access_token_hook TO supabase_auth_admin;
GRANT SELECT ON public.user_roles TO supabase_auth_admin;
GRANT USAGE ON SCHEMA public TO supabase_auth_admin;

-- Comments
COMMENT ON FUNCTION custom_access_token_hook IS 'Custom Access Token Hook: Injects user role and tenant_id into JWT claims for RLS enforcement';

-- IMPORTANT: After running this migration, configure the hook in Supabase Dashboard:
-- 1. Go to Authentication > Hooks
-- 2. Select "Custom Access Token"
-- 3. Enable the hook and select this function: custom_access_token_hook
-- 4. Or use Supabase CLI: supabase secrets set AUTH_HOOK_CUSTOM_ACCESS_TOKEN=custom_access_token_hook

-- Test the hook (manually via SQL):
-- SELECT custom_access_token_hook('{"user_id": "some-user-uuid", "claims": {}}'::JSONB);
