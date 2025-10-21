-- Fix guests table contact schema for residence app compatibility
-- This migration adjusts the contact number fields to match residence app expectations

-- Make phone_number nullable (it's currently NOT NULL and causing constraint violations)
ALTER TABLE guests ALTER COLUMN phone_number DROP NOT NULL;

-- Sync existing data: copy phone_number to contact_number if contact_number is NULL
UPDATE guests
SET contact_number = phone_number
WHERE contact_number IS NULL AND phone_number IS NOT NULL;

-- Add a check constraint to ensure at least one contact method is provided
-- This maintains data integrity while allowing flexibility
ALTER TABLE guests ADD CONSTRAINT guests_contact_check
CHECK (contact_number IS NOT NULL OR phone_number IS NOT NULL);

-- Update comments to clarify field usage
COMMENT ON COLUMN guests.contact_number IS 'Primary contact number used by residence app';
COMMENT ON COLUMN guests.phone_number IS 'Legacy phone number field (optional, kept for backward compatibility)';

-- Create a trigger to automatically sync contact_number to phone_number if phone_number is NULL
-- This ensures compatibility with any sentinel app functionality that might still use phone_number
CREATE OR REPLACE FUNCTION sync_guest_contact_number()
RETURNS TRIGGER AS $$
BEGIN
    -- If phone_number is NULL but contact_number is provided, sync it
    IF NEW.phone_number IS NULL AND NEW.contact_number IS NOT NULL THEN
        NEW.phone_number = NEW.contact_number;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically sync contact numbers
CREATE TRIGGER sync_guest_contact_number_trigger
    BEFORE INSERT OR UPDATE ON guests
    FOR EACH ROW
    EXECUTE FUNCTION sync_guest_contact_number();

-- Add index for better query performance on contact_number
CREATE INDEX IF NOT EXISTS idx_guests_contact_number ON guests(contact_number) WHERE contact_number IS NOT NULL;