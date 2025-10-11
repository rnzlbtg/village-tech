-- Migration: 004_create_gates.sql
-- Description: Create gates table for community entrance/exit points
-- Author: Platform App Implementation
-- Date: 2025-10-10

CREATE TABLE IF NOT EXISTS gates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  location VARCHAR(255),
  description TEXT,
  gate_type VARCHAR(50) DEFAULT 'main' CHECK (gate_type IN ('main', 'pedestrian', 'service', 'emergency')),
  operational_status VARCHAR(50) DEFAULT 'active' CHECK (operational_status IN ('active', 'inactive', 'maintenance')),
  equipment_config JSONB DEFAULT '{}',
  has_rfid_reader BOOLEAN DEFAULT false,
  has_barrier BOOLEAN DEFAULT false,
  operating_hours JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(tenant_id, name)
);

-- Apply updated_at trigger
CREATE TRIGGER update_gates_updated_at
  BEFORE UPDATE ON gates
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Create indexes
CREATE INDEX idx_gates_tenant_id ON gates(tenant_id);
CREATE INDEX idx_gates_operational_status ON gates(operational_status);
CREATE INDEX idx_gates_gate_type ON gates(gate_type);

-- Enable Row Level Security
ALTER TABLE gates ENABLE ROW LEVEL SECURITY;

-- Comments
COMMENT ON TABLE gates IS 'Gate entrance/exit points for the community';
COMMENT ON COLUMN gates.gate_type IS 'Type of gate: main, pedestrian, service, emergency';
COMMENT ON COLUMN gates.operational_status IS 'Gate status: active, inactive, maintenance';
COMMENT ON COLUMN gates.equipment_config IS 'RFID reader and equipment configuration stored as JSON';
COMMENT ON COLUMN gates.operating_hours IS 'Gate operating hours schedule stored as JSON';
