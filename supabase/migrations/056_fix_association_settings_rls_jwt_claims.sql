-- Migration: 056_fix_association_settings_rls_jwt_claims.sql
-- Description: Fix association_settings RLS policies to use correct JWT claim format (app_role instead of role)
-- Author: RLS Fix Implementation
-- Date: 2025-10-16

-- Drop existing RLS policies that use old JWT claim format
DROP POLICY IF EXISTS "Super admins manage all settings" ON association_settings;
DROP POLICY IF EXISTS "Admins manage tenant settings" ON association_settings;
DROP POLICY IF EXISTS "Household heads read tenant settings" ON association_settings;
DROP POLICY IF EXISTS "Guards read tenant settings" ON association_settings;

-- Recreate policies using correct JWT claim format (app_role instead of role)
-- Policy: Super admins have full access to all association settings
CREATE POLICY "Super admins manage all settings"
ON association_settings
FOR ALL
TO authenticated
USING ((auth.jwt() ->> 'app_role') = 'super_admin')
WITH CHECK ((auth.jwt() ->> 'app_role') = 'super_admin');

-- Policy: Tenant admins can manage association settings in their tenant
CREATE POLICY "Admins manage tenant settings"
ON association_settings
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

-- Policy: Household heads can read association settings in their tenant
CREATE POLICY "Household heads read tenant settings"
ON association_settings
FOR SELECT
TO authenticated
USING (
  tenant_id = (auth.jwt() ->> 'tenant_id')::UUID
  AND (auth.jwt() ->> 'app_role') = 'household_head'
  AND is_active = true
);

-- Policy: Guards can read association settings in their tenant
CREATE POLICY "Guards read tenant settings"
ON association_settings
FOR SELECT
TO authenticated
USING (
  tenant_id = (auth.jwt() ->> 'tenant_id')::UUID
  AND (auth.jwt() ->> 'app_role') = 'guard'
  AND is_active = true
);

-- Comments
COMMENT ON POLICY "Super admins manage all settings" ON association_settings IS 'Platform super admins can manage all tenant settings using app_role claim';
COMMENT ON POLICY "Admins manage tenant settings" ON association_settings IS 'Tenant admins can CRUD association settings using app_role claim';
COMMENT ON POLICY "Household heads read tenant settings" ON association_settings IS 'Household heads can view active settings for their tenant using app_role claim';
COMMENT ON POLICY "Guards read tenant settings" ON association_settings IS 'Guards can view active settings for their tenant using app_role claim';