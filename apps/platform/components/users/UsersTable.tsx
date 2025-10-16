'use client'

import { useState } from 'react'
import Link from 'next/link'
import { Search, Filter, X, Eye, Edit, MoreVertical, Trash2, User } from 'lucide-react'

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

interface UsersTableProps {
  users: UserProfile[]
  tenantName?: string | null
}

export default function UsersTable({ users, tenantName }: UsersTableProps) {
  const [searchTerm, setSearchTerm] = useState('')
  const [filterOpen, setFilterOpen] = useState(false)
  const [selectedRole, setSelectedRole] = useState('all')
  const [selectedStatus, setSelectedStatus] = useState('all')
  const [sortBy, setSortBy] = useState<'name' | 'email' | 'role' | 'date'>('name')
  const [sortOrder, setSortOrder] = useState<'asc' | 'desc'>('asc')
  const [activeDropdown, setActiveDropdown] = useState<string | null>(null)

  // Available roles for filter
  const roles = ['all', 'super_admin', 'admin_head', 'admin_officer']
  const statuses = ['all', 'active', 'inactive', 'pending']

  // Handle search and filtering
  const filteredAndSortedUsers = users
    .filter((user) => {
      const fullName = `${user.first_name || ''} ${user.last_name || ''}`.toLowerCase()
      const matchesSearch =
        fullName.includes(searchTerm.toLowerCase()) ||
        (user.email || '').toLowerCase().includes(searchTerm.toLowerCase())
      const matchesRole = selectedRole === 'all' || user.role === selectedRole
      const matchesStatus = selectedStatus === 'all' || user.status === selectedStatus
      return matchesSearch && matchesRole && matchesStatus
    })
    .sort((a, b) => {
      let comparison = 0
      const aFullName = `${a.first_name || ''} ${a.last_name || ''}`
      const bFullName = `${b.first_name || ''} ${b.last_name || ''}`

      switch (sortBy) {
        case 'name':
          comparison = aFullName.localeCompare(bFullName)
          break
        case 'email':
          comparison = (a.email || '').localeCompare(b.email || '')
          break
        case 'role':
          comparison = a.role.localeCompare(b.role)
          break
        case 'date':
          comparison = new Date(a.created_at).getTime() - new Date(b.created_at).getTime()
          break
        default:
          comparison = 0
      }
      return sortOrder === 'asc' ? comparison : -comparison
    })

  // Handle sorting
  const handleSort = (column: 'name' | 'email' | 'role' | 'date') => {
    if (sortBy === column) {
      setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc')
    } else {
      setSortBy(column)
      setSortOrder('asc')
    }
  }

  // Format last login
  const formatLastLogin = (lastLogin: string | null) => {
    if (!lastLogin) return 'Never'
    const date = new Date(lastLogin)
    const now = new Date()
    const diffMs = now.getTime() - date.getTime()
    const diffMins = Math.floor(diffMs / 60000)
    const diffHours = Math.floor(diffMins / 60)
    const diffDays = Math.floor(diffHours / 24)

    if (diffMins < 60) return `${diffMins} minutes ago`
    if (diffHours < 24) return `${diffHours} hours ago`
    if (diffDays < 7) return `${diffDays} days ago`
    return date.toLocaleDateString()
  }

  // Format role display
  const formatRole = (role: string) => {
    return role
      .split('_')
      .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
      .join(' ')
  }

  return (
    <div className="bg-white rounded-lg shadow">
      <div className="p-6 border-b flex flex-wrap justify-between items-center gap-4">
        <h2 className="text-lg font-semibold text-gray-800">
          {tenantName ? `Admin Users - ${tenantName}` : 'All Users'}
        </h2>
        <div className="flex items-center space-x-3">
          <div className="relative">
            <input
              type="text"
              placeholder="Search users..."
              className="pl-10 pr-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
            <Search className="absolute left-3 top-2.5 h-5 w-5 text-gray-400" />
            {searchTerm && (
              <button
                onClick={() => setSearchTerm('')}
                className="absolute right-3 top-2.5 text-gray-400 hover:text-gray-600"
              >
                <X className="h-4 w-4" />
              </button>
            )}
          </div>
          <button
            onClick={() => setFilterOpen(!filterOpen)}
            className={`p-2 rounded-lg border ${
              filterOpen ? 'bg-primary-light border-primary' : 'hover:bg-gray-50'
            }`}
          >
            <Filter
              className={`h-5 w-5 ${filterOpen ? 'text-primary' : 'text-gray-500'}`}
            />
          </button>
        </div>
      </div>

      {/* Filter Panel */}
      {filterOpen && (
        <div className="p-4 border-b bg-gray-50">
          <div className="flex flex-wrap items-center gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Role</label>
              <select
                value={selectedRole}
                onChange={(e) => setSelectedRole(e.target.value)}
                className="px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
              >
                {roles.map((role) => (
                  <option key={role} value={role}>
                    {role === 'all' ? 'All Roles' : formatRole(role)}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Status</label>
              <select
                value={selectedStatus}
                onChange={(e) => setSelectedStatus(e.target.value)}
                className="px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
              >
                {statuses.map((status) => (
                  <option key={status} value={status}>
                    {status === 'all'
                      ? 'All Statuses'
                      : status.charAt(0).toUpperCase() + status.slice(1)}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Sort By</label>
              <select
                value={sortBy}
                onChange={(e) => setSortBy(e.target.value as 'name' | 'email' | 'role' | 'date')}
                className="px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
              >
                <option value="name">Name</option>
                <option value="email">Email</option>
                <option value="role">Role</option>
                <option value="date">Date Created</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Order</label>
              <select
                value={sortOrder}
                onChange={(e) => setSortOrder(e.target.value as 'asc' | 'desc')}
                className="px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
              >
                <option value="asc">Ascending</option>
                <option value="desc">Descending</option>
              </select>
            </div>
            <div className="ml-auto self-end">
              <button
                onClick={() => {
                  setSelectedRole('all')
                  setSelectedStatus('all')
                  setSortBy('name')
                  setSortOrder('asc')
                }}
                className="px-3 py-2 text-sm text-gray-600 hover:text-gray-800"
              >
                Reset Filters
              </button>
            </div>
          </div>
        </div>
      )}

      <div className="p-6">
        {filteredAndSortedUsers.length > 0 ? (
          <table className="min-w-full divide-y divide-gray-200">
            <thead>
              <tr>
                <th
                  className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-50"
                  onClick={() => handleSort('name')}
                >
                  <div className="flex items-center">
                    User
                    {sortBy === 'name' && <span className="ml-1">{sortOrder === 'asc' ? '↑' : '↓'}</span>}
                  </div>
                </th>
                <th
                  className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-50"
                  onClick={() => handleSort('email')}
                >
                  <div className="flex items-center">
                    Email
                    {sortBy === 'email' && <span className="ml-1">{sortOrder === 'asc' ? '↑' : '↓'}</span>}
                  </div>
                </th>
                <th
                  className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-50"
                  onClick={() => handleSort('role')}
                >
                  <div className="flex items-center">
                    Role
                    {sortBy === 'role' && <span className="ml-1">{sortOrder === 'asc' ? '↑' : '↓'}</span>}
                  </div>
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Community
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Last Login
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredAndSortedUsers.map((user) => (
                <tr key={user.id} className="hover:bg-gray-50 transition-colors duration-150">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="flex-shrink-0 h-10 w-10 bg-primary-light rounded-full flex items-center justify-center">
                        <User className="h-5 w-5 text-primary" />
                      </div>
                      <div className="ml-4">
                        <div className="text-sm font-medium text-gray-900">
                          {user.first_name} {user.last_name}
                        </div>
                        <div className="text-xs text-gray-500">
                          Created: {new Date(user.created_at).toLocaleDateString()}
                        </div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-500">{user.email}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-500">{formatRole(user.role)}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-500">
                      {user.tenant ? user.tenant.name : 'All Communities'}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span
                      className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${
                        user.status === 'active'
                          ? 'bg-green-100 text-green-800'
                          : user.status === 'pending'
                            ? 'bg-yellow-100 text-yellow-800'
                            : 'bg-gray-100 text-gray-800'
                      }`}
                    >
                      {user.status
                        ? user.status.charAt(0).toUpperCase() + user.status.slice(1)
                        : 'Inactive'}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-500">{formatLastLogin(user.last_login_at)}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <div className="flex items-center">
                      <Link
                        href={`/users/${user.id}`}
                        className="text-primary hover:text-primary-dark mr-3 flex items-center"
                        title="View details"
                      >
                        <Eye className="h-4 w-4" />
                      </Link>
                      <Link
                        href={`/users/${user.id}/edit`}
                        className="text-primary-dark hover:text-primary mr-3 flex items-center"
                        title="Edit user"
                      >
                        <Edit className="h-4 w-4" />
                      </Link>
                      <div className="relative">
                        <button
                          onClick={() =>
                            setActiveDropdown(activeDropdown === user.id ? null : user.id)
                          }
                          className="text-gray-400 hover:text-gray-600"
                        >
                          <MoreVertical className="h-5 w-5" />
                        </button>
                        {activeDropdown === user.id && (
                          <div className="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg z-10 border">
                            <div className="py-1">
                              <button className="block w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-gray-100">
                                Delete User
                              </button>
                            </div>
                          </div>
                        )}
                      </div>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <div className="text-center py-8">
            <p className="text-gray-500">No users found matching your criteria</p>
          </div>
        )}
      </div>
    </div>
  )
}
