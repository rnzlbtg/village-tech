import { requireAdmin, getTenantId } from '@/lib/auth/helpers'
import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import MainLayout from '@/components/layout/MainLayout'

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const user = await requireAdmin()
  const tenantId = await getTenantId()

  if (!tenantId) {
    redirect('/login')
  }

  const supabase = await createClient()

  // Get tenant name
  const { data: tenant } = await supabase
    .from('tenants')
    .select('name')
    .eq('id', tenantId)
    .single()

  const userName = user.user_metadata?.first_name
    ? `${user.user_metadata.first_name} ${user.user_metadata.last_name || ''}`
    : user.email

  return (
    <MainLayout tenantName={tenant?.name} userName={userName}>
      {children}
    </MainLayout>
  )
}
