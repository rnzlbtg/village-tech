-- Migration: 036_secure_household_head_creation.sql
-- Description: Secure household head creation without service role for user creation
-- Approach: Use database triggers to automatically set tenant_id from admin's JWT claims

-- Create a table to track pending household head registrations
-- This allows admins to "invite" users without using service role
CREATE TABLE IF NOT EXISTS household_head_invitations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  phone_number TEXT NOT NULL,
  date_of_birth DATE,
  residence_unit_id UUID NOT NULL REFERENCES residence_units(id) ON DELETE CASCADE,
  household_id UUID REFERENCES households(id) ON DELETE CASCADE,
  invited_by UUID NOT NULL REFERENCES auth.users(id),
  invited_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '7 days'),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'expired', 'cancelled')),
  invitation_token TEXT UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Add indexes
CREATE INDEX idx_household_head_invitations_tenant ON household_head_invitations(tenant_id);
CREATE INDEX idx_household_head_invitations_email ON household_head_invitations(email);
CREATE INDEX idx_household_head_invitations_token ON household_head_invitations(invitation_token);
CREATE INDEX idx_household_head_invitations_status ON household_head_invitations(status);

-- RLS Policies for invitations
ALTER TABLE household_head_invitations ENABLE ROW LEVEL SECURITY;

-- Admins can create invitations for their tenant
CREATE POLICY "Admins can create invitations"
  ON household_head_invitations FOR INSERT
  WITH CHECK (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'app_role') IN ('admin_head', 'admin_officer')
  );

-- Admins can view invitations for their tenant
CREATE POLICY "Admins can view invitations"
  ON household_head_invitations FOR SELECT
  USING (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'app_role') IN ('admin_head', 'admin_officer')
  );

-- Admins can update/cancel invitations for their tenant
CREATE POLICY "Admins can update invitations"
  ON household_head_invitations FOR UPDATE
  USING (
    tenant_id = (auth.jwt()->>'tenant_id')::UUID
    AND (auth.jwt()->>'app_role') IN ('admin_head', 'admin_officer')
  );

-- Public users can view their own invitation by token (for signup flow)
CREATE POLICY "Public can view invitation by token"
  ON household_head_invitations FOR SELECT
  USING (
    status = 'pending'
    AND expires_at > NOW()
    AND invitation_token = current_setting('request.headers', true)::json->>'invitation_token'
  );

-- Function to generate invitation token
CREATE OR REPLACE FUNCTION generate_invitation_token()
RETURNS TEXT AS $$
BEGIN
  RETURN encode(gen_random_bytes(32), 'base64');
END;
$$ LANGUAGE plpgsql;

-- Trigger to set invitation token on insert
CREATE OR REPLACE FUNCTION set_invitation_token()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.invitation_token IS NULL THEN
    NEW.invitation_token := generate_invitation_token();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_invitation_token
  BEFORE INSERT ON household_head_invitations
  FOR EACH ROW
  EXECUTE FUNCTION set_invitation_token();

-- Function to auto-expire invitations
CREATE OR REPLACE FUNCTION expire_old_invitations()
RETURNS void AS $$
BEGIN
  UPDATE household_head_invitations
  SET status = 'expired'
  WHERE status = 'pending'
    AND expires_at < NOW();
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-set tenant_id for new auth users based on invitation
-- This runs when a user signs up via invitation link
CREATE OR REPLACE FUNCTION set_tenant_from_invitation()
RETURNS TRIGGER AS $$
DECLARE
  v_invitation household_head_invitations%ROWTYPE;
BEGIN
  -- Look for a pending invitation for this email
  SELECT * INTO v_invitation
  FROM household_head_invitations
  WHERE email = NEW.email
    AND status = 'pending'
    AND expires_at > NOW()
  ORDER BY created_at DESC
  LIMIT 1;

  IF FOUND THEN
    -- Set tenant_id and role in app_metadata
    NEW.raw_app_meta_data := jsonb_build_object(
      'tenant_id', v_invitation.tenant_id::text,
      'role', 'household_head',
      'household_id', v_invitation.household_id::text
    );

    -- Set user_metadata
    NEW.raw_user_meta_data := jsonb_build_object(
      'first_name', v_invitation.first_name,
      'last_name', v_invitation.last_name,
      'phone_number', v_invitation.phone_number,
      'role', 'household_head'
    );

    -- Mark invitation as accepted
    UPDATE household_head_invitations
    SET status = 'accepted'
    WHERE id = v_invitation.id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Note: This trigger needs to be created in Supabase Dashboard → Database → Triggers
-- because it needs to run on auth.users table which requires elevated permissions
--
-- CREATE TRIGGER trigger_set_tenant_from_invitation
--   BEFORE INSERT ON auth.users
--   FOR EACH ROW
--   EXECUTE FUNCTION set_tenant_from_invitation();

-- Alternative: Use Supabase Edge Functions or Auth Hooks for this
-- See: https://supabase.com/docs/guides/auth/auth-hooks

COMMENT ON TABLE household_head_invitations IS 'Secure invitation system for household heads without using service role';
COMMENT ON FUNCTION set_tenant_from_invitation() IS 'Automatically sets tenant_id from invitation when user signs up - must be manually created on auth.users table';
