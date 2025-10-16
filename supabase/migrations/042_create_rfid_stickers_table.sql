-- Migration: 042_create_rfid_stickers_table.sql
-- Description: Create rfid_stickers table for tracking physical RFID stickers
-- Author: Admin App Sticker Distribution
-- Date: 2025-10-15

-- Create rfid_stickers table
CREATE TABLE rfid_stickers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    household_id UUID NOT NULL REFERENCES households(id) ON DELETE CASCADE,
    sticker_request_id UUID REFERENCES sticker_requests(id) ON DELETE SET NULL,
    sticker_code TEXT NOT NULL UNIQUE,
    vehicle_plate TEXT,
    vehicle_make TEXT,
    vehicle_model TEXT,
    vehicle_color TEXT,
    vehicle_type TEXT,
    owner_name TEXT,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'lost', 'damaged', 'expired', 'revoked')),
    issued_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    last_scanned_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_rfid_stickers_tenant ON rfid_stickers(tenant_id);
CREATE INDEX idx_rfid_stickers_household ON rfid_stickers(household_id);
CREATE INDEX idx_rfid_stickers_code ON rfid_stickers(sticker_code);
CREATE INDEX idx_rfid_stickers_status ON rfid_stickers(status);
CREATE INDEX idx_rfid_stickers_request ON rfid_stickers(sticker_request_id);

-- Create trigger for updated_at
CREATE TRIGGER update_rfid_stickers_updated_at
    BEFORE UPDATE ON rfid_stickers
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Add RLS policies
ALTER TABLE rfid_stickers ENABLE ROW LEVEL SECURITY;

-- Policy: Admins can view all rfid stickers for their tenant
CREATE POLICY "Admins can view rfid stickers in their tenant"
ON rfid_stickers
FOR SELECT
TO authenticated
USING (
    tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
    AND (
        COALESCE(
            (auth.jwt() -> 'app_metadata' ->> 'role')::TEXT,
            (auth.jwt() ->> 'app_role')::TEXT
        ) IN ('admin_head', 'admin_officer')
    )
);

-- Policy: Admins can manage rfid stickers in their tenant
CREATE POLICY "Admins can manage rfid stickers in their tenant"
ON rfid_stickers
FOR ALL
TO authenticated
USING (
    tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
    AND (
        COALESCE(
            (auth.jwt() -> 'app_metadata' ->> 'role')::TEXT,
            (auth.jwt() ->> 'app_role')::TEXT
        ) IN ('admin_head', 'admin_officer')
    )
)
WITH CHECK (
    tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
    AND (
        COALESCE(
            (auth.jwt() -> 'app_metadata' ->> 'role')::TEXT,
            (auth.jwt() ->> 'app_role')::TEXT
        ) IN ('admin_head', 'admin_officer')
    )
);

COMMENT ON TABLE rfid_stickers IS 'Table for tracking physical RFID stickers issued to households';
COMMENT ON COLUMN rfid_stickers.status IS 'Status of the RFID sticker: active, lost, damaged, expired, revoked';
COMMENT ON COLUMN rfid_stickers.expires_at IS 'When the RFID sticker expires (if applicable)';
COMMENT ON COLUMN rfid_stickers.last_scanned_at IS 'Last time the sticker was scanned by gate system';