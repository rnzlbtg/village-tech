-- Migration: 012_rls_tenants.sql
-- Description: Row Level Security policies for tenants table
-- Author: Platform App Implementation
-- Date: 2025-10-10

-- Policy: Super admins have full access to all tenants
CREATE POLICY "Super admins have full access"
ON tenants
FOR ALL
TO authenticated
USING (
  COALESCE(
    (auth.jwt() -> 'app_metadata' ->> 'role')::TEXT,
    (auth.jwt() ->> 'role')::TEXT
  ) = 'super_admin'
);

-- Policy: Admins can read their assigned tenant
CREATE POLICY "Admins can read assigned tenant"
ON tenants
FOR SELECT
TO authenticated
USING (
  id = COALESCE(
    (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::UUID,
    (auth.jwt() ->> 'tenant_id')::UUID
  )
  AND COALESCE(
    (auth.jwt() -> 'app_metadata' ->> 'role')::TEXT,
    (auth.jwt() ->> 'role')::TEXT
  ) IN ('admin_head', 'admin_officer')
);

-- Policy: Household heads can read their assigned tenant
CREATE POLICY "Household heads can read assigned tenant"
ON tenants
FOR SELECT
TO authenticated
USING (
  id = COALESCE(
    (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::UUID,
    (auth.jwt() ->> 'tenant_id')::UUID
  )
  AND COALESCE(
    (auth.jwt() -> 'app_metadata' ->> 'role')::TEXT,
    (auth.jwt() ->> 'role')::TEXT
  ) = 'household_head'
);

-- Policy: Guards can read their assigned tenant
CREATE POLICY "Guards can read assigned tenant"
ON tenants
FOR SELECT
TO authenticated
USING (
  id = COALESCE(
    (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::UUID,
    (auth.jwt() ->> 'tenant_id')::UUID
  )
  AND COALESCE(
    (auth.jwt() -> 'app_metadata' ->> 'role')::TEXT,
    (auth.jwt() ->> 'role')::TEXT
  ) = 'guard'
);

-- Comments
COMMENT ON POLICY "Super admins have full access" ON tenants IS 'Platform super admins can create, read, update, delete all tenants';
COMMENT ON POLICY "Admins can read assigned tenant" ON tenants IS 'Tenant admins can view their own tenant information';
COMMENT ON POLICY "Household heads can read assigned tenant" ON tenants IS 'Household heads can view their tenant information for context';
COMMENT ON POLICY "Guards can read assigned tenant" ON tenants IS 'Guards can view tenant information for operational context';
