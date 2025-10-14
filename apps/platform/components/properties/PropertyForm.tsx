'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { createProperty, updateProperty } from '@/lib/actions/property'
import { Property } from '@/lib/types/property'
import { CheckCircle, AlertTriangle } from 'lucide-react'

interface PropertyFormProps {
  tenantId: string
  initialData?: Property
  mode: 'create' | 'edit'
  onSuccess?: () => void
}

export default function PropertyForm({ tenantId, initialData, mode, onSuccess }: PropertyFormProps) {
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

    try {
      const result = mode === 'create' ? await createProperty(formData) : await updateProperty(formData)

      if (result.success) {
        setSuccess(true)
        setTimeout(() => {
          if (onSuccess) {
            onSuccess()
          } else {
            router.push(`/tenants/${tenantId}/properties`)
            router.refresh()
          }
        }, 1500)
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
              Property {mode === 'create' ? 'created' : 'updated'} successfully! Redirecting...
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

        <div>
          <h2 className="text-xl font-semibold text-gray-800 border-b pb-2 mb-4">
            Property Information
          </h2>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label htmlFor="name" className="block text-sm font-medium text-gray-700 mb-1">
                Property Name *
              </label>
              <input
                type="text"
                id="name"
                name="name"
                required
                defaultValue={initialData?.name}
                className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                placeholder="e.g., Building A"
              />
            </div>

            <div>
              <label htmlFor="property_type" className="block text-sm font-medium text-gray-700 mb-1">
                Property Type
              </label>
              <select
                id="property_type"
                name="property_type"
                defaultValue={initialData?.property_type || 'building'}
                className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
              >
                <option value="building">Building</option>
                <option value="lot">Lot</option>
                <option value="section">Section</option>
                <option value="phase">Phase</option>
              </select>
            </div>
          </div>

          <div className="mt-4">
            <label htmlFor="address" className="block text-sm font-medium text-gray-700 mb-1">
              Address
            </label>
            <input
              type="text"
              id="address"
              name="address"
              defaultValue={initialData?.address}
              className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
              placeholder="e.g., 123 Main Street, Building A"
            />
          </div>

          <div className="mt-4">
            <label htmlFor="description" className="block text-sm font-medium text-gray-700 mb-1">
              Description
            </label>
            <textarea
              id="description"
              name="description"
              rows={3}
              defaultValue={initialData?.description}
              className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
              placeholder="Optional description of the property"
            />
          </div>

          <div className="mt-4">
            <label htmlFor="total_units" className="block text-sm font-medium text-gray-700 mb-1">
              Total Units
            </label>
            <input
              type="number"
              id="total_units"
              name="total_units"
              min="0"
              defaultValue={initialData?.total_units || ''}
              className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
              placeholder="e.g., 50"
            />
          </div>
        </div>

        <div className="flex justify-end space-x-4 pt-6 border-t">
          <button
            type="submit"
            disabled={loading}
            className="px-6 py-2 bg-primary hover:bg-secondary text-white rounded-lg transition-colors duration-200 disabled:opacity-70 disabled:cursor-not-allowed"
          >
            {loading ? 'Processing...' : mode === 'create' ? 'Create Property' : 'Save Changes'}
          </button>
        </div>
      </form>
    </div>
  )
}
