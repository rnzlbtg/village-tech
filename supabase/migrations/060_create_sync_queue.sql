-- Migration 035: Create sync_queue table
-- Purpose: Offline operations for background synchronization

CREATE TABLE IF NOT EXISTS sync_queue (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE NOT NULL,
  operation TEXT NOT NULL CHECK (operation IN ('CREATE', 'UPDATE', 'DELETE')),
  entity_type TEXT NOT NULL,
  entity_id UUID NOT NULL,
  payload JSONB NOT NULL DEFAULT '{}',
  priority TEXT NOT NULL DEFAULT 'normal' CHECK (priority IN ('critical', 'high', 'normal', 'low')),
  retry_count INTEGER DEFAULT 0 NOT NULL,
  max_retries INTEGER DEFAULT 5 NOT NULL,
  scheduled_for TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  last_attempt_at TIMESTAMPTZ,
  next_attempt_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'cancelled')),
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE sync_queue ENABLE ROW LEVEL SECURITY;

-- Create indexes for performance
CREATE INDEX idx_sync_queue_tenant_id ON sync_queue(tenant_id);
CREATE INDEX idx_sync_queue_entity_type ON sync_queue(entity_type);
CREATE INDEX idx_sync_queue_entity_id ON sync_queue(entity_id);
CREATE INDEX idx_sync_queue_priority ON sync_queue(priority);
CREATE INDEX idx_sync_queue_status ON sync_queue(status);
CREATE INDEX idx_sync_queue_scheduled_for ON sync_queue(scheduled_for);
CREATE INDEX idx_sync_queue_next_attempt_at ON sync_queue(next_attempt_at);

-- Composite indexes for common queries
CREATE INDEX idx_sync_queue_tenant_priority ON sync_queue(tenant_id, priority);
CREATE INDEX idx_sync_queue_pending_operations ON sync_queue(tenant_id, status, priority)
  WHERE status IN ('pending', 'processing');
CREATE INDEX idx_sync_queue_retry_operations ON sync_queue(tenant_id, status, next_attempt_at)
  WHERE status = 'failed' AND retry_count < max_retries;

-- RLS Policies
CREATE POLICY "Guards can view tenant sync operations" ON sync_queue
  FOR SELECT USING (
    tenant_id = current_setting('app.current_tenant_id', true)::uuid
  );

CREATE POLICY "Guards can create tenant sync operations" ON sync_queue
  FOR INSERT WITH CHECK (
    tenant_id = current_setting('app.current_tenant_id', true)::uuid
  );

CREATE POLICY "Guards can update tenant sync operations" ON sync_queue
  FOR UPDATE USING (
    tenant_id = current_setting('app.current_tenant_id', true)::uuid
  );

-- Sync operations should not be deleted by guards, only by system/admin
CREATE POLICY "Guards cannot delete sync operations" ON sync_queue
  FOR DELETE USING (false);

CREATE POLICY "System can manage sync operations" ON sync_queue
  FOR ALL USING (
    auth.jwt() ->> 'role' = 'service_role' OR
    (auth.jwt() ->> 'role' = 'admin' AND
     tenant_id = current_setting('app.current_tenant_id', true)::uuid)
  );

-- Update timestamp trigger
CREATE TRIGGER update_sync_queue_updated_at
    BEFORE UPDATE ON sync_queue
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to add sync operation to queue
CREATE OR REPLACE FUNCTION add_sync_operation(
  p_tenant_id UUID,
  p_operation TEXT,
  p_entity_type TEXT,
  p_entity_id UUID,
  p_payload JSONB DEFAULT '{}',
  p_priority TEXT DEFAULT 'normal'
)
RETURNS UUID AS $$
DECLARE
  operation_id UUID;
BEGIN
  INSERT INTO sync_queue (
    tenant_id,
    operation,
    entity_type,
    entity_id,
    payload,
    priority,
    next_attempt_at
  ) VALUES (
    p_tenant_id,
    p_operation,
    p_entity_type,
    p_entity_id,
    p_payload,
    p_priority,
    NOW()
  ) RETURNING id INTO operation_id;

  RETURN operation_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get pending sync operations for a tenant
CREATE OR REPLACE FUNCTION get_pending_sync_operations(
  p_tenant_id UUID,
  p_limit INTEGER DEFAULT 50,
  p_priority_only TEXT DEFAULT NULL
)
RETURNS TABLE (
  id UUID,
  operation TEXT,
  entity_type TEXT,
  entity_id UUID,
  payload JSONB,
  priority TEXT,
  retry_count INTEGER,
  scheduled_for TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    sq.id,
    sq.operation,
    sq.entity_type,
    sq.entity_id,
    sq.payload,
    sq.priority,
    sq.retry_count,
    sq.scheduled_for
  FROM sync_queue sq
  WHERE sq.tenant_id = p_tenant_id
    AND sq.status = 'pending'
    AND sq.scheduled_for <= NOW()
    AND (p_priority_only IS NULL OR sq.priority = p_priority_only)
    AND sq.retry_count < sq.max_retries
  ORDER BY
    sq.priority DESC,
    sq.scheduled_for ASC,
    sq.created_at ASC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to mark sync operation as completed
CREATE OR REPLACE FUNCTION complete_sync_operation(p_operation_id UUID, p_success BOOLEAN DEFAULT true)
RETURNS BOOLEAN AS $$
DECLARE
  updated_count INTEGER;
BEGIN
  UPDATE sync_queue
  SET
    status = CASE WHEN p_success THEN 'completed' ELSE 'failed' END,
    updated_at = NOW(),
    last_attempt_at = NOW()
  WHERE id = p_operation_id
    AND status IN ('pending', 'processing');

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RETURN updated_count > 0;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to schedule retry for failed operation
CREATE OR REPLACE FUNCTION schedule_sync_retry(
  p_operation_id UUID,
  p_error_message TEXT DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
  retry_delay INTERVAL;
  updated_count INTEGER;
BEGIN
  -- Calculate exponential backoff delay (1min, 2min, 4min, 8min, 16min)
  retry_delay = INTERVAL '1 minute' * (2 ^ (
    SELECT LEAST(retry_count, 4)
    FROM sync_queue
    WHERE id = p_operation_id
  ));

  UPDATE sync_queue
  SET
    status = 'pending',
    retry_count = retry_count + 1,
    next_attempt_at = NOW() + retry_delay,
    last_attempt_at = NOW(),
    error_message = p_error_message,
    updated_at = NOW()
  WHERE id = p_operation_id
    AND status IN ('pending', 'processing', 'failed')
    AND retry_count < max_retries;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RETURN updated_count > 0;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to clean old completed sync operations
CREATE OR REPLACE FUNCTION cleanup_completed_sync_operations(p_days_old INTEGER DEFAULT 7)
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  DELETE FROM sync_queue
  WHERE status = 'completed'
    AND updated_at < NOW() - INTERVAL '1 day' * p_days_old;

  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Comments
COMMENT ON TABLE sync_queue IS 'Offline operations for background synchronization';
COMMENT ON COLUMN sync_queue.id IS 'Unique identifier for the sync operation';
COMMENT ON COLUMN sync_queue.tenant_id IS 'Associated tenant/community';
COMMENT ON COLUMN sync_queue.operation IS 'Database operation: CREATE, UPDATE, DELETE';
COMMENT ON COLUMN sync_queue.entity_type IS 'Type of entity being synchronized';
COMMENT ON COLUMN sync_queue.entity_id IS 'Identifier of the entity';
COMMENT ON COLUMN sync_queue.payload IS 'Serialized data for the operation';
COMMENT ON COLUMN sync_queue.priority IS 'Operation priority: critical, high, normal, low';
COMMENT ON COLUMN sync_queue.retry_count IS 'Number of retry attempts';
COMMENT ON COLUMN sync_queue.max_retries IS 'Maximum allowed retry attempts';
COMMENT ON COLUMN sync_queue.scheduled_for IS 'When to process the operation';
COMMENT ON COLUMN sync_queue.last_attempt_at IS 'Last retry attempt timestamp';
COMMENT ON COLUMN sync_queue.next_attempt_at IS 'Next scheduled attempt timestamp';
COMMENT ON COLUMN sync_queue.status IS 'Operation status: pending, processing, completed, failed, cancelled';
COMMENT ON COLUMN sync_queue.error_message IS 'Error details for failed operations';
COMMENT ON COLUMN sync_queue.created_at IS 'Record creation timestamp';
COMMENT ON COLUMN sync_queue.updated_at IS 'Last update timestamp';