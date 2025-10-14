import { requireSuperAdmin } from '@/lib/auth/helpers'
import { createClient } from '@/lib/supabase/server'
import { getTenants } from '@/lib/actions/tenant'
import UsersManagementClient from '@/components/users/UsersManagementClient'

export default async function UsersPage() {
  await requireSuperAdmin()

  const supabase = await createClient()

  // Fetch all tenants for selection
  const tenants = await getTenants()

  // Fetch all users with their profiles and tenant information
  const { data: users, error } = await supabase
    .from('user_profiles')
    .select(`
      *,
      tenant:tenants(
        id,
        name
      )
    `)
    .order('created_at', { ascending: false })

  if (error) {
    console.error('Error fetching users:', error)
  }

  return <UsersManagementClient tenants={tenants} users={users || []} />
}
