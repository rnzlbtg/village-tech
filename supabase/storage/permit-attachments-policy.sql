-- Storage bucket and RLS policies for construction permit attachments
-- Bucket: permit-attachments
-- Purpose: Store permit-related documents (plans, approvals, photos)
-- Access: Tenant-scoped, admins can manage, household heads can view their own permits

-- Create bucket (run manually in Supabase Dashboard if not exists)
-- Bucket name: permit-attachments
-- Public: false
-- File size limit: 10 MB
-- Allowed MIME types: image/*, application/pdf, application/msword, application/vnd.openxmlformats-officedocument.wordprocessingml.document

-- RLS Policies for permit-attachments bucket

-- Policy: Admins can upload permit attachments for their tenant
CREATE POLICY "Admins can upload permit attachments"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'permit-attachments'
  AND (storage.foldername(name))[1] = (auth.jwt() ->> 'tenant_id')::TEXT
  AND (auth.jwt() ->> 'app_role')::TEXT IN ('admin_head', 'admin_officer')
);

-- Policy: Admins can view permit attachments in their tenant
CREATE POLICY "Admins can view permit attachments"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'permit-attachments'
  AND (storage.foldername(name))[1] = (auth.jwt() ->> 'tenant_id')::TEXT
  AND (auth.jwt() ->> 'app_role')::TEXT IN ('admin_head', 'admin_officer')
);

-- Policy: Admins can update permit attachments in their tenant
CREATE POLICY "Admins can update permit attachments"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'permit-attachments'
  AND (storage.foldername(name))[1] = (auth.jwt() ->> 'tenant_id')::TEXT
  AND (auth.jwt() ->> 'app_role')::TEXT IN ('admin_head', 'admin_officer')
);

-- Policy: Admins can delete permit attachments in their tenant
CREATE POLICY "Admins can delete permit attachments"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'permit-attachments'
  AND (storage.foldername(name))[1] = (auth.jwt() ->> 'tenant_id')::TEXT
  AND (auth.jwt() ->> 'app_role')::TEXT IN ('admin_head', 'admin_officer')
);

-- Policy: Household heads can view attachments for their own permits
CREATE POLICY "Household heads can view own permit attachments"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'permit-attachments'
  AND (storage.foldername(name))[1] = (auth.jwt() ->> 'tenant_id')::TEXT
  AND EXISTS (
    SELECT 1 FROM construction_permits
    WHERE construction_permits.id = (storage.foldername(name))[2]::UUID
    AND construction_permits.household_id = (auth.jwt() ->> 'household_id')::UUID
  )
  AND (auth.jwt() ->> 'app_role')::TEXT = 'household_head'
);

-- Path structure: {tenant_id}/{permit_id}/{timestamp}-{filename}
-- Example: 123e4567-e89b-12d3-a456-426614174000/789e0123-e89b-12d3-a456-426614174002/1704067200-floor_plan.pdf
