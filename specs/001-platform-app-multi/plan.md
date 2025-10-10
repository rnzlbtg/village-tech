# Implementation Plan: Platform App - Multi-Tenant Management System

**Branch**: `001-platform-app-multi` | **Date**: 2025-10-10 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-platform-app-multi/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Web application for platform super administrators to manage multi-tenant residential communities. Primary capabilities include creating and configuring tenants, defining property structures and residence units, configuring gate entrances and equipment, creating initial admin users, and setting association-level rules and operational parameters. The system must support at least 100 concurrent tenants with complete data isolation, provide audit logging for all configuration changes, and enable tenant onboarding in under 30 minutes for communities up to 100 residences.

## Technical Context

**Language/Version**: TypeScript 5.0+ / Node.js 20 LTS (backend), React 18+ / TypeScript 5.0+ (frontend)
**Primary Dependencies**: Next.js 14 (frontend framework), Supabase (backend/database), shadcn/ui (UI components), TanStack Query (data fetching)
**Storage**: Supabase PostgreSQL with Row-Level Security (RLS) for multi-tenant isolation
**Testing**: Vitest (unit), Playwright (E2E), React Testing Library (component tests)
**Target Platform**: Web (Chrome/Safari/Edge latest 2 versions), responsive desktop-first design
**Project Type**: Web application (Next.js full-stack with Supabase backend)
**Performance Goals**: <30 min tenant onboarding for 100 residences, <2s page load, 100+ concurrent tenants supported
**Constraints**: Multi-tenant data isolation (RLS enforced), audit logging required for all config changes, bulk import support for large communities
**Scale/Scope**: 100+ tenants, ~5-10 screens, platform admin-only access (no public-facing pages)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Specification-Driven Workflow (NON-NEGOTIABLE)
- ✅ **PASS**: Feature specification exists at `specs/001-platform-app-multi/spec.md`
- ✅ **PASS**: User scenarios defined with acceptance criteria (5 user stories)
- ✅ **PASS**: Functional requirements documented (FR-001 through FR-015)
- ✅ **PASS**: Success criteria measurable and tracked (SC-001 through SC-006)

### Quality Over Speed (NON-NEGOTIABLE)
- ✅ **PASS**: Performance targets defined (<30 min onboarding, <2s page load, 100+ tenants)
- ✅ **PASS**: Data isolation requirement explicitly documented (multi-tenant RLS)
- ⚠️ **DEFER**: Technical debt tracking - will be addressed during implementation phase

### Architecture
- ✅ **PASS**: Layered architecture implied (Next.js frontend + Supabase backend)
- ✅ **PASS**: Clear separation of concerns (admin-only platform, no public pages)
- ⚠️ **RESEARCH NEEDED**: Bulk import implementation strategy for large communities
- ⚠️ **RESEARCH NEEDED**: Audit logging pattern (database triggers vs application-level)
- ⚠️ **RESEARCH NEEDED**: Multi-tenant RLS policy design patterns

### Security and Privacy
- ✅ **PASS**: Authentication through Supabase Auth (JWT-based)
- ✅ **PASS**: Multi-tenant isolation via RLS policies
- ✅ **PASS**: Admin-only access (platform super administrators)
- ⚠️ **RESEARCH NEEDED**: Super admin role management and security model
- ⚠️ **RESEARCH NEEDED**: Preventing accidental tenant data exposure in UI

### UX and Design Principles
- ✅ **PASS**: Responsive design requirement (desktop-first)
- ✅ **PASS**: UI component library specified (shadcn/ui)
- ⚠️ **DEFER**: WCAG 2.1 AA compliance - will be verified during UI implementation
- ⚠️ **DEFER**: Dark mode support - can be added post-MVP

### Testing
- ✅ **PASS**: Test strategy defined (Vitest unit, Playwright E2E, React Testing Library)
- ⚠️ **DEFER**: Test coverage targets - will be set during implementation

### Gate Evaluation (Initial)
**Status**: ✅ **CONDITIONALLY APPROVED** - May proceed to Phase 0 research to resolve flagged items

**Action Items Before Phase 1**:
1. ✅ Research bulk import strategies (COMPLETED - see research.md)
2. ✅ Research audit logging best practices (COMPLETED - see research.md)
3. ✅ Research multi-tenant RLS policy patterns (COMPLETED - see research.md)
4. ✅ Research super admin authentication (COMPLETED - see research.md)

---

### Gate Re-evaluation (Post-Design)

**Status**: ✅ **APPROVED** - All research completed, design artifacts generated

#### Research Resolution Summary
- ✅ **Bulk Import**: Resolved - Server-side processing with PapaParse/SheetJS + PostgreSQL COPY
- ✅ **Audit Logging**: Resolved - Database triggers with monthly partitioning
- ✅ **Multi-Tenant RLS**: Resolved - tenant_id column + JWT claims + mandatory indexing
- ✅ **Super Admin Auth**: Resolved - app_metadata + Custom Access Token Hook + middleware

#### Design Artifacts Verification
- ✅ **data-model.md**: Complete - 7 core entities with RLS policies and audit logging
- ✅ **contracts/**: Complete - Server Actions and authorization matrix documented
- ✅ **quickstart.md**: Complete - Developer guide with setup and key workflows
- ✅ **Agent Context**: Updated - CLAUDE.md updated with Next.js/TypeScript stack

#### Constitution Re-check

**Architecture**:
- ✅ **PASS**: Layered architecture confirmed (Next.js frontend + Supabase backend)
- ✅ **PASS**: Bulk import strategy defined (server-side with batching)
- ✅ **PASS**: Audit logging pattern defined (database triggers)
- ✅ **PASS**: Multi-tenant RLS policies defined with JWT claims

**Security and Privacy**:
- ✅ **PASS**: Super admin role management defined (app_metadata + JWT)
- ✅ **PASS**: Preventing tenant data exposure (RLS policies + server-side validation)

**Final Gate Status**: ✅ **FULLY APPROVED** - Ready for Phase 2 (Task Generation)

## Project Structure

### Documentation (this feature)

```
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```
apps/platform/                              # Next.js web app for platform super admins
├── app/                                    # Next.js 14 app directory
│   ├── (auth)/                             # Auth route group
│   │   ├── login/                          # Login page
│   │   └── layout.tsx                      # Auth layout
│   │
│   ├── (dashboard)/                        # Protected dashboard routes
│   │   ├── tenants/                        # Tenant management
│   │   │   ├── page.tsx                    # Tenant list
│   │   │   ├── [id]/                       # Tenant detail pages
│   │   │   │   ├── page.tsx                # Tenant overview
│   │   │   │   ├── properties/             # Property configuration
│   │   │   │   ├── gates/                  # Gate configuration
│   │   │   │   ├── admins/                 # Admin user management
│   │   │   │   └── settings/               # Association settings
│   │   │   └── new/                        # Create tenant
│   │   ├── dashboard/                      # Main dashboard
│   │   └── layout.tsx                      # Dashboard layout
│   │
│   ├── api/                                # API routes (if needed beyond Supabase)
│   │   └── bulk-import/                    # Bulk import endpoint
│   │
│   ├── layout.tsx                          # Root layout
│   └── page.tsx                            # Home/redirect page
│
├── components/                             # React components
│   ├── ui/                                 # shadcn/ui components
│   ├── tenants/                            # Tenant-specific components
│   │   ├── tenant-form.tsx
│   │   ├── tenant-list.tsx
│   │   └── tenant-card.tsx
│   ├── properties/                         # Property components
│   ├── gates/                              # Gate components
│   └── shared/                             # Shared components
│
├── lib/                                    # Utilities and helpers
│   ├── supabase/                           # Supabase client & helpers
│   │   ├── client.ts                       # Browser client
│   │   ├── server.ts                       # Server client
│   │   └── middleware.ts                   # Auth middleware
│   ├── hooks/                              # Custom React hooks
│   ├── utils/                              # Utility functions
│   └── validations/                        # Zod schemas
│
├── public/                                 # Static assets
├── tests/                                  # Tests
│   ├── unit/                               # Vitest unit tests
│   ├── component/                          # React Testing Library
│   └── e2e/                                # Playwright E2E tests
│
├── next.config.js                          # Next.js configuration
├── tailwind.config.ts                      # Tailwind CSS config
├── tsconfig.json                           # TypeScript config
└── package.json                            # Dependencies

supabase/                                   # Backend (existing, extended for Platform)
├── migrations/                             # Add Platform-specific tables
│   ├── 001_create_tenants.sql
│   ├── 002_create_properties.sql
│   ├── 003_create_gates.sql
│   ├── 004_create_admin_users.sql
│   └── 005_create_audit_logs.sql
├── functions/                              # Edge functions
│   └── bulk-import/                        # Bulk import handler
└── seed.sql                                # Seed data for dev

packages/                                   # Shared packages (existing)
├── database-types/                         # Supabase types (extended for Platform)
└── supabase-client/                        # Supabase client config
```

**Structure Decision**: Next.js 14 web application using App Router with file-based routing. The app follows Next.js conventions with route groups for auth and protected dashboard routes. Supabase provides backend services (auth, database, RLS). The app is located in monorepo at `apps/platform/` and imports shared packages for database types.

## Complexity Tracking

*Fill ONLY if Constitution Check has violations that must be justified*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
