'use client'

import { useState, useTransition } from 'react'
import { useRouter } from 'next/navigation'
import { createAdminUser, updateAdminUser } from '@/lib/actions/admin-user'
import { AdminUser } from '@/lib/types/admin-user'

interface AdminUserFormProps {
  tenantId: string
  initialData?: AdminUser
  mode: 'create' | 'edit'
  onSuccess?: () => void
}

export default function AdminUserForm({ tenantId, initialData, mode, onSuccess }: AdminUserFormProps) {
  const router = useRouter()
  const [isPending, startTransition] = useTransition()
  const [error, setError] = useState<string | null>(null)

  const [formData, setFormData] = useState({
    email: initialData?.email || '',
    password: '',
    first_name: initialData?.first_name || '',
    last_name: initialData?.last_name || '',
    phone_number: initialData?.phone_number || '',
    role: initialData?.role || 'admin_officer',
    is_active: initialData?.is_active ?? true,
  })

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value, type } = e.target
    const newValue = type === 'checkbox' ? (e.target as HTMLInputElement).checked : value

    setFormData((prev) => ({ ...prev, [name]: newValue }))
  }

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    setError(null)

    if (mode === 'create' && formData.password.length < 6) {
      setError('Temporary password must be at least 6 characters')
      return
    }

    const data = new FormData()
    data.append('tenant_id', tenantId)
    data.append('email', formData.email)
    if (mode === 'create') {
      data.append('password', formData.password)
    }
    data.append('first_name', formData.first_name)
    data.append('last_name', formData.last_name)
    if (formData.phone_number) {
      data.append('phone_number', formData.phone_number)
    }
    data.append('role', formData.role)

    if (mode === 'edit' && initialData) {
      data.append('id', initialData.id)
      data.append('is_active', String(formData.is_active))
    }

    startTransition(async () => {
      const result = mode === 'create' ? await createAdminUser(data) : await updateAdminUser(data)

      if (!result.success) {
        setError(result.error || 'An error occurred')
        return
      }

      if (onSuccess) {
        router.refresh()
        onSuccess()
      } else {
        router.push(`/tenants/${tenantId}/admin-users`)
        router.refresh()
      }
    })
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
          {error}
        </div>
      )}

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div>
          <label htmlFor="first_name" className="block text-sm font-medium text-gray-700 mb-2">
            First Name *
          </label>
          <input
            type="text"
            id="first_name"
            name="first_name"
            value={formData.first_name}
            onChange={handleChange}
            required
            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
          />
        </div>

        <div>
          <label htmlFor="last_name" className="block text-sm font-medium text-gray-700 mb-2">
            Last Name *
          </label>
          <input
            type="text"
            id="last_name"
            name="last_name"
            value={formData.last_name}
            onChange={handleChange}
            required
            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
          />
        </div>
      </div>

      <div>
        <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-2">
          Email Address *
        </label>
        <input
          type="email"
          id="email"
          name="email"
          value={formData.email}
          onChange={handleChange}
          required
          disabled={mode === 'edit'}
          className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent disabled:bg-gray-100 disabled:cursor-not-allowed"
        />
      </div>

      {mode === 'create' && (
        <div>
          <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-2">
            Temporary Password *
          </label>
          <input
            type="password"
            id="password"
            name="password"
            value={formData.password}
            onChange={handleChange}
            required
            minLength={6}
            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
          />
          <p className="mt-1 text-sm text-gray-500">
            Minimum 6 characters. User will be prompted to change on first login.
          </p>
        </div>
      )}

      <div>
        <label htmlFor="phone_number" className="block text-sm font-medium text-gray-700 mb-2">
          Phone Number
        </label>
        <input
          type="tel"
          id="phone_number"
          name="phone_number"
          value={formData.phone_number}
          onChange={handleChange}
          placeholder="+1234567890"
          className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
        />
        <p className="mt-1 text-sm text-gray-500">Format: +[country code][number]</p>
      </div>

      <div>
        <label htmlFor="role" className="block text-sm font-medium text-gray-700 mb-2">
          Role *
        </label>
        <select
          id="role"
          name="role"
          value={formData.role}
          onChange={handleChange}
          required
          className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
        >
          <option value="admin_officer">Admin Officer</option>
          <option value="admin_head">Admin Head</option>
        </select>
        <p className="mt-1 text-sm text-gray-500">
          Admin Head has full permissions, Admin Officer has limited permissions
        </p>
      </div>

      {mode === 'edit' && (
        <div className="flex items-center">
          <input
            type="checkbox"
            id="is_active"
            name="is_active"
            checked={formData.is_active}
            onChange={handleChange}
            className="h-4 w-4 text-primary focus:ring-primary border-gray-300 rounded"
          />
          <label htmlFor="is_active" className="ml-2 block text-sm text-gray-700">
            Active (user can log in)
          </label>
        </div>
      )}

      <div className="flex justify-end space-x-4 pt-4 border-t">
        <button
          type="button"
          onClick={() => router.back()}
          disabled={isPending}
          className="px-6 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 disabled:opacity-50"
        >
          Cancel
        </button>
        <button
          type="submit"
          disabled={isPending}
          className="px-6 py-2 bg-primary text-white rounded-lg hover:bg-primary/90 disabled:opacity-50"
        >
          {isPending ? 'Saving...' : mode === 'create' ? 'Create Admin User' : 'Update Admin User'}
        </button>
      </div>
    </form>
  )
}
