-- Migration 033: Create entry_logs table
-- Purpose: Complete audit trail of all gate activities

CREATE TABLE IF NOT EXISTS entry_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE NOT NULL,
  guard_id UUID REFERENCES guards(id) ON DELETE SET NULL NOT NULL,
  entry_type TEXT NOT NULL CHECK (entry_type IN ('resident', 'guest', 'delivery', 'construction', 'other')),
  person_name TEXT NOT NULL,
  vehicle_info TEXT,
  rfid_sticker_id UUID REFERENCES rfid_stickers(id) ON DELETE SET NULL,
  guest_id UUID, -- Will reference guest_registrations when created
  delivery_id UUID, -- Will reference delivery_logs when created
  construction_permit_id UUID, -- Will reference construction_permits when created
  destination TEXT NOT NULL,
  purpose TEXT,
  verification_method TEXT NOT NULL CHECK (verification_method IN ('rfid', 'manual', 'phone_call', 'permit')),
  verification_status TEXT NOT NULL CHECK (verification_status IN ('verified', 'pending', 'denied')),
  entry_time TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  exit_time TIMESTAMPTZ,
  duration_on_site INTERVAL,
  notes TEXT,
  metadata JSONB DEFAULT '{}',
  synced BOOLEAN DEFAULT true NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE entry_logs ENABLE ROW LEVEL SECURITY;

-- Create indexes for performance
CREATE INDEX idx_entry_logs_tenant_id ON entry_logs(tenant_id);
CREATE INDEX idx_entry_logs_guard_id ON entry_logs(guard_id);
CREATE INDEX idx_entry_logs_entry_time ON entry_logs(entry_time);
CREATE INDEX idx_entry_logs_exit_time ON entry_logs(exit_time);
CREATE INDEX idx_entry_logs_entry_type ON entry_logs(entry_type);
CREATE INDEX idx_entry_logs_verification_status ON entry_logs(verification_status);
CREATE INDEX idx_entry_logs_rfid_sticker_id ON entry_logs(rfid_sticker_id);
CREATE INDEX idx_entry_logs_synced ON entry_logs(synced);

-- Composite indexes for common queries
CREATE INDEX idx_entry_logs_tenant_entry_time ON entry_logs(tenant_id, entry_time);
CREATE INDEX idx_entry_logs_today_entries ON entry_logs(tenant_id, entry_time)
  WHERE entry_time >= CURRENT_DATE;
CREATE INDEX idx_entry_logs_active_entries ON entry_logs(tenant_id, entry_time, exit_time)
  WHERE exit_time IS NULL;

-- RLS Policies
CREATE POLICY "Guards can view tenant entry logs" ON entry_logs
  FOR SELECT USING (
    tenant_id = current_setting('app.current_tenant_id', true)::uuid
  );

CREATE POLICY "Guards can insert tenant entry logs" ON entry_logs
  FOR INSERT WITH CHECK (
    tenant_id = current_setting('app.current_tenant_id', true)::uuid
  );

CREATE POLICY "Guards can update tenant entry logs" ON entry_logs
  FOR UPDATE USING (
    tenant_id = current_setting('app.current_tenant_id', true)::uuid
  );

-- Entry logs should never be deleted, only archived
CREATE POLICY "Guards cannot delete entry logs" ON entry_logs
  FOR DELETE USING (false);

CREATE POLICY "Admins can manage entry logs" ON entry_logs
  FOR SELECT USING (
    auth.jwt() ->> 'role' = 'admin' AND
    tenant_id = current_setting('app.current_tenant_id', true)::uuid
  );

-- Update timestamp trigger
CREATE TRIGGER update_entry_logs_updated_at
    BEFORE UPDATE ON entry_logs
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to calculate duration_on_site automatically
CREATE OR REPLACE FUNCTION calculate_duration_on_site()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.exit_time IS NOT NULL AND OLD.exit_time IS NULL THEN
        NEW.duration_on_site = NEW.exit_time - NEW.entry_time;
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to calculate duration when exit_time is set
CREATE TRIGGER trigger_calculate_duration
    BEFORE UPDATE ON entry_logs
    FOR EACH ROW
    EXECUTE FUNCTION calculate_duration_on_site();

-- Function to get today's entries for a tenant
CREATE OR REPLACE FUNCTION get_todays_entries(p_tenant_id UUID)
RETURNS TABLE (
  id UUID,
  guard_id UUID,
  entry_type TEXT,
  person_name TEXT,
  destination TEXT,
  verification_status TEXT,
  entry_time TIMESTAMPTZ,
  exit_time TIMESTAMPTZ,
  duration_on_site INTERVAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT
      el.id,
      el.guard_id,
      el.entry_type,
      el.person_name,
      el.destination,
      el.verification_status,
      el.entry_time,
      el.exit_time,
      el.duration_on_site
    FROM entry_logs el
    WHERE el.tenant_id = p_tenant_id
      AND el.entry_time >= CURRENT_DATE
      AND el.entry_time < CURRENT_DATE + INTERVAL '1 day'
    ORDER BY el.entry_time DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Comments
COMMENT ON TABLE entry_logs IS 'Complete audit trail of all gate activities';
COMMENT ON COLUMN entry_logs.id IS 'Unique identifier for the entry log';
COMMENT ON COLUMN entry_logs.tenant_id IS 'Associated tenant/community';
COMMENT ON COLUMN entry_logs.guard_id IS 'Guard who processed the entry';
COMMENT ON COLUMN entry_logs.entry_type IS 'Type of entry: resident, guest, delivery, construction, other';
COMMENT ON COLUMN entry_logs.person_name IS 'Name of the person entering';
COMMENT ON COLUMN entry_logs.vehicle_info IS 'Vehicle details if applicable';
COMMENT ON COLUMN entry_logs.rfid_sticker_id IS 'RFID sticker used for verification';
COMMENT ON COLUMN entry_logs.guest_id IS 'Guest registration reference';
COMMENT ON COLUMN entry_logs.delivery_id IS 'Delivery log reference';
COMMENT ON COLUMN entry_logs.construction_permit_id IS 'Construction permit reference';
COMMENT ON COLUMN entry_logs.destination IS 'Destination household/location';
COMMENT ON COLUMN entry_logs.purpose IS 'Purpose of entry';
COMMENT ON COLUMN entry_logs.verification_method IS 'Method used for verification: rfid, manual, phone_call, permit';
COMMENT ON COLUMN entry_logs.verification_status IS 'Verification result: verified, pending, denied';
COMMENT ON COLUMN entry_logs.entry_time IS 'Entry timestamp';
COMMENT ON COLUMN entry_logs.exit_time IS 'Exit timestamp';
COMMENT ON COLUMN entry_logs.duration_on_site IS 'Calculated time spent on site';
COMMENT ON COLUMN entry_logs.notes IS 'Guard notes and observations';
COMMENT ON COLUMN entry_logs.metadata IS 'Additional data in JSON format';
COMMENT ON COLUMN entry_logs.synced IS 'Server synchronization status';
COMMENT ON COLUMN entry_logs.created_at IS 'Record creation timestamp';
COMMENT ON COLUMN entry_logs.updated_at IS 'Last update timestamp';