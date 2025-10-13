'use client'

import { useState } from 'react'
import { markPermitComplete } from '@/lib/actions/permits'
import { toast } from 'sonner'
import { useRouter } from 'next/navigation'

export function PermitActions({ permitId, status }: { permitId: string; status: string }) {
  const router = useRouter()
  const [loading, setLoading] = useState(false)

  const handleMarkComplete = async () => {
    const confirmed = window.confirm(
      'Mark this construction project as complete? Worker access will be revoked.'
    )

    if (!confirmed) return

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

  const handleMarkInProgress = async () => {
    // In a full implementation, this would call an updatePermitStatus action
    toast.info('This action would mark the permit as in progress')
  }

  return (
    <div className="space-y-4">
      {status === 'approved' && (
        <button
          onClick={handleMarkInProgress}
          disabled={loading}
          className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
        >
          Mark as In Progress
        </button>
      )}

      {['approved', 'in_progress'].includes(status) && (
        <button
          onClick={handleMarkComplete}
          disabled={loading}
          className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50"
        >
          {loading ? 'Processing...' : 'Mark as Complete'}
        </button>
      )}
    </div>
  )
}
