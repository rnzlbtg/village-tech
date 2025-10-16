'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { createResidenceUnit, updateResidenceUnit } from '@/lib/actions/residence-unit'
import { ResidenceUnit } from '@/lib/types/residence-unit'
import { CheckCircle, AlertTriangle } from 'lucide-react'

interface ResidenceUnitFormProps {
  tenantId: string
  propertyId: string
  initialData?: ResidenceUnit
  mode: 'create' | 'edit'
  onSuccess?: () => void
}

export default function ResidenceUnitForm({ tenantId, propertyId, initialData, mode, onSuccess }: ResidenceUnitFormProps) {
  const router = useRouter()
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState(false)

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    setLoading(true)
    setError(null)
    setSuccess(false)

    const formData = new FormData(e.currentTarget)
    formData.append('tenant_id', tenantId)
    formData.append('property_id', propertyId)

    try {
      const result = mode === 'create' ? await createResidenceUnit(formData) : await updateResidenceUnit(formData)

      if (result.success) {
        setSuccess(true)
        if (onSuccess) {
          onSuccess()
        } else {
          setTimeout(() => {
            router.push(`/tenants/${tenantId}/properties/${propertyId}`)
            router.refresh()
          }, 1500)
        }
      } else {
        setError(result.error || 'An error occurred')
      }
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'An unexpected error occurred'
      setError(errorMessage)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="space-y-6">
      {success && (
        <div className="bg-primary-light border-l-4 border-primary p-4 rounded-md">
          <div className="flex items-center">
            <CheckCircle className="h-5 w-5 text-primary mr-2" />
            <p className="text-primary">
              Unit {mode === 'create' ? 'created' : 'updated'} successfully!
            </p>
          </div>
        </div>
      )}

      {error && (
        <div className="bg-red-50 border-l-4 border-red-500 p-4 rounded-md">
          <div className="flex items-center">
            <AlertTriangle className="h-5 w-5 text-red-500 mr-2" />
            <p className="text-red-700">{error}</p>
          </div>
        </div>
      )}

      <form onSubmit={handleSubmit} className="space-y-6">
        {mode === 'edit' && <input type="hidden" name="id" value={initialData?.id} />}

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div>
            <label htmlFor="unit_number" className="block text-sm font-medium text-gray-700 mb-1">
              Unit Number *
            </label>
            <input
              type="text"
              id="unit_number"
              name="unit_number"
              required
              defaultValue={initialData?.unit_number}
              className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
              placeholder="e.g., 101"
            />
          </div>

          <div>
            <label htmlFor="floor_number" className="block text-sm font-medium text-gray-700 mb-1">
              Floor Number
            </label>
            <input
              type="number"
              id="floor_number"
              name="floor_number"
              min="0"
              defaultValue={initialData?.floor_number || ''}
              className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
              placeholder="e.g., 1"
            />
          </div>

          <div>
            <label htmlFor="unit_type" className="block text-sm font-medium text-gray-700 mb-1">
              Unit Type
            </label>
            <select
              id="unit_type"
              name="unit_type"
              defaultValue={initialData?.unit_type || 'apartment'}
              className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
            >
              <option value="apartment">Apartment</option>
              <option value="house">House</option>
              <option value="townhouse">Townhouse</option>
              <option value="condo">Condo</option>
              <option value="studio">Studio</option>
              <option value="other">Other</option>
            </select>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
          <div>
            <label htmlFor="bedrooms" className="block text-sm font-medium text-gray-700 mb-1">
              Bedrooms
            </label>
            <input
              type="number"
              id="bedrooms"
              name="bedrooms"
              min="0"
              defaultValue={initialData?.bedrooms || ''}
              className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
              placeholder="e.g., 2"
            />
          </div>

          <div>
            <label htmlFor="bathrooms" className="block text-sm font-medium text-gray-700 mb-1">
              Bathrooms
            </label>
            <input
              type="number"
              id="bathrooms"
              name="bathrooms"
              min="0"
              step="0.5"
              defaultValue={initialData?.bathrooms || ''}
              className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
              placeholder="e.g., 1.5"
            />
          </div>

          <div>
            <label htmlFor="square_meters" className="block text-sm font-medium text-gray-700 mb-1">
              Size (sq m)
            </label>
            <input
              type="number"
              id="square_meters"
              name="square_meters"
              min="0"
              step="0.01"
              defaultValue={initialData?.square_meters || ''}
              className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
              placeholder="e.g., 75"
            />
          </div>

          <div>
            <label htmlFor="parking_slots" className="block text-sm font-medium text-gray-700 mb-1">
              Parking Slots
            </label>
            <input
              type="number"
              id="parking_slots"
              name="parking_slots"
              min="0"
              defaultValue={initialData?.parking_slots || ''}
              className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
              placeholder="e.g., 1"
            />
          </div>
        </div>

        <div>
          <label className="flex items-center space-x-2">
            <input
              type="checkbox"
              name="is_occupied"
              value="true"
              defaultChecked={initialData?.is_occupied}
              className="w-4 h-4 text-primary focus:ring-primary border-gray-300 rounded"
            />
            <span className="text-sm font-medium text-gray-700">Currently Occupied</span>
          </label>
        </div>

        <div>
          <label htmlFor="notes" className="block text-sm font-medium text-gray-700 mb-1">
            Notes
          </label>
          <textarea
            id="notes"
            name="notes"
            rows={3}
            defaultValue={initialData?.notes || ''}
            className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
            placeholder="Additional information about this unit..."
          />
        </div>

        <div className="flex justify-end space-x-4 pt-6 border-t">
          <button
            type="button"
            onClick={() => onSuccess ? onSuccess() : router.back()}
            className="px-4 py-2 border rounded-lg text-gray-700 hover:bg-gray-100 transition-colors duration-200"
          >
            Cancel
          </button>
          <button
            type="submit"
            disabled={loading}
            className="px-6 py-2 bg-primary hover:bg-secondary text-white rounded-lg transition-colors duration-200 disabled:opacity-70 disabled:cursor-not-allowed"
          >
            {loading ? 'Processing...' : mode === 'create' ? 'Create Unit' : 'Save Changes'}
          </button>
        </div>
      </form>
    </div>
  )
}
