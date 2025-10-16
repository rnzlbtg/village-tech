-- Migration: 005_create_admin_users.sql
-- Description: Create admin_users table for tenant administrators
-- Author: Platform App Implementation
-- Date: 2025-10-10

CREATE TABLE IF NOT EXISTS admin_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  auth_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  phone VARCHAR(50),
  role VARCHAR(50) NOT NULL CHECK (role IN ('admin_head', 'admin_officer')),
  permissions JSONB DEFAULT '{}',
  is_active BOOLEAN DEFAULT true,
  last_login_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(auth_user_id),
  UNIQUE(tenant_id, email)
);

-- Apply updated_at trigger
CREATE TRIGGER update_admin_users_updated_at
  BEFORE UPDATE ON admin_users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Create indexes
CREATE INDEX idx_admin_users_tenant_id ON admin_users(tenant_id);
CREATE INDEX idx_admin_users_auth_user_id ON admin_users(auth_user_id);
CREATE INDEX idx_admin_users_role ON admin_users(role);
CREATE INDEX idx_admin_users_is_active ON admin_users(is_active) WHERE is_active = true;

-- Enable Row Level Security
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- Comments
COMMENT ON TABLE admin_users IS 'Administrative users for tenant management';
COMMENT ON COLUMN admin_users.role IS 'Admin role: admin_head (full access), admin_officer (limited access)';
COMMENT ON COLUMN admin_users.permissions IS 'Role-specific permissions stored as JSON';
COMMENT ON COLUMN admin_users.auth_user_id IS 'Reference to Supabase Auth user';
