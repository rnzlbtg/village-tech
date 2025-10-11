-- Create Super Admin User
-- This script creates a super admin user for local development
-- Run this in Supabase SQL Editor after creating the auth user

-- Step 1: Create auth user via Supabase Dashboard or run this:
-- Go to: Authentication → Users → Add User
-- Email: admin@example.com
-- Password: Admin123!
-- Auto Confirm User: Yes

-- Step 2: Get the user ID from the auth.users table
-- SELECT id, email FROM auth.users WHERE email = 'admin@example.com';

-- Step 3: Update the user's app_metadata to set role as super_admin
-- IMPORTANT: Replace 'USER_UUID_HERE' with the actual user ID from Step 2

-- UPDATE auth.users
-- SET raw_app_meta_data = jsonb_set(
--   COALESCE(raw_app_meta_data, '{}'::jsonb),
--   '{role}',
--   '"super_admin"'
-- )
-- WHERE email = 'admin@example.com';

-- Step 4: Create user profile (optional, for super admins tenant_id can be NULL)
-- INSERT INTO user_profiles (
--   id,
--   tenant_id,
--   email,
--   first_name,
--   last_name,
--   role,
--   is_active
-- ) VALUES (
--   'USER_UUID_HERE'::uuid,
--   NULL,
--   'admin@example.com',
--   'Super',
--   'Admin',
--   'super_admin',
--   true
-- ) ON CONFLICT (id) DO NOTHING;

-- Verification query:
-- SELECT
--   u.id,
--   u.email,
--   u.raw_app_meta_data->>'role' as role,
--   p.first_name,
--   p.last_name
-- FROM auth.users u
-- LEFT JOIN user_profiles p ON u.id = p.id
-- WHERE u.email = 'admin@example.com';
