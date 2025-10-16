import Link from 'next/link'
import { ArrowLeft, Building2, DoorOpen, Users, Home } from 'lucide-react'
import { notFound } from 'next/navigation'
import { getTenant } from '@/lib/actions/tenant'
import { getTenantStatistics } from '@/lib/actions/statistics'
import { getAdminUsers } from '@/lib/actions/admin-user'
import { getGates } from '@/lib/actions/gate'
import { getProperties } from '@/lib/actions/property'
import { getAssociationSettings } from '@/lib/actions/association-settings'
import TenantDetailTabs from '@/components/tenants/TenantDetailTabs'

interface TenantDetailPageProps {
  params: {
    id: string
  }
}

export default async function TenantDetailPage(props: TenantDetailPageProps) {
  const params = await props.params
  const result = await getTenant(params.id)

  if (!result.success || !result.data) {
    notFound()
  }

  const tenant = result.data
  const statsResult = await getTenantStatistics(params.id)
  const stats = statsResult.success ? statsResult.data : null
  const adminUsers = await getAdminUsers(params.id)
  const gates = await getGates(params.id)
  const properties = await getProperties(params.id)
  const associationSettingsResult = await getAssociationSettings(params.id)
  const associationSettings = associationSettingsResult.success ? associationSettingsResult.data : undefined

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-4">
          <Link href="/tenants" className="text-gray-600 hover:text-gray-800 transition-colors">
            <ArrowLeft className="h-6 w-6" />
          </Link>
          <div>
            <h1 className="text-2xl font-bold text-gray-800">{result.data.name}</h1>
            <p className="text-gray-600 mt-1">Manage community settings and structure</p>
          </div>
        </div>
      </div>

      {/* Statistics Cards */}
      {stats && (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          <div className="bg-white border border-gray-200 rounded-lg p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Properties</p>
                <p className="text-2xl font-bold text-gray-800 mt-1">{stats.properties}</p>
              </div>
              <div className="p-3 bg-primary-light rounded-lg">
                <Building2 className="h-6 w-6 text-primary" />
              </div>
            </div>
          </div>

          <div className="bg-white border border-gray-200 rounded-lg p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Residence Units</p>
                <p className="text-2xl font-bold text-gray-800 mt-1">
                  {stats.residences}
                  {tenant.max_residences && (
                    <span className="text-base text-gray-500 font-normal">
                      /{tenant.max_residences}
                    </span>
                  )}
                </p>
              </div>
              <div className="p-3 bg-primary-light rounded-lg">
                <Home className="h-6 w-6 text-primary" />
              </div>
            </div>
          </div>

          <div className="bg-white border border-gray-200 rounded-lg p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Active Gates</p>
                <p className="text-2xl font-bold text-gray-800 mt-1">
                  {stats.activeGates}/{stats.gates}
                </p>
              </div>
              <div className="p-3 bg-primary-light rounded-lg">
                <DoorOpen className="h-6 w-6 text-primary" />
              </div>
            </div>
          </div>

          <div className="bg-white border border-gray-200 rounded-lg p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Admin Users</p>
                <p className="text-2xl font-bold text-gray-800 mt-1">{stats.adminUsers}</p>
              </div>
              <div className="p-3 bg-primary-light rounded-lg">
                <Users className="h-6 w-6 text-primary" />
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Tabbed Interface */}
      <TenantDetailTabs
        tenant={tenant}
        adminUsers={adminUsers}
        gates={gates}
        properties={properties}
        tenantId={params.id}
        associationSettings={associationSettings}
      />
    </div>
  )
}
