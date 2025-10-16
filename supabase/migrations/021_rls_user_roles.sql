-- Migration: 021_rls_user_roles.sql
-- Description: Add RLS policies for user_roles table
-- Author: Platform App Implementation
-- Date: 2025-10-10

-- Super admins can view all role assignments
CREATE POLICY "Super admins can view all role assignments"
ON user_roles
FOR SELECT
TO authenticated
USING (
  COALESCE(
    (auth.jwt() -> 'app_metadata' ->> 'role')::TEXT,
    (auth.jwt() ->> 'role')::TEXT
  ) = 'super_admin'
);

-- Super admins can insert role assignments
CREATE POLICY "Super admins can insert role assignments"
ON user_roles
FOR INSERT
TO authenticated
WITH CHECK (
  COALESCE(
    (auth.jwt() -> 'app_metadata' ->> 'role')::TEXT,
    (auth.jwt() ->> 'role')::TEXT
  ) = 'super_admin'
);

-- Super admins can update role assignments
CREATE POLICY "Super admins can update role assignments"
ON user_roles
FOR UPDATE
TO authenticated
USING (
  COALESCE(
    (auth.jwt() -> 'app_metadata' ->> 'role')::TEXT,
    (auth.jwt() ->> 'role')::TEXT
  ) = 'super_admin'
);

-- Super admins can delete role assignments
CREATE POLICY "Super admins can delete role assignments"
ON user_roles
FOR DELETE
TO authenticated
USING (
  COALESCE(
    (auth.jwt() -> 'app_metadata' ->> 'role')::TEXT,
    (auth.jwt() ->> 'role')::TEXT
  ) = 'super_admin'
);

-- Users can view their own role assignments
CREATE POLICY "Users can view own role assignments"
ON user_roles
FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- Comments
COMMENT ON POLICY "Super admins can view all role assignments" ON user_roles IS 'Super admins have full visibility of all role assignments';
COMMENT ON POLICY "Users can view own role assignments" ON user_roles IS 'Users can view their own role assignments';
