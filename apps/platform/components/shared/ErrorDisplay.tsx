import { AlertCircle, RefreshCw, ChevronRight } from 'lucide-react'
import { ErrorWithRecovery } from '@/lib/errors/ErrorMessages'

interface ErrorDisplayProps {
  error: ErrorWithRecovery
  onRetry?: () => void
  className?: string
}

export default function ErrorDisplay({ error, onRetry, className = '' }: ErrorDisplayProps) {
  return (
    <div className={`bg-red-50 border border-red-200 rounded-lg p-6 ${className}`}>
      <div className="flex items-start gap-4">
        <div className="flex-shrink-0">
          <AlertCircle className="h-6 w-6 text-red-600" />
        </div>

        <div className="flex-1 min-w-0">
          {/* Error Title */}
          <h3 className="text-lg font-semibold text-red-900 mb-2">{error.title}</h3>

          {/* Error Message */}
          <p className="text-sm text-red-800 mb-4">{error.message}</p>

          {/* Recovery Steps */}
          {error.recovery && error.recovery.length > 0 && (
            <div className="mb-4">
              <h4 className="text-sm font-semibold text-red-900 mb-2">How to fix this:</h4>
              <ul className="space-y-2">
                {error.recovery.map((step, index) => (
                  <li key={index} className="flex items-start gap-2 text-sm text-red-800">
                    <ChevronRight className="h-4 w-4 flex-shrink-0 mt-0.5 text-red-600" />
                    <span>{step}</span>
                  </li>
                ))}
              </ul>
            </div>
          )}

          {/* Technical Details (Collapsible) */}
          {error.technicalDetails && (
            <details className="mt-4">
              <summary className="text-sm font-medium text-red-900 cursor-pointer hover:text-red-700">
                Technical Details
              </summary>
              <pre className="mt-2 p-3 bg-red-100 rounded text-xs text-red-900 overflow-x-auto">
                {error.technicalDetails}
              </pre>
            </details>
          )}

          {/* Retry Button */}
          {onRetry && (
            <div className="mt-4">
              <button
                onClick={onRetry}
                className="flex items-center gap-2 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors font-medium text-sm"
              >
                <RefreshCw className="h-4 w-4" />
                Try Again
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

/**
 * Inline error display for forms
 */
export function InlineError({ message }: { message: string }) {
  return (
    <div className="flex items-center gap-2 text-sm text-red-600 mt-1">
      <AlertCircle className="h-4 w-4 flex-shrink-0" />
      <span>{message}</span>
    </div>
  )
}

/**
 * Error banner for page-level errors
 */
export function ErrorBanner({
  error,
  onDismiss,
}: {
  error: ErrorWithRecovery
  onDismiss?: () => void
}) {
  return (
    <div className="bg-red-50 border-l-4 border-red-600 p-4 mb-6">
      <div className="flex items-start justify-between">
        <div className="flex items-start gap-3 flex-1">
          <AlertCircle className="h-5 w-5 text-red-600 flex-shrink-0 mt-0.5" />
          <div>
            <h4 className="font-semibold text-red-900">{error.title}</h4>
            <p className="text-sm text-red-800 mt-1">{error.message}</p>
            {error.recovery && error.recovery.length > 0 && (
              <p className="text-sm text-red-700 mt-2">{error.recovery[0]}</p>
            )}
          </div>
        </div>
        {onDismiss && (
          <button
            onClick={onDismiss}
            className="text-red-600 hover:text-red-800 p-1"
            aria-label="Dismiss"
          >
            ×
          </button>
        )}
      </div>
    </div>
  )
}
