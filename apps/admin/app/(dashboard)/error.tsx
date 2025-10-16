'use client'

import { useEffect } from 'react'
import { AlertCircle, Home } from 'lucide-react'
import Link from 'next/link'

export default function DashboardError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    console.error('Dashboard error:', error)
  }, [error])

  return (
    <div className="flex items-center justify-center min-h-[60vh] px-4">
      <div className="max-w-md w-full text-center">
        <div className="inline-flex items-center justify-center w-16 h-16 bg-red-100 rounded-full mb-4">
          <AlertCircle className="h-8 w-8 text-red-600" />
        </div>

        <h2 className="text-2xl font-bold text-gray-900 mb-2">Unable to load this page</h2>
        <p className="text-gray-600 mb-6">
          An error occurred while loading this content. This might be a temporary issue.
        </p>

        {error.digest && (
          <p className="text-sm text-gray-500 mb-4">Error Reference: {error.digest}</p>
        )}

        {process.env.NODE_ENV === 'development' && error.message && (
          <div className="mb-6 p-4 bg-gray-100 rounded-md text-left">
            <p className="text-xs font-mono text-gray-700 break-words">{error.message}</p>
            {error.stack && (
              <pre className="mt-2 text-xs text-gray-600 overflow-x-auto max-h-32">
                {error.stack}
              </pre>
            )}
          </div>
        )}

        <div className="flex flex-col sm:flex-row gap-3 justify-center">
          <button
            onClick={reset}
            className="px-6 py-2 bg-primary text-white rounded-md hover:bg-primary-dark focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 transition-colors"
          >
            Try Again
          </button>
          <Link
            href="/dashboard"
            className="inline-flex items-center justify-center gap-2 px-6 py-2 bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300 focus:outline-none focus:ring-2 focus:ring-gray-400 focus:ring-offset-2 transition-colors"
          >
            <Home className="h-4 w-4" />
            Dashboard Home
          </Link>
        </div>
      </div>
    </div>
  )
}
