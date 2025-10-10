# Data Model: Platform App - Multi-Tenant Management

**Feature**: Platform App - Multi-Tenant Management
**Date**: 2025-10-10
**Database**: Supabase PostgreSQL with Row-Level Security (RLS)

---

## Core Entities

### 1. tenants
**Purpose**: Residential communities (multi-tenant isolation)

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique tenant identifier |
| name | text | NOT NULL, UNIQUE | Community name |
| address | text | NOT NULL | Physical address |
| contact_name | text | NOT NULL | Primary contact |
| contact_email | text | NOT NULL | Contact email |
| contact_phone | text | NOT NULL | Contact phone |
| subscription_status | text | NOT NULL, default: 'active' | Status: active, suspended, cancelled |
| settings | jsonb | NOT NULL, default: '{}' | Tenant-specific settings |
| created_at | timestamptz | NOT NULL, default: now() | Record creation |
| updated_at | timestamptz | NOT NULL, default: now() | Record update |

**Indexes**: `idx_tenants_name` ON (name), `idx_tenants_status` ON (subscription_status)

**RLS Policy**: Super admins full access

---

### 2. properties
**Purpose**: Buildings/areas within a tenant

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique property identifier |
| tenant_id | uuid | FK, NOT NULL | Reference to tenant |
| property_type | text | NOT NULL | Type: building, lot, townhouse |
| name | text | NOT NULL | Property name |
| address | text | NULLABLE | Property address |
| created_at | timestamptz | NOT NULL, default: now() | Record creation |
| updated_at | timestamptz | NOT NULL, default: now() | Record update |

**Indexes**: `idx_properties_tenant` ON (tenant_id)

**RLS Policy**: Super admins OR users with matching tenant_id

---

### 3. residence_units
**Purpose**: Individual dwellings

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique unit identifier |
| tenant_id | uuid | FK, NOT NULL | Reference to tenant |
| property_id | uuid | FK, NOT NULL | Reference to property |
| unit_number | text | NOT NULL | Unit/lot number |
| address | text | NULLABLE | Full address |
| status | text | NOT NULL, default: 'vacant' | Status: vacant, occupied, maintenance |
| created_at | timestamptz | NOT NULL, default: now() | Record creation |
| updated_at | timestamptz | NOT NULL, default: now() | Record update |

**Indexes**: `idx_residence_units_tenant` ON (tenant_id), `idx_residence_units_property` ON (property_id)

**Unique Constraint**: (tenant_id, property_id, unit_number)

**RLS Policy**: Super admins OR users with matching tenant_id

---

### 4. gates
**Purpose**: Physical entrance points

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique gate identifier |
| tenant_id | uuid | FK, NOT NULL | Reference to tenant |
| name | text | NOT NULL | Gate name |
| location | text | NOT NULL | Physical location |
| operational_status | text | NOT NULL, default: 'active' | Status: active, maintenance, inactive |
| equipment_config | jsonb | NOT NULL, default: '{}' | RFID/hardware config |
| created_at | timestamptz | NOT NULL, default: now() | Record creation |
| updated_at | timestamptz | NOT NULL, default: now() | Record update |

**Indexes**: `idx_gates_tenant` ON (tenant_id)

**RLS Policy**: Super admins OR users with matching tenant_id

---

### 5. admin_users
**Purpose**: Administrative user accounts

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique user identifier (from Supabase Auth) |
| tenant_id | uuid | FK, NULLABLE | Reference to tenant (NULL for super admin) |
| role | text | NOT NULL | Role: super_admin, admin_head, admin_officer |
| email | text | NOT NULL, UNIQUE | User email |
| full_name | text | NOT NULL | User full name |
| phone | text | NULLABLE | Contact phone |
| active | boolean | NOT NULL, default: true | Account active status |
| created_at | timestamptz | NOT NULL, default: now() | Record creation |
| updated_at | timestamptz | NOT NULL, default: now() | Record update |

**Indexes**: `idx_admin_users_tenant` ON (tenant_id), `idx_admin_users_email` ON (email), `idx_admin_users_role` ON (role)

**RLS Policy**: Super admins full access; tenant admins can read their tenant's users

---

### 6. association_settings
**Purpose**: Tenant-level operational parameters

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique setting identifier |
| tenant_id | uuid | FK, NOT NULL | Reference to tenant |
| setting_key | text | NOT NULL | Setting key |
| setting_value | jsonb | NOT NULL | Setting value |
| created_at | timestamptz | NOT NULL, default: now() | Record creation |
| updated_at | timestamptz | NOT NULL, default: now() | Record update |

**Indexes**: `idx_association_settings_tenant` ON (tenant_id)

**Unique Constraint**: (tenant_id, setting_key)

**RLS Policy**: Super admins OR users with matching tenant_id

---

### 7. audit_logs (partitioned by month)
**Purpose**: Comprehensive audit trail

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique log identifier |
| timestamp | timestamptz | NOT NULL, partition key | Event timestamp |
| user_id | uuid | FK, NULLABLE | User who made change |
| operation | text | NOT NULL | Operation: INSERT, UPDATE, DELETE |
| table_name | text | NOT NULL | Affected table |
| record_id | uuid | NOT NULL | Affected record |
| old_data | jsonb | NULLABLE | Before values |
| new_data | jsonb | NULLABLE | After values |
| ip_address | inet | NULLABLE | Client IP |

**Indexes**: `idx_audit_logs_timestamp` ON (timestamp), `idx_audit_logs_user` ON (user_id), `idx_audit_logs_table` ON (table_name)

**RLS Policy**: Super admins full access

---

## Entity Relationships

```
tenants (1) ─┬─ (N) properties
              ├─ (N) residence_units
              ├─ (N) gates
              ├─ (N) admin_users (tenant_id NOT NULL)
              └─ (N) association_settings

properties (1) ─── (N) residence_units

admin_users: super_admins have tenant_id = NULL
```

---

## RLS Policies

### Super Admin Access (all tables)
```sql
CREATE POLICY "Super admins have full access"
ON {table_name} FOR ALL
TO authenticated
USING ((auth.jwt() ->> 'role')::text = 'super_admin');
```

### Tenant-Scoped Access
```sql
CREATE POLICY "Tenant users can access their data"
ON {table_name} FOR SELECT
TO authenticated
USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);
```

---

## State Transitions

### Tenant Subscription Status
```
active → suspended (manual, by super admin)
suspended → active (manual, after resolution)
active → cancelled (manual, tenant offboarding)
```

### Residence Unit Status
```
vacant → occupied (when household assigned)
occupied → vacant (when household moves out)
any → maintenance (manual, during repairs)
maintenance → previous_status (after completion)
```

### Gate Operational Status
```
active → maintenance (manual, for repairs)
maintenance → active (after repairs complete)
active → inactive (manual, gate decommissioned)
```

---

## Audit Log Strategy

- **Automatic Triggers**: On tenants, properties, residence_units, gates, admin_users, association_settings
- **Partitioning**: Monthly partitions, automated via pg_partman
- **Retention**: 90 days active, 7 years archived
- **Access**: Super admins only

---

**Data Model Version**: 1.0.0
**Next Steps**: Generate API contracts in contracts/ directory
