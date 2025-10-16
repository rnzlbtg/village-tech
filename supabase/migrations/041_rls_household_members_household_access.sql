-- Migration: 041_rls_household_members_household_access.sql
-- Description: Add RLS policies for household heads to manage their household members
-- Author: Residence App Implementation
-- Date: 2025-10-15

-- Add RLS policies for household heads to manage their own household members
-- This allows residence app users to add/edit/delete household members

-- Drop existing policies if they exist (to make migration idempotent)
DROP POLICY IF EXISTS "Household heads can view their household members" ON household_members;
DROP POLICY IF EXISTS "Household heads can insert household members" ON household_members;
DROP POLICY IF EXISTS "Household heads can update household members" ON household_members;
DROP POLICY IF EXISTS "Household heads can delete household members" ON household_members;

-- Allow household heads to view their household members
CREATE POLICY "Household heads can view their household members"
  ON household_members
  FOR SELECT
  USING (
    household_id IN (
      SELECT id FROM households WHERE household_head_id = auth.uid()
    )
  );

-- Allow household heads to insert household members
CREATE POLICY "Household heads can insert household members"
  ON household_members
  FOR INSERT
  WITH CHECK (
    household_id IN (
      SELECT id FROM households WHERE household_head_id = auth.uid()
    )
  );

-- Allow household heads to update household members
CREATE POLICY "Household heads can update household members"
  ON household_members
  FOR UPDATE
  USING (
    household_id IN (
      SELECT id FROM households WHERE household_head_id = auth.uid()
    )
  );

-- Allow household heads to delete household members
CREATE POLICY "Household heads can delete household members"
  ON household_members
  FOR DELETE
  USING (
    household_id IN (
      SELECT id FROM households WHERE household_head_id = auth.uid()
    )
    AND relationship != 'head'  -- Prevent deleting the household head
  );

-- Add helpful comments
COMMENT ON POLICY "Household heads can view their household members" ON household_members IS 'Allows residence app users to view members of their own household';
COMMENT ON POLICY "Household heads can insert household members" ON household_members IS 'Allows residence app users to add members to their own household';
COMMENT ON POLICY "Household heads can update household members" ON household_members IS 'Allows residence app users to edit members of their own household';
COMMENT ON POLICY "Household heads can delete household members" ON household_members IS 'Allows residence app users to delete members of their own household (except household head)';