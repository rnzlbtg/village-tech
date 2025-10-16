'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { createTenant, updateTenant } from '@/lib/actions/tenant'
import { Tenant } from '@/lib/types/tenant'
import { CheckCircle, AlertTriangle } from 'lucide-react'

interface TenantFormProps {
  initialData?: Tenant
  mode: 'create' | 'edit'
}

export default function TenantForm({ initialData, mode }: TenantFormProps) {
  const router = useRouter()
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState(false)
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({})

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    setLoading(true)
    setError(null)
    setSuccess(false)
    setFieldErrors({})

    const formData = new FormData(e.currentTarget)

    try {
      const result = mode === 'create' ? await createTenant(formData) : await updateTenant(formData)

      if (result.success) {
        setSuccess(true)
        setTimeout(() => {
          router.push('/tenants')
          router.refresh()
        }, 1500)
      } else {
        // Check if error contains field validation errors
        if (result.error?.includes('validation') || result.error?.includes('required')) {
          setError(result.error)
        } else if (result.error?.includes('duplicate') || result.error?.includes('already exists')) {
          setFieldErrors({ name: result.error })
          setError('Please fix the errors below')
        } else {
          setError(result.error || 'An error occurred')
        }
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
              Community {mode === 'create' ? 'created' : 'updated'} successfully! Redirecting...
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
              Community Information
            </h2>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label htmlFor="name" className="block text-sm font-medium text-gray-700 mb-1">
                  Community Name *
                </label>
                <input
                  type="text"
                  id="name"
                  name="name"
                  required
                  defaultValue={initialData?.name}
                  className={`w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary ${
                    fieldErrors.name ? 'border-red-500' : ''
                  }`}
                  placeholder="e.g., Sunset Valley Residences"
                />
                {fieldErrors.name && (
                  <p className="text-red-600 text-sm mt-1">{fieldErrors.name}</p>
                )}
              </div>

              <div>
                <label htmlFor="city" className="block text-sm font-medium text-gray-700 mb-1">
                  City
                </label>
                <input
                  type="text"
                  id="city"
                  name="city"
                  defaultValue={initialData?.city || ''}
                  className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                  placeholder="e.g., Quezon City"
                />
              </div>
            </div>

            <div className="mt-4">
              <label htmlFor="address" className="block text-sm font-medium text-gray-700 mb-1">
                Complete Address *
              </label>
              <input
                type="text"
                id="address"
                name="address"
                required
                defaultValue={initialData?.address}
                className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                placeholder="e.g., 123 Main Street, Barangay Example"
              />
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-4">
              <div>
                <label htmlFor="state" className="block text-sm font-medium text-gray-700 mb-1">
                  State/Province
                </label>
                <input
                  type="text"
                  id="state"
                  name="state"
                  defaultValue={initialData?.state || ''}
                  className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                  placeholder="e.g., Metro Manila"
                />
              </div>

              <div>
                <label htmlFor="country" className="block text-sm font-medium text-gray-700 mb-1">
                  Country
                </label>
                <input
                  type="text"
                  id="country"
                  name="country"
                  defaultValue={initialData?.country || 'Philippines'}
                  className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                />
              </div>

              <div>
                <label htmlFor="postal_code" className="block text-sm font-medium text-gray-700 mb-1">
                  Postal Code
                </label>
                <input
                  type="text"
                  id="postal_code"
                  name="postal_code"
                  defaultValue={initialData?.postal_code || ''}
                  className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                  placeholder="e.g., 1100"
                />
              </div>
            </div>
          </div>

          <div>
            <h2 className="text-xl font-semibold text-gray-800 border-b pb-2 mb-4">
              Contact Information
            </h2>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <div>
                <label
                  htmlFor="contact_name"
                  className="block text-sm font-medium text-gray-700 mb-1"
                >
                  Contact Person
                </label>
                <input
                  type="text"
                  id="contact_name"
                  name="contact_name"
                  defaultValue={initialData?.contact_name || ''}
                  className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                  placeholder="e.g., Juan Dela Cruz"
                />
              </div>

              <div>
                <label
                  htmlFor="contact_email"
                  className="block text-sm font-medium text-gray-700 mb-1"
                >
                  Contact Email
                </label>
                <input
                  type="email"
                  id="contact_email"
                  name="contact_email"
                  defaultValue={initialData?.contact_email || ''}
                  className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                  placeholder="e.g., admin@example.com"
                />
              </div>

              <div>
                <label
                  htmlFor="contact_phone"
                  className="block text-sm font-medium text-gray-700 mb-1"
                >
                  Contact Phone
                </label>
                <input
                  type="tel"
                  id="contact_phone"
                  name="contact_phone"
                  defaultValue={initialData?.contact_phone || ''}
                  className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                  placeholder="e.g., +63 912 345 6789"
                />
              </div>
            </div>
          </div>

          <div className="flex justify-between space-x-4 pt-6 border-t">
            <button
              type="button"
              onClick={() => router.push('/tenants')}
              className="px-4 py-2 border rounded-lg text-gray-700 hover:bg-gray-100 transition-colors duration-200"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={loading}
              className="px-6 py-2 bg-primary hover:bg-secondary text-white rounded-lg transition-colors duration-200 disabled:opacity-70 disabled:cursor-not-allowed"
            >
              {loading ? 'Processing...' : mode === 'create' ? 'Create Community' : 'Save Changes'}
            </button>
        </div>
      </form>
    </div>
  )
}
