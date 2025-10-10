# Data Model Recommendations
## Village Tech v4 - Database Schema & Entity Relationships

**Database:** PostgreSQL (via Supabase)
**ORM:** Prisma (recommended) or Supabase client
**Multi-tenancy Strategy:** Shared database with tenant_id/association_id scoping

---

## Entity Relationship Diagram (ERD)

```
┌─────────────────┐
│ PlatformTenant  │
│ (Super Admin)   │
└────────┬────────┘
         │ 1:N
         ▼
┌─────────────────┐
│  Association    │◄─────────┐
│  (Community)    │          │
└────┬───┬────┬───┘          │
     │   │    │              │
     │   │    │ 1:N          │
     │   │    └──────┐       │
     │   │           ▼       │
     │   │      ┌─────────┐  │
     │   │      │  Gate   │  │
     │   │      │(Entrance)│  │
     │   │      └─────────┘  │
     │   │                   │
     │   │ 1:N               │ N:1
     │   └──────┐            │
     │          ▼            │
     │   ┌──────────────┐    │
     │   │  Residence   │    │
     │   │  (Property)  │    │
     │   └──────┬───────┘    │
     │          │ M:N        │
     │          │ (junction) │
     │          ▼            │
     │   ┌──────────────┐    │
     ├──►│  Household   │◄───┤
     │   └───┬──────────┘    │
     │       │                │
     │       │ 1:N            │
     │       ▼                │
     │   ┌─────────┐          │
     └──►│  User   │──────────┘
         │(Members)│
         └────┬────┘
              │ 1:N
              ▼
         ┌─────────┐
         │ Vehicle │
         └────┬────┘
              │ 1:1
              ▼
         ┌─────────┐
         │ Sticker │
         └─────────┘

Additional Entities (connected to core):
- Guest (N:1 Household)
- ConstructionPermit (N:1 Household, N:1 Residence)
- ConstructionWorker (N:1 ConstructionPermit)
- Delivery (N:1 Residence)
- EntryLog (N:1 Gate)
- Incident (N:1 Association)
- SecurityTeam (1:1 Association)
- Payment (N:1 Association, N:1 User)
- Announcement (N:1 Association)
- Election (N:1 Association)
```

---

## Core Entities

### 1. PlatformTenant

**Purpose:** Super-entity for multi-tenant SaaS platform

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK | Unique tenant identifier |
| `name` | VARCHAR(255) | NOT NULL | Tenant name |
| `slug` | VARCHAR(100) | UNIQUE, NOT NULL | URL-friendly identifier |
| `status` | ENUM | NOT NULL | active, inactive, suspended |
| `subscription_tier` | ENUM | | free, basic, premium, enterprise |
| `config` | JSONB | | Platform-level configuration |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Relationships:**
- 1:N → Association (one tenant can have multiple communities)

**Indexes:**
- `idx_tenant_slug` on `slug`
- `idx_tenant_status` on `status`

**Notes:**
- This is the top-level entity for multi-tenant isolation
- All downstream entities will reference association_id which links back to tenant_id

---

### 2. Association (Community/Village)

**Purpose:** Represents a residential community

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK | Unique association identifier |
| `tenant_id` | UUID | FK → PlatformTenant, NOT NULL | Parent tenant |
| `name` | VARCHAR(255) | NOT NULL | Community name |
| `address` | TEXT | | Physical address |
| `city` | VARCHAR(100) | | City |
| `state` | VARCHAR(100) | | State/Province |
| `postal_code` | VARCHAR(20) | | Postal code |
| `country` | VARCHAR(100) | | Country |
| `status` | ENUM | NOT NULL | active, inactive |
| `rules` | JSONB | | Village rules, curfew, sticker limits, fees |
| `logo_url` | VARCHAR(500) | | Community logo |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Relationships:**
- N:1 → PlatformTenant
- 1:N → User (Admin Head, Admin Officers)
- 1:N → Residence
- 1:N → Household
- 1:N → Gate
- 1:1 → SecurityTeam

**Indexes:**
- `idx_association_tenant` on `tenant_id`
- `idx_association_status` on `status`

**Sample `rules` JSONB:**
```json
{
  "curfew": "22:00",
  "sticker_limit_per_household": 4,
  "association_fee_monthly": 500,
  "construction_fee_base": 1000,
  "late_payment_penalty_percent": 5
}
```

---

### 3. Residence (Property)

**Purpose:** Represents a physical property/residence in the community

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK | Unique residence identifier |
| `association_id` | UUID | FK → Association, NOT NULL | Parent association |
| `address` | VARCHAR(500) | NOT NULL | Property address (e.g., "Block 1, Lot 5") |
| `type` | ENUM | NOT NULL | house, townhouse, condo, lot |
| `lot_number` | VARCHAR(50) | | Lot number |
| `block_number` | VARCHAR(50) | | Block number |
| `floor_area_sqm` | DECIMAL(10,2) | | Floor area in square meters |
| `status` | ENUM | NOT NULL | occupied, vacant, under_construction |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Relationships:**
- N:1 → Association
- M:N → Household (via HouseholdResidence junction table)
- 1:N → ConstructionPermit
- 1:N → Delivery

**Indexes:**
- `idx_residence_association` on `association_id`
- `idx_residence_status` on `status`
- `idx_residence_lot_block` on `lot_number, block_number`

**Notes:**
- This is a NEW entity to support "household head can have one or more residences"
- A residence can be linked to multiple households (e.g., co-owners, renters)

---

### 4. Household

**Purpose:** Represents a family unit or group living together

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK | Unique household identifier |
| `association_id` | UUID | FK → Association, NOT NULL | Parent association |
| `household_head_id` | UUID | FK → User, UNIQUE | Primary household head |
| `status` | ENUM | NOT NULL | active, inactive |
| `sticker_quota` | INT | DEFAULT 0 | Number of stickers allowed |
| `stickers_used` | INT | DEFAULT 0 | Number of stickers currently issued |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Relationships:**
- N:1 → Association
- M:N → Residence (via HouseholdResidence junction table)
- 1:N → User (household members)
- 1:N → Vehicle
- 1:N → Guest
- 1:N → BeneficialUser
- 1:N → ConstructionPermit

**Indexes:**
- `idx_household_association` on `association_id`
- `idx_household_head` on `household_head_id`
- `idx_household_status` on `status`

**Notes:**
- Household is separate from Residence to support multiple residences per household
- Sticker quota is set at household level, not residence level

---

### 5. HouseholdResidence (Junction Table)

**Purpose:** Many-to-many relationship between Household and Residence

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK | Unique identifier |
| `household_id` | UUID | FK → Household, NOT NULL | Household reference |
| `residence_id` | UUID | FK → Residence, NOT NULL | Residence reference |
| `relationship_type` | ENUM | NOT NULL | owner, renter, co_owner |
| `is_primary` | BOOLEAN | DEFAULT false | Is this the primary residence? |
| `move_in_date` | DATE | | Move-in date |
| `move_out_date` | DATE | | Move-out date (if no longer active) |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |

**Relationships:**
- N:1 → Household
- N:1 → Residence

**Indexes:**
- `idx_household_residence_household` on `household_id`
- `idx_household_residence_residence` on `residence_id`
- `unique_household_residence` UNIQUE on `household_id, residence_id` (prevent duplicates)

**Notes:**
- Allows household head to own/rent multiple residences
- `is_primary` flag indicates the main residence for notifications, etc.

---

### 6. User

**Purpose:** Represents all users in the system (admins, residents, guards)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK | Unique user identifier (from Supabase Auth) |
| `association_id` | UUID | FK → Association | Association (NULL for platform admins) |
| `household_id` | UUID | FK → Household | Household (NULL for non-residents) |
| `email` | VARCHAR(255) | UNIQUE | Email address |
| `phone` | VARCHAR(20) | | Phone number |
| `first_name` | VARCHAR(100) | NOT NULL | First name |
| `last_name` | VARCHAR(100) | NOT NULL | Last name |
| `user_type` | ENUM | NOT NULL | platform_admin, admin_head, admin_officer, household_head, household_member, guard_dispatcher, guard_gate, guard_roaming |
| `is_household_head` | BOOLEAN | DEFAULT false | Is this user a household head? |
| `status` | ENUM | NOT NULL | active, inactive, suspended |
| `avatar_url` | VARCHAR(500) | | Profile picture URL |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Relationships:**
- N:1 → Association (NULL for platform admins)
- N:1 → Household (NULL for non-residents)
- M:N → Role (via UserRole junction table for RBAC)
- 1:N → Vehicle (owner)
- 1:N → Payment (payer)

**Indexes:**
- `idx_user_association` on `association_id`
- `idx_user_household` on `household_id`
- `idx_user_type` on `user_type`
- `idx_user_email` on `email`

**Notes:**
- User table integrates with Supabase Auth (id matches auth.users.id)
- `user_type` determines app access (platform_admin → Platform App, household_head → Residence App, etc.)

---

### 7. Vehicle

**Purpose:** Represents vehicles owned by household members

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK | Unique vehicle identifier |
| `household_id` | UUID | FK → Household, NOT NULL | Owning household |
| `owner_id` | UUID | FK → User, NOT NULL | Vehicle owner (household member) |
| `plate_number` | VARCHAR(20) | UNIQUE, NOT NULL | License plate number |
| `vehicle_type` | ENUM | NOT NULL | car, motorcycle, suv, van, truck |
| `make` | VARCHAR(100) | | Vehicle make (e.g., Toyota) |
| `model` | VARCHAR(100) | | Vehicle model (e.g., Camry) |
| `color` | VARCHAR(50) | | Vehicle color |
| `year` | INT | | Year of manufacture |
| `sticker_id` | UUID | FK → Sticker | Associated sticker (if any) |
| `status` | ENUM | NOT NULL | active, inactive, sold |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Relationships:**
- N:1 → Household
- N:1 → User (owner)
- 1:1 → Sticker (optional)
- 1:N → VehicleViolation

**Indexes:**
- `idx_vehicle_household` on `household_id`
- `idx_vehicle_owner` on `owner_id`
- `idx_vehicle_plate` on `plate_number`
- `idx_vehicle_sticker` on `sticker_id`

---

### 8. Sticker

**Purpose:** RFID stickers for vehicle access

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK | Unique sticker identifier |
| `association_id` | UUID | FK → Association, NOT NULL | Issuing association |
| `rfid_code` | VARCHAR(100) | UNIQUE, NOT NULL | RFID/NFC code |
| `qr_code` | VARCHAR(100) | UNIQUE | QR code (fallback) |
| `issued_to_household_id` | UUID | FK → Household, NOT NULL | Issued to household |
| `issued_to_user_id` | UUID | FK → User, NOT NULL | Issued to user (resident or beneficial user) |
| `vehicle_id` | UUID | FK → Vehicle | Associated vehicle |
| `sticker_type` | ENUM | NOT NULL | resident, beneficial_user, temporary, endorsed_user |
| `status` | ENUM | NOT NULL | active, expired, revoked, lost |
| `issue_date` | DATE | NOT NULL | Date issued |
| `expiry_date` | DATE | NOT NULL | Expiration date |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Relationships:**
- N:1 → Association
- N:1 → Household
- N:1 → User (issued to)
- 1:1 → Vehicle (optional)

**Indexes:**
- `idx_sticker_rfid` on `rfid_code`
- `idx_sticker_qr` on `qr_code`
- `idx_sticker_household` on `issued_to_household_id`
- `idx_sticker_user` on `issued_to_user_id`
- `idx_sticker_status` on `status`

**Notes:**
- Sticker types align with workflow definitions:
  - `resident`: Household member
  - `beneficial_user`: Non-household member who receives vehicle sticker
  - `endorsed_user`: Household member issued a sticker
  - `temporary`: Temporary access (e.g., guests)

---

## Supporting Entities

### 9. BeneficialUser

**Purpose:** Non-household members who can receive vehicle stickers

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK | Unique identifier |
| `household_id` | UUID | FK → Household, NOT NULL | Associated household |
| `first_name` | VARCHAR(100) | NOT NULL | First name |
| `last_name` | VARCHAR(100) | NOT NULL | Last name |
| `phone` | VARCHAR(20) | | Phone number |
| `email` | VARCHAR(255) | | Email address |
| `relationship` | VARCHAR(100) | | Relationship to household (e.g., "family friend") |
| `status` | ENUM | NOT NULL | active, inactive |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Relationships:**
- N:1 → Household
- 1:N → Sticker (can receive vehicle stickers)

**Indexes:**
- `idx_beneficial_user_household` on `household_id`

---

### 10. Guest

**Purpose:** Scheduled guest visits

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK | Unique guest identifier |
| `household_id` | UUID | FK → Household, NOT NULL | Host household |
| `first_name` | VARCHAR(100) | NOT NULL | Guest first name |
| `last_name` | VARCHAR(100) | NOT NULL | Guest last name |
| `phone` | VARCHAR(20) | | Guest phone |
| `plate_number` | VARCHAR(20) | | Guest vehicle plate |
| `visit_date` | DATE | NOT NULL | Scheduled visit date |
| `visit_start_time` | TIME | | Visit start time |
| `visit_end_time` | TIME | | Visit end time (if day-trip) |
| `duration_type` | ENUM | NOT NULL | day_trip, multi_day |
| `checkout_date` | DATE | | Checkout date (for multi-day) |
| `purpose` | TEXT | | Purpose of visit |
| `status` | ENUM | NOT NULL | scheduled, checked_in, checked_out, cancelled, overstayed |
| `checked_in_at` | TIMESTAMP | | Actual check-in timestamp |
| `checked_out_at` | TIMESTAMP | | Actual check-out timestamp |
| `logged_by_guard_id` | UUID | FK → User | Guard who logged entry |
| `notes` | TEXT | | Additional notes |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Relationships:**
- N:1 → Household
- N:1 → User (guard who logged entry)

**Indexes:**
- `idx_guest_household` on `household_id`
- `idx_guest_visit_date` on `visit_date`
- `idx_guest_status` on `status`

**Notes:**
- `duration_type` addresses requirement: "day-trip or multi-day visit"
- `status = overstayed` triggers alerts for guards and household

---

### 11. ConstructionPermit

**Purpose:** Construction/maintenance permits

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK | Unique permit identifier |
| `household_id` | UUID | FK → Household, NOT NULL | Requesting household |
| `residence_id` | UUID | FK → Residence, NOT NULL | Residence for construction |
| `description` | TEXT | NOT NULL | Construction details |
| `construction_type` | ENUM | NOT NULL | renovation, new_build, repair, landscaping |
| `start_date` | DATE | NOT NULL | Planned start date |
| `end_date` | DATE | NOT NULL | Planned end date |
| `fee_amount` | DECIMAL(10,2) | NOT NULL | Computed construction fee |
| `payment_status` | ENUM | NOT NULL | pending, paid, refunded |
| `payment_id` | UUID | FK → Payment | Associated payment |
| `approval_status` | ENUM | NOT NULL | pending, approved, rejected, on_hold |
| `approved_by_admin_id` | UUID | FK → User | Admin who approved |
| `approved_at` | TIMESTAMP | | Approval timestamp |
| `completion_status` | ENUM | NOT NULL | not_started, in_progress, completed, cancelled |
| `completed_at` | TIMESTAMP | | Completion timestamp |
| `notes` | TEXT | | Admin notes |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Relationships:**
- N:1 → Household
- N:1 → Residence
- N:1 → Payment
- N:1 → User (approving admin)
- 1:N → ConstructionWorker

**Indexes:**
- `idx_construction_permit_household` on `household_id`
- `idx_construction_permit_residence` on `residence_id`
- `idx_construction_permit_approval_status` on `approval_status`
- `idx_construction_permit_completion_status` on `completion_status`

**Notes:**
- Workflow: Request → Fee Computation → Payment → Approval → In Progress → Completed
- "On hold" if payment pending (per workflow note: "If NOT paid → construction on hold order")

---

### 12. ConstructionWorker

**Purpose:** Individual construction workers with gate passes

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK | Unique worker identifier |
| `permit_id` | UUID | FK → ConstructionPermit, NOT NULL | Associated permit |
| `first_name` | VARCHAR(100) | NOT NULL | Worker first name |
| `last_name` | VARCHAR(100) | NOT NULL | Worker last name |
| `phone` | VARCHAR(20) | | Worker phone |
| `id_number` | VARCHAR(50) | | Government ID number |
| `gate_pass_code` | VARCHAR(100) | UNIQUE | QR code or pass code |
| `start_date` | DATE | NOT NULL | Worker access start date |
| `end_date` | DATE | NOT NULL | Worker access end date (linked to permit) |
| `status` | ENUM | NOT NULL | active, expired, revoked |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Relationships:**
- N:1 → ConstructionPermit
- 1:N → EntryLog (worker entries)

**Indexes:**
- `idx_construction_worker_permit` on `permit_id`
- `idx_construction_worker_pass_code` on `gate_pass_code`
- `idx_construction_worker_status` on `status`

**Notes:**
- Addresses GAP-004: Construction worker individual gate passes
- `gate_pass_code` is scanned by guards at gate (QR code or digital pass)
- Workers auto-expire when permit is completed

---

### 13. Delivery

**Purpose:** Delivery tracking and management

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK | Unique delivery identifier |
| `residence_id` | UUID | FK → Residence, NOT NULL | Destination residence |
| `household_id` | UUID | FK → Household | Recipient household (if known) |
| `delivery_service` | VARCHAR(100) | | Delivery service (e.g., "FedEx", "GrabFood") |
| `sender_name` | VARCHAR(255) | | Sender name |
| `arrival_time` | TIMESTAMP | NOT NULL | Arrival at gate |
| `entry_time` | TIMESTAMP | | Entry into community |
| `exit_time` | TIMESTAMP | | Exit from community |
| `is_perishable` | BOOLEAN | DEFAULT false | Is delivery perishable? |
| `recipient_available` | BOOLEAN | | Was recipient available? |
| `status` | ENUM | NOT NULL | at_gate, in_transit, delivered, returned, delayed |
| `logged_by_guard_id` | UUID | FK → User, NOT NULL | Guard who logged delivery |
| `notes` | TEXT | | Guard notes (e.g., instructions from household) |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Relationships:**
- N:1 → Residence
- N:1 → Household (optional)
- N:1 → User (guard)

**Indexes:**
- `idx_delivery_residence` on `residence_id`
- `idx_delivery_household` on `household_id`
- `idx_delivery_status` on `status`
- `idx_delivery_arrival` on `arrival_time`

**Notes:**
- Timer monitoring calculated as `exit_time - entry_time`
- Response protocol triggers if delivery duration exceeds acceptable time

---

### 14. Gate (Entrance)

**Purpose:** Community gates/entrances

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK | Unique gate identifier |
| `association_id` | UUID | FK → Association, NOT NULL | Parent association |
| `name` | VARCHAR(100) | NOT NULL | Gate name (e.g., "Main Gate", "East Entrance") |
| `location` | VARCHAR(255) | | Physical location/address |
| `gate_type` | ENUM | NOT NULL | main, secondary, pedestrian, service |
| `status` | ENUM | NOT NULL | active, inactive, under_maintenance |
| `has_rfid_reader` | BOOLEAN | DEFAULT false | RFID reader installed? |
| `has_camera` | BOOLEAN | DEFAULT false | CCTV camera installed? |
| `equipment_config` | JSONB | | Equipment configuration |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Relationships:**
- N:1 → Association
- 1:N → EntryLog
- M:N → User (guards assigned to gate via GateGuardAssignment)

**Indexes:**
- `idx_gate_association` on `association_id`
- `idx_gate_status` on `status`

---

### 15. EntryLog

**Purpose:** Comprehensive entry/exit logging

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK | Unique log identifier |
| `gate_id` | UUID | FK → Gate, NOT NULL | Entry/exit gate |
| `entry_type` | ENUM | NOT NULL | resident, guest, delivery, construction_worker, visitor |
| `person_name` | VARCHAR(255) | | Name of person (if applicable) |
| `user_id` | UUID | FK → User | Resident user (if applicable) |
| `guest_id` | UUID | FK → Guest | Guest record (if pre-registered) |
| `worker_id` | UUID | FK → ConstructionWorker | Worker record (if applicable) |
| `delivery_id` | UUID | FK → Delivery | Delivery record (if applicable) |
| `vehicle_plate` | VARCHAR(20) | | Vehicle plate number |
| `rfid_code` | VARCHAR(100) | | RFID code scanned |
| `entry_time` | TIMESTAMP | NOT NULL | Entry timestamp |
| `exit_time` | TIMESTAMP | | Exit timestamp |
| `purpose` | TEXT | | Purpose of visit |
| `logged_by_guard_id` | UUID | FK → User, NOT NULL | Guard who logged entry |
| `authorized_by_household_id` | UUID | FK → Household | Household that authorized (if applicable) |
| `notes` | TEXT | | Additional notes |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |

**Relationships:**
- N:1 → Gate
- N:1 → User (resident, if applicable)
- N:1 → Guest (if applicable)
- N:1 → ConstructionWorker (if applicable)
- N:1 → Delivery (if applicable)
- N:1 → User (guard who logged)
- N:1 → Household (authorizing household)

**Indexes:**
- `idx_entry_log_gate` on `gate_id`
- `idx_entry_log_entry_type` on `entry_type`
- `idx_entry_log_entry_time` on `entry_time`
- `idx_entry_log_user` on `user_id`
- `idx_entry_log_guard` on `logged_by_guard_id`

**Notes:**
- Central logging table for all entries/exits
- Links to relevant entities (Guest, Worker, Delivery) based on entry_type

---

### 16. Incident

**Purpose:** Security incident tracking

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK | Unique incident identifier |
| `association_id` | UUID | FK → Association, NOT NULL | Associated community |
| `incident_type` | ENUM | NOT NULL | theft, vandalism, noise_complaint, trespassing, emergency, other |
| `severity` | ENUM | NOT NULL | low, medium, high, critical |
| `reported_by` | VARCHAR(100) | NOT NULL | Source (user, cctv_ai, guard) |
| `reported_by_user_id` | UUID | FK → User | User who reported (if applicable) |
| `reported_at` | TIMESTAMP | NOT NULL | Report timestamp |
| `location` | VARCHAR(255) | | Incident location |
| `description` | TEXT | NOT NULL | Incident description |
| `status` | ENUM | NOT NULL | reported, dispatched, resolved, escalated, closed |
| `assigned_to_guard_id` | UUID | FK → User | Guard assigned to respond |
| `response_time` | INT | | Response time in seconds |
| `resolution` | TEXT | | Resolution details |
| `escalated_to_admin` | BOOLEAN | DEFAULT false | Escalated to admin? |
| `escalated_at` | TIMESTAMP | | Escalation timestamp |
| `resolved_at` | TIMESTAMP | | Resolution timestamp |
| `photo_urls` | JSONB | | Array of photo URLs |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Relationships:**
- N:1 → Association
- N:1 → User (reporter, if applicable)
- N:1 → User (assigned guard)

**Indexes:**
- `idx_incident_association` on `association_id`
- `idx_incident_severity` on `severity`
- `idx_incident_status` on `status`
- `idx_incident_reported_at` on `reported_at`

**Notes:**
- Addresses GAP-008: Incident escalation to admin
- High/critical severity incidents trigger `escalated_to_admin = true`
- Response time calculated as `dispatch_time - reported_at`

---

### 17. SecurityTeam

**Purpose:** Security team/agency hired by association

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK | Unique team identifier |
| `association_id` | UUID | FK → Association, UNIQUE, NOT NULL | Associated community (1:1) |
| `agency_name` | VARCHAR(255) | NOT NULL | Security agency name |
| `contract_start_date` | DATE | NOT NULL | Contract start |
| `contract_end_date` | DATE | | Contract end |
| `dispatcher_id` | UUID | FK → User | Head security command/dispatcher |
| `status` | ENUM | NOT NULL | active, inactive, contract_ended |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Relationships:**
- 1:1 → Association
- N:1 → User (dispatcher)
- 1:N → User (guards via security_team_id on User table)

**Indexes:**
- `idx_security_team_association` on `association_id`
- `idx_security_team_status` on `status`

---

### 18. Payment

**Purpose:** Financial transaction tracking

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK | Unique payment identifier |
| `association_id` | UUID | FK → Association, NOT NULL | Associated community |
| `payer_id` | UUID | FK → User, NOT NULL | User who made payment |
| `payment_type` | ENUM | NOT NULL | construction_fee, association_fee, sticker_fee, penalty |
| `reference_id` | UUID | | Reference to related entity (permit_id, household_id, etc.) |
| `amount` | DECIMAL(10,2) | NOT NULL | Payment amount |
| `currency` | VARCHAR(3) | DEFAULT 'PHP' | Currency code |
| `payment_method` | ENUM | NOT NULL | cash, bank_transfer, card, online |
| `status` | ENUM | NOT NULL | pending, paid, failed, refunded |
| `payment_date` | TIMESTAMP | | Actual payment timestamp |
| `receipt_number` | VARCHAR(100) | UNIQUE | Receipt number |
| `receipt_url` | VARCHAR(500) | | Receipt PDF URL |
| `gateway_transaction_id` | VARCHAR(255) | | Payment gateway transaction ID |
| `notes` | TEXT | | Additional notes |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Relationships:**
- N:1 → Association
- N:1 → User (payer)
- Polymorphic reference via `reference_id` (ConstructionPermit, Household, etc.)

**Indexes:**
- `idx_payment_association` on `association_id`
- `idx_payment_payer` on `payer_id`
- `idx_payment_type` on `payment_type`
- `idx_payment_status` on `status`
- `idx_payment_receipt` on `receipt_number`

**Notes:**
- Addresses GAP-005: Financial transaction tracking
- `receipt_number` auto-generated (e.g., "RCP-2025-00001")
- `receipt_url` points to generated PDF receipt

---

### 19. Announcement

**Purpose:** Community announcements

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK | Unique announcement identifier |
| `association_id` | UUID | FK → Association, NOT NULL | Associated community |
| `created_by_admin_id` | UUID | FK → User, NOT NULL | Admin who created |
| `title` | VARCHAR(255) | NOT NULL | Announcement title |
| `content` | TEXT | NOT NULL | Announcement content |
| `priority` | ENUM | NOT NULL | normal, high, urgent |
| `target_audience` | ENUM | NOT NULL | all, specific_households |
| `specific_household_ids` | JSONB | | Array of household IDs (if specific) |
| `sent_at` | TIMESTAMP | | Sent timestamp |
| `status` | ENUM | NOT NULL | draft, sent, archived |
| `read_receipts` | JSONB | | Array of {household_id, read_at} |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Relationships:**
- N:1 → Association
- N:1 → User (admin creator)

**Indexes:**
- `idx_announcement_association` on `association_id`
- `idx_announcement_status` on `status`
- `idx_announcement_sent_at` on `sent_at`

**Notes:**
- Addresses GAP-012: Announcement read receipts
- `read_receipts` JSONB example: `[{"household_id": "uuid", "read_at": "timestamp"}]`

---

### 20. Election

**Purpose:** Community officer elections

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK | Unique election identifier |
| `association_id` | UUID | FK → Association, NOT NULL | Associated community |
| `position` | VARCHAR(100) | NOT NULL | Position being elected (e.g., "HOA President") |
| `nomination_start` | TIMESTAMP | NOT NULL | Nomination period start |
| `nomination_end` | TIMESTAMP | NOT NULL | Nomination period end |
| `voting_start` | TIMESTAMP | NOT NULL | Voting period start |
| `voting_end` | TIMESTAMP | NOT NULL | Voting period end |
| `status` | ENUM | NOT NULL | draft, nomination_open, nomination_closed, voting_open, voting_closed, completed |
| `candidates` | JSONB | NOT NULL | Array of candidate user IDs |
| `votes` | JSONB | | Encrypted votes: {household_id: candidate_id} |
| `results` | JSONB | | Vote tallies: {candidate_id: vote_count} |
| `winner_id` | UUID | FK → User | Elected user |
| `term_start_date` | DATE | | Term start date |
| `term_end_date` | DATE | | Term end date |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |

**Relationships:**
- N:1 → Association
- N:1 → User (winner)

**Indexes:**
- `idx_election_association` on `association_id`
- `idx_election_status` on `status`
- `idx_election_voting_dates` on `voting_start, voting_end`

**Notes:**
- Addresses GAP-003: Election management
- One vote per household head enforced via constraint on `votes` JSONB (unique household_id keys)
- `votes` should be encrypted or hashed for privacy

---

## Row-Level Security (RLS) Policies

### Multi-Tenant Data Isolation

**Strategy:** All queries must be scoped by `association_id` (or `tenant_id` for Platform entities)

**Example RLS Policies (PostgreSQL):**

```sql
-- Association: Users can only access their own association
CREATE POLICY association_isolation ON association
  FOR ALL
  USING (
    association.id = current_setting('app.current_association_id')::uuid
    OR
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.user_type = 'platform_admin'
    )
  );

-- Household: Users can only access households in their association
CREATE POLICY household_isolation ON household
  FOR ALL
  USING (
    household.association_id = current_setting('app.current_association_id')::uuid
  );

-- User-specific data: Household heads can only access their own household
CREATE POLICY household_head_access ON household
  FOR SELECT
  USING (
    household.household_head_id = auth.uid()
  );

-- Guards can only access their assigned gates
CREATE POLICY guard_gate_access ON entry_log
  FOR INSERT
  USING (
    EXISTS (
      SELECT 1 FROM gate_guard_assignment
      WHERE gate_guard_assignment.guard_id = auth.uid()
      AND gate_guard_assignment.gate_id = entry_log.gate_id
    )
  );
```

**Implementation Notes:**
- Set `app.current_association_id` session variable on authentication
- Platform admins bypass association isolation
- Guards, residents, and admins see only their association's data

---

## Indexes & Performance Optimization

### Critical Indexes

1. **Foreign Key Indexes:** Index all FK columns for join performance
2. **Status Columns:** Index status/enum columns for filtering
3. **Timestamp Columns:** Index `created_at`, `updated_at`, entry/exit times for reporting
4. **Composite Indexes:** For common query patterns

**Example Composite Indexes:**

```sql
-- Entry logs by gate and date range
CREATE INDEX idx_entry_log_gate_time ON entry_log(gate_id, entry_time DESC);

-- Payments by association and status
CREATE INDEX idx_payment_association_status ON payment(association_id, status);

-- Guests by household and visit date
CREATE INDEX idx_guest_household_date ON guest(household_id, visit_date);

-- Incidents by association, severity, and status
CREATE INDEX idx_incident_assoc_severity_status ON incident(association_id, severity, status);
```

---

## Database Migration Strategy

### Phase 1: Core Schema (Week 1-2)
```
1. Create PlatformTenant, Association, Residence, Household, User
2. Create HouseholdResidence junction table
3. Implement RLS policies
4. Seed dev data (1 platform tenant, 2 associations)
```

### Phase 2: Vehicles & Access (Week 3-4)
```
5. Create Vehicle, Sticker, Gate, EntryLog
6. Add indexes for entry logging performance
7. Seed gates and test RFID validation
```

### Phase 3: Operations (Week 5-10)
```
8. Create Guest, BeneficialUser, Payment, Announcement
9. Create ConstructionPermit, ConstructionWorker
10. Create Delivery
11. Implement payment gateway integration
```

### Phase 4: Security & Governance (Week 11+)
```
12. Create Incident, SecurityTeam
13. Create Election
14. Add analytics views and materialized views for dashboards
15. Final performance tuning
```

---

## Sample Database Queries

### 1. Get all residences for a household head

```sql
SELECT r.*
FROM residence r
JOIN household_residence hr ON r.id = hr.residence_id
JOIN household h ON hr.household_id = h.id
WHERE h.household_head_id = $user_id
AND hr.move_out_date IS NULL;
```

### 2. Validate RFID sticker at gate

```sql
SELECT s.*, v.plate_number, u.first_name, u.last_name
FROM sticker s
JOIN vehicle v ON s.vehicle_id = v.id
JOIN user u ON s.issued_to_user_id = u.id
WHERE s.rfid_code = $scanned_code
AND s.status = 'active'
AND s.expiry_date >= CURRENT_DATE;
```

### 3. Check if guest is on the list

```sql
SELECT g.*
FROM guest g
WHERE g.household_id = (
  SELECT household_id FROM household_residence hr
  JOIN residence r ON hr.residence_id = r.id
  WHERE r.address = $residence_address
  LIMIT 1
)
AND g.visit_date = CURRENT_DATE
AND g.status IN ('scheduled', 'checked_in')
AND (g.first_name || ' ' || g.last_name) ILIKE '%' || $guest_name || '%';
```

### 4. Get construction permits requiring approval

```sql
SELECT cp.*, h.household_head_id, r.address
FROM construction_permit cp
JOIN household h ON cp.household_id = h.id
JOIN residence r ON cp.residence_id = r.id
WHERE cp.association_id = $association_id
AND cp.approval_status = 'pending'
AND cp.payment_status = 'paid'
ORDER BY cp.created_at ASC;
```

### 5. Daily entry statistics for admin dashboard

```sql
SELECT
  DATE(entry_time) as date,
  entry_type,
  COUNT(*) as entry_count
FROM entry_log
WHERE gate_id IN (
  SELECT id FROM gate WHERE association_id = $association_id
)
AND entry_time >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(entry_time), entry_type
ORDER BY date DESC, entry_type;
```

---

## Data Model Validation Checklist

✅ **Multi-tenancy:** All entities scoped by `association_id` or `tenant_id`
✅ **Residence entity:** Explicit Residence table with M:N to Household
✅ **Vehicle tracking:** Vehicle entity with sticker assignment and violations
✅ **Payment tracking:** Payment entity with receipts and transaction history
✅ **Construction workers:** Individual worker passes with gate pass codes
✅ **Guest duration:** Visit duration tracking (day-trip vs multi-day)
✅ **Incident escalation:** Severity classification and admin escalation flag
✅ **Beneficial users:** Separate entity for non-household sticker recipients
✅ **Election management:** Election entity with nominations, votes, results
✅ **Announcement receipts:** Read receipts in JSONB on Announcement table

---

## Related Documents

- [Comprehensive Business Analysis](business-analysis-comprehensive.md)
- [Executive Summary](executive-summary.md)
- [Gap Analysis](gap-analysis.md)
- [Implementation Roadmap](implementation-roadmap.md)

---

**End of Data Model Recommendations**
