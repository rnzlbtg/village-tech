# Data Isolation Implementation

**Feature**: Multi-Tenant Data Isolation
**Implementation Strategy**: Row-Level Security (RLS)
**Database**: Supabase PostgreSQL
**Status**: Implemented
**Date**: 2025-10-13

## Overview

The application implements **PostgreSQL Row-Level Security (RLS)** for multi-tenant data isolation, ensuring complete data segregation between tenants at the database level.

## Implementation Approach

### Option Selected: Row-Level Security (RLS)

**Database-enforced isolation** where PostgreSQL RLS policies prevent cross-tenant queries at the database level. Even if application code has bugs, users cannot access other tenants' data because PostgreSQL blocks unauthorized access.

### Why RLS?

- **Security**: Database-enforced (not just application-level filtering)
- **Performance**: Single database, optimized queries with proper indexing
- **Operational Simplicity**: One database instance, easier backups/maintenance
- **Cost Effective**: No need for multiple database instances or schemas

## Architecture

### JWT Claims

User authentication tokens include:
- `tenant_id`: UUID of assigned tenant
- `role`: User role (super_admin, admin_head, admin_officer, household_head, guard)

### RLS Policy Pattern

All tenant-scoped tables follow this pattern:

```sql
CREATE POLICY "Role-based access"
ON table_name
FOR SELECT|INSERT|UPDATE|DELETE
TO authenticated
USING (
  tenant_id = (auth.jwt() ->> 'tenant_id')::UUID
  AND (auth.jwt() ->> 'role')::TEXT IN ('allowed_roles')
);
```

### Special Case: Super Admin

Super admins have platform-wide access:

```sql
CREATE POLICY "Super admins have full access"
ON table_name
FOR ALL
TO authenticated
USING (
  (auth.jwt() ->> 'role')::TEXT = 'super_admin'
);
```

## Tables with RLS Protection

All tenant-scoped tables have RLS enabled:

1. **tenants** - Community/tenant records
2. **properties** - Property structures within tenants
3. **residence_units** - Individual dwelling units
4. **gates** - Gate entrances and equipment
5. **admin_users** - Administrative user accounts (historical/deprecated)
6. **user_profiles** - User profile information
7. **user_roles** - Role assignments per tenant
8. **association_settings** - Tenant-level configuration
9. **audit_logs** - Audit trail with tenant isolation

## Access Control Matrix

| Role | Tenants | Properties | Residence Units | Gates | Admin Users | Audit Logs |
|------|---------|-----------|----------------|-------|-------------|------------|
| super_admin | All (CRUD) | All (CRUD) | All (CRUD) | All (CRUD) | All (CRUD) | All (R) |
| admin_head | Own (R) | Own (CRUD) | Own (CRUD) | Own (CRUD) | Own (CRUD) | Own (R) |
| admin_officer | Own (R) | Own (CRUD) | Own (CRUD) | Own (CRUD) | Own (R) | Own (R) |
| household_head | Own (R) | Own (R) | Own (R) | Own (R) | - | - |
| guard | Own (R) | Own (R) | Own (R) | Own (R) | - | - |

**Legend**: R=Read, C=Create, U=Update, D=Delete, Own=Own tenant only

## Example: Properties Table RLS

```sql
-- Migration: 013_rls_properties.sql

-- Super admins see everything
CREATE POLICY "Super admins manage all properties"
ON properties
FOR ALL
TO authenticated
USING ((auth.jwt() ->> 'role')::TEXT = 'super_admin');

-- Tenant admins manage only their tenant's properties
CREATE POLICY "Admins manage tenant properties"
ON properties
FOR ALL
TO authenticated
USING (
  tenant_id = (auth.jwt() ->> 'tenant_id')::UUID
  AND (auth.jwt() ->> 'role')::TEXT IN ('admin_head', 'admin_officer')
);

-- Household heads read only their tenant's properties
CREATE POLICY "Household heads read tenant properties"
ON properties
FOR SELECT
TO authenticated
USING (
  tenant_id = (auth.jwt() ->> 'tenant_id')::UUID
  AND (auth.jwt() ->> 'role')::TEXT = 'household_head'
);
```

## Security Guarantees

### 1. Database-Level Enforcement

RLS policies are enforced by PostgreSQL, independent of application code:
- Even direct SQL queries respect RLS
- No way to bypass policies without database superuser access
- Application bugs cannot leak cross-tenant data

### 2. JWT-Based Claims

- `tenant_id` and `role` stored in JWT app_metadata
- Set by Custom Access Token Hook during authentication
- Cannot be modified by client-side code
- Verified on every database request

### 3. Mandatory Filtering

All queries automatically filtered by:
- User's assigned `tenant_id` from JWT
- User's `role` permissions from JWT
- No explicit `WHERE tenant_id = ?` needed in application code

## Performance Considerations

### Indexing Strategy

All tenant-scoped tables have composite indexes:

```sql
CREATE INDEX idx_properties_tenant_id ON properties(tenant_id);
CREATE INDEX idx_residence_units_tenant_property
  ON residence_units(tenant_id, property_id);
```

### Query Performance

- RLS adds minimal overhead (JWT extraction + tenant_id filter)
- Proper indexes ensure efficient tenant-scoped queries
- Query planner optimizes RLS predicates

## Testing & Validation

### Test Scenarios

1. **Cross-tenant access attempts**: Verify users cannot access other tenants' data
2. **Super admin access**: Verify super admins see all tenant data
3. **Role-based access**: Verify each role sees only permitted data
4. **JWT tampering**: Verify modified JWTs are rejected

### Validation Queries

```sql
-- Verify RLS is enabled on all tenant tables
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('tenants', 'properties', 'residence_units', 'gates');

-- List all RLS policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE schemaname = 'public';
```

## Migration Files

RLS policies are defined in these migration files:

- `supabase/migrations/012_rls_tenants.sql`
- `supabase/migrations/013_rls_properties.sql`
- `supabase/migrations/014_rls_residence_units.sql`
- `supabase/migrations/015_rls_gates.sql`
- `supabase/migrations/016_rls_admin_users.sql`
- `supabase/migrations/017_rls_association_settings.sql`
- `supabase/migrations/018_rls_audit_logs.sql`
- `supabase/migrations/021_rls_user_roles.sql`

## Related Documentation

- **Custom Access Token Hook**: `supabase/migrations/011_custom_access_token_hook.sql`
- **Data Model**: `specs/001-platform-app-multi/data-model.md`
- **Specification**: `specs/001-platform-app-multi/spec.md` (FR-003)
- **Implementation Plan**: `specs/001-platform-app-multi/plan.md`

## Compliance with Requirements

### FR-003: Multi-tenant data isolation

> "System MUST support multi-tenant data isolation ensuring each tenant's data is completely segregated"

**Status**: ✅ **IMPLEMENTED**

- Database-enforced RLS on all tenant-scoped tables
- JWT-based tenant identification
- Zero cross-tenant data leakage possible
- Super admin role for platform management
- Comprehensive access control matrix

### Success Criteria SC-004

> "All tenant data remains completely isolated with zero data leakage incidents between tenants"

**Implementation**: RLS guarantees zero cross-tenant queries at database level.

## Maintenance

### Adding New Tenant-Scoped Tables

When adding new tables with tenant data:

1. Add `tenant_id UUID REFERENCES tenants(id)` column
2. Create RLS policies following existing patterns
3. Add tenant_id index: `CREATE INDEX idx_table_tenant_id ON table(tenant_id)`
4. Enable RLS: `ALTER TABLE table ENABLE ROW LEVEL SECURITY`
5. Test cross-tenant access prevention

### Policy Updates

When modifying access control:

1. Update RLS policy SQL in new migration file
2. Test with each role type
3. Verify existing queries still work
4. Update this documentation

## Known Limitations

1. **Super admin visibility**: Super admins see all data (by design for platform management)
2. **Performance at scale**: Large tenant counts (>10,000) may require partitioning strategies
3. **Service role bypass**: Supabase service role bypasses RLS (use carefully in backend)

## Future Considerations

- **Audit log partitioning**: Implement time-based partitioning for audit_logs table
- **Performance monitoring**: Add query performance tracking per tenant
- **Compliance reporting**: Generate tenant isolation compliance reports
