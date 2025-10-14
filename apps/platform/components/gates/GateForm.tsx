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
  onSuccess?: () => void
}

export default function GateForm({ tenantId, initialData, mode, onSuccess }: GateFormProps) {
  const router = useRouter()
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState(false)

  // Extract common RFID settings from equipment_config
  const existingConfig = initialData?.equipment_config || {}
  const [rfidEnabled, setRfidEnabled] = useState(existingConfig?.rfid_reader?.enabled ?? true)
  const [rfidIp, setRfidIp] = useState(existingConfig?.rfid_reader?.connection_ip || '')
  const [rfidPort, setRfidPort] = useState(existingConfig?.rfid_reader?.port || '9000')
  const [rfidReadRange, setRfidReadRange] = useState(existingConfig?.rfid_reader?.read_range || '5')
  const [rfidFrequency, setRfidFrequency] = useState(existingConfig?.rfid_reader?.frequency || '13.56')

  // Advanced settings in JSON
  const advancedDefaults = { ...existingConfig }
  delete advancedDefaults.rfid_reader
  const [advancedConfig, setAdvancedConfig] = useState(
    Object.keys(advancedDefaults).length > 0 ? JSON.stringify(advancedDefaults, null, 2) : ''
  )

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    setLoading(true)
    setError(null)
    setSuccess(false)

    const formData = new FormData(e.currentTarget)
    formData.append('tenant_id', tenantId)

    // Build combined equipment config from structured fields + advanced JSON
    const equipmentConfig: any = {
      rfid_reader: {
        enabled: rfidEnabled,
        connection_ip: rfidIp,
        port: rfidPort,
        read_range: rfidReadRange,
        frequency: rfidFrequency,
      },
    }

    // Merge advanced JSON config if provided
    if (advancedConfig.trim()) {
      try {
        const advancedParsed = JSON.parse(advancedConfig)
        Object.assign(equipmentConfig, advancedParsed)
      } catch (err) {
        setError('Invalid JSON in advanced configuration')
        setLoading(false)
        return
      }
    }

    formData.set('equipment_config', JSON.stringify(equipmentConfig))

    try {
      const result = mode === 'create' ? await createGate(formData) : await updateGate(formData)

      if (result.success) {
        setSuccess(true)
        if (onSuccess) {
          setTimeout(() => {
            router.refresh()
            onSuccess()
          }, 1500)
        } else {
          setTimeout(() => {
            router.push(`/tenants/${tenantId}/gates`)
            router.refresh()
          }, 1500)
        }
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

          {/* Common RFID Settings - Structured Form */}
          <div className="bg-gray-50 p-4 rounded-lg mb-6">
            <h3 className="text-lg font-medium text-gray-800 mb-4">RFID Reader Settings</h3>

            <div className="space-y-4">
              <div className="flex items-center">
                <input
                  type="checkbox"
                  id="rfid_enabled"
                  checked={rfidEnabled}
                  onChange={(e) => setRfidEnabled(e.target.checked)}
                  className="h-4 w-4 text-primary focus:ring-primary border-gray-300 rounded"
                />
                <label htmlFor="rfid_enabled" className="ml-2 block text-sm text-gray-700">
                  Enable RFID Reader
                </label>
              </div>

              {rfidEnabled && (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mt-4">
                  <div>
                    <label htmlFor="rfid_ip" className="block text-sm font-medium text-gray-700 mb-1">
                      Connection IP Address
                    </label>
                    <input
                      type="text"
                      id="rfid_ip"
                      value={rfidIp}
                      onChange={(e) => setRfidIp(e.target.value)}
                      className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                      placeholder="e.g., 192.168.1.100"
                    />
                  </div>

                  <div>
                    <label htmlFor="rfid_port" className="block text-sm font-medium text-gray-700 mb-1">
                      Port
                    </label>
                    <input
                      type="text"
                      id="rfid_port"
                      value={rfidPort}
                      onChange={(e) => setRfidPort(e.target.value)}
                      className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                      placeholder="e.g., 9000"
                    />
                  </div>

                  <div>
                    <label htmlFor="rfid_read_range" className="block text-sm font-medium text-gray-700 mb-1">
                      Read Range (meters)
                    </label>
                    <input
                      type="text"
                      id="rfid_read_range"
                      value={rfidReadRange}
                      onChange={(e) => setRfidReadRange(e.target.value)}
                      className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                      placeholder="e.g., 5"
                    />
                  </div>

                  <div>
                    <label htmlFor="rfid_frequency" className="block text-sm font-medium text-gray-700 mb-1">
                      Frequency (MHz)
                    </label>
                    <input
                      type="text"
                      id="rfid_frequency"
                      value={rfidFrequency}
                      onChange={(e) => setRfidFrequency(e.target.value)}
                      className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                      placeholder="e.g., 13.56"
                    />
                  </div>
                </div>
              )}
            </div>
          </div>

          {/* Advanced Settings - JSON Editor */}
          <div>
            <label htmlFor="advanced_config" className="block text-sm font-medium text-gray-700 mb-1">
              Advanced Equipment Settings (JSON)
            </label>
            <textarea
              id="advanced_config"
              value={advancedConfig}
              onChange={(e) => setAdvancedConfig(e.target.value)}
              rows={6}
              className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary font-mono text-sm"
              placeholder={`{\n  "camera": {\n    "enabled": true,\n    "resolution": "1080p",\n    "recording": true\n  },\n  "barrier": {\n    "type": "automatic",\n    "speed": "normal"\n  }\n}`}
            />
            <p className="text-xs text-gray-500 mt-1">
              Optional: Configure cameras, barriers, and other equipment in JSON format
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
