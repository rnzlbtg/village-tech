-- Remove the guest contact check constraint that's preventing NULL contact numbers
-- The residence app treats contact number as completely optional

-- Drop the constraint that requires at least one contact number
ALTER TABLE guests DROP CONSTRAINT IF EXISTS guests_contact_check;

-- Update the trigger to be more flexible - only sync if contact_number is provided
DROP TRIGGER IF EXISTS sync_guest_contact_number_trigger ON guests;
DROP FUNCTION IF EXISTS sync_guest_contact_number();

-- Recreate the trigger with optional sync behavior
CREATE OR REPLACE FUNCTION sync_guest_contact_number()
RETURNS TRIGGER AS $$
BEGIN
    -- Only sync contact_number to phone_number if contact_number is provided
    -- This maintains compatibility while allowing both to be NULL
    IF NEW.contact_number IS NOT NULL THEN
        NEW.phone_number = NEW.contact_number;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recreate trigger with more flexible behavior
CREATE TRIGGER sync_guest_contact_number_trigger
    BEFORE INSERT OR UPDATE ON guests
    FOR EACH ROW
    EXECUTE FUNCTION sync_guest_contact_number();

-- Update comments to reflect that contact is truly optional
COMMENT ON COLUMN guests.contact_number IS 'Guest contact number (completely optional for residence app)';
COMMENT ON COLUMN guests.phone_number IS 'Legacy phone number field (optional, synced from contact_number when provided)';