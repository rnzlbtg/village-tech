'use client'

import { useEffect } from 'react'

interface CreateRuleModalProps {
  isOpen: boolean
  onClose: () => void
  onSuccess?: () => void
}

export function CreateRuleModal({ isOpen, onClose, onSuccess }: CreateRuleModalProps) {
  useEffect(() => {
    const handleEscape = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && isOpen) {
        onClose()
      }
    }

    if (isOpen) {
      document.body.style.overflow = 'hidden'
      document.addEventListener('keydown', handleEscape)
    } else {
      document.body.style.overflow = 'unset'
    }

    return () => {
      document.body.style.overflow = 'unset'
      document.removeEventListener('keydown', handleEscape)
    }
  }, [isOpen, onClose])

  if (!isOpen) return null

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto">
      <div className="flex min-h-screen items-center justify-center p-4">
        {/* Backdrop */}
        <div
          className="fixed inset-0 bg-black bg-opacity-50 transition-opacity"
          onClick={onClose}
        />

        {/* Modal */}
        <div className="relative w-full max-w-4xl transform rounded-lg bg-white shadow-xl transition-all">
          {/* Header */}
          <div className="flex items-center justify-between p-6 border-b border-gray-200">
            <h2 className="text-xl font-semibold text-gray-900">Create New Village Rule</h2>
            <button
              onClick={onClose}
              className="text-gray-400 hover:text-gray-600 transition-colors"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>

          {/* Content */}
          <div className="p-6">
            <RulesEditorWithCallbacks
              onSuccess={onSuccess || onClose}
              onCancel={onClose}
            />
          </div>
        </div>
      </div>
    </div>
  )
}

// Import RulesEditor at the bottom to avoid circular imports
import { RulesEditor } from './RulesEditor'

// Forward ref to pass callbacks to RulesEditor
function RulesEditorWithCallbacks({ onSuccess, onCancel }: { onSuccess: () => void; onCancel: () => void }) {
  return (
    <RulesEditor
      mode="create"
      onSuccess={onSuccess}
      onCancel={onCancel}
    />
  )
}