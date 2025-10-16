-- Migration: 034_fix_all_rls_app_role.sql
-- Description: Fix all RLS policies to use app_role instead of role claim
-- Author: Admin App Fix
-- Date: 2025-10-14

-- Drop and recreate households policies
DROP POLICY IF EXISTS "Admins can view their tenant's households" ON households;
DROP POLICY IF EXISTS "Admin heads can insert households" ON households;
DROP POLICY IF EXISTS "Admin heads can update households" ON households;

CREATE POLICY "Admins can view their tenant's households"
  ON households FOR SELECT
  USING (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'app_role') IN ('admin_head', 'admin_officer')
  );

CREATE POLICY "Admin heads can insert households"
  ON households FOR INSERT
  WITH CHECK (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'app_role') = 'admin_head'
  );

CREATE POLICY "Admin heads can update households"
  ON households FOR UPDATE
  USING (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'app_role') = 'admin_head'
  );

-- Drop and recreate household_members policies
DROP POLICY IF EXISTS "Admins can view household members" ON household_members;
DROP POLICY IF EXISTS "Admin heads can manage household members" ON household_members;

CREATE POLICY "Admins can view household members"
  ON household_members FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM households
      WHERE households.id = household_members.household_id
      AND households.tenant_id = (auth.jwt()->>'tenant_id')::UUID
    )
    AND (auth.jwt()->>'app_role') IN ('admin_head', 'admin_officer')
  );

CREATE POLICY "Admin heads can manage household members"
  ON household_members FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM households
      WHERE households.id = household_members.household_id
      AND households.tenant_id = (auth.jwt()->>'tenant_id')::UUID
    )
    AND (auth.jwt()->>'app_role') = 'admin_head'
  );

-- Fix sticker_programs policies
DROP POLICY IF EXISTS "Admins can view sticker programs" ON sticker_programs;
DROP POLICY IF EXISTS "Admin heads can manage sticker programs" ON sticker_programs;

CREATE POLICY "Admins can view sticker programs"
  ON sticker_programs FOR SELECT
  USING (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'app_role') IN ('admin_head', 'admin_officer')
  );

CREATE POLICY "Admin heads can manage sticker programs"
  ON sticker_programs FOR ALL
  USING (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'app_role') = 'admin_head'
  );

-- Fix sticker_requests policies
DROP POLICY IF EXISTS "Admins can view sticker requests" ON sticker_requests;
DROP POLICY IF EXISTS "Admins can update sticker requests" ON sticker_requests;

CREATE POLICY "Admins can view sticker requests"
  ON sticker_requests FOR SELECT
  USING (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'app_role') IN ('admin_head', 'admin_officer')
  );

CREATE POLICY "Admins can update sticker requests"
  ON sticker_requests FOR UPDATE
  USING (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'app_role') IN ('admin_head', 'admin_officer')
  );

-- Fix construction_permits policies
DROP POLICY IF EXISTS "Admins can view construction permits" ON construction_permits;
DROP POLICY IF EXISTS "Admin heads can manage construction permits" ON construction_permits;

CREATE POLICY "Admins can view construction permits"
  ON construction_permits FOR SELECT
  USING (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'app_role') IN ('admin_head', 'admin_officer')
  );

CREATE POLICY "Admin heads can manage construction permits"
  ON construction_permits FOR ALL
  USING (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'app_role') = 'admin_head'
  );

-- Fix permit_payments policies
DROP POLICY IF EXISTS "Admins can view permit payments" ON permit_payments;
DROP POLICY IF EXISTS "Admins can record permit payments" ON permit_payments;

CREATE POLICY "Admins can view permit payments"
  ON permit_payments FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM construction_permits
      WHERE construction_permits.id = permit_payments.permit_id
      AND construction_permits.tenant_id = (auth.jwt()->>'tenant_id')::UUID
    )
    AND (auth.jwt()->>'app_role') IN ('admin_head', 'admin_officer')
  );

CREATE POLICY "Admins can record permit payments"
  ON permit_payments FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM construction_permits
      WHERE construction_permits.id = permit_payments.permit_id
      AND construction_permits.tenant_id = (auth.jwt()->>'tenant_id')::UUID
    )
    AND (auth.jwt()->>'app_role') IN ('admin_head', 'admin_officer')
  );

-- Fix announcements policies
DROP POLICY IF EXISTS "Admins can view announcements" ON announcements;
DROP POLICY IF EXISTS "Admins can manage announcements" ON announcements;

CREATE POLICY "Admins can view announcements"
  ON announcements FOR SELECT
  USING (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'app_role') IN ('admin_head', 'admin_officer')
    AND deleted_at IS NULL
  );

CREATE POLICY "Admins can manage announcements"
  ON announcements FOR ALL
  USING (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'app_role') IN ('admin_head', 'admin_officer')
  );

-- Fix invoices policies
DROP POLICY IF EXISTS "Admins can view invoices" ON invoices;
DROP POLICY IF EXISTS "Admin heads can manage invoices" ON invoices;

CREATE POLICY "Admins can view invoices"
  ON invoices FOR SELECT
  USING (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'app_role') IN ('admin_head', 'admin_officer')
  );

CREATE POLICY "Admin heads can manage invoices"
  ON invoices FOR ALL
  USING (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'app_role') = 'admin_head'
  );

-- Fix payment_logs policies
DROP POLICY IF EXISTS "Admins can view payment logs" ON payment_logs;
DROP POLICY IF EXISTS "Admins can record payments" ON payment_logs;
DROP POLICY IF EXISTS "Admin heads can void payments" ON payment_logs;

CREATE POLICY "Admins can view payment logs"
  ON payment_logs FOR SELECT
  USING (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'app_role') IN ('admin_head', 'admin_officer')
  );

CREATE POLICY "Admins can record payments"
  ON payment_logs FOR INSERT
  WITH CHECK (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'app_role') IN ('admin_head', 'admin_officer')
  );

CREATE POLICY "Admin heads can void payments"
  ON payment_logs FOR UPDATE
  USING (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'app_role') = 'admin_head'
  );
