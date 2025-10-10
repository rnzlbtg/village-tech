# Architecture Decision: Monorepo with Independent Deployable Services

**Date**: 2025-10-10
**Status**: Approved
**Decision**: Use monorepo structure with independent deployable services

---

## Context

The Village Tech v4 system consists of four applications that need to share common code and a unified backend:

1. **Platform App** (Next.js) - Super admin tenant management
2. **Admin App** (Next.js) - Community admin operations
3. **Residence App** (Flutter) - Household head mobile app
4. **Sentinel App** (Flutter) - Gate guard mobile app

These applications have significant overlap in:

- **Shared Entities**: Household, Sticker, Construction Permit, Guest, Announcement, Village Rules
- **Shared Backend**: Single Supabase database with multi-tenant isolation
- **Shared Auth**: Supabase Auth with role-based access control
- **Cross-App Workflows**: Actions in one app trigger updates in others (e.g., Admin approves sticker → Residence App notified → Sentinel App can verify)

---

## Decision

**Adopt a monorepo architecture where all applications and shared code live in a single repository, but each application is treated as an independent deployable service.**

### Repository Structure

```
village-tech-v4/                    # Single Git Repository
├── apps/
│   ├── platform/                   # Next.js - Independent deployment to Vercel
│   ├── admin/                      # Next.js - Independent deployment to Vercel
│   ├── residence/                  # Flutter - Independent deployment to App/Play Store
│   └── sentinel/                   # Flutter - Independent deployment to App/Play Store
│
├── packages/                       # Shared libraries (imported at build time)
│   ├── database-types/             # Generated types from Supabase schema
│   ├── supabase-client/            # Configured Supabase client (TypeScript + Dart)
│   ├── shared-ui-web/              # React components for web apps
│   ├── shared-ui-mobile/           # Flutter widgets for mobile apps
│   └── validation/                 # Zod/Dart validation schemas
│
├── supabase/                       # Shared backend infrastructure
│   ├── migrations/                 # Database schema (all apps share)
│   ├── functions/                  # Edge Functions for business logic
│   └── seed.sql                    # Development seed data
│
└── specs/                          # Feature specifications for all apps
    ├── 001-platform-app-multi/
    ├── 002-admin-app-residential/
    ├── 003-residence-app-mobile/
    └── 004-sentinel-app-mobile/
```

---

## Key Principles

### 1. Monorepo (Physical Structure)

- All code lives in one Git repository
- Shared code in `packages/` directory
- Shared backend in `supabase/` directory
- All specifications in `specs/` directory

### 2. Independent Deployable Services (Logical Structure)

- Each app has its own build pipeline and configuration
- Each app deploys independently to its own environment
- Each app has its own versioning and release cycle
- Apps import shared packages at build time (not runtime coupling)

### 3. Shared Backend

- Single Supabase project with one PostgreSQL database
- Multi-tenant isolation via Row-Level Security (RLS)
- Different apps have different access levels:
  - **Platform App**: Full access (all tenants)
  - **Admin App**: Tenant-scoped access via RLS
  - **Residence App**: Household-scoped access via RLS
  - **Sentinel App**: Read-only guest lists, permits, rules

### 4. Independent CI/CD

- Each app triggers deployment only when affected
- Example: Updating Admin App doesn't redeploy Platform App
- Shared package changes trigger rebuilds of affected apps

---

## Benefits

### ✅ Development Velocity

- **No Duplicate Code**: Types, validation, business logic shared across apps
- **Instant Updates**: Changes to shared packages immediately available to all apps
- **No Publishing Overhead**: No need to publish/version shared packages to npm

### ✅ Type Safety

- **Single Source of Truth**: Database schema generates types for all apps
- **Compile-Time Validation**: TypeScript/Dart catch cross-app inconsistencies
- **Atomic Refactoring**: Rename entity field → all apps update together

### ✅ Deployment Independence

- **Independent Scaling**: Each app scales based on its own load patterns
- **Independent Releases**: Apps can be at different versions (Admin v2.5, Platform v1.3)
- **Fault Isolation**: If Admin App crashes, Residence App keeps working
- **Targeted Deployments**: Only deploy the app that changed

### ✅ Team Collaboration

- **Unified Workflow**: All developers work in same repo with same tools
- **Cross-App Features**: Easier to implement features spanning multiple apps
- **Atomic Pull Requests**: Single PR can update shared types + affected apps
- **Consistent Testing**: Integration tests can span multiple apps

### ✅ Code Quality

- **Shared Standards**: Linting, formatting, testing conventions unified
- **Reusable Components**: UI components shared across Platform & Admin apps
- **Business Logic**: Validation rules defined once, used everywhere
- **API Contracts**: OpenAPI schema generated from database, shared by all apps

---

## Trade-offs

### Considered Alternatives

#### ❌ Multi-Repo (Separate Repository per App)

**Why Rejected**:

- Would require duplicating type definitions across 4+ repos
- Managing schema versions and package publishing overhead
- Complex cross-repo coordination for features spanning multiple apps
- Slower development due to publish/install cycles for shared code
- Risk of version drift between apps

#### ❌ Microservices (Separate Database per App)

**Why Rejected**:

- Apps share too much data (Household, Sticker, Permit entities used by multiple apps)
- Would require complex data synchronization
- Cross-app queries would become expensive distributed transactions
- Multi-tenant isolation already handled by RLS at database level

#### ❌ Tightly Coupled Monolith (All Apps Deploy Together)

**Why Rejected**:

- No deployment independence (Platform App bug blocks Admin App deployment)
- Can't scale apps independently
- Single point of failure (one app crash affects all)
- Mobile apps can't have independent release schedules

---

## Implementation Guidelines

### Package Imports

Apps import shared packages using workspace aliases:

```typescript
// In apps/admin/src/pages/households.tsx
import { Household, Sticker } from "@village/database-types";
import { supabase } from "@village/supabase-client";
import { validateSticker } from "@village/validation";
```

### Independent Build Commands

Each app builds independently:

```bash
# Build only Platform App
cd apps/platform && npm run build

# Build only Admin App
cd apps/admin && npm run build

# Build only Residence App
cd apps/residence && flutter build apk
```

### CI/CD Pipeline Example

Deploy only affected apps:

```yaml
# .github/workflows/deploy-admin.yml
name: Deploy Admin App
on:
  push:
    branches: [main]
    paths:
      - "apps/admin/**"
      - "packages/**" # Rebuild if shared code changes
      - "supabase/migrations/**" # Rebuild if schema changes

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build Admin App
        run: |
          cd apps/admin
          npm install
          npm run build
      - name: Deploy to Vercel
        run: vercel deploy --prod
```

### Versioning Strategy

Each app maintains its own version:

```json
// apps/platform/package.json
{
  "name": "@village/platform-app",
  "version": "1.3.2"
}

// apps/admin/package.json
{
  "name": "@village/admin-app",
  "version": "2.5.0"
}
```

---

## Migration Path

### Phase 1: Repository Setup

1. Initialize monorepo with Turborepo or Nx
2. Create `apps/`, `packages/`, `supabase/` structure
3. Configure workspace dependencies

### Phase 2: Shared Packages

1. Extract database types from Supabase schema
2. Create shared Supabase client configurations
3. Build shared UI component libraries

### Phase 3: Application Development

1. Develop Platform App (001-platform-app-multi)
2. Develop Admin App (002-admin-app-residential)
3. Develop Residence App (003-residence-app-mobile)
4. Develop Sentinel App (004-sentinel-app-mobile)

### Phase 4: CI/CD Setup

1. Configure GitHub Actions for independent deployments
2. Set up Vercel projects for web apps
3. Configure app store deployments for mobile apps

---

## Success Criteria

This architecture decision will be considered successful if:

✅ Developers can build and deploy each app independently
✅ Shared type changes update all apps without manual synchronization
✅ Cross-app features (e.g., sticker approval workflow) work seamlessly
✅ CI/CD pipelines deploy only affected apps when changes occur
✅ Mobile apps can release on independent schedules from web apps
✅ No code duplication across apps for shared entities and logic

---

## References

- [Monorepo Best Practices](https://monorepo.tools/)
- [Turborepo Documentation](https://turbo.build/repo/docs)
- [Nx Monorepo Documentation](https://nx.dev/)
- [Supabase Multi-Tenant Architecture](https://supabase.com/docs/guides/database/row-level-security)

---

## Conversation Summary

**Question**: Is the current approach a monorepo that shares components with each application?

**Answer**: Yes, the architecture uses a **monorepo with independent deployable services**:

- **Monorepo**: All code in one repository with shared packages
- **Independent Services**: Each app builds, deploys, and scales independently
- **Shared at Build Time**: Apps import shared code during compilation (not runtime coupling)

**Key Insight**: This approach provides the benefits of code reuse (via monorepo) while maintaining the flexibility of microservices (independent deployments), without the downsides of either extreme (package publishing overhead of multi-repo OR tight coupling of monolith).

### What This Is NOT

❌ **Microservices**: Each app would have its own database → NOT this
❌ **Tightly Coupled Monolith**: All apps deploy together as one unit → NOT this
❌ **Multi-Repo**: Each app in separate repo with published packages → NOT this
