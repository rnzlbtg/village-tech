-- Add household-based RLS policies for guests table
-- This allows household heads to manage their own guests

-- First, let household heads view guests for their household only
CREATE POLICY "Household heads can view guests for their household" ON guests
    FOR SELECT USING (
        household_id IN (
            SELECT id FROM households
            WHERE household_head_id = auth.uid()
        )
    );

-- Household heads can insert guests for their household only
CREATE POLICY "Household heads can insert guests for their household" ON guests
    FOR INSERT WITH CHECK (
        household_id IN (
            SELECT id FROM households
            WHERE household_head_id = auth.uid()
        )
    );

-- Household heads can update guests for their household only
CREATE POLICY "Household heads can update guests for their household" ON guests
    FOR UPDATE USING (
        household_id IN (
            SELECT id FROM households
            WHERE household_head_id = auth.uid()
        )
    );

-- Household heads can delete guests for their household only
CREATE POLICY "Household heads can delete guests for their household" ON guests
    FOR DELETE USING (
        household_id IN (
            SELECT id FROM households
            WHERE household_head_id = auth.uid()
        )
    );

-- Update the view definitions to use new columns
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

-- Add household members view for household heads
CREATE OR REPLACE VIEW household_guests AS
SELECT
    g.*,
    h.household_name,
    h.residence_unit_id
FROM guests g
JOIN households h ON g.household_id = h.id
WHERE h.household_head_id = auth.uid()
ORDER BY g.visit_start DESC;

-- Grant permissions on the new view
GRANT SELECT ON household_guests TO authenticated;