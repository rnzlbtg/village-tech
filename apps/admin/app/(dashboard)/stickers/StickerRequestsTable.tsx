'use client'

import { useState } from 'react'
import { approveStickerRequest, rejectStickerRequest } from '@/lib/actions/stickers'
import { toast } from 'sonner'
import StickerDistributionModal from './StickerDistributionModal'

type StickerRequest = {
  id: string
  vehicle_plate_number: string
  vehicle_make: string | null
  vehicle_model: string | null
  vehicle_color: string | null
  vehicle_type: string | null
  request_status: string
  requested_at: string
  reviewed_at: string | null
  distributed_at: string | null
  rejection_reason: string | null
  sticker_code: string | null
  household: {
    id: string
    household_name: string
    residence_unit: {
      unit_number: string
      property: { name: string }
    } | null
  }
}

type Props = {
  requests: StickerRequest[]
  currentStatus: string
}

export default function StickerRequestsTable({ requests, currentStatus }: Props) {
  const [loading, setLoading] = useState<string | null>(null)
  const [distributionRequest, setDistributionRequest] = useState<StickerRequest | null>(null)

  const statusColors = {
    pending: 'bg-yellow-100 text-yellow-800',
    approved: 'bg-blue-100 text-blue-800',
    distributed: 'bg-green-100 text-green-800',
    rejected: 'bg-red-100 text-red-800',
  }

  const handleApprove = async (requestId: string) => {
    setLoading(requestId)
    try {
      const result = await approveStickerRequest({ request_id: requestId })
      if (result.success) {
        toast.success('Sticker request approved')
        window.location.reload()
      } else {
        toast.error(result.error || 'Failed to approve request')
      }
    } catch (error) {
      toast.error('Failed to approve request')
    } finally {
      setLoading(null)
    }
  }

  const handleReject = async (requestId: string) => {
    const reason = window.prompt('Enter rejection reason:')
    if (!reason) return

    setLoading(requestId)
    try {
      const result = await rejectStickerRequest({
        request_id: requestId,
        rejection_reason: reason,
      })
      if (result.success) {
        toast.success('Sticker request rejected')
        window.location.reload()
      } else {
        toast.error(result.error || 'Failed to reject request')
      }
    } catch (error) {
      toast.error('Failed to reject request')
    } finally {
      setLoading(null)
    }
  }

  const handleDistribute = (request: StickerRequest) => {
    setDistributionRequest(request)
  }

  return (
    <>
      <div className="mb-4 flex gap-2 border-b">
        <a
          href="/stickers"
          className={`px-4 py-2 ${currentStatus === 'all' ? 'border-b-2 border-blue-600 font-semibold' : 'text-gray-600'}`}
        >
          All ({requests.length})
        </a>
        <a
          href="/stickers?status=pending"
          className={`px-4 py-2 ${currentStatus === 'pending' ? 'border-b-2 border-blue-600 font-semibold' : 'text-gray-600'}`}
        >
          Pending
        </a>
        <a
          href="/stickers?status=approved"
          className={`px-4 py-2 ${currentStatus === 'approved' ? 'border-b-2 border-blue-600 font-semibold' : 'text-gray-600'}`}
        >
          Approved
        </a>
        <a
          href="/stickers?status=distributed"
          className={`px-4 py-2 ${currentStatus === 'distributed' ? 'border-b-2 border-blue-600 font-semibold' : 'text-gray-600'}`}
        >
          Distributed
        </a>
        <a
          href="/stickers?status=rejected"
          className={`px-4 py-2 ${currentStatus === 'rejected' ? 'border-b-2 border-blue-600 font-semibold' : 'text-gray-600'}`}
        >
          Rejected
        </a>
      </div>

      {requests.length === 0 ? (
        <div className="text-center py-12 bg-gray-50 rounded-lg">
          <p className="text-gray-500">No sticker requests found</p>
        </div>
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full border-collapse bg-white shadow rounded-lg">
            <thead>
              <tr className="bg-gray-50 border-b">
                <th className="text-left p-4 font-semibold">Household</th>
                <th className="text-left p-4 font-semibold">Vehicle</th>
                <th className="text-left p-4 font-semibold">Owner</th>
                <th className="text-left p-4 font-semibold">Status</th>
                <th className="text-left p-4 font-semibold">Requested</th>
                <th className="text-right p-4 font-semibold">Actions</th>
              </tr>
            </thead>
            <tbody>
              {requests.map((request) => (
                <tr key={request.id} className="border-b hover:bg-gray-50">
                  <td className="p-4">
                    <div>
                      <div className="font-medium">{request.household.household_name}</div>
                      <div className="text-sm text-gray-600">
                        {request.household.residence_unit?.property.name} -{' '}
                        {request.household.residence_unit?.unit_number}
                      </div>
                    </div>
                  </td>
                  <td className="p-4">
                    <div>
                      <div className="font-medium">{request.vehicle_plate_number}</div>
                      <div className="text-sm text-gray-600">
                        {request.vehicle_make} {request.vehicle_color && `• ${request.vehicle_color}`}
                      </div>
                    </div>
                  </td>
                  <td className="p-4">{request.household.household_name}</td>
                  <td className="p-4">
                    <span
                      className={`px-2 py-1 rounded text-xs font-medium ${
                        statusColors[request.request_status as keyof typeof statusColors] || 'bg-gray-100 text-gray-800'
                      }`}
                    >
                      {request.request_status.toUpperCase()}
                    </span>
                    {request.rejection_reason && (
                      <div className="text-xs text-red-600 mt-1">
                        Reason: {request.rejection_reason}
                      </div>
                    )}
                  </td>
                  <td className="p-4 text-sm text-gray-600">
                    {new Date(request.requested_at).toLocaleDateString()}
                  </td>
                  <td className="p-4 text-right">
                    {request.request_status === 'pending' && (
                      <div className="flex gap-2 justify-end">
                        <button
                          onClick={() => handleApprove(request.id)}
                          disabled={loading === request.id}
                          className="px-3 py-1 bg-green-600 text-white text-sm rounded hover:bg-green-700 disabled:opacity-50"
                        >
                          {loading === request.id ? 'Approving...' : 'Approve'}
                        </button>
                        <button
                          onClick={() => handleReject(request.id)}
                          disabled={loading === request.id}
                          className="px-3 py-1 bg-red-600 text-white text-sm rounded hover:bg-red-700 disabled:opacity-50"
                        >
                          Reject
                        </button>
                      </div>
                    )}
                    {request.request_status === 'approved' && (
                      <button
                        onClick={() => handleDistribute(request)}
                        className="px-3 py-1 bg-blue-600 text-white text-sm rounded hover:bg-blue-700"
                      >
                        Distribute
                      </button>
                    )}
                    {request.request_status === 'distributed' && (
                      <span className="text-sm text-green-600">
                        ✓ Distributed {new Date(request.distributed_at!).toLocaleDateString()}
                      </span>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {distributionRequest && (
        <StickerDistributionModal
          request={distributionRequest}
          onClose={() => setDistributionRequest(null)}
        />
      )}
    </>
  )
}
