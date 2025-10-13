'use client'

import { useState } from 'react'
import { createAnnouncement } from '@/lib/actions/announcements'
import { toast } from 'sonner'
import { useRouter } from 'next/navigation'
import { AnnouncementAttachments } from './AnnouncementAttachments'
import { PrioritySelector } from './PrioritySelector'

const AUDIENCE_OPTIONS = [
  { value: 'residents', label: 'Residents' },
  { value: 'guards', label: 'Gate Guards' },
  { value: 'security', label: 'Roaming Security' },
  { value: 'admin', label: 'Admin Staff' },
]

export function AnnouncementForm() {
  const router = useRouter()
  const [loading, setLoading] = useState(false)
  const [formData, setFormData] = useState({
    title: '',
    content: '',
    priority: 'normal' as 'normal' | 'high' | 'urgent',
    target_audience: ['residents'] as string[],
    attachment_urls: [] as string[],
    expires_at: '',
  })

  const handleAudienceToggle = (audience: string) => {
    setFormData(prev => ({
      ...prev,
      target_audience: prev.target_audience.includes(audience)
        ? prev.target_audience.filter(a => a !== audience)
        : [...prev.target_audience, audience],
    }))
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    if (!formData.title.trim()) {
      toast.error('Title is required')
      return
    }

    if (!formData.content.trim()) {
      toast.error('Content is required')
      return
    }

    if (formData.target_audience.length === 0) {
      toast.error('Select at least one target audience')
      return
    }

    setLoading(true)

    try {
      const result = await createAnnouncement({
        title: formData.title,
        content: formData.content,
        priority: formData.priority,
        target_audience: formData.target_audience,
        attachment_urls: formData.attachment_urls.length > 0 ? formData.attachment_urls : undefined,
        expires_at: formData.expires_at || undefined,
      })

      if (result.success) {
        toast.success(result.message || 'Announcement created successfully')
        router.push('/announcements')
      } else {
        toast.error(result.error || 'Failed to create announcement')
      }
    } catch (error) {
      toast.error('An error occurred')
    } finally {
      setLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="bg-white rounded-lg shadow p-6 space-y-6">
      {/* Title */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Title *
        </label>
        <input
          type="text"
          value={formData.title}
          onChange={e => setFormData(prev => ({ ...prev, title: e.target.value }))}
          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          placeholder="Enter announcement title..."
          required
        />
      </div>

      {/* Content */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Content *
        </label>
        <textarea
          value={formData.content}
          onChange={e => setFormData(prev => ({ ...prev, content: e.target.value }))}
          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          rows={6}
          placeholder="Enter announcement content..."
          required
        />
        <p className="mt-1 text-xs text-gray-500">{formData.content.length} characters</p>
      </div>

      {/* Priority */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Priority *
        </label>
        <PrioritySelector
          value={formData.priority}
          onChange={priority => setFormData(prev => ({ ...prev, priority }))}
        />
      </div>

      {/* Target Audience */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Target Audience *
        </label>
        <div className="space-y-2">
          {AUDIENCE_OPTIONS.map(option => (
            <label key={option.value} className="flex items-center">
              <input
                type="checkbox"
                checked={formData.target_audience.includes(option.value)}
                onChange={() => handleAudienceToggle(option.value)}
                className="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
              />
              <span className="ml-2 text-sm text-gray-700">{option.label}</span>
            </label>
          ))}
        </div>
      </div>

      {/* File Attachments */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Attachments (Optional)
        </label>
        <AnnouncementAttachments
          attachmentUrls={formData.attachment_urls}
          onAttachmentsChange={urls => setFormData(prev => ({ ...prev, attachment_urls: urls }))}
        />
      </div>

      {/* Expiration Date */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Expiration Date (Optional)
        </label>
        <input
          type="datetime-local"
          value={formData.expires_at}
          onChange={e => setFormData(prev => ({ ...prev, expires_at: e.target.value }))}
          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
        />
        <p className="mt-1 text-xs text-gray-500">
          Leave empty for permanent announcement
        </p>
      </div>

      {/* Urgent Warning */}
      {formData.priority === 'urgent' && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-4">
          <div className="flex">
            <svg
              className="w-5 h-5 text-red-600 mr-2"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
              />
            </svg>
            <div>
              <h4 className="text-sm font-medium text-red-800">Urgent Announcement</h4>
              <p className="text-sm text-red-700 mt-1">
                Push notifications will be sent to all selected recipients immediately.
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Submit Buttons */}
      <div className="flex gap-3 pt-4 border-t border-gray-200">
        <button
          type="submit"
          disabled={loading}
          className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {loading ? 'Publishing...' : 'Publish Announcement'}
        </button>
        <a
          href="/announcements"
          className="px-6 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200"
        >
          Cancel
        </a>
      </div>
    </form>
  )
}
