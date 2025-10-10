# Developer Quickstart: Platform App - Multi-Tenant Management

**Feature**: Platform App - Multi-Tenant Management System
**Platform**: Next.js 14+ (Web)
**Date**: 2025-10-10

---

## 🎯 Overview

The Platform App is a Next.js web application for platform super administrators to onboard and configure residential community tenants. Features include tenant creation, property/residence configuration, gate setup, admin user creation, and association settings management.

---

## 📋 Prerequisites

### Required Tools
- **Node.js**: 20 LTS or higher
- **pnpm**: 8.0+ (recommended) or npm
- **Git**: For version control

### Backend Setup
- **Supabase Project**: Access to Village Tech v4 Supabase instance
- **Environment Variables**: `.env.local` with Supabase credentials

---

## 🚀 Quick Start (5 minutes)

### 1. Clone & Navigate
```bash
git clone https://github.com/your-org/village-tech-v4.git
cd village-tech-v4
git checkout 001-platform-app-multi
cd apps/platform
```

### 2. Install Dependencies
```bash
pnpm install
```

### 3. Configure Environment
Create `.env.local`:
```bash
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://your-project-id.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# App
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

### 4. Run Development Server
```bash
pnpm dev
```

Visit http://localhost:3000

---

## 🏗️ Project Structure

```
apps/platform/
├── app/
│   ├── (auth)/login/              # Authentication
│   ├── (dashboard)/               # Protected routes
│   │   ├── tenants/               # Tenant management
│   │   │   ├── page.tsx           # List
│   │   │   ├── [id]/              # Detail/Edit
│   │   │   └── new/               # Create
│   │   └── dashboard/             # Overview
│   ├── api/bulk-import/           # Bulk import endpoint
│   └── layout.tsx
├── components/
│   ├── ui/                        # shadcn/ui
│   ├── tenants/                   # Tenant components
│   └── shared/
├── lib/
│   ├── supabase/                  # Supabase clients
│   ├── actions/                   # Server Actions
│   ├── hooks/                     # React hooks
│   └── validations/               # Zod schemas
└── tests/
```

---

## 🔑 Key Workflows

### 1. Create Tenant (Server Action)

```typescript
// lib/actions/tenant.ts
'use server'

import { z } from 'zod'
import { createServerClient } from '@/lib/supabase/server'

const createTenantSchema = z.object({
  name: z.string().min(3),
  address: z.string().min(10),
  contact_email: z.string().email(),
  // ...
})

export async function createTenant(formData: FormData) {
  const supabase = createServerClient()

  // Get user and check role
  const { data: { user } } = await supabase.auth.getUser()
  if (user?.app_metadata?.role !== 'super_admin') {
    return { error: 'Unauthorized' }
  }

  // Validate
  const data = createTenantSchema.parse(Object.fromEntries(formData))

  // Insert
  const { data: tenant, error } = await supabase
    .from('tenants')
    .insert(data)
    .select()
    .single()

  if (error) return { error: error.message }
  return { success: true, data: tenant }
}
```

### 2. Bulk Import Residences

```typescript
// app/api/bulk-import/route.ts
import { NextRequest } from 'next/server'
import Papa from 'papaparse'

export async function POST(req: NextRequest) {
  const formData = await req.formData()
  const file = formData.get('file') as File

  // Parse CSV
  const text = await file.text()
  const { data } = Papa.parse(text, { header: true })

  // Validate each row
  const residences = data.map(validateRow)

  // Batch insert
  const supabase = createServerClient()
  const { data: inserted, error } = await supabase
    .from('residence_units')
    .insert(residences)

  return Response.json({ success: !error, count: inserted?.length })
}
```

### 3. RLS Policy Example

```sql
-- tenants table RLS
CREATE POLICY "Super admins can access all tenants"
ON tenants FOR ALL
TO authenticated
USING ((auth.jwt() ->> 'role')::text = 'super_admin');

-- properties table RLS
CREATE POLICY "Super admins and tenant users can access"
ON properties FOR SELECT
TO authenticated
USING (
  (auth.jwt() ->> 'role')::text = 'super_admin'
  OR tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
);
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

### 1. Server-Side User Validation
```typescript
// ALWAYS use getUser() not getSession()
const { data: { user } } = await supabase.auth.getUser()
```

### 2. Role-Based Authorization
```typescript
// Check in every Server Action
if (user?.app_metadata?.role !== 'super_admin') {
  throw new Error('Unauthorized')
}
```

### 3. Input Validation
```typescript
// Use Zod for all inputs
const schema = z.object({ ... })
const validated = schema.parse(input)
```

---

## 🚨 Troubleshooting

### RLS Policies Blocking Queries
**Issue**: Cannot read data despite being authenticated

**Solution**:
1. Check user role in JWT: `console.log(user.app_metadata.role)`
2. Verify RLS policy includes your role
3. Test policy with SQL Editor role switching

### Bulk Import Failing
**Issue**: Large CSV files timing out

**Solution**:
1. Process in batches (1,000-10,000 rows)
2. Use PostgreSQL COPY command for very large datasets
3. Implement progress indicator with streaming

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
4. ⏳ Implement tenant management (Priority P1)
5. ⏳ Implement property configuration (Priority P1)

---

**Last Updated**: 2025-10-10
**Version**: 1.0.0
**Maintained By**: Platform Team
