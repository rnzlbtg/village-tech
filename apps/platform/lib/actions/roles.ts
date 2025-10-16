'use server'

import { createClient } from '@/lib/supabase/server'
import { requireSuperAdmin } from '@/lib/auth/helpers'

export interface RoleWithStats {
  role: string
  userCount: number
  tenants: string[]
}

export async function getRoles() {
  try {
    await requireSuperAdmin()

    const supabase = await createClient()

    // Get all role assignments with tenant info
    const { data: roleData, error } = await supabase
      .from('user_roles')
      .select(`
        role,
        is_active,
        tenant_id,
        tenant:tenants(name)
      `)
      .eq('is_active', true)

    if (error) {
      console.error('Error fetching roles:', error)
      return {
        success: false,
        error: error.message,
      }
    }

    // Group by role and count users
    const roleMap = new Map<string, RoleWithStats>()

    roleData?.forEach((item) => {
      if (!roleMap.has(item.role)) {
        roleMap.set(item.role, {
          role: item.role,
          userCount: 0,
          tenants: [],
        })
      }

      const roleStats = roleMap.get(item.role)!
      roleStats.userCount++

      // Add tenant name if exists and not already in list
      if (item.tenant?.name && !roleStats.tenants.includes(item.tenant.name)) {
        roleStats.tenants.push(item.tenant.name)
      }
    })

    return {
      success: true,
      data: Array.from(roleMap.values()),
    }
  } catch (error) {
    console.error('Error in getRoles:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to fetch roles',
    }
  }
}
