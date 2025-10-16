-- Migration: 023_create_households.sql
-- Description: Create households and household_members tables for resident family management
-- Author: Admin App Implementation
-- Date: 2025-10-12

-- Households table: Links families to residence units
CREATE TABLE IF NOT EXISTS households (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  residence_unit_id UUID NOT NULL REFERENCES residence_units(id) ON DELETE CASCADE,
  household_head_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  household_name TEXT NOT NULL,
  move_in_date DATE,
  move_out_date DATE,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'moved_out')),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Partial unique index: Only one active household per residence unit
CREATE UNIQUE INDEX idx_households_active_residence_unit
  ON households(residence_unit_id)
  WHERE status = 'active';

-- Household members table: Family members within a household
CREATE TABLE IF NOT EXISTS household_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  household_id UUID NOT NULL REFERENCES households(id) ON DELETE CASCADE,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  relationship TEXT NOT NULL CHECK (relationship IN ('head', 'spouse', 'child', 'parent', 'sibling', 'relative', 'helper', 'tenant')),
  date_of_birth DATE,
  phone_number TEXT,
  email TEXT,
  is_primary_contact BOOLEAN DEFAULT FALSE,
  id_document_type TEXT,
  id_document_number TEXT,
  emergency_contact_name TEXT,
  emergency_contact_phone TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for households
CREATE INDEX idx_households_tenant ON households(tenant_id);
CREATE INDEX idx_households_residence_unit ON households(residence_unit_id);
CREATE INDEX idx_households_household_head ON households(household_head_id);
CREATE INDEX idx_households_status ON households(tenant_id, status);

-- Indexes for household_members
CREATE INDEX idx_household_members_household ON household_members(household_id);
CREATE INDEX idx_household_members_relationship ON household_members(household_id, relationship);
CREATE INDEX idx_household_members_email ON household_members(email) WHERE email IS NOT NULL;

-- Trigger for updated_at
CREATE TRIGGER update_households_updated_at
  BEFORE UPDATE ON households
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_household_members_updated_at
  BEFORE UPDATE ON household_members
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Comments
COMMENT ON TABLE households IS 'Family units residing in the community';
COMMENT ON TABLE household_members IS 'Individual members of each household';
COMMENT ON COLUMN households.status IS 'active: currently residing, inactive: temporarily away, moved_out: permanently left';
