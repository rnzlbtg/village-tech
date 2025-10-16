'use client'

import { useState } from 'react'
import { markPermitComplete, holdPermit, unholdPermit } from '@/lib/actions/permits'
import { toast } from 'sonner'
import { useRouter } from 'next/navigation'
import { ConfirmModal } from '@/components/ui/ConfirmModal'

export function PermitActions({ permitId, status }: { permitId: string; status: string }) {
  const router = useRouter()
  const [loading, setLoading] = useState(false)
  const [showHoldForm, setShowHoldForm] = useState(false)
  const [holdReason, setHoldReason] = useState('')

  // Modal states
  const [showCompleteModal, setShowCompleteModal] = useState(false)
  const [showUnholdModal, setShowUnholdModal] = useState(false)

  const handleMarkComplete = async () => {
    setShowCompleteModal(true)
  }

  const confirmMarkComplete = async () => {
    setShowCompleteModal(false)
    setLoading(true)
    try {
      const result = await markPermitComplete({ permit_id: permitId })

      if (result.success) {
        toast.success(result.message || 'Permit marked as complete')
        router.refresh()
      } else {
        toast.error(result.error || 'Failed to mark permit as complete')
      }
    } catch (error) {
      toast.error('An error occurred')
    } finally {
      setLoading(false)
    }
  }

  const handleHold = async (e: React.FormEvent) => {
    e.preventDefault()

    if (holdReason.length < 10) {
      toast.error('Hold reason must be at least 10 characters')
      return
    }

    setLoading(true)
    try {
      const result = await holdPermit({
        permit_id: permitId,
        hold_reason: holdReason,
      })

      if (result.success) {
        toast.success(result.message || 'Permit placed on hold')
        setShowHoldForm(false)
        setHoldReason('')
        router.refresh()
      } else {
        toast.error(result.error || 'Failed to place permit on hold')
      }
    } catch (error) {
      toast.error('An error occurred')
    } finally {
      setLoading(false)
    }
  }

  const handleUnhold = async () => {
    setShowUnholdModal(true)
  }

  const confirmUnhold = async () => {
    setShowUnholdModal(false)
    setLoading(true)
    try {
      const result = await unholdPermit({ permit_id: permitId })

      if (result.success) {
        toast.success(result.message || 'Permit resumed')
        router.refresh()
      } else {
        toast.error(result.error || 'Failed to resume permit')
      }
    } catch (error) {
      toast.error('An error occurred')
    } finally {
      setLoading(false)
    }
  }

  // Hold form dialog
  if (showHoldForm) {
    return (
      <form onSubmit={handleHold} className="space-y-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Hold Reason *
          </label>
          <textarea
            value={holdReason}
            onChange={e => setHoldReason(e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500"
            rows={4}
            placeholder="Explain why this permit is being placed on hold..."
            required
            minLength={10}
          />
          <p className="mt-1 text-xs text-gray-500">Minimum 10 characters</p>
        </div>

        <div className="flex gap-3">
          <button
            type="submit"
            disabled={loading || holdReason.length < 10}
            className="px-4 py-2 bg-orange-600 text-white rounded-lg hover:bg-orange-700 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {loading ? 'Placing on Hold...' : 'Confirm Hold'}
          </button>
          <button
            type="button"
            onClick={() => {
              setShowHoldForm(false)
              setHoldReason('')
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
    <>
      <div className="space-y-4">
        {status === 'approved' && (
          <>
            <button
              onClick={() => setShowHoldForm(true)}
              disabled={loading}
              className="px-4 py-2 bg-orange-600 text-white rounded-lg hover:bg-orange-700 disabled:opacity-50"
            >
              Place on Hold
            </button>
            <button
              onClick={handleMarkComplete}
              disabled={loading}
              className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50"
            >
              {loading ? 'Processing...' : 'Mark as Complete'}
            </button>
          </>
        )}

        {status === 'on_hold' && (
          <button
            onClick={handleUnhold}
            disabled={loading}
            className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
          >
            {loading ? 'Processing...' : 'Resume Permit'}
          </button>
        )}
      </div>

      {/* Confirm Complete Modal */}
      <ConfirmModal
        isOpen={showCompleteModal}
        title="Mark Permit as Complete"
        message="Mark this construction project as complete? Worker access will be revoked."
        confirmText="Mark Complete"
        cancelText="Cancel"
        confirmButtonClass="bg-green-600 hover:bg-green-700"
        onConfirm={confirmMarkComplete}
        onCancel={() => setShowCompleteModal(false)}
      />

      {/* Confirm Unhold Modal */}
      <ConfirmModal
        isOpen={showUnholdModal}
        title="Resume Permit"
        message="Resume this construction permit? Worker access will be restored."
        confirmText="Resume"
        cancelText="Cancel"
        confirmButtonClass="bg-blue-600 hover:bg-blue-700"
        onConfirm={confirmUnhold}
        onCancel={() => setShowUnholdModal(false)}
      />
    </>
  )
}
