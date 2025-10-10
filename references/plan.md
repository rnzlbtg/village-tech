ARCHITECTURE OVERVIEW

**Repository Strategy**: Monorepo with Independent Deployable Services

This project uses a **monorepo** (single repository) containing all applications and shared code, but treats each application as an **independent deployable service**. This approach provides the benefits of code sharing while maintaining deployment independence.

### Repository Structure

```
village-tech-v4/                    # Single Git Repository
├── apps/
│   ├── platform/                   # Next.js - Super admin tenant management
│   │   └── Deploy: Vercel (platform.villagetechv4.com)
│   ├── admin/                      # Next.js - Community admin operations
│   │   └── Deploy: Vercel (admin.villagetechv4.com)
│   ├── residence/                  # Flutter - Household head mobile app
│   │   └── Deploy: App Store + Play Store
│   └── sentinel/                   # Flutter - Gate guard mobile app
│       └── Deploy: App Store + Play Store (separate app)
│
├── packages/                       # Shared code (imported at build time)
│   ├── database-types/             # Generated TypeScript/Dart types from Supabase
│   ├── supabase-client/            # Configured Supabase client (TS + Dart)
│   ├── shared-ui-web/              # React components for Platform & Admin
│   ├── shared-ui-mobile/           # Flutter widgets for Residence & Sentinel
│   └── validation/                 # Zod schemas shared across apps
│
├── supabase/                       # Shared backend infrastructure
│   ├── migrations/                 # Database schema (shared by all apps)
│   ├── functions/                  # Edge Functions for business logic
│   ├── config.toml                 # Supabase configuration
│   └── seed.sql                    # Development seed data
│
├── specs/                          # Feature specifications
│   ├── 001-platform-app-multi/
│   ├── 002-admin-app-residential/
│   ├── 003-residence-app-mobile/
│   └── 004-sentinel-app-mobile/
│
└── .specify/                       # Spec-Kit templates and workflows
```

### Key Characteristics

**Shared Code via Imports**: Apps import from packages at build time, not runtime

```typescript
// In apps/admin/src/pages/households.tsx
import { Household } from "@village/database-types";
import { supabase } from "@village/supabase-client";
```

**Independent Build Pipelines**: Each app builds separately

- `npm run build` in `apps/platform` doesn't affect `apps/admin`
- Each app has its own `package.json`, dependencies, and build configuration

  **Independent Deployments**: Apps deploy separately

- Update Admin App → Deploy only Admin App to Vercel
- Update Residence App → Push new Flutter build to app stores
- No need to redeploy all apps when one changes

  **Independent Versioning**: Each app has its own release cycle

- Admin App v2.5.0, Platform App v1.3.2, Residence App v3.0.1
- Apps evolve at different paces based on feature needs

  **Shared Database**: Single Supabase project with multi-tenant isolation

- Platform App: Full access to all tenants (super admin)
- Admin App: RLS-restricted to assigned tenant
- Residence App: RLS-restricted to household data
- Sentinel App: Read-only for guest lists, permits, rules

  **Independent CI/CD**: Each app triggers deployment only when affected

```yaml
# .github/workflows/deploy-admin.yml
on:
  push:
    paths:
      - "apps/admin/**" # Deploy if Admin App changes
      - "packages/**" # Deploy if shared packages change
```

### Benefits of This Approach

1. **Faster Development**: Shared code changes are immediate (no npm publish/install)
2. **Type Safety**: Database schema changes update all apps' types instantly
3. **Independent Scaling**: Each app scales separately based on load
4. **Independent Releases**: Deploy apps on different schedules
5. **Fault Isolation**: If one app crashes, others continue working
6. **Code Reuse**: No duplication of types, validation, or business logic
7. **Atomic Updates**: Database schema + affected apps can deploy together

---

TECHNOLOGY STACK

BACKEND (via Supabase)

- Supabase (PostgreSQL + Auth + Storage + Edge Functions)
- PostgreSQL 15+ (managed by Supabase)
- Row-Level Security (RLS) for tenant isolation and secure multi-tenant data access
- Supabase Edge Functions for server-side logic (business workflows, webhooks, scheduled tasks)
- Supabase Realtime for live updates (gate monitoring, incident alerts)
- Supabase Auth for authentication & authorization
  - JWT-based session management
  - Role-based & claims-based rules using Supabase policies
  - Optional MFA (TOTP or SMS)
- Supabase Storage for file and media management (e.g., incident photos)
- Supabase Functions Scheduler (via `pg_cron` or Supabase Scheduler) for periodic background tasks (notifications, reports)

FRONTEND (Web + Admin Platform)

- Next.js 15 (App Router, TypeScript, Server Actions)
- TanStack Query (React Query) → data fetching, caching, and synchronization with Supabase
- Zustand → lightweight state management for UI and session state
- React Hook Form (RHF) + Zod → form management and validation
- TailwindCSS → utility-first styling
- Shadcn/ui → component library with accessible, customizable UI primitives
- Supabase JS Client → direct communication with database and auth API
- Next Auth (optional) → enhanced auth flows if needed beyond Supabase’s native auth
- Server Components + SSR/ISR → performance and SEO benefits for admin dashboard

MOBILE APPS

- Flutter (3.24+) + Dart 3 for cross-platform mobile apps (iOS + Android)
- supabase_flutter SDK → authentication, database, storage, and realtime integration
- Riverpod → state management
- GoRouter → declarative navigation
- Hive or Drift → local storage and offline caching
- Material 3 + Flutter Adaptive Scaffolding → native UI/UX for all platforms
- Flutter Background Services → background sync, notifications, and offline task handling
- Firebase Cloud Messaging (FCM) → push notifications
- Platform Channels → for native integrations (camera, location, biometrics)

---

AUTHENTICATION & AUTHORIZATION

- Supabase Auth with JWT + refresh rotation
- Role-based access control (RBAC) and row-level policies in SQL for tenant data isolation
- Organization and user-level roles (e.g., Admin, Operator, Resident)
- Optional MFA support using Supabase’s Auth extensions or custom logic
- Email & magic link login for non-technical users

---

DATABASE & DATA MODEL

- Supabase PostgreSQL
  - Normalized schema for users, tenants, properties, incidents, and notifications
  - RLS policies for per-tenant isolation
  - Database triggers for audit logs and event tracking
  - Views for analytics and reporting
- Supabase Realtime → subscriptions for gate/incident updates
- Supabase Storage → store documents, media, and community assets

---

INFRASTRUCTURE & DEPLOYMENT

- Fully hosted on Supabase + Vercel stack
  - Backend (DB, functions, storage) → Supabase
  - Frontend → Vercel with auto-deploy on merge
- Environment Configuration: `.env` + Supabase secrets
- CI/CD: GitHub Actions (lint, test, build, deploy)
- Monitoring: Supabase Insights + Vercel Analytics (optionally Datadog)
- Caching: via TanStack Query + optional Vercel Edge Caching
- CDN: handled by Vercel Edge Network

---

INTEGRATIONS

- Stripe → payments (community dues, gate fees)
- Twilio / Supabase Functions → SMS notifications
- SendGrid / Resend → transactional email (alerts, onboarding)
- Cloudflare → DNS, CDN, and DDoS protection
- Firebase Cloud Messaging (FCM) → push notifications for Flutter apps

---

TESTING & QUALITY

- Vitest → unit and integration testing (Next.js + TS)
- Playwright → end-to-end UI testing
- React Testing Library → component testing
- Mock Service Worker (MSW) → API mocking for offline/dev tests
- Zod validation → enforces consistent data shapes across client and server
- Flutter Testing Framework → unit, widget, and integration tests for mobile
- Mockito + IntegrationTest → for Flutter logic and backend communication

---

DEVELOPMENT WORKFLOW

- Next.js App Router conventions for structure and SSR
- Git Feature Branch Workflow with PR reviews
- Conventional Commits → automated changelogs
- Semantic Versioning (SemVer)
- Prettier + ESLint → consistent formatting and linting
- dart format + very_good_analysis for Flutter
- OpenAPI schema (via Supabase introspection) → generated API types
- Husky + lint-staged → pre-commit checks
