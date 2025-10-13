import { createClient } from '@/lib/supabase/server'
import { getTenantId } from '@/lib/auth/helpers'
import { redirect } from 'next/navigation'

export const metadata = {
  title: 'Invoices | Admin',
  description: 'Manage association fee invoices',
}

type InvoiceStatus = 'unpaid' | 'partial' | 'paid' | 'overdue'

export default async function InvoicesPage({
  searchParams,
}: {
  searchParams: { status?: InvoiceStatus }
}) {
  const supabase = await createClient()
  const tenantId = await getTenantId()

  if (!tenantId) {
    redirect('/login')
  }

  // Build query with optional status filter
  let query = supabase
    .from('invoices')
    .select(`
      id,
      invoice_number,
      invoice_type,
      description,
      total_amount,
      amount_paid,
      amount_due,
      status,
      due_date,
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

  const { data: invoices, error } = await query

  if (error) {
    console.error('Error fetching invoices:', error)
  }

  // Calculate status counts and totals
  const statusCounts = {
    all: invoices?.length || 0,
    unpaid: invoices?.filter(i => i.status === 'unpaid').length || 0,
    partial: invoices?.filter(i => i.status === 'partial').length || 0,
    paid: invoices?.filter(i => i.status === 'paid').length || 0,
    overdue: invoices?.filter(i => i.status === 'overdue').length || 0,
  }

  const totals = {
    total_billed: invoices?.reduce((sum, i) => sum + Number(i.total_amount), 0) || 0,
    total_paid: invoices?.reduce((sum, i) => sum + Number(i.amount_paid), 0) || 0,
    total_due: invoices?.reduce((sum, i) => sum + Number(i.amount_due), 0) || 0,
  }

  return (
    <div className="container mx-auto py-6">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-3xl font-bold">Association Fee Invoices</h1>
          <p className="text-gray-600 mt-1">View and manage household invoices</p>
        </div>
        <a
          href="/fees/structure"
          className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
        >
          Fee Structure
        </a>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        <div className="bg-white rounded-lg shadow p-4">
          <div className="text-sm text-gray-600">Total Billed</div>
          <div className="text-2xl font-bold text-gray-900">
            ${totals.total_billed.toFixed(2)}
          </div>
        </div>
        <div className="bg-white rounded-lg shadow p-4">
          <div className="text-sm text-gray-600">Total Collected</div>
          <div className="text-2xl font-bold text-green-600">
            ${totals.total_paid.toFixed(2)}
          </div>
        </div>
        <div className="bg-white rounded-lg shadow p-4">
          <div className="text-sm text-gray-600">Outstanding Balance</div>
          <div className="text-2xl font-bold text-red-600">${totals.total_due.toFixed(2)}</div>
        </div>
      </div>

      {/* Status Filters */}
      <div className="mb-6 flex gap-2 flex-wrap">
        <StatusFilterButton status={null} label="All" count={statusCounts.all} current={searchParams.status} />
        <StatusFilterButton status="unpaid" label="Unpaid" count={statusCounts.unpaid} current={searchParams.status} />
        <StatusFilterButton status="partial" label="Partial" count={statusCounts.partial} current={searchParams.status} />
        <StatusFilterButton status="paid" label="Paid" count={statusCounts.paid} current={searchParams.status} />
        <StatusFilterButton status="overdue" label="Overdue" count={statusCounts.overdue} current={searchParams.status} />
      </div>

      {/* Invoices Table */}
      <div className="bg-white rounded-lg shadow">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Invoice #
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Household
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Description
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Total
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Paid
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Balance
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Due Date
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {invoices && invoices.length > 0 ? (
                invoices.map((invoice: any) => (
                  <tr key={invoice.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm font-medium text-gray-900">{invoice.invoice_number}</div>
                      <div className="text-xs text-gray-500">
                        {new Date(invoice.created_at).toLocaleDateString()}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-gray-900">{invoice.household?.household_name}</div>
                      <div className="text-xs text-gray-500">
                        Unit: {invoice.household?.residence_unit?.unit_number || 'N/A'}
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="text-sm text-gray-900">{invoice.description}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      ${Number(invoice.total_amount).toFixed(2)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-green-600">
                      ${Number(invoice.amount_paid).toFixed(2)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-red-600">
                      ${Number(invoice.amount_due).toFixed(2)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {new Date(invoice.due_date).toLocaleDateString()}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <StatusBadge status={invoice.status} />
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      {invoice.status !== 'paid' && (
                        <a
                          href={`/fees/payments/new?invoice_id=${invoice.id}`}
                          className="text-blue-600 hover:text-blue-900 mr-3"
                        >
                          Record Payment
                        </a>
                      )}
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={9} className="px-6 py-12 text-center text-gray-500">
                    {searchParams.status ? `No ${searchParams.status} invoices found` : 'No invoices yet. Generate invoices from Fee Structure page.'}
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
  status: InvoiceStatus | null
  label: string
  count: number
  current?: InvoiceStatus
}) {
  const isActive = (status === null && !current) || status === current
  const href = status ? `/fees/invoices?status=${status}` : '/fees/invoices'

  return (
    <a
      href={href}
      className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
        isActive ? 'bg-blue-600 text-white' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
      }`}
    >
      {label} <span className="ml-1">({count})</span>
    </a>
  )
}

function StatusBadge({ status }: { status: string }) {
  const colors: Record<string, string> = {
    unpaid: 'bg-red-100 text-red-800',
    partial: 'bg-yellow-100 text-yellow-800',
    paid: 'bg-green-100 text-green-800',
    overdue: 'bg-red-100 text-red-800',
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
