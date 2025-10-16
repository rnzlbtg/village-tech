-- Migration: 003_create_residence_units.sql
-- Description: Create residence_units table for individual dwellings within properties
-- Author: Platform App Implementation
-- Date: 2025-10-10

CREATE TABLE IF NOT EXISTS residence_units (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  unit_number VARCHAR(50) NOT NULL,
  unit_type VARCHAR(50) DEFAULT 'residential' CHECK (unit_type IN ('residential', 'commercial', 'mixed')),
  floor_number INTEGER,
  building_section VARCHAR(50),
  lot_number VARCHAR(50),
  address TEXT,
  status VARCHAR(50) DEFAULT 'available' CHECK (status IN ('available', 'occupied', 'reserved', 'maintenance')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(property_id, unit_number)
);

-- Apply updated_at trigger
CREATE TRIGGER update_residence_units_updated_at
  BEFORE UPDATE ON residence_units
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Create indexes
CREATE INDEX idx_residence_units_tenant_id ON residence_units(tenant_id);
CREATE INDEX idx_residence_units_property_id ON residence_units(property_id);
CREATE INDEX idx_residence_units_status ON residence_units(status);
CREATE INDEX idx_residence_units_unit_number ON residence_units(unit_number);

-- Enable Row Level Security
ALTER TABLE residence_units ENABLE ROW LEVEL SECURITY;

-- Comments
COMMENT ON TABLE residence_units IS 'Individual dwelling units within properties';
COMMENT ON COLUMN residence_units.unit_number IS 'Unique unit identifier within the property (e.g., Unit 101, Lot 25)';
COMMENT ON COLUMN residence_units.status IS 'Unit availability status: available, occupied, reserved, maintenance';
