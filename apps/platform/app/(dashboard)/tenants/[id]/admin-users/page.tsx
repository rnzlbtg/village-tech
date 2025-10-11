import Link from 'next/link'
import { Plus } from 'lucide-react'
import { getAdminUsers } from '@/lib/actions/admin-user'
import AdminUserList from '@/components/admin-users/AdminUserList'

interface AdminUsersPageProps {
  params: {
    id: string
  }
}

export default async function AdminUsersPage({ params }: AdminUsersPageProps) {
  const users = await getAdminUsers(params.id)

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Admin Users</h1>
          <p className="text-gray-600 mt-1">Manage administrative users for this community</p>
        </div>
        <Link
          href={`/tenants/${params.id}/admin-users/new`}
          className="inline-flex items-center px-4 py-2 bg-primary text-white rounded-lg hover:bg-primary/90 transition-colors"
        >
          <Plus className="h-5 w-5 mr-2" />
          Add Admin User
        </Link>
      </div>

      <AdminUserList users={users} tenantId={params.id} />
    </div>
  )
}
