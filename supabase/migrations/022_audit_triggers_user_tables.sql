-- Migration: 021_audit_triggers_user_tables.sql
-- Description: Add audit triggers for user_profiles and user_roles tables
-- Author: Platform App Implementation
-- Date: 2025-10-12

-- Add audit trigger for user_profiles table
CREATE TRIGGER audit_user_profiles_trigger
  AFTER INSERT OR UPDATE OR DELETE ON user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION audit_trigger_function();

-- Add audit trigger for user_roles table
CREATE TRIGGER audit_user_roles_trigger
  AFTER INSERT OR UPDATE OR DELETE ON user_roles
  FOR EACH ROW
  EXECUTE FUNCTION audit_trigger_function();

-- Comments
COMMENT ON TRIGGER audit_user_profiles_trigger ON user_profiles IS 'Audit trail for user profile changes';
COMMENT ON TRIGGER audit_user_roles_trigger ON user_roles IS 'Audit trail for user role changes';
