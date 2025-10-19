-- Migration 032: Create rfid_stickers table
-- Purpose: Vehicle RFID stickers for resident access control

CREATE TABLE IF NOT EXISTS rfid_stickers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE NOT NULL,
  sticker_code TEXT UNIQUE NOT NULL,
  resident_id UUID NOT NULL, -- References residence unit or household
  vehicle_info TEXT,
  license_plate TEXT,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'expired', 'disabled', 'lost')),
  issued_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL,
  last_used_at TIMESTAMPTZ,
  issued_by_guard_id UUID REFERENCES guards(id) ON DELETE SET NULL,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE rfid_stickers ENABLE ROW LEVEL SECURITY;

-- Create indexes for performance
CREATE INDEX idx_rfid_stickers_tenant_id ON rfid_stickers(tenant_id);
CREATE INDEX idx_rfid_stickers_sticker_code ON rfid_stickers(sticker_code);
CREATE INDEX idx_rfid_stickers_status ON rfid_stickers(status);
CREATE INDEX idx_rfid_stickers_resident_id ON rfid_stickers(resident_id);
CREATE INDEX idx_rfid_stickers_expires_at ON rfid_stickers(expires_at);
CREATE INDEX idx_rfid_stickers_last_used_at ON rfid_stickers(last_used_at);

-- Composite indexes for common queries
CREATE INDEX idx_rfid_stickers_tenant_status ON rfid_stickers(tenant_id, status);
CREATE INDEX idx_rfid_stickers_active_expires ON rfid_stickers(status, expires_at) WHERE status = 'active';

-- RLS Policies
CREATE POLICY "Guards can view tenant RFID stickers" ON rfid_stickers
  FOR SELECT USING (
    tenant_id = current_setting('app.current_tenant_id', true)::uuid
  );

CREATE POLICY "Guards can insert tenant RFID stickers" ON rfid_stickers
  FOR INSERT WITH CHECK (
    tenant_id = current_setting('app.current_tenant_id', true)::uuid
  );

CREATE POLICY "Guards can update tenant RFID stickers" ON rfid_stickers
  FOR UPDATE USING (
    tenant_id = current_setting('app.current_tenant_id', true)::uuid
  );

CREATE POLICY "Admins can manage RFID stickers" ON rfid_stickers
  FOR ALL USING (
    auth.jwt() ->> 'role' = 'admin' AND
    tenant_id = current_setting('app.current_tenant_id', true)::uuid
  );

-- Update timestamp trigger
CREATE TRIGGER update_rfid_stickers_updated_at
    BEFORE UPDATE ON rfid_stickers
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to update last_used_at when verified
CREATE OR REPLACE FUNCTION update_rfid_last_used()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_used_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to automatically update last_used_at when sticker is used in entry logs
CREATE TRIGGER trigger_update_rfid_last_used
    AFTER INSERT ON entry_logs
    FOR EACH ROW
    WHEN (NEW.rfid_sticker_id IS NOT NULL)
    EXECUTE FUNCTION update_rfid_last_used();

-- Comments
COMMENT ON TABLE rfid_stickers IS 'Vehicle RFID stickers for resident access control';
COMMENT ON COLUMN rfid_stickers.id IS 'Unique identifier for the RFID sticker';
COMMENT ON COLUMN rfid_stickers.tenant_id IS 'Associated tenant/community';
COMMENT ON COLUMN rfid_stickers.sticker_code IS 'Unique RFID identifier code';
COMMENT ON COLUMN rfid_stickers.resident_id IS 'Associated resident (household or residence unit)';
COMMENT ON COLUMN rfid_stickers.vehicle_info IS 'Vehicle make/model/color information';
COMMENT ON COLUMN rfid_stickers.license_plate IS 'Vehicle license plate number';
COMMENT ON COLUMN rfid_stickers.status IS 'Sticker status: active, expired, disabled, lost';
COMMENT ON COLUMN rfid_stickers.issued_at IS 'Sticker issue date';
COMMENT ON COLUMN rfid_stickers.expires_at IS 'Sticker expiration date';
COMMENT ON COLUMN rfid_stickers.last_used_at IS 'Last successful scan timestamp';
COMMENT ON COLUMN rfid_stickers.issued_by_guard_id IS 'Guard who issued the sticker';
COMMENT ON COLUMN rfid_stickers.metadata IS 'Additional properties in JSON format';
COMMENT ON COLUMN rfid_stickers.created_at IS 'Record creation timestamp';
COMMENT ON COLUMN rfid_stickers.updated_at IS 'Last update timestamp';