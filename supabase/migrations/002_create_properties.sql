-- Migration: 002_create_properties.sql
-- Description: Create properties table for residential buildings/areas within tenants
-- Author: Platform App Implementation
-- Date: 2025-10-10

CREATE TABLE IF NOT EXISTS properties (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  property_type VARCHAR(50) DEFAULT 'building' CHECK (property_type IN ('building', 'lot', 'section', 'phase')),
  address TEXT,
  description TEXT,
  total_units INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(tenant_id, name)
);

-- Apply updated_at trigger
CREATE TRIGGER update_properties_updated_at
  BEFORE UPDATE ON properties
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Create indexes
CREATE INDEX idx_properties_tenant_id ON properties(tenant_id);
CREATE INDEX idx_properties_property_type ON properties(property_type);

-- Enable Row Level Security
ALTER TABLE properties ENABLE ROW LEVEL SECURITY;

-- Comments
COMMENT ON TABLE properties IS 'Properties (buildings, sections, phases) within a tenant community';
COMMENT ON COLUMN properties.property_type IS 'Type of property: building, lot, section, phase';
COMMENT ON COLUMN properties.total_units IS 'Total number of residence units in this property';
