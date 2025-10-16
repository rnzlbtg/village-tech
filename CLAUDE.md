# village-tech-v4 Development Guidelines

Auto-generated from all feature plans. Last updated: 2025-10-10

## Active Technologies
- Flutter 3.24+ / Dart 3 + supabase_flutter (backend), riverpod (state), go_router (navigation), hive/drift (offline storage) (004-sentinel-app-mobile)
- TypeScript 5.0+ / Node.js 20 LTS (backend), React 18+ / TypeScript 5.0+ (frontend) + Next.js 14 (frontend framework), Supabase (backend/database), shadcn/ui (UI components), TanStack Query (data fetching) (001-platform-app-multi)
- Supabase PostgreSQL with Row-Level Security (RLS) for multi-tenant isolation (001-platform-app-multi)
- TypeScript 5.0+ / Node.js 20 LTS, React 18+ / TypeScript 5.0+ + Next.js 14, Supabase, shadcn/ui, TanStack Query, React Hook Form (002-admin-app-residential)
- Supabase PostgreSQL with RLS (tenant-scoped access) (002-admin-app-residential)
- [e.g., Python 3.11, Swift 5.9, Rust 1.75 or NEEDS CLARIFICATION] + [e.g., FastAPI, UIKit, LLVM or NEEDS CLARIFICATION] (003-residence-app-mobile)
- [if applicable, e.g., PostgreSQL, CoreData, files or N/A] (003-residence-app-mobile)
- Flutter 3.24+ / Dart 3 + supabase_flutter, riverpod, go_router, hive (offline cache), flutter_image_compress, firebase_messaging (003-residence-app-mobile)
- Supabase PostgreSQL with RLS (household-scoped access), Supabase Storage (photo uploads), Hive (offline cache) (003-residence-app-mobile)

## Project Structure
```
src/
tests/
```

## Commands
# Add commands for Flutter 3.24+ / Dart 3

## Code Style
Flutter 3.24+ / Dart 3: Follow standard conventions

## Recent Changes
- 003-residence-app-mobile: Added Flutter 3.24+ / Dart 3 + supabase_flutter, riverpod, go_router, hive (offline cache), flutter_image_compress, firebase_messaging
- 003-residence-app-mobile: Added [e.g., Python 3.11, Swift 5.9, Rust 1.75 or NEEDS CLARIFICATION] + [e.g., FastAPI, UIKit, LLVM or NEEDS CLARIFICATION]
- 002-admin-app-residential: Added TypeScript 5.0+ / Node.js 20 LTS, React 18+ / TypeScript 5.0+ + Next.js 14, Supabase, shadcn/ui, TanStack Query, React Hook Form

<!-- MANUAL ADDITIONS START -->

The system uses a three-level hierarchy to represent residential communities:

```
TENANT (Residential Community/Village)
  └─ PROPERTY (Building/Phase/Section)
      └─ RESIDENCE UNIT (Individual Home/Apartment)
          └─ HOUSEHOLD (Family/Residents)
```

#### Level 1: Tenant
- **Definition**: The entire residential community or village
- **Created by**: Platform Super Admin (Platform App - 001)
- **Examples**: "Greenfield Village", "Sunset Heights Community", "Oakwood Estates"
- **Attributes**:
  - Community name
  - Community address (e.g., "123 Main St, Manila")
  - Contact information
  - Subscription status (active/trial/suspended)
  - Max residences allowed
- **Purpose**: Multi-tenant isolation - each tenant's data is completely segregated via PostgreSQL RLS

#### Level 2: Property
- **Definition**: A physical structure or area within the tenant/community
- **Created by**: Tenant Admin (Admin App - 002)
- **Examples**:
  - "Phase 1" (50 single-family homes)
  - "Tower A" (condo building with 100 units)
  - "Townhouse Block" (row of 20 townhouses)
  - "Commercial Section" (business area)
- **Attributes**:
  - Property name
  - Property address (specific building/phase location)
  - Property type (residential/commercial/mixed)
  - Total units (capacity)
  - Total floors (for multi-story buildings)
  - Year built
  - Lot size
- **Purpose**: Grouping residence units by physical structure or development phase

#### Level 3: Residence Unit
- **Definition**: An individual dwelling or apartment within a property
- **Created by**: Tenant Admin (Admin App - 002)
- **Examples**:
  - "House 25" (in Phase 1)
  - "Unit 101" (in Tower A)
  - "TH-5" (in Townhouse Block)
- **Attributes**:
  - Unit number/identifier
  - Floor number (for multi-story)
  - Unit type (studio, 1br, 2br, 3br+, house, penthouse)
  - Bedrooms
  - Bathrooms
  - Square meters
  - Parking slots
  - Occupancy status (occupied/vacant)
- **Purpose**: Individual household assignment

#### Level 4: Household (References Residence Unit)
- **Definition**: A family or group of residents living in a residence unit
- **Created by**: Tenant Admin (Admin App - 002)
- **Examples**: "Smith Family", "Jones Household"
- **Attributes**:
  - Household name
  - Residence unit (foreign key)
  - Move-in date
  - Move-out date
  - Status (active/inactive/pending)
- **Purpose**: Tracking who lives in which unit

### Why Three Levels?

**Use Case 1: Large gated village with multiple phases**
```
Tenant: "Greenfield Village"
  ├─ Property: "Phase 1" (50 houses)
  │   ├─ Unit: House 1
  │   ├─ Unit: House 2
  │   └─ ...
  ├─ Property: "Phase 2" (75 houses)
  │   ├─ Unit: House 1
  │   └─ ...
  └─ Property: "Clubhouse Area"
      └─ Unit: Admin Office
```

**Use Case 2: Mixed-use community with condos and houses**
```
Tenant: "Sunset Heights"
  ├─ Property: "Tower A" (condo)
  │   ├─ Unit: 101
  │   ├─ Unit: 102
  │   └─ ...
  ├─ Property: "Tower B" (condo)
  │   └─ ...
  └─ Property: "Garden Villas" (houses)
      ├─ Unit: Villa 1
      └─ ...
```

**Use Case 3: Simple subdivision**
```
Tenant: "Oakwood Estates"
  └─ Property: "Main Subdivision" (all houses)
      ├─ Unit: Lot 1
      ├─ Unit: Lot 2
      └─ ...
```

### Application Responsibilities

| Level | Platform App (001) | Admin App (002) |
|-------|-------------------|-----------------|
| **Tenant** | ✅ Create, Read, Update (monitoring) | ❌ Read-only (view own tenant) |
| **Property** | ✅ Read-only (monitoring) | ✅ Full CRUD |
| **Residence Unit** | ✅ Read-only (monitoring) | ✅ Full CRUD |
| **Household** | ❌ No access | ✅ Full CRUD |

### RLS (Row-Level Security) Enforcement

- **Platform App**: Uses service role (bypasses RLS) or super_admin app_role for cross-tenant access
- **Admin App**: Uses authenticated user with `app_role: 'admin_head'` or `'admin_officer'` + `tenant_id` in JWT claims
- **RLS Policies**: All tenant-scoped tables (properties, residence_units, households) filter by `tenant_id = (auth.jwt() ->> 'tenant_id')::uuid`

### Database Tables

```sql
-- Level 1
tenants (id, name, address, subscription_status, ...)

-- Level 2 (tenant_id FK)
properties (id, tenant_id, name, address, property_type, total_units, ...)

-- Level 3 (property_id FK)
residence_units (id, property_id, unit_number, floor_number, bedrooms, ...)

-- Level 4 (residence_unit_id FK)
households (id, residence_unit_id, household_name, move_in_date, status, ...)
```

### Migration Path (Platform → Admin)

1. **Platform Super Admin** (Platform App):
   - Creates Tenant: "Greenfield Village"
   - Creates Admin Users: admin_head@greenfield.com
   - Hands off to tenant admin

2. **Tenant Admin** (Admin App):
   - Logs in with credentials from Platform Admin
   - Creates Properties: "Phase 1", "Phase 2"
   - Creates Residence Units: House 1, House 2, ...
   - Creates Households: Assigns families to units
   - Manages day-to-day operations
   
<!-- MANUAL ADDITIONS END -->
