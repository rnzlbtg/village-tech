'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { createGate, updateGate } from '@/lib/actions/gate'
import { Gate } from '@/lib/types/gate'
import { CheckCircle, AlertTriangle } from 'lucide-react'

interface GateFormProps {
  tenantId: string
  initialData?: Gate
  mode: 'create' | 'edit'
}

export default function GateForm({ tenantId, initialData, mode }: GateFormProps) {
  const router = useRouter()
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState(false)
  const [equipmentConfig, setEquipmentConfig] = useState(
    initialData?.equipment_config ? JSON.stringify(initialData.equipment_config, null, 2) : ''
  )

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    setLoading(true)
    setError(null)
    setSuccess(false)

    const formData = new FormData(e.currentTarget)
    formData.append('tenant_id', tenantId)
    formData.set('equipment_config', equipmentConfig)

    try {
      const result = mode === 'create' ? await createGate(formData) : await updateGate(formData)

      if (result.success) {
        setSuccess(true)
        setTimeout(() => {
          router.push(`/tenants/${tenantId}/gates`)
          router.refresh()
        }, 1500)
      } else {
        setError(result.error || 'An error occurred')
      }
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'An unexpected error occurred'
      setError(errorMessage)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="space-y-6">
      {success && (
        <div className="bg-primary-light border-l-4 border-primary p-4 rounded-md">
          <div className="flex items-center">
            <CheckCircle className="h-5 w-5 text-primary mr-2" />
            <p className="text-primary">
              Gate {mode === 'create' ? 'created' : 'updated'} successfully! Redirecting...
            </p>
          </div>
        </div>
      )}

      {error && (
        <div className="bg-red-50 border-l-4 border-red-500 p-4 rounded-md">
          <div className="flex items-center">
            <AlertTriangle className="h-5 w-5 text-red-500 mr-2" />
            <p className="text-red-700">{error}</p>
          </div>
        </div>
      )}

      <form onSubmit={handleSubmit} className="space-y-6">
        {mode === 'edit' && <input type="hidden" name="id" value={initialData?.id} />}

        <div>
          <h2 className="text-xl font-semibold text-gray-800 border-b pb-2 mb-4">
            Gate Information
          </h2>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label htmlFor="name" className="block text-sm font-medium text-gray-700 mb-1">
                Gate Name *
              </label>
              <input
                type="text"
                id="name"
                name="name"
                required
                defaultValue={initialData?.name}
                className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                placeholder="e.g., Main Entrance"
              />
            </div>

            <div>
              <label htmlFor="gate_type" className="block text-sm font-medium text-gray-700 mb-1">
                Gate Type
              </label>
              <select
                id="gate_type"
                name="gate_type"
                defaultValue={initialData?.gate_type || 'main'}
                className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
              >
                <option value="main">Main Entrance</option>
                <option value="pedestrian">Pedestrian</option>
                <option value="vehicle">Vehicle Only</option>
                <option value="service">Service Entrance</option>
                <option value="emergency">Emergency Exit</option>
              </select>
            </div>
          </div>

          <div className="mt-4">
            <label htmlFor="location" className="block text-sm font-medium text-gray-700 mb-1">
              Location *
            </label>
            <input
              type="text"
              id="location"
              name="location"
              required
              defaultValue={initialData?.location}
              className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
              placeholder="e.g., North entrance, near Building A"
            />
          </div>

          <div className="mt-4">
            <label htmlFor="operational_status" className="block text-sm font-medium text-gray-700 mb-1">
              Operational Status
            </label>
            <select
              id="operational_status"
              name="operational_status"
              defaultValue={initialData?.operational_status || 'active'}
              className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
            >
              <option value="active">Active</option>
              <option value="maintenance">Under Maintenance</option>
              <option value="inactive">Inactive</option>
            </select>
          </div>
        </div>

        <div>
          <h2 className="text-xl font-semibold text-gray-800 border-b pb-2 mb-4">
            Equipment Configuration
          </h2>

          <div>
            <label htmlFor="equipment_config" className="block text-sm font-medium text-gray-700 mb-1">
              Equipment Settings (JSON)
            </label>
            <textarea
              id="equipment_config"
              value={equipmentConfig}
              onChange={(e) => setEquipmentConfig(e.target.value)}
              rows={8}
              className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary font-mono text-sm"
              placeholder={`{\n  "rfid_reader": {\n    "enabled": true,\n    "model": "HID R90"\n  },\n  "camera": {\n    "enabled": true,\n    "resolution": "1080p"\n  }\n}`}
            />
            <p className="text-xs text-gray-500 mt-1">
              Configure RFID readers, cameras, and other equipment in JSON format
            </p>
          </div>
        </div>

        <div>
          <label htmlFor="notes" className="block text-sm font-medium text-gray-700 mb-1">
            Notes
          </label>
          <textarea
            id="notes"
            name="notes"
            rows={3}
            defaultValue={initialData?.notes || ''}
            className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
            placeholder="Additional information about this gate..."
          />
        </div>

        <div className="flex justify-between space-x-4 pt-6 border-t">
          <button
            type="button"
            onClick={() => router.push(`/tenants/${tenantId}/gates`)}
            className="px-4 py-2 border rounded-lg text-gray-700 hover:bg-gray-100 transition-colors duration-200"
          >
            Cancel
          </button>
          <button
            type="submit"
            disabled={loading}
            className="px-6 py-2 bg-primary hover:bg-secondary text-white rounded-lg transition-colors duration-200 disabled:opacity-70 disabled:cursor-not-allowed"
          >
            {loading ? 'Processing...' : mode === 'create' ? 'Create Gate' : 'Save Changes'}
          </button>
        </div>
      </form>
    </div>
  )
}
