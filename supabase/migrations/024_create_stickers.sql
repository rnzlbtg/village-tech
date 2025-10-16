-- Migration: 024_create_stickers.sql
-- Description: Create sticker programs and requests tables for vehicle sticker management
-- Author: Admin App Implementation
-- Date: 2025-10-12

-- Sticker programs table: Configuration for sticker allocation
CREATE TABLE IF NOT EXISTS sticker_programs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  program_name TEXT NOT NULL,
  program_year INTEGER NOT NULL,
  stickers_per_household INTEGER NOT NULL DEFAULT 2,
  start_date DATE NOT NULL,
  end_date DATE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(tenant_id, program_year)
);

-- Sticker requests table: Household requests for vehicle stickers
CREATE TABLE IF NOT EXISTS sticker_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  household_id UUID NOT NULL REFERENCES households(id) ON DELETE CASCADE,
  program_id UUID NOT NULL REFERENCES sticker_programs(id) ON DELETE CASCADE,
  vehicle_plate_number TEXT NOT NULL,
  vehicle_make TEXT,
  vehicle_model TEXT,
  vehicle_color TEXT,
  vehicle_type TEXT CHECK (vehicle_type IN ('car', 'suv', 'truck', 'motorcycle', 'van')),
  request_status TEXT NOT NULL DEFAULT 'pending' CHECK (request_status IN ('pending', 'approved', 'rejected', 'distributed')),
  requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  reviewed_at TIMESTAMPTZ,
  reviewed_by UUID REFERENCES auth.users(id),
  rejection_reason TEXT,
  distributed_at TIMESTAMPTZ,
  distributed_by UUID REFERENCES auth.users(id),
  sticker_code TEXT,
  recipient_signature_url TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for sticker_programs
CREATE INDEX idx_sticker_programs_tenant ON sticker_programs(tenant_id);
CREATE INDEX idx_sticker_programs_active ON sticker_programs(tenant_id, is_active) WHERE is_active = TRUE;

-- Indexes for sticker_requests
CREATE INDEX idx_sticker_requests_tenant ON sticker_requests(tenant_id);
CREATE INDEX idx_sticker_requests_household ON sticker_requests(household_id);
CREATE INDEX idx_sticker_requests_program ON sticker_requests(program_id);
CREATE INDEX idx_sticker_requests_status ON sticker_requests(tenant_id, request_status);
CREATE INDEX idx_sticker_requests_plate ON sticker_requests(vehicle_plate_number);

-- Trigger for updated_at
CREATE TRIGGER update_sticker_programs_updated_at
  BEFORE UPDATE ON sticker_programs
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sticker_requests_updated_at
  BEFORE UPDATE ON sticker_requests
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Comments
COMMENT ON TABLE sticker_programs IS 'Annual vehicle sticker program configuration';
COMMENT ON TABLE sticker_requests IS 'Household requests for vehicle access stickers';
COMMENT ON COLUMN sticker_requests.request_status IS 'pending: awaiting admin review, approved: ready for pickup, rejected: denied, distributed: physically given to resident';
