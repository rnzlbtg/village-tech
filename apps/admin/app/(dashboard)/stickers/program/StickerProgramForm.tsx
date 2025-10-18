'use client'

import { useState } from 'react'
import { setStickerProgram } from '@/lib/actions/stickers'
import { toast } from 'sonner'

export default function StickerProgramForm() {
  const [formData, setFormData] = useState({
    program_name: '',
    program_year: new Date().getFullYear(),
    stickers_per_household: 2,
    effective_date: new Date().toISOString().split('T')[0],
    expiry_date: '',
  })
  const [loading, setLoading] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)

    try {
      const result = await setStickerProgram({
        program_name: formData.program_name,
        program_year: formData.program_year,
        stickers_per_household: formData.stickers_per_household,
        effective_date: formData.effective_date,
        expiry_date: formData.expiry_date || undefined,
      })

      if (result.success) {
        toast.success('Sticker program configured successfully')
        // Reset form
        setFormData({
          program_name: '',
          program_year: new Date().getFullYear(),
          stickers_per_household: 2,
          effective_date: new Date().toISOString().split('T')[0],
          expiry_date: '',
        })
        window.location.reload()
      } else {
        toast.error(result.error || 'Failed to configure program')
      }
    } catch (error) {
      toast.error('Failed to configure program')
    } finally {
      setLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div>
        <label htmlFor="program_name" className="block text-sm font-medium mb-2">
          Program Name *
        </label>
        <input
          type="text"
          id="program_name"
          value={formData.program_name}
          onChange={(e) => setFormData({ ...formData, program_name: e.target.value })}
          placeholder="e.g., 2025 Vehicle Sticker Program"
          className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
          required
        />
      </div>

      <div>
        <label htmlFor="program_year" className="block text-sm font-medium mb-2">
          Program Year *
        </label>
        <input
          type="number"
          id="program_year"
          value={formData.program_year}
          onChange={(e) => setFormData({ ...formData, program_year: parseInt(e.target.value) })}
          min="2020"
          max="2100"
          className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
          required
        />
      </div>

      <div>
        <label htmlFor="stickers_per_household" className="block text-sm font-medium mb-2">
          Stickers per Household *
        </label>
        <input
          type="number"
          id="stickers_per_household"
          value={formData.stickers_per_household}
          onChange={(e) =>
            setFormData({ ...formData, stickers_per_household: parseInt(e.target.value) })
          }
          min="1"
          max="10"
          className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
          required
        />
        <p className="text-xs text-gray-600 mt-1">
          Maximum number of vehicle stickers allowed per household
        </p>
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div>
          <label htmlFor="effective_date" className="block text-sm font-medium mb-2">
            Effective Date *
          </label>
          <input
            type="date"
            id="effective_date"
            value={formData.effective_date}
            onChange={(e) => setFormData({ ...formData, effective_date: e.target.value })}
            className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            required
          />
        </div>

        <div>
          <label htmlFor="expiry_date" className="block text-sm font-medium mb-2">
            Expiry Date (Optional)
          </label>
          <input
            type="date"
            id="expiry_date"
            value={formData.expiry_date}
            onChange={(e) => setFormData({ ...formData, expiry_date: e.target.value })}
            min={formData.effective_date}
            className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          <p className="text-xs text-gray-600 mt-1">Leave empty for no expiry</p>
        </div>
      </div>

      <div className="flex gap-3">
        <button
          type="submit"
          disabled={loading}
          className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
        >
          {loading ? 'Creating...' : 'Create Program'}
        </button>
        <a
          href="/stickers"
          className="px-6 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
        >
          Cancel
        </a>
      </div>
    </form>
  )
}
