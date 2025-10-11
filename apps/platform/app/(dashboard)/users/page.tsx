import { requireSuperAdmin } from '@/lib/auth/helpers'
import { createClient } from '@/lib/supabase/server'
import UsersTable from '@/components/users/UsersTable'
import Link from 'next/link'
import { UserPlus } from 'lucide-react'

export default async function UsersPage() {
  await requireSuperAdmin()

  const supabase = await createClient()

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

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-gray-800">User Management</h1>
        <Link
          href="/users/new"
          className="bg-primary hover:bg-primary-dark text-white py-2 px-4 rounded-lg flex items-center transition-colors duration-200"
        >
          <UserPlus className="h-4 w-4 mr-2" />
          Add New User
        </Link>
      </div>

      <UsersTable users={users || []} />
    </div>
  )
}
