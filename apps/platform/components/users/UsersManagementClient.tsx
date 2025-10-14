'use client'

import { useState, useMemo } from 'react'
import { UserPlus, X } from 'lucide-react'
import { Tenant } from '@/lib/types/tenant'
import UsersTable from './UsersTable'
import UserForm from './UserForm'

interface UserProfile {
  id: string
  user_id: string
  first_name: string | null
  last_name: string | null
  email: string
  role: string
  tenant_id: string | null
  status: string | null
  created_at: string
  last_login_at: string | null
  tenant?: {
    id: string
    name: string
  } | null
}

interface UsersManagementClientProps {
  tenants: Tenant[]
  users: UserProfile[]
}

export default function UsersManagementClient({ tenants, users }: UsersManagementClientProps) {
  const [selectedTenant, setSelectedTenant] = useState<string>('all')
  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false)

  // Filter users based on selected tenant
  const filteredUsers = useMemo(() => {
    if (selectedTenant === 'all') {
      return users
    }
    return users.filter((user) => user.tenant_id === selectedTenant)
  }, [users, selectedTenant])

  // Get selected tenant name for display
  const selectedTenantName = useMemo(() => {
    if (selectedTenant === 'all') return null
    return tenants.find((t) => t.id === selectedTenant)?.name || null
  }, [selectedTenant, tenants])

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">User Provisioning</h1>
          <p className="text-gray-600 mt-1">Manage platform users, roles, and access permissions</p>
        </div>
      </div>

      {/* Tenant Selection Card */}
      <div className="bg-white rounded-lg shadow">
        <div className="p-6 border-b">
          <h2 className="text-lg font-semibold text-gray-800 mb-1">Select Community</h2>
          <p className="text-sm text-gray-600">Choose a community to manage its admin users</p>
        </div>
        <div className="p-6">
          <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
            <div className="w-full sm:w-[300px]">
              <label
                htmlFor="tenant-select"
                className="block text-sm font-medium text-gray-700 mb-2"
              >
                Community
              </label>
              <select
                id="tenant-select"
                value={selectedTenant}
                onChange={(e) => setSelectedTenant(e.target.value)}
                className="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-primary focus:border-primary"
              >
                <option value="all">All Communities</option>
                {tenants.map((tenant) => (
                  <option key={tenant.id} value={tenant.id}>
                    {tenant.name}
                  </option>
                ))}
              </select>
            </div>
            <div className="self-end">
              <button
                onClick={() => setIsCreateModalOpen(true)}
                className="bg-primary hover:bg-secondary text-white py-2 px-4 rounded-lg flex items-center transition-colors duration-200"
              >
                <UserPlus className="h-4 w-4 mr-2" />
                Add User
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Users Table */}
      <UsersTable users={filteredUsers} tenantName={selectedTenantName} />

      {/* Create User Modal */}
      {isCreateModalOpen && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-xl max-w-4xl w-full max-h-[90vh] overflow-y-auto">
            <div className="sticky top-0 bg-white border-b px-6 py-4 flex justify-between items-center">
              <div>
                <h2 className="text-xl font-bold text-gray-800">Create New User</h2>
                <p className="text-sm text-gray-600 mt-1">Add a new user to the platform</p>
              </div>
              <button
                onClick={() => setIsCreateModalOpen(false)}
                className="text-gray-500 hover:text-gray-700 transition-colors"
              >
                <X className="h-6 w-6" />
              </button>
            </div>
            <div className="p-6">
              <UserForm
                mode="create"
                tenants={tenants}
                onSuccess={() => {
                  setIsCreateModalOpen(false)
                  window.location.reload() // Refresh to show new user
                }}
              />
            </div>

            {/* Information Box */}
            <div className="mx-6 mb-6 bg-blue-50 border border-blue-200 rounded-lg p-4">
              <h3 className="text-sm font-semibold text-blue-900 mb-2">Important Information</h3>
              <ul className="text-sm text-blue-800 space-y-1">
                <li>• User accounts are created in Supabase Auth with the provided credentials</li>
                <li>• Super Admins have platform-wide access to all tenants</li>
                <li>• Admin Heads can fully manage their assigned tenant</li>
                <li>• Admin Officers have limited administrative access</li>
                <li>• All roles except Super Admin require a tenant assignment</li>
              </ul>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
