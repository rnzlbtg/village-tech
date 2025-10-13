-- Migration: 028_create_rls_policies_admin.sql
-- Description: RLS policies for admin app tables (tenant-scoped access)
-- Author: Admin App Implementation
-- Date: 2025-10-12

-- Enable RLS on all tables
ALTER TABLE households ENABLE ROW LEVEL SECURITY;
ALTER TABLE household_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE sticker_programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE sticker_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE construction_permits ENABLE ROW LEVEL SECURITY;
ALTER TABLE permit_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_logs ENABLE ROW LEVEL SECURITY;

-- Households policies
CREATE POLICY "Admins can view their tenant's households"
  ON households FOR SELECT
  USING (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'role') IN ('admin_head', 'admin_officer')
  );

CREATE POLICY "Admin heads can insert households"
  ON households FOR INSERT
  WITH CHECK (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'role') = 'admin_head'
  );

CREATE POLICY "Admin heads can update households"
  ON households FOR UPDATE
  USING (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'role') = 'admin_head'
  );

-- Household members policies
CREATE POLICY "Admins can view household members"
  ON household_members FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM households
      WHERE households.id = household_members.household_id
      AND households.tenant_id = (auth.jwt()->>'tenant_id')::UUID
    )
    AND (auth.jwt()->>'role') IN ('admin_head', 'admin_officer')
  );

CREATE POLICY "Admin heads can manage household members"
  ON household_members FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM households
      WHERE households.id = household_members.household_id
      AND households.tenant_id = (auth.jwt()->>'tenant_id')::UUID
    )
    AND (auth.jwt()->>'role') = 'admin_head'
  );

-- Sticker programs policies
CREATE POLICY "Admins can view sticker programs"
  ON sticker_programs FOR SELECT
  USING (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'role') IN ('admin_head', 'admin_officer')
  );

CREATE POLICY "Admin heads can manage sticker programs"
  ON sticker_programs FOR ALL
  USING (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'role') = 'admin_head'
  );

-- Sticker requests policies
CREATE POLICY "Admins can view sticker requests"
  ON sticker_requests FOR SELECT
  USING (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'role') IN ('admin_head', 'admin_officer')
  );

CREATE POLICY "Admins can update sticker requests"
  ON sticker_requests FOR UPDATE
  USING (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'role') IN ('admin_head', 'admin_officer')
  );

-- Construction permits policies
CREATE POLICY "Admins can view construction permits"
  ON construction_permits FOR SELECT
  USING (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'role') IN ('admin_head', 'admin_officer')
  );

CREATE POLICY "Admin heads can manage construction permits"
  ON construction_permits FOR ALL
  USING (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'role') = 'admin_head'
  );

-- Permit payments policies
CREATE POLICY "Admins can view permit payments"
  ON permit_payments FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM construction_permits
      WHERE construction_permits.id = permit_payments.permit_id
      AND construction_permits.tenant_id = (auth.jwt()->>'tenant_id')::UUID
    )
    AND (auth.jwt()->>'role') IN ('admin_head', 'admin_officer')
  );

CREATE POLICY "Admins can record permit payments"
  ON permit_payments FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM construction_permits
      WHERE construction_permits.id = permit_payments.permit_id
      AND construction_permits.tenant_id = (auth.jwt()->>'tenant_id')::UUID
    )
    AND (auth.jwt()->>'role') IN ('admin_head', 'admin_officer')
  );

-- Announcements policies
CREATE POLICY "Admins can view announcements"
  ON announcements FOR SELECT
  USING (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'role') IN ('admin_head', 'admin_officer')
    AND deleted_at IS NULL
  );

CREATE POLICY "Admins can manage announcements"
  ON announcements FOR ALL
  USING (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'role') IN ('admin_head', 'admin_officer')
  );

-- Invoices policies
CREATE POLICY "Admins can view invoices"
  ON invoices FOR SELECT
  USING (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'role') IN ('admin_head', 'admin_officer')
  );

CREATE POLICY "Admin heads can manage invoices"
  ON invoices FOR ALL
  USING (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'role') = 'admin_head'
  );

-- Payment logs policies
CREATE POLICY "Admins can view payment logs"
  ON payment_logs FOR SELECT
  USING (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'role') IN ('admin_head', 'admin_officer')
  );

CREATE POLICY "Admins can record payments"
  ON payment_logs FOR INSERT
  WITH CHECK (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'role') IN ('admin_head', 'admin_officer')
  );

CREATE POLICY "Admin heads can void payments"
  ON payment_logs FOR UPDATE
  USING (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'role') = 'admin_head'
  );

-- Comments
COMMENT ON POLICY "Admins can view their tenant's households" ON households IS 'Tenant-scoped read access for admins';
COMMENT ON POLICY "Admin heads can manage sticker programs" ON sticker_programs IS 'Only admin heads can configure sticker allocation';
