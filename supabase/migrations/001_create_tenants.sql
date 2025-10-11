-- Migration: 001_create_tenants.sql
-- Description: Create tenants table for multi-tenant residential communities
-- Author: Platform App Implementation
-- Date: 2025-10-10

CREATE TABLE IF NOT EXISTS tenants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL UNIQUE,
  address TEXT NOT NULL,
  city VARCHAR(100),
  state VARCHAR(100),
  country VARCHAR(100) DEFAULT 'Philippines',
  postal_code VARCHAR(20),
  contact_name VARCHAR(255),
  contact_email VARCHAR(255),
  contact_phone VARCHAR(50),
  subscription_status VARCHAR(50) DEFAULT 'active' CHECK (subscription_status IN ('active', 'inactive', 'suspended', 'trial')),
  subscription_plan VARCHAR(50),
  max_users INTEGER,
  max_residences INTEGER,
  settings JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create updated_at trigger function (reusable for all tables)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to tenants table
CREATE TRIGGER update_tenants_updated_at
  BEFORE UPDATE ON tenants
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Create index on name for fast lookups
CREATE INDEX idx_tenants_name ON tenants(name);

-- Create index on subscription_status for filtering
CREATE INDEX idx_tenants_subscription_status ON tenants(subscription_status);

-- Enable Row Level Security
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;

-- Comments
COMMENT ON TABLE tenants IS 'Multi-tenant communities managed by the platform';
COMMENT ON COLUMN tenants.subscription_status IS 'Tenant subscription status: active, inactive, suspended, trial';
COMMENT ON COLUMN tenants.settings IS 'Tenant-specific configuration settings stored as JSON';
