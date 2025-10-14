import { requireAdmin, getTenantId } from '@/lib/auth/helpers'
import { createClient } from '@/lib/supabase/server'
import Link from 'next/link'
import { ArrowLeft } from 'lucide-react'

export default async function NewHouseholdPage() {
  const user = await requireAdmin()
  const tenantId = await getTenantId()

  console.log('User role:', user.app_metadata?.role || user.user_metadata?.role)
  console.log('Tenant ID:', tenantId)
  console.log('User app_metadata:', user.app_metadata)
  console.log('User user_metadata:', user.user_metadata)

  const supabase = await createClient()

  // Debug: Check actual JWT claims
  const { data: sessionData } = await supabase.auth.getSession()
  if (sessionData.session) {
    const token = sessionData.session.access_token
    const payload = JSON.parse(Buffer.from(token.split('.')[1], 'base64').toString())
    console.log('JWT Payload:', payload)
    console.log('JWT role claim:', payload.role)
    console.log('JWT tenant_id claim:', payload.tenant_id)
  }

  // Test RLS with raw SQL
  const { data: rlsTest, error: rlsError } = await supabase.rpc('test_rls_context')
  console.log('RLS Test Result:', rlsTest)
  console.log('RLS Test Error:', rlsError)

  // Check all properties in DB (for debugging)
  const { data: allProperties } = await supabase
    .from('properties')
    .select('id, name, tenant_id')
    .limit(10)

  // Fetch properties and their units for the dropdown
  const { data: properties, error: propertiesError } = await supabase
    .from('properties')
    .select(
      `
      id,
      name,
      residence_units(
        id,
        unit_number
      )
    `
    )
    .eq('tenant_id', tenantId!)
    .order('name')

  if (propertiesError) {
    console.error('Error fetching properties:', propertiesError)
  }

  console.log('Properties data:', properties)
  console.log('Properties count:', properties?.length || 0)
  console.log('All properties:', allProperties)

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <Link href="/households" className="flex items-center text-gray-600 hover:text-gray-900">
          <ArrowLeft className="h-5 w-5" />
        </Link>
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Add New Household</h1>
          <p className="text-gray-600 mt-1">Create a new household record</p>
        </div>
      </div>

      {/* Debug info */}
      <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4 text-sm space-y-2">
        <p>
          <strong>Debug Info:</strong>
        </p>
        <p>Tenant ID: {tenantId || 'null'}</p>
        <p>User Role: {user.app_metadata?.role || user.user_metadata?.role || 'null'}</p>
        <p>Properties Found: {properties?.length || 0}</p>
        {propertiesError && <p className="text-red-600">Error: {propertiesError.message}</p>}
        <details className="mt-2">
          <summary className="cursor-pointer font-semibold">
            All Properties in DB (first 10)
          </summary>
          <pre className="mt-2 text-xs bg-white p-2 rounded overflow-auto">
            {JSON.stringify(properties, null, 2)}
          </pre>
        </details>
      </div>

      <div className="bg-white rounded-lg shadow p-6">
        <form className="space-y-6">
          <div>
            <label htmlFor="household_name" className="block text-sm font-medium text-gray-700">
              Household Name
            </label>
            <input
              type="text"
              id="household_name"
              name="household_name"
              required
              className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary focus:ring-primary sm:text-sm"
              placeholder="e.g., Smith Family"
            />
          </div>

          <div>
            <label htmlFor="property_id" className="block text-sm font-medium text-gray-700">
              Property
            </label>
            <select
              id="property_id"
              name="property_id"
              required
              className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary focus:ring-primary sm:text-sm"
            >
              <option value="">Select a property</option>
              {properties?.map((property: any) => {
                const units =
                  property.residence_units?.filter((unit: any) => unit.id !== null) || []
                return units.length > 0 ? (
                  <optgroup key={property.id} label={property.name}>
                    {units.map((unit: any) => (
                      <option key={unit.id} value={unit.id}>
                        Unit {unit.unit_number}
                      </option>
                    ))}
                  </optgroup>
                ) : null
              })}
            </select>
          </div>

          <div>
            <label htmlFor="move_in_date" className="block text-sm font-medium text-gray-700">
              Move-In Date
            </label>
            <input
              type="date"
              id="move_in_date"
              name="move_in_date"
              className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary focus:ring-primary sm:text-sm"
            />
          </div>

          <div>
            <label htmlFor="status" className="block text-sm font-medium text-gray-700">
              Status
            </label>
            <select
              id="status"
              name="status"
              required
              defaultValue="active"
              className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary focus:ring-primary sm:text-sm"
            >
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
              <option value="pending">Pending</option>
            </select>
          </div>

          <div className="flex gap-3 pt-4">
            <button
              type="submit"
              className="flex-1 bg-primary text-white px-4 py-2 rounded-lg hover:bg-primary-dark transition-colors"
            >
              Create Household
            </button>
            <Link
              href="/households"
              className="flex-1 bg-gray-200 text-gray-700 px-4 py-2 rounded-lg hover:bg-gray-300 transition-colors text-center"
            >
              Cancel
            </Link>
          </div>
        </form>
      </div>
    </div>
  )
}
