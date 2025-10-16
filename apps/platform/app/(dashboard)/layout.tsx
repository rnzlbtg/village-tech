import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import MobileDashboardLayout from '@/components/layout/MobileDashboardLayout'
import KeyboardShortcutsProvider from '@/components/shared/KeyboardShortcutsProvider'

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const supabase = await createClient()

  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) {
    redirect('/login')
  }

  return (
    <KeyboardShortcutsProvider>
      <MobileDashboardLayout>{children}</MobileDashboardLayout>
    </KeyboardShortcutsProvider>
  )
}
