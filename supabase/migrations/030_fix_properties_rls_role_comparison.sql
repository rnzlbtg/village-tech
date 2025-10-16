-- Migration: 030_fix_properties_rls_role_comparison.sql
-- Description: Fix RLS policies to properly compare role as text, not database role
-- Author: RLS Fix
-- Date: 2025-10-14

-- Drop existing policies
DROP POLICY IF EXISTS "Super admins manage all properties" ON properties;
DROP POLICY IF EXISTS "Admins manage tenant properties" ON properties;

-- Recreate with proper text comparison using = ANY for role checking
CREATE POLICY "Super admins manage all properties"
ON properties
FOR ALL
TO authenticated
USING ((auth.jwt() ->> 'role') = 'super_admin')
WITH CHECK ((auth.jwt() ->> 'role') = 'super_admin');

CREATE POLICY "Admins manage tenant properties"
ON properties
FOR ALL
TO authenticated
USING (
  tenant_id = (auth.jwt() ->> 'tenant_id')::UUID
  AND (auth.jwt() ->> 'role') = ANY(ARRAY['admin_head', 'admin_officer'])
)
WITH CHECK (
  tenant_id = (auth.jwt() ->> 'tenant_id')::UUID
  AND (auth.jwt() ->> 'role') = ANY(ARRAY['admin_head', 'admin_officer'])
);

-- Comments
COMMENT ON POLICY "Super admins manage all properties" ON properties IS 'Platform super admins can manage all tenant properties (fixed role comparison)';
COMMENT ON POLICY "Admins manage tenant properties" ON properties IS 'Tenant admins can CRUD properties within their tenant (fixed role comparison)';
