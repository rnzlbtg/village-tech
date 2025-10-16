import Link from 'next/link'
import { Building2, Users, Settings, BarChart3 } from 'lucide-react'
import { getTenants } from '@/lib/actions/tenant'
import CommunityDistributionChart from '@/components/dashboard/CommunityDistributionChart'

export default async function DashboardPage() {
  const tenants = await getTenants()

  // Calculate distribution by status
  const statusDistribution = [
    {
      name: 'Active',
      value: tenants.filter((t) => t.subscription_status === 'active').length,
    },
    {
      name: 'Trial',
      value: tenants.filter((t) => t.subscription_status === 'trial').length,
    },
    {
      name: 'Inactive',
      value: tenants.filter((t) => t.subscription_status === 'inactive').length,
    },
    {
      name: 'Suspended',
      value: tenants.filter((t) => t.subscription_status === 'suspended').length,
    },
  ].filter((item) => item.value > 0) // Only show categories with data

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-800">Dashboard</h1>
        <p className="text-gray-600 mt-1">Welcome to the Village Tech Platform</p>
      </div>

      {/* Quick Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white border border-gray-200 rounded-lg p-6 transition-all duration-300 hover:shadow-lg">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Total Communities</p>
              <p className="text-3xl font-bold text-gray-800 mt-2">{tenants.length}</p>
            </div>
            <div className="p-4 bg-primary-light rounded-lg">
              <Building2 className="h-8 w-8 text-primary" />
            </div>
          </div>
        </div>

        <div className="bg-white border border-gray-200 rounded-lg p-6 transition-all duration-300 hover:shadow-lg">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Active Communities</p>
              <p className="text-3xl font-bold text-gray-800 mt-2">
                {tenants.filter((t) => t.subscription_status === 'active').length}
              </p>
            </div>
            <div className="p-4 bg-green-100 rounded-lg">
              <BarChart3 className="h-8 w-8 text-green-600" />
            </div>
          </div>
        </div>

        <div className="bg-white border border-gray-200 rounded-lg p-6 transition-all duration-300 hover:shadow-lg">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Trial Communities</p>
              <p className="text-3xl font-bold text-gray-800 mt-2">
                {tenants.filter((t) => t.subscription_status === 'trial').length}
              </p>
            </div>
            <div className="p-4 bg-amber-100 rounded-lg">
              <Users className="h-8 w-8 text-amber-600" />
            </div>
          </div>
        </div>
      </div>

      {/* Community Distribution Analytics */}
      {tenants.length > 0 && (
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-lg font-semibold text-gray-800 mb-6">Community Distribution</h2>
          <CommunityDistributionChart data={statusDistribution} />
        </div>
      )}

      {/* Quick Actions */}
      <div>
        <h2 className="text-lg font-semibold text-gray-800 mb-4">Quick Actions</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <Link
            href="/tenants"
            className="bg-white border border-gray-200 rounded-lg p-6 hover:border-primary hover:shadow-md transition-all group"
          >
            <div className="flex items-center space-x-4">
              <div className="p-3 bg-primary-light rounded-lg group-hover:bg-primary transition-colors">
                <Building2 className="h-6 w-6 text-primary group-hover:text-white" />
              </div>
              <div>
                <h3 className="font-semibold text-gray-800">Manage Communities</h3>
                <p className="text-sm text-gray-600">View and manage all communities</p>
              </div>
            </div>
          </Link>

          <Link
            href="/tenants/new"
            className="bg-white border border-gray-200 rounded-lg p-6 hover:border-primary hover:shadow-md transition-all group"
          >
            <div className="flex items-center space-x-4">
              <div className="p-3 bg-primary-light rounded-lg group-hover:bg-primary transition-colors">
                <Building2 className="h-6 w-6 text-primary group-hover:text-white" />
              </div>
              <div>
                <h3 className="font-semibold text-gray-800">Add New Community</h3>
                <p className="text-sm text-gray-600">Create a new community tenant</p>
              </div>
            </div>
          </Link>

          <Link
            href="/settings"
            className="bg-white border border-gray-200 rounded-lg p-6 hover:border-primary hover:shadow-md transition-all group"
          >
            <div className="flex items-center space-x-4">
              <div className="p-3 bg-primary-light rounded-lg group-hover:bg-primary transition-colors">
                <Settings className="h-6 w-6 text-primary group-hover:text-white" />
              </div>
              <div>
                <h3 className="font-semibold text-gray-800">Platform Settings</h3>
                <p className="text-sm text-gray-600">Configure platform settings</p>
              </div>
            </div>
          </Link>
        </div>
      </div>

      {/* Recent Communities */}
      {tenants.length > 0 && (
        <div>
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-gray-800">Recent Communities</h2>
            <Link href="/tenants" className="text-primary hover:text-primary/80 text-sm font-medium">
              View all →
            </Link>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {tenants.slice(0, 3).map((tenant) => (
              <Link
                key={tenant.id}
                href={`/tenants/${tenant.id}`}
                className="bg-white border border-gray-200 rounded-lg p-6 hover:border-primary hover:shadow-md transition-all"
              >
                <div className="flex items-start justify-between mb-3">
                  <h3 className="font-semibold text-gray-800">{tenant.name}</h3>
                  <span
                    className={`px-2 py-1 rounded-full text-xs font-medium ${
                      tenant.subscription_status === 'active'
                        ? 'bg-green-100 text-green-800'
                        : tenant.subscription_status === 'trial'
                        ? 'bg-amber-100 text-amber-800'
                        : 'bg-gray-100 text-gray-800'
                    }`}
                  >
                    {tenant.subscription_status}
                  </span>
                </div>
                <p className="text-sm text-gray-600 mb-2">{tenant.address}</p>
                {tenant.city && (
                  <p className="text-sm text-gray-500">
                    {tenant.city}
                    {tenant.state && `, ${tenant.state}`}
                  </p>
                )}
              </Link>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}
