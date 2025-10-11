-- Migration: 013_rls_properties.sql
-- Description: Row Level Security policies for properties table
-- Author: Platform App Implementation
-- Date: 2025-10-10

-- Policy: Super admins have full access to all properties
CREATE POLICY "Super admins manage all properties"
ON properties
FOR ALL
TO authenticated
USING ((auth.jwt() ->> 'role')::TEXT = 'super_admin');

-- Policy: Tenant admins can manage properties in their tenant
CREATE POLICY "Admins manage tenant properties"
ON properties
FOR ALL
TO authenticated
USING (
  tenant_id = (auth.jwt() ->> 'tenant_id')::UUID
  AND (auth.jwt() ->> 'role')::TEXT IN ('admin_head', 'admin_officer')
);

-- Policy: Household heads can read properties in their tenant
CREATE POLICY "Household heads read tenant properties"
ON properties
FOR SELECT
TO authenticated
USING (
  tenant_id = (auth.jwt() ->> 'tenant_id')::UUID
  AND (auth.jwt() ->> 'role')::TEXT = 'household_head'
);

-- Policy: Guards can read properties in their tenant
CREATE POLICY "Guards read tenant properties"
ON properties
FOR SELECT
TO authenticated
USING (
  tenant_id = (auth.jwt() ->> 'tenant_id')::UUID
  AND (auth.jwt() ->> 'role')::TEXT = 'guard'
);

-- Comments
COMMENT ON POLICY "Super admins manage all properties" ON properties IS 'Platform super admins can manage all tenant properties';
COMMENT ON POLICY "Admins manage tenant properties" ON properties IS 'Tenant admins can CRUD properties within their tenant';
COMMENT ON POLICY "Household heads read tenant properties" ON properties IS 'Household heads can view property structure for context';
