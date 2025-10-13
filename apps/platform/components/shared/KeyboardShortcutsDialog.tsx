'use client'

import { useState, useEffect } from 'react'
import { X, Keyboard } from 'lucide-react'
import { keyboardShortcuts } from '@/lib/hooks/useKeyboardShortcuts'

export default function KeyboardShortcutsDialog() {
  const [isOpen, setIsOpen] = useState(false)

  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      // Open dialog with Shift + ?
      if (event.shiftKey && event.key === '?') {
        event.preventDefault()
        setIsOpen(true)
      }
      // Close dialog with Escape
      if (event.key === 'Escape') {
        setIsOpen(false)
      }
    }

    document.addEventListener('keydown', handleKeyDown)
    return () => document.removeEventListener('keydown', handleKeyDown)
  }, [])

  if (!isOpen) return null

  return (
    <>
      {/* Backdrop */}
      <div
        className="fixed inset-0 bg-black bg-opacity-50 z-50"
        onClick={() => setIsOpen(false)}
      />

      {/* Dialog */}
      <div
        id="keyboard-shortcuts-dialog"
        className="fixed inset-0 z-50 flex items-center justify-center p-4"
      >
        <div className="bg-white rounded-lg shadow-xl max-w-2xl w-full max-h-[80vh] overflow-auto">
          {/* Header */}
          <div className="flex items-center justify-between p-6 border-b">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-primary/10 rounded-lg">
                <Keyboard className="h-6 w-6 text-primary" />
              </div>
              <div>
                <h2 className="text-xl font-bold text-gray-900">Keyboard Shortcuts</h2>
                <p className="text-sm text-gray-600">Speed up your workflow</p>
              </div>
            </div>
            <button
              onClick={() => setIsOpen(false)}
              className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
            >
              <X className="h-5 w-5 text-gray-500" />
            </button>
          </div>

          {/* Shortcuts List */}
          <div className="p-6">
            <div className="space-y-4">
              <div>
                <h3 className="text-sm font-semibold text-gray-900 mb-3 uppercase tracking-wide">
                  Navigation
                </h3>
                <div className="space-y-2">
                  {keyboardShortcuts.slice(0, 4).map((shortcut, index) => (
                    <div
                      key={index}
                      className="flex items-center justify-between py-2 px-3 bg-gray-50 rounded-lg"
                    >
                      <span className="text-sm text-gray-700">{shortcut.description}</span>
                      <kbd className="px-3 py-1 text-xs font-semibold text-gray-800 bg-white border border-gray-300 rounded-md shadow-sm">
                        {shortcut.keys}
                      </kbd>
                    </div>
                  ))}
                </div>
              </div>

              <div>
                <h3 className="text-sm font-semibold text-gray-900 mb-3 uppercase tracking-wide">
                  Actions
                </h3>
                <div className="space-y-2">
                  {keyboardShortcuts.slice(4, 6).map((shortcut, index) => (
                    <div
                      key={index}
                      className="flex items-center justify-between py-2 px-3 bg-gray-50 rounded-lg"
                    >
                      <span className="text-sm text-gray-700">{shortcut.description}</span>
                      <kbd className="px-3 py-1 text-xs font-semibold text-gray-800 bg-white border border-gray-300 rounded-md shadow-sm">
                        {shortcut.keys}
                      </kbd>
                    </div>
                  ))}
                </div>
              </div>

              <div>
                <h3 className="text-sm font-semibold text-gray-900 mb-3 uppercase tracking-wide">
                  Help
                </h3>
                <div className="space-y-2">
                  {keyboardShortcuts.slice(6).map((shortcut, index) => (
                    <div
                      key={index}
                      className="flex items-center justify-between py-2 px-3 bg-gray-50 rounded-lg"
                    >
                      <span className="text-sm text-gray-700">{shortcut.description}</span>
                      <kbd className="px-3 py-1 text-xs font-semibold text-gray-800 bg-white border border-gray-300 rounded-md shadow-sm">
                        {shortcut.keys}
                      </kbd>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>

          {/* Footer */}
          <div className="p-6 border-t bg-gray-50">
            <p className="text-sm text-gray-600 text-center">
              Press <kbd className="px-2 py-1 text-xs font-semibold bg-white border border-gray-300 rounded">Shift + ?</kbd> to open this dialog anytime
            </p>
          </div>
        </div>
      </div>
    </>
  )
}
