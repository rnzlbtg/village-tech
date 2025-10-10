# Research Findings: Platform App - Multi-Tenant Management System

**Date**: 2025-10-10
**Feature**: Platform App - Multi-Tenant Management
**Purpose**: Resolve technical unknowns and establish implementation patterns

---

## 1. Bulk Import Strategies for Property/Residence Data

### Decision
Use **server-side processing with PapaParse (CSV) / SheetJS (Excel)** combined with **PostgreSQL COPY command** or **batched inserts via Supabase Edge Functions**.

### Rationale
- Server-side processing provides better security, validation control, and handles large files without browser memory constraints
- PostgreSQL COPY command offers 4-10x performance improvement over regular inserts for bulk operations
- PapaParse and SheetJS are battle-tested, widely adopted libraries
- Edge Functions enable transaction control and proper error handling

### Implementation Pattern
```
High-Level Flow:
1. Client uploads file via Next.js API Route
2. File parsed server-side using PapaParse (CSV) or SheetJS (Excel)
3. Data validated using Zod schema before database operations
4. Bulk insert using PostgreSQL COPY or batched inserts (1,000-10,000 rows/batch)
5. All operations wrapped in database transaction
6. Real-time progress updates via streaming or polling
7. Rollback on error with detailed error reporting

Transaction Handling:
BEGIN TRANSACTION;
  - Validate all rows
  - Batch insert (using COPY or batched INSERT)
  - If error: ROLLBACK
  - If success: COMMIT
END TRANSACTION;
```

### Key Packages/Tools
- **papaparse** (v5.4.1+) - CSV parsing, fastest client/server-side parser
- **xlsx / SheetJS** (v0.20.0+) - Excel file handling
- **zod** (v3.22+) - TypeScript-first schema validation
- **PostgreSQL COPY** command (via raw SQL)
- **Supabase Edge Functions** for transaction orchestration

### Alternatives Considered
- **Client-Side Processing**: Rejected due to browser memory limits and security risks
- **Server Actions**: Rejected for large files due to 1MB default body limit
- **Direct Supabase API**: Use for medium datasets (<1000 rows), not recommended for very large datasets

### Security/Performance Considerations
- Validate file type and size before processing (max 50MB recommended)
- Use Zod schema validation for every row
- Sanitize all input to prevent SQL injection
- Rate limiting on upload endpoints
- PostgreSQL COPY command: 4-10x faster than batched inserts
- Batch size sweet spot: 1,000-10,000 rows per transaction
- Provide row-by-row validation errors with line numbers
- Disable database triggers during bulk import, rebuild indexes after

---

## 2. Audit Logging Best Practices

### Decision
Use **database triggers for automatic audit logging** with **table partitioning** for performance and retention management.

### Rationale
- Database triggers ensure 100% coverage regardless of application code paths
- Automatic logging prevents developer oversight
- Partitioning enables fast archival and cleanup
- Supabase provides battle-tested audit pattern
- Defense-in-depth approach catches all database changes

### Implementation Pattern
```
Trigger-Based Audit System:
1. Create audit log table with partitioning (monthly partitions)
2. Implement PostgreSQL triggers on audited tables (INSERT, UPDATE, DELETE)
3. Capture: user_id, timestamp, operation, table_name, row_id, old_values, new_values
4. Use JSONB columns for flexible before/after value storage
5. Leverage RLS policies to control audit log access
6. Implement automatic partition management via pg_partman

Audit Table Schema:
- id (uuid, primary key)
- timestamp (timestamptz, partition key)
- user_id (uuid, from JWT)
- operation (text: INSERT/UPDATE/DELETE)
- table_name (text)
- record_id (uuid)
- old_data (jsonb)
- new_data (jsonb)
- ip_address (inet)
```

### Key Packages/Tools
- **PostgreSQL native triggers**
- **pg_partman** - Automated partition management
- **pg_cron** - Scheduled partition cleanup/archival
- **Supabase supa-audit pattern** (official recommendation)

### Alternatives Considered
- **Application-Level Logging Only**: Rejected as primary approach; easy to miss operations
- **pgAudit Extension**: Use for compliance requirements, not primary audit trail (logs to files, not queryable tables)
- **Hybrid Approach (Selected)**: Database triggers for data changes + application-level logging for business events

### Security/Performance Considerations
**What to Capture:**
- Required: user_id, timestamp, operation type, table/record identifier
- Recommended: before/after values (JSONB), IP address
- Avoid: Sensitive data (passwords, PII) - use masking

**Performance:**
- Table Partitioning: Monthly partitions (500x improvement on range queries)
- Indexing: Index on timestamp, user_id, table_name, operation
- Selective Logging: Only audit security-critical tables
- Avoid Over-Logging: Balance compliance needs with performance

**Retention & Archival:**
- Active Data: 90 days in primary partitions
- Archive: 1-7 years in detached partitions
- Automation: Use pg_partman for creation, pg_cron for archival

---

## 3. Multi-Tenant RLS Policy Patterns for Supabase

### Decision
Implement **tenant_id column with RLS policies** using **JWT custom claims** for tenant context, with **mandatory indexing** on tenant_id.

### Rationale
- RLS provides database-level security (defense-in-depth)
- Tenant isolation guaranteed regardless of application code bugs
- JWT claims eliminate expensive subqueries in policies
- Indexing prevents performance degradation on large datasets
- Supabase's built-in RLS integration simplifies implementation

### Implementation Pattern
```
Core Architecture:
1. Add tenant_id column to all tenant-scoped tables
2. Create foreign key to tenants.id table
3. Store tenant_id in JWT custom claims via Custom Access Token Hook
4. Implement RLS policies using JWT claims: (auth.jwt() ->> 'tenant_id')::uuid
5. Index tenant_id as last column in composite indexes
6. Enable RLS from day one on all tables

Policy Template - Tenant Isolation:
CREATE POLICY "Users can only see their tenant's data"
ON table_name FOR SELECT
TO authenticated
USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

Policy Template - Super Admin Access:
CREATE POLICY "Super admins can access all tenants"
ON table_name FOR ALL
TO authenticated
USING (
  (auth.jwt() ->> 'role')::text = 'super_admin'
  OR tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
);
```

### Key Packages/Tools
- **PostgreSQL Row Level Security** (built-in)
- **Supabase Auth with Custom Access Token Hooks**
- **JWT custom claims** for tenant context
- **pgTAP** for RLS policy unit tests

### Alternatives Considered
- **Separate Schemas per Tenant**: Rejected due to schema management complexity; only for regulated industries
- **Application-Level Tenant Filtering**: Rejected as sole mechanism; no defense-in-depth, SQL injection risks
- **Composite Primary Keys with tenant_id**: Use for specific high-volume tables only

### Security/Performance Considerations
**Critical Security Rules:**
1. Never trust user_metadata in RLS policies (user-modifiable)
2. Use app_metadata or JWT custom claims (only modifiable by service role)
3. Enable RLS from day one (tables without RLS allow unrestricted access)
4. Always specify role in policies (use `TO authenticated`)
5. Test policies thoroughly with SQL session role switching

**Performance Optimization:**
- **Mandatory Indexing**: `CREATE INDEX idx_table_user_tenant ON table_name(user_id, tenant_id);`
- Index tenant_id LAST in composite indexes for optimal query plans
- **Function Wrapping**: Use `(SELECT auth.jwt()->>'tenant_id')::uuid` to cache result

**Common Pitfalls:**
- Missing indexes: 100x+ slowdown on large tables
- Not wrapping functions: Call auth.uid() once, not per row
- Overly complex policies: Subqueries kill performance - use JWT claims
- Using service_role in policies: Service role ALWAYS bypasses RLS

**Recommended tenant_id Strategy:**
- Type: UUID (not integer for security)
- Null: NOT NULL (every row must have tenant)
- Foreign Key: REFERENCES tenants(id) ON DELETE CASCADE
- Index: Always include in composite indexes (last position)

---

## 4. Super Admin Authentication and Role Management

### Decision
Use **Supabase app_metadata with custom JWT claims** for role storage, enforced via **Custom Access Token Hook**, with **Next.js middleware** for route protection.

### Rationale
- app_metadata is secure (only modifiable by service role)
- JWT custom claims enable RLS policies and route guards
- Custom Access Token Hooks ensure claims always in sync
- Middleware provides centralized route protection
- Prevents privilege escalation through client-side manipulation

### Implementation Pattern
```
Role Management Flow:
1. Store roles in user_roles table (user_id, role)
2. Custom Access Token Hook fetches role and adds to JWT claims
3. JWT contains: { role: 'super_admin', tenant_id: null }
4. Next.js middleware checks JWT claims before rendering routes
5. RLS policies use JWT claims for data access control
6. Server-side validation on ALL data operations

Custom Access Token Hook (Supabase):
CREATE OR REPLACE FUNCTION custom_access_token_hook(event jsonb)
RETURNS jsonb AS $$
DECLARE
  user_role text;
BEGIN
  SELECT role INTO user_role
  FROM user_roles
  WHERE user_id = (event->>'user_id')::uuid;

  event := jsonb_set(event, '{claims,user_role}', to_jsonb(user_role));
  RETURN event;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

Next.js Middleware (Route Protection):
- Use getUser() (NOT getSession()) for server-side validation
- Check user.app_metadata.role
- Redirect unauthorized users
- Apply to /super-admin/* routes
```

### Key Packages/Tools
- **Supabase Auth with Custom Access Token Hook**
- **@supabase/ssr** (v0.5.0+) - SSR-compatible auth
- **Next.js middleware** (built-in)
- **Secure HTTP-only cookies** (via @supabase/ssr)
- **PKCE flow** (automatic)

### Alternatives Considered
- **user_metadata for Roles**: Rejected - user-modifiable, major security vulnerability
- **Database Table Lookup on Every Request**: Rejected - performance overhead
- **Third-Party Auth (Auth0, Clerk)**: Use for complex enterprise requirements; Supabase sufficient for most cases

### Security/Performance Considerations
**Critical Security Practices:**

1. **Always Use getUser() on Server:**
```typescript
// DANGEROUS - Session can be spoofed
const { data: { session } } = await supabase.auth.getSession()

// SAFE - Validates with auth server
const { data: { user } } = await supabase.auth.getUser()
```

2. **Server-Side Validation Required:**
- Client-side checks are for UX only
- ALWAYS validate roles server-side in API routes and Server Actions
- NEVER trust client-provided role information

3. **Role Hierarchy:**
```
super_admin (platform-wide access, all tenants)
  └─ tenant_admin (single tenant management)
      └─ user (tenant-scoped access)
```

4. **Preventing Privilege Escalation:**
- Store roles in app_metadata or dedicated table (NOT user_metadata)
- Only service role can modify user roles
- Validate role changes server-side
- Audit all role modifications
- Implement principle of least privilege

**JWT Token Management:**
- Access Token Expiry: 1 hour (recommended)
- Refresh Token: Single-use tokens (prevents replay attacks)
- Secure cookies: sameSite: 'Lax', secure: true, httpOnly: true

**Route Protection Patterns:**
- **Middleware**: Centralized security logic, runs before page renders
- **Server Components**: Per-component authorization with getUser()
- **API Routes**: Always validate roles server-side, use service role client

**Super Admin Considerations:**
- Tenant Context: Super admins may impersonate/view any tenant
- Audit Everything: Log all super admin actions
- MFA Requirement: Consider requiring MFA for super admin accounts
- Session Timeout: Shorter timeout for super admins

---

## Summary & Recommendations

### Technology Stack
- **Frontend**: Next.js 14+ with App Router
- **Backend**: Supabase (PostgreSQL + Auth + Edge Functions)
- **Validation**: Zod
- **File Parsing**: PapaParse (CSV), SheetJS (Excel)
- **Auth**: @supabase/ssr with Custom Access Token Hook

### Security Checklist
- ✅ RLS enabled on all tables
- ✅ Roles stored in app_metadata (not user_metadata)
- ✅ Server-side validation with getUser() (not getSession())
- ✅ JWT custom claims for tenant and role context
- ✅ Middleware protection on admin routes
- ✅ Audit logging with triggers
- ✅ Input validation on all user data
- ✅ Rate limiting on upload endpoints

### Performance Checklist
- ✅ Index tenant_id on all multi-tenant tables
- ✅ Wrap auth functions in SELECT for RLS policies
- ✅ Use PostgreSQL COPY for bulk imports
- ✅ Partition audit log tables monthly
- ✅ Explicit WHERE clauses even with RLS
- ✅ Batch operations (1,000-10,000 rows)

### Implementation Priority
1. **Enable RLS immediately** - Foundation for multi-tenant security
2. **Implement role management** - Required for admin features
3. **Set up audit logging** - Track all changes from day one
4. **Build bulk import** - Administrative efficiency feature

---

**Research Completed**: 2025-10-10
**Next Phase**: Phase 1 - Design & Contracts (data-model.md, contracts/, quickstart.md)
