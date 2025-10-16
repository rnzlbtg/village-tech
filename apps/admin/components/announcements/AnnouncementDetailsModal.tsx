'use client'

import { X } from 'lucide-react'

interface Announcement {
  id: string
  title: string
  content: string
  priority: 'normal' | 'high' | 'urgent'
  target_audience: string[]
  attachment_urls?: string[]
  published_at: string
  expires_at?: string
  is_published: boolean
  published_by: string
  created_at: string
}

interface AnnouncementDetailsModalProps {
  announcement: Announcement | null
  isOpen: boolean
  onClose: () => void
}

export function AnnouncementDetailsModal({
  announcement,
  isOpen,
  onClose,
}: AnnouncementDetailsModalProps) {
  if (!announcement || !isOpen) return null

  const priorityColors = {
    normal: 'bg-blue-100 text-blue-800',
    high: 'bg-yellow-100 text-yellow-800',
    urgent: 'bg-red-100 text-red-800',
  }

  const audienceLabels: Record<string, string> = {
    residents: 'Residents',
    guards: 'Security Guards',
    security: 'Security Team',
    all: 'All Users',
  }

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto">
      <div className="flex min-h-screen items-center justify-center p-4">
        {/* Backdrop */}
        <div
          className="fixed inset-0 bg-black bg-opacity-50 transition-opacity"
          onClick={onClose}
        />

        {/* Modal */}
        <div className="relative w-full max-w-2xl transform rounded-lg bg-white shadow-xl">
          <div className="p-6">
            <div className="flex items-start justify-between mb-4">
              <div className="flex items-center gap-3">
                <h2 className="text-xl font-semibold text-gray-900">{announcement.title}</h2>
                <span
                  className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                    priorityColors[announcement.priority] || 'bg-gray-100 text-gray-800'
                  }`}
                >
                  {announcement.priority.toUpperCase()}
                </span>
              </div>
              <button type="button" className="text-gray-400 hover:text-gray-500" onClick={onClose}>
                <X className="h-6 w-6" />
              </button>
            </div>

            <div className="space-y-4">
              {/* Metadata */}
              <div className="flex flex-wrap items-center gap-4 text-sm text-gray-600 pb-4 border-b">
                <div>
                  Published: {new Date(announcement.published_at).toLocaleDateString()} at{' '}
                  {new Date(announcement.published_at).toLocaleTimeString()}
                </div>
                {announcement.expires_at && (
                  <div>Expires: {new Date(announcement.expires_at).toLocaleDateString()}</div>
                )}
                <div>By Admin</div>
              </div>

              {/* Target Audience */}
              <div>
                <h4 className="text-sm font-semibold text-gray-900 mb-2">Target Audience</h4>
                <div className="flex flex-wrap gap-2">
                  {announcement.target_audience.map((audience) => (
                    <span
                      key={audience}
                      className="inline-flex px-3 py-1 text-sm bg-gray-100 text-gray-700 rounded-md"
                    >
                      {audienceLabels[audience] || audience}
                    </span>
                  ))}
                </div>
              </div>

              {/* Content */}
              <div>
                <h4 className="text-sm font-semibold text-gray-900 mb-2">Message</h4>
                <div className="prose prose-sm max-w-none text-gray-700 whitespace-pre-wrap">
                  {announcement.content}
                </div>
              </div>

              {/* Attachments */}
              {announcement.attachment_urls && announcement.attachment_urls.length > 0 && (
                <div>
                  <h4 className="text-sm font-semibold text-gray-900 mb-2">Attachments</h4>
                  <div className="space-y-2">
                    {announcement.attachment_urls.map((url, index) => (
                      <div
                        key={index}
                        className="flex items-center gap-2 p-2 bg-gray-50 rounded-md"
                      >
                        <svg
                          className="w-4 h-4 text-gray-400"
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
                        <a
                          href={url}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="text-sm text-blue-600 hover:text-blue-800 truncate"
                        >
                          {url.split('/').pop() || `Attachment ${index + 1}`}
                        </a>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Footer Actions */}
              <div className="flex justify-end pt-4 border-t">
                <button
                  type="button"
                  className="px-4 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500"
                  onClick={onClose}
                >
                  Close
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
