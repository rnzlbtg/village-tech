'use server'

import { createClient } from '@/lib/supabase/server'

export async function getTenantStatistics(tenantId: string) {
  try {
    // Use admin client to bypass RLS for super admin access
    const { createAdminClient } = await import('@/lib/supabase/server')
    const supabase = createAdminClient()

    // Get property count
    const { count: propertyCount } = await supabase
      .from('properties')
      .select('*', { count: 'exact', head: true })
      .eq('tenant_id', tenantId)

    // Get residence unit count
    const { count: residenceCount } = await supabase
      .from('residence_units')
      .select('*', { count: 'exact', head: true })
      .eq('tenant_id', tenantId)

    // Get gate count
    const { count: gateCount } = await supabase
      .from('gates')
      .select('*', { count: 'exact', head: true })
      .eq('tenant_id', tenantId)

    // Get admin user count
    const { count: adminCount } = await supabase
      .from('user_profiles')
      .select('*', { count: 'exact', head: true })
      .eq('tenant_id', tenantId)
      .in('role', ['admin_head', 'admin_officer'])
      .eq('is_active', true)

    // Get active gates count
    const { count: activeGatesCount } = await supabase
      .from('gates')
      .select('*', { count: 'exact', head: true })
      .eq('tenant_id', tenantId)
      .eq('operational_status', 'active')

    return {
      success: true,
      data: {
        properties: propertyCount || 0,
        residences: residenceCount || 0,
        gates: gateCount || 0,
        activeGates: activeGatesCount || 0,
        adminUsers: adminCount || 0,
      },
    }
  } catch (error) {
    console.error('Error fetching tenant statistics:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to fetch statistics',
    }
  }
}
