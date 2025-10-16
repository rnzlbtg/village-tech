-- Storage bucket and RLS policies for payment receipts
-- Bucket: receipt-archives
-- Purpose: Store PDF payment receipts for permanent archival
-- Access: Tenant-scoped, admins can manage, household heads can view their own receipts

-- Create bucket (run manually in Supabase Dashboard if not exists)
-- Bucket name: receipt-archives
-- Public: false
-- File size limit: 5 MB
-- Allowed MIME types: application/pdf

-- RLS Policies for receipt-archives bucket

-- Policy: Admins can upload receipts for their tenant
CREATE POLICY "Admins can upload receipts"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'receipt-archives'
  AND (storage.foldername(name))[1] = (auth.jwt() ->> 'tenant_id')::TEXT
  AND (auth.jwt() ->> 'app_role')::TEXT IN ('admin_head', 'admin_officer')
);

-- Policy: Admins can view receipts in their tenant
CREATE POLICY "Admins can view receipts"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'receipt-archives'
  AND (storage.foldername(name))[1] = (auth.jwt() ->> 'tenant_id')::TEXT
  AND (auth.jwt() ->> 'app_role')::TEXT IN ('admin_head', 'admin_officer')
);

-- Policy: Receipts are immutable (no updates allowed)
-- Receipts should never be updated to maintain audit trail integrity

-- Policy: Admins can delete receipts only if payment is voided
CREATE POLICY "Admins can delete voided receipts"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'receipt-archives'
  AND (storage.foldername(name))[1] = (auth.jwt() ->> 'tenant_id')::TEXT
  AND (auth.jwt() ->> 'app_role')::TEXT IN ('admin_head', 'admin_officer')
  AND EXISTS (
    SELECT 1 FROM payment_logs
    WHERE payment_logs.receipt_number = REPLACE((storage.foldername(name))[2], '.pdf', '')
    AND payment_logs.voided_at IS NOT NULL
  )
);

-- Policy: Household heads can view their own receipts
CREATE POLICY "Household heads can view own receipts"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'receipt-archives'
  AND (storage.foldername(name))[1] = (auth.jwt() ->> 'tenant_id')::TEXT
  AND EXISTS (
    SELECT 1 FROM payment_logs
    WHERE payment_logs.receipt_number = REPLACE((storage.foldername(name))[2], '.pdf', '')
    AND payment_logs.household_id = (auth.jwt() ->> 'household_id')::UUID
  )
  AND (auth.jwt() ->> 'app_role')::TEXT = 'household_head'
);

-- Path structure: {tenant_id}/{receipt_number}.pdf
-- Example: 123e4567-e89b-12d3-a456-426614174000/RCP-2025-00001.pdf
