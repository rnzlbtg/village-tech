-- Migration 031: Create guards table
-- Purpose: Gate guard user accounts and authentication for Sentinel app

CREATE TABLE IF NOT EXISTS guards (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE NOT NULL,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('head_guard', 'guard_officer', 'guard_trainee')),
  phone TEXT,
  employee_id TEXT,
  is_active BOOLEAN DEFAULT true,
  last_login_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE guards ENABLE ROW LEVEL SECURITY;

-- Create indexes for performance
CREATE INDEX idx_guards_tenant_id ON guards(tenant_id);
CREATE INDEX idx_guards_email ON guards(email);
CREATE INDEX idx_guards_role ON guards(role);
CREATE INDEX idx_guards_is_active ON guards(is_active);
CREATE INDEX idx_guards_created_at ON guards(created_at);

-- RLS Policies
CREATE POLICY "Guards can view own tenant data" ON guards
  FOR SELECT USING (
    tenant_id = current_setting('app.current_tenant_id', true)::uuid
  );

CREATE POLICY "Guards can insert own tenant data" ON guards
  FOR INSERT WITH CHECK (
    tenant_id = current_setting('app.current_tenant_id', true)::uuid
  );

CREATE POLICY "Guards can update own tenant data" ON guards
  FOR UPDATE USING (
    tenant_id = current_setting('app.current_tenant_id', true)::uuid
  );

CREATE POLICY "Admins can manage guards" ON guards
  FOR ALL USING (
    auth.jwt() ->> 'role' = 'admin' AND
    tenant_id = current_setting('app.current_tenant_id', true)::uuid
  );

-- Update timestamp trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_guards_updated_at
    BEFORE UPDATE ON guards
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Comments
COMMENT ON TABLE guards IS 'Gate guard user accounts and authentication';
COMMENT ON COLUMN guards.id IS 'Unique identifier for the guard';
COMMENT ON COLUMN guards.tenant_id IS 'Associated tenant/community';
COMMENT ON COLUMN guards.email IS 'Guard login email (unique)';
COMMENT ON COLUMN guards.full_name IS 'Guard display name';
COMMENT ON COLUMN guards.role IS 'Guard role: head_guard, guard_officer, guard_trainee';
COMMENT ON COLUMN guards.phone IS 'Guard contact number';
COMMENT ON COLUMN guards.employee_id IS 'Employee identifier (unique within tenant)';
COMMENT ON COLUMN guards.is_active IS 'Employment status';
COMMENT ON COLUMN guards.last_login_at IS 'Last successful login timestamp';
COMMENT ON COLUMN guards.created_at IS 'Account creation timestamp';
COMMENT ON COLUMN guards.updated_at IS 'Last update timestamp';