# Data Model: Admin App - Residential Community Administration

**Feature**: Admin App - Residential Community Administration
**Date**: 2025-10-10
**Database**: Supabase PostgreSQL with Row-Level Security (RLS)

---

## Core Entities

### 1. households
**Purpose**: Residence assignment and household management

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique household identifier |
| tenant_id | uuid | FK, NOT NULL | Reference to tenant |
| residence_unit_id | uuid | FK, NOT NULL | Reference to residence_units |
| household_head_id | uuid | FK, NULLABLE | Reference to user (Supabase Auth) |
| household_name | text | NOT NULL | Household identifier name |
| move_in_date | date | NULLABLE | Date household moved in |
| status | text | NOT NULL, default: 'active' | Status: active, moved_out, suspended |
| created_at | timestamptz | NOT NULL, default: now() | Record creation |
| updated_at | timestamptz | NOT NULL, default: now() | Record update |

**Indexes**: `idx_households_tenant` ON (tenant_id), `idx_households_residence` ON (residence_unit_id), `idx_households_head` ON (household_head_id)

**RLS Policy**: Tenant admins can CRUD their tenant's households; household heads can read their own

---

### 2. household_members
**Purpose**: Family members and residents in household

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique member identifier |
| household_id | uuid | FK, NOT NULL | Reference to household |
| full_name | text | NOT NULL | Member name |
| relationship | text | NOT NULL | Relationship: head, spouse, child, parent, other |
| contact_number | text | NULLABLE | Contact phone |
| email | text | NULLABLE | Email address |
| birth_date | date | NULLABLE | Date of birth |
| created_at | timestamptz | NOT NULL, default: now() | Record creation |

**Indexes**: `idx_household_members_household` ON (household_id)

**RLS Policy**: Admins and household heads can manage

---

### 3. sticker_programs
**Purpose**: Tenant-wide vehicle sticker allocation rules

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique program identifier |
| tenant_id | uuid | FK, NOT NULL | Reference to tenant |
| program_name | text | NOT NULL | Program name |
| stickers_per_household | int | NOT NULL | Max stickers per household |
| effective_date | date | NOT NULL | Program start date |
| expiry_date | date | NULLABLE | Program end date |
| active | boolean | NOT NULL, default: true | Program active status |
| created_at | timestamptz | NOT NULL, default: now() | Record creation |

**Indexes**: `idx_sticker_programs_tenant` ON (tenant_id)

**RLS Policy**: Admins can CRUD for their tenant

---

### 4. sticker_requests
**Purpose**: Household vehicle sticker requests

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique request identifier |
| household_id | uuid | FK, NOT NULL | Reference to household |
| vehicle_plate | text | NOT NULL | Vehicle plate number |
| vehicle_make | text | NULLABLE | Vehicle make/model |
| vehicle_color | text | NULLABLE | Vehicle color |
| owner_name | text | NOT NULL | Vehicle owner name |
| status | text | NOT NULL, default: 'pending' | Status: pending, approved, distributed, rejected |
| requested_at | timestamptz | NOT NULL, default: now() | Request timestamp |
| approved_at | timestamptz | NULLABLE | Approval timestamp |
| approved_by | uuid | FK, NULLABLE | Admin who approved |
| distributed_at | timestamptz | NULLABLE | Distribution timestamp |
| signature | text | NULLABLE | Pickup signature |
| rejection_reason | text | NULLABLE | Reason if rejected |
| created_at | timestamptz | NOT NULL, default: now() | Record creation |

**Indexes**: `idx_sticker_requests_household` ON (household_id), `idx_sticker_requests_status` ON (status)

**RLS Policy**: Household heads can create/read their requests; admins can CRUD all tenant requests

---

### 5. construction_permits
**Purpose**: Construction permit applications and approvals

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique permit identifier |
| tenant_id | uuid | FK, NOT NULL | Reference to tenant |
| household_id | uuid | FK, NOT NULL | Reference to household |
| permit_reference | text | NOT NULL, UNIQUE | Permit reference number |
| project_description | text | NOT NULL | Construction project description |
| contractor_name | text | NOT NULL | Contractor company name |
| contractor_contact | text | NOT NULL | Contractor contact |
| authorized_workers | jsonb | NOT NULL, default: '[]' | Array of worker details |
| start_date | date | NOT NULL | Project start date |
| end_date | date | NOT NULL | Project end date |
| road_fee | decimal(10,2) | NOT NULL, default: 0 | Computed road usage fee |
| status | text | NOT NULL, default: 'pending' | Status: pending, approved, in_progress, completed, rejected |
| payment_status | text | NOT NULL, default: 'unpaid' | Payment status |
| approved_at | timestamptz | NULLABLE | Approval timestamp |
| approved_by | uuid | FK, NULLABLE | Admin who approved |
| completed_at | timestamptz | NULLABLE | Completion timestamp |
| created_at | timestamptz | NOT NULL, default: now() | Record creation |
| updated_at | timestamptz | NOT NULL, default: now() | Record update |

**Indexes**: `idx_construction_permits_tenant` ON (tenant_id), `idx_construction_permits_household` ON (household_id), `idx_construction_permits_status` ON (status)

**RLS Policy**: Household heads can create/read their permits; admins can CRUD all tenant permits

---

### 6. permit_payments
**Purpose**: Payment tracking for construction permits

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique payment identifier |
| permit_id | uuid | FK, NOT NULL | Reference to construction_permits |
| payment_log_id | uuid | FK, NOT NULL | Reference to payment_logs |
| amount | decimal(10,2) | NOT NULL | Payment amount |
| created_at | timestamptz | NOT NULL, default: now() | Record creation |

**Indexes**: `idx_permit_payments_permit` ON (permit_id)

**RLS Policy**: Admins can CRUD for their tenant

---

### 7. announcements
**Purpose**: Community announcements to residents and staff

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique announcement identifier |
| tenant_id | uuid | FK, NOT NULL | Reference to tenant |
| title | text | NOT NULL | Announcement title |
| content | text | NOT NULL | Announcement content |
| priority | text | NOT NULL, default: 'normal' | Priority: normal, high, urgent |
| target_audience | text[] | NOT NULL | Audience: residents, guards, security, admin |
| attachment_urls | text[] | NULLABLE | File URLs from Supabase Storage |
| created_by | uuid | FK, NOT NULL | Admin who created |
| published_at | timestamptz | NULLABLE | Publication timestamp |
| expires_at | timestamptz | NULLABLE | Expiration timestamp |
| active | boolean | NOT NULL, default: true | Announcement active |
| created_at | timestamptz | NOT NULL, default: now() | Record creation |

**Indexes**: `idx_announcements_tenant` ON (tenant_id), `idx_announcements_active` ON (active) WHERE active = true

**RLS Policy**: Admins can CRUD for their tenant; targeted audiences can read

---

### 8. payment_logs (event-sourced)
**Purpose**: Comprehensive payment tracking for all payment types

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique payment log identifier |
| tenant_id | uuid | FK, NOT NULL | Reference to tenant |
| receipt_number | text | UNIQUE, NOT NULL | Generated receipt number |
| household_id | uuid | FK, NOT NULL | Reference to household |
| invoice_id | uuid | FK, NULLABLE | Reference to invoices (if applicable) |
| amount | decimal(10,2) | NOT NULL | Payment amount |
| payment_method | text | NOT NULL | Method: cash, check, bank_transfer |
| payment_date | date | NOT NULL | Payment date |
| check_number | text | NULLABLE | Check number (if check) |
| check_bank | text | NULLABLE | Bank name (if check) |
| check_date | date | NULLABLE | Check date (if check) |
| status | text | NOT NULL, default: 'completed' | Status: pending, completed, voided |
| recorded_by | uuid | FK, NOT NULL | Admin who recorded |
| notes | text | NULLABLE | Additional notes |
| created_at | timestamptz | NOT NULL, default: now() | Record creation |
| updated_at | timestamptz | NOT NULL, default: now() | Record update |

**Indexes**: `idx_payment_logs_tenant` ON (tenant_id), `idx_payment_logs_household` ON (household_id), `idx_payment_logs_date` ON (payment_date), `idx_payment_logs_receipt` ON (receipt_number)

**RLS Policy**: Admins can CRUD for their tenant; households can read their own payments

---

### 9. invoices
**Purpose**: Association fee invoices and other charges

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique invoice identifier |
| tenant_id | uuid | FK, NOT NULL | Reference to tenant |
| household_id | uuid | FK, NOT NULL | Reference to household |
| invoice_number | text | UNIQUE, NOT NULL | Invoice number |
| invoice_type | text | NOT NULL | Type: association_fee, construction_permit, sticker, other |
| description | text | NOT NULL | Invoice description |
| total_amount | decimal(10,2) | NOT NULL | Total amount due |
| amount_paid | decimal(10,2) | NOT NULL, default: 0 | Amount paid |
| amount_due | decimal(10,2) | GENERATED ALWAYS AS (total_amount - amount_paid) STORED | Remaining balance |
| status | text | NOT NULL, default: 'unpaid' | Status: unpaid, partial, paid, overdue |
| due_date | date | NOT NULL | Payment due date |
| created_at | timestamptz | NOT NULL, default: now() | Record creation |
| updated_at | timestamptz | NOT NULL, default: now() | Record update |

**Indexes**: `idx_invoices_tenant` ON (tenant_id), `idx_invoices_household` ON (household_id), `idx_invoices_status` ON (status)

**RLS Policy**: Admins can CRUD for their tenant; households can read their own invoices

---

### 10. elections
**Purpose**: Homeowner association elections

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique election identifier |
| tenant_id | uuid | FK, NOT NULL | Reference to tenant |
| election_name | text | NOT NULL | Election name |
| description | text | NOT NULL | Election description |
| positions | text[] | NOT NULL | Positions being elected |
| registration_start | timestamptz | NOT NULL | Candidate registration start |
| registration_end | timestamptz | NOT NULL | Candidate registration end |
| voting_start | timestamptz | NOT NULL | Voting period start |
| voting_end | timestamptz | NOT NULL | Voting period end |
| status | text | NOT NULL, default: 'upcoming' | Status: upcoming, registration, voting, completed, cancelled |
| created_by | uuid | FK, NOT NULL | Admin who created |
| created_at | timestamptz | NOT NULL, default: now() | Record creation |
| updated_at | timestamptz | NOT NULL, default: now() | Record update |

**Indexes**: `idx_elections_tenant` ON (tenant_id), `idx_elections_status` ON (status)

**RLS Policy**: Admins can CRUD for their tenant; residents can read active elections

---

### 11. election_candidates
**Purpose**: Candidates registered for elections

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique candidate identifier |
| election_id | uuid | FK, NOT NULL | Reference to elections |
| household_id | uuid | FK, NOT NULL | Reference to household |
| candidate_name | text | NOT NULL | Candidate name |
| position | text | NOT NULL | Position running for |
| platform | text | NULLABLE | Candidate platform |
| photo_url | text | NULLABLE | Candidate photo |
| status | text | NOT NULL, default: 'registered' | Status: registered, approved, withdrawn |
| vote_count | int | NOT NULL, default: 0 | Vote count |
| created_at | timestamptz | NOT NULL, default: now() | Record creation |

**Indexes**: `idx_election_candidates_election` ON (election_id)

**RLS Policy**: Admins can CRUD for their tenant; residents can read approved candidates

---

## Relationships

```
tenants (1) ─┬─ (N) households
              ├─ (N) sticker_programs
              ├─ (N) construction_permits
              ├─ (N) announcements
              ├─ (N) payment_logs
              ├─ (N) invoices
              └─ (N) elections

households (1) ─┬─ (N) household_members
                ├─ (N) sticker_requests
                ├─ (N) construction_permits
                ├─ (N) payment_logs
                ├─ (N) invoices
                └─ (N) election_candidates

construction_permits (1) ─── (N) permit_payments

elections (1) ─── (N) election_candidates

payment_logs (1) ─── (N) payment_allocations (if needed for split payments)
```

---

## State Transitions

### Household Status
```
active → suspended (manual, by admin)
active → moved_out (manual, when household leaves)
```

### Sticker Request Status
```
pending → approved (by admin)
approved → distributed (when physically distributed)
pending → rejected (by admin with reason)
```

### Construction Permit Status
```
pending → approved (by admin after payment)
approved → in_progress (when construction starts)
in_progress → completed (when admin marks complete)
pending → rejected (by admin with reason)
```

### Payment Status (payment_logs)
```
pending → completed (when payment processed)
completed → voided (admin correction, with notes)
```

### Invoice Status
```
unpaid → partial (when partial payment received)
partial → paid (when fully paid)
unpaid → overdue (auto, when past due_date)
```

### Election Status
```
upcoming → registration (when registration_start reached)
registration → voting (when registration_end reached)
voting → completed (when voting_end reached)
any → cancelled (manual, by admin)
```

---

## Database Functions & Triggers

### Auto-update invoice status
```sql
CREATE OR REPLACE FUNCTION update_invoice_status()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE invoices
  SET
    status = CASE
      WHEN amount_paid >= total_amount THEN 'paid'
      WHEN amount_paid > 0 THEN 'partial'
      WHEN due_date < CURRENT_DATE THEN 'overdue'
      ELSE 'unpaid'
    END,
    updated_at = NOW()
  WHERE id = NEW.invoice_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### Generate receipt number
```sql
CREATE OR REPLACE FUNCTION generate_receipt_number(p_tenant_id UUID)
RETURNS TEXT AS $$
DECLARE
  v_count INT;
  v_year TEXT;
BEGIN
  v_year := TO_CHAR(CURRENT_DATE, 'YYYY');

  SELECT COUNT(*) INTO v_count
  FROM payment_logs
  WHERE tenant_id = p_tenant_id
  AND EXTRACT(YEAR FROM created_at) = EXTRACT(YEAR FROM CURRENT_DATE);

  RETURN 'RCP-' || v_year || '-' || LPAD((v_count + 1)::TEXT, 6, '0');
END;
$$ LANGUAGE plpgsql;
```

---

## RLS Policies Summary

### Admin Access Pattern
```sql
-- Admins can access all tenant data
CREATE POLICY "Admins access tenant data"
ON {table_name} FOR ALL
TO authenticated
USING (
  tenant_id = (SELECT tenant_id FROM user_tenants WHERE user_id = auth.uid())
  AND EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_id = auth.uid()
    AND role IN ('admin_head', 'admin_officer')
  )
);
```

### Household Head Access Pattern
```sql
-- Household heads can read their own household data
CREATE POLICY "Household heads access own data"
ON {table_name} FOR SELECT
TO authenticated
USING (
  household_id IN (
    SELECT id FROM households WHERE household_head_id = auth.uid()
  )
);
```

---

**Data Model Version**: 1.0.0
**Next Steps**: Generate API contracts
