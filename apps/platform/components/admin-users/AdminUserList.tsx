import { AdminUser } from '@/lib/types/admin-user'
import AdminUserCard from './AdminUserCard'
import { UserCog } from 'lucide-react'

interface AdminUserListProps {
  users: AdminUser[]
  tenantId: string
}

export default function AdminUserList({ users, tenantId }: AdminUserListProps) {
  if (users.length === 0) {
    return (
      <div className="bg-white rounded-lg border p-12 text-center">
        <UserCog className="h-12 w-12 text-gray-400 mx-auto mb-4" />
        <h3 className="text-lg font-semibold text-gray-800 mb-2">No admin users yet</h3>
        <p className="text-gray-600">
          Create admin users to manage this community and its operations.
        </p>
      </div>
    )
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {users.map((user) => (
        <AdminUserCard key={user.id} user={user} tenantId={tenantId} />
      ))}
    </div>
  )
}
