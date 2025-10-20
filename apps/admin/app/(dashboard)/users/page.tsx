'use client'

import { useState, useEffect } from 'react'
import { toast } from 'sonner'
import { getUsers, createUser, deleteUser, toggleUserStatus } from '@/lib/actions/users'
import UserList from '@/components/users/UserList'
import UserForm from '@/components/users/UserForm'
import { UserModal } from '@/components/users/UserModal'
import { ConfirmModal } from '@/components/ui/ConfirmModal'
import { AdminRole } from '@/lib/validations/users'

interface User {
  id: string
  email: string
  first_name: string
  last_name: string
  phone_number?: string
  role: AdminRole
  is_active: boolean
  created_at: string
  updated_at: string
}

export default function UsersPage() {
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(true)
  const [actionLoading, setActionLoading] = useState(false)
  const [showCreateModal, setShowCreateModal] = useState(false)
  const [showDeleteModal, setShowDeleteModal] = useState(false)
  const [selectedUser, setSelectedUser] = useState<User | null>(null)

  // Fetch users on component mount
  useEffect(() => {
    fetchUsers()
  }, [])

  const fetchUsers = async () => {
    try {
      setLoading(true)
      const result = await getUsers()
      if (result.success) {
        setUsers(result.data || [])
      } else {
        toast.error(result.error || 'Failed to fetch users')
      }
    } catch (error) {
      console.error('Error fetching users:', error)
      toast.error('Failed to fetch users')
    } finally {
      setLoading(false)
    }
  }

  const handleCreateUser = async (formData: any) => {
    try {
      setActionLoading(true)

      // Convert form data to FormData
      const formDataObj = new FormData()
      Object.entries(formData).forEach(([key, value]) => {
        if (typeof value === 'boolean') {
          formDataObj.append(key, value.toString())
        } else {
          formDataObj.append(key, value as string)
        }
      })

      const result = await createUser(formDataObj)

      if (result.success) {
        toast.success(result.message || 'User created successfully')
        setShowCreateModal(false)
        await fetchUsers()
      } else {
        toast.error(result.error || 'Failed to create user')
      }
    } catch (error) {
      console.error('Error creating user:', error)
      toast.error('Failed to create user')
    } finally {
      setActionLoading(false)
    }
  }

  const handleDeleteUser = async (userId: string) => {
    try {
      setActionLoading(true)
      const result = await deleteUser(userId)

      if (result.success) {
        toast.success(result.message || 'User deleted successfully')
        await fetchUsers()
      } else {
        toast.error(result.error || 'Failed to delete user')
      }
    } catch (error) {
      console.error('Error deleting user:', error)
      toast.error('Failed to delete user')
    } finally {
      setActionLoading(false)
    }
  }

  const handleToggleStatus = async (userId: string) => {
    try {
      setActionLoading(true)
      const result = await toggleUserStatus(userId)

      if (result.success) {
        toast.success(result.message || 'User status updated successfully')
        await fetchUsers()
      } else {
        toast.error(result.error || 'Failed to update user status')
      }
    } catch (error) {
      console.error('Error toggling user status:', error)
      toast.error('Failed to update user status')
    } finally {
      setActionLoading(false)
    }
  }

  const handleResetPassword = async (userId: string) => {
    // For now, just show a placeholder toast
    // In a real implementation, this would open a password reset modal
    toast.info('Password reset feature coming soon')
  }

  const handleDeleteClick = (user: User) => {
    setSelectedUser(user)
    setShowDeleteModal(true)
  }

  const handleDeleteConfirm = async () => {
    if (!selectedUser) return

    try {
      await handleDeleteUser(selectedUser.id)
      setShowDeleteModal(false)
      setSelectedUser(null)
    } catch (error) {
      console.error('Error in delete confirmation:', error)
    }
  }

  return (
    <div className="p-6">
      {/* User List */}
      <UserList
        users={users}
        onCreateUser={() => setShowCreateModal(true)}
        onDeleteUser={handleDeleteClick}
        onToggleStatus={handleToggleStatus}
        onResetPassword={handleResetPassword}
        isLoading={loading}
      />

      {/* Create User Modal */}
      <UserModal
        isOpen={showCreateModal}
        title="Create New User"
        mode="create"
        onClose={() => setShowCreateModal(false)}
      >
        <UserForm
          onSubmit={handleCreateUser}
          onCancel={() => setShowCreateModal(false)}
          isLoading={actionLoading}
          mode="create"
        />
      </UserModal>

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
    </div>
  )
}