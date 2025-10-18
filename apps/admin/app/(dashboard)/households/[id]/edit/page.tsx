'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { ArrowLeft } from 'lucide-react'
import { updateHousehold } from '@/lib/actions/household'
import { createClient } from '@/lib/supabase/client'

export default function EditHouseholdPage({ params }: { params: { id: string } }) {
  const router = useRouter()
  const [loading, setLoading] = useState(false)
  const [fetchLoading, setFetchLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [household, setHousehold] = useState<any>(null)

  useEffect(() => {
    async function fetchHousehold() {
      const supabase = createClient()
      const { data, error } = await supabase
        .from('households')
        .select(`
          *,
          residence_unit:residence_units(
            id,
            unit_number,
            unit_type,
            address,
            property:properties(
              id,
              name
            )
          )
        `)
        .eq('id', params.id)
        .single()

      if (error) {
        setError('Failed to load household')
        setFetchLoading(false)
        return
      }

      setHousehold(data)
      setFetchLoading(false)
    }

    fetchHousehold()
  }, [params.id])

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault()
    setLoading(true)
    setError(null)

    const formData = new FormData(e.currentTarget)
    const result = await updateHousehold(params.id, formData)

    if (result.success) {
      router.push(`/households/${params.id}`)
      router.refresh()
    } else {
      setError(result.error || 'Failed to update household')
      setLoading(false)
    }
  }

  if (fetchLoading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-gray-600">Loading...</div>
      </div>
    )
  }

  if (!household) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-gray-600">Household not found</div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <Link
          href={`/households/${params.id}`}
          className="flex items-center text-gray-600 hover:text-gray-900"
        >
          <ArrowLeft className="h-5 w-5" />
        </Link>
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Edit Household</h1>
          <p className="text-gray-600 mt-1">Update household information</p>
        </div>
      </div>

      {error && (
        <div className="bg-red-50 border border-red-200 text-red-600 px-4 py-3 rounded-lg">
          {error}
        </div>
      )}

      <div className="bg-white rounded-lg shadow">
        <form onSubmit={handleSubmit} className="p-6 space-y-8">
          {/* Residence Unit Section (Read-only) */}
          <div className="space-y-4">
            <h2 className="text-lg font-semibold text-gray-800 border-b pb-2">
              Residence Unit Details
            </h2>
            <div className="bg-gray-50 p-4 rounded-lg space-y-3">
              <p className="text-sm text-gray-600">
                Residence unit details cannot be changed after creation
              </p>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <p className="text-sm font-medium text-gray-700">Property</p>
                  <p className="text-gray-900">
                    {household.residence_unit?.property?.name || 'N/A'}
                  </p>
                </div>
                <div>
                  <p className="text-sm font-medium text-gray-700">Unit Number</p>
                  <p className="text-gray-900">{household.residence_unit?.unit_number || 'N/A'}</p>
                </div>
                <div>
                  <p className="text-sm font-medium text-gray-700">Unit Type</p>
                  <p className="text-gray-900 capitalize">
                    {household.residence_unit?.unit_type || 'N/A'}
                  </p>
                </div>
                {household.residence_unit?.address && (
                  <div>
                    <p className="text-sm font-medium text-gray-700">Address</p>
                    <p className="text-gray-900">{household.residence_unit.address}</p>
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Household Section */}
          <div className="space-y-4">
            <h2 className="text-lg font-semibold text-gray-800 border-b pb-2">
              Household Details
            </h2>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label htmlFor="household_name" className="block text-sm font-medium text-gray-700 mb-2">
                  Household Name <span className="text-red-500">*</span>
                </label>
                <input
                  type="text"
                  id="household_name"
                  name="household_name"
                  required
                  defaultValue={household.household_name}
                  className="block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-primary focus:border-primary"
                  placeholder="Smith Family"
                />
              </div>

              <div>
                <label htmlFor="status" className="block text-sm font-medium text-gray-700 mb-2">
                  Status
                </label>
                <select
                  id="status"
                  name="status"
                  defaultValue={household.status}
                  className="block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-primary focus:border-primary"
                >
                  <option value="active">Active</option>
                  <option value="inactive">Inactive</option>
                  <option value="pending">Pending</option>
                </select>
              </div>

              <div>
                <label htmlFor="move_in_date" className="block text-sm font-medium text-gray-700 mb-2">
                  Move-In Date
                </label>
                <input
                  type="date"
                  id="move_in_date"
                  name="move_in_date"
                  defaultValue={household.move_in_date || ''}
                  className="block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-primary focus:border-primary"
                />
              </div>

              <div>
                <label htmlFor="move_out_date" className="block text-sm font-medium text-gray-700 mb-2">
                  Move-Out Date
                </label>
                <input
                  type="date"
                  id="move_out_date"
                  name="move_out_date"
                  defaultValue={household.move_out_date || ''}
                  className="block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-primary focus:border-primary"
                />
              </div>

              <div className="md:col-span-2">
                <label htmlFor="notes" className="block text-sm font-medium text-gray-700 mb-2">
                  Notes
                </label>
                <textarea
                  id="notes"
                  name="notes"
                  rows={3}
                  defaultValue={household.notes || ''}
                  className="block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-primary focus:border-primary"
                  placeholder="Additional notes or comments"
                />
              </div>
            </div>
          </div>

          <div className="flex justify-end gap-3 pt-4 border-t">
            <Link
              href={`/households/${params.id}`}
              className="px-4 py-2 border border-gray-300 rounded-md hover:bg-gray-50 transition-colors"
            >
              Cancel
            </Link>
            <button
              type="submit"
              disabled={loading}
              className="bg-primary hover:bg-secondary text-white px-4 py-2 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {loading ? 'Saving...' : 'Save Changes'}
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}
