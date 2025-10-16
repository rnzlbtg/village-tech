'use client'

import { useEffect } from 'react'
import { useRouter } from 'next/navigation'

interface ShortcutConfig {
  key: string
  ctrlKey?: boolean
  shiftKey?: boolean
  action: () => void
  description: string
}

export function useKeyboardShortcuts() {
  const router = useRouter()

  useEffect(() => {
    const shortcuts: ShortcutConfig[] = [
      // Navigation shortcuts
      {
        key: 'h',
        ctrlKey: true,
        action: () => router.push('/'),
        description: 'Go to home/dashboard',
      },
      {
        key: 't',
        ctrlKey: true,
        action: () => router.push('/tenants'),
        description: 'Go to tenants',
      },
      {
        key: 'u',
        ctrlKey: true,
        action: () => router.push('/users'),
        description: 'Go to users',
      },
      {
        key: 'a',
        ctrlKey: true,
        action: () => router.push('/audit-logs'),
        description: 'Go to audit logs',
      },
      // Action shortcuts
      {
        key: 'n',
        ctrlKey: true,
        shiftKey: true,
        action: () => router.push('/tenants/new'),
        description: 'Create new tenant',
      },
      {
        key: 'k',
        ctrlKey: true,
        action: () => {
          // Trigger search modal (if exists)
          const searchInput = document.querySelector('input[type="search"]') as HTMLInputElement
          if (searchInput) {
            searchInput.focus()
          }
        },
        description: 'Focus search',
      },
      // Help shortcut
      {
        key: '?',
        shiftKey: true,
        action: () => {
          // Show keyboard shortcuts help
          const helpDialog = document.getElementById('keyboard-shortcuts-dialog')
          if (helpDialog) {
            helpDialog.style.display = 'block'
          }
        },
        description: 'Show keyboard shortcuts',
      },
    ]

    const handleKeyDown = (event: KeyboardEvent) => {
      const target = event.target as HTMLElement

      // Don't trigger shortcuts when typing in input fields
      if (
        target.tagName === 'INPUT' ||
        target.tagName === 'TEXTAREA' ||
        target.isContentEditable
      ) {
        // Allow Ctrl+K for search even in inputs
        if (!(event.ctrlKey && event.key === 'k')) {
          return
        }
      }

      shortcuts.forEach((shortcut) => {
        const matchesKey = event.key.toLowerCase() === shortcut.key.toLowerCase()
        const matchesCtrl = shortcut.ctrlKey ? event.ctrlKey : !event.ctrlKey
        const matchesShift = shortcut.shiftKey ? event.shiftKey : !event.shiftKey

        if (matchesKey && matchesCtrl && matchesShift) {
          event.preventDefault()
          shortcut.action()
        }
      })
    }

    document.addEventListener('keydown', handleKeyDown)

    return () => {
      document.removeEventListener('keydown', handleKeyDown)
    }
  }, [router])

  return null
}

// Export shortcuts configuration for help dialog
export const keyboardShortcuts = [
  { keys: 'Ctrl + H', description: 'Go to home/dashboard' },
  { keys: 'Ctrl + T', description: 'Go to tenants' },
  { keys: 'Ctrl + U', description: 'Go to users' },
  { keys: 'Ctrl + A', description: 'Go to audit logs' },
  { keys: 'Ctrl + Shift + N', description: 'Create new tenant' },
  { keys: 'Ctrl + K', description: 'Focus search' },
  { keys: 'Shift + ?', description: 'Show keyboard shortcuts' },
  { keys: 'Esc', description: 'Close modals/dialogs' },
]
