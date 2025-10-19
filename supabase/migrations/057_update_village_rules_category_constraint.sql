-- Migration: 057_update_village_rules_category_constraint.sql
-- Description: Update village_rules rule_category check constraint to include all categories used by the form
-- Author: Rules System Fix
-- Date: 2025-10-16

-- Drop the existing constraint
ALTER TABLE village_rules DROP CONSTRAINT IF EXISTS village_rules_rule_category_check;

-- Add the updated constraint with all categories from the form
ALTER TABLE village_rules
ADD CONSTRAINT village_rules_rule_category_check
CHECK (rule_category IN ('general', 'security', 'construction', 'parking', 'noise', 'pets', 'other'));

-- Update the comment to reflect the new categories
COMMENT ON COLUMN village_rules.rule_category IS 'Category of the rule: general, security, construction, parking, noise, pets, other';