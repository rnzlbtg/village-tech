import { createClient } from '@/lib/supabase/server'
import { getTenantId } from '@/lib/auth/helpers'
import Link from 'next/link'
import { DollarSign, FileText, TrendingUp, AlertCircle } from 'lucide-react'

export const metadata = {
  title: 'Fees & Payments | Admin',
  description: 'Manage household fees and payment tracking',
}

export default async function FeesPage() {
  const supabase = await createClient()
  const tenantId = await getTenantId()

  // Fetch statistics
  const { data: invoices } = await supabase
    .from('fee_invoices')
    .select('id, status, amount')
    .eq('tenant_id', tenantId)

  const totalInvoices = invoices?.length || 0
  const paidInvoices = invoices?.filter((i) => i.status === 'paid').length || 0
  const pendingInvoices = invoices?.filter((i) => i.status === 'pending').length || 0
  const overdueInvoices = invoices?.filter((i) => i.status === 'overdue').length || 0
  const totalAmount = invoices?.reduce((sum, i) => sum + Number(i.amount), 0) || 0
  const paidAmount = invoices?.filter((i) => i.status === 'paid').reduce((sum, i) => sum + Number(i.amount), 0) || 0

  const stats = [
    {
      name: 'Total Invoices',
      value: totalInvoices,
      icon: FileText,
      color: 'text-blue-600',
      bgColor: 'bg-blue-100',
    },
    {
      name: 'Paid',
      value: paidInvoices,
      icon: DollarSign,
      color: 'text-green-600',
      bgColor: 'bg-green-100',
    },
    {
      name: 'Pending',
      value: pendingInvoices,
      icon: TrendingUp,
      color: 'text-yellow-600',
      bgColor: 'bg-yellow-100',
    },
    {
      name: 'Overdue',
      value: overdueInvoices,
      icon: AlertCircle,
      color: 'text-red-600',
      bgColor: 'bg-red-100',
    },
  ]

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Fees & Payments</h1>
          <p className="text-gray-600 mt-1">Manage household fees and track payments</p>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {stats.map((stat) => (
          <div
            key={stat.name}
            className="bg-white rounded-lg shadow p-6 card-hover"
          >
            <div className="flex items-center">
              <div className={`${stat.bgColor} p-3 rounded-lg`}>
                <stat.icon className={`h-6 w-6 ${stat.color}`} />
              </div>
              <div className="ml-4">
                <p className="text-gray-500 text-sm">{stat.name}</p>
                <p className="text-2xl font-semibold text-gray-800">{stat.value}</p>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Financial Summary */}
      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-lg font-semibold text-gray-800 mb-4">Financial Summary</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div>
            <p className="text-sm text-gray-600">Total Amount</p>
            <p className="text-2xl font-bold text-gray-800">
              ₱{totalAmount.toLocaleString('en-PH', { minimumFractionDigits: 2 })}
            </p>
          </div>
          <div>
            <p className="text-sm text-gray-600">Collected</p>
            <p className="text-2xl font-bold text-green-600">
              ₱{paidAmount.toLocaleString('en-PH', { minimumFractionDigits: 2 })}
            </p>
          </div>
          <div>
            <p className="text-sm text-gray-600">Outstanding</p>
            <p className="text-2xl font-bold text-red-600">
              ₱{(totalAmount - paidAmount).toLocaleString('en-PH', { minimumFractionDigits: 2 })}
            </p>
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <Link
          href="/fees/invoices"
          className="bg-white rounded-lg shadow p-6 hover:shadow-lg transition-shadow border-l-4 border-primary"
        >
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-lg font-semibold text-gray-800">View All Invoices</h3>
              <p className="text-gray-600 text-sm mt-1">
                Manage and track all fee invoices
              </p>
            </div>
            <FileText className="h-8 w-8 text-primary" />
          </div>
        </Link>

        <div className="bg-white rounded-lg shadow p-6 border-l-4 border-gray-300 opacity-60">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-lg font-semibold text-gray-800">Fee Configuration</h3>
              <p className="text-gray-600 text-sm mt-1">
                Set up fee types and schedules (Coming soon)
              </p>
            </div>
            <DollarSign className="h-8 w-8 text-gray-400" />
          </div>
        </div>
      </div>
    </div>
  )
}
