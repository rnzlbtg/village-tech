'use client'

import { useEffect } from 'react'
import { AlertTriangle } from 'lucide-react'

export default function TenantsError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    console.error('Tenants page error:', error)
  }, [error])

  return (
    <div className="flex items-center justify-center min-h-[400px]">
      <div className="text-center space-y-4 max-w-md">
        <div className="flex justify-center">
          <div className="p-4 bg-red-50 rounded-full">
            <AlertTriangle className="h-12 w-12 text-red-500" />
          </div>
        </div>
        <h2 className="text-2xl font-bold text-gray-800">Something went wrong</h2>
        <p className="text-gray-600">
          {error.message || 'An error occurred while loading the communities.'}
        </p>
        <button
          onClick={reset}
          className="px-6 py-2 bg-primary text-white rounded-lg hover:bg-primary/90 transition-colors"
        >
          Try again
        </button>
      </div>
    </div>
  )
}
