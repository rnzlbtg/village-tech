'use server'

import { createClient, createAdminClient } from '@/lib/supabase/server'
import { requireSuperAdmin } from '@/lib/auth/helpers'

export async function getAuditLogs(filters?: {
  tenantId?: string
  action?: string
  entityType?: string
  userId?: string
  startDate?: string
  endDate?: string
  limit?: number
  offset?: number
}) {
  try {
    await requireSuperAdmin()

    // Use admin client to bypass RLS for super admin queries
    const supabase = createAdminClient()

    let query = supabase
      .from('audit_logs')
      .select('*', { count: 'exact' })
      .order('timestamp', { ascending: false })

    // Apply filters
    if (filters?.tenantId) {
      query = query.eq('tenant_id', filters.tenantId)
    }

    if (filters?.action) {
      query = query.eq('operation', filters.action)
    }

    if (filters?.entityType) {
      query = query.eq('table_name', filters.entityType)
    }

    if (filters?.userId) {
      query = query.eq('user_id', filters.userId)
    }

    if (filters?.startDate) {
      query = query.gte('timestamp', filters.startDate)
    }

    if (filters?.endDate) {
      query = query.lte('timestamp', filters.endDate)
    }

    // Pagination
    const limit = filters?.limit || 50
    const offset = filters?.offset || 0
    query = query.range(offset, offset + limit - 1)

    const { data: logs, error, count } = await query

    if (error) {
      console.error('Error fetching audit logs:', error)
      return {
        success: false,
        error: error.message,
      }
    }

    return {
      success: true,
      data: logs || [],
      count: count || 0,
    }
  } catch (error) {
    console.error('Error in getAuditLogs:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to fetch audit logs',
    }
  }
}

export async function getAuditLogStats() {
  try {
    await requireSuperAdmin()

    // Use admin client to bypass RLS for super admin queries
    const supabase = createAdminClient()

    // Get total count
    const { count: totalCount } = await supabase
      .from('audit_logs')
      .select('*', { count: 'exact', head: true })

    // Get count by action type
    const { data: actionCounts } = await supabase
      .from('audit_logs')
      .select('operation')
      .limit(1000)

    const actionStats = actionCounts?.reduce(
      (acc, log) => {
        acc[log.operation] = (acc[log.operation] || 0) + 1
        return acc
      },
      {} as Record<string, number>
    )

    return {
      success: true,
      data: {
        total: totalCount || 0,
        byAction: actionStats || {},
      },
    }
  } catch (error) {
    console.error('Error in getAuditLogStats:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to fetch audit log stats',
    }
  }
}
