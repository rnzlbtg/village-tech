-- Migration: 029_fix_properties_rls_with_check.sql
-- Description: Fix RLS policies for properties table by adding WITH CHECK clauses
-- Author: RLS Fix
-- Date: 2025-10-14

-- Drop existing policies
DROP POLICY IF EXISTS "Super admins manage all properties" ON properties;
DROP POLICY IF EXISTS "Admins manage tenant properties" ON properties;

-- Recreate with WITH CHECK clauses for INSERT operations
CREATE POLICY "Super admins manage all properties"
ON properties
FOR ALL
TO authenticated
USING ((auth.jwt() ->> 'role')::TEXT = 'super_admin')
WITH CHECK ((auth.jwt() ->> 'role')::TEXT = 'super_admin');

CREATE POLICY "Admins manage tenant properties"
ON properties
FOR ALL
TO authenticated
USING (
  tenant_id = (auth.jwt() ->> 'tenant_id')::UUID
  AND (auth.jwt() ->> 'role')::TEXT IN ('admin_head', 'admin_officer')
)
WITH CHECK (
  tenant_id = (auth.jwt() ->> 'tenant_id')::UUID
  AND (auth.jwt() ->> 'role')::TEXT IN ('admin_head', 'admin_officer')
);

-- Comments
COMMENT ON POLICY "Super admins manage all properties" ON properties IS 'Platform super admins can manage all tenant properties (fixed with WITH CHECK)';
COMMENT ON POLICY "Admins manage tenant properties" ON properties IS 'Tenant admins can CRUD properties within their tenant (fixed with WITH CHECK)';
