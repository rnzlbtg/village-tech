import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'

export async function getUserId() {
  const supabase = await createClient()
  const {
    data: { user },
    error,
  } = await supabase.auth.getUser()

  if (error || !user) {
    return null
  }

  return user.id
}

export async function getTenantId() {
  const supabase = await createClient()
  const {
    data: { user },
    error,
  } = await supabase.auth.getUser()

  if (error || !user) {
    return null
  }

  // Get tenant_id from user_metadata or app_metadata
  const tenantId =
    user.app_metadata?.tenant_id || user.user_metadata?.tenant_id

  return tenantId || null
}

export async function requireAdmin() {
  const supabase = await createClient()
  const {
    data: { user },
    error,
  } = await supabase.auth.getUser()

  if (error || !user) {
    redirect('/login')
  }

  // Check if user has admin role
  const role = user.app_metadata?.role || user.user_metadata?.role

  if (!role || !['admin_head', 'admin_officer'].includes(role)) {
    throw new Error('Unauthorized: Admin access required')
  }

  return user
}

export async function getAdminRole() {
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) return null

  return (user.app_metadata?.role || user.user_metadata?.role) as
    | 'admin_head'
    | 'admin_officer'
    | null
}
