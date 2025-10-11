-- Migration: 006_create_association_settings.sql
-- Description: Create association_settings table for tenant operational parameters
-- Author: Platform App Implementation
-- Date: 2025-10-10

CREATE TABLE IF NOT EXISTS association_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  setting_category VARCHAR(100) NOT NULL,
  setting_key VARCHAR(100) NOT NULL,
  setting_value JSONB NOT NULL,
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(tenant_id, setting_category, setting_key)
);

-- Apply updated_at trigger
CREATE TRIGGER update_association_settings_updated_at
  BEFORE UPDATE ON association_settings
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Create indexes
CREATE INDEX idx_association_settings_tenant_id ON association_settings(tenant_id);
CREATE INDEX idx_association_settings_category ON association_settings(setting_category);
CREATE INDEX idx_association_settings_is_active ON association_settings(is_active) WHERE is_active = true;

-- Enable Row Level Security
ALTER TABLE association_settings ENABLE ROW LEVEL SECURITY;

-- Comments
COMMENT ON TABLE association_settings IS 'Tenant-level operational settings and parameters';
COMMENT ON COLUMN association_settings.setting_category IS 'Setting category: fees, rules, operations, notifications, etc.';
COMMENT ON COLUMN association_settings.setting_key IS 'Unique setting key within category';
COMMENT ON COLUMN association_settings.setting_value IS 'Setting value stored as JSON for flexibility';

-- Example seed data for common settings
INSERT INTO association_settings (tenant_id, setting_category, setting_key, setting_value, description)
SELECT
  t.id,
  'fees',
  'monthly_association_fee',
  '{"amount": 0, "currency": "PHP", "billing_day": 1}'::jsonb,
  'Monthly association fee configuration'
FROM tenants t
ON CONFLICT DO NOTHING;
