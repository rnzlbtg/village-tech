-- Proper Tenant-Aware RLS Fix
-- This implements correct tenant isolation using app_metadata

-- =====================================================
-- STEP 1: Replace the workaround policies with proper ones
-- =====================================================

-- Drop the workaround policies
DROP POLICY IF EXISTS "Users can view guests for their tenant only" ON guests;
DROP POLICY IF EXISTS "Users can insert guests for their tenant only" ON guests;
DROP POLICY IF EXISTS "Users can update guests for their tenant only" ON guests;
DROP POLICY IF EXISTS "Users can delete guests for their tenant only" ON guests;

-- =====================================================
-- STEP 2: Create proper tenant-aware policies
-- =====================================================

-- Create proper SELECT policy with tenant filtering
CREATE POLICY "Users can view guests for their tenant only" ON guests
    FOR SELECT USING (
        auth.uid() IS NOT NULL
        AND tenant_id = (
            (auth.jwt() ->> 'app_metadata')::json ->> 'tenant_id'
        )::uuid
    );

-- Create proper INSERT policy with tenant filtering
CREATE POLICY "Users can insert guests for their tenant only" ON guests
    FOR INSERT WITH CHECK (
        auth.uid() IS NOT NULL
        AND tenant_id = (
            (auth.jwt() ->> 'app_metadata')::json ->> 'tenant_id'
        )::uuid
    );

-- Create proper UPDATE policy with tenant filtering
CREATE POLICY "Users can update guests for their tenant only" ON guests
    FOR UPDATE USING (
        auth.uid() IS NOT NULL
        AND tenant_id = (
            (auth.jwt() ->> 'app_metadata')::json ->> 'tenant_id'
        )::uuid
    );

-- Create proper DELETE policy with tenant filtering and role checks
CREATE POLICY "Users can delete guests for their tenant only" ON guests
    FOR DELETE USING (
        auth.uid() IS NOT NULL
        AND tenant_id = (
            (auth.jwt() ->> 'app_metadata')::json ->> 'tenant_id'
        )::uuid
        AND (
            -- Allow admins to delete
            EXISTS (
                SELECT 1 FROM user_roles ur
                WHERE ur.user_id = auth.uid()
                AND ur.role IN ('admin', 'super_admin')
                AND ur.tenant_id = (
                    (auth.jwt() ->> 'app_metadata')::json ->> 'tenant_id'
                )::uuid
            )
            -- Or household heads for their own guests
            OR household_id IN (
                SELECT id FROM households
                WHERE household_head_id = auth.uid()
            )
        )
    );

-- =====================================================
-- STEP 3: Update the guest_dashboard view with proper filtering
-- =====================================================

-- Drop and recreate the view with proper tenant filtering
DROP VIEW IF EXISTS guest_dashboard;

CREATE OR REPLACE VIEW guest_dashboard AS
SELECT
    g.*,
    h.household_name,
    ru.unit_number,
    p.name as property_name,
    t.name as tenant_name
FROM guests g
JOIN households h ON g.household_id = h.id
LEFT JOIN residence_units ru ON h.residence_unit_id = ru.id
LEFT JOIN properties p ON ru.property_id = p.id
JOIN tenants t ON g.tenant_id = t.id
WHERE g.tenant_id = (
    (auth.jwt() ->> 'app_metadata')::json ->> 'tenant_id'
)::uuid
  AND auth.uid() IS NOT NULL
ORDER BY g.visit_start DESC;

-- Grant permissions on the view
GRANT SELECT ON guest_dashboard TO authenticated;

-- =====================================================
-- STEP 4: Update debug function with proper tenant extraction
-- =====================================================

-- Update the debug function
DROP FUNCTION IF EXISTS test_guest_access();

CREATE OR REPLACE FUNCTION test_guest_access()
RETURNS TABLE (
    guest_count int,
    has_access boolean,
    user_tenant_id uuid,
    user_id uuid,
    sample_guest_name text,
    debug_info json
) AS $$
BEGIN
    -- Return detailed access information
    RETURN QUERY
    SELECT
        COUNT(*)::int as guest_count,
        COUNT(*) > 0 as has_access,
        ((auth.jwt() ->> 'app_metadata')::json ->> 'tenant_id')::uuid as user_tenant_id,
        auth.uid() as user_id,
        (SELECT g.guest_name FROM guests g LIMIT 1) as sample_guest_name,
        json_build_object(
            'user_metadata', auth.jwt() -> 'user_metadata',
            'app_metadata', auth.jwt() -> 'app_metadata',
            'tenant_from_user_meta', auth.jwt() ->> 'tenant_id',
            'tenant_from_app_meta', ((auth.jwt() ->> 'app_metadata')::json ->> 'tenant_id'),
            'tenant_check', ((auth.jwt() ->> 'app_metadata')::json ->> 'tenant_id')::uuid
        ) as debug_info
    FROM guests g
    WHERE g.tenant_id = (
        (auth.jwt() ->> 'app_metadata')::json ->> 'tenant_id'
    )::uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permission for the debug function
GRANT EXECUTE ON FUNCTION test_guest_access() TO authenticated;

-- =====================================================
-- STEP 5: Add comprehensive testing function
-- =====================================================

-- Create a function to test cross-tenant access
CREATE OR REPLACE FUNCTION test_cross_tenant_access()
RETURNS TABLE (
    total_guests int,
    tenant_guests int,
    other_tenant_guests int,
    test_result text
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        (SELECT COUNT(*) FROM guests) as total_guests,
        (SELECT COUNT(*) FROM guests WHERE tenant_id = ((auth.jwt() ->> 'app_metadata')::json ->> 'tenant_id')::uuid) as tenant_guests,
        (SELECT COUNT(*) FROM guests WHERE tenant_id != ((auth.jwt() ->> 'app_metadata')::json ->> 'tenant_id')::uuid) as other_tenant_guests,
        CASE
            WHEN (SELECT COUNT(*) FROM guests WHERE tenant_id = ((auth.jwt() ->> 'app_metadata')::json ->> 'tenant_id')::uuid) > 0
                 AND (SELECT COUNT(*) FROM guests WHERE tenant_id != ((auth.jwt() ->> 'app_metadata')::json ->> 'tenant_id')::uuid) = 0
            THEN 'SUCCESS: Proper tenant isolation working'
            ELSE 'ISSUE: Check tenant filtering'
        END as test_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION test_cross_tenant_access() TO authenticated;

-- =====================================================
-- COMMENTS
-- =====================================================

COMMENT ON POLICY "Users can view guests for their tenant only" ON guests IS
    'Proper tenant isolation using app_metadata. Users can only see guests from their own tenant.';

COMMENT ON POLICY "Users can insert guests for their tenant only" ON guests IS
    'Users can only create guests for their own tenant based on app_metadata tenant_id.';

COMMENT ON FUNCTION test_cross_tenant_access() IS
    'Tests that RLS policies properly isolate tenant data and prevent cross-tenant access';

/*
This migration implements proper multi-tenant security:

✅ CORRECT: Uses ((auth.jwt() ->> 'app_metadata')::json ->> 'tenant_id')::uuid
✅ SECURITY: Users only see their own tenant's guests
✅ ISOLATION: Prevents cross-tenant data access
✅ TESTING: Includes debug functions to verify isolation

The key fix was using the correct JSON operator chain:
- WRONG: auth.jwt() ->> 'app_metadata' ->> 'tenant_id'
- RIGHT: ((auth.jwt() ->> 'app_metadata')::json ->> 'tenant_id')::uuid

This ensures that security@sunsetvalley.com with tenant_id 11111111-1111-1111-1111-111111111111
can only see guests from that same tenant, not guests from other tenants.
*/