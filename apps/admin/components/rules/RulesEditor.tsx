'use client'

import { useState } from 'react'
import { createVillageRules, updateVillageRules } from '@/lib/actions/rules'
import { toast } from 'sonner'
import { useRouter } from 'next/navigation'

export function RulesEditor({
  initialData,
  mode = 'create',
  onSuccess,
  onCancel,
}: {
  initialData?: any
  mode?: 'create' | 'edit'
  onSuccess?: () => void
  onCancel?: () => void
}) {
  const router = useRouter()
  const [loading, setLoading] = useState(false)
  const [formData, setFormData] = useState({
    title: initialData?.title || '',
    content: initialData?.content || '',
    effective_date: initialData?.effective_date || new Date().toISOString().split('T')[0],
    category: initialData?.category || 'general',
  })

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    if (!formData.title.trim()) {
      toast.error('Title is required')
      return
    }

    if (formData.content.length < 50) {
      toast.error('Rules content must be at least 50 characters')
      return
    }

    setLoading(true)

    try {
      let result
      if (mode === 'create') {
        result = await createVillageRules(formData)
      } else {
        result = await updateVillageRules({
          rules_id: initialData.id,
          ...formData,
        })
      }

      if (result.success) {
        toast.success(result.message || `Village rules ${mode === 'create' ? 'created' : 'updated'} successfully`)
        if (onSuccess) {
          onSuccess()
        } else {
          router.push('/rules')
        }
      } else {
        toast.error(result.error || `Failed to ${mode} village rules`)
      }
    } catch (error) {
      toast.error('An error occurred')
    } finally {
      setLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      {/* Title */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Rule Title *
        </label>
        <input
          type="text"
          value={formData.title}
          onChange={e => setFormData(prev => ({ ...prev, title: e.target.value }))}
          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          placeholder="e.g., Community Noise Policy"
          required
        />
      </div>

      {/* Category */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Category
        </label>
        <select
          value={formData.category}
          onChange={e => setFormData(prev => ({ ...prev, category: e.target.value }))}
          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
        >
          <option value="general">General</option>
          <option value="security">Security</option>
          <option value="construction">Construction</option>
          <option value="parking">Parking</option>
          <option value="noise">Noise</option>
          <option value="pets">Pets</option>
          <option value="other">Other</option>
        </select>
      </div>

      {/* Content */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Rules Content *
        </label>
        <textarea
          value={formData.content}
          onChange={e => setFormData(prev => ({ ...prev, content: e.target.value }))}
          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          rows={12}
          placeholder="Enter the detailed rules and guidelines..."
          required
          minLength={50}
        />
        <p className="mt-1 text-xs text-gray-500">
          {formData.content.length} characters (minimum 50)
        </p>
      </div>

      {/* Effective Date */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Effective Date *
        </label>
        <input
          type="date"
          value={formData.effective_date}
          onChange={e => setFormData(prev => ({ ...prev, effective_date: e.target.value }))}
          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          required
        />
        <p className="mt-1 text-xs text-gray-500">
          When these rules take effect
        </p>
      </div>

      {/* Help Text */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <h4 className="text-sm font-medium text-blue-900 mb-2">Formatting Tips:</h4>
        <ul className="text-sm text-blue-800 space-y-1">
          <li>• Use clear, concise language</li>
          <li>• Number or bullet important points</li>
          <li>• Include enforcement procedures if applicable</li>
          <li>• Specify any penalties or consequences</li>
        </ul>
      </div>

      {/* Submit Buttons */}
      <div className="flex gap-3 pt-4 border-t border-gray-200">
        <button
          type="submit"
          disabled={loading}
          className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {loading ? 'Saving...' : mode === 'create' ? 'Create Rule' : 'Update Rule'}
        </button>
        <button
          type="button"
          onClick={onCancel || (() => router.push('/rules'))}
          className="px-6 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200"
        >
          Cancel
        </button>
      </div>
    </form>
  )
}
