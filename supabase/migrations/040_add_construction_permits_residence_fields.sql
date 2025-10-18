-- Migration: 040_add_construction_permits_residence_fields.sql
-- Description: Add fields to construction_permits for residence app compatibility
-- Author: Residence App Implementation
-- Date: 2025-10-15

-- Add contractor fields (not required for admin-created permits, but needed for residence app)
ALTER TABLE construction_permits
  ADD COLUMN IF NOT EXISTS contractor_name TEXT,
  ADD COLUMN IF NOT EXISTS contractor_contact TEXT,
  ADD COLUMN IF NOT EXISTS estimated_workers INTEGER;

-- Make permit_reference nullable and auto-generate if not provided
ALTER TABLE construction_permits
  ALTER COLUMN permit_reference DROP NOT NULL;

-- Create trigger to auto-generate permit reference if not provided
CREATE OR REPLACE FUNCTION auto_generate_permit_reference()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.permit_reference IS NULL THEN
    NEW.permit_reference := generate_permit_reference();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_auto_generate_permit_reference
  BEFORE INSERT ON construction_permits
  FOR EACH ROW
  EXECUTE FUNCTION auto_generate_permit_reference();

-- Add RLS policies for household heads to access their own permits
CREATE POLICY "Household heads can view their permits"
  ON construction_permits
  FOR SELECT
  USING (
    household_id IN (
      SELECT id FROM households WHERE household_head_id = auth.uid()
    )
  );

CREATE POLICY "Household heads can insert permits"
  ON construction_permits
  FOR INSERT
  WITH CHECK (
    household_id IN (
      SELECT id FROM households WHERE household_head_id = auth.uid()
    )
  );

CREATE POLICY "Household heads can update their pending permits"
  ON construction_permits
  FOR UPDATE
  USING (
    household_id IN (
      SELECT id FROM households WHERE household_head_id = auth.uid()
    )
    AND permit_status = 'pending'
  );

CREATE POLICY "Household heads can delete their pending permits"
  ON construction_permits
  FOR DELETE
  USING (
    household_id IN (
      SELECT id FROM households WHERE household_head_id = auth.uid()
    )
    AND permit_status = 'pending'
  );

-- Add comments
COMMENT ON COLUMN construction_permits.contractor_name IS 'Contractor name (for residence app submissions)';
COMMENT ON COLUMN construction_permits.contractor_contact IS 'Contractor contact info (for residence app submissions)';
COMMENT ON COLUMN construction_permits.estimated_workers IS 'Estimated number of workers (for residence app submissions)';
