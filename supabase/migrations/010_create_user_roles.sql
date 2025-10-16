-- Migration: 010_create_user_roles.sql
-- Description: Create user_roles table for role management and Custom Access Token Hook support
-- Author: Platform App Implementation
-- Date: 2025-10-10

CREATE TABLE IF NOT EXISTS user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  role VARCHAR(50) NOT NULL CHECK (role IN ('super_admin', 'admin_head', 'admin_officer', 'household_head', 'guard')),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, tenant_id)
);

-- Apply updated_at trigger
CREATE TRIGGER update_user_roles_updated_at
  BEFORE UPDATE ON user_roles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Create indexes
CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX idx_user_roles_tenant_id ON user_roles(tenant_id);
CREATE INDEX idx_user_roles_role ON user_roles(role);
CREATE INDEX idx_user_roles_active ON user_roles(user_id, is_active) WHERE is_active = true;

-- Enable Row Level Security
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

-- Comments
COMMENT ON TABLE user_roles IS 'User role assignments for authentication and authorization';
COMMENT ON COLUMN user_roles.role IS 'User role: super_admin, admin_head, admin_officer, household_head, guard';
COMMENT ON COLUMN user_roles.tenant_id IS 'Tenant association (NULL for super_admin who has platform-wide access)';
COMMENT ON COLUMN user_roles.is_active IS 'Whether this role assignment is currently active';

-- Allow super_admins to have NULL tenant_id (platform-wide access)
ALTER TABLE user_roles DROP CONSTRAINT IF EXISTS user_roles_user_id_tenant_id_key;
ALTER TABLE user_roles ADD CONSTRAINT user_roles_user_tenant_unique
  UNIQUE NULLS NOT DISTINCT (user_id, tenant_id);
