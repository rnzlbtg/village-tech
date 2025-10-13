import { createClient } from '@/lib/supabase/server'
import { getTenantId } from '@/lib/auth/helpers'
import { redirect } from 'next/navigation'

export const metadata = {
  title: 'Announcements | Admin',
  description: 'Manage community announcements',
}

type AnnouncementPriority = 'normal' | 'high' | 'urgent'

export default async function AnnouncementsPage({
  searchParams,
}: {
  searchParams: { priority?: AnnouncementPriority }
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
      active,
      created_by,
      created_at,
      creator:user_profiles!announcements_created_by_fkey(full_name)
    `)
    .eq('tenant_id', tenantId)
    .eq('active', true)
    .order('published_at', { ascending: false })

  if (searchParams.priority) {
    query = query.eq('priority', searchParams.priority)
  }

  const { data: announcements, error } = await query

  if (error) {
    console.error('Error fetching announcements:', error)
  }

  const priorityCounts = {
    all: announcements?.length || 0,
    normal: announcements?.filter(a => a.priority === 'normal').length || 0,
    high: announcements?.filter(a => a.priority === 'high').length || 0,
    urgent: announcements?.filter(a => a.priority === 'urgent').length || 0,
  }

  return (
    <div className="container mx-auto py-6">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-3xl font-bold">Community Announcements</h1>
          <p className="text-gray-600 mt-1">Create and manage announcements for residents and staff</p>
        </div>
        <a
          href="/announcements/new"
          className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
        >
          Create Announcement
        </a>
      </div>

      {/* Priority Filters */}
      <div className="mb-6 flex gap-2 flex-wrap">
        <PriorityFilterButton
          priority={null}
          label="All"
          count={priorityCounts.all}
          current={searchParams.priority}
        />
        <PriorityFilterButton
          priority="normal"
          label="Normal"
          count={priorityCounts.normal}
          current={searchParams.priority}
        />
        <PriorityFilterButton
          priority="high"
          label="High"
          count={priorityCounts.high}
          current={searchParams.priority}
        />
        <PriorityFilterButton
          priority="urgent"
          label="Urgent"
          count={priorityCounts.urgent}
          current={searchParams.priority}
        />
      </div>

      {/* Announcements Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {announcements && announcements.length > 0 ? (
          announcements.map((announcement: any) => (
            <div
              key={announcement.id}
              className="bg-white rounded-lg shadow hover:shadow-lg transition-shadow"
            >
              <div className="p-6">
                <div className="flex items-start justify-between mb-3">
                  <PriorityBadge priority={announcement.priority} />
                  <span className="text-xs text-gray-500">
                    {new Date(announcement.published_at).toLocaleDateString()}
                  </span>
                </div>

                <h3 className="text-lg font-semibold text-gray-900 mb-2">{announcement.title}</h3>

                <p className="text-sm text-gray-600 mb-4 line-clamp-3">{announcement.content}</p>

                <div className="flex flex-wrap gap-1 mb-4">
                  {announcement.target_audience.map((audience: string) => (
                    <span
                      key={audience}
                      className="inline-flex px-2 py-1 text-xs bg-gray-100 text-gray-700 rounded"
                    >
                      {audience}
                    </span>
                  ))}
                </div>

                {announcement.attachment_urls && announcement.attachment_urls.length > 0 && (
                  <div className="flex items-center text-xs text-gray-500 mb-4">
                    <svg
                      className="w-4 h-4 mr-1"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth={2}
                        d="M15.172 7l-6.586 6.586a2 2 0 102.828 2.828l6.414-6.586a4 4 0 00-5.656-5.656l-6.415 6.585a6 6 0 108.486 8.486L20.5 13"
                      />
                    </svg>
                    {announcement.attachment_urls.length} attachment(s)
                  </div>
                )}

                <div className="flex items-center justify-between pt-4 border-t border-gray-100">
                  <span className="text-xs text-gray-500">
                    By {announcement.creator?.full_name || 'Admin'}
                  </span>
                  <a
                    href={`/announcements/${announcement.id}`}
                    className="text-sm text-blue-600 hover:text-blue-800 font-medium"
                  >
                    View Details →
                  </a>
                </div>
              </div>
            </div>
          ))
        ) : (
          <div className="col-span-full text-center py-12 text-gray-500">
            {searchParams.priority
              ? `No ${searchParams.priority} priority announcements found`
              : 'No announcements yet. Create your first announcement!'}
          </div>
        )}
      </div>
    </div>
  )
}

function PriorityFilterButton({
  priority,
  label,
  count,
  current,
}: {
  priority: AnnouncementPriority | null
  label: string
  count: number
  current?: AnnouncementPriority
}) {
  const isActive = (priority === null && !current) || priority === current
  const href = priority ? `/announcements?priority=${priority}` : '/announcements'

  return (
    <a
      href={href}
      className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
        isActive ? 'bg-blue-600 text-white' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
      }`}
    >
      {label} <span className="ml-1">({count})</span>
    </a>
  )
}

function PriorityBadge({ priority }: { priority: string }) {
  const colors: Record<string, string> = {
    normal: 'bg-blue-100 text-blue-800',
    high: 'bg-yellow-100 text-yellow-800',
    urgent: 'bg-red-100 text-red-800',
  }

  return (
    <span
      className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
        colors[priority] || 'bg-gray-100 text-gray-800'
      }`}
    >
      {priority}
    </span>
  )
}
