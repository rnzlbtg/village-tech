import Link from 'next/link'
import { Plus } from 'lucide-react'
import { getProperties } from '@/lib/actions/property'
import PropertyList from '@/components/properties/PropertyList'

interface PropertiesPageProps {
  params: {
    id: string
  }
}

export default async function PropertiesPage({ params }: PropertiesPageProps) {
  const properties = await getProperties(params.id)

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Properties</h1>
          <p className="text-gray-600 mt-1">Manage properties within this community</p>
        </div>
        <Link
          href={`/tenants/${params.id}/properties/new`}
          className="bg-primary hover:bg-secondary text-white px-4 py-2 rounded-lg flex items-center transition-colors duration-200"
        >
          <Plus className="h-5 w-5 mr-2" />
          Add Property
        </Link>
      </div>

      <div className="bg-white rounded-lg shadow p-4">
        <div className="flex items-center justify-between mb-4">
          <p className="text-sm text-gray-600">
            <span className="font-semibold text-gray-800">{properties.length}</span>{' '}
            {properties.length === 1 ? 'property' : 'properties'} total
          </p>
        </div>
      </div>

      <PropertyList properties={properties} tenantId={params.id} />
    </div>
  )
}
