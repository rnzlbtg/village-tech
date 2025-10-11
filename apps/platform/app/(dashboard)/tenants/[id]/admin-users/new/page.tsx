import Link from 'next/link'
import { ArrowLeft } from 'lucide-react'
import AdminUserForm from '@/components/admin-users/AdminUserForm'

interface NewAdminUserPageProps {
  params: {
    id: string
  }
}

export default async function NewAdminUserPage({ params }: NewAdminUserPageProps) {
  return (
    <div className="space-y-6">
      <div className="flex items-center space-x-4">
        <Link
          href={`/tenants/${params.id}/admin-users`}
          className="text-gray-600 hover:text-gray-800 transition-colors"
        >
          <ArrowLeft className="h-6 w-6" />
        </Link>
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Add Admin User</h1>
          <p className="text-gray-600 mt-1">Create a new administrative user</p>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow p-6">
        <AdminUserForm tenantId={params.id} mode="create" />
      </div>
    </div>
  )
}
