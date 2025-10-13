'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { createUser, updateUser } from '@/lib/actions/user'
import { User } from '@/lib/types/user'
import { AlertCircle, CheckCircle, Loader2 } from 'lucide-react'
import { toast } from 'sonner'

interface UserFormProps {
  initialData?: User
  mode: 'create' | 'edit'
  tenants: Array<{ id: string; name: string }>
}

export default function UserForm({ initialData, mode, tenants }: UserFormProps) {
  const router = useRouter()
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({})
  const [selectedRole, setSelectedRole] = useState(initialData?.role || '')

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    setLoading(true)
    setError(null)
    setFieldErrors({})

    const formData = new FormData(e.currentTarget)

    try {
      const result = mode === 'create' ? await createUser(formData) : await updateUser(formData)

      if (result.success) {
        toast.success(result.message || `User ${mode === 'create' ? 'created' : 'updated'} successfully`)
        router.push('/users')
        router.refresh()
      } else {
        setError(result.error || 'An error occurred')
        toast.error(result.error || 'An error occurred')
      }
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'An unexpected error occurred'
      setError(errorMessage)
      toast.error(errorMessage)
    } finally {
      setLoading(false)
    }
  }

  const handleRoleChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    setSelectedRole(e.target.value)
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      {/* Hidden ID for edit mode */}
      {mode === 'edit' && initialData && (
        <input type="hidden" name="id" value={initialData.id} />
      )}

      {/* Error Alert */}
      {error && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-4 flex items-start gap-3">
          <AlertCircle className="h-5 w-5 text-red-600 flex-shrink-0 mt-0.5" />
          <div>
            <h3 className="text-sm font-semibold text-red-900">Error</h3>
            <p className="text-sm text-red-800 mt-1">{error}</p>
          </div>
        </div>
      )}

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Email */}
        <div>
          <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-2">
            Email Address *
          </label>
          <input
            type="email"
            id="email"
            name="email"
            required
            disabled={mode === 'edit'}
            defaultValue={initialData?.email}
            className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary ${
              mode === 'edit' ? 'bg-gray-100 cursor-not-allowed' : 'border-gray-300'
            } ${fieldErrors.email ? 'border-red-500' : ''}`}
            placeholder="user@example.com"
          />
          {fieldErrors.email && (
            <p className="text-sm text-red-600 mt-1">{fieldErrors.email}</p>
          )}
          {mode === 'edit' && (
            <p className="text-xs text-gray-500 mt-1">Email cannot be changed</p>
          )}
        </div>

        {/* First Name */}
        <div>
          <label htmlFor="first_name" className="block text-sm font-medium text-gray-700 mb-2">
            First Name *
          </label>
          <input
            type="text"
            id="first_name"
            name="first_name"
            required
            defaultValue={initialData?.first_name}
            className={`w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary ${
              fieldErrors.first_name ? 'border-red-500' : ''
            }`}
            placeholder="John"
          />
          {fieldErrors.first_name && (
            <p className="text-sm text-red-600 mt-1">{fieldErrors.first_name}</p>
          )}
        </div>

        {/* Last Name */}
        <div>
          <label htmlFor="last_name" className="block text-sm font-medium text-gray-700 mb-2">
            Last Name *
          </label>
          <input
            type="text"
            id="last_name"
            name="last_name"
            required
            defaultValue={initialData?.last_name}
            className={`w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary ${
              fieldErrors.last_name ? 'border-red-500' : ''
            }`}
            placeholder="Doe"
          />
          {fieldErrors.last_name && (
            <p className="text-sm text-red-600 mt-1">{fieldErrors.last_name}</p>
          )}
        </div>

        {/* Phone */}
        <div>
          <label htmlFor="phone_number" className="block text-sm font-medium text-gray-700 mb-2">
            Phone Number
          </label>
          <input
            type="tel"
            id="phone_number"
            name="phone_number"
            defaultValue={initialData?.phone_number || ''}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary"
            placeholder="+63 917 123 4567"
          />
        </div>

        {/* Role */}
        <div>
          <label htmlFor="role" className="block text-sm font-medium text-gray-700 mb-2">
            Role *
          </label>
          <select
            id="role"
            name="role"
            required
            value={selectedRole}
            onChange={handleRoleChange}
            defaultValue={initialData?.role}
            className={`w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary ${
              fieldErrors.role ? 'border-red-500' : ''
            }`}
          >
            <option value="">Select a role</option>
            <option value="super_admin">Super Admin</option>
            <option value="admin_head">Admin Head</option>
            <option value="admin_officer">Admin Officer</option>
            <option value="household_head">Household Head</option>
            <option value="guard">Security Guard</option>
          </select>
          {fieldErrors.role && (
            <p className="text-sm text-red-600 mt-1">{fieldErrors.role}</p>
          )}
        </div>

        {/* Tenant */}
        <div className="md:col-span-2">
          <label htmlFor="tenant_id" className="block text-sm font-medium text-gray-700 mb-2">
            Tenant/Community {selectedRole !== 'super_admin' && <span className="text-red-500">*</span>}
          </label>
          <select
            id="tenant_id"
            name="tenant_id"
            required={selectedRole !== 'super_admin'}
            disabled={selectedRole === 'super_admin'}
            defaultValue={initialData?.tenant_id || ''}
            className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary ${
              selectedRole === 'super_admin' ? 'bg-gray-100 cursor-not-allowed' : 'border-gray-300'
            } ${fieldErrors.tenant_id ? 'border-red-500' : ''}`}
          >
            <option value="">
              {selectedRole === 'super_admin' ? 'None (Super Admin)' : 'Select a community'}
            </option>
            {tenants.map((tenant) => (
              <option key={tenant.id} value={tenant.id}>
                {tenant.name}
              </option>
            ))}
          </select>
          {fieldErrors.tenant_id && (
            <p className="text-sm text-red-600 mt-1">{fieldErrors.tenant_id}</p>
          )}
          <p className="text-sm text-gray-500 mt-1">
            {selectedRole === 'super_admin'
              ? 'Super admins have access to all tenants'
              : 'Required for all other roles'}
          </p>
        </div>

        {/* Password (create mode only) */}
        {mode === 'create' && (
          <div className="md:col-span-2">
            <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-2">
              Temporary Password *
            </label>
            <input
              type="password"
              id="password"
              name="password"
              required
              minLength={8}
              className={`w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary ${
                fieldErrors.password ? 'border-red-500' : ''
              }`}
              placeholder="Minimum 8 characters"
            />
            {fieldErrors.password && (
              <p className="text-sm text-red-600 mt-1">{fieldErrors.password}</p>
            )}
            <p className="text-xs text-gray-500 mt-1">
              User will be prompted to change password on first login.
            </p>
          </div>
        )}

        {/* Active Status (edit mode only) */}
        {mode === 'edit' && (
          <div className="md:col-span-2">
            <label className="flex items-center">
              <input
                type="checkbox"
                name="is_active"
                value="true"
                defaultChecked={initialData?.is_active}
                className="w-4 h-4 text-primary border-gray-300 rounded focus:ring-primary"
              />
              <span className="ml-2 text-sm text-gray-700">Active user</span>
            </label>
            <p className="text-xs text-gray-500 mt-1">
              Inactive users cannot log in to the platform
            </p>
          </div>
        )}
      </div>

      {/* Action Buttons */}
      <div className="flex gap-3 pt-4 border-t">
        <button
          type="button"
          onClick={() => router.back()}
          disabled={loading}
          className="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Cancel
        </button>
        <button
          type="submit"
          disabled={loading}
          className="px-4 py-2 bg-primary text-white rounded-md hover:bg-primary-dark transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
        >
          {loading ? (
            <>
              <Loader2 className="h-4 w-4 animate-spin" />
              {mode === 'create' ? 'Creating...' : 'Updating...'}
            </>
          ) : (
            <>
              <CheckCircle className="h-4 w-4" />
              {mode === 'create' ? 'Create User' : 'Update User'}
            </>
          )}
        </button>
      </div>
    </form>
  )
}
