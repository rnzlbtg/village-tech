-- Migration: 042_rls_household_members_household_access.sql
-- Description: Add RLS policies for household heads to read sticker programs
-- Author: Residence App Implementation
-- Date: 2025-10-15

-- Add RLS policies for household heads to read sticker programs
-- This allows residence app users to see their sticker allocation programs

-- Drop existing policies if they exist (to make migration idempotent)
DROP POLICY IF EXISTS "Household heads can view sticker programs" ON sticker_programs;

-- Allow household heads to view sticker programs for their tenant
CREATE POLICY "Household heads can view sticker programs"
  ON sticker_programs
  FOR SELECT
  USING (
    tenant_id IN (
      SELECT p.tenant_id
      FROM households h
      INNER JOIN residence_units ru ON ru.id = h.residence_unit_id
      INNER JOIN properties p ON p.id = ru.property_id
      WHERE h.household_head_id = auth.uid()
    )
  );

-- Add helpful comment
COMMENT ON POLICY "Household heads can view sticker programs" ON sticker_programs IS 'Allows residence app users to view sticker programs for their tenant (but not modify them)';