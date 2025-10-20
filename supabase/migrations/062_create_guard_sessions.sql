-- Migration 034: Create guard_sessions table
-- Purpose: Authentication session management for guards

CREATE TABLE IF NOT EXISTS guard_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  guard_id UUID REFERENCES guards(id) ON DELETE CASCADE NOT NULL,
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE NOT NULL,
  login_time TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  logout_time TIMESTAMPTZ,
  device_info TEXT,
  ip_address INET,
  user_agent TEXT,
  is_active BOOLEAN DEFAULT true NOT NULL,
  session_token_hash TEXT, -- Hash of session token for security
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE guard_sessions ENABLE ROW LEVEL SECURITY;

-- Create indexes for performance
CREATE INDEX idx_guard_sessions_guard_id ON guard_sessions(guard_id);
CREATE INDEX idx_guard_sessions_tenant_id ON guard_sessions(tenant_id);
CREATE INDEX idx_guard_sessions_login_time ON guard_sessions(login_time);
CREATE INDEX idx_guard_sessions_logout_time ON guard_sessions(logout_time);
CREATE INDEX idx_guard_sessions_is_active ON guard_sessions(is_active);
CREATE INDEX idx_guard_sessions_session_token_hash ON guard_sessions(session_token_hash);

-- Composite indexes for common queries
CREATE INDEX idx_guard_sessions_active_sessions ON guard_sessions(guard_id, is_active)
  WHERE is_active = true;
CREATE INDEX idx_guard_sessions_tenant_active ON guard_sessions(tenant_id, is_active)
  WHERE is_active = true;

-- RLS Policies
CREATE POLICY "Guards can view own sessions" ON guard_sessions
  FOR SELECT USING (
    guard_id = auth.jwt() ->> 'user_id'::uuid
  );

CREATE POLICY "Guards can create own sessions" ON guard_sessions
  FOR INSERT WITH CHECK (
    guard_id = auth.jwt() ->> 'user_id'::uuid
  );

CREATE POLICY "Guards can update own sessions" ON guard_sessions
  FOR UPDATE USING (
    guard_id = auth.jwt() ->> 'user_id'::uuid
  );

CREATE POLICY "Head guards can view tenant sessions" ON guard_sessions
  FOR SELECT USING (
    tenant_id = current_setting('app.current_tenant_id', true)::uuid AND
    auth.jwt() ->> 'role' IN ('head_guard', 'admin')
  );

-- Sessions should not be deleted, only deactivated
CREATE POLICY "Guards cannot delete sessions" ON guard_sessions
  FOR DELETE USING (false);

-- Update timestamp trigger
CREATE TRIGGER update_guard_sessions_updated_at
    BEFORE UPDATE ON guard_sessions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to end all active sessions for a guard
CREATE OR REPLACE FUNCTION end_guard_sessions(p_guard_id UUID)
RETURNS INTEGER AS $$
DECLARE
  session_count INTEGER;
BEGIN
  UPDATE guard_sessions
  SET
    logout_time = NOW(),
    is_active = false,
    updated_at = NOW()
  WHERE guard_id = p_guard_id
    AND is_active = true;

  GET DIAGNOSTICS session_count = ROW_COUNT;
  RETURN session_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check and clean expired sessions
CREATE OR REPLACE FUNCTION clean_expired_sessions()
RETURNS INTEGER AS $$
DECLARE
  session_count INTEGER;
  max_session_duration INTERVAL = INTERVAL '12 hours'; -- Max session duration
BEGIN
  UPDATE guard_sessions
  SET
    logout_time = NOW(),
    is_active = false,
    updated_at = NOW()
  WHERE is_active = true
    AND login_time < NOW() - max_session_duration;

  GET DIAGNOSTICS session_count = ROW_COUNT;
  RETURN session_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get active sessions for tenant
CREATE OR REPLACE FUNCTION get_active_sessions(p_tenant_id UUID)
RETURNS TABLE (
  id UUID,
  guard_id UUID,
  guard_name TEXT,
  guard_role TEXT,
  login_time TIMESTAMPTZ,
  device_info TEXT,
  ip_address INET
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    gs.id,
    gs.guard_id,
    g.full_name as guard_name,
    g.role as guard_role,
    gs.login_time,
    gs.device_info,
    gs.ip_address
  FROM guard_sessions gs
  INNER JOIN guards g ON gs.guard_id = g.id
  WHERE gs.tenant_id = p_tenant_id
    AND gs.is_active = true
    AND g.is_active = true
  ORDER BY gs.login_time DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create a scheduled job to clean expired sessions (requires pg_cron extension)
-- SELECT cron.schedule('clean-expired-sessions', '0 */6 * * *', 'SELECT clean_expired_sessions();');

-- Comments
COMMENT ON TABLE guard_sessions IS 'Authentication session management for guards';
COMMENT ON COLUMN guard_sessions.id IS 'Unique identifier for the session';
COMMENT ON COLUMN guard_sessions.guard_id IS 'Associated guard';
COMMENT ON COLUMN guard_sessions.tenant_id IS 'Associated tenant/community';
COMMENT ON COLUMN guard_sessions.login_time IS 'Session start timestamp';
COMMENT ON COLUMN guard_sessions.logout_time IS 'Session end timestamp';
COMMENT ON COLUMN guard_sessions.device_info IS 'Device identification information';
COMMENT ON COLUMN guard_sessions.ip_address IS 'Network IP address';
COMMENT ON COLUMN guard_sessions.user_agent IS 'Browser/app user agent string';
COMMENT ON COLUMN guard_sessions.is_active IS 'Session active status';
COMMENT ON COLUMN guard_sessions.session_token_hash IS 'Hashed session token for security';
COMMENT ON COLUMN guard_sessions.created_at IS 'Record creation timestamp';
COMMENT ON COLUMN guard_sessions.updated_at IS 'Last update timestamp';