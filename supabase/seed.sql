-- Seed data for local development

-- Create a test tenant for development
INSERT INTO tenants (
  id,
  name,
  address,
  city,
  state,
  country,
  postal_code,
  contact_name,
  contact_email,
  contact_phone,
  subscription_status,
  subscription_plan,
  max_users,
  max_residences
) VALUES (
  '11111111-1111-1111-1111-111111111111'::uuid,
  'Sunset Valley Residences',
  '123 Main Street, Barangay Example',
  'Quezon City',
  'Metro Manila',
  'Philippines',
  '1100',
  'Juan Dela Cruz',
  'contact@sunsetvalley.com',
  '+63 912 345 6789',
  'active',
  'Premium',
  100,
  500
) ON CONFLICT (name) DO NOTHING;

-- ============================================================================
-- CREATE SUPER ADMIN USER
-- ============================================================================
-- Create super admin for local development
-- Credentials: admin@test.com / admin

-- Create auth user with super_admin role
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  '00000000-0000-0000-0000-000000000001'::uuid,
  'authenticated',
  'authenticated',
  'admin@test.com',
  crypt('admin', gen_salt('bf')),
  NOW(),
  '{"role": "super_admin"}'::jsonb,
  '{}'::jsonb,
  NOW(),
  NOW(),
  '',
  '',
  '',
  ''
) ON CONFLICT (id) DO NOTHING;

-- Create user profile for super admin
INSERT INTO user_profiles (
  id,
  tenant_id,
  email,
  first_name,
  last_name,
  role,
  is_active
) VALUES (
  '00000000-0000-0000-0000-000000000001'::uuid,
  NULL,
  'admin@test.com',
  'Super',
  'Admin',
  'super_admin',
  true
) ON CONFLICT (id) DO NOTHING;

-- Create identity record for email authentication
INSERT INTO auth.identities (
  id,
  user_id,
  identity_data,
  provider,
  provider_id,
  last_sign_in_at,
  created_at,
  updated_at
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000001'::uuid,
  format('{"sub":"%s","email":"%s"}', '00000000-0000-0000-0000-000000000001'::text, 'admin@test.com')::jsonb,
  'email',
  '00000000-0000-0000-0000-000000000001',
  NOW(),
  NOW(),
  NOW()
) ON CONFLICT (provider, provider_id) DO NOTHING;

-- ============================================================================
-- LOGIN CREDENTIALS FOR LOCAL DEVELOPMENT
-- ============================================================================
-- Email: admin@test.com
-- Password: admin
--
-- This super admin can:
-- - Create new tenants (communities)
-- - Manage all tenant data
-- - Create admin users for each tenant
