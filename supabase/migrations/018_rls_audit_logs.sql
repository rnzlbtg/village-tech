-- Migration: 018_rls_audit_logs.sql
-- Description: Row Level Security policies for audit_logs table
-- Author: Platform App Implementation
-- Date: 2025-10-10

-- Policy: Super admins can read all audit logs
CREATE POLICY "Super admins read all audit logs"
ON audit_logs
FOR SELECT
TO authenticated
USING ((auth.jwt() ->> 'role')::TEXT = 'super_admin');

-- Policy: Admin heads can read audit logs for their tenant
CREATE POLICY "Admin heads read tenant audit logs"
ON audit_logs
FOR SELECT
TO authenticated
USING (
  tenant_id = (auth.jwt() ->> 'tenant_id')::UUID
  AND (auth.jwt() ->> 'role')::TEXT = 'admin_head'
);

-- Note: No INSERT/UPDATE/DELETE policies - audit logs are append-only via triggers
-- Users cannot directly modify audit logs, only the audit trigger can insert them

-- Comments
COMMENT ON POLICY "Super admins read all audit logs" ON audit_logs IS 'Platform super admins can view all audit trail entries';
COMMENT ON POLICY "Admin heads read tenant audit logs" ON audit_logs IS 'Admin heads can view audit trail for their tenant for compliance';
