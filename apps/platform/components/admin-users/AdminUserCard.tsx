import Link from 'next/link'
import { Mail, Phone, Shield, ShieldCheck } from 'lucide-react'
import { AdminUser } from '@/lib/types/admin-user'

interface AdminUserCardProps {
  user: AdminUser
  tenantId: string
}

export default function AdminUserCard({ user, tenantId }: AdminUserCardProps) {
  const roleDisplay = {
    admin_head: { label: 'Admin Head', icon: ShieldCheck, color: 'text-primary' },
    admin_officer: { label: 'Admin Officer', icon: Shield, color: 'text-secondary' },
  }

  const role = roleDisplay[user.role]
  const RoleIcon = role.icon

  return (
    <Link href={`/tenants/${tenantId}/admin-users/${user.id}`}>
      <div className="bg-white rounded-lg border hover:border-primary hover:shadow-md transition-all p-6 cursor-pointer">
        <div className="flex items-start justify-between mb-4">
          <div className="flex-1">
            <h3 className="text-lg font-semibold text-gray-800 mb-1">
              {user.first_name} {user.last_name}
            </h3>
            <div className="flex items-center space-x-2">
              <RoleIcon className={`h-4 w-4 ${role.color}`} />
              <span className={`text-sm font-medium ${role.color}`}>{role.label}</span>
            </div>
          </div>
          <div
            className={`px-3 py-1 rounded-full text-xs font-medium ${
              user.is_active
                ? 'bg-green-100 text-green-800'
                : 'bg-gray-100 text-gray-800'
            }`}
          >
            {user.is_active ? 'Active' : 'Inactive'}
          </div>
        </div>

        <div className="space-y-2">
          <div className="flex items-center text-sm text-gray-600">
            <Mail className="h-4 w-4 mr-2 text-gray-400" />
            <span className="truncate">{user.email}</span>
          </div>
          {user.phone_number && (
            <div className="flex items-center text-sm text-gray-600">
              <Phone className="h-4 w-4 mr-2 text-gray-400" />
              <span>{user.phone_number}</span>
            </div>
          )}
        </div>

        <div className="mt-4 pt-4 border-t text-xs text-gray-500">
          Created {new Date(user.created_at).toLocaleDateString()}
        </div>
      </div>
    </Link>
  )
}
