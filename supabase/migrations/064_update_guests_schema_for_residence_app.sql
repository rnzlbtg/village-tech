-- Update guests table schema to support residence app
-- This migration adds/renames columns to match the residence app expected schema

-- Add new columns needed by residence app
ALTER TABLE guests ADD COLUMN IF NOT EXISTS contact_number TEXT;
ALTER TABLE guests ADD COLUMN IF NOT EXISTS visit_type TEXT NOT NULL DEFAULT 'day_trip' CHECK (visit_type IN ('day_trip', 'multi_day'));
ALTER TABLE guests ADD COLUMN IF NOT EXISTS visit_start TIMESTAMPTZ;
ALTER TABLE guests ADD COLUMN IF NOT EXISTS visit_end TIMESTAMPTZ;
ALTER TABLE guests ADD COLUMN IF NOT EXISTS vehicle_plate TEXT;
ALTER TABLE guests ADD COLUMN IF NOT EXISTS check_in_time TIMESTAMPTZ;
ALTER TABLE guests ADD COLUMN IF NOT EXISTS check_out_time TIMESTAMPTZ;

-- Create a function to populate new columns from existing ones
CREATE OR REPLACE FUNCTION populate_residence_guest_columns()
RETURNS VOID AS $$
BEGIN
    -- Update visit_start from scheduled_date if visit_start is NULL
    UPDATE guests
    SET visit_start = scheduled_date
    WHERE visit_start IS NULL AND scheduled_date IS NOT NULL;

    -- For day trips, set visit_end to same day at 11:59 PM
    UPDATE guests
    SET visit_end = (scheduled_date::date + INTERVAL '1 day' - INTERVAL '1 minute')
    WHERE visit_end IS NULL
      AND scheduled_date IS NOT NULL
      AND visit_type = 'day_trip';

    -- For multi-day, set visit_end to next day at same time (as default)
    UPDATE guests
    SET visit_end = scheduled_date + INTERVAL '1 day'
    WHERE visit_end IS NULL
      AND scheduled_date IS NOT NULL
      AND visit_type = 'multi_day';

    -- Copy phone_number to contact_number if contact_number is NULL
    UPDATE guests
    SET contact_number = phone_number
    WHERE contact_number IS NULL AND phone_number IS NOT NULL;

    -- Copy vehicle_info to vehicle_plate if vehicle_plate is NULL
    UPDATE guests
    SET vehicle_plate = vehicle_info
    WHERE vehicle_plate IS NULL AND vehicle_info IS NOT NULL;

    -- Set visit_type based on duration if still default
    UPDATE guests
    SET visit_type = CASE
        WHEN scheduled_date::date = (scheduled_date + INTERVAL '1 day' - INTERVAL '1 minute')::date
        THEN 'day_trip'
        ELSE 'multi_day'
    END
    WHERE visit_type = 'day_trip' AND scheduled_date IS NOT NULL;

    -- Update status values to match residence app expectations
    UPDATE guests
    SET status = 'scheduled'
    WHERE status = 'expected';

    -- Copy actual_arrival to check_in_time if check_in_time is NULL
    UPDATE guests
    SET check_in_time = actual_arrival
    WHERE check_in_time IS NULL AND actual_arrival IS NOT NULL AND status = 'checked_in';

    -- Copy actual_departure to check_out_time if check_out_time is NULL
    UPDATE guests
    SET check_out_time = actual_departure
    WHERE check_out_time IS NULL AND actual_departure IS NOT NULL AND status = 'checked_out';
END;
$$ LANGUAGE plpgsql;

-- Run the population function
SELECT populate_residence_guest_columns();

-- Drop the function after use
DROP FUNCTION populate_residence_guest_columns();

-- Add indexes for new columns
CREATE INDEX IF NOT EXISTS idx_guests_visit_start ON guests(visit_start);
CREATE INDEX IF NOT EXISTS idx_guests_visit_end ON guests(visit_end);
CREATE INDEX IF NOT EXISTS idx_guests_visit_type ON guests(visit_type);
CREATE INDEX IF NOT EXISTS idx_guests_check_in_time ON guests(check_in_time);
CREATE INDEX IF NOT EXISTS idx_guests_check_out_time ON guests(check_out_time);

-- Add comments for new columns
COMMENT ON COLUMN guests.contact_number IS 'Guest contact number (residence app compatibility)';
COMMENT ON COLUMN guests.visit_type IS 'Visit type: day_trip or multi-day (residence app)';
COMMENT ON COLUMN guests.visit_start IS 'Visit start date and time (residence app)';
COMMENT ON COLUMN guests.visit_end IS 'Visit end date and time (residence app)';
COMMENT ON COLUMN guests.vehicle_plate IS 'Vehicle plate number (residence app)';
COMMENT ON COLUMN guests.check_in_time IS 'Actual check-in time (residence app)';
COMMENT ON COLUMN guests.check_out_time IS 'Actual check-out time (residence app)';