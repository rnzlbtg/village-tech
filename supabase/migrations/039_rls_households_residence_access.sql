-- Add RLS policies for household heads to view their own household data
-- This allows residence app users to access their household information

-- Drop existing policies if they exist (to make migration idempotent)
DROP POLICY IF EXISTS "Household heads can view their own household" ON households;
DROP POLICY IF EXISTS "Household heads can view their residence unit" ON residence_units;
DROP POLICY IF EXISTS "Household heads can view their property" ON properties;

-- Allow household heads to view their own household
CREATE POLICY "Household heads can view their own household"
  ON households
  FOR SELECT
  USING (
    household_head_id = auth.uid()
  );

-- Allow household heads to view their residence unit
CREATE POLICY "Household heads can view their residence unit"
  ON residence_units
  FOR SELECT
  USING (
    id IN (
      SELECT residence_unit_id
      FROM households
      WHERE household_head_id = auth.uid()
    )
  );

-- Allow household heads to view their property
CREATE POLICY "Household heads can view their property"
  ON properties
  FOR SELECT
  USING (
    id IN (
      SELECT ru.property_id
      FROM residence_units ru
      INNER JOIN households h ON h.residence_unit_id = ru.id
      WHERE h.household_head_id = auth.uid()
    )
  );

-- Add helpful comment
COMMENT ON POLICY "Household heads can view their own household" ON households IS 'Allows residence app users to view their own household data';
COMMENT ON POLICY "Household heads can view their residence unit" ON residence_units IS 'Allows residence app users to view their residence unit data';
COMMENT ON POLICY "Household heads can view their property" ON properties IS 'Allows residence app users to view their property data';
