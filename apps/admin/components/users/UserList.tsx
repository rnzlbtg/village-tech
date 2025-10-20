'use client'

import { useState } from 'react'
import { format } from 'date-fns'
import {
  Users,
  Plus,
  Search,
  MoreVertical,
  Edit,
  Trash2,
  Key,
  UserCheck,
  UserX,
  Shield,
  ShieldCheck,
  AlertCircle
} from 'lucide-react'
import { ConfirmModal } from '@/components/ui/ConfirmModal'
import { toast } from 'sonner'

interface User {
  id: string
  email: string
  first_name: string
  last_name: string
  phone_number?: string
  role: 'admin_head' | 'admin_officer' | 'security_head' | 'security_officer'
  is_active: boolean
  created_at: string
  updated_at: string
}

interface UserListProps {
  users: User[]
  onCreateUser: () => void
  onDeleteUser: (userId: string) => void
  onToggleStatus: (userId: string) => void
  onResetPassword: (userId: string) => void
  isLoading?: boolean
}

export default function UserList({
  users,
  onCreateUser,
  onDeleteUser,
  onToggleStatus,
  onResetPassword,
  isLoading = false
}: UserListProps) {
  const [searchTerm, setSearchTerm] = useState('')
  const [showDeleteModal, setShowDeleteModal] = useState(false)
  const [showStatusModal, setShowStatusModal] = useState(false)
  const [selectedUser, setSelectedUser] = useState<User | null>(null)
  const [actionLoading, setActionLoading] = useState(false)

  // Filter users based on search term
  const filteredUsers = users.filter(user => {
    const searchLower = searchTerm.toLowerCase()
    return (
      user.first_name.toLowerCase().includes(searchLower) ||
      user.last_name.toLowerCase().includes(searchLower) ||
      user.email.toLowerCase().includes(searchLower) ||
      user.role.toLowerCase().includes(searchLower)
    )
  })

  const getRoleDisplay = (role: string) => {
    switch (role) {
      case 'admin_head':
        return { label: 'Admin Head', color: 'text-purple-600 bg-purple-100' }
      case 'admin_officer':
        return { label: 'Admin Officer', color: 'text-blue-600 bg-blue-100' }
      case 'security_head':
        return { label: 'Security Head', color: 'text-green-600 bg-green-100' }
      case 'security_officer':
        return { label: 'Security Officer', color: 'text-orange-600 bg-orange-100' }
      default:
        return { label: role, color: 'text-gray-600 bg-gray-100' }
    }
  }

  const getRoleIcon = (role: string) => {
    switch (role) {
      case 'admin_head':
      case 'admin_officer':
        return Shield
      case 'security_head':
      case 'security_officer':
        return ShieldCheck
      default:
        return Users
    }
  }

  const handleDeleteClick = (user: User) => {
    setSelectedUser(user)
    setShowDeleteModal(true)
  }

  const handleDeleteConfirm = async () => {
    if (!selectedUser) return

    setActionLoading(true)
    try {
      await onDeleteUser(selectedUser.id)
      setShowDeleteModal(false)
      setSelectedUser(null)
      toast.success('User deleted successfully')
    } catch (error) {
      toast.error('Failed to delete user')
    } finally {
      setActionLoading(false)
    }
  }

  const handleStatusToggle = async (user: User) => {
    setSelectedUser(user)
    setShowStatusModal(true)
  }

  const handleStatusConfirm = async () => {
    if (!selectedUser) return

    setActionLoading(true)
    try {
      await onToggleStatus(selectedUser.id)
      setShowStatusModal(false)
      setSelectedUser(null)
      toast.success(`User ${selectedUser.is_active ? 'deactivated' : 'activated'} successfully`)
    } catch (error) {
      toast.error('Failed to update user status')
    } finally {
      setActionLoading(false)
    }
  }

  const handleResetPassword = async (user: User) => {
    // In a real implementation, this would open a modal to enter new password
    // For now, we'll just show a toast
    toast.info('Password reset feature coming soon')
  }

  if (isLoading) {
    return (
      <div className="flex items-center justify-center py-12">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
        <span className="ml-3 text-gray-600">Loading users...</span>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">User Management</h2>
          <p className="text-gray-600 mt-1">Manage admin and security personnel accounts</p>
        </div>
        <button
          onClick={onCreateUser}
          className="flex items-center gap-2 px-4 py-2 text-white bg-primary rounded-md hover:bg-primary-dark transition-colors"
        >
          <Plus className="h-5 w-5" />
          Add User
        </button>
      </div>

      {/* Search Bar */}
      <div className="relative">
        <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
        <input
          type="text"
          placeholder="Search users by name, email, or role..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary"
        />
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-4 gap-4">
        <div className="bg-white border border-gray-200 rounded-lg p-4">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-blue-100 rounded-lg">
              <Users className="h-6 w-6 text-blue-600" />
            </div>
            <div>
              <p className="text-2xl font-bold text-gray-900">{users.length}</p>
              <p className="text-sm text-gray-600">Total Users</p>
            </div>
          </div>
        </div>
        <div className="bg-white border border-gray-200 rounded-lg p-4">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-green-100 rounded-lg">
              <UserCheck className="h-6 w-6 text-green-600" />
            </div>
            <div>
              <p className="text-2xl font-bold text-gray-900">
                {users.filter(u => u.is_active).length}
              </p>
              <p className="text-sm text-gray-600">Active</p>
            </div>
          </div>
        </div>
        <div className="bg-white border border-gray-200 rounded-lg p-4">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-red-100 rounded-lg">
              <UserX className="h-6 w-6 text-red-600" />
            </div>
            <div>
              <p className="text-2xl font-bold text-gray-900">
                {users.filter(u => !u.is_active).length}
              </p>
              <p className="text-sm text-gray-600">Inactive</p>
            </div>
          </div>
        </div>
        <div className="bg-white border border-gray-200 rounded-lg p-4">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-purple-100 rounded-lg">
              <Shield className="h-6 w-6 text-purple-600" />
            </div>
            <div>
              <p className="text-2xl font-bold text-gray-900">
                {users.filter(u => u.role.startsWith('admin')).length}
              </p>
              <p className="text-sm text-gray-600">Admin Users</p>
            </div>
          </div>
        </div>
      </div>

      {/* User List */}
      {filteredUsers.length === 0 ? (
        <div className="bg-white border border-gray-200 rounded-lg p-12 text-center">
          <Users className="h-12 w-12 text-gray-400 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">
            {searchTerm ? 'No users found' : 'No users yet'}
          </h3>
          <p className="text-gray-600 mb-6">
            {searchTerm
              ? 'Try adjusting your search terms or filters.'
              : 'Get started by adding your first admin or security personnel.'
            }
          </p>
          {!searchTerm && (
            <button
              onClick={onCreateUser}
              className="flex items-center gap-2 px-4 py-2 text-white bg-primary rounded-md hover:bg-primary-dark transition-colors mx-auto"
            >
              <Plus className="h-5 w-5" />
              Add First User
            </button>
          )}
        </div>
      ) : (
        <div className="bg-white border border-gray-200 rounded-lg overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50 border-b border-gray-200">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    User
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Role
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Status
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Created
                  </th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {filteredUsers.map((user) => {
                  const RoleIcon = getRoleIcon(user.role)
                  const roleDisplay = getRoleDisplay(user.role)

                  return (
                    <tr key={user.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center gap-3">
                          <div className="flex-shrink-0">
                            <div className="h-10 w-10 rounded-full bg-gray-200 flex items-center justify-center">
                              <RoleIcon className="h-5 w-5 text-gray-600" />
                            </div>
                          </div>
                          <div>
                            <div className="text-sm font-medium text-gray-900">
                              {user.first_name} {user.last_name}
                            </div>
                            <div className="text-sm text-gray-500">{user.email}</div>
                            {user.phone_number && (
                              <div className="text-xs text-gray-400">{user.phone_number}</div>
                            )}
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-medium ${roleDisplay.color}`}>
                          <RoleIcon className="h-3 w-3" />
                          {roleDisplay.label}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-medium ${
                          user.is_active
                            ? 'text-green-600 bg-green-100'
                            : 'text-red-600 bg-red-100'
                        }`}>
                          {user.is_active ? (
                            <>
                              <UserCheck className="h-3 w-3" />
                              Active
                            </>
                          ) : (
                            <>
                              <UserX className="h-3 w-3" />
                              Inactive
                            </>
                          )}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {format(new Date(user.created_at), 'MMM dd, yyyy')}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                        <div className="flex items-center justify-end gap-2">
                          <button
                            onClick={() => handleStatusToggle(user)}
                            className="p-1 text-gray-400 hover:text-gray-600 transition-colors"
                            title={user.is_active ? 'Deactivate user' : 'Activate user'}
                          >
                            {user.is_active ? (
                              <UserX className="h-4 w-4" />
                            ) : (
                              <UserCheck className="h-4 w-4" />
                            )}
                          </button>
                          <button
                            onClick={() => onResetPassword(user.id)}
                            className="p-1 text-gray-400 hover:text-gray-600 transition-colors"
                            title="Reset password"
                          >
                            <Key className="h-4 w-4" />
                          </button>
                            <button
                            onClick={() => handleDeleteClick(user)}
                            className="p-1 text-red-400 hover:text-red-600 transition-colors"
                            title="Delete user"
                          >
                            <Trash2 className="h-4 w-4" />
                          </button>
                        </div>
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Delete Confirmation Modal */}
      <ConfirmModal
        isOpen={showDeleteModal}
        title="Delete User"
        message={`Are you sure you want to delete "${selectedUser?.first_name} ${selectedUser?.last_name}"? This action cannot be undone and will remove all access to the system.`}
        confirmText="Delete User"
        cancelText="Cancel"
        onConfirm={handleDeleteConfirm}
        onCancel={() => {
          setShowDeleteModal(false)
          setSelectedUser(null)
        }}
        confirmButtonClass="bg-red-600 hover:bg-red-700"
      />

      {/* Status Toggle Confirmation Modal */}
      <ConfirmModal
        isOpen={showStatusModal}
        title={`${selectedUser?.is_active ? 'Deactivate' : 'Activate'} User`}
        message={`Are you sure you want to ${selectedUser?.is_active ? 'deactivate' : 'activate'} "${selectedUser?.first_name} ${selectedUser?.last_name}"? ${selectedUser?.is_active ? 'They will no longer be able to log in to the system.' : 'They will regain access to the system.'}`}
        confirmText={selectedUser?.is_active ? 'Deactivate' : 'Activate'}
        cancelText="Cancel"
        onConfirm={handleStatusConfirm}
        onCancel={() => {
          setShowStatusModal(false)
          setSelectedUser(null)
        }}
        confirmButtonClass={selectedUser?.is_active ? 'bg-red-600 hover:bg-red-700' : 'bg-green-600 hover:bg-green-700'}
      />
    </div>
  )
}