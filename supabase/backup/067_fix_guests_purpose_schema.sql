-- Fix guests table purpose field to make it optional for residence app
-- This migration makes purpose nullable as it should be optional in the UI

-- Make purpose nullable (it's currently NOT NULL and causing constraint violations)
ALTER TABLE guests ALTER COLUMN purpose DROP NOT NULL;

-- For existing records that have NULL purpose, set a default value for consistency
UPDATE guests
SET purpose = 'Visit'
WHERE purpose IS NULL;

-- Add comment clarifying that purpose is optional
COMMENT ON COLUMN guests.purpose IS 'Purpose of visit (optional for residence app)';

-- Note: The contact number sync trigger and indexes were already created in migration 066,
-- so no need to recreate them here.