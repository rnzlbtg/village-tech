-- Fix Sentinel app RLS policies for guest access
-- Guards need to see all guests for their tenant, not just household-specific ones

-- First, let's see what user roles guards have
-- Guard users typically have role 'guard' or 'security' in the user_roles table

-- Drop existing household head policies that are preventing guard access
DROP POLICY IF EXISTS "Household heads can view guests for their household" ON guests;
DROP POLICY IF EXISTS "Household heads can insert guests for their household" ON guests;
DROP POLICY IF EXISTS "Household heads can update guests for their household" ON guests;
DROP POLICY IF EXISTS "Household heads can delete guests for their household" ON guests;

-- Create new guard-specific policies
CREATE POLICY "Guards can view all guests for their tenant" ON guests
    FOR SELECT USING (
        tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
        AND (
            -- Allow if user is a guard
            EXISTS (
                SELECT 1 FROM user_roles ur
                WHERE ur.user_id = auth.uid()
                AND ur.role = 'guard'
                AND ur.tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
            )
            -- Or if user is an admin
            OR EXISTS (
                SELECT 1 FROM user_roles ur
                WHERE ur.user_id = auth.uid()
                AND ur.role IN ('admin', 'super_admin')
                AND ur.tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
            )
            -- Or if user is a household head (for household access)
            OR household_id IN (
                SELECT id FROM households
                WHERE household_head_id = auth.uid()
            )
        )
    );

-- Guards can insert guests for their tenant
CREATE POLICY "Guards can insert guests for their tenant" ON guests
    FOR INSERT WITH CHECK (
        tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
        AND (
            -- Allow if user is a guard
            EXISTS (
                SELECT 1 FROM user_roles ur
                WHERE ur.user_id = auth.uid()
                AND ur.role = 'guard'
                AND ur.tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
            )
            -- Or if user is an admin
            OR EXISTS (
                SELECT 1 FROM user_roles ur
                WHERE ur.user_id = auth.uid()
                AND ur.role IN ('admin', 'super_admin')
                AND ur.tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
            )
            -- Or if user is a household head (for household access)
            OR household_id IN (
                SELECT id FROM households
                WHERE household_head_id = auth.uid()
            )
        )
    );

-- Guards can update guests for their tenant
CREATE POLICY "Guards can update guests for their tenant" ON guests
    FOR UPDATE USING (
        tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
        AND (
            -- Allow if user is a guard
            EXISTS (
                SELECT 1 FROM user_roles ur
                WHERE ur.user_id = auth.uid()
                AND ur.role = 'guard'
                AND ur.tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
            )
            -- Or if user is an admin
            OR EXISTS (
                SELECT 1 FROM user_roles ur
                WHERE ur.user_id = auth.uid()
                AND ur.role IN ('admin', 'super_admin')
                AND ur.tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
            )
            -- Or if user is a household head (for household access)
            OR household_id IN (
                SELECT id FROM households
                WHERE household_head_id = auth.uid()
            )
        )
    );

-- Guards can delete guests for their tenant
CREATE POLICY "Guards can delete guests for their tenant" ON guests
    FOR DELETE USING (
        tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
        AND (
            -- Allow if user is a guard
            EXISTS (
                SELECT 1 FROM user_roles ur
                WHERE ur.user_id = auth.uid()
                AND ur.role IN ('admin', 'super_admin')
                AND ur.tenant_id = (auth.jwt() ->> 'tenant_id')::uuid
            )
            -- Only admins can delete, guards can only check-in/check-out
            OR household_id IN (
                SELECT id FROM households
                WHERE household_head_id = auth.uid()
            )
        )
    );

-- Alternative simpler approach: Remove role-based restrictions entirely
-- and rely on tenant-based access for all authenticated users

-- Drop the existing tenant-only policies if they exist
DROP POLICY IF EXISTS "Users can view guests for their tenant only" ON guests;
DROP POLICY IF EXISTS "Users can insert guests for their tenant only" ON guests;
DROP POLICY IF EXISTS "Users can update guests for their tenant only" ON guests;
DROP POLICY IF EXISTS "Users can delete guests for their tenant only" ON guests;

-- Create simplified tenant-based policies that check both user_metadata and app_metadata
CREATE POLICY "Users can view guests for their tenant only" ON guests
    FOR SELECT USING (
        tenant_id = COALESCE(
            (auth.jwt() ->> 'tenant_id')::uuid,
            (auth.jwt() ->> 'app_metadata' ->> 'tenant_id')::uuid
        )
    );

CREATE POLICY "Users can insert guests for their tenant only" ON guests
    FOR INSERT WITH CHECK (
        tenant_id = COALESCE(
            (auth.jwt() ->> 'tenant_id')::uuid,
            (auth.jwt() ->> 'app_metadata' ->> 'tenant_id')::uuid
        )
    );

CREATE POLICY "Users can update guests for their tenant only" ON guests
    FOR UPDATE USING (
        tenant_id = COALESCE(
            (auth.jwt() ->> 'tenant_id')::uuid,
            (auth.jwt() ->> 'app_metadata' ->> 'tenant_id')::uuid
        )
    );

CREATE POLICY "Users can delete guests for their tenant only" ON guests
    FOR DELETE USING (
        tenant_id = COALESCE(
            (auth.jwt() ->> 'tenant_id')::uuid,
            (auth.jwt() ->> 'app_metadata' ->> 'tenant_id')::uuid
        )
        AND (
            -- Allow deletion for admins
            EXISTS (
                SELECT 1 FROM user_roles ur
                WHERE ur.user_id = auth.uid()
                AND ur.role IN ('admin', 'super_admin')
                AND ur.tenant_id = COALESCE(
                    (auth.jwt() ->> 'tenant_id')::uuid,
                    (auth.jwt() ->> 'app_metadata' ->> 'tenant_id')::uuid
                )
            )
            -- Or household heads for their own guests
            OR household_id IN (
                SELECT id FROM households
                WHERE household_head_id = auth.uid()
            )
        )
    );

-- Create a view for guard-specific access
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
WHERE g.tenant_id = COALESCE(
    (auth.jwt() ->> 'tenant_id')::uuid,
    (auth.jwt() ->> 'app_metadata' ->> 'tenant_id')::uuid
)
ORDER BY g.visit_start DESC;

-- Grant permissions on the new view
GRANT SELECT ON guest_dashboard TO authenticated;

-- Add helpful comment
COMMENT ON VIEW guest_dashboard IS 'Guard dashboard view with all guest information including household and property details';