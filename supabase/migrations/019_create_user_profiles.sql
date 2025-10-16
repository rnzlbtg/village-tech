-- Migration: 019_create_user_profiles.sql
-- Description: Create user_profiles table for all authenticated users
-- Author: Platform App Implementation
-- Date: 2025-10-10

CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  email VARCHAR(255) NOT NULL UNIQUE,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  phone_number VARCHAR(50),
  role VARCHAR(50) NOT NULL CHECK (role IN ('super_admin', 'admin_head', 'admin_officer', 'household_head', 'guard')),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Apply updated_at trigger
CREATE TRIGGER update_user_profiles_updated_at
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Create indexes
CREATE INDEX idx_user_profiles_tenant_id ON user_profiles(tenant_id);
CREATE INDEX idx_user_profiles_email ON user_profiles(email);
CREATE INDEX idx_user_profiles_role ON user_profiles(role);
CREATE INDEX idx_user_profiles_is_active ON user_profiles(is_active) WHERE is_active = true;

-- Enable Row Level Security
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can read own profile"
ON user_profiles
FOR SELECT
TO authenticated
USING (id = auth.uid());

CREATE POLICY "Users can update own profile"
ON user_profiles
FOR UPDATE
TO authenticated
USING (id = auth.uid());

CREATE POLICY "Super admins have full access to profiles"
ON user_profiles
FOR ALL
TO authenticated
USING (
  COALESCE(
    (auth.jwt() -> 'app_metadata' ->> 'role')::TEXT,
    (auth.jwt() ->> 'role')::TEXT
  ) = 'super_admin'
);

-- Comments
COMMENT ON TABLE user_profiles IS 'User profiles for all authenticated users';
COMMENT ON COLUMN user_profiles.role IS 'User role: super_admin, admin_head, admin_officer, household_head, guard';
COMMENT ON COLUMN user_profiles.tenant_id IS 'Tenant assignment (NULL for super_admin)';
