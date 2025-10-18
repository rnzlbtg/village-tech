-- Migration: 043_rls_sticker_requests_household_access.sql
-- Description: Add RLS policies for household heads to manage their sticker requests
-- Author: Residence App Implementation
-- Date: 2025-10-15

-- Add RLS policies for household heads to manage their own sticker requests
-- This allows residence app users to view, insert, update, and delete their sticker requests

-- Drop existing policies if they exist (to make migration idempotent)
DROP POLICY IF EXISTS "Household heads can view their sticker requests" ON sticker_requests;
DROP POLICY IF EXISTS "Household heads can insert sticker requests" ON sticker_requests;
DROP POLICY IF EXISTS "Household heads can update their pending sticker requests" ON sticker_requests;
DROP POLICY IF EXISTS "Household heads can delete their pending sticker requests" ON sticker_requests;

-- Allow household heads to view their sticker requests
CREATE POLICY "Household heads can view their sticker requests"
  ON sticker_requests
  FOR SELECT
  USING (
    household_id IN (
      SELECT id FROM households WHERE household_head_id = auth.uid()
    )
  );

-- Allow household heads to insert sticker requests
CREATE POLICY "Household heads can insert sticker requests"
  ON sticker_requests
  FOR INSERT
  WITH CHECK (
    household_id IN (
      SELECT id FROM households WHERE household_head_id = auth.uid()
    )
  );

-- Allow household heads to update their pending sticker requests
CREATE POLICY "Household heads can update their pending sticker requests"
  ON sticker_requests
  FOR UPDATE
  USING (
    household_id IN (
      SELECT id FROM households WHERE household_head_id = auth.uid()
    )
    AND request_status = 'pending'
  );

-- Allow household heads to delete their pending sticker requests
CREATE POLICY "Household heads can delete their pending sticker requests"
  ON sticker_requests
  FOR DELETE
  USING (
    household_id IN (
      SELECT id FROM households WHERE household_head_id = auth.uid()
    )
    AND request_status = 'pending'
  );

-- Add helpful comments
COMMENT ON POLICY "Household heads can view their sticker requests" ON sticker_requests IS 'Allows residence app users to view their own sticker requests';
COMMENT ON POLICY "Household heads can insert sticker requests" ON sticker_requests IS 'Allows residence app users to create sticker requests';
COMMENT ON POLICY "Household heads can update their pending sticker requests" ON sticker_requests IS 'Allows residence app users to edit pending sticker requests';
COMMENT ON POLICY "Household heads can delete their pending sticker requests" ON sticker_requests IS 'Allows residence app users to cancel pending sticker requests';