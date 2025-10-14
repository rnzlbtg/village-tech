'use client'

import { useState, useEffect } from 'react'
import { createClient } from '@/lib/supabase/client'
import { createFeeStructure } from '@/lib/actions/fees'
import { toast } from 'sonner'
import Link from 'next/link'
import { ArrowLeft } from 'lucide-react'

type FeeStructure = {
  id: string
  fee_name: string
  fee_amount: number
  billing_frequency: string
  is_active: boolean
  created_at: string
}

export default function FeeStructurePage() {
  const [structures, setStructures] = useState<FeeStructure[]>([])
  const [loading, setLoading] = useState(true)
  const [formData, setFormData] = useState({
    fee_name: '',
    fee_amount: 0,
    billing_frequency: 'monthly',
    description: '',
  })
  const [submitting, setSubmitting] = useState(false)

  useEffect(() => {
    fetchFeeStructures()
  }, [])

  async function fetchFeeStructures() {
    const supabase = createClient()
    const { data, error } = await supabase
      .from('fee_structures')
      .select('*')
      .order('created_at', { ascending: false })

    if (error) {
      console.error('Error fetching fee structures:', error)
      toast.error('Failed to load fee structures')
    } else {
      setStructures(data || [])
    }
    setLoading(false)
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setSubmitting(true)

    try {
      const result = await createFeeStructure({
        fee_name: formData.fee_name,
        fee_amount: formData.fee_amount,
        billing_frequency: formData.billing_frequency as 'monthly' | 'quarterly' | 'annually',
        description: formData.description || undefined,
      })

      if (result.success) {
        toast.success('Fee structure created successfully')
        setFormData({
          fee_name: '',
          fee_amount: 0,
          billing_frequency: 'monthly',
          description: '',
        })
        fetchFeeStructures()
      } else {
        toast.error(result.error || 'Failed to create fee structure')
      }
    } catch (error) {
      toast.error('Failed to create fee structure')
    } finally {
      setSubmitting(false)
    }
  }

  async function toggleActive(id: string, currentStatus: boolean) {
    const supabase = createClient()
    const { error } = await supabase
      .from('fee_structures')
      .update({ is_active: !currentStatus })
      .eq('id', id)

    if (error) {
      toast.error('Failed to update fee structure')
    } else {
      toast.success(currentStatus ? 'Fee structure deactivated' : 'Fee structure activated')
      fetchFeeStructures()
    }
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center gap-4">
        <Link href="/fees" className="flex items-center text-gray-600 hover:text-gray-900">
          <ArrowLeft className="h-5 w-5" />
        </Link>
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Fee Structure Configuration</h1>
          <p className="text-gray-600 mt-1">Configure association fees and billing periods</p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Create Form */}
        <div className="lg:col-span-1">
          <div className="bg-white rounded-lg shadow">
            <div className="p-6 border-b">
              <h2 className="text-lg font-semibold text-gray-800">Create Fee Structure</h2>
            </div>
            <form onSubmit={handleSubmit} className="p-6 space-y-4">
              <div>
                <label htmlFor="fee_name" className="block text-sm font-medium text-gray-700 mb-2">
                  Fee Name <span className="text-red-500">*</span>
                </label>
                <input
                  type="text"
                  id="fee_name"
                  value={formData.fee_name}
                  onChange={(e) => setFormData({ ...formData, fee_name: e.target.value })}
                  className="block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-primary focus:border-primary"
                  placeholder="e.g., Monthly Association Fee"
                  required
                />
              </div>

              <div>
                <label htmlFor="fee_amount" className="block text-sm font-medium text-gray-700 mb-2">
                  Amount <span className="text-red-500">*</span>
                </label>
                <input
                  type="number"
                  id="fee_amount"
                  value={formData.fee_amount}
                  onChange={(e) => setFormData({ ...formData, fee_amount: parseFloat(e.target.value) })}
                  className="block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-primary focus:border-primary"
                  placeholder="0.00"
                  step="0.01"
                  min="0"
                  required
                />
              </div>

              <div>
                <label htmlFor="billing_frequency" className="block text-sm font-medium text-gray-700 mb-2">
                  Billing Frequency <span className="text-red-500">*</span>
                </label>
                <select
                  id="billing_frequency"
                  value={formData.billing_frequency}
                  onChange={(e) => setFormData({ ...formData, billing_frequency: e.target.value })}
                  className="block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-primary focus:border-primary"
                  required
                >
                  <option value="monthly">Monthly</option>
                  <option value="quarterly">Quarterly</option>
                  <option value="annually">Annually</option>
                </select>
              </div>

              <div>
                <label htmlFor="description" className="block text-sm font-medium text-gray-700 mb-2">
                  Description
                </label>
                <textarea
                  id="description"
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  className="block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-primary focus:border-primary"
                  rows={3}
                  placeholder="Optional description"
                />
              </div>

              <button
                type="submit"
                disabled={submitting}
                className="w-full bg-primary hover:bg-secondary text-white px-4 py-2 rounded-lg transition-colors disabled:opacity-50"
              >
                {submitting ? 'Creating...' : 'Create Fee Structure'}
              </button>
            </form>
          </div>
        </div>

        {/* Fee Structures List */}
        <div className="lg:col-span-2">
          <div className="bg-white rounded-lg shadow">
            <div className="p-6 border-b">
              <h2 className="text-lg font-semibold text-gray-800">Active Fee Structures</h2>
            </div>
            <div className="p-6">
              {loading ? (
                <p className="text-center py-8 text-gray-500">Loading...</p>
              ) : structures.length === 0 ? (
                <p className="text-center py-8 text-gray-500">No fee structures configured</p>
              ) : (
                <div className="space-y-4">
                  {structures.map((structure) => (
                    <div
                      key={structure.id}
                      className="flex items-center justify-between p-4 border rounded-lg hover:bg-gray-50"
                    >
                      <div className="flex-1">
                        <div className="flex items-center gap-3">
                          <h3 className="font-medium">{structure.fee_name}</h3>
                          <span
                            className={`text-xs px-2 py-0.5 rounded-full ${
                              structure.is_active
                                ? 'bg-green-100 text-green-800'
                                : 'bg-gray-100 text-gray-800'
                            }`}
                          >
                            {structure.is_active ? 'Active' : 'Inactive'}
                          </span>
                        </div>
                        <div className="mt-1 text-sm text-gray-600">
                          <span className="font-semibold">${structure.fee_amount.toFixed(2)}</span>
                          <span className="mx-2">•</span>
                          <span className="capitalize">{structure.billing_frequency}</span>
                        </div>
                      </div>
                      <button
                        onClick={() => toggleActive(structure.id, structure.is_active)}
                        className="px-3 py-1 text-sm border border-gray-300 rounded-md hover:bg-gray-100"
                      >
                        {structure.is_active ? 'Deactivate' : 'Activate'}
                      </button>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
