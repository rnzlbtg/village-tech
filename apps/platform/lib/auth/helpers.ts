import { createClient } from '@/lib/supabase/server'

export async function getCurrentUser() {
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  return user
}

export async function getUserRole() {
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) return null

  // Role is injected into JWT by Custom Access Token Hook
  const role = user.app_metadata?.role || 'authenticated'
  return role as string
}

export async function getTenantId() {
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) return null

  // tenant_id is injected into JWT by Custom Access Token Hook
  const tenantId = user.app_metadata?.tenant_id
  return tenantId as string | null
}

export async function isSuperAdmin() {
  const role = await getUserRole()
  return role === 'super_admin'
}

export async function requireSuperAdmin() {
  const user = await getCurrentUser()
  const role = user?.app_metadata?.role

  if (!user || role !== 'super_admin') {
    throw new Error('Unauthorized: Super admin access required')
  }

  return user
}

export async function signOut() {
  const supabase = await createClient()
  await supabase.auth.signOut()
}
