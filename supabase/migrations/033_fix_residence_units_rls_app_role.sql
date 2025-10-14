-- Migration: 033_fix_residence_units_rls_app_role.sql
-- Description: Fix RLS policies to use app_role instead of role claim
-- Author: Admin App Fix
-- Date: 2025-10-14

-- Drop existing policies
DROP POLICY IF EXISTS "Super admins manage all units" ON residence_units;
DROP POLICY IF EXISTS "Admins manage tenant units" ON residence_units;
DROP POLICY IF EXISTS "Household heads read tenant units" ON residence_units;
DROP POLICY IF EXISTS "Guards read tenant units" ON residence_units;

-- Policy: Super admins have full access to all residence units
CREATE POLICY "Super admins manage all units"
ON residence_units
FOR ALL
TO authenticated
USING ((auth.jwt() ->> 'app_role')::TEXT = 'super_admin');

-- Policy: Tenant admins can manage residence units in their tenant
CREATE POLICY "Admins manage tenant units"
ON residence_units
FOR ALL
TO authenticated
USING (
  tenant_id = (auth.jwt() ->> 'tenant_id')::UUID
  AND (auth.jwt() ->> 'app_role')::TEXT IN ('admin_head', 'admin_officer')
);

-- Policy: Household heads can read residence units in their tenant
CREATE POLICY "Household heads read tenant units"
ON residence_units
FOR SELECT
TO authenticated
USING (
  tenant_id = (auth.jwt() ->> 'tenant_id')::UUID
  AND (auth.jwt() ->> 'app_role')::TEXT = 'household_head'
);

-- Policy: Guards can read residence units in their tenant
CREATE POLICY "Guards read tenant units"
ON residence_units
FOR SELECT
TO authenticated
USING (
  tenant_id = (auth.jwt() ->> 'tenant_id')::UUID
  AND (auth.jwt() ->> 'app_role')::TEXT = 'guard'
);

-- Comments
COMMENT ON POLICY "Super admins manage all units" ON residence_units IS 'Platform super admins can manage all residence units';
COMMENT ON POLICY "Admins manage tenant units" ON residence_units IS 'Tenant admins can CRUD residence units within their tenant';
COMMENT ON POLICY "Household heads read tenant units" ON residence_units IS 'Household heads can view unit structure for reference';
