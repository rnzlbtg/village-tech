'use client'

import { useState } from 'react'
import { approveConstructionPermit, rejectConstructionPermit } from '@/lib/actions/permits'
import { toast } from 'sonner'
import { useRouter } from 'next/navigation'

export function PermitApprovalForm({
  permitId,
  currentFee,
}: {
  permitId: string
  currentFee: number
}) {
  const router = useRouter()
  const [loading, setLoading] = useState(false)
  const [rejectionReason, setRejectionReason] = useState('')
  const [showRejectForm, setShowRejectForm] = useState(false)

  const handleApprove = async () => {
    if (currentFee > 0) {
      const confirmed = window.confirm(
        `This permit has a road fee of $${currentFee.toFixed(2)}. Has payment been received?`
      )
      if (!confirmed) {
        toast.error('Payment must be received before approval')
        return
      }
    }

    setLoading(true)
    try {
      const result = await approveConstructionPermit({ permit_id: permitId })

      if (result.success) {
        toast.success(result.message || 'Permit approved successfully')
        router.refresh()
      } else {
        toast.error(result.error || 'Failed to approve permit')
      }
    } catch (error) {
      toast.error('An error occurred')
    } finally {
      setLoading(false)
    }
  }

  const handleReject = async (e: React.FormEvent) => {
    e.preventDefault()

    if (rejectionReason.length < 10) {
      toast.error('Rejection reason must be at least 10 characters')
      return
    }

    setLoading(true)
    try {
      const result = await rejectConstructionPermit({
        permit_id: permitId,
        rejection_reason: rejectionReason,
      })

      if (result.success) {
        toast.success(result.message || 'Permit rejected')
        router.refresh()
      } else {
        toast.error(result.error || 'Failed to reject permit')
      }
    } catch (error) {
      toast.error('An error occurred')
    } finally {
      setLoading(false)
    }
  }

  if (showRejectForm) {
    return (
      <form onSubmit={handleReject} className="space-y-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Rejection Reason *
          </label>
          <textarea
            value={rejectionReason}
            onChange={e => setRejectionReason(e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            rows={4}
            placeholder="Explain why this permit is being rejected..."
            required
            minLength={10}
          />
          <p className="mt-1 text-xs text-gray-500">Minimum 10 characters</p>
        </div>

        <div className="flex gap-3">
          <button
            type="submit"
            disabled={loading || rejectionReason.length < 10}
            className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {loading ? 'Rejecting...' : 'Confirm Rejection'}
          </button>
          <button
            type="button"
            onClick={() => {
              setShowRejectForm(false)
              setRejectionReason('')
            }}
            className="px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200"
          >
            Cancel
          </button>
        </div>
      </form>
    )
  }

  return (
    <div className="space-y-4">
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <p className="text-sm text-blue-800">
          Review the permit details carefully before approving or rejecting. Approval will send
          notifications to the household and guard house.
        </p>
      </div>

      <div className="flex gap-3">
        <button
          onClick={handleApprove}
          disabled={loading}
          className="px-6 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {loading ? 'Processing...' : 'Approve Permit'}
        </button>
        <button
          onClick={() => setShowRejectForm(true)}
          disabled={loading}
          className="px-6 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Reject Permit
        </button>
      </div>
    </div>
  )
}
