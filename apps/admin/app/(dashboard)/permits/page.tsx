import { createClient } from '@/lib/supabase/server'
import { getTenantId } from '@/lib/auth/helpers'
import { redirect } from 'next/navigation'

export const metadata = {
  title: 'Construction Permits | Admin',
  description: 'Manage construction permits',
}

type PermitStatus = 'pending' | 'approved' | 'in_progress' | 'completed' | 'rejected' | 'on_hold'

export default async function PermitsPage({
  searchParams,
}: {
  searchParams: { status?: PermitStatus }
}) {
  const supabase = await createClient()
  const tenantId = await getTenantId()

  if (!tenantId) {
    redirect('/login')
  }

  // Build query with optional status filter
  let query = supabase
    .from('construction_permits')
    .select(`
      id,
      permit_reference,
      project_description,
      contractor_name,
      start_date,
      end_date,
      road_fee,
      status,
      payment_status,
      created_at,
      household:households!inner(
        id,
        household_name,
        residence_unit:residence_units(unit_number)
      )
    `)
    .eq('tenant_id', tenantId)
    .order('created_at', { ascending: false })

  if (searchParams.status) {
    query = query.eq('status', searchParams.status)
  }

  const { data: permits, error } = await query

  if (error) {
    console.error('Error fetching permits:', error)
  }

  const statusCounts = {
    all: permits?.length || 0,
    pending: permits?.filter(p => p.status === 'pending').length || 0,
    approved: permits?.filter(p => p.status === 'approved').length || 0,
    in_progress: permits?.filter(p => p.status === 'in_progress').length || 0,
    completed: permits?.filter(p => p.status === 'completed').length || 0,
  }

  return (
    <div className="container mx-auto py-6">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-3xl font-bold">Construction Permits</h1>
          <p className="text-gray-600 mt-1">
            Manage construction permit requests and approvals
          </p>
        </div>
      </div>

      {/* Status Filters */}
      <div className="mb-6 flex gap-2 flex-wrap">
        <StatusFilterButton status={null} label="All" count={statusCounts.all} current={searchParams.status} />
        <StatusFilterButton
          status="pending"
          label="Pending"
          count={statusCounts.pending}
          current={searchParams.status}
        />
        <StatusFilterButton
          status="approved"
          label="Approved"
          count={statusCounts.approved}
          current={searchParams.status}
        />
        <StatusFilterButton
          status="in_progress"
          label="In Progress"
          count={statusCounts.in_progress}
          current={searchParams.status}
        />
        <StatusFilterButton
          status="completed"
          label="Completed"
          count={statusCounts.completed}
          current={searchParams.status}
        />
      </div>

      {/* Permits Table */}
      <div className="bg-white rounded-lg shadow">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Permit Reference
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Household
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Project
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Contractor
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Period
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Road Fee
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Payment
                </th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {permits && permits.length > 0 ? (
                permits.map((permit: any) => (
                  <tr key={permit.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm font-medium text-gray-900">{permit.permit_reference}</div>
                      <div className="text-xs text-gray-500">
                        {new Date(permit.created_at).toLocaleDateString()}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-gray-900">{permit.household?.household_name}</div>
                      <div className="text-xs text-gray-500">
                        Unit: {permit.household?.residence_unit?.unit_number || 'N/A'}
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="text-sm text-gray-900 max-w-xs truncate">
                        {permit.project_description}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-gray-900">{permit.contractor_name}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      <div>{new Date(permit.start_date).toLocaleDateString()}</div>
                      <div>to {new Date(permit.end_date).toLocaleDateString()}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      ${permit.road_fee.toFixed(2)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <StatusBadge status={permit.status} />
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <PaymentBadge status={permit.payment_status} />
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <a
                        href={`/permits/${permit.id}`}
                        className="text-blue-600 hover:text-blue-900 mr-3"
                      >
                        View
                      </a>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={9} className="px-6 py-12 text-center text-gray-500">
                    {searchParams.status
                      ? `No ${searchParams.status} permits found`
                      : 'No construction permits yet'}
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}

function StatusFilterButton({
  status,
  label,
  count,
  current,
}: {
  status: PermitStatus | null
  label: string
  count: number
  current?: PermitStatus
}) {
  const isActive = (status === null && !current) || status === current
  const href = status ? `/permits?status=${status}` : '/permits'

  return (
    <a
      href={href}
      className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
        isActive
          ? 'bg-blue-600 text-white'
          : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
      }`}
    >
      {label} <span className="ml-1">({count})</span>
    </a>
  )
}

function StatusBadge({ status }: { status: string }) {
  const colors: Record<string, string> = {
    pending: 'bg-yellow-100 text-yellow-800',
    approved: 'bg-green-100 text-green-800',
    in_progress: 'bg-blue-100 text-blue-800',
    completed: 'bg-gray-100 text-gray-800',
    rejected: 'bg-red-100 text-red-800',
    on_hold: 'bg-orange-100 text-orange-800',
  }

  return (
    <span
      className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
        colors[status] || 'bg-gray-100 text-gray-800'
      }`}
    >
      {status.replace('_', ' ')}
    </span>
  )
}

function PaymentBadge({ status }: { status: string }) {
  const colors: Record<string, string> = {
    unpaid: 'bg-red-100 text-red-800',
    partial: 'bg-yellow-100 text-yellow-800',
    paid: 'bg-green-100 text-green-800',
  }

  return (
    <span
      className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
        colors[status] || 'bg-gray-100 text-gray-800'
      }`}
    >
      {status}
    </span>
  )
}
