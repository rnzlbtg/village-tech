import Link from 'next/link'
import { Tenant } from '@/lib/types/tenant'
import { Building, MapPin, Users } from 'lucide-react'

interface TenantCardProps {
  tenant: Tenant
}

export default function TenantCard({ tenant }: TenantCardProps) {
  const statusColors = {
    active: 'bg-green-100 text-green-800',
    trial: 'bg-amber-100 text-amber-800',
    inactive: 'bg-gray-100 text-gray-800',
    suspended: 'bg-red-100 text-red-800',
  }

  return (
    <Link
      href={`/tenants/${tenant.id}`}
      className="block bg-white rounded-lg shadow hover:shadow-md transition-shadow duration-200 p-6"
    >
      <div className="flex justify-between items-start mb-4">
        <div className="flex items-start space-x-3">
          <div className="bg-primary-light p-3 rounded-lg">
            <Building className="h-6 w-6 text-primary" />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-gray-800">{tenant.name}</h3>
            <div className="flex items-center text-sm text-gray-500 mt-1">
              <MapPin className="h-4 w-4 mr-1" />
              {tenant.city || tenant.address}
            </div>
          </div>
        </div>
        <span
          className={`px-3 py-1 text-xs font-semibold rounded-full ${
            statusColors[tenant.subscription_status]
          }`}
        >
          {tenant.subscription_status.charAt(0).toUpperCase() +
            tenant.subscription_status.slice(1)}
        </span>
      </div>

      <div className="grid grid-cols-2 gap-4 pt-4 border-t">
        {tenant.max_residences && (
          <div className="flex items-center text-sm">
            <Building className="h-4 w-4 text-gray-400 mr-2" />
            <span className="text-gray-600">Max: {tenant.max_residences} units</span>
          </div>
        )}
        {tenant.max_users && (
          <div className="flex items-center text-sm">
            <Users className="h-4 w-4 text-gray-400 mr-2" />
            <span className="text-gray-600">Max: {tenant.max_users} users</span>
          </div>
        )}
      </div>

      {tenant.contact_email && (
        <div className="mt-4 pt-4 border-t">
          <p className="text-xs text-gray-500">Contact: {tenant.contact_email}</p>
        </div>
      )}
    </Link>
  )
}
