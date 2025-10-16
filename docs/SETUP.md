# Platform Setup Guide

## Prerequisites

- Node.js 18+ and npm
- Docker Desktop (for Supabase local development)
- Git

## Initial Setup

### 1. Install Dependencies

```bash
npm install
```

### 2. Start Supabase Local

```bash
npx supabase start
```

This will start the local Supabase instance. Note the output:

```
API URL: http://127.0.0.1:54321
GraphQL URL: http://127.0.0.1:54321/graphql/v1
DB URL: postgresql://postgres:postgres@127.0.0.1:54322/postgres
Studio URL: http://127.0.0.1:54323
Inbucket URL: http://127.0.0.1:54324
JWT secret: super-secret-jwt-token-with-at-least-32-characters-long
anon key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
service_role key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 3. Configure Environment Variables

Create `.env.local` in `apps/platform/`:

```env
NEXT_PUBLIC_SUPABASE_URL=http://127.0.0.1:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key_from_supabase_start
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_from_supabase_start
```

### 4. Run Migrations

```bash
npx supabase db reset
```

This will:
- Create all database tables
- Set up Row Level Security (RLS) policies
- Create audit logging triggers
- Seed initial development data

### 5. Create Super Admin User

A super admin user is required to create and manage tenants (communities).

#### Step 1: Create Auth User

1. Open Supabase Studio: http://127.0.0.1:54323
2. Navigate to **Authentication → Users**
3. Click **Add User**
4. Fill in:
   - **Email**: `admin@example.com`
   - **Password**: `Admin123!`
   - **Auto Confirm User**: ✓ (checked)
5. Click **Create User**

#### Step 2: Set Super Admin Role

1. Copy the user ID from the users table
2. Go to **SQL Editor** in Supabase Studio
3. Run this SQL:

```sql
UPDATE auth.users
SET raw_app_meta_data = jsonb_set(
  COALESCE(raw_app_meta_data, '{}'::jsonb),
  '{role}',
  '"super_admin"'
)
WHERE email = 'admin@example.com';
```

#### Step 3: Create User Profile (Optional)

Replace `USER_UUID_HERE` with the actual UUID from step 2:

```sql
INSERT INTO user_profiles (
  id,
  tenant_id,
  email,
  first_name,
  last_name,
  role,
  is_active
) VALUES (
  'USER_UUID_HERE'::uuid,
  NULL,
  'admin@example.com',
  'Super',
  'Admin',
  'super_admin',
  true
) ON CONFLICT (id) DO NOTHING;
```

#### Step 4: Verify Setup

Run this verification query:

```sql
SELECT
  u.id,
  u.email,
  u.raw_app_meta_data->>'role' as role,
  p.first_name,
  p.last_name,
  p.is_active
FROM auth.users u
LEFT JOIN user_profiles p ON u.id = p.id
WHERE u.email = 'admin@example.com';
```

Expected result:
- `role` should be `'super_admin'`
- `is_active` should be `true`

### 6. Start Development Server

```bash
npm run dev
```

Navigate to: http://localhost:3000

### 7. Sign In

Use the super admin credentials:
- **Email**: `admin@example.com`
- **Password**: `Admin123!`

You should now be able to:
- Create new tenants (communities)
- Manage all tenant data
- Create admin users for each tenant

## Troubleshooting

### "Unauthorized: Super admin access required"

**Cause**: The user's role is not set to `super_admin` in `raw_app_meta_data`.

**Solution**:
1. Verify the role is set correctly:
   ```sql
   SELECT email, raw_app_meta_data->>'role' as role
   FROM auth.users
   WHERE email = 'admin@example.com';
   ```
2. If the role is not `super_admin`, run the UPDATE query from Step 2 above.

### Cannot see tenants after login

**Cause**: RLS policies may not be correctly configured for super admins.

**Solution**:
1. Check RLS policies allow super_admin role
2. Verify the Custom Access Token Hook is configured (if using hosted Supabase)

### User not found after creation

**Cause**: Email confirmation is required but user wasn't auto-confirmed.

**Solution**:
1. Make sure "Auto Confirm User" was checked when creating the user
2. Or manually confirm the user:
   ```sql
   UPDATE auth.users
   SET email_confirmed_at = NOW()
   WHERE email = 'admin@example.com';
   ```

### Network request goes to localhost instead of Supabase

**This is expected behavior**. The form uses Next.js Server Actions, which:
1. POST to the current route (`localhost:3000/tenants/new`)
2. Server Action executes server-side
3. Server Action calls Supabase API
4. Result is returned to the client

The Supabase API calls happen server-side and won't appear in your browser's network tab.

## Database Migrations

All migrations are in `supabase/migrations/`. To create a new migration:

```bash
npx supabase migration new migration_name
```

To apply migrations:

```bash
npx supabase db reset  # Drops and recreates database
# OR
npx supabase migration up  # Apply pending migrations only
```

## User Roles

The system supports these roles:

- `super_admin` - Full system access, can manage all tenants
- `admin_head` - Full access within assigned tenant
- `admin_officer` - Limited admin access within assigned tenant
- `household_head` - Manages household within tenant
- `guard` - Gate/security access within tenant

## Next Steps

After setting up your super admin:

1. **Create a Tenant**: Navigate to "Communities" → "Add Community"
2. **Create Admin Users**: For each tenant, create admin users via "Admin Users"
3. **Configure Properties**: Add properties and residence units
4. **Set up Gates**: Configure gate/entrance points
5. **Create Households**: Add household heads and members
