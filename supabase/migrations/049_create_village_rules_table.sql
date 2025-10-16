-- Migration: 049_create_village_rules_table.sql
-- Description: Create dedicated village_rules table for structured rule data
-- Author: Rules System Implementation
-- Date: 2025-10-16

-- Create village_rules table
CREATE TABLE IF NOT EXISTS village_rules (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  rule_category VARCHAR(50) NOT NULL CHECK (rule_category IN ('general', 'parking', 'noise', 'construction', 'curfew')),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  curfew_start_time TIME,
  curfew_end_time TIME,
  is_active BOOLEAN DEFAULT true,
  published BOOLEAN DEFAULT false,
  published_at TIMESTAMP WITH TIME ZONE,
  version INTEGER DEFAULT 1,
  published_by UUID REFERENCES user_profiles(id),
  effective_date DATE DEFAULT CURRENT_DATE,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_village_rules_tenant_id ON village_rules(tenant_id);
CREATE INDEX IF NOT EXISTS idx_village_rules_category ON village_rules(tenant_id, rule_category);
CREATE INDEX IF NOT EXISTS idx_village_rules_active ON village_rules(tenant_id, is_active);
CREATE INDEX IF NOT EXISTS idx_village_rules_order ON village_rules(tenant_id, rule_category, display_order);
CREATE INDEX IF NOT EXISTS idx_village_rules_published ON village_rules(tenant_id, published);
CREATE INDEX IF NOT EXISTS idx_village_rules_effective_date ON village_rules(tenant_id, effective_date);
CREATE INDEX IF NOT EXISTS idx_village_rules_version ON village_rules(tenant_id, version);

-- Add RLS (Row Level Security) for tenant isolation
ALTER TABLE village_rules ENABLE ROW LEVEL SECURITY;

-- RLS policy: Users can only read rules from their own tenant
CREATE POLICY "Users can view village rules from their tenant" ON village_rules
  FOR SELECT USING (
    tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
  );

-- RLS policy: Only admin officers and heads can manage rules
CREATE POLICY "Admin users can manage village rules" ON village_rules
  FOR ALL USING (
    tenant_id = (auth.jwt() ->> 'tenant_id')::uuid AND
    (auth.jwt() ->> 'app_role') IN ('admin_officer', 'admin_head')
  );

-- Add table comments
COMMENT ON TABLE village_rules IS 'Village rules and regulations with categorization and curfew settings';
COMMENT ON COLUMN village_rules.rule_category IS 'Category of the rule: general, parking, noise, construction, curfew';
COMMENT ON COLUMN village_rules.curfew_start_time IS 'Start time for curfew rules (NULL for non-curfew rules)';
COMMENT ON COLUMN village_rules.curfew_end_time IS 'End time for curfew rules (NULL for non-curfew rules)';
COMMENT ON COLUMN village_rules.is_active IS 'Whether the rule is currently active and displayed';
COMMENT ON COLUMN village_rules.published IS 'Whether the rule has been published to residents';
COMMENT ON COLUMN village_rules.published_at IS 'Timestamp when the rule was published';
COMMENT ON COLUMN village_rules.version IS 'Version number of the rule for tracking changes';
COMMENT ON COLUMN village_rules.published_by IS 'Admin user who published the rule';
COMMENT ON COLUMN village_rules.effective_date IS 'Date when the rule becomes effective';
COMMENT ON COLUMN village_rules.display_order IS 'Order in which to display rules within each category';

-- Trigger to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_village_rules_updated_at
  BEFORE UPDATE ON village_rules
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create function to auto-increment version on updates
CREATE OR REPLACE FUNCTION increment_rule_version()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.title != OLD.title OR NEW.description != OLD.description OR
     NEW.curfew_start_time != OLD.curfew_start_time OR NEW.curfew_end_time != OLD.curfew_end_time THEN
    NEW.version = OLD.version + 1;
    NEW.published = false;  -- Reset publication status on content changes
    NEW.published_at = NULL;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-increment version
CREATE TRIGGER village_rules_version_increment
  BEFORE UPDATE ON village_rules
  FOR EACH ROW
  EXECUTE FUNCTION increment_rule_version();

-- Create a view for published rules with metadata
CREATE OR REPLACE VIEW published_village_rules AS
SELECT
  vr.*,
  up.first_name || ' ' || up.last_name as published_by_name,
  up.email as published_by_email
FROM village_rules vr
LEFT JOIN user_profiles up ON vr.published_by = up.id
WHERE vr.published = true AND vr.effective_date <= CURRENT_DATE;

-- Add comments for the view
COMMENT ON VIEW published_village_rules IS 'View of published village rules with publisher metadata';
COMMENT ON COLUMN published_village_rules.published_by_name IS 'Full name of the admin who published the rule';
COMMENT ON COLUMN published_village_rules.published_by_email IS 'Email of the admin who published the rule';

-- Migrate data from association_settings.village_rules if it exists
-- Only run if the column exists (migration 047 may have been deleted)
DO $$
BEGIN
  -- Check if the village_rules column exists in association_settings
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'association_settings'
    AND column_name = 'village_rules'
  ) THEN
    INSERT INTO village_rules (tenant_id, rule_category, title, description, curfew_start_time, curfew_end_time, is_active, published, published_at, version, published_by, effective_date, display_order, created_at, updated_at)
    SELECT
      tenant_id,
      rule->>'category' as rule_category,
      rule->>'title' as title,
      rule->>'description' as description,
      CASE
        WHEN rule->>'curfewStartTime' IS NOT NULL THEN (rule->>'curfewStartTime')::time
        ELSE NULL
      END as curfew_start_time,
      CASE
        WHEN rule->>'curfewEndTime' IS NOT NULL THEN (rule->>'curfewEndTime')::time
        ELSE NULL
      END as curfew_end_time,
      COALESCE((rule->>'isActive')::boolean, true) as is_active,
      COALESCE((rule->>'isPublished')::boolean, true) as published,
      COALESCE((rule->>'publishedAt')::timestamp, NOW()) as published_at,
      COALESCE((rule->>'version')::integer, 1) as version,
      NULL::UUID as published_by, -- Will be set by admin during publishing workflow
      COALESCE((rule->>'effectiveDate')::date, CURRENT_DATE) as effective_date,
      COALESCE((rule->>'displayOrder')::integer, 0) as display_order,
      COALESCE((rule->>'createdAt')::timestamp, NOW()) as created_at,
      COALESCE((rule->>'updatedAt')::timestamp, NOW()) as updated_at
    FROM association_settings,
    jsonb_array_elements(association_settings.village_rules) as rule
    WHERE village_rules IS NOT NULL
      AND jsonb_array_length(village_rules) > 0
    ON CONFLICT DO NOTHING;
  ELSE
    -- No existing data to migrate, table is empty
    RAISE NOTICE 'No village_rules column found in association_settings - skipping data migration';
  END IF;
END $$;

-- Create rules audit table
CREATE TABLE IF NOT EXISTS village_rules_audit (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  rule_id UUID REFERENCES village_rules(id) ON DELETE CASCADE,
  action VARCHAR(20) NOT NULL CHECK (action IN ('created', 'updated', 'published', 'unpublished', 'deleted')),
  old_data JSONB,
  new_data JSONB,
  changed_fields JSONB,
  performed_by UUID REFERENCES user_profiles(id),
  performed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  ip_address INET,
  user_agent TEXT
);

-- Add indexes for audit trail
CREATE INDEX IF NOT EXISTS idx_village_rules_audit_tenant_id ON village_rules_audit(tenant_id);
CREATE INDEX IF NOT EXISTS idx_village_rules_audit_rule_id ON village_rules_audit(rule_id);
CREATE INDEX IF NOT EXISTS idx_village_rules_audit_action ON village_rules_audit(tenant_id, action);
CREATE INDEX IF NOT EXISTS idx_village_rules_audit_performed_at ON village_rules_audit(performed_at);
CREATE INDEX IF NOT EXISTS idx_village_rules_audit_performed_by ON village_rules_audit(performed_by);

-- Enable RLS for audit table
ALTER TABLE village_rules_audit ENABLE ROW LEVEL SECURITY;

-- RLS policies for audit table
CREATE POLICY "Users can view audit logs from their tenant" ON village_rules_audit
  FOR SELECT USING (
    tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
  );

CREATE POLICY "Admin users can create audit logs" ON village_rules_audit
  FOR INSERT WITH CHECK (
    tenant_id = (auth.jwt() ->> 'tenant_id')::uuid AND
    (auth.jwt() ->> 'app_role') IN ('admin_officer', 'admin_head')
  );

-- Add comments for audit table
COMMENT ON TABLE village_rules_audit IS 'Audit trail for all village rules changes and publications';
COMMENT ON COLUMN village_rules_audit.action IS 'Type of action performed on the rule';
COMMENT ON COLUMN village_rules_audit.old_data IS 'Previous state of the rule before the change';
COMMENT ON COLUMN village_rules_audit.new_data IS 'New state of the rule after the change';
COMMENT ON COLUMN village_rules_audit.changed_fields IS 'JSON array of field names that were changed';
COMMENT ON COLUMN village_rules_audit.performed_by IS 'Admin user who performed the action';
COMMENT ON COLUMN village_rules_audit.ip_address IS 'IP address from which the action was performed';
COMMENT ON COLUMN village_rules_audit.user_agent IS 'User agent string of the client';

-- Create function to automatically log rule changes
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

    -- Calculate changed fields
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
      WHERE value IS NOT NULL
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

-- Create triggers for audit logging
CREATE TRIGGER village_rules_audit_trigger
  AFTER INSERT OR UPDATE OR DELETE ON village_rules
  FOR EACH ROW EXECUTE FUNCTION log_rule_changes();

-- Create rules publication workflow table
CREATE TABLE IF NOT EXISTS rules_publication_workflow (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  rule_id UUID REFERENCES village_rules(id) ON DELETE CASCADE,
  workflow_status VARCHAR(20) NOT NULL DEFAULT 'draft'
    CHECK (workflow_status IN ('draft', 'review', 'approved', 'scheduled', 'published', 'rejected')),
  scheduled_publish_date TIMESTAMP WITH TIME ZONE,
  actual_publish_date TIMESTAMP WITH TIME ZONE,
  review_notes TEXT,
  reviewer_id UUID REFERENCES user_profiles(id),
  publisher_id UUID REFERENCES user_profiles(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for workflow
CREATE INDEX IF NOT EXISTS idx_rules_workflow_tenant_id ON rules_publication_workflow(tenant_id);
CREATE INDEX IF NOT EXISTS idx_rules_workflow_rule_id ON rules_publication_workflow(rule_id);
CREATE INDEX IF NOT EXISTS idx_rules_workflow_status ON rules_publication_workflow(tenant_id, workflow_status);
CREATE INDEX IF NOT EXISTS idx_rules_workflow_scheduled ON rules_publication_workflow(scheduled_publish_date);

-- Enable RLS for workflow table
ALTER TABLE rules_publication_workflow ENABLE ROW LEVEL SECURITY;

-- RLS policies for workflow table
CREATE POLICY "Admin users can manage workflow from their tenant" ON rules_publication_workflow
  FOR ALL USING (
    tenant_id = (auth.jwt() ->> 'tenant_id')::uuid AND
    (auth.jwt() ->> 'app_role') IN ('admin_officer', 'admin_head')
  );

-- Add comments for workflow table
COMMENT ON TABLE rules_publication_workflow IS 'Workflow for managing rules publication process';
COMMENT ON COLUMN rules_publication_workflow.workflow_status IS 'Current status in the publication workflow';
COMMENT ON COLUMN rules_publication_workflow.scheduled_publish_date IS 'Scheduled date for automatic publication';
COMMENT ON COLUMN rules_publication_workflow.actual_publish_date IS 'Actual date when rule was published';
COMMENT ON COLUMN rules_publication_workflow.review_notes IS 'Notes from review process';
COMMENT ON COLUMN rules_publication_workflow.reviewer_id IS 'Admin who reviewed the rule';
COMMENT ON COLUMN rules_publication_workflow.publisher_id IS 'Admin who published the rule';

-- Create trigger to update updated_at for workflow table
CREATE TRIGGER update_rules_publication_workflow_updated_at
  BEFORE UPDATE ON rules_publication_workflow
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();