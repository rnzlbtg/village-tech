-- Migration: 015_rls_gates.sql
-- Description: Row Level Security policies for gates table
-- Author: Platform App Implementation
-- Date: 2025-10-10

-- Policy: Super admins have full access to all gates
CREATE POLICY "Super admins manage all gates"
ON gates
FOR ALL
TO authenticated
USING (
  COALESCE(
    (auth.jwt() -> 'app_metadata' ->> 'role')::TEXT,
    (auth.jwt() ->> 'role')::TEXT
  ) = 'super_admin'
);

-- Policy: Tenant admins can manage gates in their tenant
CREATE POLICY "Admins manage tenant gates"
ON gates
FOR ALL
TO authenticated
USING (
  tenant_id = COALESCE(
    (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::UUID,
    (auth.jwt() ->> 'tenant_id')::UUID
  )
  AND COALESCE(
    (auth.jwt() -> 'app_metadata' ->> 'role')::TEXT,
    (auth.jwt() ->> 'role')::TEXT
  ) IN ('admin_head', 'admin_officer')
);

-- Policy: Guards can read gates in their tenant
CREATE POLICY "Guards read tenant gates"
ON gates
FOR SELECT
TO authenticated
USING (
  tenant_id = COALESCE(
    (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::UUID,
    (auth.jwt() ->> 'tenant_id')::UUID
  )
  AND COALESCE(
    (auth.jwt() -> 'app_metadata' ->> 'role')::TEXT,
    (auth.jwt() ->> 'role')::TEXT
  ) = 'guard'
);

-- Policy: Household heads can read gates in their tenant
CREATE POLICY "Household heads read tenant gates"
ON gates
FOR SELECT
TO authenticated
USING (
  tenant_id = COALESCE(
    (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::UUID,
    (auth.jwt() ->> 'tenant_id')::UUID
  )
  AND COALESCE(
    (auth.jwt() -> 'app_metadata' ->> 'role')::TEXT,
    (auth.jwt() ->> 'role')::TEXT
  ) = 'household_head'
);

-- Comments
COMMENT ON POLICY "Super admins manage all gates" ON gates IS 'Platform super admins can manage all gate configurations';
COMMENT ON POLICY "Admins manage tenant gates" ON gates IS 'Tenant admins can CRUD gates within their tenant';
COMMENT ON POLICY "Guards read tenant gates" ON gates IS 'Guards can view gate configurations for operational use';
