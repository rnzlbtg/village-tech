-- Migration: 007_create_audit_logs.sql
-- Description: Create audit_logs table for compliance
-- Author: Platform App Implementation
-- Date: 2025-10-10

-- Create audit_logs table
CREATE TABLE IF NOT EXISTS audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  table_name VARCHAR(100) NOT NULL,
  operation VARCHAR(10) NOT NULL CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
  old_data JSONB,
  new_data JSONB,
  changed_fields TEXT[],
  ip_address INET,
  user_agent TEXT,
  timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_audit_logs_tenant_id ON audit_logs(tenant_id, timestamp);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id, timestamp);
CREATE INDEX idx_audit_logs_table_name ON audit_logs(table_name, timestamp);
CREATE INDEX idx_audit_logs_timestamp ON audit_logs(timestamp DESC);

-- Enable Row Level Security
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Comments
COMMENT ON TABLE audit_logs IS 'Audit trail for all tenant-scoped data changes';
COMMENT ON COLUMN audit_logs.operation IS 'Type of operation: INSERT, UPDATE, DELETE';
COMMENT ON COLUMN audit_logs.old_data IS 'Record state before change (for UPDATE/DELETE)';
COMMENT ON COLUMN audit_logs.new_data IS 'Record state after change (for INSERT/UPDATE)';
COMMENT ON COLUMN audit_logs.changed_fields IS 'List of field names that were modified (for UPDATE)';
