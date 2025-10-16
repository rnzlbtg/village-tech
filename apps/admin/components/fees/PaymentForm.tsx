'use client'

import { useState, useEffect } from 'react'
import { createClient } from '@/lib/supabase/client'
import { recordPayment } from '@/lib/actions/payments'
import { toast } from 'sonner'
import { useRouter } from 'next/navigation'

type Household = {
  id: string
  household_name: string
  residence_unit: {
    unit_number: string
    property: { name: string }
  } | null
}

type Invoice = {
  id: string
  invoice_number: string
  amount: number
  amount_paid: number
  invoice_status: string
  due_date: string
}

export default function PaymentRecordingForm({ households }: { households: Household[] }) {
  const router = useRouter()
  const [selectedHousehold, setSelectedHousehold] = useState('')
  const [invoices, setInvoices] = useState<Invoice[]>([])
  const [loadingInvoices, setLoadingInvoices] = useState(false)
  const [formData, setFormData] = useState({
    amount_paid: 0,
    payment_method: 'cash',
    payment_reference: '',
    notes: '',
  })
  const [submitting, setSubmitting] = useState(false)

  useEffect(() => {
    if (selectedHousehold) {
      fetchUnpaidInvoices(selectedHousehold)
    } else {
      setInvoices([])
    }
  }, [selectedHousehold])

  async function fetchUnpaidInvoices(householdId: string) {
    setLoadingInvoices(true)
    const supabase = createClient()

    const { data, error } = await supabase
      .from('invoices')
      .select('*')
      .eq('household_id', householdId)
      .in('invoice_status', ['unpaid', 'partial'])
      .order('due_date', { ascending: true })

    if (error) {
      console.error('Error fetching invoices:', error)
      toast.error('Failed to load invoices')
    } else {
      setInvoices(data || [])
    }
    setLoadingInvoices(false)
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()

    if (!selectedHousehold) {
      toast.error('Please select a household')
      return
    }

    if (formData.amount_paid <= 0) {
      toast.error('Please enter a valid payment amount')
      return
    }

    setSubmitting(true)

    try {
      const result = await recordPayment({
        household_id: selectedHousehold,
        amount_paid: formData.amount_paid,
        payment_method: formData.payment_method as 'cash' | 'check' | 'bank_transfer' | 'online',
        payment_reference: formData.payment_reference || undefined,
        notes: formData.notes || undefined,
      })

      if (result.success) {
        toast.success('Payment recorded successfully')
        // Reset form
        setFormData({
          amount_paid: 0,
          payment_method: 'cash',
          payment_reference: '',
          notes: '',
        })
        setSelectedHousehold('')
        router.refresh()
      } else {
        toast.error(result.error || 'Failed to record payment')
      }
    } catch (error) {
      toast.error('Failed to record payment')
    } finally {
      setSubmitting(false)
    }
  }

  const totalUnpaid = invoices.reduce((sum, inv) => sum + (inv.amount - inv.amount_paid), 0)

  return (
    <form onSubmit={handleSubmit} className="p-6 space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Household Selection */}
        <div className="md:col-span-2">
          <label htmlFor="household" className="block text-sm font-medium text-gray-700 mb-2">
            Select Household <span className="text-red-500">*</span>
          </label>
          <select
            id="household"
            value={selectedHousehold}
            onChange={(e) => setSelectedHousehold(e.target.value)}
            className="block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-primary focus:border-primary"
            required
          >
            <option value="">Select a household</option>
            {households.map((household) => (
              <option key={household.id} value={household.id}>
                {household.household_name}
                {household.residence_unit &&
                  ` - ${household.residence_unit.property.name} Unit ${household.residence_unit.unit_number}`}
              </option>
            ))}
          </select>
        </div>

        {/* Unpaid Invoices Summary */}
        {selectedHousehold && (
          <div className="md:col-span-2 bg-blue-50 border border-blue-200 rounded-lg p-4">
            <h3 className="font-semibold text-blue-900 mb-2">Outstanding Invoices</h3>
            {loadingInvoices ? (
              <p className="text-sm text-blue-700">Loading invoices...</p>
            ) : invoices.length === 0 ? (
              <p className="text-sm text-blue-700">No unpaid invoices found</p>
            ) : (
              <>
                <div className="space-y-2">
                  {invoices.map((invoice) => (
                    <div key={invoice.id} className="flex justify-between text-sm">
                      <span className="text-blue-700">
                        {invoice.invoice_number} - Due: {new Date(invoice.due_date).toLocaleDateString()}
                      </span>
                      <span className="font-semibold text-blue-900">
                        ${(invoice.amount - invoice.amount_paid).toFixed(2)}
                      </span>
                    </div>
                  ))}
                </div>
                <div className="mt-3 pt-3 border-t border-blue-300 flex justify-between">
                  <span className="font-semibold text-blue-900">Total Outstanding:</span>
                  <span className="font-bold text-blue-900">${totalUnpaid.toFixed(2)}</span>
                </div>
              </>
            )}
          </div>
        )}

        {/* Payment Amount */}
        <div>
          <label htmlFor="amount_paid" className="block text-sm font-medium text-gray-700 mb-2">
            Payment Amount <span className="text-red-500">*</span>
          </label>
          <input
            type="number"
            id="amount_paid"
            value={formData.amount_paid}
            onChange={(e) => setFormData({ ...formData, amount_paid: parseFloat(e.target.value) })}
            className="block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-primary focus:border-primary"
            placeholder="0.00"
            step="0.01"
            min="0"
            required
          />
          {totalUnpaid > 0 && formData.amount_paid > totalUnpaid && (
            <p className="mt-1 text-xs text-yellow-600">
              ⚠️ Payment exceeds outstanding balance (${totalUnpaid.toFixed(2)})
            </p>
          )}
        </div>

        {/* Payment Method */}
        <div>
          <label htmlFor="payment_method" className="block text-sm font-medium text-gray-700 mb-2">
            Payment Method <span className="text-red-500">*</span>
          </label>
          <select
            id="payment_method"
            value={formData.payment_method}
            onChange={(e) => setFormData({ ...formData, payment_method: e.target.value })}
            className="block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-primary focus:border-primary"
            required
          >
            <option value="cash">Cash</option>
            <option value="check">Check</option>
            <option value="bank_transfer">Bank Transfer</option>
            <option value="online">Online Payment</option>
          </select>
        </div>

        {/* Payment Reference */}
        <div>
          <label htmlFor="payment_reference" className="block text-sm font-medium text-gray-700 mb-2">
            Reference Number
          </label>
          <input
            type="text"
            id="payment_reference"
            value={formData.payment_reference}
            onChange={(e) => setFormData({ ...formData, payment_reference: e.target.value })}
            className="block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-primary focus:border-primary"
            placeholder="Check number, transaction ID, etc."
          />
        </div>

        {/* Notes */}
        <div className="md:col-span-2">
          <label htmlFor="notes" className="block text-sm font-medium text-gray-700 mb-2">
            Notes
          </label>
          <textarea
            id="notes"
            value={formData.notes}
            onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
            className="block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-primary focus:border-primary"
            rows={3}
            placeholder="Additional notes about this payment"
          />
        </div>
      </div>

      {/* Submit Buttons */}
      <div className="flex justify-end gap-3 pt-4 border-t">
        <Link
          href="/fees/invoices"
          className="px-4 py-2 border border-gray-300 rounded-md hover:bg-gray-50 transition-colors"
        >
          Cancel
        </Link>
        <button
          type="submit"
          disabled={submitting || !selectedHousehold || formData.amount_paid <= 0}
          className="bg-primary hover:bg-secondary text-white px-4 py-2 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {submitting ? 'Recording...' : 'Record Payment'}
        </button>
      </div>
    </form>
  )
}
