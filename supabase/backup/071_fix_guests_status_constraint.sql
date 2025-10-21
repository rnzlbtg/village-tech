-- Fix guests table status constraint to match residence app expectations
-- The residence app uses different status values than the original sentinel app

-- Drop the existing status check constraint
ALTER TABLE guests DROP CONSTRAINT IF EXISTS guests_status_check;

-- Create a new status constraint that matches residence app expectations
ALTER TABLE guests ADD CONSTRAINT guests_status_check
CHECK (status IN ('scheduled', 'checked_in', 'checked_out', 'cancelled'));

-- Update existing records to use residence app status values
UPDATE guests
SET status = 'scheduled'
WHERE status = 'expected';

-- Update comments to clarify the status values
COMMENT ON COLUMN guests.status IS 'Guest visit status: scheduled, checked_in, checked_out, or cancelled (residence app compatibility)';

-- Update views to use the new status values if needed
DROP VIEW IF EXISTS active_guests;
CREATE OR REPLACE VIEW active_guests AS
SELECT
    g.*,
    h.household_name
FROM guests g
JOIN households h ON g.household_id = h.id
WHERE g.status IN ('scheduled', 'checked_in')
  AND g.visit_end >= NOW();

DROP VIEW IF EXISTS today_guests;
CREATE OR REPLACE VIEW today_guests AS
SELECT
    g.*,
    h.household_name
FROM guests g
JOIN households h ON g.household_id = h.id
WHERE DATE(g.visit_start) = CURRENT_DATE
   OR DATE(g.visit_end) = CURRENT_DATE
   OR (g.visit_start <= NOW() AND g.visit_end >= NOW());

-- Recreate household_guests view with updated status handling
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

GRANT SELECT ON household_guests TO authenticated;