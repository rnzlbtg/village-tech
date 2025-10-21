-- Fix guests table scheduled_date field for residence app compatibility
-- This migration makes scheduled_date nullable and syncs it with visit_start

-- Make scheduled_date nullable (it's currently NOT NULL and causing constraint violations)
ALTER TABLE guests ALTER COLUMN scheduled_date DROP NOT NULL;

-- Create a trigger to automatically sync scheduled_date from visit_start
-- This maintains compatibility with sentinel app while allowing residence app flexibility
CREATE OR REPLACE FUNCTION sync_guest_scheduled_date()
RETURNS TRIGGER AS $$
BEGIN
    -- If scheduled_date is NULL but visit_start is provided, sync it
    IF NEW.scheduled_date IS NULL AND NEW.visit_start IS NOT NULL THEN
        NEW.scheduled_date = NEW.visit_start;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically sync scheduled_date
CREATE TRIGGER sync_guest_scheduled_date_trigger
    BEFORE INSERT OR UPDATE ON guests
    FOR EACH ROW
    EXECUTE FUNCTION sync_guest_scheduled_date();

-- Sync existing records: update scheduled_date from visit_start for any NULL values
UPDATE guests
SET scheduled_date = visit_start
WHERE scheduled_date IS NULL AND visit_start IS NOT NULL;

-- For records that still have NULL scheduled_date (no visit_start either), set to current date
UPDATE guests
SET scheduled_date = CURRENT_DATE
WHERE scheduled_date IS NULL;

-- Add comment clarifying field usage
COMMENT ON COLUMN guests.scheduled_date IS 'Legacy scheduled date (auto-synced from visit_start, kept for sentinel app compatibility)';
COMMENT ON COLUMN guests.visit_start IS 'Primary visit start date/time used by residence app';