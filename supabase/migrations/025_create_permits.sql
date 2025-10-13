-- Migration: 025_create_permits.sql
-- Description: Create construction permits and payments tables
-- Author: Admin App Implementation
-- Date: 2025-10-12

-- Construction permits table
CREATE TABLE IF NOT EXISTS construction_permits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  household_id UUID NOT NULL REFERENCES households(id) ON DELETE CASCADE,
  permit_reference TEXT NOT NULL UNIQUE,
  project_type TEXT NOT NULL CHECK (project_type IN ('renovation', 'repair', 'construction', 'landscaping', 'electrical', 'plumbing')),
  project_description TEXT NOT NULL,
  start_date DATE NOT NULL,
  estimated_end_date DATE NOT NULL,
  actual_end_date DATE,
  road_fee_amount DECIMAL(10,2),
  payment_deadline DATE,
  permit_status TEXT NOT NULL DEFAULT 'pending' CHECK (permit_status IN ('pending', 'approved', 'rejected', 'in_progress', 'on_hold', 'completed', 'cancelled')),
  requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  approved_at TIMESTAMPTZ,
  approved_by UUID REFERENCES auth.users(id),
  rejection_reason TEXT,
  completion_notes TEXT,
  guard_notified_at TIMESTAMPTZ,
  attachments_url TEXT[],
  authorized_workers JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Permit payments table
CREATE TABLE IF NOT EXISTS permit_payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  permit_id UUID NOT NULL REFERENCES construction_permits(id) ON DELETE CASCADE,
  payment_amount DECIMAL(10,2) NOT NULL,
  payment_method TEXT NOT NULL CHECK (payment_method IN ('cash', 'check', 'bank_transfer', 'online')),
  payment_reference TEXT,
  paid_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  received_by UUID REFERENCES auth.users(id),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_construction_permits_tenant ON construction_permits(tenant_id);
CREATE INDEX idx_construction_permits_household ON construction_permits(household_id);
CREATE INDEX idx_construction_permits_status ON construction_permits(tenant_id, permit_status);
CREATE INDEX idx_construction_permits_reference ON construction_permits(permit_reference);
CREATE INDEX idx_permit_payments_permit ON permit_payments(permit_id);

-- Trigger for updated_at
CREATE TRIGGER update_construction_permits_updated_at
  BEFORE UPDATE ON construction_permits
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Function to generate permit reference number
CREATE OR REPLACE FUNCTION generate_permit_reference()
RETURNS TEXT AS $$
DECLARE
  ref_number TEXT;
  year_part TEXT;
  sequence_num INTEGER;
BEGIN
  year_part := TO_CHAR(CURRENT_DATE, 'YYYY');

  SELECT COALESCE(MAX(CAST(SUBSTRING(permit_reference FROM 'PERM-' || year_part || '-([0-9]+)') AS INTEGER)), 0) + 1
  INTO sequence_num
  FROM construction_permits
  WHERE permit_reference LIKE 'PERM-' || year_part || '-%';

  ref_number := 'PERM-' || year_part || '-' || LPAD(sequence_num::TEXT, 6, '0');
  RETURN ref_number;
END;
$$ LANGUAGE plpgsql;

-- Comments
COMMENT ON TABLE construction_permits IS 'Construction and renovation permits for households';
COMMENT ON TABLE permit_payments IS 'Road fee payments for construction permits';
