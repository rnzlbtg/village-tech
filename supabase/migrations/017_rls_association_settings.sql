-- Migration: 017_rls_association_settings.sql
-- Description: Row Level Security policies for association_settings table
-- Author: Platform App Implementation
-- Date: 2025-10-10

-- Policy: Super admins have full access to all association settings
CREATE POLICY "Super admins manage all settings"
ON association_settings
FOR ALL
TO authenticated
USING ((auth.jwt() ->> 'role')::TEXT = 'super_admin');

-- Policy: Tenant admins can manage association settings in their tenant
CREATE POLICY "Admins manage tenant settings"
ON association_settings
FOR ALL
TO authenticated
USING (
  tenant_id = (auth.jwt() ->> 'tenant_id')::UUID
  AND (auth.jwt() ->> 'role')::TEXT IN ('admin_head', 'admin_officer')
);

-- Policy: Household heads can read association settings in their tenant
CREATE POLICY "Household heads read tenant settings"
ON association_settings
FOR SELECT
TO authenticated
USING (
  tenant_id = (auth.jwt() ->> 'tenant_id')::UUID
  AND (auth.jwt() ->> 'role')::TEXT = 'household_head'
  AND is_active = true
);

-- Policy: Guards can read association settings in their tenant
CREATE POLICY "Guards read tenant settings"
ON association_settings
FOR SELECT
TO authenticated
USING (
  tenant_id = (auth.jwt() ->> 'tenant_id')::UUID
  AND (auth.jwt() ->> 'role')::TEXT = 'guard'
  AND is_active = true
);

-- Comments
COMMENT ON POLICY "Super admins manage all settings" ON association_settings IS 'Platform super admins can manage all tenant settings';
COMMENT ON POLICY "Admins manage tenant settings" ON association_settings IS 'Tenant admins can CRUD association settings';
COMMENT ON POLICY "Household heads read tenant settings" ON association_settings IS 'Household heads can view active settings for their tenant';
