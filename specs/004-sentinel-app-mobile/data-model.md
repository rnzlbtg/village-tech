# Data Model: Sentinel App Mobile

**Feature**: Sentinel App - Gate Guard Access Control
**Date**: 2025-10-10
**Database**: Supabase PostgreSQL with Row-Level Security (RLS)

---

## Overview

This data model supports gate guard operations for resident, guest, delivery, and construction worker entry management. All tables include tenant isolation via RLS policies to ensure multi-tenant security. The model supports offline-first operations with sync queue tracking.

---

## Entity Relationship Diagram

```
┌─────────────────┐
│  guards         │
│  (Supabase Auth)│
└────────┬────────┘
         │
         │ (assigns entries)
         │
┌────────▼────────────────────┐
│  entry_logs                 │
│  - id                       │
│  - tenant_id (FK)           │
│  - guard_id (FK)            │
│  - entry_type               │
│  - timestamp                │
│  - vehicle_info             │
│  - person_info              │
│  - verification_method      │
│  - status                   │
└─────────────────────────────┘
         │
         ├──────────────┬─────────────┬──────────────┐
         │              │             │              │
┌────────▼────────┐ ┌───▼─────────┐ ┌▼──────────┐ ┌─▼────────────┐
│ rfid_stickers   │ │ guest_logs  │ │ delivery_│ │ construction_│
│ - id            │ │ - id        │ │ logs     │ │ worker_logs  │
│ - tenant_id     │ │ - entry_id  │ │ - id     │ │ - id         │
│ - sticker_code  │ │ - guest_name│ │ - entry  │ │ - entry_id   │
│ - household_id  │ │ - household │ │ - company│ │ - worker_name│
│ - vehicle_plate │ │ - purpose   │ │ - recip. │ │ - permit_id  │
│ - status        │ │ - verified  │ │ - timer  │ │ - time_onsite│
│ - expiry_date   │ └─────────────┘ └──────────┘ └──────────────┘
└─────────────────┘
         │
┌────────▼────────┐
│  households     │
│  (existing)     │
│  - id           │
│  - tenant_id    │
│  - address      │
│  - contact      │
└─────────────────┘

┌──────────────────┐
│ pre_registered_  │
│ guests           │
│ - id             │
│ - household_id   │
│ - guest_name     │
│ - visit_date     │
│ - expected_time  │
│ - purpose        │
│ - status         │
└──────────────────┘

┌──────────────────┐
│ construction_    │
│ permits          │
│ - id             │
│ - tenant_id      │
│ - household_id   │
│ - permit_ref     │
│ - project_desc   │
│ - start_date     │
│ - end_date       │
│ - authorized_    │
│   workers[]      │
│ - status         │
└──────────────────┘

┌──────────────────┐
│ incident_reports │
│ - id             │
│ - tenant_id      │
│ - guard_id       │
│ - incident_type  │
│ - description    │
│ - location       │
│ - timestamp      │
│ - resolution     │
│ - status         │
└──────────────────┘

┌──────────────────┐
│ village_rules    │
│ - id             │
│ - tenant_id      │
│ - rule_category  │
│ - rule_text      │
│ - effective_date │
│ - active         │
└──────────────────┘

┌──────────────────┐
│ announcements    │
│ - id             │
│ - tenant_id      │
│ - title          │
│ - message        │
│ - priority       │
│ - created_at     │
│ - expires_at     │
└──────────────────┘

┌──────────────────┐
│ sync_queue       │
│ (local only)     │
│ - id             │
│ - operation      │
│ - entity_type    │
│ - entity_id      │
│ - payload        │
│ - timestamp      │
│ - retry_count    │
│ - status         │
└──────────────────┘
```

---

## Core Entities

### 1. entry_logs
**Purpose**: Comprehensive log of all gate activity (residents, guests, deliveries, workers)

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique entry log identifier |
| tenant_id | uuid | FK, NOT NULL | Reference to tenant (community) |
| guard_id | uuid | FK, NOT NULL | Reference to guard who processed entry |
| entry_type | text | NOT NULL | Type: 'resident', 'guest', 'delivery', 'construction' |
| timestamp | timestamptz | NOT NULL, default: now() | Entry timestamp |
| vehicle_info | jsonb | NULLABLE | Vehicle details: {plate, make, model, color} |
| person_info | jsonb | NULLABLE | Person details: {name, contact, id_number} |
| verification_method | text | NOT NULL | Method: 'rfid', 'manual', 'pre_registered', 'permit' |
| verification_status | text | NOT NULL | Status: 'granted', 'denied', 'pending' |
| denial_reason | text | NULLABLE | Reason if entry denied |
| notes | text | NULLABLE | Additional notes from guard |
| synced | boolean | NOT NULL, default: false | Sync status for offline logs |
| created_at | timestamptz | NOT NULL, default: now() | Record creation timestamp |
| updated_at | timestamptz | NOT NULL, default: now() | Record update timestamp |

**Indexes**:
- `idx_entry_logs_tenant_timestamp` ON (tenant_id, timestamp DESC)
- `idx_entry_logs_guard_id` ON (guard_id)
- `idx_entry_logs_entry_type` ON (entry_type)
- `idx_entry_logs_synced` ON (synced) WHERE synced = false

**RLS Policy**: Guards can only view/insert entries for their assigned tenant

**Validation Rules**:
- `entry_type` must be one of: 'resident', 'guest', 'delivery', 'construction'
- `verification_method` must be one of: 'rfid', 'manual', 'pre_registered', 'permit'
- `verification_status` must be one of: 'granted', 'denied', 'pending'
- Trigger: update `updated_at` on row update

---

### 2. rfid_stickers
**Purpose**: Vehicle RFID sticker registry for resident verification

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique sticker identifier |
| tenant_id | uuid | FK, NOT NULL | Reference to tenant |
| sticker_code | text | NOT NULL, UNIQUE | RFID sticker unique code |
| household_id | uuid | FK, NOT NULL | Reference to household |
| vehicle_plate | text | NOT NULL | Registered vehicle plate number |
| vehicle_make | text | NULLABLE | Vehicle make/model |
| status | text | NOT NULL, default: 'active' | Status: 'active', 'expired', 'revoked', 'lost' |
| issued_date | date | NOT NULL | Date sticker was issued |
| expiry_date | date | NOT NULL | Sticker expiration date |
| created_at | timestamptz | NOT NULL, default: now() | Record creation timestamp |
| updated_at | timestamptz | NOT NULL, default: now() | Record update timestamp |

**Indexes**:
- `idx_rfid_stickers_code` ON (sticker_code) UNIQUE
- `idx_rfid_stickers_tenant_household` ON (tenant_id, household_id)
- `idx_rfid_stickers_status` ON (status) WHERE status = 'active'

**RLS Policy**: Guards can read stickers for their tenant; only admins can write

**Validation Rules**:
- `status` must be one of: 'active', 'expired', 'revoked', 'lost'
- `expiry_date` must be >= `issued_date`
- Check constraint: `expiry_date` >= `issued_date`
- Trigger: auto-update status to 'expired' when `expiry_date` < current_date

---

### 3. pre_registered_guests
**Purpose**: Pre-registered guest list from household heads

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique guest registration identifier |
| household_id | uuid | FK, NOT NULL | Reference to household |
| guest_name | text | NOT NULL | Name of expected guest |
| guest_contact | text | NULLABLE | Guest phone number |
| visit_date | date | NOT NULL | Expected visit date |
| expected_time | time | NULLABLE | Expected arrival time |
| duration_hours | int | NULLABLE | Expected visit duration |
| purpose | text | NOT NULL | Visit purpose |
| vehicle_plate | text | NULLABLE | Guest vehicle plate |
| status | text | NOT NULL, default: 'pending' | Status: 'pending', 'arrived', 'cancelled', 'expired' |
| checked_in_at | timestamptz | NULLABLE | Actual check-in timestamp |
| entry_log_id | uuid | FK, NULLABLE | Reference to entry_log when checked in |
| created_by | uuid | FK, NOT NULL | Household head who registered |
| created_at | timestamptz | NOT NULL, default: now() | Registration timestamp |
| updated_at | timestamptz | NOT NULL, default: now() | Record update timestamp |

**Indexes**:
- `idx_pre_registered_guests_visit_date` ON (visit_date, status)
- `idx_pre_registered_guests_household` ON (household_id)
- `idx_pre_registered_guests_status` ON (status) WHERE status = 'pending'

**RLS Policy**: Guards can read pending guests for current date; households can CRUD their own registrations

**Validation Rules**:
- `status` must be one of: 'pending', 'arrived', 'cancelled', 'expired'
- Trigger: auto-update status to 'expired' for pending guests where `visit_date` < current_date

---

### 4. guest_logs
**Purpose**: Detailed guest entry records (linked to entry_logs)

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique guest log identifier |
| entry_log_id | uuid | FK, NOT NULL | Reference to entry_logs |
| guest_name | text | NOT NULL | Guest name |
| household_id | uuid | FK, NOT NULL | Destination household |
| purpose | text | NOT NULL | Visit purpose |
| verification_method | text | NOT NULL | Method: 'pre_registered', 'household_call', 'manual' |
| household_contacted | boolean | NOT NULL, default: false | Whether household was called |
| household_response | text | NULLABLE | Response from household head |
| exit_timestamp | timestamptz | NULLABLE | Guest exit time |
| visit_duration_minutes | int | NULLABLE | Calculated visit duration |
| created_at | timestamptz | NOT NULL, default: now() | Record creation timestamp |

**Indexes**:
- `idx_guest_logs_entry_log` ON (entry_log_id)
- `idx_guest_logs_household` ON (household_id)

**RLS Policy**: Guards can read/write for their tenant

**Validation Rules**:
- `verification_method` must be one of: 'pre_registered', 'household_call', 'manual'
- Trigger: calculate `visit_duration_minutes` when `exit_timestamp` is set

---

### 5. delivery_logs
**Purpose**: Delivery tracking with timer and recipient verification

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique delivery log identifier |
| entry_log_id | uuid | FK, NOT NULL | Reference to entry_logs |
| delivery_company | text | NOT NULL | Delivery company name |
| recipient_household_id | uuid | FK, NOT NULL | Destination household |
| package_type | text | NOT NULL | Package type: 'standard', 'perishable', 'large' |
| package_description | text | NULLABLE | Package description |
| recipient_contacted | boolean | NOT NULL, default: false | Whether recipient was contacted |
| recipient_available | boolean | NULLABLE | Recipient availability status |
| special_instructions | text | NULLABLE | Instructions for perishable/special packages |
| entry_timestamp | timestamptz | NOT NULL | Delivery entry time |
| exit_timestamp | timestamptz | NULLABLE | Delivery exit time |
| delivery_duration_minutes | int | NULLABLE | Calculated delivery duration |
| duration_alert_sent | boolean | NOT NULL, default: false | Alert sent if duration exceeded |
| created_at | timestamptz | NOT NULL, default: now() | Record creation timestamp |

**Indexes**:
- `idx_delivery_logs_entry_log` ON (entry_log_id)
- `idx_delivery_logs_household` ON (recipient_household_id)
- `idx_delivery_logs_exit` ON (exit_timestamp) WHERE exit_timestamp IS NULL

**RLS Policy**: Guards can read/write for their tenant

**Validation Rules**:
- `package_type` must be one of: 'standard', 'perishable', 'large'
- Trigger: calculate `delivery_duration_minutes` when `exit_timestamp` is set
- Trigger: set `duration_alert_sent` = true if duration exceeds expected threshold

---

### 6. construction_permits
**Purpose**: Construction permit registry with authorized worker lists

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique permit identifier |
| tenant_id | uuid | FK, NOT NULL | Reference to tenant |
| household_id | uuid | FK, NOT NULL | Household requesting construction |
| permit_reference | text | NOT NULL, UNIQUE | Permit reference number |
| project_description | text | NOT NULL | Construction project description |
| contractor_name | text | NOT NULL | Contractor company name |
| contractor_contact | text | NOT NULL | Contractor contact number |
| authorized_workers | jsonb | NOT NULL, default: '[]' | Array of authorized workers: [{name, id_number, role}] |
| start_date | date | NOT NULL | Permit start date |
| end_date | date | NOT NULL | Permit end date |
| status | text | NOT NULL, default: 'active' | Status: 'pending', 'active', 'expired', 'completed', 'revoked' |
| approved_by | uuid | FK, NULLABLE | Admin who approved permit |
| created_at | timestamptz | NOT NULL, default: now() | Permit creation timestamp |
| updated_at | timestamptz | NOT NULL, default: now() | Record update timestamp |

**Indexes**:
- `idx_construction_permits_ref` ON (permit_reference) UNIQUE
- `idx_construction_permits_tenant_status` ON (tenant_id, status)
- `idx_construction_permits_dates` ON (start_date, end_date)

**RLS Policy**: Guards can read active permits for their tenant; admins can CRUD

**Validation Rules**:
- `status` must be one of: 'pending', 'active', 'expired', 'completed', 'revoked'
- `end_date` must be >= `start_date`
- Check constraint: `end_date` >= `start_date`
- Trigger: auto-update status to 'expired' when `end_date` < current_date AND status = 'active'

---

### 7. construction_worker_logs
**Purpose**: Construction worker entry/exit tracking

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique worker log identifier |
| entry_log_id | uuid | FK, NOT NULL | Reference to entry_logs |
| permit_id | uuid | FK, NOT NULL | Reference to construction_permits |
| worker_name | text | NOT NULL | Worker name |
| worker_id_number | text | NOT NULL | Worker ID/license number |
| entry_timestamp | timestamptz | NOT NULL | Worker entry time |
| exit_timestamp | timestamptz | NULLABLE | Worker exit time |
| time_onsite_minutes | int | NULLABLE | Calculated time on-site |
| currently_onsite | boolean | NOT NULL, default: true | Whether worker is currently on-site |
| created_at | timestamptz | NOT NULL, default: now() | Record creation timestamp |

**Indexes**:
- `idx_construction_worker_logs_permit` ON (permit_id)
- `idx_construction_worker_logs_onsite` ON (currently_onsite) WHERE currently_onsite = true

**RLS Policy**: Guards can read/write for their tenant

**Validation Rules**:
- Trigger: calculate `time_onsite_minutes` when `exit_timestamp` is set
- Trigger: set `currently_onsite` = false when `exit_timestamp` is set

---

### 8. incident_reports
**Purpose**: Security incident and rule violation reporting

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique incident identifier |
| tenant_id | uuid | FK, NOT NULL | Reference to tenant |
| guard_id | uuid | FK, NOT NULL | Guard who reported incident |
| incident_type | text | NOT NULL | Type: 'security', 'rule_violation', 'suspicious_activity', 'other' |
| severity | text | NOT NULL | Severity: 'low', 'medium', 'high', 'critical' |
| location | text | NOT NULL | Incident location |
| description | text | NOT NULL | Detailed incident description |
| involved_parties | jsonb | NULLABLE | Array of involved persons/vehicles |
| photos | jsonb | NULLABLE | Array of photo URLs from Supabase Storage |
| timestamp | timestamptz | NOT NULL, default: now() | Incident timestamp |
| dispatch_notified | boolean | NOT NULL, default: false | Whether guard house was notified |
| dispatch_response | text | NULLABLE | Response from dispatch |
| resolution | text | NULLABLE | Incident resolution details |
| status | text | NOT NULL, default: 'open' | Status: 'open', 'in_progress', 'resolved', 'closed' |
| resolved_at | timestamptz | NULLABLE | Resolution timestamp |
| created_at | timestamptz | NOT NULL, default: now() | Record creation timestamp |
| updated_at | timestamptz | NOT NULL, default: now() | Record update timestamp |

**Indexes**:
- `idx_incident_reports_tenant_timestamp` ON (tenant_id, timestamp DESC)
- `idx_incident_reports_guard` ON (guard_id)
- `idx_incident_reports_status` ON (status) WHERE status IN ('open', 'in_progress')

**RLS Policy**: Guards can CRUD incidents for their tenant; dispatch can update

**Validation Rules**:
- `incident_type` must be one of: 'security', 'rule_violation', 'suspicious_activity', 'other'
- `severity` must be one of: 'low', 'medium', 'high', 'critical'
- `status` must be one of: 'open', 'in_progress', 'resolved', 'closed'
- Trigger: set `resolved_at` when status changes to 'resolved' or 'closed'

---

### 9. village_rules
**Purpose**: Community rules and guidelines for guard reference

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique rule identifier |
| tenant_id | uuid | FK, NOT NULL | Reference to tenant |
| rule_category | text | NOT NULL | Category: 'curfew', 'parking', 'noise', 'security', 'general' |
| rule_title | text | NOT NULL | Rule title |
| rule_description | text | NOT NULL | Detailed rule description |
| enforcement_instructions | text | NULLABLE | Instructions for guards on enforcement |
| effective_date | date | NOT NULL | Date rule becomes effective |
| active | boolean | NOT NULL, default: true | Whether rule is currently active |
| created_by | uuid | FK, NOT NULL | Admin who created rule |
| created_at | timestamptz | NOT NULL, default: now() | Rule creation timestamp |
| updated_at | timestamptz | NOT NULL, default: now() | Record update timestamp |

**Indexes**:
- `idx_village_rules_tenant_active` ON (tenant_id, active) WHERE active = true
- `idx_village_rules_category` ON (rule_category)

**RLS Policy**: Guards can read active rules for their tenant; admins can CRUD

**Validation Rules**:
- `rule_category` must be one of: 'curfew', 'parking', 'noise', 'security', 'general'

---

### 10. announcements
**Purpose**: Admin announcements for guards

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique announcement identifier |
| tenant_id | uuid | FK, NOT NULL | Reference to tenant |
| title | text | NOT NULL | Announcement title |
| message | text | NOT NULL | Announcement message content |
| priority | text | NOT NULL, default: 'normal' | Priority: 'normal', 'high', 'urgent' |
| target_audience | text | NOT NULL, default: 'all_guards' | Target: 'all_guards', 'specific_gate', 'specific_guard' |
| created_by | uuid | FK, NOT NULL | Admin who created announcement |
| created_at | timestamptz | NOT NULL, default: now() | Announcement creation timestamp |
| expires_at | timestamptz | NULLABLE | Announcement expiration timestamp |
| active | boolean | NOT NULL, default: true | Whether announcement is active |

**Indexes**:
- `idx_announcements_tenant_active` ON (tenant_id, active) WHERE active = true
- `idx_announcements_priority` ON (priority) WHERE priority = 'urgent'

**RLS Policy**: Guards can read active announcements for their tenant; admins can CRUD

**Validation Rules**:
- `priority` must be one of: 'normal', 'high', 'urgent'
- `target_audience` must be one of: 'all_guards', 'specific_gate', 'specific_guard'
- Trigger: set `active` = false when `expires_at` < current_timestamp

---

## Local-Only Entities (Mobile App)

### 11. sync_queue
**Purpose**: Offline sync queue for pending operations

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | text | PK | Unique sync queue item identifier (UUID) |
| operation | text | NOT NULL | Operation: 'CREATE', 'UPDATE', 'DELETE' |
| entity_type | text | NOT NULL | Entity type being synced |
| entity_id | text | NOT NULL | ID of entity being synced |
| payload | text | NOT NULL | JSON payload of operation |
| timestamp | integer | NOT NULL | Unix timestamp of operation |
| retry_count | integer | NOT NULL, default: 0 | Number of retry attempts |
| status | text | NOT NULL, default: 'pending' | Status: 'pending', 'processing', 'failed', 'completed' |
| error_message | text | NULLABLE | Error message if failed |

**Storage**: Hive/Drift local database (not synced to Supabase)

**Validation Rules**:
- `operation` must be one of: 'CREATE', 'UPDATE', 'DELETE'
- `status` must be one of: 'pending', 'processing', 'failed', 'completed'
- Max `retry_count` = 5, then move to dead letter queue

---

## State Transitions

### RFID Sticker Status
```
active → expired (auto, when expiry_date < current_date)
active → revoked (manual, by admin)
active → lost (manual, by admin/household)
```

### Pre-Registered Guest Status
```
pending → arrived (when checked in by guard)
pending → cancelled (manual, by household)
pending → expired (auto, when visit_date < current_date)
```

### Delivery Status
```
entry_logs.status: granted → delivery entry logged
delivery_logs.exit_timestamp: NULL → timer running
delivery_logs.exit_timestamp: SET → completed
```

### Construction Permit Status
```
pending → active (when approved by admin)
active → expired (auto, when end_date < current_date)
active → completed (manual, when project done)
active → revoked (manual, by admin)
```

### Incident Report Status
```
open → in_progress (when dispatch responds)
in_progress → resolved (when action taken)
resolved → closed (when verified complete)
```

---

## Row-Level Security (RLS) Policies

### Guards (via Supabase Auth)
- Can SELECT from all tables WHERE tenant_id = auth.jwt()->>'tenant_id'
- Can INSERT into entry_logs, guest_logs, delivery_logs, construction_worker_logs, incident_reports
- Cannot UPDATE/DELETE historical logs (audit trail)

### Households (via Supabase Auth)
- Can CRUD pre_registered_guests WHERE household_id = auth.jwt()->>'household_id'
- Can SELECT rfid_stickers WHERE household_id = auth.jwt()->>'household_id'

### Admins
- Full CRUD on all tables for their tenant

---

## Database Functions

### 1. validate_rfid_sticker(sticker_code text)
**Purpose**: Real-time RFID validation
**Returns**: JSON with {valid: boolean, household_id: uuid, vehicle_info: object, status: text}

### 2. auto_expire_entities()
**Purpose**: Background job to auto-update expired statuses
**Triggers**: Daily cron job via Supabase Scheduler

### 3. calculate_duration(entry_ts timestamptz, exit_ts timestamptz)
**Purpose**: Calculate time duration in minutes
**Returns**: integer (minutes)

### 4. trigger_delivery_alert()
**Purpose**: Alert guard when delivery exceeds expected duration
**Triggers**: On delivery_logs UPDATE

---

## Migration Strategy

### Phase 1: Core Tables
1. entry_logs
2. rfid_stickers
3. households (extend existing)

### Phase 2: Guest & Delivery
4. pre_registered_guests
5. guest_logs
6. delivery_logs

### Phase 3: Construction & Incidents
7. construction_permits
8. construction_worker_logs
9. incident_reports

### Phase 4: Rules & Announcements
10. village_rules
11. announcements

---

## Offline Sync Considerations

### Offline-Writable Tables
- entry_logs (with synced = false)
- guest_logs
- delivery_logs
- construction_worker_logs
- incident_reports

### Offline-Readable Tables (Cached)
- rfid_stickers (cached for quick lookup)
- pre_registered_guests (for current date)
- construction_permits (active only)
- village_rules (active only)
- announcements (active only)

### Sync Conflict Resolution
- **Last-Write-Wins (LWW)**: Use timestamp for most entities
- **Server Authority**: RFID validation always re-validates on sync
- **Merge Strategy**: Incident reports merge guard notes and dispatch responses

---

**Data Model Version**: 1.0.0
**Next Steps**: Generate API contracts in contracts/ directory
