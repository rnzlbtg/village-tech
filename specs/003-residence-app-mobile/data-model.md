# Data Model: Residence App - Household Management Mobile Application

**Feature**: Residence App - Household Management Mobile Application
**Date**: 2025-10-10
**Database**: Supabase PostgreSQL with Row-Level Security (RLS)

---

## Core Entities

### 1. household_members
**Purpose**: Family members and residents living in the residence

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique member identifier |
| household_id | uuid | FK, NOT NULL | Reference to households |
| full_name | text | NOT NULL | Member name |
| relationship | text | NOT NULL | Relationship: head, spouse, child, parent, other |
| contact_number | text | NULLABLE | Contact phone |
| email | text | NULLABLE | Email address |
| birth_date | date | NULLABLE | Date of birth |
| created_at | timestamptz | NOT NULL, default: now() | Record creation |
| updated_at | timestamptz | NOT NULL, default: now() | Record update |

**Indexes**: `idx_household_members_household` ON (household_id)

**RLS Policy**: Household heads can CRUD their own household members; admins can CRUD all members for their tenant

---

### 2. beneficial_users
**Purpose**: Non-resident individuals with vehicle access privileges

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique beneficial user identifier |
| household_id | uuid | FK, NOT NULL | Reference to households |
| full_name | text | NOT NULL | Beneficial user name |
| contact_number | text | NOT NULL | Contact phone |
| email | text | NULLABLE | Email address |
| relationship | text | NOT NULL | Relationship to household (helper, family, friend) |
| id_photo_url | text | NULLABLE | Photo URL from Supabase Storage |
| status | text | NOT NULL, default: 'active' | Status: active, inactive |
| created_at | timestamptz | NOT NULL, default: now() | Record creation |
| updated_at | timestamptz | NOT NULL, default: now() | Record update |

**Indexes**: `idx_beneficial_users_household` ON (household_id), `idx_beneficial_users_status` ON (status)

**RLS Policy**: Household heads can CRUD their own beneficial users; admins can CRUD all beneficial users for their tenant

---

### 3. sticker_requests
**Purpose**: Vehicle sticker requests from household heads

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique request identifier |
| household_id | uuid | FK, NOT NULL | Reference to households |
| requested_by | uuid | FK, NOT NULL | User who requested (household head) |
| owner_type | text | NOT NULL | Owner type: household_member, beneficial_user |
| owner_id | uuid | NOT NULL | Reference to household_member or beneficial_user |
| vehicle_plate | text | NOT NULL | Vehicle plate number |
| vehicle_make | text | NULLABLE | Vehicle make/model |
| vehicle_color | text | NULLABLE | Vehicle color |
| status | text | NOT NULL, default: 'pending' | Status: pending, approved, distributed, rejected |
| requested_at | timestamptz | NOT NULL, default: now() | Request timestamp |
| approved_at | timestamptz | NULLABLE | Approval timestamp |
| approved_by | uuid | FK, NULLABLE | Admin who approved |
| distributed_at | timestamptz | NULLABLE | Distribution timestamp |
| signature | text | NULLABLE | Pickup signature (base64 or URL) |
| rejection_reason | text | NULLABLE | Reason if rejected |
| created_at | timestamptz | NOT NULL, default: now() | Record creation |

**Indexes**: `idx_sticker_requests_household` ON (household_id), `idx_sticker_requests_status` ON (status), `idx_sticker_requests_owner` ON (owner_type, owner_id)

**RLS Policy**: Household heads can create and read their own requests; admins can CRUD all tenant requests

---

### 4. rfid_stickers
**Purpose**: Physical RFID stickers assigned to vehicles (shared with Sentinel App)

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique sticker identifier |
| tenant_id | uuid | FK, NOT NULL | Reference to tenant |
| household_id | uuid | FK, NOT NULL | Reference to household |
| sticker_code | text | UNIQUE, NOT NULL | RFID sticker code |
| vehicle_plate | text | NOT NULL | Vehicle plate number |
| owner_type | text | NOT NULL | Owner type: household_member, beneficial_user |
| owner_id | uuid | NOT NULL | Reference to household_member or beneficial_user |
| issue_date | date | NOT NULL | Sticker issue date |
| expiry_date | date | NULLABLE | Sticker expiration date |
| status | text | NOT NULL, default: 'active' | Status: active, expired, lost, deactivated |
| created_at | timestamptz | NOT NULL, default: now() | Record creation |
| updated_at | timestamptz | NOT NULL, default: now() | Record update |

**Indexes**: `idx_rfid_stickers_tenant` ON (tenant_id), `idx_rfid_stickers_household` ON (household_id), `idx_rfid_stickers_code` ON (sticker_code), `idx_rfid_stickers_status` ON (status)

**RLS Policy**: Household heads can read their own stickers; admins can CRUD all stickers for their tenant; guards can read all stickers for their tenant

---

### 5. pre_registered_guests
**Purpose**: Scheduled guest visits pre-registered by household heads

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique guest registration identifier |
| household_id | uuid | FK, NOT NULL | Reference to household |
| registered_by | uuid | FK, NOT NULL | User who registered (household head) |
| guest_name | text | NOT NULL | Guest name |
| guest_contact | text | NULLABLE | Guest contact number |
| visit_start | timestamptz | NOT NULL | Visit start time |
| visit_end | timestamptz | NOT NULL | Visit end time |
| visit_type | text | NOT NULL | Type: day_trip, multi_day |
| purpose | text | NULLABLE | Visit purpose |
| vehicle_plate | text | NULLABLE | Guest vehicle plate |
| status | text | NOT NULL, default: 'scheduled' | Status: scheduled, checked_in, checked_out, cancelled |
| checked_in_at | timestamptz | NULLABLE | Check-in timestamp |
| checked_out_at | timestamptz | NULLABLE | Check-out timestamp |
| created_at | timestamptz | NOT NULL, default: now() | Record creation |
| updated_at | timestamptz | NOT NULL, default: now() | Record update |

**Indexes**: `idx_pre_registered_guests_household` ON (household_id), `idx_pre_registered_guests_visit_start` ON (visit_start), `idx_pre_registered_guests_status` ON (status)

**RLS Policy**: Household heads can CRUD their own guests; admins and guards can read all guests for their tenant

---

### 6. guest_logs
**Purpose**: Entry/exit logs for all guest visits (created by Sentinel App)

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique log identifier |
| tenant_id | uuid | FK, NOT NULL | Reference to tenant |
| household_id | uuid | FK, NOT NULL | Reference to household |
| guest_registration_id | uuid | FK, NULLABLE | Reference to pre_registered_guests (if pre-registered) |
| guest_name | text | NOT NULL | Guest name |
| guest_contact | text | NULLABLE | Guest contact |
| vehicle_plate | text | NULLABLE | Guest vehicle |
| entry_timestamp | timestamptz | NOT NULL | Entry timestamp |
| exit_timestamp | timestamptz | NULLABLE | Exit timestamp |
| verification_method | text | NOT NULL | Method: pre_registered, phone_call |
| verified_by | uuid | FK, NOT NULL | Guard who verified |
| created_at | timestamptz | NOT NULL, default: now() | Record creation |

**Indexes**: `idx_guest_logs_tenant` ON (tenant_id), `idx_guest_logs_household` ON (household_id), `idx_guest_logs_entry` ON (entry_timestamp)

**RLS Policy**: Household heads can read their own guest logs; admins and guards can read all logs for their tenant

---

### 7. construction_permit_requests
**Purpose**: Construction permit applications from household heads

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique permit request identifier |
| household_id | uuid | FK, NOT NULL | Reference to household |
| requested_by | uuid | FK, NOT NULL | User who requested (household head) |
| project_type | text | NOT NULL | Type: renovation, construction, repair, landscaping |
| project_description | text | NOT NULL | Project description |
| contractor_name | text | NOT NULL | Contractor company name |
| contractor_contact | text | NOT NULL | Contractor contact |
| start_date | date | NOT NULL | Project start date |
| end_date | date | NOT NULL | Project end date |
| estimated_workers | int | NOT NULL | Estimated number of workers |
| road_fee | decimal(10,2) | NULLABLE | Computed road usage fee |
| status | text | NOT NULL, default: 'pending' | Status: pending, fee_pending, approved, rejected, completed |
| payment_status | text | NOT NULL, default: 'unpaid' | Payment status: unpaid, paid |
| payment_log_id | uuid | FK, NULLABLE | Reference to payment_logs |
| approved_at | timestamptz | NULLABLE | Approval timestamp |
| approved_by | uuid | FK, NULLABLE | Admin who approved |
| rejection_reason | text | NULLABLE | Reason if rejected |
| created_at | timestamptz | NOT NULL, default: now() | Record creation |
| updated_at | timestamptz | NOT NULL, default: now() | Record update |

**Indexes**: `idx_construction_permit_requests_household` ON (household_id), `idx_construction_permit_requests_status` ON (status)

**RLS Policy**: Household heads can create and read their own requests; admins can CRUD all requests for their tenant

---

### 8. messages
**Purpose**: Communication between household heads and admin officers

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique message identifier |
| tenant_id | uuid | FK, NOT NULL | Reference to tenant |
| sender_id | uuid | FK, NOT NULL | User who sent message |
| recipient_id | uuid | FK, NULLABLE | User who receives message (NULL for broadcast) |
| subject | text | NULLABLE | Message subject |
| content | text | NOT NULL | Message content |
| message_type | text | NOT NULL | Type: household_to_admin, admin_to_household |
| read_at | timestamptz | NULLABLE | Read timestamp |
| created_at | timestamptz | NOT NULL, default: now() | Record creation |

**Indexes**: `idx_messages_tenant` ON (tenant_id), `idx_messages_sender` ON (sender_id), `idx_messages_recipient` ON (recipient_id)

**RLS Policy**: Users can read messages where they are sender or recipient; admins can read all messages for their tenant

---

### 9. announcements
**Purpose**: Broadcast announcements from admin to residents (read-only for household heads)

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

**Indexes**: `idx_announcements_tenant` ON (tenant_id), `idx_announcements_active` ON (active) WHERE active = true, `idx_announcements_published` ON (published_at)

**RLS Policy**: Household heads can read active announcements where 'residents' is in target_audience; admins can CRUD announcements for their tenant

---

### 10. user_fcm_tokens
**Purpose**: Firebase Cloud Messaging tokens for push notifications

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique token identifier |
| user_id | uuid | FK, NOT NULL | Reference to auth.users |
| fcm_token | text | NOT NULL | FCM device token |
| platform | text | NOT NULL | Platform: ios, android |
| created_at | timestamptz | NOT NULL, default: now() | Record creation |
| updated_at | timestamptz | NOT NULL, default: now() | Record update |

**Indexes**: `idx_user_fcm_tokens_user` ON (user_id)

**Unique Constraint**: (user_id, platform)

**RLS Policy**: Users can CRUD their own tokens; admins can read all tokens for notification delivery

---

### 11. village_rules
**Purpose**: Community rules and guidelines (read-only for household heads)

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | uuid | PK | Unique rule identifier |
| tenant_id | uuid | FK, NOT NULL | Reference to tenant |
| rule_category | text | NOT NULL | Category: general, parking, noise, construction, curfew |
| rule_title | text | NOT NULL | Rule title |
| rule_content | text | NOT NULL | Rule content |
| curfew_start | time | NULLABLE | Curfew start time (if applicable) |
| curfew_end | time | NULLABLE | Curfew end time (if applicable) |
| active | boolean | NOT NULL, default: true | Rule active |
| created_at | timestamptz | NOT NULL, default: now() | Record creation |
| updated_at | timestamptz | NOT NULL, default: now() | Record update |

**Indexes**: `idx_village_rules_tenant` ON (tenant_id), `idx_village_rules_category` ON (rule_category), `idx_village_rules_active` ON (active) WHERE active = true

**RLS Policy**: Household heads can read active rules for their tenant; admins can CRUD rules for their tenant

---

## Relationships

```
households (1) ─┬─ (N) household_members
                ├─ (N) beneficial_users
                ├─ (N) sticker_requests
                ├─ (N) rfid_stickers
                ├─ (N) pre_registered_guests
                ├─ (N) guest_logs
                └─ (N) construction_permit_requests

sticker_requests (1) ─── (1) rfid_stickers (after distribution)

pre_registered_guests (1) ─── (N) guest_logs (entry/exit records)

construction_permit_requests (1) ─── (1) payment_logs (via payment_log_id)

auth.users (1) ─── (N) user_fcm_tokens

tenants (1) ─┬─ (N) announcements
             ├─ (N) messages
             ├─ (N) village_rules
             └─ (N) guest_logs
```

---

## State Transitions

### Sticker Request Status
```
pending → approved (by admin)
approved → distributed (when physically collected with signature)
pending → rejected (by admin with reason)
```

### RFID Sticker Status
```
active → expired (automatic when expiry_date reached)
active → lost (manual, when household reports lost)
active → deactivated (manual, when household member removed or beneficial user removed)
```

### Pre-Registered Guest Status
```
scheduled → checked_in (when guest enters gate)
checked_in → checked_out (when guest exits gate)
scheduled → cancelled (by household head)
```

### Construction Permit Request Status
```
pending → fee_pending (when admin computes fee)
fee_pending → approved (when payment received and admin approves)
pending → rejected (by admin with reason)
approved → completed (when construction is finished)
```

---

## Database Functions & Triggers

### Auto-expire guests after visit end time
```sql
CREATE OR REPLACE FUNCTION auto_expire_guest_visits()
RETURNS void AS $$
BEGIN
  UPDATE pre_registered_guests
  SET status = 'expired'
  WHERE visit_end < NOW()
  AND status = 'scheduled';
END;
$$ LANGUAGE plpgsql;

-- Run every 15 minutes via pg_cron
SELECT cron.schedule('expire-guests', '*/15 * * * *', 'SELECT auto_expire_guest_visits()');
```

### Send notification on sticker approval
```sql
CREATE OR REPLACE FUNCTION notify_sticker_approved()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'approved' AND OLD.status != 'approved' THEN
    PERFORM net.http_post(
      url := 'https://your-project.supabase.co/functions/v1/send-notification',
      headers := jsonb_build_object('Authorization', 'Bearer ' || current_setting('request.jwt.claim.token')),
      body := jsonb_build_object(
        'userId', (SELECT household_head_id FROM households WHERE id = NEW.household_id),
        'title', 'Sticker Request Approved',
        'body', 'Your vehicle sticker request has been approved. Please collect at admin office.',
        'data', jsonb_build_object('requestId', NEW.id, 'type', 'sticker_approval')
      )
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_notify_sticker_approved
AFTER UPDATE ON sticker_requests
FOR EACH ROW
EXECUTE FUNCTION notify_sticker_approved();
```

### Auto-expire RFID stickers
```sql
CREATE OR REPLACE FUNCTION auto_expire_stickers()
RETURNS void AS $$
BEGIN
  UPDATE rfid_stickers
  SET status = 'expired'
  WHERE expiry_date < CURRENT_DATE
  AND status = 'active';
END;
$$ LANGUAGE plpgsql;

-- Run daily at midnight via pg_cron
SELECT cron.schedule('expire-stickers', '0 0 * * *', 'SELECT auto_expire_stickers()');
```

---

## RLS Policies Summary

### Household Head Access Pattern
```sql
-- Household heads can access their own household data
CREATE POLICY "Household heads access own data"
ON {table_name} FOR ALL
TO authenticated
USING (
  household_id IN (
    SELECT id FROM households WHERE household_head_id = auth.uid()
  )
);
```

### Admin Access Pattern
```sql
-- Admins can access all tenant data
CREATE POLICY "Admins access tenant data"
ON {table_name} FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM households h
    WHERE h.id = {table_name}.household_id
    AND h.tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
    AND (auth.jwt() ->> 'role')::text IN ('admin_head', 'admin_officer')
  )
);
```

### Guard Access Pattern (Read-only)
```sql
-- Guards can read all tenant data for verification
CREATE POLICY "Guards read tenant data"
ON {table_name} FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM households h
    WHERE h.id = {table_name}.household_id
    AND h.tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
    AND (auth.jwt() ->> 'role')::text = 'guard'
  )
);
```

---

## Storage Buckets

### user-photos
**Purpose**: Store ID photos for beneficial users

**RLS Policies**:
```sql
-- Household heads can upload photos
CREATE POLICY "Household heads upload photos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'user-photos' AND
  (storage.foldername(name))[1] = (auth.jwt() ->> 'tenant_id')::text AND
  (auth.jwt() ->> 'role')::text = 'household_head'
);

-- Admins and household heads can view photos
CREATE POLICY "Admins and household heads view photos"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'user-photos' AND
  (storage.foldername(name))[1] = (auth.jwt() ->> 'tenant_id')::text
);
```

---

**Data Model Version**: 1.0.0
**Next Steps**: Generate API contracts
