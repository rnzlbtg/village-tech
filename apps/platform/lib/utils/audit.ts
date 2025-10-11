/**
 * Audit Logging Utilities
 *
 * Audit logging is handled automatically by database triggers.
 * All INSERT, UPDATE, and DELETE operations on tenant-scoped tables
 * are logged to the audit_logs table.
 *
 * The audit_trigger_function() captures:
 * - user_id (from auth.uid())
 * - tenant_id (from the row data)
 * - table_name
 * - operation (INSERT, UPDATE, DELETE)
 * - old_data (for UPDATE and DELETE)
 * - new_data (for INSERT and UPDATE)
 * - changed_fields (for UPDATE operations)
 * - timestamp
 *
 * Usage:
 * No code changes needed - all tenant operations are automatically logged.
 *
 * To query audit logs for a specific tenant:
 * ```typescript
 * const { data } = await supabase
 *   .from('audit_logs')
 *   .select('*')
 *   .eq('tenant_id', tenantId)
 *   .eq('table_name', 'tenants')
 *   .order('timestamp', { ascending: false })
 * ```
 *
 * Tables with audit logging:
 * - tenants
 * - properties
 * - residence_units
 * - gates
 * - admin_users
 * - association_settings
 */

import { createClient } from '@/lib/supabase/server'

export interface AuditLog {
  id: string
  tenant_id: string
  user_id: string | null
  table_name: string
  operation: 'INSERT' | 'UPDATE' | 'DELETE'
  old_data: Record<string, any> | null
  new_data: Record<string, any> | null
  changed_fields: string[] | null
  timestamp: string
}

/**
 * Get audit logs for a specific tenant and table
 */
export async function getAuditLogs(
  tenantId: string,
  tableName?: string,
  limit: number = 100
): Promise<{ success: boolean; data?: AuditLog[]; error?: string }> {
  try {
    const supabase = await createClient()

    let query = supabase
      .from('audit_logs')
      .select('*')
      .eq('tenant_id', tenantId)
      .order('timestamp', { ascending: false })
      .limit(limit)

    if (tableName) {
      query = query.eq('table_name', tableName)
    }

    const { data, error } = await query

    if (error) {
      return { success: false, error: error.message }
    }

    return { success: true, data: data as AuditLog[] }
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to fetch audit logs',
    }
  }
}

/**
 * Get recent changes for a specific record
 */
export async function getRecordHistory(
  tenantId: string,
  tableName: string,
  recordId: string,
  limit: number = 50
): Promise<{ success: boolean; data?: AuditLog[]; error?: string }> {
  try {
    const supabase = await createClient()

    const { data, error } = await supabase
      .from('audit_logs')
      .select('*')
      .eq('tenant_id', tenantId)
      .eq('table_name', tableName)
      .or(`old_data->>id.eq.${recordId},new_data->>id.eq.${recordId}`)
      .order('timestamp', { ascending: false })
      .limit(limit)

    if (error) {
      return { success: false, error: error.message }
    }

    return { success: true, data: data as AuditLog[] }
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to fetch record history',
    }
  }
}
