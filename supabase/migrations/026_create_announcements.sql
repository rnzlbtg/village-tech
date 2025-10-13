-- Migration: 026_create_announcements.sql
-- Description: Create announcements table for community communications
-- Author: Admin App Implementation
-- Date: 2025-10-12

-- Announcements table
CREATE TABLE IF NOT EXISTS announcements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  priority TEXT NOT NULL DEFAULT 'normal' CHECK (priority IN ('normal', 'high', 'urgent')),
  target_audience TEXT[] NOT NULL, -- Array of: 'residents', 'guards', 'security', 'all'
  attachment_urls TEXT[],
  published_at TIMESTAMPTZ,
  published_by UUID REFERENCES auth.users(id),
  expires_at TIMESTAMPTZ,
  is_published BOOLEAN DEFAULT FALSE,
  push_notification_sent BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX idx_announcements_tenant ON announcements(tenant_id);
CREATE INDEX idx_announcements_published ON announcements(tenant_id, is_published) WHERE is_published = TRUE;
CREATE INDEX idx_announcements_priority ON announcements(tenant_id, priority);
CREATE INDEX idx_announcements_expires ON announcements(expires_at) WHERE expires_at IS NOT NULL;
CREATE INDEX idx_announcements_deleted ON announcements(deleted_at) WHERE deleted_at IS NULL;

-- Trigger for updated_at
CREATE TRIGGER update_announcements_updated_at
  BEFORE UPDATE ON announcements
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Comments
COMMENT ON TABLE announcements IS 'Community announcements and notices';
COMMENT ON COLUMN announcements.target_audience IS 'Array of recipient groups: residents, guards, security, or all';
COMMENT ON COLUMN announcements.deleted_at IS 'Soft delete timestamp';
