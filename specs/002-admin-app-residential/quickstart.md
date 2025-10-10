# Developer Quickstart: Admin App - Residential Community Administration

**Feature**: Admin App - Residential Community Administration
**Platform**: Next.js 14+ (Web)
**Date**: 2025-10-10

---

## 🎯 Overview

The Admin App is a Next.js web application for tenant admin officers to manage daily community operations including household setup, vehicle sticker distribution, construction permits, announcements, association fees, and HOA elections.

---

## 📋 Prerequisites

- **Node.js**: 20 LTS+
- **pnpm**: 8.0+ (or npm)
- **Supabase Project**: Access to Village Tech v4 instance
- **Platform App**: Tenant must be created in Platform App first

---

## 🚀 Quick Start

### 1. Clone & Navigate
```bash
cd village-tech-v4
git checkout 002-admin-app-residential
cd apps/admin
```

### 2. Install Dependencies
```bash
pnpm install
```

### 3. Configure Environment
Create `.env.local`:
```bash
NEXT_PUBLIC_SUPABASE_URL=https://your-project-id.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
NEXT_PUBLIC_APP_URL=http://localhost:3001
```

### 4. Run Development Server
```bash
pnpm dev
```

Visit http://localhost:3001

---

## 🔑 Key Workflows

### 1. Create Household

```typescript
// lib/actions/household.ts
'use server'

import { z } from 'zod'
import { createServerClient } from '@/lib/supabase/server'

const createHouseholdSchema = z.object({
  residence_unit_id: z.string().uuid(),
  household_name: z.string().min(3),
  household_head_email: z.string().email(),
  household_head_name: z.string()
})

export async function createHousehold(formData: FormData) {
  const supabase = createServerClient()
  const data = createHouseholdSchema.parse(Object.fromEntries(formData))

  // Create Supabase Auth user for household head
  const { data: user } = await supabase.auth.admin.createUser({
    email: data.household_head_email,
    email_confirm: true,
    user_metadata: {
      full_name: data.household_head_name
    },
    app_metadata: {
      role: 'household_head',
      tenant_id: await getTenantId()
    }
  })

  // Create household record
  const { data: household } = await supabase
    .from('households')
    .insert({
      tenant_id: await getTenantId(),
      residence_unit_id: data.residence_unit_id,
      household_head_id: user.id,
      household_name: data.household_name
    })
    .select()
    .single()

  return { success: true, household }
}
```

### 2. Approve Sticker Request

```typescript
// lib/actions/stickers.ts
export async function approveStickerRequest(requestId: string) {
  const supabase = createServerClient()

  // Check allocation limit
  const { data: request } = await supabase
    .from('sticker_requests')
    .select('*, household:households(*)')
    .eq('id', requestId)
    .single()

  const { count } = await supabase
    .from('rfid_stickers')
    .select('*', { count: 'exact', head: true })
    .eq('household_id', request.household_id)
    .eq('status', 'active')

  // Get program limit
  const { data: program } = await supabase
    .from('sticker_programs')
    .select('stickers_per_household')
    .eq('tenant_id', await getTenantId())
    .eq('active', true)
    .single()

  if (count >= program.stickers_per_household) {
    throw new Error('Household has reached sticker allocation limit')
  }

  // Approve request
  await supabase
    .from('sticker_requests')
    .update({
      status: 'approved',
      approved_at: new Date().toISOString(),
      approved_by: await getUserId()
    })
    .eq('id', requestId)

  // Send notification
  await sendNotification(request.household.household_head_id, {
    title: 'Sticker Request Approved',
    body: 'Your vehicle sticker request has been approved. Please collect at admin office.'
  })

  return { success: true }
}
```

### 3. Record Payment with Receipt Generation

```typescript
// lib/actions/payments.ts
import { pdf } from '@react-pdf/renderer'
import { PaymentReceiptTemplate } from '@/components/receipts/PaymentReceipt'

export async function recordPayment(data: RecordPaymentInput) {
  const supabase = createServerClient()

  // Generate receipt number
  const receiptNumber = await generateReceiptNumber()

  // Insert payment log
  const { data: payment } = await supabase
    .from('payment_logs')
    .insert({
      tenant_id: await getTenantId(),
      receipt_number: receiptNumber,
      household_id: data.household_id,
      invoice_id: data.invoice_id,
      amount: data.amount,
      payment_method: data.payment_method,
      payment_date: data.payment_date,
      check_number: data.check_number,
      check_bank: data.check_bank,
      recorded_by: await getUserId(),
      status: 'completed'
    })
    .select()
    .single()

  // Update invoice if provided
  if (data.invoice_id) {
    await updateInvoicePayment(data.invoice_id, data.amount)
  }

  // Generate PDF receipt
  const { data: household } = await supabase
    .from('households')
    .select('*')
    .eq('id', data.household_id)
    .single()

  const receiptBlob = await pdf(
    <PaymentReceiptTemplate payment={payment} household={household} />
  ).toBlob()

  // Upload to Storage
  const receiptPath = `${await getTenantId()}/receipts/${receiptNumber}.pdf`
  await supabase.storage
    .from('receipt-archives')
    .upload(receiptPath, receiptBlob)

  return { success: true, receiptNumber, receiptPath }
}
```

### 4. File Upload for Announcements

```typescript
// app/api/announcements/upload/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { createServerClient } from '@/lib/supabase/server'

export async function POST(req: NextRequest) {
  const formData = await req.formData()
  const file = formData.get('file') as File
  const announcementId = formData.get('announcement_id') as string

  const supabase = createServerClient()

  // Validate file
  const allowedTypes = ['application/pdf', 'image/jpeg', 'image/png']
  if (!allowedTypes.includes(file.type)) {
    return NextResponse.json({ error: 'Invalid file type' }, { status: 400 })
  }

  if (file.size > 10 * 1024 * 1024) { // 10MB
    return NextResponse.json({ error: 'File too large' }, { status: 400 })
  }

  // Upload to Supabase Storage
  const filePath = `${await getTenantId()}/announcements/${Date.now()}-${file.name}`
  const { data, error } = await supabase.storage
    .from('announcement-files')
    .upload(filePath, file)

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }

  // Get public URL
  const { data: { publicUrl } } = supabase.storage
    .from('announcement-files')
    .getPublicUrl(filePath)

  return NextResponse.json({ success: true, fileUrl: publicUrl })
}
```

---

## 🧪 Testing

### Run Tests
```bash
# Unit tests
pnpm test

# E2E tests
pnpm test:e2e

# Coverage
pnpm test:coverage
```

---

## 🔐 Security Best Practices

### 1. Always Use getUser()
```typescript
const { data: { user } } = await supabase.auth.getUser()
// Not getSession()
```

### 2. Validate Tenant Scope
```typescript
async function getTenantId() {
  const { data: { user } } = await supabase.auth.getUser()
  return user?.app_metadata?.tenant_id
}
```

### 3. Check Admin Role
```typescript
async function requireAdmin() {
  const { data: { user } } = await supabase.auth.getUser()
  if (!['admin_head', 'admin_officer'].includes(user?.app_metadata?.role)) {
    throw new Error('Unauthorized')
  }
}
```

---

## 🚨 Troubleshooting

### RLS Policies Blocking
**Issue**: Cannot insert/update records

**Solution**:
1. Verify user role in JWT: `user.app_metadata.role`
2. Check tenant_id matches in RLS policy
3. Use SQL Editor to test policy with role switching

### File Upload Failing
**Issue**: Upload times out or fails

**Solution**:
1. Check file size < 10MB
2. Verify bucket exists and RLS allows INSERT
3. Use signed upload URLs for large files

### Receipt PDF Not Generating
**Issue**: PDF generation fails

**Solution**:
1. Check @react-pdf/renderer is installed
2. Verify all required data is present
3. Test PDF template in isolation

---

## 📚 Additional Resources

- [Feature Specification](./spec.md)
- [Data Model](./data-model.md)
- [API Contracts](./contracts/README.md)
- [Research Findings](./research.md)

---

## 🎯 Next Steps

1. ✅ Complete Phase 0 research (DONE)
2. ✅ Complete Phase 1 design artifacts (DONE)
3. ⏳ Phase 2: Generate tasks.md via `/speckit.tasks` command
4. ⏳ Implement household management (Priority P1)
5. ⏳ Implement sticker management (Priority P1)

---

**Last Updated**: 2025-10-10
**Version**: 1.0.0
**Maintained By**: Admin App Team
