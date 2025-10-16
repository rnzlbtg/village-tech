'use client'

import { useState } from 'react'
import { toast } from 'sonner'

export function AnnouncementAttachments({
  attachmentUrls,
  onAttachmentsChange,
}: {
  attachmentUrls: string[]
  onAttachmentsChange: (urls: string[]) => void
}) {
  const [uploading, setUploading] = useState(false)

  const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    if (!e.target.files || e.target.files.length === 0) return

    const files = Array.from(e.target.files)

    // Validate file types (T080)
    const allowedTypes = [
      'application/pdf',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'image/jpeg',
      'image/png',
    ]
    const invalidFiles = files.filter(f => !allowedTypes.includes(f.type))

    if (invalidFiles.length > 0) {
      toast.error('Only PDF, DOCX, JPEG, and PNG files are allowed')
      return
    }

    // Validate file sizes (T080 - 10MB limit)
    const oversizedFiles = files.filter(f => f.size > 10 * 1024 * 1024)
    if (oversizedFiles.length > 0) {
      toast.error('Files must be smaller than 10MB')
      return
    }

    setUploading(true)

    try {
      // TODO: T083 - Upload to Supabase Storage
      // For MVP, simulate upload
      await new Promise(resolve => setTimeout(resolve, 1500))

      // Generate mock URLs (in production, use actual uploaded URLs)
      const mockUrls = files.map(
        file => `/uploads/announcements/${Date.now()}-${file.name}`
      )

      onAttachmentsChange([...attachmentUrls, ...mockUrls])
      toast.success(`${files.length} file(s) uploaded successfully`)

      // Reset file input
      e.target.value = ''
    } catch (error) {
      toast.error('Failed to upload files')
    } finally {
      setUploading(false)
    }
  }

  const handleRemoveFile = (index: number) => {
    const newUrls = attachmentUrls.filter((_, i) => i !== index)
    onAttachmentsChange(newUrls)
    toast.success('File removed')
  }

  return (
    <div className="space-y-3">
      {/* File Input */}
      <div className="flex items-center gap-3">
        <label
          htmlFor="announcement-files"
          className="px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 cursor-pointer text-sm font-medium"
        >
          {uploading ? 'Uploading...' : 'Choose Files'}
        </label>
        <input
          id="announcement-files"
          type="file"
          multiple
          accept=".pdf,.docx,.jpg,.jpeg,.png"
          onChange={handleFileChange}
          disabled={uploading}
          className="hidden"
        />
        <span className="text-xs text-gray-500">PDF, DOCX, JPEG, PNG (max 10MB each)</span>
      </div>

      {/* Uploaded Files List */}
      {attachmentUrls.length > 0 && (
        <div className="bg-gray-50 rounded-lg p-4 space-y-2">
          <p className="text-sm font-medium text-gray-700">Attached Files:</p>
          {attachmentUrls.map((url, index) => (
            <div
              key={index}
              className="flex items-center justify-between bg-white rounded p-2"
            >
              <div className="flex items-center gap-2">
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
                    d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                  />
                </svg>
                <span className="text-sm text-gray-700">{url.split('/').pop()}</span>
              </div>
              <button
                type="button"
                onClick={() => handleRemoveFile(index)}
                className="text-red-600 hover:text-red-800 text-sm"
              >
                Remove
              </button>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
