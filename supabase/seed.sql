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
-- Credentials: test@superadmin.com / admin

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
  'test@superadmin.com',
  crypt('password', gen_salt('bf')),
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
  'test@superadmin.com',
  'Super',
  'Admin',
  'super_admin',
  true
) ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- CREATE TENANT ADMIN USER FOR SUNSET VALLEY
-- ============================================================================
-- Create tenant admin for the created tenant
-- Credentials: admin@sunsetvalley.com / admin

-- Create auth user with admin_head role
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
  '22222222-2222-2222-2222-222222222222'::uuid,
  'authenticated',
  'authenticated',
  'admin@sunsetvalley.com',
  crypt('password', gen_salt('bf')),
  NOW(),
  '{"tenant_id": "11111111-1111-1111-1111-111111111111", "app_role": "admin_head"}'::jsonb,
  '{}'::jsonb,
  NOW(),
  NOW(),
  '',
  '',
  '',
  ''
) ON CONFLICT (id) DO NOTHING;

-- Create user profile for tenant admin
INSERT INTO user_profiles (
  id,
  tenant_id,
  email,
  first_name,
  last_name,
  role,
  is_active
) VALUES (
  '22222222-2222-2222-2222-222222222222'::uuid,
  '11111111-1111-1111-1111-111111111111'::uuid,
  'admin@sunsetvalley.com',
  'Maria',
  'Santos',
  'admin_head',
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
  '22222222-2222-2222-2222-222222222222',
  '22222222-2222-2222-2222-222222222222'::uuid,
  format('{"sub":"%s","email":"%s"}', '22222222-2222-2222-2222-222222222222'::text, 'admin@sunsetvalley.com')::jsonb,
  'email',
  '22222222-2222-2222-2222-222222222222',
  NOW(),
  NOW(),
  NOW()
) ON CONFLICT (provider, provider_id) DO NOTHING;

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
  format('{"sub":"%s","email":"%s"}', '00000000-0000-0000-0000-000000000001'::text, 'test@superadmin.com')::jsonb,
  'email',
  '00000000-0000-0000-0000-000000000001',
  NOW(),
  NOW(),
  NOW()
) ON CONFLICT (provider, provider_id) DO NOTHING;

-- ============================================================================
-- CREATE SAMPLE DATA FOR SUNSET VALLEY TENANT
-- ============================================================================

-- Create Property 1: Tower A (Condominium Building)
INSERT INTO properties (
  id,
  tenant_id,
  name,
  address,
  property_type,
  total_units,
  description,
  created_at,
  updated_at
) VALUES (
  '33333333-3333-3333-3333-333333333333'::uuid,
  '11111111-1111-1111-1111-111111111111'::uuid,
  'Tower A',
  '123 Sunset Boulevard, Sunset Valley Residences',
  'building',
  100,
  '25-floor condominium building with studio, 2BR, and 3BR units. Built in 2020 with modern amenities.',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Create Property 2: Garden Villas
INSERT INTO properties (
  id,
  tenant_id,
  name,
  address,
  property_type,
  total_units,
  description,
  created_at,
  updated_at
) VALUES (
  '44444444-4444-4444-4444-444444444444'::uuid,
  '11111111-1111-1111-1111-111111111111'::uuid,
  'Garden Villas',
  '456 Garden Lane, Sunset Valley Residences',
  'lot',
  50,
  'Gated community with 2-story single-family homes. Built in 2018 on 8,500 square meter lot.',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Create Residence Units for Tower A (Units 101-105)
INSERT INTO residence_units (
  id,
  tenant_id,
  property_id,
  unit_number,
  unit_type,
  floor_number,
  status,
  address,
  created_at,
  updated_at
) VALUES
  ('55555555-5555-5555-5555-555555555551'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, '33333333-3333-3333-3333-333333333333'::uuid, 'Unit 101', 'residential', 1, 'occupied', '123 Sunset Boulevard, Tower A, Unit 101', NOW(), NOW()),
  ('55555555-5555-5555-5555-555555555552'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, '33333333-3333-3333-3333-333333333333'::uuid, 'Unit 102', 'residential', 1, 'occupied', '123 Sunset Boulevard, Tower A, Unit 102', NOW(), NOW()),
  ('55555555-5555-5555-5555-555555555553'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, '33333333-3333-3333-3333-333333333333'::uuid, 'Unit 103', 'residential', 1, 'available', '123 Sunset Boulevard, Tower A, Unit 103', NOW(), NOW()),
  ('55555555-5555-5555-5555-555555555554'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, '33333333-3333-3333-3333-333333333333'::uuid, 'Unit 104', 'residential', 1, 'occupied', '123 Sunset Boulevard, Tower A, Unit 104', NOW(), NOW()),
  ('55555555-5555-5555-5555-555555555555'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, '33333333-3333-3333-3333-333333333333'::uuid, 'Unit 105', 'residential', 1, 'available', '123 Sunset Boulevard, Tower A, Unit 105', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Create Residence Units for Garden Villas (Houses GV-01 to GV-03)
INSERT INTO residence_units (
  id,
  tenant_id,
  property_id,
  unit_number,
  unit_type,
  floor_number,
  status,
  address,
  created_at,
  updated_at
) VALUES
  ('66666666-6666-6666-6666-666666666661'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, '44444444-4444-4444-4444-444444444444'::uuid, 'GV-01', 'residential', 1, 'occupied', '456 Garden Lane, Garden Villas, GV-01', NOW(), NOW()),
  ('66666666-6666-6666-6666-666666666662'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, '44444444-4444-4444-4444-444444444444'::uuid, 'GV-02', 'residential', 1, 'occupied', '456 Garden Lane, Garden Villas, GV-02', NOW(), NOW()),
  ('66666666-6666-6666-6666-666666666663'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, '44444444-4444-4444-4444-444444444444'::uuid, 'GV-03', 'residential', 1, 'available', '456 Garden Lane, Garden Villas, GV-03', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Create Household Head Users and Households

-- Household Head 1: Juan Dela Cruz (Unit 102)
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
  '77777777-7777-7777-7777-777777777771'::uuid,
  'authenticated',
  'authenticated',
  'juan.delacruz@sunsetvalley.com',
  crypt('password', gen_salt('bf')),
  NOW(),
  '{"tenant_id": "11111111-1111-1111-1111-111111111111", "app_role": "household_head"}'::jsonb,
  '{}'::jsonb,
  NOW(),
  NOW(),
  '',
  '',
  '',
  ''
) ON CONFLICT (id) DO NOTHING;

INSERT INTO user_profiles (
  id,
  tenant_id,
  email,
  first_name,
  last_name,
  role,
  is_active
) VALUES (
  '77777777-7777-7777-7777-777777777771'::uuid,
  '11111111-1111-1111-1111-111111111111'::uuid,
  'juan.delacruz@sunsetvalley.com',
  'Juan',
  'Dela Cruz',
  'household_head',
  true
) ON CONFLICT (id) DO NOTHING;

INSERT INTO households (
  id,
  tenant_id,
  residence_unit_id,
  household_name,
  move_in_date,
  status,
  created_at,
  updated_at
) VALUES (
  '88888888-8888-8888-8888-888888888881'::uuid,
  '11111111-1111-1111-1111-111111111111'::uuid,
  '55555555-5555-5555-5555-555555555552'::uuid,
  'Dela Cruz Family',
  '2023-01-15',
  'active',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Household Head 2: Maria Reyes (Unit 104)
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
  '77777777-7777-7777-7777-777777777772'::uuid,
  'authenticated',
  'authenticated',
  'maria.reyes@sunsetvalley.com',
  crypt('password', gen_salt('bf')),
  NOW(),
  '{"tenant_id": "11111111-1111-1111-1111-111111111111", "app_role": "household_head"}'::jsonb,
  '{}'::jsonb,
  NOW(),
  NOW(),
  '',
  '',
  '',
  ''
) ON CONFLICT (id) DO NOTHING;

INSERT INTO user_profiles (
  id,
  tenant_id,
  email,
  first_name,
  last_name,
  role,
  is_active
) VALUES (
  '77777777-7777-7777-7777-777777777772'::uuid,
  '11111111-1111-1111-1111-111111111111'::uuid,
  'maria.reyes@sunsetvalley.com',
  'Maria',
  'Reyes',
  'household_head',
  true
) ON CONFLICT (id) DO NOTHING;

INSERT INTO households (
  id,
  tenant_id,
  residence_unit_id,
  household_name,
  move_in_date,
  status,
  created_at,
  updated_at
) VALUES (
  '88888888-8888-8888-8888-888888888882'::uuid,
  '11111111-1111-1111-1111-111111111111'::uuid,
  '55555555-5555-5555-5555-555555555554'::uuid,
  'Reyes Family',
  '2022-06-10',
  'active',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Household Head 3: Roberto Santos (GV-01)
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
  '77777777-7777-7777-7777-777777777773'::uuid,
  'authenticated',
  'authenticated',
  'roberto.santos@sunsetvalley.com',
  crypt('password', gen_salt('bf')),
  NOW(),
  '{"tenant_id": "11111111-1111-1111-1111-111111111111", "app_role": "household_head"}'::jsonb,
  '{}'::jsonb,
  NOW(),
  NOW(),
  '',
  '',
  '',
  ''
) ON CONFLICT (id) DO NOTHING;

INSERT INTO user_profiles (
  id,
  tenant_id,
  email,
  first_name,
  last_name,
  role,
  is_active
) VALUES (
  '77777777-7777-7777-7777-777777777773'::uuid,
  '11111111-1111-1111-1111-111111111111'::uuid,
  'roberto.santos@sunsetvalley.com',
  'Roberto',
  'Santos',
  'household_head',
  true
) ON CONFLICT (id) DO NOTHING;

INSERT INTO households (
  id,
  tenant_id,
  residence_unit_id,
  household_name,
  move_in_date,
  status,
  created_at,
  updated_at
) VALUES (
  '88888888-8888-8888-8888-888888888883'::uuid,
  '11111111-1111-1111-1111-111111111111'::uuid,
  '66666666-6666-6666-6666-666666666661'::uuid,
  'Santos Family',
  '2021-03-20',
  'active',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Create identity records for household heads
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES
  ('77777777-7777-7777-7777-777777777771', '77777777-7777-7777-7777-777777777771'::uuid, format('{"sub":"%s","email":"%s"}', '77777777-7777-7777-7777-777777777771'::text, 'juan.delacruz@sunsetvalley.com')::jsonb, 'email', '77777777-7777-7777-7777-777777777771', NOW(), NOW(), NOW()),
  ('77777777-7777-7777-7777-777777777772', '77777777-7777-7777-7777-777777777772'::uuid, format('{"sub":"%s","email":"%s"}', '77777777-7777-7777-7777-777777777772'::text, 'maria.reyes@sunsetvalley.com')::jsonb, 'email', '77777777-7777-7777-7777-777777777772', NOW(), NOW(), NOW()),
  ('77777777-7777-7777-7777-777777777773', '77777777-7777-7777-7777-777777777773'::uuid, format('{"sub":"%s","email":"%s"}', '77777777-7777-7777-7777-777777777773'::text, 'roberto.santos@sunsetvalley.com')::jsonb, 'email', '77777777-7777-7777-7777-777777777773', NOW(), NOW(), NOW())
ON CONFLICT (provider, provider_id) DO NOTHING;

-- ============================================================================
-- LOGIN CREDENTIALS FOR LOCAL DEVELOPMENT
-- ============================================================================
--
-- 1. SUPER ADMIN (Platform Level):
--    Email: test@superadmin.com
--    Password: password
--    - Can create new tenants (communities)
--    - Can manage all tenant data
--    - Can create admin users for each tenant
--
-- 2. TENANT ADMIN (Sunset Valley Residences):
--    Email: admin@sunsetvalley.com
--    Password: admin
--    - Can manage Sunset Valley tenant data
--    - Can create rules, permits, users, etc.
--    - Can manage village operations
--
-- 3. HOUSEHOLD HEADS:
--    Email: juan.delacruz@sunsetvalley.com / Password: password (Unit 102)
--    Email: maria.reyes@sunsetvalley.com / Password: password (Unit 104)
--    Email: roberto.santos@sunsetvalley.com / Password: password (GV-01)
--
-- Use the tenant admin account (admin@sunsetvalley.com) for testing the rules functionality.
