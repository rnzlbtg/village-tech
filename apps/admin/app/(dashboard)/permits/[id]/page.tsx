import { createClient } from '@/lib/supabase/server'
import { getTenantId } from '@/lib/auth/helpers'
import { redirect } from 'next/navigation'
import { PermitApprovalForm } from '@/components/permits/PermitApprovalForm'
import { PermitActions } from '@/components/permits/PermitActions'

export const metadata = {
  title: 'Permit Details | Admin',
  description: 'View construction permit details',
}

export default async function PermitDetailPage({ params }: { params: { id: string } }) {
  const supabase = await createClient()
  const tenantId = await getTenantId()

  if (!tenantId) {
    redirect('/login')
  }

  const { data: permit, error } = await supabase
    .from('construction_permits')
    .select(`
      *,
      household:households!inner(
        id,
        household_name,
        household_head_id,
        residence_unit:residence_units(
          id,
          unit_number,
          property:properties(name)
        )
      ),
      approved_by_user:user_profiles!construction_permits_approved_by_fkey(
        full_name
      )
    `)
    .eq('id', params.id)
    .eq('tenant_id', tenantId)
    .single()

  if (error || !permit) {
    return (
      <div className="container mx-auto py-6">
        <div className="bg-red-50 border border-red-200 text-red-800 px-4 py-3 rounded">
          Permit not found
        </div>
      </div>
    )
  }

  const authorizedWorkers = Array.isArray(permit.authorized_workers)
    ? permit.authorized_workers
    : []

  return (
    <div className="container mx-auto py-6">
      {/* Header */}
      <div className="mb-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold">{permit.permit_reference}</h1>
            <p className="text-gray-600 mt-1">Construction Permit Details</p>
          </div>
          <div className="flex gap-2">
            <a
              href="/permits"
              className="px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200"
            >
              Back to List
            </a>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Main Content */}
        <div className="lg:col-span-2 space-y-6">
          {/* Status and Payment Info */}
          <div className="bg-white rounded-lg shadow p-6">
            <h2 className="text-xl font-semibold mb-4">Status</h2>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="text-sm font-medium text-gray-500">Permit Status</label>
                <div className="mt-1">
                  <StatusBadge status={permit.status} />
                </div>
              </div>
              <div>
                <label className="text-sm font-medium text-gray-500">Payment Status</label>
                <div className="mt-1">
                  <PaymentBadge status={permit.payment_status} />
                </div>
              </div>
              <div>
                <label className="text-sm font-medium text-gray-500">Road Fee</label>
                <div className="mt-1 text-lg font-semibold">${permit.road_fee.toFixed(2)}</div>
              </div>
              <div>
                <label className="text-sm font-medium text-gray-500">Created</label>
                <div className="mt-1">{new Date(permit.created_at).toLocaleString()}</div>
              </div>
            </div>
          </div>

          {/* Project Details */}
          <div className="bg-white rounded-lg shadow p-6">
            <h2 className="text-xl font-semibold mb-4">Project Details</h2>
            <div className="space-y-4">
              <div>
                <label className="text-sm font-medium text-gray-500">Description</label>
                <p className="mt-1 text-gray-900">{permit.project_description}</p>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-sm font-medium text-gray-500">Start Date</label>
                  <p className="mt-1 text-gray-900">
                    {new Date(permit.start_date).toLocaleDateString()}
                  </p>
                </div>
                <div>
                  <label className="text-sm font-medium text-gray-500">End Date</label>
                  <p className="mt-1 text-gray-900">
                    {new Date(permit.end_date).toLocaleDateString()}
                  </p>
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-sm font-medium text-gray-500">Contractor</label>
                  <p className="mt-1 text-gray-900">{permit.contractor_name}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-gray-500">Contact</label>
                  <p className="mt-1 text-gray-900">{permit.contractor_contact}</p>
                </div>
              </div>
            </div>
          </div>

          {/* Authorized Workers */}
          <div className="bg-white rounded-lg shadow p-6">
            <h2 className="text-xl font-semibold mb-4">Authorized Workers</h2>
            {authorizedWorkers.length > 0 ? (
              <div className="overflow-x-auto">
                <table className="min-w-full divide-y divide-gray-200">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">
                        Name
                      </th>
                      <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">
                        ID Number
                      </th>
                      <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">
                        Role
                      </th>
                    </tr>
                  </thead>
                  <tbody className="bg-white divide-y divide-gray-200">
                    {authorizedWorkers.map((worker: any, index: number) => (
                      <tr key={index}>
                        <td className="px-4 py-3 text-sm text-gray-900">{worker.name}</td>
                        <td className="px-4 py-3 text-sm text-gray-900">{worker.id_number}</td>
                        <td className="px-4 py-3 text-sm text-gray-900">{worker.role}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            ) : (
              <p className="text-gray-500">No workers authorized yet</p>
            )}
          </div>

          {/* Approval Form (if pending) */}
          {permit.status === 'pending' && (
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-xl font-semibold mb-4">Approve/Reject Permit</h2>
              <PermitApprovalForm permitId={permit.id} currentFee={permit.road_fee} />
            </div>
          )}

          {/* Actions (if approved or in progress) */}
          {['approved', 'in_progress'].includes(permit.status) && (
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-xl font-semibold mb-4">Actions</h2>
              <PermitActions permitId={permit.id} status={permit.status} />
            </div>
          )}
        </div>

        {/* Sidebar */}
        <div className="space-y-6">
          {/* Household Info */}
          <div className="bg-white rounded-lg shadow p-6">
            <h2 className="text-lg font-semibold mb-4">Household</h2>
            <div className="space-y-3">
              <div>
                <label className="text-sm font-medium text-gray-500">Name</label>
                <p className="mt-1 text-gray-900">{permit.household.household_name}</p>
              </div>
              <div>
                <label className="text-sm font-medium text-gray-500">Residence</label>
                <p className="mt-1 text-gray-900">
                  {permit.household.residence_unit?.property?.name || 'N/A'} -{' '}
                  {permit.household.residence_unit?.unit_number || 'N/A'}
                </p>
              </div>
            </div>
          </div>

          {/* Approval Info */}
          {permit.approved_at && (
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-lg font-semibold mb-4">Approval Info</h2>
              <div className="space-y-3">
                <div>
                  <label className="text-sm font-medium text-gray-500">Approved By</label>
                  <p className="mt-1 text-gray-900">
                    {permit.approved_by_user?.full_name || 'Admin'}
                  </p>
                </div>
                <div>
                  <label className="text-sm font-medium text-gray-500">Approved On</label>
                  <p className="mt-1 text-gray-900">
                    {new Date(permit.approved_at).toLocaleString()}
                  </p>
                </div>
              </div>
            </div>
          )}

          {/* Completion Info */}
          {permit.completed_at && (
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-lg font-semibold mb-4">Completion Info</h2>
              <div className="space-y-3">
                <div>
                  <label className="text-sm font-medium text-gray-500">Completed On</label>
                  <p className="mt-1 text-gray-900">
                    {new Date(permit.completed_at).toLocaleString()}
                  </p>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
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
      className={`inline-flex px-3 py-1 text-sm font-semibold rounded-full ${
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
      className={`inline-flex px-3 py-1 text-sm font-semibold rounded-full ${
        colors[status] || 'bg-gray-100 text-gray-800'
      }`}
    >
      {status}
    </span>
  )
}
