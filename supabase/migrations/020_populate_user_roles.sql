-- Migration: 020_populate_user_roles.sql
-- Description: Populate user_roles table from existing user_profiles data
-- Author: Platform App Implementation
-- Date: 2025-10-10

-- Insert role assignments from user_profiles into user_roles
-- This migration ensures existing users have their roles properly assigned in the user_roles table
INSERT INTO user_roles (user_id, tenant_id, role, is_active, created_at, updated_at)
SELECT
  id as user_id,
  tenant_id,
  role,
  is_active,
  created_at,
  NOW() as updated_at
FROM user_profiles
WHERE role IS NOT NULL
ON CONFLICT (user_id, tenant_id) DO UPDATE
SET
  role = EXCLUDED.role,
  is_active = EXCLUDED.is_active,
  updated_at = NOW();

-- Add comment
COMMENT ON TABLE user_roles IS 'User role assignments synced from user_profiles - tracks active role assignments per user per tenant';
