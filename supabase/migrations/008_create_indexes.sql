-- Migration: 008_create_indexes.sql
-- Description: Create additional performance indexes for all tables
-- Author: Platform App Implementation
-- Date: 2025-10-10

-- Enable pg_trgm extension for trigram search (must be before creating trigram indexes)
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Composite indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_properties_tenant_name ON properties(tenant_id, name);
CREATE INDEX IF NOT EXISTS idx_residence_units_tenant_property ON residence_units(tenant_id, property_id);
CREATE INDEX IF NOT EXISTS idx_gates_tenant_status ON gates(tenant_id, operational_status);
CREATE INDEX IF NOT EXISTS idx_admin_users_tenant_role ON admin_users(tenant_id, role) WHERE is_active = true;

-- Indexes for filtering and sorting
CREATE INDEX IF NOT EXISTS idx_tenants_created_at ON tenants(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_properties_created_at ON properties(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_residence_units_created_at ON residence_units(created_at DESC);

-- Full-text search indexes (for future search functionality)
CREATE INDEX IF NOT EXISTS idx_tenants_name_trgm ON tenants USING gin(name gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_properties_name_trgm ON properties USING gin(name gin_trgm_ops);

-- Comments
COMMENT ON INDEX idx_properties_tenant_name IS 'Composite index for tenant-scoped property lookup by name';
COMMENT ON INDEX idx_residence_units_tenant_property IS 'Composite index for residence unit queries within tenant and property';
COMMENT ON INDEX idx_gates_tenant_status IS 'Composite index for filtering gates by tenant and operational status';
COMMENT ON INDEX idx_tenants_name_trgm IS 'Trigram index for fuzzy search on tenant names';
