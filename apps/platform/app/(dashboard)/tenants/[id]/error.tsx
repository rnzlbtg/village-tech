'use client'

import { useEffect } from 'react'
import Link from 'next/link'
import { AlertTriangle, ArrowLeft } from 'lucide-react'

export default function TenantDetailError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    console.error('Tenant detail error:', error)
  }, [error])

  return (
    <div className="space-y-6">
      <Link
        href="/tenants"
        className="inline-flex items-center text-gray-600 hover:text-gray-800 transition-colors"
      >
        <ArrowLeft className="h-5 w-5 mr-2" />
        Back to Communities
      </Link>

      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center space-y-4 max-w-md">
          <div className="flex justify-center">
            <div className="p-4 bg-red-50 rounded-full">
              <AlertTriangle className="h-12 w-12 text-red-500" />
            </div>
          </div>
          <h2 className="text-2xl font-bold text-gray-800">Failed to load community</h2>
          <p className="text-gray-600">
            {error.message || 'An error occurred while loading the community details.'}
          </p>
          <div className="flex justify-center space-x-4">
            <button
              onClick={reset}
              className="px-6 py-2 bg-primary text-white rounded-lg hover:bg-primary/90 transition-colors"
            >
              Try again
            </button>
            <Link
              href="/tenants"
              className="px-6 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors"
            >
              Go back
            </Link>
          </div>
        </div>
      </div>
    </div>
  )
}
