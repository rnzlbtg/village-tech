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
    user.app_metadata?.tenant_id ||
    user.app_metadata?.app_tenant_id ||
    user.user_metadata?.tenant_id ||
    user.user_metadata?.app_tenant_id

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

  // Debug: Log user metadata for troubleshooting
  console.log('requireAdmin - User metadata:', {
    user_id: user.id,
    app_metadata: user.app_metadata,
    user_metadata: user.user_metadata,
  })

  // Check if user has admin role (look for both legacy 'role' and new 'app_role')
  const role = user.app_metadata?.app_role || user.app_metadata?.role ||
                user.user_metadata?.app_role || user.user_metadata?.role

  console.log('requireAdmin - Found role:', role)

  if (!role || !['admin_head', 'admin_officer'].includes(role)) {
    console.error('requireAdmin - Unauthorized. Role not found or invalid:', role)
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

  return (user.app_metadata?.app_role || user.app_metadata?.role ||
           user.user_metadata?.app_role || user.user_metadata?.role) as
    | 'admin_head'
    | 'admin_officer'
    | null
}
