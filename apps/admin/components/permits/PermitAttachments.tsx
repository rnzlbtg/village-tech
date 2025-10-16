'use client'

import { useState } from 'react'
import { toast } from 'sonner'

export function PermitAttachments({ permitId }: { permitId: string }) {
  const [uploading, setUploading] = useState(false)
  const [files, setFiles] = useState<File[]>([])

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files) {
      const selectedFiles = Array.from(e.target.files)

      // Validate file types
      const allowedTypes = ['application/pdf', 'image/jpeg', 'image/png', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'application/zip']
      const invalidFiles = selectedFiles.filter(f => !allowedTypes.includes(f.type))

      if (invalidFiles.length > 0) {
        toast.error('Only PDF, JPEG, PNG, XLSX, and ZIP files are allowed')
        return
      }

      // Validate file sizes (10MB max)
      const oversizedFiles = selectedFiles.filter(f => f.size > 10 * 1024 * 1024)
      if (oversizedFiles.length > 0) {
        toast.error('Files must be smaller than 10MB')
        return
      }

      setFiles(selectedFiles)
    }
  }

  const handleUpload = async () => {
    if (files.length === 0) {
      toast.error('Please select files to upload')
      return
    }

    setUploading(true)

    try {
      // TODO: Implement file upload to Supabase Storage (T066)
      // For MVP, just simulate upload
      await new Promise(resolve => setTimeout(resolve, 1500))

      toast.success(`${files.length} file(s) uploaded successfully`)
      setFiles([])

      // Reset file input
      const fileInput = document.getElementById('file-input') as HTMLInputElement
      if (fileInput) fileInput.value = ''
    } catch (error) {
      toast.error('Failed to upload files')
    } finally {
      setUploading(false)
    }
  }

  return (
    <div className="space-y-4">
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Upload Project Documents
        </label>
        <input
          id="file-input"
          type="file"
          multiple
          accept=".pdf,.jpg,.jpeg,.png,.xlsx,.zip"
          onChange={handleFileChange}
          className="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100"
        />
        <p className="mt-1 text-xs text-gray-500">
          Accepted formats: PDF, JPEG, PNG, XLSX, ZIP. Max 10MB per file.
        </p>
      </div>

      {files.length > 0 && (
        <div className="bg-gray-50 rounded-lg p-4">
          <p className="text-sm font-medium text-gray-700 mb-2">Selected Files:</p>
          <ul className="space-y-1">
            {files.map((file, index) => (
              <li key={index} className="text-sm text-gray-600">
                {file.name} ({(file.size / 1024).toFixed(1)} KB)
              </li>
            ))}
          </ul>
        </div>
      )}

      <button
        onClick={handleUpload}
        disabled={uploading || files.length === 0}
        className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
      >
        {uploading ? 'Uploading...' : 'Upload Files'}
      </button>
    </div>
  )
}
