'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { ArrowLeft } from 'lucide-react'
import { createProperty } from '@/lib/actions/property'

export default function NewPropertyPage() {
  const router = useRouter()
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault()
    setLoading(true)
    setError(null)

    const formData = new FormData(e.currentTarget)
    const result = await createProperty(formData)

    if (result.success) {
      router.push('/properties')
      router.refresh()
    } else {
      setError(result.error || 'Failed to create property')
      setLoading(false)
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <Link
          href="/properties"
          className="flex items-center text-gray-600 hover:text-gray-900"
        >
          <ArrowLeft className="h-5 w-5" />
        </Link>
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Add New Property</h1>
          <p className="text-gray-600 mt-1">Create a new property in your community</p>
        </div>
      </div>

      {error && (
        <div className="bg-red-50 border border-red-200 text-red-600 px-4 py-3 rounded-lg">
          {error}
        </div>
      )}

      <div className="bg-white rounded-lg shadow p-6">
        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="md:col-span-2">
              <label htmlFor="name" className="block text-sm font-medium text-gray-700">
                Property Name <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                id="name"
                name="name"
                required
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary focus:ring-primary sm:text-sm"
                placeholder="e.g., Phase 1, Building A"
              />
            </div>

            <div className="md:col-span-2">
              <label htmlFor="address" className="block text-sm font-medium text-gray-700">
                Address <span className="text-red-500">*</span>
              </label>
              <textarea
                id="address"
                name="address"
                required
                rows={2}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary focus:ring-primary sm:text-sm"
                placeholder="Full address of the property"
              />
            </div>

            <div>
              <label htmlFor="property_type" className="block text-sm font-medium text-gray-700">
                Property Type
              </label>
              <select
                id="property_type"
                name="property_type"
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary focus:ring-primary sm:text-sm"
              >
                <option value="">Select type</option>
                <option value="residential">Residential</option>
                <option value="commercial">Commercial</option>
                <option value="mixed">Mixed Use</option>
              </select>
            </div>

            <div>
              <label htmlFor="total_units" className="block text-sm font-medium text-gray-700">
                Total Units
              </label>
              <input
                type="number"
                id="total_units"
                name="total_units"
                min="0"
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary focus:ring-primary sm:text-sm"
                placeholder="e.g., 50"
              />
            </div>

            <div>
              <label htmlFor="total_floors" className="block text-sm font-medium text-gray-700">
                Total Floors
              </label>
              <input
                type="number"
                id="total_floors"
                name="total_floors"
                min="0"
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary focus:ring-primary sm:text-sm"
                placeholder="e.g., 10"
              />
            </div>

            <div>
              <label htmlFor="year_built" className="block text-sm font-medium text-gray-700">
                Year Built
              </label>
              <input
                type="number"
                id="year_built"
                name="year_built"
                min="1900"
                max={new Date().getFullYear()}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary focus:ring-primary sm:text-sm"
                placeholder="e.g., 2020"
              />
            </div>

            <div className="md:col-span-2">
              <label htmlFor="lot_size" className="block text-sm font-medium text-gray-700">
                Lot Size (sq meters)
              </label>
              <input
                type="number"
                id="lot_size"
                name="lot_size"
                min="0"
                step="0.01"
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary focus:ring-primary sm:text-sm"
                placeholder="e.g., 5000.50"
              />
            </div>
          </div>

          <div className="flex gap-3 pt-4 border-t">
            <button
              type="submit"
              disabled={loading}
              className="flex-1 bg-primary text-white px-4 py-2 rounded-lg hover:bg-primary-dark transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {loading ? 'Creating...' : 'Create Property'}
            </button>
            <Link
              href="/properties"
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
