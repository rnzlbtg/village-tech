# API Contracts - Admin App Residential

**Version**: 1.0.0
**Date**: 2025-10-10
**Architecture**: Next.js Server Actions + Supabase Direct Client Access

---

## Overview

The Admin App uses **Next.js Server Actions** for mutations and **Supabase client direct access** for queries, following the same pattern as Platform App.

---

## Server Action Contracts

### 1. Household Management

#### `createHousehold(data: CreateHouseholdInput): Promise<Result>`

**Input Schema (Zod)**:
```typescript
{
  residence_unit_id: uuid,
  household_name: string,
  household_head_email: string,
  household_head_name: string,
  household_head_phone?: string,
  move_in_date?: date
}
```

**Process**:
1. Create Supabase Auth user for household head
2. Set app_metadata with role='household_head' and tenant_id
3. Create household record linking to residence unit
4. Send welcome email with login credentials

**Authorization**: Admin (admin_head or admin_officer)

---

#### `addHouseholdMember(data: AddMemberInput): Promise<Result>`

**Input Schema**:
```typescript
{
  household_id: uuid,
  full_name: string,
  relationship: 'head' | 'spouse' | 'child' | 'parent' | 'other',
  contact_number?: string,
  email?: string,
  birth_date?: date
}
```

**Authorization**: Admin or household head (for own household)

---

### 2. Sticker Management

#### `approveStickerRequest(requestId: uuid): Promise<Result>`

**Process**:
1. Validate request is pending
2. Check household hasn't exceeded allocation
3. Update status to 'approved'
4. Send notification to household head
5. Log approval in audit trail

**Authorization**: Admin only

---

#### `distributeStickerPhysical(data: DistributeStickerInput): Promise<Result>`

**Input Schema**:
```typescript
{
  request_id: uuid,
  sticker_code: string,
  signature: string,
  distributed_at?: datetime
}
```

**Process**:
1. Validate request is approved
2. Create rfid_stickers record
3. Update request status to 'distributed'
4. Generate pickup receipt

**Authorization**: Admin only

---

### 3. Construction Permits

#### `approveConstructionPermit(data: ApprovePermitInput): Promise<Result>`

**Input Schema**:
```typescript
{
  permit_id: uuid,
  road_fee: number,
  approved_workers: Array<{name: string, id_number: string}>,
  notes?: string
}
```

**Process**:
1. Validate payment received
2. Update permit status to 'approved'
3. Generate permit reference number
4. Send permit details to guard house (creates construction_permits record for Sentinel)
5. Notify household head

**Authorization**: Admin only

---

#### `markPermitComplete(permitId: uuid): Promise<Result>`

**Process**:
1. Update permit status to 'completed'
2. Revoke worker gate access
3. Archive permit documents
4. Notify household

**Authorization**: Admin only

---

### 4. Announcements

#### `createAnnouncement(data: CreateAnnouncementInput): Promise<Result>`

**Input Schema**:
```typescript
{
  title: string,
  content: string,
  priority: 'normal' | 'high' | 'urgent',
  target_audience: Array<'residents' | 'guards' | 'security' | 'admin'>,
  attachment_files?: File[],
  expires_at?: datetime
}
```

**Process**:
1. Upload attachments to Supabase Storage (announcement-files bucket)
2. Create announcement record
3. Send push notifications if urgent
4. Mark as published

**Authorization**: Admin only

---

### 5. Payment Recording

#### `recordPayment(data: RecordPaymentInput): Promise<Result>`

**Input Schema**:
```typescript
{
  household_id: uuid,
  invoice_id?: uuid,
  amount: number,
  payment_method: 'cash' | 'check' | 'bank_transfer',
  payment_date: date,
  check_number?: string,
  check_bank?: string,
  check_date?: date,
  notes?: string
}
```

**Process**:
1. Generate receipt number
2. Insert payment_log
3. Update invoice if provided
4. Generate PDF receipt
5. Archive receipt in Storage

**Output**:
```typescript
{
  success: boolean,
  receipt_number: string,
  receipt_pdf_url: string
}
```

**Authorization**: Admin only

---

#### `recordPartialPayment(data: PartialPaymentInput): Promise<Result>`

**Input Schema**:
```typescript
{
  household_id: uuid,
  total_amount: number,
  payment_method: string,
  payment_date: date,
  allocations: Array<{ invoice_id: uuid, amount: number }>,
  check_details?: { number: string, bank: string, date: date }
}
```

**Process**:
1. Create payment_log
2. Create payment_allocations for each invoice
3. Update multiple invoices
4. Generate consolidated receipt

**Authorization**: Admin only

---

### 6. Election Management

#### `createElection(data: CreateElectionInput): Promise<Result>`

**Input Schema**:
```typescript
{
  election_name: string,
  description: string,
  positions: string[],
  registration_start: datetime,
  registration_end: datetime,
  voting_start: datetime,
  voting_end: datetime
}
```

**Authorization**: Admin (admin_head only)

---

#### `approveCandidates(candidateIds: uuid[]): Promise<Result>`

**Process**:
1. Update candidate status to 'approved'
2. Notify candidates
3. Publish to resident app

**Authorization**: Admin (admin_head only)

---

## Direct Supabase Queries (RSC)

### Fetch Households
```typescript
const { data: households } = await supabase
  .from('households')
  .select(`
    *,
    residence_unit:residence_units(unit_number, property:properties(name)),
    household_head:users(email, full_name),
    members:household_members(count)
  `)
  .eq('tenant_id', tenantId)
  .order('household_name')
```

### Fetch Sticker Requests
```typescript
const { data: requests } = await supabase
  .from('sticker_requests')
  .select(`
    *,
    household:households(household_name, residence_unit:residence_units(unit_number))
  `)
  .eq('status', 'pending')
  .order('requested_at')
```

### Fetch Pending Permits
```typescript
const { data: permits } = await supabase
  .from('construction_permits')
  .select(`
    *,
    household:households(household_name),
    payment:permit_payments(amount, payment_log:payment_logs(receipt_number))
  `)
  .in('status', ['pending', 'approved', 'in_progress'])
  .order('created_at', { ascending: false })
```

---

## File Upload Endpoints

### Upload Announcement Attachment
```typescript
// app/api/announcements/upload/route.ts
POST /api/announcements/upload

Request: multipart/form-data
  - file: File
  - announcement_id: uuid

Response:
{
  success: boolean,
  file_url: string
}
```

### Upload Permit Attachment
```typescript
POST /api/permits/upload

Request: multipart/form-data
  - file: File
  - permit_id: uuid

Response:
{
  success: boolean,
  file_url: string,
  signed_download_url: string
}
```

---

## PDF Generation Endpoint

### Generate Receipt PDF
```typescript
POST /api/receipts/generate

Request:
{
  receipt_number: string
}

Response: application/pdf (binary)
```

---

## Error Handling

### Standard Error Response
```typescript
{
  success: false,
  error: string,
  code?: string
}
```

### Common Error Codes
- `UNAUTHORIZED`: Insufficient permissions
- `VALIDATION_ERROR`: Input validation failed
- `NOT_FOUND`: Resource not found
- `ALLOCATION_EXCEEDED`: Sticker allocation limit reached
- `PAYMENT_REQUIRED`: Payment not received
- `ALREADY_EXISTS`: Duplicate entry

---

## Authorization Matrix

| Operation | Admin Head | Admin Officer | Household Head |
|-----------|------------|---------------|----------------|
| Create Household | ✅ | ✅ | ❌ |
| Approve Sticker | ✅ | ✅ | ❌ |
| Distribute Sticker | ✅ | ✅ | ❌ |
| Approve Permit | ✅ | ✅ | ❌ |
| Record Payment | ✅ | ✅ | ❌ |
| Create Announcement | ✅ | ✅ | ❌ |
| Create Election | ✅ | ❌ | ❌ |
| Approve Candidates | ✅ | ❌ | ❌ |

---

## Validation Strategy

All Server Actions use **Zod** schemas:

```typescript
import { z } from 'zod'

const createHouseholdSchema = z.object({
  residence_unit_id: z.string().uuid(),
  household_name: z.string().min(3).max(100),
  household_head_email: z.string().email(),
  household_head_name: z.string().min(3),
  household_head_phone: z.string().optional(),
  move_in_date: z.coerce.date().optional()
})

export async function createHousehold(input: unknown) {
  const data = createHouseholdSchema.parse(input)
  // ... implementation
}
```

---

**Last Updated**: 2025-10-10
**Related Docs**: [data-model.md](../data-model.md), [quickstart.md](../quickstart.md)
