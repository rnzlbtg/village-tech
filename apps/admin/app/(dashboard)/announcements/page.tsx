import { createClient } from '@/lib/supabase/server'
import { getTenantId } from '@/lib/auth/helpers'
import { redirect } from 'next/navigation'
import { AnnouncementsPageClient } from './AnnouncementsPageClient'

export const metadata = {
  title: 'Announcements | Admin',
  description: 'Manage community announcements',
}

export default async function AnnouncementsPage({
  searchParams,
}: {
  searchParams: { priority?: 'normal' | 'high' | 'urgent' }
}) {
  const supabase = await createClient()
  const tenantId = await getTenantId()

  if (!tenantId) {
    redirect('/login')
  }

  // Build query with optional priority filter
  let query = supabase
    .from('announcements')
    .select(`
      id,
      title,
      content,
      priority,
      target_audience,
      attachment_urls,
      published_at,
      expires_at,
      is_published,
      published_by,
      created_at
    `)
    .eq('tenant_id', tenantId)
    .eq('is_published', true)
    .order('published_at', { ascending: false })

  if (searchParams.priority) {
    query = query.eq('priority', searchParams.priority)
  }

  const { data: announcements, error } = await query

  if (error) {
    console.error('Error fetching announcements:', error)
  }

  return <AnnouncementsPageClient announcements={announcements || []} searchParams={searchParams} />
}
