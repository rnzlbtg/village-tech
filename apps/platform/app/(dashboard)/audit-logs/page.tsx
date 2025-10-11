import { getAuditLogs, getAuditLogStats } from '@/lib/actions/audit-logs'
import { getTenants } from '@/lib/actions/tenant'
import AuditLogsTable from '@/components/audit-logs/AuditLogsTable'

export default async function AuditLogsPage() {
  const logsResult = await getAuditLogs({ limit: 50, offset: 0 })
  const statsResult = await getAuditLogStats()
  const tenants = await getTenants()

  const logs = logsResult.success ? logsResult.data : []
  const stats = statsResult.success ? statsResult.data : null

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-800">Audit Logs</h1>
        <p className="text-gray-600 mt-1">Track all system activities and changes</p>
      </div>

      {/* Statistics Cards */}
      {stats && (
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div className="bg-white border border-gray-200 rounded-lg p-6">
            <p className="text-sm text-gray-600">Total Logs</p>
            <p className="text-2xl font-bold text-gray-800 mt-1">{stats.total}</p>
          </div>
          <div className="bg-white border border-gray-200 rounded-lg p-6">
            <p className="text-sm text-gray-600">Create Actions</p>
            <p className="text-2xl font-bold text-gray-800 mt-1">{stats.byAction['create'] || 0}</p>
          </div>
          <div className="bg-white border border-gray-200 rounded-lg p-6">
            <p className="text-sm text-gray-600">Update Actions</p>
            <p className="text-2xl font-bold text-gray-800 mt-1">{stats.byAction['update'] || 0}</p>
          </div>
          <div className="bg-white border border-gray-200 rounded-lg p-6">
            <p className="text-sm text-gray-600">Delete Actions</p>
            <p className="text-2xl font-bold text-gray-800 mt-1">{stats.byAction['delete'] || 0}</p>
          </div>
        </div>
      )}

      {/* Audit Logs Table */}
      <AuditLogsTable initialLogs={logs} tenants={tenants} />
    </div>
  )
}
