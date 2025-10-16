# Tasks: Platform App - Multi-Tenant Management System

**Input**: Design documents from `/specs/001-platform-app-multi/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/
**Branch**: `001-platform-app-multi`

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [X] T001 Create Next.js project structure at `apps/platform/` with App Router configuration
- [X] T002 Initialize TypeScript project with dependencies: Next.js 14, React 18, TypeScript 5.0+
- [X] T003 [P] Configure ESLint and Prettier for code quality
- [X] T004 [P] Install Supabase client dependencies: @supabase/supabase-js, @supabase/ssr
- [X] T005 [P] Install UI dependencies: shadcn/ui components, Tailwind CSS, Radix UI primitives
- [X] T006 [P] Install validation and utility libraries: Zod, TanStack Query, date-fns
- [X] T007 Configure Tailwind CSS in `apps/platform/tailwind.config.ts`
- [X] T008 Setup environment variables structure in `apps/platform/.env.local.example`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

### Database Infrastructure

- [X] T009 Create tenants table migration in `supabase/migrations/001_create_tenants.sql`
- [X] T010 [P] Create properties table migration in `supabase/migrations/002_create_properties.sql`
- [X] T011 [P] Create residence_units table migration in `supabase/migrations/003_create_residence_units.sql`
- [X] T012 [P] Create gates table migration in `supabase/migrations/004_create_gates.sql`
- [X] T013 [P] Create admin_users table migration in `supabase/migrations/005_create_admin_users.sql`
- [X] T014 [P] Create association_settings table migration in `supabase/migrations/006_create_association_settings.sql`
- [X] T015 Create audit_logs table with monthly partitioning in `supabase/migrations/007_create_audit_logs.sql`
- [X] T016 Create database indexes for all tables in `supabase/migrations/008_create_indexes.sql`
- [X] T017 Implement audit log triggers for all tenant-scoped tables in `supabase/migrations/009_create_audit_triggers.sql`

### Authentication & Authorization

- [X] T018 Create user_roles table for role management in `supabase/migrations/010_create_user_roles.sql`
- [X] T019 Implement Custom Access Token Hook function in `supabase/migrations/011_custom_access_token_hook.sql`
- [X] T020 Configure RLS policies for tenants table in `supabase/migrations/012_rls_tenants.sql`
- [X] T021 [P] Configure RLS policies for properties table in `supabase/migrations/013_rls_properties.sql`
- [X] T022 [P] Configure RLS policies for residence_units table in `supabase/migrations/014_rls_residence_units.sql`
- [X] T023 [P] Configure RLS policies for gates table in `supabase/migrations/015_rls_gates.sql`
- [X] T024 [P] Configure RLS policies for admin_users table in `supabase/migrations/016_rls_admin_users.sql`
- [X] T025 [P] Configure RLS policies for association_settings table in `supabase/migrations/017_rls_association_settings.sql`
- [X] T026 Configure RLS policies for audit_logs table in `supabase/migrations/018_rls_audit_logs.sql`

### Application Infrastructure

- [X] T027 Create Supabase browser client in `apps/platform/lib/supabase/client.ts`
- [X] T028 Create Supabase server client in `apps/platform/lib/supabase/server.ts`
- [X] T029 Create Next.js middleware for auth protection in `apps/platform/middleware.ts`
- [X] T030 Generate TypeScript types from Supabase schema in `packages/database-types/`
- [X] T031 Create base layout with auth check in `apps/platform/app/layout.tsx`
- [X] T032 [P] Create auth layout in `apps/platform/app/(auth)/layout.tsx`
- [X] T033 [P] Create dashboard layout with navigation in `apps/platform/app/(dashboard)/layout.tsx`
- [X] T034 Create login page in `apps/platform/app/(auth)/login/page.tsx`
- [X] T035 Implement auth helper utilities in `apps/platform/lib/auth/helpers.ts`
- [X] T036 [P] Initialize shadcn/ui components: Button, Form, Input, Card, Table in `apps/platform/components/ui/`
- [X] T037 Create error boundary component in `apps/platform/components/shared/error-boundary.tsx`
- [X] T038 Create loading states component in `apps/platform/components/shared/loading.tsx`

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Create New Tenant (Priority: P1) 🎯 MVP

**Goal**: Enable platform super administrators to onboard new residential communities by creating tenants with basic information

**Independent Test**: Create a tenant with required information (name, address, contact details), verify tenant appears in system and is accessible

### Implementation for User Story 1

- [X] T039 [P] [US1] Create Zod validation schema for tenant in `apps/platform/lib/validations/tenant.ts`
- [X] T040 [P] [US1] Create tenant type definitions in `apps/platform/lib/types/tenant.ts`
- [X] T041 [US1] Implement createTenant Server Action in `apps/platform/lib/actions/tenant.ts`
- [X] T042 [US1] Implement updateTenant Server Action in `apps/platform/lib/actions/tenant.ts`
- [X] T043 [US1] Implement deleteTenant Server Action in `apps/platform/lib/actions/tenant.ts`
- [X] T044 [P] [US1] Create TenantForm component in `apps/platform/components/tenants/tenant-form.tsx`
- [X] T045 [P] [US1] Create TenantCard component in `apps/platform/components/tenants/tenant-card.tsx`
- [X] T046 [P] [US1] Create TenantList component in `apps/platform/components/tenants/tenant-list.tsx`
- [X] T047 [US1] Create tenant list page in `apps/platform/app/(dashboard)/tenants/page.tsx`
- [X] T048 [US1] Create new tenant page in `apps/platform/app/(dashboard)/tenants/new/page.tsx`
- [X] T049 [US1] Create tenant detail page in `apps/platform/app/(dashboard)/tenants/[id]/page.tsx`
- [X] T050 [US1] Add validation error handling and user feedback for tenant operations
- [X] T051 [US1] Implement duplicate tenant name prevention logic
- [X] T052 [US1] Add audit logging verification for tenant creation/updates

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - Configure Properties and Residences (Priority: P1) 🎯 MVP

**Goal**: Enable platform administrators to define physical structure of residential communities including properties and residence units

**Independent Test**: Define properties within a tenant, add residence units with identifiers, verify structure is saved and retrievable

### Implementation for User Story 2

- [X] T053 [P] [US2] Create Zod validation schema for property in `apps/platform/lib/validations/property.ts`
- [X] T054 [P] [US2] Create Zod validation schema for residence unit in `apps/platform/lib/validations/residence-unit.ts`
- [X] T055 [P] [US2] Create property type definitions in `apps/platform/lib/types/property.ts`
- [X] T056 [P] [US2] Create residence unit type definitions in `apps/platform/lib/types/residence-unit.ts`
- [X] T057 [US2] Implement createProperty Server Action in `apps/platform/lib/actions/property.ts`
- [X] T058 [US2] Implement updateProperty Server Action in `apps/platform/lib/actions/property.ts`
- [X] T059 [US2] Implement deleteProperty Server Action in `apps/platform/lib/actions/property.ts`
- [X] T060 [US2] Implement createResidenceUnit Server Action in `apps/platform/lib/actions/residence-unit.ts`
- [X] T061 [US2] Implement updateResidenceUnit Server Action in `apps/platform/lib/actions/residence-unit.ts`
- [X] T062 [US2] Implement deleteResidenceUnit Server Action in `apps/platform/lib/actions/residence-unit.ts`
- [X] T063 [P] [US2] Create PropertyForm component in `apps/platform/components/properties/property-form.tsx`
- [X] T064 [P] [US2] Create PropertyCard component in `apps/platform/components/properties/property-card.tsx`
- [X] T065 [P] [US2] Create PropertyList component in `apps/platform/components/properties/property-list.tsx`
- [X] T066 [P] [US2] Create ResidenceUnitForm component in `apps/platform/components/properties/residence-unit-form.tsx`
- [X] T067 [P] [US2] Create ResidenceUnitTable component in `apps/platform/components/properties/residence-unit-table.tsx`
- [X] T068 [US2] Create properties list page in `apps/platform/app/(dashboard)/tenants/[id]/properties/page.tsx`
- [X] T069 [US2] Create property detail page in `apps/platform/app/(dashboard)/tenants/[id]/properties/[propertyId]/page.tsx`
- [X] T070 [US2] Implement duplicate unit number validation within same property
- [X] T071 [US2] Add property summary with residence count display
- [X] T072 [US2] Implement bulk import CSV/Excel parsing logic using PapaParse in `apps/platform/lib/utils/csv-parser.ts`
- [X] T073 [US2] Create bulk import API route in `apps/platform/app/api/bulk-import/route.ts`
- [X] T074 [US2] Create BulkImportDialog component in `apps/platform/components/properties/bulk-import-dialog.tsx`
- [X] T075 [US2] Implement batched database insert logic (1,000 rows per batch) in bulk import
- [X] T076 [US2] Add transaction rollback handling for bulk import errors
- [X] T077 [US2] Add progress indicator for bulk import operations

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - Configure Gate Entrances (Priority: P2)

**Goal**: Enable platform administrators to define physical gates and entrance points with equipment configuration

**Independent Test**: Create gate entries with names, locations, and equipment settings, verify gates appear and are associated with correct tenant

### Implementation for User Story 3

- [X] T078 [P] [US3] Create Zod validation schema for gate in `apps/platform/lib/validations/gate.ts`
- [X] T079 [P] [US3] Create gate type definitions in `apps/platform/lib/types/gate.ts`
- [X] T080 [US3] Implement createGate Server Action in `apps/platform/lib/actions/gate.ts`
- [X] T081 [US3] Implement updateGate Server Action in `apps/platform/lib/actions/gate.ts`
- [X] T082 [US3] Implement deleteGate Server Action in `apps/platform/lib/actions/gate.ts`
- [X] T083 [P] [US3] Create GateForm component with equipment config in `apps/platform/components/gates/gate-form.tsx`
- [X] T084 [P] [US3] Create GateCard component with status indicator in `apps/platform/components/gates/gate-card.tsx`
- [X] T085 [P] [US3] Create GateList component in `apps/platform/components/gates/gate-list.tsx`
- [X] T086 [US3] Create gates list page in `apps/platform/app/(dashboard)/tenants/[id]/gates/page.tsx`
- [X] T087 [US3] Create gate detail page in `apps/platform/app/(dashboard)/tenants/[id]/gates/[gateId]/page.tsx`
- [X] T088 [US3] Implement RFID equipment configuration UI with JSON editor
- [X] T089 [US3] Add gate operational status management (active/maintenance/inactive)
- [X] T090 [US3] Display gate list with status and equipment information

**Checkpoint**: User Stories 1, 2, AND 3 should all work independently

---

## Phase 6: User Story 4 - Create Initial Admin Users (Priority: P2)

**Goal**: Enable platform administrators to create administrative users (admin head and officers) for tenant management

**Independent Test**: Create admin head and officer users, verify they can log in and have appropriate access to assigned tenant

### Implementation for User Story 4

- [X] T091 [P] [US4] Create Zod validation schema for admin user in `apps/platform/lib/validations/admin-user.ts`
- [X] T092 [P] [US4] Create admin user type definitions in `apps/platform/lib/types/admin-user.ts`
- [X] T093 [US4] Implement createAdminUser Server Action with Supabase Auth integration in `apps/platform/lib/actions/admin-user.ts`
- [X] T094 [US4] Implement updateAdminUser Server Action in `apps/platform/lib/actions/admin-user.ts`
- [X] T095 [US4] Implement deactivateAdminUser Server Action in `apps/platform/lib/actions/admin-user.ts`
- [X] T096 [US4] Implement helper function to set app_metadata (role, tenant_id) via service role client
- [X] T097 [P] [US4] Create AdminUserForm component in `apps/platform/components/admins/admin-user-form.tsx`
- [X] T098 [P] [US4] Create AdminUserCard component in `apps/platform/components/admins/admin-user-card.tsx`
- [X] T099 [P] [US4] Create AdminUserList component in `apps/platform/components/admins/admin-user-list.tsx`
- [X] T100 [US4] Create admin users list page in `apps/platform/app/(dashboard)/tenants/[id]/admins/page.tsx`
- [X] T101 [US4] Create new admin user page in `apps/platform/app/(dashboard)/tenants/[id]/admins/new/page.tsx`
- [X] T102 [US4] Implement password validation (min 8 chars, uppercase, lowercase, number)
- [X] T103 [US4] Implement unique email validation across all users
- [X] T104 [US4] Add role selection UI (admin_head vs admin_officer)
- [X] T105 [US4] Verify Custom Access Token Hook adds JWT claims correctly
- [X] T106 [US4] Test admin user login and tenant access verification

**Checkpoint**: User Stories 1, 2, 3, AND 4 should all work independently

---

## Phase 7: User Story 5 - Configure Association Rules and Settings (Priority: P3)

**Goal**: Enable platform administrators to define association-level settings, rules, and operational parameters

**Independent Test**: Set association rules and fee structures, verify settings are saved and visible to admin users

### Implementation for User Story 5

- [X] T107 [P] [US5] Create Zod validation schema for association settings in `apps/platform/lib/validations/association-settings.ts`
- [X] T108 [P] [US5] Create association settings type definitions in `apps/platform/lib/types/association-settings.ts`
- [X] T109 [US5] Implement updateAssociationSettings Server Action in `apps/platform/lib/actions/association-settings.ts`
- [X] T110 [US5] Implement getAssociationSettings Server Action in `apps/platform/lib/actions/association-settings.ts`
- [X] T111 [P] [US5] Create SettingsForm component with fee structure inputs in `apps/platform/components/settings/settings-form.tsx`
- [X] T112 [P] [US5] Create SettingsSummary component in `apps/platform/components/settings/settings-summary.tsx`
- [X] T113 [US5] Create association settings page in `apps/platform/app/(dashboard)/tenants/[id]/settings/page.tsx`
- [X] T114 [US5] Implement fee structure configuration UI (monthly/quarterly/annual)
- [X] T115 [US5] Implement operational rules and guidelines editor
- [X] T116 [US5] Add settings validation and error handling
- [X] T117 [US5] Display settings summary with all configured parameters

**Checkpoint**: All user stories should now be independently functional

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [X] T118 [P] Create dashboard overview page in `apps/platform/app/(dashboard)/dashboard/page.tsx`
- [X] T119 [P] Add tenant statistics cards (total tenants, properties, residences) to dashboard
- [X] T120 [P] Create shared navigation component in `apps/platform/components/shared/navigation.tsx`
- [X] T121 [P] Create shared page header component in `apps/platform/components/shared/page-header.tsx`
- [X] T122 [P] Create shared breadcrumb component in `apps/platform/components/shared/breadcrumb.tsx`
- [X] T123 Implement toast notifications for success/error feedback
- [X] T124 Add loading states to all Server Action operations
- [X] T125 Implement optimistic UI updates with TanStack Query
- [X] T126 Add confirmation dialogs for delete operations
- [X] T127 [P] Create audit log viewer for super admins in `apps/platform/app/(dashboard)/audit-logs/page.tsx`
- [X] T128 Implement search and filter functionality for tenant list
- [X] T129 Add pagination to all list views
- [X] T130 Implement responsive design for mobile devices
- [X] T131 Add keyboard shortcuts for common operations
- [X] T132 Create seed data script for development in `supabase/seed.sql`
- [X] T133 Add comprehensive error messages with recovery suggestions
- [X] T134 Implement rate limiting on bulk import endpoints
- [X] T135 Add file size and type validation for bulk imports
- [X] T136 Optimize database queries with proper indexing verification
- [X] T137 Add performance monitoring for page load times
- [X] T138 Run quickstart.md validation and verify all workflows
- [X] T139 Update documentation with implementation notes
- [X] T140 [FR-013] Implement delete prevention for tenants with active residents or ongoing operations in `apps/platform/lib/actions/tenant.ts`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-7)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Phase 8)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P1)**: Can start after Foundational (Phase 2) - Requires US1 for tenant context but independently testable
- **User Story 3 (P2)**: Can start after Foundational (Phase 2) - Requires US1 for tenant context but independently testable
- **User Story 4 (P2)**: Can start after Foundational (Phase 2) - Requires US1 for tenant context but independently testable
- **User Story 5 (P3)**: Can start after Foundational (Phase 2) - Requires US1 for tenant context but independently testable

### Within Each User Story

- Validation schemas and types before Server Actions
- Server Actions before UI components
- UI components before pages
- Core implementation before integration features
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel (T003-T006)
- All database migration tasks marked [P] can run in parallel (T010-T014, T021-T025)
- All RLS policy tasks can run in parallel after migrations complete
- Validation schemas and type definitions within a story marked [P] can run in parallel
- UI components within a story marked [P] can run in parallel
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 2

```bash
# Launch all validation schemas together:
Task T053: "Create Zod validation schema for property"
Task T054: "Create Zod validation schema for residence unit"

# Launch all type definitions together:
Task T055: "Create property type definitions"
Task T056: "Create residence unit type definitions"

# Launch all UI components together after Server Actions complete:
Task T063: "Create PropertyForm component"
Task T064: "Create PropertyCard component"
Task T065: "Create PropertyList component"
Task T066: "Create ResidenceUnitForm component"
Task T067: "Create ResidenceUnitTable component"
```

---

## Implementation Strategy

### MVP First (User Stories 1 & 2 Only)

1. Complete Phase 1: Setup (T001-T008)
2. Complete Phase 2: Foundational (T009-T038) - CRITICAL - blocks all stories
3. Complete Phase 3: User Story 1 (T039-T052)
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Complete Phase 4: User Story 2 (T053-T077)
6. **STOP and VALIDATE**: Test User Stories 1 AND 2 independently
7. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (Basic MVP!)
3. Add User Story 2 → Test independently → Deploy/Demo (Full MVP!)
4. Add User Story 3 → Test independently → Deploy/Demo
5. Add User Story 4 → Test independently → Deploy/Demo
6. Add User Story 5 → Test independently → Deploy/Demo
7. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together (T001-T038)
2. Once Foundational is done:
   - Developer A: User Story 1 (T039-T052)
   - Developer B: User Story 2 (T053-T077)
   - Developer C: User Story 3 (T078-T090)
3. Stories complete and integrate independently
4. Merge order based on priority (P1 before P2 before P3)

---

## Summary Statistics

**Total Tasks**: 140 tasks
**Parallelizable Tasks**: 52 tasks (37% can run in parallel)

**Tasks by Phase**:
- Phase 1 (Setup): 8 tasks
- Phase 2 (Foundational): 30 tasks (CRITICAL - blocks all user stories)
- Phase 3 (User Story 1 - P1): 14 tasks
- Phase 4 (User Story 2 - P1): 25 tasks
- Phase 5 (User Story 3 - P2): 13 tasks
- Phase 6 (User Story 4 - P2): 16 tasks
- Phase 7 (User Story 5 - P3): 11 tasks
- Phase 8 (Polish): 23 tasks

**MVP Scope Recommendation**:
- **Minimal MVP**: Phase 1 + Phase 2 + Phase 3 (User Story 1 only) = 52 tasks
- **Recommended MVP**: Phase 1 + Phase 2 + Phase 3 + Phase 4 (User Stories 1 & 2) = 77 tasks
- **Full P1 Features**: Above + includes tenant creation and property configuration

**Estimated Timeline** (single developer):
- MVP (US1 only): ~2-3 weeks
- Recommended MVP (US1 + US2): ~3-4 weeks
- Full Feature (US1-US5): ~6-8 weeks
- With 3 developers working in parallel: ~3-4 weeks for full feature

---

## Notes

- [P] tasks = different files, no dependencies - can be parallelized
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Commit after each task or logical group of related tasks
- Stop at any checkpoint to validate story independently
- All database migrations must complete before application code
- RLS policies are CRITICAL for multi-tenant security
- Server Actions must validate authorization on every request
- Bulk import requires careful transaction handling and error reporting
- Custom Access Token Hook is essential for JWT claims in RLS policies
