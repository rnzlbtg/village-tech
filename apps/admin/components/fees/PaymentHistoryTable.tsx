'use client'

import { useState, useEffect } from 'react'
import { createClient } from '@/lib/supabase/client'
import { useRouter, useSearchParams } from 'next/navigation'
import { Download, FileText, Search } from 'lucide-react'

interface PaymentLog {
  id: string
  receipt_number: string
  payment_amount: number
  payment_method: string
  payment_reference: string | null
  payment_date: string
  receipt_url: string | null
  notes: string | null
  voided_at: string | null
  household: {
    household_name: string
    residence_unit: {
      unit_number: string
    }
  }
  invoice: {
    invoice_number: string
    invoice_type: string
  } | null
  received_by_profile: {
    full_name: string
  } | null
}

interface Household {
  id: string
  household_name: string
  residence_unit: {
    unit_number: string
  }
}

interface PaymentHistoryTableProps {
  households: Household[]
  initialFilters: {
    household_id?: string
    start_date?: string
    end_date?: string
  }
}

export default function PaymentHistoryTable({
  households,
  initialFilters,
}: PaymentHistoryTableProps) {
  const router = useRouter()
  const searchParams = useSearchParams()
  const supabase = createClient()

  const [payments, setPayments] = useState<PaymentLog[]>([])
  const [loading, setLoading] = useState(true)
  const [filters, setFilters] = useState({
    household_id: initialFilters.household_id || '',
    start_date: initialFilters.start_date || '',
    end_date: initialFilters.end_date || '',
  })

  useEffect(() => {
    fetchPayments()
  }, [searchParams])

  async function fetchPayments() {
    setLoading(true)
    try {
      let query = supabase
        .from('payment_logs')
        .select(
          `
          id,
          receipt_number,
          payment_amount,
          payment_method,
          payment_reference,
          payment_date,
          receipt_url,
          notes,
          voided_at,
          household:households!inner(
            household_name,
            residence_unit:residence_units(unit_number)
          ),
          invoice:invoices(
            invoice_number,
            invoice_type
          ),
          received_by_profile:user_profiles!payment_logs_received_by_fkey(
            full_name
          )
        `
        )
        .order('payment_date', { ascending: false })
        .order('created_at', { ascending: false })

      // Apply filters
      if (filters.household_id) {
        query = query.eq('household_id', filters.household_id)
      }
      if (filters.start_date) {
        query = query.gte('payment_date', filters.start_date)
      }
      if (filters.end_date) {
        query = query.lte('payment_date', filters.end_date)
      }

      const { data, error } = await query

      if (error) throw error
      setPayments(data || [])
    } catch (error) {
      console.error('Error fetching payments:', error)
    } finally {
      setLoading(false)
    }
  }

  function handleFilterChange(field: string, value: string) {
    const newFilters = { ...filters, [field]: value }
    setFilters(newFilters)

    // Update URL params
    const params = new URLSearchParams()
    if (newFilters.household_id) params.set('household', newFilters.household_id)
    if (newFilters.start_date) params.set('start_date', newFilters.start_date)
    if (newFilters.end_date) params.set('end_date', newFilters.end_date)

    router.push(`/fees/history?${params.toString()}`)
  }

  function formatAmount(amount: number) {
    return new Intl.NumberFormat('en-PH', {
      style: 'currency',
      currency: 'PHP',
    }).format(amount)
  }

  function formatDate(dateString: string) {
    return new Date(dateString).toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
      year: 'numeric',
    })
  }

  const totalAmount = payments
    .filter((p) => !p.voided_at)
    .reduce((sum, p) => sum + Number(p.payment_amount), 0)

  return (
    <div className="bg-white rounded-lg border border-gray-200">
      {/* Filters */}
      <div className="p-4 border-b border-gray-200">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Household</label>
            <select
              value={filters.household_id}
              onChange={(e) => handleFilterChange('household_id', e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-primary focus:border-primary"
            >
              <option value="">All Households</option>
              {households.map((h) => (
                <option key={h.id} value={h.id}>
                  {h.household_name} - Unit {h.residence_unit.unit_number}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Start Date</label>
            <input
              type="date"
              value={filters.start_date}
              onChange={(e) => handleFilterChange('start_date', e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-primary focus:border-primary"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">End Date</label>
            <input
              type="date"
              value={filters.end_date}
              onChange={(e) => handleFilterChange('end_date', e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-primary focus:border-primary"
            />
          </div>
        </div>

        {/* Summary Stats */}
        <div className="mt-4 flex items-center justify-between">
          <div className="text-sm text-gray-600">
            {payments.length} payment{payments.length !== 1 ? 's' : ''} found
          </div>
          <div className="text-lg font-semibold text-gray-900">
            Total: {formatAmount(totalAmount)}
          </div>
        </div>
      </div>

      {/* Table */}
      <div className="overflow-x-auto">
        {loading ? (
          <div className="p-8 text-center text-gray-500">Loading payments...</div>
        ) : payments.length === 0 ? (
          <div className="p-8 text-center text-gray-500">
            <FileText className="mx-auto h-12 w-12 text-gray-400 mb-2" />
            <p>No payments found</p>
          </div>
        ) : (
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                  Receipt
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                  Date
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                  Household
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                  Invoice
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                  Method
                </th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">
                  Amount
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                  Received By
                </th>
                <th className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {payments.map((payment) => (
                <tr key={payment.id} className={payment.voided_at ? 'bg-red-50' : ''}>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">
                      {payment.receipt_number}
                    </div>
                    {payment.payment_reference && (
                      <div className="text-xs text-gray-500">Ref: {payment.payment_reference}</div>
                    )}
                    {payment.voided_at && (
                      <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-red-100 text-red-800">
                        VOIDED
                      </span>
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {formatDate(payment.payment_date)}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">
                      {payment.household.household_name}
                    </div>
                    <div className="text-xs text-gray-500">
                      Unit {payment.household.residence_unit.unit_number}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {payment.invoice ? (
                      <>
                        <div>{payment.invoice.invoice_number}</div>
                        <div className="text-xs text-gray-500 capitalize">
                          {payment.invoice.invoice_type.replace('_', ' ')}
                        </div>
                      </>
                    ) : (
                      <span className="text-gray-400">N/A</span>
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-gray-100 text-gray-800 capitalize">
                      {payment.payment_method.replace('_', ' ')}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900 text-right font-semibold">
                    {formatAmount(Number(payment.payment_amount))}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {payment.received_by_profile?.full_name || 'N/A'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-center">
                    {payment.receipt_url && !payment.voided_at ? (
                      <a
                        href={payment.receipt_url}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="inline-flex items-center gap-1 text-blue-600 hover:text-blue-800"
                      >
                        <Download className="h-4 w-4" />
                        <span className="text-sm">Receipt</span>
                      </a>
                    ) : (
                      <span className="text-gray-400 text-sm">N/A</span>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  )
}
