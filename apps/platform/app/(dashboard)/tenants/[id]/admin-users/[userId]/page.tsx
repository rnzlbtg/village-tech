import Link from 'next/link'
import { ArrowLeft } from 'lucide-react'
import { notFound } from 'next/navigation'
import { getAdminUser } from '@/lib/actions/admin-user'
import AdminUserForm from '@/components/admin-users/AdminUserForm'

interface AdminUserDetailPageProps {
  params: {
    id: string
    userId: string
  }
}

export default async function AdminUserDetailPage({ params }: AdminUserDetailPageProps) {
  const result = await getAdminUser(params.userId)

  if (!result.success || !result.data) {
    notFound()
  }

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
          <h1 className="text-2xl font-bold text-gray-800">Edit Admin User</h1>
          <p className="text-gray-600 mt-1">Update administrative user details</p>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow p-6">
        <AdminUserForm tenantId={params.id} initialData={result.data} mode="edit" />
      </div>
    </div>
  )
}
