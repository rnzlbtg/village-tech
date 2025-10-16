-- Migration: 058_fix_village_rules_audit_trigger.sql
-- Description: Fix the log_rule_changes trigger function WHERE clause
-- Author: Rules System Fix
-- Date: 2025-10-16

-- Drop the existing trigger and function
DROP TRIGGER IF EXISTS village_rules_audit_trigger ON village_rules;
DROP FUNCTION IF EXISTS log_rule_changes();

-- Recreate the function with correct WHERE clause
CREATE OR REPLACE FUNCTION log_rule_changes()
RETURNS TRIGGER AS $$
DECLARE
  action_type VARCHAR(20);
  changed_fields JSONB;
BEGIN
  -- Determine action type
  IF TG_OP = 'INSERT' THEN
    action_type := 'created';
    changed_fields := '[]'::jsonb;
  ELSIF TG_OP = 'UPDATE' THEN
    action_type := CASE
      WHEN NEW.published = true AND OLD.published = false THEN 'published'
      WHEN NEW.published = false AND OLD.published = true THEN 'unpublished'
      ELSE 'updated'
    END;

    -- Calculate changed fields with correct WHERE clause
    changed_fields := (
      SELECT jsonb_agg(key)
      FROM jsonb_object_keys(
        CASE
          WHEN TG_OP = 'UPDATE' THEN
            jsonb_build_object(
              'title', CASE WHEN OLD.title IS DISTINCT FROM NEW.title THEN NEW.title ELSE NULL END,
              'description', CASE WHEN OLD.description IS DISTINCT FROM NEW.description THEN NEW.description ELSE NULL END,
              'rule_category', CASE WHEN OLD.rule_category IS DISTINCT FROM NEW.rule_category THEN NEW.rule_category ELSE NULL END,
              'curfew_start_time', CASE WHEN OLD.curfew_start_time IS DISTINCT FROM NEW.curfew_start_time THEN NEW.curfew_start_time ELSE NULL END,
              'curfew_end_time', CASE WHEN OLD.curfew_end_time IS DISTINCT FROM NEW.curfew_end_time THEN NEW.curfew_end_time ELSE NULL END,
              'is_active', CASE WHEN OLD.is_active IS DISTINCT FROM NEW.is_active THEN NEW.is_active ELSE NULL END,
              'published', CASE WHEN OLD.published IS DISTINCT FROM NEW.published THEN NEW.published ELSE NULL END
            )
          ELSE '{}'::jsonb
        END
      ) key
      WHERE key IS NOT NULL  -- Fixed: was "value IS NOT NULL"
    );
  ELSIF TG_OP = 'DELETE' THEN
    action_type := 'deleted';
    changed_fields := '[]'::jsonb;
  END IF;

  -- Insert audit record
  INSERT INTO village_rules_audit (
    tenant_id,
    rule_id,
    action,
    old_data,
    new_data,
    changed_fields,
    performed_by
  ) VALUES (
    NEW.tenant_id,
    COALESCE(NEW.id, OLD.id),
    action_type,
    CASE WHEN TG_OP = 'DELETE' THEN row_to_json(OLD) ELSE row_to_json(OLD) END,
    CASE WHEN TG_OP = 'DELETE' THEN NULL ELSE row_to_json(NEW) END,
    changed_fields,
    COALESCE((auth.jwt() ->> 'user_id')::uuid, (auth.jwt() ->> 'sub')::uuid)
  );

  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Recreate the trigger
CREATE TRIGGER village_rules_audit_trigger
  AFTER INSERT OR UPDATE OR DELETE ON village_rules
  FOR EACH ROW EXECUTE FUNCTION log_rule_changes();