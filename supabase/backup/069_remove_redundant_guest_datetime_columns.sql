-- Remove redundant datetime columns from guests table
-- These columns are legacy from sentinel app and are replaced by visit_start/visit_end in residence app

-- First drop any existing triggers that reference these columns
DROP TRIGGER IF EXISTS sync_guest_scheduled_date_trigger ON guests;
DROP FUNCTION IF EXISTS sync_guest_scheduled_date();

-- Drop ALL views that depend on the columns we're removing
DROP VIEW IF EXISTS active_guests;
DROP VIEW IF EXISTS today_guests;
DROP VIEW IF EXISTS household_guests;

-- Drop indexes that reference these columns if they exist
DROP INDEX IF EXISTS idx_guests_scheduled_date;

-- Now drop the redundant columns
ALTER TABLE guests DROP COLUMN IF EXISTS scheduled_date;
ALTER TABLE guests DROP COLUMN IF EXISTS expected_arrival;
ALTER TABLE guests DROP COLUMN IF EXISTS expected_departure;

-- Recreate views with the new schema
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

-- Update comments to clarify the datetime fields
COMMENT ON COLUMN guests.visit_start IS 'Primary visit start date and time';
COMMENT ON COLUMN guests.visit_end IS 'Primary visit end date and time';
COMMENT ON COLUMN guests.check_in_time IS 'Actual check-in time (when guest arrives)';
COMMENT ON COLUMN guests.check_out_time IS 'Actual check-out time (when guest leaves)';

-- Grant permissions on the updated view
GRANT SELECT ON household_guests TO authenticated;