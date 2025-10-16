import { requireSuperAdmin } from '@/lib/auth/helpers'
import { createClient } from '@/lib/supabase/server'
import UserForm from '@/components/users/UserForm'
import Link from 'next/link'
import { ArrowLeft } from 'lucide-react'

export default async function NewUserPage() {
  await requireSuperAdmin()

  const supabase = await createClient()

  // Fetch all tenants for the dropdown
  const { data: tenants } = await supabase
    .from('tenants')
    .select('id, name')
    .order('name')

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
          <h1 className="text-xl md:text-2xl font-bold text-gray-800">Create New User</h1>
          <p className="text-sm text-gray-600 mt-1">Add a new user to the platform</p>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow p-4 md:p-6">
        <UserForm mode="create" tenants={tenants || []} />
      </div>

      {/* Information Box */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <h3 className="text-sm font-semibold text-blue-900 mb-2">Important Information</h3>
        <ul className="text-sm text-blue-800 space-y-1">
          <li>• User accounts are created in Supabase Auth with the provided credentials</li>
          <li>• Super Admins have platform-wide access to all tenants</li>
          <li>• Admin Heads can fully manage their assigned tenant</li>
          <li>• Admin Officers have limited administrative access</li>
          <li>• All roles except Super Admin require a tenant assignment</li>
        </ul>
      </div>
    </div>
  )
}
