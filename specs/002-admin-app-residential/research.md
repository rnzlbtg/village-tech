# Research Findings: Admin App - Residential Community Administration

**Date**: 2025-10-10
**Feature**: Admin App - Residential Community Administration
**Purpose**: Resolve technical unknowns and establish implementation patterns

---

## 1. File Upload Strategy for Announcements and Permits

### Decision
Use **Supabase Storage with client-side uploads via signed URLs** for files >1MB, and direct server-side uploads for smaller files.

### Rationale
- Next.js Server Actions have default 1MB body size limit
- Signed URL pattern allows secure file uploads directly from client to Supabase
- Supabase Storage integrates seamlessly with PostgreSQL RLS for tenant-scoped access
- Default 50MB file size limit is sufficient for documents and images

### Implementation Pattern
```
Small Files (<1MB): Direct Server Action upload
Large Files (>1MB): Signed URL pattern
  1. Server Action generates signed upload URL
  2. Client uploads directly to Supabase Storage
  3. Server Action records metadata in database

Progress Tracking: Axios for upload progress
File Validation: Server-side validation of type and size
```

### Key Packages
- `@supabase/supabase-js` (v2.45+) - Storage client
- `axios` (v1.7+) - Upload progress tracking
- `react-dropzone` (v14+) - File selection UI (optional)

### Recommended Limits and Types
**File Size Limits:**
- Documents (PDF, DOCX, XLSX): 10MB max
- Images (JPEG, PNG): 5MB max

**Allowed Types:**
- Announcements: PDF, DOCX, JPEG, PNG
- Permits: PDF, XLSX, JPEG, PNG, ZIP

### Security/Performance Considerations
- Always validate file types on client AND server
- Use signed URLs with 2-hour expiration for uploads
- Store files in tenant-scoped folders: `{tenant_id}/{category}/{timestamp}-{filename}`
- Verify file signatures (magic bytes), don't trust MIME types
- Rate limiting: max 10 uploads per minute per user
- Add virus scanning for production (ClamAV)

---

## 2. Receipt Generation and PDF Printing

### Decision
Use **@react-pdf/renderer for client-side browser-based PDF generation** with component-based templates, with optional Supabase Edge Function fallback.

### Rationale
- React-native component-based architecture, familiar to Next.js developers
- Client-side generation reduces server load
- Template-based approach makes receipts easy to maintain
- Browser-based generation works offline for printing
- Edge Functions available for complex PDFs or server-side archival

### Implementation Pattern
```
Client-Side Generation:
1. Create PDF template with @react-pdf/renderer components
2. Generate PDF blob in browser
3. Download or print directly from browser

Print-Friendly:
- Use proper print media queries
- A4 page size optimization
- Include barcodes/QR codes for verification

Offline Support:
- Service Worker caching
- IndexedDB for offline receipt storage
```

### Key Packages
- `@react-pdf/renderer` (v4.0+) - React-based PDF generation
- `jspdf` (v2.5+) - Lightweight alternative
- `jsbarcode` (v3.11+) - Generate barcodes
- `qrcode.react` (v4.0+) - QR codes

### Alternatives Considered
- **jsPDF**: Lighter but imperative API (harder to maintain)
- **pdfmake**: Good for complex layouts, larger bundle
- **Puppeteer** (server-side): High quality but heavy and slow

### Security/Performance Considerations
- Generate receipt numbers server-side
- Include digital signature or hash for verification
- Bundle size: @react-pdf/renderer ~500KB (gzipped)
- Performance: ~200-500ms for simple receipt
- Use dynamic imports to reduce initial bundle size

---

## 3. Payment Tracking Patterns (No Gateway Integration)

### Decision
Use **event-sourced payment logging** with dedicated payment_logs table, supporting cash/check tracking, partial payments, and comprehensive audit trail.

### Rationale
- No payment gateway needed for MVP
- Event-sourcing provides complete audit trail
- Supports partial payments and mixed payment methods
- Separate logs table allows tracking without modifying invoices
- Enables robust reporting and reconciliation

### Implementation Pattern
```
Database Schema:
- payment_logs: Event-sourced payment records
- payment_allocations: Link payments to multiple invoices
- invoices: Track total, paid, and due amounts with generated column

Payment Flow:
1. Admin records payment (cash/check/bank transfer)
2. Generate unique receipt number
3. Insert payment log
4. Create allocations if partial payment
5. Update invoice(s) paid amount and status
6. Trigger auto-generates receipt PDF

Payment Status: unpaid → partial → paid → overdue
```

### Key Database Tables
```sql
payment_logs:
  - receipt_number (unique)
  - amount, payment_method, payment_date
  - check_number, check_bank (nullable)
  - status: pending, completed, voided

payment_allocations:
  - payment_log_id, invoice_id
  - allocated_amount

invoices:
  - total_amount, amount_paid
  - amount_due (generated column)
  - status: unpaid, partial, paid, overdue
```

### Security/Performance Considerations
- Generate receipt numbers server-side
- Log all payment modifications in audit table
- RLS policies scoped to tenant_id
- Prevent payment deletion (soft delete via status='voided')
- Index payment_date for fast date-range queries
- Use materialized views for complex reports

---

## 4. Document Storage Security

### Decision
Use **Supabase Storage with multi-layered RLS policies** for tenant-scoped access, signed URLs with 1-hour expiration, and separate buckets per document type.

### Rationale
- Supabase Storage integrates with PostgreSQL RLS
- Tenant-scoped folder structure prevents cross-tenant leakage
- Signed URLs provide time-limited access
- Separate buckets enable different security policies per type
- File metadata in PostgreSQL enables search and indexing

### Implementation Pattern
```
Bucket Structure:
- announcement-files: Public to tenant residents
- permit-attachments: Private to admins and applicant
- household-documents: Private to admins and household
- receipt-archives: Private to admins and payer

File Path Structure:
{tenant_id}/{category}/{timestamp}-{filename}

RLS Policies:
- Admins: Upload and view all tenant files
- Households: View only their own files
- Residents: View announcements only

Signed URLs:
- 1-hour expiration for downloads
- 2-hour expiration for uploads
- Cached client-side for 30 minutes
```

### Key Features
- Full-text search on file metadata (PostgreSQL tsvector)
- Tag-based search
- File access audit logging
- Automatic CDN distribution
- Thumbnail generation for images

### Security/Performance Considerations
- Never expose storage keys client-side
- Validate file signatures (magic bytes)
- Implement virus scanning for production
- Rate limit: max 10 uploads/minute per user
- CDN Integration: Automatic with Supabase
- Cache signed URLs client-side (30 min)
- Lazy load file lists, paginate results

---

## Summary & Recommendations

### Technology Stack
- **File Uploads**: Supabase Storage with signed URLs
- **Receipt Generation**: @react-pdf/renderer (client-side)
- **Payment Tracking**: event-sourced payment_logs table
- **Document Security**: Supabase Storage RLS + signed URLs

### Implementation Priority
1. File upload with Supabase Storage
2. Receipt generation with @react-pdf/renderer
3. Payment logging with event-sourcing
4. Document security with RLS policies

### Integration Points
All systems integrate seamlessly:
- Payments generate receipts (PDF) stored in Supabase Storage
- Permit attachments uploaded to Storage with RLS
- File metadata indexed in PostgreSQL for search
- All operations audited in database

---

**Research Completed**: 2025-10-10
**Next Phase**: Phase 1 - Design & Contracts
