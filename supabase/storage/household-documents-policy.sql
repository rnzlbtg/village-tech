-- Storage bucket and RLS policies for household documents
-- Bucket: household-documents
-- Purpose: Store household member documents (IDs, birth certificates, etc.)
-- Access: Tenant-scoped, admins can upload/view, household heads can view their own

-- Create bucket (run manually in Supabase Dashboard if not exists)
-- Bucket name: household-documents
-- Public: false
-- File size limit: 10 MB
-- Allowed MIME types: image/*, application/pdf

-- RLS Policies for household-documents bucket

-- Policy: Admins can upload documents for their tenant
CREATE POLICY "Admins can upload household documents"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'household-documents'
  AND (storage.foldername(name))[1] = (auth.jwt() ->> 'tenant_id')::TEXT
  AND (auth.jwt() ->> 'app_role')::TEXT IN ('admin_head', 'admin_officer')
);

-- Policy: Admins can view documents in their tenant
CREATE POLICY "Admins can view household documents"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'household-documents'
  AND (storage.foldername(name))[1] = (auth.jwt() ->> 'tenant_id')::TEXT
  AND (auth.jwt() ->> 'app_role')::TEXT IN ('admin_head', 'admin_officer')
);

-- Policy: Admins can update documents in their tenant
CREATE POLICY "Admins can update household documents"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'household-documents'
  AND (storage.foldername(name))[1] = (auth.jwt() ->> 'tenant_id')::TEXT
  AND (auth.jwt() ->> 'app_role')::TEXT IN ('admin_head', 'admin_officer')
);

-- Policy: Admins can delete documents in their tenant
CREATE POLICY "Admins can delete household documents"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'household-documents'
  AND (storage.foldername(name))[1] = (auth.jwt() ->> 'tenant_id')::TEXT
  AND (auth.jwt() ->> 'app_role')::TEXT IN ('admin_head', 'admin_officer')
);

-- Policy: Household heads can view their own household documents
CREATE POLICY "Household heads can view own documents"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'household-documents'
  AND (storage.foldername(name))[1] = (auth.jwt() ->> 'tenant_id')::TEXT
  AND (storage.foldername(name))[2] = (auth.jwt() ->> 'household_id')::TEXT
  AND (auth.jwt() ->> 'app_role')::TEXT = 'household_head'
);

-- Path structure: {tenant_id}/{household_id}/{filename}
-- Example: 123e4567-e89b-12d3-a456-426614174000/456e7890-e89b-12d3-a456-426614174001/birth_cert.pdf
