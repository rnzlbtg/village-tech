---
description: "Implementation tasks for Admin App - Residential Community Administration"
---

# Tasks: Admin App - Residential Community Administration

**Input**: Design documents from `/specs/002-admin-app-residential/`
**Prerequisites**: plan.md, spec.md, data-model.md, contracts/README.md, research.md, quickstart.md
**Architecture**: Next.js 14 App Router + Supabase PostgreSQL with RLS

**Tests**: Not explicitly requested - tests are OPTIONAL for this feature

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions
- **Next.js App**: `apps/admin/` (Next.js 14 App Router)
- **Supabase**: `supabase/migrations/` for SQL migrations
- **Storage**: `supabase/storage/` for bucket policies

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create Next.js 14 project at `apps/admin/` with TypeScript and App Router configuration
- [ ] T002 [P] Install core dependencies: next@14, react@18, typescript@5, @supabase/supabase-js@2.45+, zod@3.23+
- [ ] T003 [P] Install UI dependencies: shadcn/ui components, @tanstack/react-query@5, react-hook-form@7
- [ ] T004 [P] Install file handling: @react-pdf/renderer@4, axios@1.7+, react-dropzone@14
- [ ] T005 [P] Configure ESLint, Prettier, and TypeScript strict mode in `apps/admin/tsconfig.json`
- [ ] T006 [P] Setup environment configuration in `apps/admin/.env.local` template with Supabase keys
- [ ] T007 [P] Initialize shadcn/ui with components config at `apps/admin/components/ui/`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

### Database Schema & Migrations

- [ ] T008 Create migration `supabase/migrations/010_create_households.sql` for households and household_members tables with indexes
- [ ] T009 [P] Create migration `supabase/migrations/011_create_stickers.sql` for sticker_programs, sticker_requests tables with indexes
- [ ] T010 [P] Create migration `supabase/migrations/012_create_permits.sql` for construction_permits, permit_payments tables with indexes
- [ ] T011 [P] Create migration `supabase/migrations/013_create_announcements.sql` for announcements table with indexes
- [ ] T012 [P] Create migration `supabase/migrations/014_create_payment_logs.sql` for payment_logs, invoices tables with indexes and generated columns
- [ ] T013 [P] Create migration `supabase/migrations/015_create_elections.sql` for elections, election_candidates tables with indexes
- [ ] T014 Create migration `supabase/migrations/016_create_rls_policies.sql` for all tenant-scoped RLS policies (admins and household heads)
- [ ] T015 Create migration `supabase/migrations/017_create_database_functions.sql` for generate_receipt_number() and update_invoice_status() trigger functions

### Supabase Storage Configuration

- [ ] T016 [P] Create Storage bucket `household-documents` with RLS policies in `supabase/storage/household-documents-policy.sql`
- [ ] T017 [P] Create Storage bucket `permit-attachments` with RLS policies in `supabase/storage/permit-attachments-policy.sql`
- [ ] T018 [P] Create Storage bucket `announcement-files` with RLS policies in `supabase/storage/announcement-files-policy.sql`
- [ ] T019 [P] Create Storage bucket `receipt-archives` with RLS policies in `supabase/storage/receipt-archives-policy.sql`

### Authentication & Authorization

- [ ] T020 Create Supabase client utilities at `apps/admin/lib/supabase/server.ts` and `apps/admin/lib/supabase/client.ts`
- [ ] T021 [P] Create auth middleware at `apps/admin/middleware.ts` to verify admin role and tenant scope
- [ ] T022 [P] Create auth helper functions at `apps/admin/lib/auth/helpers.ts` (getTenantId, requireAdmin, getUserId)
- [ ] T023 Create login page at `apps/admin/app/(auth)/login/page.tsx` with Supabase Auth integration

### Shared UI Components

- [ ] T024 [P] Create shared layout component at `apps/admin/components/shared/AdminLayout.tsx` with sidebar navigation
- [ ] T025 [P] Create tenant header component at `apps/admin/components/shared/TenantHeader.tsx` showing tenant name and user info
- [ ] T026 [P] Create data table component at `apps/admin/components/shared/DataTable.tsx` with sorting, filtering, pagination
- [ ] T027 [P] Create form components at `apps/admin/components/shared/FormField.tsx` with React Hook Form integration
- [ ] T028 [P] Create status badge component at `apps/admin/components/shared/StatusBadge.tsx` for status visualization

### Validation Schemas

- [ ] T029 [P] Create validation schemas at `apps/admin/lib/validations/household.ts` for household operations (Zod)
- [ ] T030 [P] Create validation schemas at `apps/admin/lib/validations/stickers.ts` for sticker operations (Zod)
- [ ] T031 [P] Create validation schemas at `apps/admin/lib/validations/permits.ts` for permit operations (Zod)
- [ ] T032 [P] Create validation schemas at `apps/admin/lib/validations/announcements.ts` for announcement operations (Zod)
- [ ] T033 [P] Create validation schemas at `apps/admin/lib/validations/payments.ts` for payment operations (Zod)

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Setup Household and Household Head (Priority: P1) 🎯 MVP

**Goal**: Enable admin to create households, assign household heads with authentication credentials, and manage household information

**Independent Test**: Create a household for a residence unit, assign a household head with email/phone, verify household head receives login credentials and can authenticate

### Implementation for User Story 1

- [ ] T034 [P] [US1] Create Server Action at `apps/admin/lib/actions/household.ts` implementing createHousehold() with Supabase Auth user creation
- [ ] T035 [P] [US1] Create Server Action at `apps/admin/lib/actions/household.ts` implementing updateHousehold() for household info updates
- [ ] T036 [P] [US1] Create Server Action at `apps/admin/lib/actions/household.ts` implementing addHouseholdMember() for adding family members
- [ ] T037 [P] [US1] Create household list page at `apps/admin/app/(dashboard)/households/page.tsx` with DataTable showing all households
- [ ] T038 [P] [US1] Create household detail page at `apps/admin/app/(dashboard)/households/[id]/page.tsx` showing household info and members
- [ ] T039 [P] [US1] Create household form component at `apps/admin/components/households/HouseholdForm.tsx` with residence selection
- [ ] T040 [P] [US1] Create household head form component at `apps/admin/components/households/HouseholdHeadForm.tsx` with email/phone fields
- [ ] T041 [P] [US1] Create household member form component at `apps/admin/components/households/HouseholdMemberForm.tsx` with relationship dropdown
- [ ] T042 [US1] Add form validation and error handling for household creation with duplicate email checks
- [ ] T043 [US1] Add welcome email notification to household head with login credentials and app links

**Checkpoint**: At this point, User Story 1 should be fully functional - admin can create households and household heads can log in

---

## Phase 4: User Story 2 - Vehicle Sticker Management (Priority: P1) 🎯 MVP

**Goal**: Enable admin to manage vehicle sticker program including setting limits, receiving requests, approving requests, and tracking distribution

**Independent Test**: Set sticker allocation (2 per household), receive sticker request from household, approve request, record physical distribution with signature

### Implementation for User Story 2

- [ ] T044 [P] [US2] Create Server Action at `apps/admin/lib/actions/stickers.ts` implementing setStickerProgram() for configuring allocation limits
- [ ] T045 [P] [US2] Create Server Action at `apps/admin/lib/actions/stickers.ts` implementing approveStickerRequest() with allocation validation
- [ ] T046 [P] [US2] Create Server Action at `apps/admin/lib/actions/stickers.ts` implementing rejectStickerRequest() with rejection reason
- [ ] T047 [P] [US2] Create Server Action at `apps/admin/lib/actions/stickers.ts` implementing distributeStickerPhysical() with signature capture
- [ ] T048 [P] [US2] Create sticker requests list page at `apps/admin/app/(dashboard)/stickers/page.tsx` with pending/approved/distributed filters
- [ ] T049 [P] [US2] Create sticker program config page at `apps/admin/app/(dashboard)/stickers/program/page.tsx` for setting allocation limits
- [ ] T050 [P] [US2] Create sticker request detail modal at `apps/admin/components/stickers/StickerRequestDetail.tsx` with vehicle info and approval actions
- [ ] T051 [P] [US2] Create sticker distribution form at `apps/admin/components/stickers/StickerDistributionForm.tsx` with signature pad integration
- [ ] T052 [US2] Add allocation limit validation before approval (check household hasn't exceeded limit)
- [ ] T053 [US2] Add notification to household head when request is approved with pickup instructions
- [ ] T054 [US2] Add notification to household head when request is rejected with reason
- [ ] T055 [US2] Generate distribution receipt showing sticker code, vehicle plate, and signature

**Checkpoint**: At this point, User Story 2 should be fully functional - complete sticker lifecycle from allocation to distribution

---

## Phase 5: User Story 3 - Construction Permit Management (Priority: P2)

**Goal**: Enable admin to receive permit requests, compute road fees, collect payments, approve permits, send to guard house, and mark completion

**Independent Test**: Receive permit request, compute road fee based on project details, record payment, approve permit, verify guard house receives permit, mark project complete

### Implementation for User Story 3

- [ ] T056 [P] [US3] Create Server Action at `apps/admin/lib/actions/permits.ts` implementing computeRoadFee() based on project type and duration
- [ ] T057 [P] [US3] Create Server Action at `apps/admin/lib/actions/permits.ts` implementing approveConstructionPermit() with payment validation
- [ ] T058 [P] [US3] Create Server Action at `apps/admin/lib/actions/permits.ts` implementing rejectConstructionPermit() with rejection reason
- [ ] T059 [P] [US3] Create Server Action at `apps/admin/lib/actions/permits.ts` implementing markPermitComplete() to revoke worker access
- [ ] T060 [P] [US3] Create Server Action at `apps/admin/lib/actions/permits.ts` implementing holdPermit() for payment deadline violations
- [ ] T061 [P] [US3] Create permits list page at `apps/admin/app/(dashboard)/permits/page.tsx` with status filters (pending/approved/in_progress/completed)
- [ ] T062 [P] [US3] Create permit detail page at `apps/admin/app/(dashboard)/permits/[id]/page.tsx` showing project details, workers, and payment status
- [ ] T063 [P] [US3] Create permit approval form at `apps/admin/components/permits/PermitApprovalForm.tsx` with fee computation and worker authorization
- [ ] T064 [P] [US3] Create file upload component at `apps/admin/components/permits/PermitAttachments.tsx` for project drawings and documents
- [ ] T065 [US3] Add payment tracking integration linking permit_payments to payment_logs table
- [ ] T066 [US3] Add file upload route at `apps/admin/app/api/permits/upload/route.ts` with signed URL pattern for large files
- [ ] T067 [US3] Add notification to household head when permit is approved with worker access details
- [ ] T068 [US3] Add notification to guard house with permit reference, household, and authorized workers list
- [ ] T069 [US3] Add automatic hold status when payment deadline is exceeded
- [ ] T070 [US3] Generate permit reference number with format "PERM-YYYY-NNNNNN"

**Checkpoint**: At this point, User Story 3 should be fully functional - complete permit workflow from request to completion

---

## Phase 6: User Story 4 - Community Announcements (Priority: P2)

**Goal**: Enable admin to create and send announcements with file attachments to specific recipient groups (residents, guards, security)

**Independent Test**: Create announcement with title, content, and PDF attachment, select recipient groups (residents + guards), send announcement, verify recipients receive and can view in their apps

### Implementation for User Story 4

- [ ] T071 [P] [US4] Create Server Action at `apps/admin/lib/actions/announcements.ts` implementing createAnnouncement() with file upload integration
- [ ] T072 [P] [US4] Create Server Action at `apps/admin/lib/actions/announcements.ts` implementing editAnnouncement() for updating content
- [ ] T073 [P] [US4] Create Server Action at `apps/admin/lib/actions/announcements.ts` implementing deleteAnnouncement() with soft delete
- [ ] T074 [P] [US4] Create announcements list page at `apps/admin/app/(dashboard)/announcements/page.tsx` with priority and audience filters
- [ ] T075 [P] [US4] Create announcement form page at `apps/admin/app/(dashboard)/announcements/new/page.tsx` with rich text editor
- [ ] T076 [P] [US4] Create announcement form component at `apps/admin/components/announcements/AnnouncementForm.tsx` with audience checkboxes
- [ ] T077 [P] [US4] Create file upload component at `apps/admin/components/announcements/AnnouncementAttachments.tsx` with drag-drop support
- [ ] T078 [P] [US4] Create priority selector at `apps/admin/components/announcements/PrioritySelector.tsx` (normal/high/urgent)
- [ ] T079 [US4] Add file upload route at `apps/admin/app/api/announcements/upload/route.ts` with type validation (PDF, DOCX, images)
- [ ] T080 [US4] Add file size validation (10MB limit) and magic bytes verification
- [ ] T081 [US4] Add push notification sending for urgent announcements to all target audience users
- [ ] T082 [US4] Add expiration date handling to auto-hide expired announcements
- [ ] T083 [US4] Upload announcement files to Supabase Storage announcement-files bucket with tenant-scoped paths

**Checkpoint**: At this point, User Story 4 should be fully functional - announcements can be created and delivered to targeted audiences

---

## Phase 7: User Story 5 - Association Fee Collection (Priority: P3)

**Goal**: Enable admin to configure fee structures, generate bills, record payments, and issue receipts for association dues

**Independent Test**: Configure monthly association fee ($50), generate bills for all households, record cash payment from a household, issue PDF receipt

### Implementation for User Story 5

- [ ] T084 [P] [US5] Create Server Action at `apps/admin/lib/actions/fees.ts` implementing createFeeStructure() for configuring billing periods
- [ ] T085 [P] [US5] Create Server Action at `apps/admin/lib/actions/fees.ts` implementing generateInvoices() for creating bills based on fee schedule
- [ ] T086 [P] [US5] Create Server Action at `apps/admin/lib/actions/payments.ts` implementing recordPayment() with receipt generation
- [ ] T087 [P] [US5] Create Server Action at `apps/admin/lib/actions/payments.ts` implementing recordPartialPayment() with multiple invoice allocations
- [ ] T088 [P] [US5] Create Server Action at `apps/admin/lib/actions/payments.ts` implementing voidPayment() for corrections with notes
- [ ] T089 [P] [US5] Create fee structure page at `apps/admin/app/(dashboard)/fees/structure/page.tsx` for configuring fee types and amounts
- [ ] T090 [P] [US5] Create invoices list page at `apps/admin/app/(dashboard)/fees/invoices/page.tsx` with status filters (unpaid/partial/paid/overdue)
- [ ] T091 [P] [US5] Create payment recording page at `apps/admin/app/(dashboard)/fees/payments/page.tsx` with household selection
- [ ] T092 [P] [US5] Create payment form component at `apps/admin/components/fees/PaymentForm.tsx` with cash/check/bank transfer fields
- [ ] T093 [P] [US5] Create receipt template at `apps/admin/lib/pdf/PaymentReceipt.tsx` using @react-pdf/renderer components
- [ ] T094 [US5] Add auto-generation of invoice numbers with format "INV-YYYY-NNNNNN"
- [ ] T095 [US5] Add receipt number generation using database function generate_receipt_number()
- [ ] T096 [US5] Add PDF receipt generation and upload to Supabase Storage receipt-archives bucket
- [ ] T097 [US5] Add payment trigger to update invoice status (unpaid → partial → paid) automatically
- [ ] T098 [US5] Add overdue status auto-update for invoices past due date
- [ ] T099 [US5] Add payment history view showing all payments for a household

**Checkpoint**: At this point, User Story 5 should be fully functional - complete fee collection workflow with receipt generation

---

## Phase 8: User Story 6 - Village Rules and Curfew Management (Priority: P3)

**Goal**: Enable admin to set village rules, guidelines, and curfew times that are accessible to residents and security personnel

**Independent Test**: Create village rules document, set curfew time (10PM-5AM), publish to residents and guards, verify rules are accessible in respective apps

### Implementation for User Story 6

- [ ] T100 [P] [US6] Create Server Action at `apps/admin/lib/actions/rules.ts` implementing createVillageRules() with effective dates
- [ ] T101 [P] [US6] Create Server Action at `apps/admin/lib/actions/rules.ts` implementing updateVillageRules() for revisions
- [ ] T102 [P] [US6] Create Server Action at `apps/admin/lib/actions/rules.ts` implementing setCurfewTimes() for gate access restrictions
- [ ] T103 [P] [US6] Create Server Action at `apps/admin/lib/actions/rules.ts` implementing publishRules() to distribute to all user groups
- [ ] T104 [P] [US6] Create village rules page at `apps/admin/app/(dashboard)/rules/page.tsx` with rules editor and curfew configuration
- [ ] T105 [P] [US6] Create rules editor component at `apps/admin/components/rules/RulesEditor.tsx` with rich text editing
- [ ] T106 [P] [US6] Create curfew settings component at `apps/admin/components/rules/CurfewSettings.tsx` with time pickers
- [ ] T107 [US6] Add version tracking for rules with effective dates and change history
- [ ] T108 [US6] Add notification to all residents when new rules are published
- [ ] T109 [US6] Add notification to guard house when curfew times are updated
- [ ] T110 [US6] Create announcement linking rules publication to announcement system

**Checkpoint**: All user stories should now be independently functional

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T111 [P] Create dashboard home page at `apps/admin/app/(dashboard)/page.tsx` with key metrics (pending requests, recent payments, active permits)
- [ ] T112 [P] Add search functionality across households, permits, and payments at `apps/admin/components/shared/GlobalSearch.tsx`
- [ ] T113 [P] Add export functionality for payment reports (CSV/Excel) at `apps/admin/lib/exports/payments.ts`
- [ ] T114 [P] Add export functionality for household lists at `apps/admin/lib/exports/households.ts`
- [ ] T115 [P] Create audit log viewer at `apps/admin/app/(dashboard)/audit/page.tsx` showing all admin actions with timestamp and user
- [ ] T116 [P] Add loading states and skeleton screens for all data tables
- [ ] T117 [P] Add error boundaries for graceful error handling at `apps/admin/app/error.tsx`
- [ ] T118 [P] Add offline indicator and connection status at `apps/admin/components/shared/ConnectionStatus.tsx`
- [ ] T119 [P] Optimize images and assets with Next.js Image component
- [ ] T120 [P] Add accessibility improvements (ARIA labels, keyboard navigation, screen reader support)
- [ ] T121 Code cleanup and refactoring to remove duplicate code across Server Actions
- [ ] T122 Performance optimization: implement React Query caching strategies with stale-while-revalidate
- [ ] T123 Security hardening: add rate limiting for file uploads (10 per minute per user)
- [ ] T124 Security hardening: add CSRF protection for all Server Actions
- [ ] T125 Run quickstart.md validation to ensure all workflows function correctly

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-8)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Phase 9)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P1)**: Can start after Foundational (Phase 2) - References households but independently testable
- **User Story 3 (P2)**: Can start after Foundational (Phase 2) - References households and payments but independently testable
- **User Story 4 (P2)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 5 (P3)**: Can start after Foundational (Phase 2) - References households but independently testable
- **User Story 6 (P3)**: Can start after Foundational (Phase 2) - No dependencies on other stories

### Within Each User Story

- Server Actions before UI components (actions define the contracts)
- List pages before detail pages (overview before drill-down)
- Form components can be built in parallel with Server Actions
- File upload routes after form components
- Notifications and integrations after core functionality
- Validation and error handling after happy path implementation

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational database migrations marked [P] can run in parallel (T009-T013)
- All Foundational storage buckets marked [P] can run in parallel (T016-T019)
- All validation schemas marked [P] can run in parallel (T029-T033)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- Within each user story, tasks marked [P] can run in parallel:
  - US1: T034-T041 (Server Actions and UI components)
  - US2: T044-T051 (Server Actions and UI components)
  - US3: T056-T064 (Server Actions and UI components)
  - US4: T071-T078 (Server Actions and UI components)
  - US5: T084-T093 (Server Actions and UI components)
  - US6: T100-T106 (Server Actions and UI components)
- All Polish tasks marked [P] can run in parallel (T111-T120)

---

## Parallel Example: User Story 1

```bash
# Launch Server Actions in parallel:
Task: "Create Server Action createHousehold() at apps/admin/lib/actions/household.ts"
Task: "Create Server Action updateHousehold() at apps/admin/lib/actions/household.ts"
Task: "Create Server Action addHouseholdMember() at apps/admin/lib/actions/household.ts"

# Launch UI components in parallel:
Task: "Create household list page at apps/admin/app/(dashboard)/households/page.tsx"
Task: "Create household detail page at apps/admin/app/(dashboard)/households/[id]/page.tsx"
Task: "Create household form component at apps/admin/components/households/HouseholdForm.tsx"
```

---

## Implementation Strategy

### MVP First (User Stories 1 + 2 Only)

1. Complete Phase 1: Setup (T001-T007)
2. Complete Phase 2: Foundational (T008-T033) - CRITICAL - blocks all stories
3. Complete Phase 3: User Story 1 - Household Management (T034-T043)
4. Complete Phase 4: User Story 2 - Sticker Management (T044-T055)
5. **STOP and VALIDATE**: Test US1 and US2 independently
6. Deploy/demo if ready - this provides core admin functionality

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready (33 tasks)
2. Add User Story 1 → Test independently → Deploy/Demo (MVP - 10 tasks)
3. Add User Story 2 → Test independently → Deploy/Demo (12 tasks)
4. Add User Story 3 → Test independently → Deploy/Demo (15 tasks)
5. Add User Story 4 → Test independently → Deploy/Demo (13 tasks)
6. Add User Story 5 → Test independently → Deploy/Demo (16 tasks)
7. Add User Story 6 → Test independently → Deploy/Demo (11 tasks)
8. Complete Polish phase → Final release (15 tasks)

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together (Tasks T001-T033)
2. Once Foundational is done:
   - Developer A: User Story 1 (Household Management)
   - Developer B: User Story 2 (Sticker Management)
   - Developer C: User Story 4 (Announcements - no dependencies)
3. Next iteration:
   - Developer A: User Story 3 (Construction Permits)
   - Developer B: User Story 5 (Fee Collection)
   - Developer C: User Story 6 (Rules Management)
4. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Server Actions use Zod validation schemas defined in Phase 2
- File uploads use Supabase Storage with signed URLs for large files
- Receipt generation uses @react-pdf/renderer on client side
- All database operations are tenant-scoped via RLS policies
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence

---

## Task Summary

- **Total Tasks**: 125 tasks
- **Phase 1 (Setup)**: 7 tasks
- **Phase 2 (Foundational)**: 26 tasks (BLOCKING)
- **Phase 3 (US1 - Households)**: 10 tasks
- **Phase 4 (US2 - Stickers)**: 12 tasks
- **Phase 5 (US3 - Permits)**: 15 tasks
- **Phase 6 (US4 - Announcements)**: 13 tasks
- **Phase 7 (US5 - Fees)**: 16 tasks
- **Phase 8 (US6 - Rules)**: 11 tasks
- **Phase 9 (Polish)**: 15 tasks
- **Parallelizable Tasks**: 67 tasks marked [P]
- **Suggested MVP Scope**: Phases 1-4 (US1 + US2) = 55 tasks
