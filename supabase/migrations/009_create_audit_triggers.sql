-- Migration: 009_create_audit_triggers.sql
-- Description: Create audit triggers for all tenant-scoped tables
-- Author: Platform App Implementation
-- Date: 2025-10-10

-- Generic audit logging function for all tables
CREATE OR REPLACE FUNCTION audit_trigger_function()
RETURNS TRIGGER AS $$
DECLARE
  tenant_id_value UUID;
  changed_fields_array TEXT[];
BEGIN
  -- Extract tenant_id from the record (NEW for INSERT/UPDATE, OLD for DELETE)
  -- Special case: tenants table uses 'id' instead of 'tenant_id'
  IF TG_TABLE_NAME = 'tenants' THEN
    IF TG_OP = 'DELETE' THEN
      tenant_id_value := OLD.id;
    ELSE
      tenant_id_value := NEW.id;
    END IF;
  ELSE
    IF TG_OP = 'DELETE' THEN
      tenant_id_value := OLD.tenant_id;
    ELSE
      tenant_id_value := NEW.tenant_id;
    END IF;
  END IF;

  -- Skip audit logging if tenant_id is NULL (e.g., super admin users)
  -- Audit logs table requires tenant_id, so we cannot log these records
  IF tenant_id_value IS NULL THEN
    IF TG_OP = 'DELETE' THEN
      RETURN OLD;
    ELSE
      RETURN NEW;
    END IF;
  END IF;

  -- For UPDATE operations, calculate changed fields
  IF TG_OP = 'UPDATE' THEN
    SELECT ARRAY_AGG(key)
    INTO changed_fields_array
    FROM jsonb_each(to_jsonb(NEW))
    WHERE to_jsonb(NEW)->key IS DISTINCT FROM to_jsonb(OLD)->key;
  END IF;

  -- Insert audit log entry
  INSERT INTO audit_logs (
    tenant_id,
    user_id,
    table_name,
    operation,
    old_data,
    new_data,
    changed_fields,
    timestamp
  ) VALUES (
    tenant_id_value,
    auth.uid(), -- Current authenticated user
    TG_TABLE_NAME,
    TG_OP,
    CASE WHEN TG_OP IN ('UPDATE', 'DELETE') THEN to_jsonb(OLD) ELSE NULL END,
    CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN to_jsonb(NEW) ELSE NULL END,
    changed_fields_array,
    NOW()
  );

  -- Return appropriate record
  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  ELSE
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Apply audit triggers to all tenant-scoped tables
CREATE TRIGGER audit_tenants_trigger
  AFTER INSERT OR UPDATE OR DELETE ON tenants
  FOR EACH ROW
  EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER audit_properties_trigger
  AFTER INSERT OR UPDATE OR DELETE ON properties
  FOR EACH ROW
  EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER audit_residence_units_trigger
  AFTER INSERT OR UPDATE OR DELETE ON residence_units
  FOR EACH ROW
  EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER audit_gates_trigger
  AFTER INSERT OR UPDATE OR DELETE ON gates
  FOR EACH ROW
  EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER audit_admin_users_trigger
  AFTER INSERT OR UPDATE OR DELETE ON admin_users
  FOR EACH ROW
  EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER audit_association_settings_trigger
  AFTER INSERT OR UPDATE OR DELETE ON association_settings
  FOR EACH ROW
  EXECUTE FUNCTION audit_trigger_function();

-- Comments
COMMENT ON FUNCTION audit_trigger_function IS 'Generic audit logging function for all tenant-scoped tables';
