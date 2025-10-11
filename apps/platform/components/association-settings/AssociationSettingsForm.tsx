'use client'

import { useState, useTransition } from 'react'
import { useRouter } from 'next/navigation'
import { updateAssociationSettings } from '@/lib/actions/association-settings'
import { AssociationSettings } from '@/lib/types/association-settings'
import { Save } from 'lucide-react'

interface AssociationSettingsFormProps {
  tenantId: string
  initialData?: AssociationSettings
}

export default function AssociationSettingsForm({
  tenantId,
  initialData,
}: AssociationSettingsFormProps) {
  const router = useRouter()
  const [isPending, startTransition] = useTransition()
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState(false)
  const [activeTab, setActiveTab] = useState<'general' | 'billing' | 'notifications' | 'security'>(
    'general'
  )

  const [settings, setSettings] = useState({
    general: initialData?.settings?.general || {},
    billing: initialData?.settings?.billing || {},
    notifications: initialData?.settings?.notifications || {},
    security: initialData?.settings?.security || {},
  })

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    setError(null)
    setSuccess(false)

    const formData = new FormData()
    formData.append('tenant_id', tenantId)
    formData.append('settings', JSON.stringify(settings))

    startTransition(async () => {
      const result = await updateAssociationSettings(formData)

      if (!result.success) {
        setError(result.error || 'An error occurred')
        return
      }

      setSuccess(true)
      setTimeout(() => setSuccess(false), 3000)
      router.refresh()
    })
  }

  const updateGeneralSetting = (key: string, value: any) => {
    setSettings((prev) => ({
      ...prev,
      general: { ...prev.general, [key]: value },
    }))
  }

  const updateBillingSetting = (key: string, value: any) => {
    setSettings((prev) => ({
      ...prev,
      billing: { ...prev.billing, [key]: value },
    }))
  }

  const updateNotificationSetting = (key: string, value: any) => {
    setSettings((prev) => ({
      ...prev,
      notifications: { ...prev.notifications, [key]: value },
    }))
  }

  const updateSecuritySetting = (key: string, value: any) => {
    setSettings((prev) => ({
      ...prev,
      security: { ...prev.security, [key]: value },
    }))
  }

  const tabs = [
    { id: 'general' as const, label: 'General' },
    { id: 'billing' as const, label: 'Billing' },
    { id: 'notifications' as const, label: 'Notifications' },
    { id: 'security' as const, label: 'Security' },
  ]

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
          {error}
        </div>
      )}

      {success && (
        <div className="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded">
          Settings updated successfully!
        </div>
      )}

      {/* Tabs */}
      <div className="border-b border-gray-200">
        <nav className="flex space-x-8">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              type="button"
              onClick={() => setActiveTab(tab.id)}
              className={`py-4 px-1 border-b-2 font-medium text-sm ${
                activeTab === tab.id
                  ? 'border-primary text-primary'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </nav>
      </div>

      {/* General Settings */}
      {activeTab === 'general' && (
        <div className="space-y-6">
          <h3 className="text-lg font-semibold text-gray-800">General Settings</h3>

          <div>
            <label htmlFor="association_name" className="block text-sm font-medium text-gray-700 mb-2">
              Association Name
            </label>
            <input
              type="text"
              id="association_name"
              value={settings.general.association_name || ''}
              onChange={(e) => updateGeneralSetting('association_name', e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
              placeholder="e.g., Sunset Valley Homeowners Association"
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label htmlFor="operating_start" className="block text-sm font-medium text-gray-700 mb-2">
                Operating Hours Start
              </label>
              <input
                type="time"
                id="operating_start"
                value={settings.general.operating_hours?.start || ''}
                onChange={(e) =>
                  updateGeneralSetting('operating_hours', {
                    ...settings.general.operating_hours,
                    start: e.target.value,
                  })
                }
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
              />
            </div>

            <div>
              <label htmlFor="operating_end" className="block text-sm font-medium text-gray-700 mb-2">
                Operating Hours End
              </label>
              <input
                type="time"
                id="operating_end"
                value={settings.general.operating_hours?.end || ''}
                onChange={(e) =>
                  updateGeneralSetting('operating_hours', {
                    ...settings.general.operating_hours,
                    end: e.target.value,
                  })
                }
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
              />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label htmlFor="timezone" className="block text-sm font-medium text-gray-700 mb-2">
                Timezone
              </label>
              <select
                id="timezone"
                value={settings.general.timezone || 'Asia/Manila'}
                onChange={(e) => updateGeneralSetting('timezone', e.target.value)}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
              >
                <option value="Asia/Manila">Asia/Manila (PHT)</option>
                <option value="Asia/Singapore">Asia/Singapore (SGT)</option>
                <option value="UTC">UTC</option>
              </select>
            </div>

            <div>
              <label htmlFor="language" className="block text-sm font-medium text-gray-700 mb-2">
                Language
              </label>
              <select
                id="language"
                value={settings.general.language || 'en'}
                onChange={(e) => updateGeneralSetting('language', e.target.value)}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
              >
                <option value="en">English</option>
                <option value="fil">Filipino</option>
              </select>
            </div>
          </div>
        </div>
      )}

      {/* Billing Settings */}
      {activeTab === 'billing' && (
        <div className="space-y-6">
          <h3 className="text-lg font-semibold text-gray-800">Billing Settings</h3>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label htmlFor="currency" className="block text-sm font-medium text-gray-700 mb-2">
                Currency
              </label>
              <select
                id="currency"
                value={settings.billing.currency || 'PHP'}
                onChange={(e) => updateBillingSetting('currency', e.target.value)}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
              >
                <option value="PHP">PHP - Philippine Peso</option>
                <option value="USD">USD - US Dollar</option>
              </select>
            </div>

            <div>
              <label htmlFor="billing_cycle" className="block text-sm font-medium text-gray-700 mb-2">
                Billing Cycle
              </label>
              <select
                id="billing_cycle"
                value={settings.billing.billing_cycle || 'monthly'}
                onChange={(e) => updateBillingSetting('billing_cycle', e.target.value)}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
              >
                <option value="monthly">Monthly</option>
                <option value="quarterly">Quarterly</option>
                <option value="annually">Annually</option>
              </select>
            </div>
          </div>

          <div className="grid grid-cols-3 gap-4">
            <div>
              <label htmlFor="due_day" className="block text-sm font-medium text-gray-700 mb-2">
                Due Day of Month
              </label>
              <input
                type="number"
                id="due_day"
                min="1"
                max="31"
                value={settings.billing.due_day || ''}
                onChange={(e) => updateBillingSetting('due_day', parseInt(e.target.value))}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
                placeholder="e.g., 5"
              />
            </div>

            <div>
              <label htmlFor="late_fee" className="block text-sm font-medium text-gray-700 mb-2">
                Late Fee (%)
              </label>
              <input
                type="number"
                id="late_fee"
                min="0"
                max="100"
                step="0.1"
                value={settings.billing.late_fee_percentage || ''}
                onChange={(e) =>
                  updateBillingSetting('late_fee_percentage', parseFloat(e.target.value))
                }
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
                placeholder="e.g., 2.5"
              />
            </div>

            <div>
              <label htmlFor="grace_period" className="block text-sm font-medium text-gray-700 mb-2">
                Grace Period (days)
              </label>
              <input
                type="number"
                id="grace_period"
                min="0"
                max="90"
                value={settings.billing.grace_period_days || ''}
                onChange={(e) =>
                  updateBillingSetting('grace_period_days', parseInt(e.target.value))
                }
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
                placeholder="e.g., 7"
              />
            </div>
          </div>
        </div>
      )}

      {/* Notification Settings */}
      {activeTab === 'notifications' && (
        <div className="space-y-6">
          <h3 className="text-lg font-semibold text-gray-800">Notification Settings</h3>

          <div className="space-y-4">
            <div className="flex items-center">
              <input
                type="checkbox"
                id="email_enabled"
                checked={settings.notifications.email_enabled || false}
                onChange={(e) => updateNotificationSetting('email_enabled', e.target.checked)}
                className="h-4 w-4 text-primary focus:ring-primary border-gray-300 rounded"
              />
              <label htmlFor="email_enabled" className="ml-2 block text-sm text-gray-700">
                Enable Email Notifications
              </label>
            </div>

            <div className="flex items-center">
              <input
                type="checkbox"
                id="sms_enabled"
                checked={settings.notifications.sms_enabled || false}
                onChange={(e) => updateNotificationSetting('sms_enabled', e.target.checked)}
                className="h-4 w-4 text-primary focus:ring-primary border-gray-300 rounded"
              />
              <label htmlFor="sms_enabled" className="ml-2 block text-sm text-gray-700">
                Enable SMS Notifications
              </label>
            </div>

            <div className="flex items-center">
              <input
                type="checkbox"
                id="push_enabled"
                checked={settings.notifications.push_enabled || false}
                onChange={(e) => updateNotificationSetting('push_enabled', e.target.checked)}
                className="h-4 w-4 text-primary focus:ring-primary border-gray-300 rounded"
              />
              <label htmlFor="push_enabled" className="ml-2 block text-sm text-gray-700">
                Enable Push Notifications
              </label>
            </div>
          </div>
        </div>
      )}

      {/* Security Settings */}
      {activeTab === 'security' && (
        <div className="space-y-6">
          <h3 className="text-lg font-semibold text-gray-800">Security Settings</h3>

          <div className="flex items-center">
            <input
              type="checkbox"
              id="two_factor_required"
              checked={settings.security.two_factor_required || false}
              onChange={(e) => updateSecuritySetting('two_factor_required', e.target.checked)}
              className="h-4 w-4 text-primary focus:ring-primary border-gray-300 rounded"
            />
            <label htmlFor="two_factor_required" className="ml-2 block text-sm text-gray-700">
              Require Two-Factor Authentication
            </label>
          </div>

          <div className="grid grid-cols-3 gap-4">
            <div>
              <label
                htmlFor="session_timeout"
                className="block text-sm font-medium text-gray-700 mb-2"
              >
                Session Timeout (minutes)
              </label>
              <input
                type="number"
                id="session_timeout"
                min="5"
                max="1440"
                value={settings.security.session_timeout_minutes || ''}
                onChange={(e) =>
                  updateSecuritySetting('session_timeout_minutes', parseInt(e.target.value))
                }
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
                placeholder="e.g., 30"
              />
            </div>

            <div>
              <label
                htmlFor="password_expiry"
                className="block text-sm font-medium text-gray-700 mb-2"
              >
                Password Expiry (days)
              </label>
              <input
                type="number"
                id="password_expiry"
                min="0"
                max="365"
                value={settings.security.password_expiry_days || ''}
                onChange={(e) =>
                  updateSecuritySetting('password_expiry_days', parseInt(e.target.value))
                }
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
                placeholder="e.g., 90"
              />
            </div>

            <div>
              <label
                htmlFor="max_login_attempts"
                className="block text-sm font-medium text-gray-700 mb-2"
              >
                Max Login Attempts
              </label>
              <input
                type="number"
                id="max_login_attempts"
                min="3"
                max="10"
                value={settings.security.max_login_attempts || ''}
                onChange={(e) =>
                  updateSecuritySetting('max_login_attempts', parseInt(e.target.value))
                }
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
                placeholder="e.g., 5"
              />
            </div>
          </div>
        </div>
      )}

      {/* Submit Button */}
      <div className="flex justify-end pt-6 border-t">
        <button
          type="submit"
          disabled={isPending}
          className="inline-flex items-center px-6 py-2 bg-primary text-white rounded-lg hover:bg-primary/90 disabled:opacity-50"
        >
          <Save className="h-5 w-5 mr-2" />
          {isPending ? 'Saving...' : 'Save Settings'}
        </button>
      </div>
    </form>
  )
}
