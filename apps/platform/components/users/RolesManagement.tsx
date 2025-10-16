'use client'

import { Shield, Info, Building } from 'lucide-react'

interface RoleWithStats {
  role: string
  userCount: number
  tenants: string[]
}

interface RolesManagementProps {
  roles: RoleWithStats[]
}

// Role metadata for display
const roleMetadata: Record<string, { name: string; description: string }> = {
  super_admin: {
    name: 'Super Admin',
    description: 'Full access to all features and settings across all communities',
  },
  admin_head: {
    name: 'Admin Head',
    description: 'Manage communities, users, and settings within assigned community',
  },
  admin_officer: {
    name: 'Admin Officer',
    description: 'Limited administrative access to manage specific community operations',
  },
  household_head: {
    name: 'Household Head',
    description: 'Manage household members and access community features',
  },
  guard: {
    name: 'Guard',
    description: 'Access gate management and visitor logging',
  },
}

export default function RolesManagement({ roles }: RolesManagementProps) {

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-gray-800">Active Roles</h1>
      </div>

      <div className="bg-primary-light border-l-4 border-primary p-4 rounded-md">
        <div className="flex">
          <Info className="h-5 w-5 text-primary mr-2 flex-shrink-0" />
          <p className="text-sm text-primary">
            Displaying roles currently assigned to users in the system. Role assignments determine
            access levels and permissions within the platform.
          </p>
        </div>
      </div>

      {roles.length > 0 ? (
        <div className="bg-white rounded-lg shadow">
          <div className="p-6 border-b">
            <h2 className="text-lg font-semibold text-gray-800">
              {roles.length} {roles.length === 1 ? 'Role' : 'Roles'} in Use
            </h2>
          </div>
          <div className="divide-y divide-gray-200">
            {roles.map((role) => {
              const metadata = roleMetadata[role.role] || {
                name: role.role,
                description: 'Custom role',
              }

              return (
                <div key={role.role} className="p-6">
                  <div className="flex justify-between items-start">
                    <div className="flex-1">
                      <h3 className="text-lg font-medium text-gray-800 flex items-center">
                        <Shield className="h-5 w-5 mr-2 text-primary" />
                        {metadata.name}
                      </h3>
                      <p className="text-sm text-gray-600 mt-1">{metadata.description}</p>
                      <div className="mt-3 flex items-center gap-4 flex-wrap">
                        <span className="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-primary-light text-primary">
                          {role.userCount} {role.userCount === 1 ? 'user' : 'users'}
                        </span>
                        <span className="text-xs text-gray-500 font-mono">{role.role}</span>
                        {role.tenants.length > 0 && (
                          <div className="flex items-center gap-2">
                            <Building className="h-3.5 w-3.5 text-gray-400" />
                            <span className="text-xs text-gray-500">
                              {role.tenants.length}{' '}
                              {role.tenants.length === 1 ? 'community' : 'communities'}
                            </span>
                          </div>
                        )}
                      </div>
                      {role.tenants.length > 0 && (
                        <div className="mt-2">
                          <p className="text-xs text-gray-500">
                            Communities: {role.tenants.join(', ')}
                          </p>
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              )
            })}
          </div>
        </div>
      ) : (
        <div className="bg-white rounded-lg shadow p-12 text-center">
          <Shield className="h-12 w-12 text-gray-300 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">No Active Roles</h3>
          <p className="text-sm text-gray-500">
            No role assignments found in the system. Users need to be assigned roles to access the
            platform.
          </p>
        </div>
      )}
    </div>
  )
}
