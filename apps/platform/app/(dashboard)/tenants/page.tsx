import Link from 'next/link'
import { Plus } from 'lucide-react'
import { getTenants } from '@/lib/actions/tenant'
import TenantList from '@/components/tenants/TenantList'

export default async function TenantsPage() {
  const tenants = await getTenants()

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Residential Communities</h1>
          <p className="text-gray-600 mt-1">Manage all tenant communities in the platform</p>
        </div>
        <Link
          href="/tenants/new"
          className="bg-primary hover:bg-secondary text-white px-4 py-2 rounded-lg flex items-center transition-colors duration-200"
        >
          <Plus className="h-5 w-5 mr-2" />
          Add Community
        </Link>
      </div>

      <div className="bg-white rounded-lg shadow p-4">
        <div className="flex items-center justify-between">
          <p className="text-sm text-gray-600">
            <span className="font-semibold text-gray-800">{tenants.length}</span>{' '}
            {tenants.length === 1 ? 'community' : 'communities'} total
          </p>
        </div>
      </div>

      <TenantList tenants={tenants} />
    </div>
  )
}
