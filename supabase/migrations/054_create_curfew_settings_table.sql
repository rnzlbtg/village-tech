-- Migration: 054_create_curfew_settings_table.sql
-- Description: Create dedicated table for curfew settings instead of storing in tenant_settings
-- Author: Rules System Implementation
-- Date: 2025-10-16

-- Create dedicated curfew_settings table
CREATE TABLE IF NOT EXISTS curfew_settings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,

  -- Curfew configuration
  start_time TIME NOT NULL, -- e.g., '22:00'
  end_time TIME NOT NULL,   -- e.g., '05:00'
  days_of_week TEXT[] NOT NULL DEFAULT ARRAY['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'],

  -- Status and control
  active BOOLEAN DEFAULT true,

  -- Additional settings
  grace_period_minutes INTEGER DEFAULT 15, -- Grace period before strict enforcement
  notification_advance_minutes INTEGER DEFAULT 30, -- Send notification X minutes before curfew

  -- Audit fields
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES user_profiles(id),
  updated_by UUID REFERENCES user_profiles(id),

  -- One curfew setting per tenant
  UNIQUE(tenant_id)
);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_curfew_settings_tenant_id ON curfew_settings(tenant_id);
CREATE INDEX IF NOT EXISTS idx_curfew_settings_active ON curfew_settings(tenant_id, active);
CREATE INDEX IF NOT EXISTS idx_curfew_settings_time_range ON curfew_settings(start_time, end_time);

-- Enable Row Level Security
ALTER TABLE curfew_settings ENABLE ROW LEVEL SECURITY;

-- RLS policies
CREATE POLICY "Users can view curfew settings from their tenant" ON curfew_settings
  FOR SELECT USING (
    tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
  );

CREATE POLICY "Admin users can manage curfew settings" ON curfew_settings
  FOR ALL USING (
    tenant_id = (auth.jwt() ->> 'tenant_id')::uuid AND
    (auth.jwt() ->> 'app_role') IN ('admin_officer', 'admin_head')
  );

-- Create trigger for updated_at
CREATE TRIGGER update_curfew_settings_updated_at
  BEFORE UPDATE ON curfew_settings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Add comments
COMMENT ON TABLE curfew_settings IS 'Dedicated table for tenant-specific curfew settings and time restrictions';
COMMENT ON COLUMN curfew_settings.start_time IS 'Time when curfew starts (24-hour format)';
COMMENT ON COLUMN curfew_settings.end_time IS 'Time when curfew ends (24-hour format)';
COMMENT ON COLUMN curfew_settings.days_of_week IS 'Array of days when curfew is active';
COMMENT ON COLUMN curfew_settings.active IS 'Whether curfew restrictions are currently enforced';
COMMENT ON COLUMN curfew_settings.grace_period_minutes IS 'Grace period before strict enforcement begins';
COMMENT ON COLUMN curfew_settings.notification_advance_minutes IS 'Send curfew reminder X minutes before start time';

-- Migrate existing curfew settings from association_settings if they exist
-- Only run if the column exists (migration 047 may have been deleted)
DO $$
BEGIN
  -- Check if the curfew_settings column exists in association_settings
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'association_settings'
    AND column_name = 'curfew_settings'
  ) THEN
    INSERT INTO curfew_settings (
      tenant_id,
      start_time,
      end_time,
      days_of_week,
      active,
      created_at,
      updated_at,
      created_by,
      updated_by
    )
    SELECT
      tenant_id,
      (curfew_settings->>'start_time')::time,
      (curfew_settings->>'end_time')::time,
      COALESCE((curfew_settings->>'days_of_week')::text[], ARRAY['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']),
      COALESCE((curfew_settings->>'active')::boolean, true),
      COALESCE((curfew_settings->>'updated_at')::timestamptz, NOW()),
      COALESCE((curfew_settings->>'updated_at')::timestamptz, NOW()),
      (SELECT id FROM user_profiles WHERE tenant_id = ts.tenant_id LIMIT 1),
      (SELECT id FROM user_profiles WHERE tenant_id = ts.tenant_id LIMIT 1)
    FROM association_settings ts
    WHERE curfew_settings IS NOT NULL
    ON CONFLICT (tenant_id) DO UPDATE SET
      start_time = EXCLUDED.start_time,
      end_time = EXCLUDED.end_time,
      days_of_week = EXCLUDED.days_of_week,
      active = EXCLUDED.active,
      updated_at = NOW(),
      updated_by = EXCLUDED.updated_by;
  ELSE
    -- No existing data to migrate, table is empty
    RAISE NOTICE 'No curfew_settings column found in association_settings - skipping data migration';
  END IF;
END $$;

-- Create view for active curfew settings with tenant info
CREATE OR REPLACE VIEW active_curfew_settings AS
SELECT
  cs.*,
  t.name as tenant_name,
  au.first_name || ' ' || au.last_name as updated_by_name
FROM curfew_settings cs
JOIN tenants t ON cs.tenant_id = t.id
LEFT JOIN user_profiles au ON cs.updated_by = au.id
WHERE cs.active = true;

-- Add comment for the view
COMMENT ON VIEW active_curfew_settings IS 'View of active curfew settings with tenant and updater information';

-- Create function to check if current time is within curfew hours
CREATE OR REPLACE FUNCTION is_curfew_active(tenant_uuid UUID, check_time TIMESTAMPTZ DEFAULT NOW())
RETURNS BOOLEAN AS $$
DECLARE
  curfew_config RECORD;
  check_day TEXT;
  check_time_only TIME;
BEGIN
  -- Get curfew settings for the tenant
  SELECT * INTO curfew_config
  FROM curfew_settings
  WHERE tenant_id = tenant_uuid AND active = true;

  -- No active curfew settings
  IF NOT FOUND THEN
    RETURN FALSE;
  END IF;

  -- Get day of week and time
  check_day := LOWER(to_char(check_time, 'Day'));
  check_time_only := check_time::time;

  -- Check if curfew is active on this day
  IF NOT (check_day = ANY(curfew_config.days_of_week)) THEN
    RETURN FALSE;
  END IF;

  -- Check if current time is within curfew hours
  IF curfew_config.start_time <= curfew_config.end_time THEN
    -- Same day (e.g., 22:00 to 05:00 doesn't cross midnight)
    RETURN check_time_only >= curfew_config.start_time
       AND check_time_only <= curfew_config.end_time;
  ELSE
    -- Crosses midnight (e.g., 22:00 to 05:00)
    RETURN check_time_only >= curfew_config.start_time
       OR check_time_only <= curfew_config.end_time;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add comment for the function
COMMENT ON FUNCTION is_curfew_active(UUID, TIMESTAMPTZ) IS 'Check if curfew is currently active for a tenant';

-- Create function to get next curfew start time
CREATE OR REPLACE FUNCTION get_next_curfew_start(tenant_uuid UUID, from_time TIMESTAMPTZ DEFAULT NOW())
RETURNS TIMESTAMPTZ AS $$
DECLARE
  curfew_config RECORD;
  next_start TIMESTAMPTZ;
  current_day INTEGER;
  days_ahead INTEGER;
BEGIN
  -- Get curfew settings
  SELECT * INTO curfew_config
  FROM curfew_settings
  WHERE tenant_id = tenant_uuid AND active = true;

  IF NOT FOUND THEN
    RETURN NULL;
  END IF;

  current_day := EXTRACT(DOW FROM from_time); -- 0=Sunday, 1=Monday, etc.

  -- Find next curfew start time
  FOR days_ahead IN 0..6 LOOP
    next_start := from_time::date + (days_ahead || ' days')::INTERVAL + curfew_config.start_time;

    -- Skip if we're looking at today and the curfew time has already passed
    IF days_ahead > 0 OR next_start > from_time THEN
      -- Check if curfew is active on this day
      IF LOWER(to_char(next_start, 'Day')) = ANY(curfew_config.days_of_week) THEN
        RETURN next_start;
      END IF;
    END IF;
  END LOOP;

  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add comment for the function
COMMENT ON FUNCTION get_next_curfew_start(UUID, TIMESTAMPTZ) IS 'Get the next curfew start time for a tenant';