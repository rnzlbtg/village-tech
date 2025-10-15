-- Migration: 038_user_profiles_admin_insert_policy.sql
-- Description: Add RLS policy to allow admin users to insert user_profiles for household heads
-- Author: Admin App Bug Fix
-- Date: 2025-10-15

-- Allow admin_head and admin_officer to insert user_profiles for household_head within their tenant
CREATE POLICY "Admins can insert household head profiles in their tenant"
ON user_profiles
FOR INSERT
TO authenticated
WITH CHECK (
  -- User must be admin_head or admin_officer (using app_role from custom access token hook)
  (auth.jwt() ->> 'app_role')::TEXT IN ('admin_head', 'admin_officer')
  AND
  -- New profile must be for household_head role
  role = 'household_head'
  AND
  -- New profile must be within admin's tenant
  tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
);

COMMENT ON POLICY "Admins can insert household head profiles in their tenant" ON user_profiles IS
  'Allows admin users to create user_profiles for household heads within their tenant';
