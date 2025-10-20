-- Migration: 064_extend_user_roles_and_admin_management_rls.sql
-- Description: Extend user roles and add RLS policies for admin user management
-- Author: User Management Feature Implementation
-- Date: 2025-10-20

-- First, extend the user_profiles role constraint to include security roles and household_member
-- Drop the existing constraint first
ALTER TABLE user_profiles DROP CONSTRAINT IF EXISTS user_profiles_role_check;

-- Add the extended constraint with all roles including security roles and household_member
ALTER TABLE user_profiles
ADD CONSTRAINT user_profiles_role_check
CHECK (role IN (
  'super_admin',
  'admin_head',
  'admin_officer',
  'security_head',
  'security_officer',
  'household_head',
  'household_member',
  'guard'
));

-- Update the comment to reflect the new roles
COMMENT ON COLUMN user_profiles.role IS
  'User role: super_admin, admin_head, admin_officer, security_head, security_officer, household_head, household_member, guard';

-- Allow admin_head to insert user_profiles for admin and security roles within their tenant
CREATE POLICY "Admin heads can create admin and security profiles in their tenant"
ON user_profiles
FOR INSERT
TO authenticated
WITH CHECK (
  -- User must be admin_head
  (auth.jwt() ->> 'app_role')::TEXT = 'admin_head'
  AND
  -- New profile must be for admin or security roles
  role IN ('admin_head', 'admin_officer', 'security_head', 'security_officer')
  AND
  -- New profile must be within admin's tenant
  tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
);

-- Allow admin_head to insert user_profiles for household_member within households of their tenant
CREATE POLICY "Admin heads can create household member profiles in their tenant"
ON user_profiles
FOR INSERT
TO authenticated
WITH CHECK (
  -- User must be admin_head
  (auth.jwt() ->> 'app_role')::TEXT = 'admin_head'
  AND
  -- New profile must be for household_member role
  role = 'household_member'
  AND
  -- New profile must be within admin's tenant
  tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
);

-- Allow admin_head and admin_officer to select user_profiles for admin and security roles within their tenant
CREATE POLICY "Admin users can read admin and security profiles in their tenant"
ON user_profiles
FOR SELECT
TO authenticated
USING (
  -- User must be admin_head or admin_officer
  (auth.jwt() ->> 'app_role')::TEXT IN ('admin_head', 'admin_officer')
  AND
  -- Profile must be for admin or security roles
  role IN ('admin_head', 'admin_officer', 'security_head', 'security_officer')
  AND
  -- Profile must be within admin's tenant
  tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
);

-- Allow admin_head and admin_officer to select user_profiles for household members within their tenant
CREATE POLICY "Admin users can read household member profiles in their tenant"
ON user_profiles
FOR SELECT
TO authenticated
USING (
  -- User must be admin_head or admin_officer
  (auth.jwt() ->> 'app_role')::TEXT IN ('admin_head', 'admin_officer')
  AND
  -- Profile must be for household_member role
  role = 'household_member'
  AND
  -- Profile must be within admin's tenant
  tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
);

-- Allow admin_head to update user_profiles for admin and security roles within their tenant
CREATE POLICY "Admin heads can update admin and security profiles in their tenant"
ON user_profiles
FOR UPDATE
TO authenticated
USING (
  -- User must be admin_head
  (auth.jwt() ->> 'app_role')::TEXT = 'admin_head'
  AND
  -- Profile must be for admin or security roles
  role IN ('admin_head', 'admin_officer', 'security_head', 'security_officer')
  AND
  -- Profile must be within admin's tenant
  tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
)
WITH CHECK (
  -- User must be admin_head
  (auth.jwt() ->> 'app_role')::TEXT = 'admin_head'
  AND
  -- Profile must be for admin or security roles
  role IN ('admin_head', 'admin_officer', 'security_head', 'security_officer')
  AND
  -- Profile must be within admin's tenant
  tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
);

-- Allow admin_head to update user_profiles for household members within their tenant
CREATE POLICY "Admin heads can update household member profiles in their tenant"
ON user_profiles
FOR UPDATE
TO authenticated
USING (
  -- User must be admin_head
  (auth.jwt() ->> 'app_role')::TEXT = 'admin_head'
  AND
  -- Profile must be for household_member role
  role = 'household_member'
  AND
  -- Profile must be within admin's tenant
  tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
)
WITH CHECK (
  -- User must be admin_head
  (auth.jwt() ->> 'app_role')::TEXT = 'admin_head'
  AND
  -- Profile must be for household_member role
  role = 'household_member'
  AND
  -- Profile must be within admin's tenant
  tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
);

-- Allow admin_head to delete user_profiles for admin and security roles within their tenant
CREATE POLICY "Admin heads can delete admin and security profiles in their tenant"
ON user_profiles
FOR DELETE
TO authenticated
USING (
  -- User must be admin_head
  (auth.jwt() ->> 'app_role')::TEXT = 'admin_head'
  AND
  -- Profile must be for admin or security roles
  role IN ('admin_head', 'admin_officer', 'security_head', 'security_officer')
  AND
  -- Profile must be within admin's tenant
  tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
);

-- Allow admin_head to delete user_profiles for household members within their tenant
CREATE POLICY "Admin heads can delete household member profiles in their tenant"
ON user_profiles
FOR DELETE
TO authenticated
USING (
  -- User must be admin_head
  (auth.jwt() ->> 'app_role')::TEXT = 'admin_head'
  AND
  -- Profile must be for household_member role
  role = 'household_member'
  AND
  -- Profile must be within admin's tenant
  tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
);

-- Update existing policy comments
COMMENT ON POLICY "Admin heads can create admin and security profiles in their tenant" ON user_profiles IS
  'Allows admin_head users to create user_profiles for admin and security roles within their tenant';
COMMENT ON POLICY "Admin heads can create household member profiles in their tenant" ON user_profiles IS
  'Allows admin_head users to create user_profiles for household members within households of their tenant';
COMMENT ON POLICY "Admin users can read admin and security profiles in their tenant" ON user_profiles IS
  'Allows admin users to read user_profiles for admin and security roles within their tenant';
COMMENT ON POLICY "Admin users can read household member profiles in their tenant" ON user_profiles IS
  'Allows admin users to read user_profiles for household members within their tenant';
COMMENT ON POLICY "Admin heads can update admin and security profiles in their tenant" ON user_profiles IS
  'Allows admin_head users to update user_profiles for admin and security roles within their tenant';
COMMENT ON POLICY "Admin heads can update household member profiles in their tenant" ON user_profiles IS
  'Allows admin_head users to update user_profiles for household members within their tenant';
COMMENT ON POLICY "Admin heads can delete admin and security profiles in their tenant" ON user_profiles IS
  'Allows admin_head users to delete user_profiles for admin and security roles within their tenant';
COMMENT ON POLICY "Admin heads can delete household member profiles in their tenant" ON user_profiles IS
  'Allows admin_head users to delete user_profiles for household members within their tenant';