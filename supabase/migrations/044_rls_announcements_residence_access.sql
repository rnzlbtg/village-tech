-- Migration: 044_rls_announcements_residence_access.sql
-- Description: Add RLS policies for residence app users to view announcements
-- Author: Residence App Implementation
-- Date: 2025-10-15

-- Drop existing policy if it exists (to make migration idempotent)
DROP POLICY IF EXISTS "Household heads can view tenant announcements" ON announcements;

-- Allow household heads to view announcements for their tenant
CREATE POLICY "Household heads can view tenant announcements"
  ON announcements
  FOR SELECT
  USING (
    tenant_id IN (
      SELECT p.tenant_id
      FROM households h
      INNER JOIN residence_units ru ON ru.id = h.residence_unit_id
      INNER JOIN properties p ON p.id = ru.property_id
      WHERE h.household_head_id = auth.uid()
    )
    AND deleted_at IS NULL
    AND is_published = TRUE
    AND (expires_at IS NULL OR expires_at > NOW())
  );

-- Add helpful comment
COMMENT ON POLICY "Household heads can view tenant announcements" ON announcements IS 'Allows residence app users to view published announcements for their tenant';