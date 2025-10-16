'use client'

import { useState, useEffect } from 'react'
import Link from 'next/link'
import { useParams, useRouter } from 'next/navigation'
import { ArrowLeft, Plus, Trash2, Home } from 'lucide-react'
import { getProperty } from '@/lib/actions/property'
import { getResidenceUnits, createResidenceUnit, deleteResidenceUnit } from '@/lib/actions/residence-unit'

export default function PropertyDetailPage() {
  const params = useParams()
  const router = useRouter()
  const propertyId = params.id as string

  const [property, setProperty] = useState<any>(null)
  const [units, setUnits] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [showAddForm, setShowAddForm] = useState(false)
  const [formLoading, setFormLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    loadData()
  }, [propertyId])

  async function loadData() {
    setLoading(true)
    const [propertyResult, unitsData] = await Promise.all([
      getProperty(propertyId),
      getResidenceUnits(propertyId)
    ])

    if (propertyResult.success) {
      setProperty(propertyResult.data)
    }
    setUnits(unitsData)
    setLoading(false)
  }

  async function handleCreateUnit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault()
    setFormLoading(true)
    setError(null)

    const formData = new FormData(e.currentTarget)
    const result = await createResidenceUnit(propertyId, formData)

    if (result.success) {
      setShowAddForm(false)
      ;(e.target as HTMLFormElement).reset()
      await loadData()
      router.refresh()
    } else {
      setError(result.error || 'Failed to create unit')
    }
    setFormLoading(false)
  }

  async function handleDelete(unitId: string) {
    if (!confirm('Are you sure you want to delete this unit?')) {
      return
    }

    const result = await deleteResidenceUnit(unitId)
    if (result.success) {
      await loadData()
      router.refresh()
    } else {
      alert(result.error || 'Failed to delete unit')
    }
  }

  if (loading) {
    return <div className="text-center py-12">Loading...</div>
  }

  if (!property) {
    return <div className="text-center py-12">Property not found</div>
  }

  const occupiedCount = units.filter(u => u.is_occupied).length
  const vacantCount = units.length - occupiedCount
  const occupancyRate = units.length > 0 ? Math.round((occupiedCount / units.length) * 100) : 0

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-4">
          <Link
            href="/properties"
            className="text-gray-600 hover:text-gray-800 transition-colors"
          >
            <ArrowLeft className="h-6 w-6" />
          </Link>
          <div>
            <h1 className="text-2xl font-bold text-gray-800">{property.name}</h1>
            <p className="text-gray-600 mt-1">{property.address}</p>
          </div>
        </div>
        {!showAddForm && (
          <button
            onClick={() => setShowAddForm(true)}
            className="bg-primary hover:bg-primary-dark text-white px-4 py-2 rounded-lg flex items-center transition-colors"
          >
            <Plus className="h-5 w-5 mr-2" />
            Add Unit
          </button>
        )}
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-white rounded-lg border p-4">
          <p className="text-sm text-gray-600">Total Units</p>
          <p className="text-2xl font-bold text-gray-800">{units.length}</p>
        </div>
        <div className="bg-white rounded-lg border p-4">
          <p className="text-sm text-gray-600">Occupied</p>
          <p className="text-2xl font-bold text-green-600">{occupiedCount}</p>
        </div>
        <div className="bg-white rounded-lg border p-4">
          <p className="text-sm text-gray-600">Vacant</p>
          <p className="text-2xl font-bold text-gray-600">{vacantCount}</p>
        </div>
        <div className="bg-white rounded-lg border p-4">
          <p className="text-sm text-gray-600">Occupancy Rate</p>
          <p className="text-2xl font-bold text-primary">{occupancyRate}%</p>
        </div>
      </div>

      {showAddForm && (
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-xl font-semibold text-gray-800 mb-4">Add New Unit</h2>
          {error && (
            <div className="bg-red-50 border border-red-200 text-red-600 px-4 py-3 rounded-lg mb-4">
              {error}
            </div>
          )}
          <form onSubmit={handleCreateUnit} className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div>
                <label htmlFor="unit_number" className="block text-sm font-medium text-gray-700">
                  Unit Number <span className="text-red-500">*</span>
                </label>
                <input
                  type="text"
                  id="unit_number"
                  name="unit_number"
                  required
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary focus:ring-primary sm:text-sm"
                  placeholder="e.g., 101"
                />
              </div>
              <div>
                <label htmlFor="floor_number" className="block text-sm font-medium text-gray-700">
                  Floor Number
                </label>
                <input
                  type="number"
                  id="floor_number"
                  name="floor_number"
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary focus:ring-primary sm:text-sm"
                  placeholder="e.g., 1"
                />
              </div>
              <div>
                <label htmlFor="unit_type" className="block text-sm font-medium text-gray-700">
                  Unit Type
                </label>
                <select
                  id="unit_type"
                  name="unit_type"
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary focus:ring-primary sm:text-sm"
                >
                  <option value="">Select type</option>
                  <option value="studio">Studio</option>
                  <option value="1br">1 Bedroom</option>
                  <option value="2br">2 Bedroom</option>
                  <option value="3br">3 Bedroom</option>
                  <option value="4br+">4+ Bedroom</option>
                  <option value="penthouse">Penthouse</option>
                </select>
              </div>
              <div>
                <label htmlFor="bedrooms" className="block text-sm font-medium text-gray-700">
                  Bedrooms
                </label>
                <input
                  type="number"
                  id="bedrooms"
                  name="bedrooms"
                  min="0"
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary focus:ring-primary sm:text-sm"
                  placeholder="e.g., 2"
                />
              </div>
              <div>
                <label htmlFor="bathrooms" className="block text-sm font-medium text-gray-700">
                  Bathrooms
                </label>
                <input
                  type="number"
                  id="bathrooms"
                  name="bathrooms"
                  min="0"
                  step="0.5"
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary focus:ring-primary sm:text-sm"
                  placeholder="e.g., 1.5"
                />
              </div>
              <div>
                <label htmlFor="square_meters" className="block text-sm font-medium text-gray-700">
                  Size (sq m)
                </label>
                <input
                  type="number"
                  id="square_meters"
                  name="square_meters"
                  min="0"
                  step="0.01"
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary focus:ring-primary sm:text-sm"
                  placeholder="e.g., 50.5"
                />
              </div>
              <div>
                <label htmlFor="parking_slots" className="block text-sm font-medium text-gray-700">
                  Parking Slots
                </label>
                <input
                  type="number"
                  id="parking_slots"
                  name="parking_slots"
                  min="0"
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary focus:ring-primary sm:text-sm"
                  placeholder="e.g., 1"
                />
              </div>
            </div>
            <div className="flex gap-3 pt-4">
              <button
                type="submit"
                disabled={formLoading}
                className="flex-1 bg-primary text-white px-4 py-2 rounded-lg hover:bg-primary-dark transition-colors disabled:opacity-50"
              >
                {formLoading ? 'Creating...' : 'Create Unit'}
              </button>
              <button
                type="button"
                onClick={() => {
                  setShowAddForm(false)
                  setError(null)
                }}
                className="flex-1 bg-gray-200 text-gray-700 px-4 py-2 rounded-lg hover:bg-gray-300 transition-colors"
              >
                Cancel
              </button>
            </div>
          </form>
        </div>
      )}

      {units.length > 0 ? (
        <div className="bg-white rounded-lg border overflow-hidden">
          <table className="w-full">
            <thead className="bg-gray-50 border-b">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Unit #
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Floor
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Type
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Beds/Baths
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Size
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Parking
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {units.map((unit) => (
                <tr key={unit.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">{unit.unit_number}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-700">{unit.floor_number ?? '-'}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-700 capitalize">{unit.unit_type || '-'}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-700">
                      {unit.bedrooms ?? '-'} / {unit.bathrooms ?? '-'}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-700">
                      {unit.square_meters ? `${unit.square_meters} m²` : '-'}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-700">{unit.parking_slots ?? '-'}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span
                      className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                        unit.is_occupied
                          ? 'bg-green-100 text-green-800'
                          : 'bg-gray-100 text-gray-800'
                      }`}
                    >
                      {unit.is_occupied ? 'Occupied' : 'Vacant'}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <button
                      onClick={() => handleDelete(unit.id)}
                      className="text-red-600 hover:text-red-900 transition-colors"
                      title="Delete unit"
                    >
                      <Trash2 className="h-4 w-4" />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : (
        <div className="bg-white rounded-lg border p-12 text-center">
          <Home className="h-12 w-12 text-gray-400 mx-auto mb-4" />
          <h3 className="text-lg font-semibold text-gray-800 mb-2">No units yet</h3>
          <p className="text-gray-600">
            Add residence units to this property to get started.
          </p>
        </div>
      )}
    </div>
  )
}
