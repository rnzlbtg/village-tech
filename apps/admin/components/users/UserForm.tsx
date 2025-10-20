'use client'

import { useState } from 'react'
import { RefreshCw, AlertCircle } from 'lucide-react'
import { InputField, SelectField, CheckboxField } from '@/components/shared/FormField'
import { CreateUserInput, UpdateUserInput, AdminRole } from '@/lib/validations/users'

interface UserFormData {
  email: string
  first_name: string
  last_name: string
  role: AdminRole
  phone_number: string
  password: string
  is_active: boolean
}

interface UserFormProps {
  onSubmit: (data: UserFormData) => void
  onCancel: () => void
  initialData?: Partial<UserFormData>
  isLoading?: boolean
  mode?: 'create' | 'edit'
}

export default function UserForm({
  onSubmit,
  onCancel,
  initialData,
  isLoading = false,
  mode = 'create'
}: UserFormProps) {
  const [formData, setFormData] = useState<UserFormData>({
    email: initialData?.email || '',
    first_name: initialData?.first_name || '',
    last_name: initialData?.last_name || '',
    role: initialData?.role || 'admin_officer',
    phone_number: initialData?.phone_number || '',
    password: initialData?.password || '',
    is_active: initialData?.is_active !== undefined ? initialData.is_active : true,
  })

  const [errors, setErrors] = useState<Partial<Record<keyof UserFormData, string>>>({})

  const generatePassword = () => {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    let password = ''
    for (let i = 0; i < 8; i++) {
      password += chars.charAt(Math.floor(Math.random() * chars.length))
    }
    handleChange('password', password)
  }

  const roleOptions = [
    { value: 'admin_head', label: 'Admin Head', helpText: 'Full administrative access' },
    { value: 'admin_officer', label: 'Admin Officer', helpText: 'Administrative access' },
    { value: 'security_head', label: 'Security Head', helpText: 'Security management access' },
    { value: 'security_officer', label: 'Security Officer', helpText: 'Security operations access' },
  ]

  const validateForm = (): boolean => {
    const newErrors: Partial<Record<keyof UserFormData, string>> = {}

    if (!formData.email.trim()) {
      newErrors.email = 'Email is required'
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      newErrors.email = 'Invalid email format'
    }

    if (!formData.first_name.trim()) {
      newErrors.first_name = 'First name is required'
    } else if (formData.first_name.length < 2) {
      newErrors.first_name = 'First name must be at least 2 characters'
    }

    if (!formData.last_name.trim()) {
      newErrors.last_name = 'Last name is required'
    } else if (formData.last_name.length < 2) {
      newErrors.last_name = 'Last name must be at least 2 characters'
    }

    if (!formData.role) {
      newErrors.role = 'Role is required'
    }

    if (formData.phone_number && formData.phone_number.length < 10) {
      newErrors.phone_number = 'Phone number must be at least 10 digits'
    }

    if (mode === 'create' && !formData.password.trim()) {
      newErrors.password = 'Password is required'
    } else if (formData.password && formData.password.length < 6) {
      newErrors.password = 'Password must be at least 6 characters'
    }

    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()

    if (!validateForm()) {
      return
    }

    onSubmit(formData)
  }

  const handleChange = (field: keyof UserFormData, value: string | boolean) => {
    setFormData(prev => ({ ...prev, [field]: value }))
    // Clear error when user starts typing
    if (errors[field]) {
      setErrors(prev => ({ ...prev, [field]: undefined }))
    }
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <InputField
          label="First Name"
          name="first_name"
          type="text"
          required
          value={formData.first_name}
          onChange={(e) => handleChange('first_name', e.target.value)}
          error={errors.first_name}
          placeholder="Juan"
        />

        <InputField
          label="Last Name"
          name="last_name"
          type="text"
          required
          value={formData.last_name}
          onChange={(e) => handleChange('last_name', e.target.value)}
          error={errors.last_name}
          placeholder="Dela Cruz"
        />
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <InputField
          label="Email Address"
          name="email"
          type="email"
          required
          value={formData.email}
          onChange={(e) => handleChange('email', e.target.value)}
          error={errors.email}
          placeholder="juan@example.com"
          helpText="Used for login and notifications"
        />

        <InputField
          label="Phone Number"
          name="phone_number"
          type="tel"
          value={formData.phone_number}
          onChange={(e) => handleChange('phone_number', e.target.value)}
          error={errors.phone_number}
          placeholder="+63 912 345 6789"
          helpText="Optional"
        />
      </div>

      <SelectField
        label="Role"
        name="role"
        required
        value={formData.role}
        onChange={(e) => handleChange('role', e.target.value as AdminRole)}
        error={errors.role}
        options={roleOptions}
        helpText="Select the appropriate role for this user"
      />

      {mode === 'create' && (
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Temporary Password
            <span className="text-red-500 ml-1">*</span>
          </label>
          <div className="flex gap-2">
            <div className="flex-1">
              <input
                type="password"
                name="password"
                required
                value={formData.password}
                onChange={(e) => handleChange('password', e.target.value)}
                placeholder="Min. 6 characters"
                className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 transition-colors ${
                  errors.password
                    ? 'border-red-300 focus:border-red-500 focus:ring-red-500'
                    : 'border-gray-300 focus:border-primary focus:ring-primary'
                }`}
              />
              {errors.password && (
                <div className="mt-1 flex items-center gap-1 text-sm text-red-600">
                  <AlertCircle className="h-4 w-4" />
                  <span>{errors.password}</span>
                </div>
              )}
            </div>
            <button
              type="button"
              onClick={generatePassword}
              className="px-4 py-2 text-gray-700 bg-gray-100 border border-gray-300 rounded-md hover:bg-gray-200 transition-colors flex items-center gap-2 whitespace-nowrap"
              title="Generate random password"
            >
              <RefreshCw className="h-4 w-4" />
              Generate
            </button>
          </div>
          <p className="mt-1 text-sm text-gray-500">
            User will be required to change this on first login
          </p>
        </div>
      )}

      {mode === 'edit' && (
        <CheckboxField
          label="Active Status"
          name="is_active"
          checked={formData.is_active}
          onChange={(e) => handleChange('is_active', e.target.checked)}
          helpText="Inactive users cannot log in to the system"
        />
      )}

      {mode === 'create' && (
        <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
          <p className="text-sm text-blue-800">
            <strong>📧 Welcome Information:</strong> The user will receive their login credentials via email. They will be required to change their password on first login for security.
          </p>
        </div>
      )}

      <div className="bg-amber-50 border border-amber-200 rounded-lg p-4">
        <p className="text-sm text-amber-800">
          <strong>⚠️ Security Note:</strong> Use a simple temporary password (e.g., "welcome123"). The user will be forced to set a strong password after their first login.
        </p>
      </div>

      <div className="flex justify-end gap-4 pt-4 border-t">
        <button
          type="button"
          onClick={onCancel}
          disabled={isLoading}
          className="px-6 py-2 text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
        >
          Cancel
        </button>
        <button
          type="submit"
          disabled={isLoading}
          className="px-6 py-2 text-white bg-primary rounded-md hover:bg-primary-dark disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
        >
          {isLoading ? 'Saving...' : mode === 'create' ? 'Create User' : 'Update User'}
        </button>
      </div>
    </form>
  )
}