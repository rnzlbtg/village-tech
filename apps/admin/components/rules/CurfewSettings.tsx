'use client'

import { useState } from 'react'
import { setCurfewTimes } from '@/lib/actions/rules'
import { toast } from 'sonner'
import { useRouter } from 'next/navigation'

const DAYS = [
  { value: 'monday', label: 'Monday' },
  { value: 'tuesday', label: 'Tuesday' },
  { value: 'wednesday', label: 'Wednesday' },
  { value: 'thursday', label: 'Thursday' },
  { value: 'friday', label: 'Friday' },
  { value: 'saturday', label: 'Saturday' },
  { value: 'sunday', label: 'Sunday' },
]

export function CurfewSettings({ currentSettings }: { currentSettings?: any }) {
  const router = useRouter()
  const [loading, setLoading] = useState(false)
  const [isEditing, setIsEditing] = useState(false)
  const [formData, setFormData] = useState({
    start_time: currentSettings?.start_time || '22:00',
    end_time: currentSettings?.end_time || '05:00',
    days_of_week: currentSettings?.days_of_week || ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'],
    active: currentSettings?.active !== false,
  })

  const handleDayToggle = (day: string) => {
    setFormData(prev => ({
      ...prev,
      days_of_week: prev.days_of_week.includes(day)
        ? prev.days_of_week.filter(d => d !== day)
        : [...prev.days_of_week, day],
    }))
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    if (formData.days_of_week.length === 0) {
      toast.error('Select at least one day')
      return
    }

    setLoading(true)

    try {
      const result = await setCurfewTimes(formData)

      if (result.success) {
        toast.success(result.message || 'Curfew settings updated successfully')
        setIsEditing(false)
        router.refresh()
      } else {
        toast.error(result.error || 'Failed to update curfew settings')
      }
    } catch (error) {
      toast.error('An error occurred')
    } finally {
      setLoading(false)
    }
  }

  if (!isEditing && currentSettings) {
    return (
      <div className="space-y-4">
        <div className="flex items-center justify-between">
          <span className="text-sm font-medium text-gray-700">Status</span>
          <span
            className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
              currentSettings.active
                ? 'bg-green-100 text-green-800'
                : 'bg-gray-100 text-gray-600'
            }`}
          >
            {currentSettings.active ? 'Active' : 'Inactive'}
          </span>
        </div>

        <div>
          <span className="text-sm font-medium text-gray-700">Curfew Hours</span>
          <p className="text-sm text-gray-900 mt-1">
            {currentSettings.start_time} - {currentSettings.end_time}
          </p>
        </div>

        <div>
          <span className="text-sm font-medium text-gray-700">Active Days</span>
          <div className="flex flex-wrap gap-1 mt-2">
            {currentSettings.days_of_week.map((day: string) => (
              <span
                key={day}
                className="inline-flex px-2 py-1 text-xs bg-blue-100 text-blue-800 rounded"
              >
                {day.charAt(0).toUpperCase() + day.slice(1, 3)}
              </span>
            ))}
          </div>
        </div>

        <button
          onClick={() => setIsEditing(true)}
          className="w-full mt-4 px-4 py-2 text-sm bg-blue-600 text-white rounded-lg hover:bg-blue-700"
        >
          Edit Curfew Settings
        </button>
      </div>
    )
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      {/* Active Toggle */}
      <div className="flex items-center justify-between">
        <label className="text-sm font-medium text-gray-700">Enable Curfew</label>
        <button
          type="button"
          onClick={() => setFormData(prev => ({ ...prev, active: !prev.active }))}
          className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${
            formData.active ? 'bg-blue-600' : 'bg-gray-200'
          }`}
        >
          <span
            className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
              formData.active ? 'translate-x-6' : 'translate-x-1'
            }`}
          />
        </button>
      </div>

      {/* Start Time */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">
          Start Time
        </label>
        <input
          type="time"
          value={formData.start_time}
          onChange={e => setFormData(prev => ({ ...prev, start_time: e.target.value }))}
          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
          required
        />
      </div>

      {/* End Time */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">
          End Time
        </label>
        <input
          type="time"
          value={formData.end_time}
          onChange={e => setFormData(prev => ({ ...prev, end_time: e.target.value }))}
          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
          required
        />
      </div>

      {/* Days of Week */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Active Days
        </label>
        <div className="space-y-2">
          {DAYS.map(day => (
            <label key={day.value} className="flex items-center">
              <input
                type="checkbox"
                checked={formData.days_of_week.includes(day.value)}
                onChange={() => handleDayToggle(day.value)}
                className="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
              />
              <span className="ml-2 text-sm text-gray-700">{day.label}</span>
            </label>
          ))}
        </div>
      </div>

      {/* Help Text */}
      <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-3">
        <p className="text-xs text-yellow-800">
          ⚠️ Curfew restrictions will be enforced at all gates during the specified hours.
          Guards will be notified of any changes.
        </p>
      </div>

      {/* Submit Buttons */}
      <div className="flex gap-2 pt-2">
        <button
          type="submit"
          disabled={loading}
          className="flex-1 px-4 py-2 text-sm bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
        >
          {loading ? 'Saving...' : 'Save Settings'}
        </button>
        {isEditing && (
          <button
            type="button"
            onClick={() => {
              setIsEditing(false)
              setFormData({
                start_time: currentSettings?.start_time || '22:00',
                end_time: currentSettings?.end_time || '05:00',
                days_of_week: currentSettings?.days_of_week || [],
                active: currentSettings?.active !== false,
              })
            }}
            className="px-4 py-2 text-sm bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200"
          >
            Cancel
          </button>
        )}
      </div>
    </form>
  )
}
