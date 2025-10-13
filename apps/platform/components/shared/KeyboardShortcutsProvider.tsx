'use client'

import { useKeyboardShortcuts } from '@/lib/hooks/useKeyboardShortcuts'
import KeyboardShortcutsDialog from './KeyboardShortcutsDialog'

export default function KeyboardShortcutsProvider({
  children,
}: {
  children: React.ReactNode
}) {
  useKeyboardShortcuts()

  return (
    <>
      {children}
      <KeyboardShortcutsDialog />
    </>
  )
}
