'use client'

import { useState, useMemo } from 'react'
import Link from 'next/link'
import { Tenant } from '@/lib/types/tenant'
import { Eye, Edit, MoreVertical, Trash2, Search, Filter } from 'lucide-react'
import Pagination from '@/components/ui/Pagination'

interface TenantListProps {
  tenants: Tenant[]
}

const ITEMS_PER_PAGE = 10

export default function TenantList({ tenants }: TenantListProps) {
  const [activeDropdown, setActiveDropdown] = useState<string | null>(null)
  const [sortBy, setSortBy] = useState<'name' | 'city' | 'created_at'>('name')
  const [sortOrder, setSortOrder] = useState<'asc' | 'desc'>('asc')
  const [searchQuery, setSearchQuery] = useState('')
  const [statusFilter, setStatusFilter] = useState<string>('all')
  const [currentPage, setCurrentPage] = useState(1)

  const handleSort = (column: 'name' | 'city' | 'created_at') => {
    if (sortBy === column) {
      setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc')
    } else {
      setSortBy(column)
      setSortOrder('asc')
    }
  }

  // Filter and sort tenants with useMemo for performance
  const filteredAndSortedTenants = useMemo(() => {
    let filtered = tenants

    // Apply search filter
    if (searchQuery) {
      const query = searchQuery.toLowerCase()
      filtered = filtered.filter(
        (tenant) =>
          tenant.name.toLowerCase().includes(query) ||
          tenant.address?.toLowerCase().includes(query) ||
          tenant.city?.toLowerCase().includes(query) ||
          tenant.state?.toLowerCase().includes(query)
      )
    }

    // Apply status filter
    if (statusFilter !== 'all') {
      filtered = filtered.filter((tenant) => tenant.subscription_status === statusFilter)
    }

    // Sort tenants
    const sorted = [...filtered].sort((a, b) => {
      let compareValue = 0
      if (sortBy === 'name') {
        compareValue = a.name.localeCompare(b.name)
      } else if (sortBy === 'city') {
        compareValue = (a.city || '').localeCompare(b.city || '')
      } else if (sortBy === 'created_at') {
        compareValue = new Date(a.created_at).getTime() - new Date(b.created_at).getTime()
      }
      return sortOrder === 'asc' ? compareValue : -compareValue
    })

    return sorted
  }, [tenants, searchQuery, statusFilter, sortBy, sortOrder])

  // Pagination logic
  const totalPages = Math.ceil(filteredAndSortedTenants.length / ITEMS_PER_PAGE)
  const paginatedTenants = useMemo(() => {
    const startIndex = (currentPage - 1) * ITEMS_PER_PAGE
    const endIndex = startIndex + ITEMS_PER_PAGE
    return filteredAndSortedTenants.slice(startIndex, endIndex)
  }, [filteredAndSortedTenants, currentPage])

  // Reset to page 1 when filters change
  const handleSearchChange = (query: string) => {
    setSearchQuery(query)
    setCurrentPage(1)
  }

  const handleStatusFilterChange = (status: string) => {
    setStatusFilter(status)
    setCurrentPage(1)
  }

  const toggleDropdown = (e: React.MouseEvent, id: string) => {
    e.stopPropagation()
    setActiveDropdown(activeDropdown === id ? null : id)
  }

  return (
    <div className="bg-white rounded-lg shadow">
      {/* Search and Filter Bar */}
      <div className="p-4 border-b border-gray-200">
        <div className="flex flex-col sm:flex-row gap-4">
          {/* Search Input */}
          <div className="relative flex-1">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <Search className="h-5 w-5 text-gray-400" />
            </div>
            <input
              type="text"
              placeholder="Search by name, address, city, or state..."
              value={searchQuery}
              onChange={(e) => handleSearchChange(e.target.value)}
              className="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md leading-5 bg-white placeholder-gray-500 focus:outline-none focus:placeholder-gray-400 focus:ring-1 focus:ring-primary focus:border-primary sm:text-sm"
            />
          </div>

          {/* Status Filter */}
          <div className="relative">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <Filter className="h-5 w-5 text-gray-400" />
            </div>
            <select
              value={statusFilter}
              onChange={(e) => handleStatusFilterChange(e.target.value)}
              className="block w-full pl-10 pr-10 py-2 border border-gray-300 rounded-md leading-5 bg-white focus:outline-none focus:ring-1 focus:ring-primary focus:border-primary sm:text-sm"
            >
              <option value="all">All Status</option>
              <option value="active">Active</option>
              <option value="trial">Trial</option>
              <option value="suspended">Suspended</option>
              <option value="inactive">Inactive</option>
            </select>
          </div>
        </div>

        {/* Results Count */}
        <div className="mt-3 text-sm text-gray-600">
          Showing <span className="font-semibold">{filteredAndSortedTenants.length}</span> of{' '}
          <span className="font-semibold">{tenants.length}</span> communities
          {searchQuery && (
            <button
              onClick={() => setSearchQuery('')}
              className="ml-2 text-primary hover:text-secondary underline"
            >
              Clear search
            </button>
          )}
          {statusFilter !== 'all' && (
            <button
              onClick={() => setStatusFilter('all')}
              className="ml-2 text-primary hover:text-secondary underline"
            >
              Clear filter
            </button>
          )}
        </div>
      </div>

      {filteredAndSortedTenants.length === 0 ? (
        <div className="p-12 text-center">
          <p className="text-gray-500 text-lg">No communities found</p>
          <p className="text-gray-400 text-sm mt-2">
            {searchQuery || statusFilter !== 'all'
              ? 'Try adjusting your search or filter criteria'
              : 'Create your first community to get started'}
          </p>
        </div>
      ) : (
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th
                className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-100"
                onClick={() => handleSort('name')}
              >
                <div className="flex items-center">
                  Community Name
                  {sortBy === 'name' && <span className="ml-1">{sortOrder === 'asc' ? '↑' : '↓'}</span>}
                </div>
              </th>
              <th
                className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-100"
                onClick={() => handleSort('city')}
              >
                <div className="flex items-center">
                  Location
                  {sortBy === 'city' && <span className="ml-1">{sortOrder === 'asc' ? '↑' : '↓'}</span>}
                </div>
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Units
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Status
              </th>
              <th
                className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-100"
                onClick={() => handleSort('created_at')}
              >
                <div className="flex items-center">
                  Created
                  {sortBy === 'created_at' && (
                    <span className="ml-1">{sortOrder === 'asc' ? '↑' : '↓'}</span>
                  )}
                </div>
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {paginatedTenants.map((tenant) => (
              <tr key={tenant.id} className="hover:bg-gray-50 transition-colors duration-150">
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="text-sm font-medium text-gray-900">{tenant.name}</div>
                  <div className="text-xs text-gray-500">{tenant.address}</div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="text-sm text-gray-500">
                    {tenant.city || '-'}
                    {tenant.state && `, ${tenant.state}`}
                  </div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="text-sm text-gray-500">{tenant.max_residences || '-'}</div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span
                    className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${
                      tenant.subscription_status === 'active'
                        ? 'bg-green-100 text-green-800'
                        : tenant.subscription_status === 'trial'
                          ? 'bg-amber-100 text-amber-800'
                          : tenant.subscription_status === 'suspended'
                            ? 'bg-red-100 text-red-800'
                            : 'bg-gray-100 text-gray-800'
                    }`}
                  >
                    {tenant.subscription_status.charAt(0).toUpperCase() +
                      tenant.subscription_status.slice(1)}
                  </span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="text-sm text-gray-500">
                    {new Date(tenant.created_at).toLocaleDateString()}
                  </div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                  <div className="flex items-center">
                    <Link
                      href={`/tenants/${tenant.id}`}
                      className="text-primary hover:text-secondary mr-3 flex items-center"
                      title="View details"
                    >
                      <Eye className="h-4 w-4" />
                    </Link>
                    <Link
                      href={`/tenants/${tenant.id}/edit`}
                      className="text-secondary hover:text-primary mr-3 flex items-center"
                      title="Edit community"
                    >
                      <Edit className="h-4 w-4" />
                    </Link>
                    <div className="relative">
                      <button
                        onClick={(e) => toggleDropdown(e, tenant.id)}
                        className="text-gray-400 hover:text-gray-600"
                      >
                        <MoreVertical className="h-5 w-5" />
                      </button>
                      {activeDropdown === tenant.id && (
                        <div className="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg z-10 border">
                          <div className="py-1">
                            <Link
                              href={`/tenants/${tenant.id}/admin-users/new`}
                              className="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                            >
                              Add Admin User
                            </Link>
                            <Link
                              href={`/tenants/${tenant.id}/properties`}
                              className="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                            >
                              Manage Properties
                            </Link>
                            <button className="block w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-gray-100">
                              <Trash2 className="h-4 w-4 inline mr-2" />
                              Delete Community
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
      </div>
      )}

      {/* Pagination */}
      {filteredAndSortedTenants.length > 0 && (
        <Pagination
          currentPage={currentPage}
          totalPages={totalPages}
          onPageChange={setCurrentPage}
          totalItems={filteredAndSortedTenants.length}
          itemsPerPage={ITEMS_PER_PAGE}
        />
      )}
    </div>
  )
}
