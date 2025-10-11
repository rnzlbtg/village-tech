import { requireSuperAdmin } from '@/lib/auth/helpers'
import { createClient } from '@/lib/supabase/server'
import UserForm from '@/components/users/UserForm'
import Link from 'next/link'
import { ArrowLeft } from 'lucide-react'
import { notFound } from 'next/navigation'

interface EditUserPageProps {
  params: {
    id: string
  }
}

export default async function EditUserPage({ params }: EditUserPageProps) {
  await requireSuperAdmin()

  const supabase = await createClient()

  // Fetch the user to edit
  const { data: user, error: userError } = await supabase
    .from('user_profiles')
    .select(`
      *,
      tenant:tenants(
        id,
        name
      )
    `)
    .eq('id', params.id)
    .single()

  if (userError || !user) {
    notFound()
  }

  // Fetch all tenants for the dropdown
  const { data: tenants, error: tenantsError } = await supabase
    .from('tenants')
    .select('id, name')
    .order('name')

  if (tenantsError) {
    console.error('Error fetching tenants:', tenantsError)
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <Link
          href="/users"
          className="p-2 hover:bg-gray-100 rounded-lg transition-colors touch-target"
        >
          <ArrowLeft className="h-5 w-5 text-gray-600" />
        </Link>
        <div>
          <h1 className="text-xl md:text-2xl font-bold text-gray-800">Edit User</h1>
          <p className="text-sm text-gray-600 mt-1">Update user information and permissions</p>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow p-4 md:p-6">
        <UserForm mode="edit" initialData={user} tenants={tenants || []} />
      </div>

      {/* Information box */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <h3 className="text-sm font-semibold text-blue-900 mb-2">Edit User Notes</h3>
        <ul className="text-sm text-blue-800 space-y-1">
          <li>• Email address cannot be changed after account creation</li>
          <li>• Password can be reset separately via the password reset function</li>
          <li>• Deactivating a user will prevent them from logging in</li>
          <li>• Super admins cannot be assigned to a specific tenant</li>
          <li>• All other roles must be assigned to a tenant/community</li>
        </ul>
      </div>
    </div>
  )
}
