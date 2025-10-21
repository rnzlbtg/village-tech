-- Consolidated migration to fix guests table schema for residence app compatibility
-- This combines fixes from migrations 066-071 to resolve all constraint violations

-- =====================================================
-- STEP 1: Fix contact number schema
-- =====================================================

-- Make phone_number nullable (it's currently NOT NULL and causing constraint violations)
ALTER TABLE guests ALTER COLUMN phone_number DROP NOT NULL;

-- Make purpose nullable (it's currently NOT NULL and causing constraint violations)
ALTER TABLE guests ALTER COLUMN purpose DROP NOT NULL;

-- Remove existing check constraints that are causing issues
ALTER TABLE guests DROP CONSTRAINT IF EXISTS guests_contact_check;
ALTER TABLE guests DROP CONSTRAINT IF EXISTS guests_status_check;

-- =====================================================
-- STEP 2: Drop redundant datetime columns and dependencies
-- =====================================================

-- Drop any existing triggers that reference the columns we're removing
DROP TRIGGER IF EXISTS sync_guest_scheduled_date_trigger ON guests;
DROP TRIGGER IF EXISTS sync_guest_contact_number_trigger ON guests;
DROP FUNCTION IF EXISTS sync_guest_scheduled_date();
DROP FUNCTION IF EXISTS sync_guest_contact_number();

-- Drop ALL views that depend on the columns we're removing
DROP VIEW IF EXISTS active_guests;
DROP VIEW IF EXISTS today_guests;
DROP VIEW IF EXISTS household_guests;

-- Drop indexes that reference columns we're removing
DROP INDEX IF EXISTS idx_guests_scheduled_date;

-- Drop the redundant datetime columns
ALTER TABLE guests DROP COLUMN IF EXISTS scheduled_date;
ALTER TABLE guests DROP COLUMN IF EXISTS expected_arrival;
ALTER TABLE guests DROP COLUMN IF EXISTS expected_departure;

-- =====================================================
-- STEP 3: Fix status constraint for residence app
-- =====================================================

-- Create a new status constraint that matches residence app expectations
ALTER TABLE guests ADD CONSTRAINT guests_status_check
CHECK (status IN ('scheduled', 'checked_in', 'checked_out', 'cancelled'));

-- Update existing records to use residence app status values
UPDATE guests
SET status = 'scheduled'
WHERE status = 'expected';

-- =====================================================
-- STEP 4: Sync existing data and clean up
-- =====================================================

-- Sync existing data: copy phone_number to contact_number if contact_number is NULL
UPDATE guests
SET contact_number = phone_number
WHERE contact_number IS NULL AND phone_number IS NOT NULL;

-- For existing records that have NULL purpose, set a default value for consistency
UPDATE guests
SET purpose = 'Visit'
WHERE purpose IS NULL;

-- =====================================================
-- STEP 5: Recreate views with new schema
-- =====================================================

-- Update active_guests view to use visit_start/visit_end instead
CREATE OR REPLACE VIEW active_guests AS
SELECT
    g.*,
    h.household_name
FROM guests g
JOIN households h ON g.household_id = h.id
WHERE g.status IN ('scheduled', 'checked_in')
  AND g.visit_end >= NOW();

-- Update today_guests view to use visit_start/visit_end instead
CREATE OR REPLACE VIEW today_guests AS
SELECT
    g.*,
    h.household_name
FROM guests g
JOIN households h ON g.household_id = h.id
WHERE DATE(g.visit_start) = CURRENT_DATE
   OR DATE(g.visit_end) = CURRENT_DATE
   OR (g.visit_start <= NOW() AND g.visit_end >= NOW());

-- Recreate household_guests view without the removed columns
CREATE OR REPLACE VIEW household_guests AS
SELECT
    g.id,
    g.tenant_id,
    g.household_id,
    g.guest_name,
    g.phone_number,
    g.purpose,
    g.status,
    g.vehicle_info,
    g.notes,
    g.approved_by_guard_id,
    g.actual_arrival,
    g.actual_departure,
    g.contact_number,
    g.visit_type,
    g.visit_start,
    g.visit_end,
    g.vehicle_plate,
    g.check_in_time,
    g.check_out_time,
    g.created_at,
    g.updated_at,
    h.household_name,
    h.residence_unit_id
FROM guests g
JOIN households h ON g.household_id = h.id
WHERE h.household_head_id = auth.uid()
ORDER BY g.visit_start DESC;

-- =====================================================
-- STEP 6: Add indexes for performance
-- =====================================================

-- Add indexes for new columns
CREATE INDEX IF NOT EXISTS idx_guests_visit_start ON guests(visit_start);
CREATE INDEX IF NOT EXISTS idx_guests_visit_end ON guests(visit_end);
CREATE INDEX IF NOT EXISTS idx_guests_visit_type ON guests(visit_type);
CREATE INDEX IF NOT EXISTS idx_guests_check_in_time ON guests(check_in_time);
CREATE INDEX IF NOT EXISTS idx_guests_check_out_time ON guests(check_out_time);
CREATE INDEX IF NOT EXISTS idx_guests_contact_number ON guests(contact_number) WHERE contact_number IS NOT NULL;

-- =====================================================
-- STEP 7: Update comments to clarify field usage
-- =====================================================

-- Update comments to clarify field usage
COMMENT ON COLUMN guests.contact_number IS 'Primary contact number used by residence app (completely optional)';
COMMENT ON COLUMN guests.phone_number IS 'Legacy phone number field (optional, kept for backward compatibility)';
COMMENT ON COLUMN guests.purpose IS 'Purpose of visit (optional for residence app)';
COMMENT ON COLUMN guests.status IS 'Guest visit status: scheduled, checked_in, checked_out, or cancelled (residence app compatibility)';
COMMENT ON COLUMN guests.visit_start IS 'Primary visit start date and time';
COMMENT ON COLUMN guests.visit_end IS 'Primary visit end date and time';
COMMENT ON COLUMN guests.check_in_time IS 'Actual check-in time (when guest arrives)';
COMMENT ON COLUMN guests.check_out_time IS 'Actual check-out time (when guest leaves)';

-- =====================================================
-- STEP 8: Grant permissions
-- =====================================================

-- Grant permissions on the views
GRANT SELECT ON active_guests TO authenticated;
GRANT SELECT ON today_guests TO authenticated;
GRANT SELECT ON household_guests TO authenticated;