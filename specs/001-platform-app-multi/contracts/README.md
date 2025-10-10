# API Contracts - Platform App Multi-Tenant Management

**Version**: 1.0.0
**Date**: 2025-10-10
**Architecture**: Next.js Server Actions + Supabase Direct Client Access

---

## Overview

The Platform App primarily uses **Next.js Server Actions** for mutations and **Supabase client direct access** for queries. API contracts defined here document the Server Action interfaces and expected data shapes.

---

## Architecture Pattern

### Queries (Read Operations)
- **Direct Supabase Client** access from React Server Components
- RLS policies enforce tenant isolation
- TypeScript types generated from Supabase schema

### Mutations (Write Operations)
- **Next.js Server Actions** for all create/update/delete operations
- Server-side validation using Zod schemas
- Role-based authorization checks
- Audit logging via database triggers

---

## Server Action Contracts

### 1. Tenant Management

#### `createTenant(data: CreateTenantInput): Promise<CreateTenantResult>`

**Purpose**: Create new residential community tenant

**Input Schema (Zod)**:
```typescript
{
  name: string (min: 3, max: 100),
  address: string (min: 10, max: 500),
  contact_name: string (min: 3, max: 100),
  contact_email: string (email format),
  contact_phone: string (phone format),
  settings?: object
}
```

**Output**:
```typescript
{
  success: boolean,
  data?: { id: uuid, name: string, ... },
  error?: string
}
```

**Authorization**: Super admin only

---

#### `updateTenant(id: uuid, data: UpdateTenantInput): Promise<UpdateTenantResult>`

**Purpose**: Update tenant information

**Input Schema**: Partial<CreateTenantInput>

**Authorization**: Super admin only

---

### 2. Property Management

#### `createProperty(data: CreatePropertyInput): Promise<CreatePropertyResult>`

**Input Schema**:
```typescript
{
  tenant_id: uuid,
  property_type: 'building' | 'lot' | 'townhouse',
  name: string,
  address?: string
}
```

**Authorization**: Super admin only

---

#### `bulkImportResidences(file: File, tenant_id: uuid): Promise<BulkImportResult>`

**Purpose**: Bulk import residence units from CSV/Excel

**Input**: File (CSV or Excel), tenant_id

**Output**:
```typescript
{
  success: boolean,
  total_rows: number,
  imported: number,
  errors: Array<{ row: number, message: string }>
}
```

**File Format** (CSV):
```
property_name,unit_number,address
Building A,101,Block 1 Lot 1
Building A,102,Block 1 Lot 2
```

**Process**:
1. Server-side file parsing (PapaParse/SheetJS)
2. Zod validation per row
3. Batched database insert (1,000 rows/batch)
4. Transaction rollback on critical errors

**Authorization**: Super admin only

---

### 3. Gate Management

#### `createGate(data: CreateGateInput): Promise<CreateGateResult>`

**Input Schema**:
```typescript
{
  tenant_id: uuid,
  name: string,
  location: string,
  equipment_config?: object
}
```

**Authorization**: Super admin only

---

### 4. Admin User Management

#### `createAdminUser(data: CreateAdminUserInput): Promise<CreateAdminUserResult>`

**Purpose**: Create admin head or officer user

**Input Schema**:
```typescript
{
  email: string (email format),
  password: string (min: 8, must include uppercase, lowercase, number),
  full_name: string,
  phone?: string,
  role: 'admin_head' | 'admin_officer',
  tenant_id: uuid
}
```

**Process**:
1. Create Supabase Auth user (via service role client)
2. Set app_metadata with role and tenant_id
3. Create admin_users table record
4. Trigger Custom Access Token Hook for JWT claims

**Authorization**: Super admin only

---

### 5. Association Settings

#### `updateAssociationSettings(tenant_id: uuid, settings: SettingsInput): Promise<SettingsResult>`

**Input Schema**:
```typescript
{
  [key: string]: {
    setting_key: string,
    setting_value: any
  }
}
```

**Common Settings**:
- association_fees: { monthly: number, annual: number }
- billing_period: 'monthly' | 'quarterly' | 'annual'
- curfew_hours: { start: string, end: string }

**Authorization**: Super admin only

---

## Error Handling

### Standard Error Response
```typescript
{
  success: false,
  error: string, // User-friendly message
  code?: string, // Error code for client handling
  details?: object // Additional context
}
```

### Common Error Codes
- `UNAUTHORIZED`: User lacks permission
- `VALIDATION_ERROR`: Input validation failed
- `DUPLICATE_ENTRY`: Unique constraint violation
- `NOT_FOUND`: Resource not found
- `SERVER_ERROR`: Internal server error

---

## Authentication & Authorization

### JWT Claims (via Custom Access Token Hook)
```json
{
  "sub": "user-uuid",
  "role": "super_admin" | "admin_head" | "admin_officer",
  "tenant_id": "tenant-uuid" | null,
  "email": "user@example.com"
}
```

### Authorization Matrix

| Operation | Super Admin | Admin Head | Admin Officer |
|-----------|-------------|------------|---------------|
| Create Tenant | ✅ | ❌ | ❌ |
| Update Tenant | ✅ | ❌ | ❌ |
| View All Tenants | ✅ | ❌ | ❌ |
| Create Property | ✅ | ❌ | ❌ |
| Bulk Import | ✅ | ❌ | ❌ |
| Create Gate | ✅ | ❌ | ❌ |
| Create Admin User | ✅ | ❌ | ❌ |
| Update Settings | ✅ | ❌ | ❌ |

---

## Validation Strategy

All Server Actions use **Zod** for input validation:

```typescript
// Example Server Action
'use server'

import { z } from 'zod'

const createTenantSchema = z.object({
  name: z.string().min(3).max(100),
  address: z.string().min(10).max(500),
  contact_email: z.string().email(),
  // ...
})

export async function createTenant(input: unknown) {
  // Validate input
  const validatedData = createTenantSchema.parse(input)

  // Check authorization
  const user = await getUser()
  if (user?.app_metadata?.role !== 'super_admin') {
    throw new Error('Unauthorized')
  }

  // Perform operation
  const { data, error } = await supabase
    .from('tenants')
    .insert(validatedData)
    .select()
    .single()

  if (error) throw error
  return { success: true, data }
}
```

---

## Testing

### Unit Tests (Vitest)
- Test Zod schemas independently
- Mock Supabase client
- Test authorization logic

### Integration Tests (Playwright)
- Test Server Action flows end-to-end
- Verify RLS policy enforcement
- Test bulk import with sample files

---

**Last Updated**: 2025-10-10
**Maintained By**: Platform Team
**Related Docs**: [data-model.md](../data-model.md), [quickstart.md](../quickstart.md)
