-- RLS Policies for Guest Management System
-- Ensures multi-tenant data isolation for guest management tables

-- Enable RLS on all guest management tables
ALTER TABLE guests ENABLE ROW LEVEL SECURITY;
ALTER TABLE guest_checkin_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE guest_verification_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE household_contact_logs ENABLE ROW LEVEL SECURITY;

-- Guest table RLS policies
CREATE POLICY "Users can view guests for their tenant only" ON guests
    FOR SELECT USING (
        tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
    );

CREATE POLICY "Users can insert guests for their tenant only" ON guests
    FOR INSERT WITH CHECK (
        tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
    );

CREATE POLICY "Users can update guests for their tenant only" ON guests
    FOR UPDATE USING (
        tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
    );

CREATE POLICY "Users can delete guests for their tenant only" ON guests
    FOR DELETE USING (
        tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
    );

-- Guest check-in logs RLS policies
CREATE POLICY "Users can view check-in logs for their tenant only" ON guest_checkin_logs
    FOR SELECT USING (
        tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
    );

CREATE POLICY "Users can insert check-in logs for their tenant only" ON guest_checkin_logs
    FOR INSERT WITH CHECK (
        tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
    );

-- Guest verification photos RLS policies
CREATE POLICY "Users can view photos for their tenant only" ON guest_verification_photos
    FOR SELECT USING (
        tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
    );

CREATE POLICY "Users can insert photos for their tenant only" ON guest_verification_photos
    FOR INSERT WITH CHECK (
        tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
    );

-- Household contact logs RLS policies
CREATE POLICY "Users can view contact logs for their tenant only" ON household_contact_logs
    FOR SELECT USING (
        tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
    );

CREATE POLICY "Users can insert contact logs for their tenant only" ON household_contact_logs
    FOR INSERT WITH CHECK (
        tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
    );

-- Functions for automatic timestamp updates
CREATE OR REPLACE FUNCTION update_guests_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger for automatic updated_at timestamp on guests
CREATE TRIGGER update_guests_updated_at
    BEFORE UPDATE ON guests
    FOR EACH ROW
    EXECUTE FUNCTION update_guests_updated_at();

-- Views for common queries
CREATE OR REPLACE VIEW active_guests AS
SELECT
    g.*,
    h.household_name
FROM guests g
JOIN households h ON g.household_id = h.id
WHERE g.status IN ('expected', 'checked_in');

CREATE OR REPLACE VIEW today_guests AS
SELECT
    g.*,
    h.household_name
FROM guests g
JOIN households h ON g.household_id = h.id
WHERE DATE(g.scheduled_date) = CURRENT_DATE
  OR DATE(g.actual_arrival) = CURRENT_DATE;

-- Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON guests TO authenticated;
GRANT SELECT, INSERT ON guest_checkin_logs TO authenticated;
GRANT SELECT, INSERT ON guest_verification_photos TO authenticated;
GRANT SELECT, INSERT ON household_contact_logs TO authenticated;
GRANT SELECT ON active_guests TO authenticated;
GRANT SELECT ON today_guests TO authenticated;