import { Property, PropertyWithCounts } from '@/lib/types/property'
import PropertyCard from './PropertyCard'
import { Building2 } from 'lucide-react'

interface PropertyListProps {
  properties: (Property | PropertyWithCounts)[]
  tenantId: string
}

export default function PropertyList({ properties, tenantId }: PropertyListProps) {
  if (properties.length === 0) {
    return (
      <div className="bg-white rounded-lg border p-12 text-center">
        <Building2 className="h-12 w-12 text-gray-400 mx-auto mb-4" />
        <h3 className="text-lg font-semibold text-gray-800 mb-2">No properties yet</h3>
        <p className="text-gray-600">
          Get started by adding your first property to this community.
        </p>
      </div>
    )
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {properties.map((property) => (
        <PropertyCard key={property.id} property={property} tenantId={tenantId} />
      ))}
    </div>
  )
}
