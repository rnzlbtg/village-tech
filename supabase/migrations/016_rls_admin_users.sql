-- Migration: 016_rls_admin_users.sql
-- Description: Row Level Security policies for admin_users table
-- Author: Platform App Implementation
-- Date: 2025-10-10

-- Policy: Super admins have full access to all admin users
CREATE POLICY "Super admins manage all admin users"
ON admin_users
FOR ALL
TO authenticated
USING ((auth.jwt() ->> 'role')::TEXT = 'super_admin');

-- Policy: Admin heads can manage admin users in their tenant
CREATE POLICY "Admin heads manage tenant admin users"
ON admin_users
FOR ALL
TO authenticated
USING (
  tenant_id = (auth.jwt() ->> 'tenant_id')::UUID
  AND (auth.jwt() ->> 'role')::TEXT = 'admin_head'
);

-- Policy: Admin officers can read admin users in their tenant
CREATE POLICY "Admin officers read tenant admin users"
ON admin_users
FOR SELECT
TO authenticated
USING (
  tenant_id = (auth.jwt() ->> 'tenant_id')::UUID
  AND (auth.jwt() ->> 'role')::TEXT = 'admin_officer'
);

-- Policy: Users can read their own admin user record
CREATE POLICY "Users read own admin user record"
ON admin_users
FOR SELECT
TO authenticated
USING (auth_user_id = auth.uid());

-- Comments
COMMENT ON POLICY "Super admins manage all admin users" ON admin_users IS 'Platform super admins can create and manage all tenant admin users';
COMMENT ON POLICY "Admin heads manage tenant admin users" ON admin_users IS 'Admin heads can CRUD admin users within their tenant';
COMMENT ON POLICY "Admin officers read tenant admin users" ON admin_users IS 'Admin officers can view other admins in their tenant';
COMMENT ON POLICY "Users read own admin user record" ON admin_users IS 'All users can view their own admin profile';
