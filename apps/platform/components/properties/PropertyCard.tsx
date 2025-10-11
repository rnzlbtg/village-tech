import Link from 'next/link'
import { Property, PropertyWithCounts } from '@/lib/types/property'
import { Building2, MapPin, Home } from 'lucide-react'

interface PropertyCardProps {
  property: Property | PropertyWithCounts
  tenantId: string
}

export default function PropertyCard({ property, tenantId }: PropertyCardProps) {
  const residenceCount = 'residence_count' in property ? property.residence_count : property.total_units || 0
  const occupiedCount = 'occupied_count' in property ? property.occupied_count : 0
  const occupancyRate = residenceCount > 0 ? Math.round((occupiedCount / residenceCount) * 100) : 0

  return (
    <Link
      href={`/tenants/${tenantId}/properties/${property.id}`}
      className="block bg-white border rounded-lg p-6 hover:shadow-lg transition-shadow duration-200"
    >
      <div className="flex items-start justify-between mb-4">
        <div className="flex items-center space-x-3">
          <div className="bg-primary-light p-3 rounded-lg">
            <Building2 className="h-6 w-6 text-primary" />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-gray-800">{property.name}</h3>
            <span className="inline-block px-2 py-1 text-xs rounded-full bg-gray-100 text-gray-700 mt-1">
              {property.property_type || 'Residential'}
            </span>
          </div>
        </div>
      </div>

      <div className="space-y-2 text-sm text-gray-600">
        <div className="flex items-center space-x-2">
          <MapPin className="h-4 w-4" />
          <span>{property.address}</span>
        </div>

        <div className="flex items-center space-x-2">
          <Home className="h-4 w-4" />
          <span>
            {residenceCount} unit{residenceCount !== 1 ? 's' : ''}
            {property.total_floors && ` • ${property.total_floors} floor${property.total_floors !== 1 ? 's' : ''}`}
          </span>
        </div>

        {residenceCount > 0 && (
          <div className="mt-4 pt-4 border-t">
            <div className="flex justify-between items-center text-xs mb-1">
              <span className="text-gray-600">Occupancy</span>
              <span className="font-semibold text-gray-800">{occupancyRate}%</span>
            </div>
            <div className="w-full bg-gray-200 rounded-full h-2">
              <div
                className="bg-primary h-2 rounded-full transition-all duration-300"
                style={{ width: `${occupancyRate}%` }}
              />
            </div>
            <p className="text-xs text-gray-500 mt-1">
              {occupiedCount} of {residenceCount} occupied
            </p>
          </div>
        )}
      </div>
    </Link>
  )
}
