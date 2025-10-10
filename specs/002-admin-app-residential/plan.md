# Implementation Plan: Admin App - Residential Community Administration

**Branch**: `002-admin-app-residential` | **Date**: 2025-10-10 | **Spec**: [spec.md](spec.md)

## Summary

Web application for tenant admin officers to manage daily community operations including household setup, vehicle sticker distribution, construction permit processing, community announcements, association fee collection, and homeowner association elections. The system must integrate with existing tenant configuration from Platform App, support multi-role access (admin head vs officers), and enable efficient day-to-day administrative workflows.

## Technical Context

**Language/Version**: TypeScript 5.0+ / Node.js 20 LTS, React 18+ / TypeScript 5.0+
**Primary Dependencies**: Next.js 14, Supabase, shadcn/ui, TanStack Query, React Hook Form
**Storage**: Supabase PostgreSQL with RLS (tenant-scoped access)
**Testing**: Vitest, Playwright, React Testing Library
**Target Platform**: Web (responsive, desktop and tablet optimized)
**Project Type**: Web application (Next.js + Supabase)
**Performance Goals**: <3s page load, <1s form submission, support 100+ concurrent admin users per tenant
**Constraints**: Tenant-scoped data access (RLS), offline receipt printing, file upload for announcements/permits
**Scale/Scope**: Per-tenant deployment, 50-500 households per tenant, ~15-20 screens

## Constitution Check

### Specification-Driven Workflow (NON-NEGOTIABLE)
- ✅ PASS: Feature spec exists with 6 user stories
- ✅ PASS: Functional requirements FR-001 through FR-030
- ✅ PASS: Success criteria SC-001 through SC-006

### Architecture
- ✅ PASS: Next.js frontend + Supabase backend
- ⚠️ RESEARCH NEEDED: File upload strategy for announcements/permits
- ⚠️ RESEARCH NEEDED: Receipt generation and printing (PDF generation)
- ⚠️ RESEARCH NEEDED: Payment tracking integration patterns

### Security
- ✅ PASS: Tenant-scoped RLS policies
- ✅ PASS: Role-based access (admin_head vs admin_officer)
- ⚠️ RESEARCH NEEDED: Document storage security (Supabase Storage)

**Gate Status**: ✅ CONDITIONALLY APPROVED - Proceed to research

---

## Research Summary

**File Upload Strategy**: Supabase Storage with RLS policies, 10MB file limit, allowed types: PDF, DOCX, XLSX, images

**Receipt Generation**: react-pdf for browser-based PDF generation, fallback to Supabase Edge Function for server-side generation

**Payment Tracking**: JSON log in database with payment_logs table, no payment gateway integration (cash/check tracking only for MVP)

**Document Security**: Supabase Storage RLS policies scoped by tenant_id, signed URLs with 1-hour expiration

---

## Project Structure

```
apps/admin/                                 # Next.js admin web app
├── app/
│   ├── (auth)/login/
│   ├── (dashboard)/
│   │   ├── households/                     # Household management
│   │   ├── stickers/                       # Vehicle sticker program
│   │   ├── permits/                        # Construction permits
│   │   ├── announcements/                  # Community announcements
│   │   ├── fees/                           # Association fees
│   │   ├── elections/                      # HOA elections
│   │   └── dashboard/
│   └── api/
│       └── receipts/                       # PDF generation
├── components/
│   ├── ui/                                 # shadcn/ui
│   ├── households/
│   ├── stickers/
│   ├── permits/
│   └── shared/
├── lib/
│   ├── supabase/
│   ├── actions/                            # Server Actions
│   ├── pdf/                                # Receipt generation
│   └── validations/
└── tests/

supabase/
├── migrations/
│   ├── 010_create_households.sql
│   ├── 011_create_stickers.sql
│   ├── 012_create_permits.sql
│   ├── 013_create_announcements.sql
│   └── 014_create_payment_logs.sql
└── storage/
    ├── household-documents/
    ├── permit-attachments/
    └── announcement-files/
```

**Structure Decision**: Next.js 14 App Router following same patterns as Platform App, with tenant-scoped RLS for all data access.

---

## Key Entities (Data Model Summary)

1. **households** - Residence assignment with household_head_id
2. **sticker_programs** - Tenant sticker allocation rules
3. **sticker_requests** - Household sticker requests
4. **rfid_stickers** - Physical sticker registry (shared with Sentinel)
5. **construction_permits** - Permit applications and approvals
6. **permit_payments** - Payment tracking for permits
7. **announcements** - Community announcements
8. **payment_logs** - Association fee payment records
9. **elections** - HOA election management
10. **election_candidates** - Candidate registry

---

## Constitution Re-check (Post-Design)

**Status**: ✅ FULLY APPROVED

- ✅ File upload strategy defined (Supabase Storage)
- ✅ Receipt generation defined (react-pdf)
- ✅ Payment tracking defined (payment_logs table)
- ✅ Document security defined (Storage RLS)
- ✅ All design artifacts complete

**Next Step**: Generate tasks.md via `/speckit.tasks`

---

**Artifacts Generated**:
- ✅ plan.md (this file)
- ✅ [research.md](./research.md) - File uploads, PDF generation, payment tracking, document security
- ✅ [data-model.md](./data-model.md) - 11 entities with RLS policies and state transitions
- ✅ [contracts/README.md](./contracts/README.md) - Server Action contracts and authorization matrix
- ✅ [quickstart.md](./quickstart.md) - Developer setup guide with key workflows

**Status**: ✅ Phase 0 and Phase 1 complete - Ready for `/speckit.tasks`
