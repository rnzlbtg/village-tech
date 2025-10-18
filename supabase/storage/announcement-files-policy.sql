-- Storage bucket and RLS policies for announcement attachments
-- Bucket: announcement-files
-- Purpose: Store announcement attachments (PDFs, images, documents)
-- Access: Tenant-scoped, admins can manage, all authenticated users in tenant can view

-- Create bucket (run manually in Supabase Dashboard if not exists)
-- Bucket name: announcement-files
-- Public: false
-- File size limit: 10 MB
-- Allowed MIME types: image/*, application/pdf, application/msword, application/vnd.openxmlformats-officedocument.wordprocessingml.document

-- RLS Policies for announcement-files bucket

-- Policy: Admins can upload announcement files for their tenant
CREATE POLICY "Admins can upload announcement files"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'announcement-files'
  AND (storage.foldername(name))[1] = (auth.jwt() ->> 'tenant_id')::TEXT
  AND (auth.jwt() ->> 'app_role')::TEXT IN ('admin_head', 'admin_officer')
);

-- Policy: Admins can view announcement files in their tenant
CREATE POLICY "Admins can view announcement files"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'announcement-files'
  AND (storage.foldername(name))[1] = (auth.jwt() ->> 'tenant_id')::TEXT
  AND (auth.jwt() ->> 'app_role')::TEXT IN ('admin_head', 'admin_officer')
);

-- Policy: Admins can update announcement files in their tenant
CREATE POLICY "Admins can update announcement files"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'announcement-files'
  AND (storage.foldername(name))[1] = (auth.jwt() ->> 'tenant_id')::TEXT
  AND (auth.jwt() ->> 'app_role')::TEXT IN ('admin_head', 'admin_officer')
);

-- Policy: Admins can delete announcement files in their tenant
CREATE POLICY "Admins can delete announcement files"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'announcement-files'
  AND (storage.foldername(name))[1] = (auth.jwt() ->> 'tenant_id')::TEXT
  AND (auth.jwt() ->> 'app_role')::TEXT IN ('admin_head', 'admin_officer')
);

-- Policy: All authenticated users in tenant can view announcement files
CREATE POLICY "Tenant users can view announcement files"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'announcement-files'
  AND (storage.foldername(name))[1] = (auth.jwt() ->> 'tenant_id')::TEXT
);

-- Path structure: {tenant_id}/{announcement_id}/{timestamp}-{filename}
-- Example: 123e4567-e89b-12d3-a456-426614174000/012e3456-e89b-12d3-a456-426614174003/1704067200-notice.pdf
