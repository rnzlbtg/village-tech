'use client'

import { useEffect } from 'react'
import { AlertCircle } from 'lucide-react'

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    // Log error to console for debugging
    console.error('Application error:', error)
  }, [error])

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
      <div className="max-w-md w-full">
        <div className="bg-white rounded-lg shadow-lg p-8">
          <div className="flex items-center justify-center w-16 h-16 mx-auto bg-red-100 rounded-full">
            <AlertCircle className="h-8 w-8 text-red-600" />
          </div>

          <div className="mt-6 text-center">
            <h1 className="text-2xl font-bold text-gray-900">Something went wrong</h1>
            <p className="mt-2 text-gray-600">
              We encountered an error while processing your request. Please try again.
            </p>

            {error.digest && (
              <p className="mt-4 text-sm text-gray-500">Error ID: {error.digest}</p>
            )}

            {process.env.NODE_ENV === 'development' && (
              <div className="mt-4 p-4 bg-gray-100 rounded-md text-left">
                <p className="text-xs font-mono text-gray-700 break-words">{error.message}</p>
              </div>
            )}
          </div>

          <div className="mt-8 flex gap-4">
            <button
              onClick={reset}
              className="flex-1 px-4 py-2 bg-primary text-white rounded-md hover:bg-primary-dark focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 transition-colors"
            >
              Try Again
            </button>
            <a
              href="/dashboard"
              className="flex-1 px-4 py-2 bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300 focus:outline-none focus:ring-2 focus:ring-gray-400 focus:ring-offset-2 transition-colors text-center"
            >
              Go to Dashboard
            </a>
          </div>
        </div>
      </div>
    </div>
  )
}
