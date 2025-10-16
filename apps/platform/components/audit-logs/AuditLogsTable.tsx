'use client'

import { useState } from 'react'
import { Filter, X, Search } from 'lucide-react'
import { Tenant } from '@/lib/types/tenant'

interface AuditLog {
  id: string
  tenant_id: string
  user_id: string | null
  table_name: string
  operation: string
  old_data: any
  new_data: any
  changed_fields: string[] | null
  ip_address: string | null
  user_agent: string | null
  timestamp: string
}

interface AuditLogsTableProps {
  initialLogs: AuditLog[]
  tenants: Tenant[]
}

export default function AuditLogsTable({ initialLogs, tenants }: AuditLogsTableProps) {
  const [logs, setLogs] = useState<AuditLog[]>(initialLogs)
  const [filterOpen, setFilterOpen] = useState(false)
  const [filters, setFilters] = useState({
    tenantId: '',
    action: '',
    entityType: '',
    search: '',
  })

  const filteredLogs = logs.filter((log) => {
    if (filters.tenantId && log.tenant_id !== filters.tenantId) return false
    if (filters.action && log.operation !== filters.action) return false
    if (filters.entityType && log.table_name !== filters.entityType) return false
    if (filters.search) {
      const searchLower = filters.search.toLowerCase()
      return (
        log.operation.toLowerCase().includes(searchLower) ||
        log.table_name.toLowerCase().includes(searchLower) ||
        log.user_id?.toLowerCase().includes(searchLower)
      )
    }
    return true
  })

  const uniqueActions = [...new Set(logs.map((log) => log.operation))]
  const uniqueEntityTypes = [...new Set(logs.map((log) => log.table_name))]

  const resetFilters = () => {
    setFilters({
      tenantId: '',
      action: '',
      entityType: '',
      search: '',
    })
  }

  const getActionBadgeColor = (operation: string) => {
    switch (operation.toUpperCase()) {
      case 'INSERT':
        return 'bg-green-100 text-green-800'
      case 'UPDATE':
        return 'bg-blue-100 text-blue-800'
      case 'DELETE':
        return 'bg-red-100 text-red-800'
      default:
        return 'bg-gray-100 text-gray-800'
    }
  }

  return (
    <div className="bg-white rounded-lg shadow">
      {/* Header with filters */}
      <div className="p-6 border-b">
        <div className="flex flex-wrap justify-between items-center gap-4">
          <h2 className="text-lg font-semibold text-gray-800">Activity Log</h2>
          <div className="flex items-center space-x-3">
            <div className="relative">
              <input
                type="text"
                placeholder="Search logs..."
                className="pl-10 pr-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                value={filters.search}
                onChange={(e) => setFilters({ ...filters, search: e.target.value })}
              />
              <Search className="absolute left-3 top-2.5 h-5 w-5 text-gray-400" />
              {filters.search && (
                <button
                  onClick={() => setFilters({ ...filters, search: '' })}
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
          <div className="mt-4 p-4 border-t bg-gray-50 rounded-lg">
            <div className="flex flex-wrap items-center gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Community</label>
                <select
                  value={filters.tenantId}
                  onChange={(e) => setFilters({ ...filters, tenantId: e.target.value })}
                  className="px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                >
                  <option value="">All Communities</option>
                  {tenants.map((tenant) => (
                    <option key={tenant.id} value={tenant.id}>
                      {tenant.name}
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Action</label>
                <select
                  value={filters.action}
                  onChange={(e) => setFilters({ ...filters, action: e.target.value })}
                  className="px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                >
                  <option value="">All Actions</option>
                  {uniqueActions.map((action) => (
                    <option key={action} value={action}>
                      {action.charAt(0).toUpperCase() + action.slice(1)}
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Entity Type</label>
                <select
                  value={filters.entityType}
                  onChange={(e) => setFilters({ ...filters, entityType: e.target.value })}
                  className="px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                >
                  <option value="">All Types</option>
                  {uniqueEntityTypes.map((type) => (
                    <option key={type} value={type}>
                      {type.charAt(0).toUpperCase() + type.slice(1)}
                    </option>
                  ))}
                </select>
              </div>

              <div className="ml-auto self-end">
                <button
                  onClick={resetFilters}
                  className="px-3 py-2 text-sm text-gray-600 hover:text-gray-800"
                >
                  Reset Filters
                </button>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Table */}
      <div className="overflow-x-auto">
        {filteredLogs.length > 0 ? (
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Timestamp
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Action
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Table
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Changed Fields
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  User ID
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  IP Address
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredLogs.map((log) => (
                <tr key={log.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">
                      {new Date(log.timestamp).toLocaleString()}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span
                      className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${getActionBadgeColor(
                        log.operation
                      )}`}
                    >
                      {log.operation}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-500">{log.table_name}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-500">
                      {log.changed_fields && log.changed_fields.length > 0
                        ? log.changed_fields.join(', ')
                        : '-'}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-500 font-mono truncate max-w-xs">
                      {log.user_id || '-'}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-500">{log.ip_address || '-'}</div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <div className="text-center py-12">
            <p className="text-gray-500">No audit logs found</p>
          </div>
        )}
      </div>

      {/* Footer with count */}
      <div className="px-6 py-4 border-t bg-gray-50">
        <p className="text-sm text-gray-600">
          Showing <span className="font-semibold">{filteredLogs.length}</span> of{' '}
          <span className="font-semibold">{logs.length}</span> logs
        </p>
      </div>
    </div>
  )
}
