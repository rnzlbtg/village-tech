# Storage Bucket Setup Guide

## Overview

The admin app requires four storage buckets in Supabase for file uploads:
1. `household-documents` - ID documents, certificates
2. `permit-attachments` - Construction permit files
3. `announcement-files` - Announcement attachments
4. `receipt-archives` - Payment receipt PDFs

Each bucket has RLS (Row Level Security) policies defined in `supabase/storage/*.sql` files.

---

## Prerequisites

- Supabase project created
- Admin access to Supabase Dashboard
- Database migrations run (up to migration 036)

---

## Setup Steps

### Step 1: Create Storage Buckets

1. Go to Supabase Dashboard → Storage
2. Click "Create bucket" for each of the following:

#### Bucket 1: household-documents
```
Name: household-documents
Public: NO (private bucket)
File size limit: 10MB
Allowed MIME types: image/*, application/pdf
```

#### Bucket 2: permit-attachments
```
Name: permit-attachments
Public: NO (private bucket)
File size limit: 10MB
Allowed MIME types: image/*, application/pdf, application/msword, application/vnd.openxmlformats-officedocument.wordprocessingml.document
```

#### Bucket 3: announcement-files
```
Name: announcement-files
Public: NO (private bucket)
File size limit: 10MB
Allowed MIME types: image/*, application/pdf, application/msword, application/vnd.openxmlformats-officedocument.wordprocessingml.document
```

#### Bucket 4: receipt-archives
```
Name: receipt-archives
Public: NO (private bucket)
File size limit: 5MB
Allowed MIME types: application/pdf
```

### Step 2: Apply RLS Policies

For each bucket, apply the corresponding SQL file from `supabase/storage/`:

1. Go to Supabase Dashboard → SQL Editor
2. Open a new query
3. Copy the contents of the policy file
4. Execute the SQL

#### Apply household-documents policies
```sql
-- Copy from: supabase/storage/household-documents-policy.sql
```

#### Apply permit-attachments policies
```sql
-- Copy from: supabase/storage/permit-attachments-policy.sql
```

#### Apply announcement-files policies
```sql
-- Copy from: supabase/storage/announcement-files-policy.sql
```

#### Apply receipt-archives policies
```sql
-- Copy from: supabase/storage/receipt-archives-policy.sql
```

### Step 3: Verify Policies

1. Go to Supabase Dashboard → Storage
2. Click on each bucket
3. Go to "Policies" tab
4. Verify policies are listed:
   - INSERT policy (admins can upload)
   - SELECT policy (admins/users can view)
   - UPDATE policy (if applicable)
   - DELETE policy (admins can delete)

---

## Testing

### Test 1: Upload Household Document (Admin)

```bash
# Test with admin credentials
curl -X POST "https://your-project.supabase.co/storage/v1/object/household-documents/{tenant_id}/{household_id}/test.pdf" \
  -H "Authorization: Bearer {admin_jwt}" \
  -H "Content-Type: application/pdf" \
  --data-binary @test.pdf
```

Expected: Success (200 OK)

### Test 2: Upload Without Auth

```bash
# Test without credentials
curl -X POST "https://your-project.supabase.co/storage/v1/object/household-documents/test.pdf" \
  --data-binary @test.pdf
```

Expected: Forbidden (403) - Policy blocks unauthenticated uploads

### Test 3: Cross-Tenant Access Blocked

```bash
# Test with tenant A credentials accessing tenant B folder
curl -X POST "https://your-project.supabase.co/storage/v1/object/household-documents/{tenant_B_id}/test.pdf" \
  -H "Authorization: Bearer {tenant_A_jwt}" \
  --data-binary @test.pdf
```

Expected: Forbidden (403) - Policy blocks cross-tenant access

---

## File Path Structure

Each bucket uses tenant isolation via path structure:

### household-documents
```
{tenant_id}/{household_id}/{filename}
Example: 123e4567-e89b-12d3-a456-426614174000/household-1/id-card.pdf
```

### permit-attachments
```
{tenant_id}/{permit_id}/{filename}
Example: 123e4567-e89b-12d3-a456-426614174000/permit-42/blueprint.pdf
```

### announcement-files
```
{tenant_id}/{announcement_id}/{filename}
Example: 123e4567-e89b-12d3-a456-426614174000/announcement-5/notice.pdf
```

### receipt-archives
```
{tenant_id}/receipts/{payment_id}/{filename}
Example: 123e4567-e89b-12d3-a456-426614174000/receipts/payment-99/receipt.pdf
```

---

## RLS Policy Summary

### household-documents
- **INSERT**: Admins only (admin_head, admin_officer) for their tenant
- **SELECT**: Admins and household heads can view their own tenant's files
- **UPDATE**: Not allowed (immutable files)
- **DELETE**: Admins only for their tenant

### permit-attachments
- **INSERT**: Admins only for their tenant
- **SELECT**: Admins and household heads for their tenant
- **UPDATE**: Admins only (replace files if needed)
- **DELETE**: Admins only for their tenant

### announcement-files
- **INSERT**: Admins only for their tenant
- **SELECT**: All tenant users (admins, household heads)
- **UPDATE**: Admins only (replace files)
- **DELETE**: Admins only for their tenant

### receipt-archives
- **INSERT**: System generated (via admin actions)
- **SELECT**: Admins and household heads for their tenant
- **UPDATE**: NOT ALLOWED (immutable audit trail)
- **DELETE**: Admins only (if payment voided)

---

## Environment Variables

Ensure these are set in your admin app:

```env
# Admin App (.env.local)
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

---

## Troubleshooting

### Issue: "Policy error" when uploading

**Cause**: RLS policies not applied or user lacks required role

**Fix**:
1. Verify policies are applied in Supabase Dashboard
2. Check user JWT claims contain `tenant_id` and correct `app_role`
3. Verify path structure matches `{tenant_id}/...`

### Issue: "File size too large"

**Cause**: File exceeds bucket limit (10MB or 5MB)

**Fix**:
1. Reduce file size on client side
2. Implement compression for images
3. Or increase bucket limit in Supabase Dashboard

### Issue: "MIME type not allowed"

**Cause**: File type not in allowed list

**Fix**:
1. Check bucket configuration in Supabase Dashboard
2. Add missing MIME type to allowed list
3. Or validate file types on client side before upload

---

## Next Steps After Setup

1. ✅ Buckets created
2. ✅ Policies applied
3. ✅ Policies verified
4. ✅ File uploads tested
5. → Integrate file upload UI components in admin app
6. → Test end-to-end workflows (household documents, permit attachments)
7. → Monitor storage usage in Supabase Dashboard

---

## Security Checklist

- [ ] All buckets are private (public: false)
- [ ] RLS policies applied and tested
- [ ] Cross-tenant access blocked
- [ ] File size limits enforced
- [ ] MIME type restrictions in place
- [ ] Unauthenticated access blocked
- [ ] Path structure follows tenant isolation pattern

---

## References

- Storage policy files: `supabase/storage/*.sql`
- Production readiness: `docs/PRODUCTION_READINESS.md`
- Supabase Storage docs: https://supabase.com/docs/guides/storage
