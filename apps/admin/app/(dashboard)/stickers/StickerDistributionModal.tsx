'use client'

import { useState, useRef, useEffect } from 'react'
import { distributeStickerPhysical } from '@/lib/actions/stickers'
import { toast } from 'sonner'
import SignatureCanvas from 'react-signature-canvas'

type StickerRequest = {
  id: string
  vehicle_plate_number: string
  vehicle_make: string | null
  vehicle_color: string | null
  owner_name: string
  household: {
    household_name: string
    residence_unit: {
      unit_number: string
      property: { name: string }
    } | null
  }
}

type Props = {
  request: StickerRequest
  onClose: () => void
}

export default function StickerDistributionModal({ request, onClose }: Props) {
  const [stickerCode, setStickerCode] = useState('')
  const [loading, setLoading] = useState(false)
  const sigPadRef = useRef<SignatureCanvas>(null)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    if (!stickerCode.trim()) {
      toast.error('Sticker code is required')
      return
    }

    if (sigPadRef.current?.isEmpty()) {
      toast.error('Signature is required')
      return
    }

    setLoading(true)

    try {
      // Get signature data URL
      const signatureData = sigPadRef.current?.toDataURL()

      const result = await distributeStickerPhysical({
        request_id: request.id,
        sticker_code: stickerCode.trim(),
        signature: signatureData || '',
        distributed_at: new Date().toISOString(),
      })

      if (result.success) {
        toast.success('Sticker distributed successfully')
        onClose()
        window.location.reload()
      } else {
        toast.error(result.error || 'Failed to distribute sticker')
      }
    } catch (error) {
      toast.error('Failed to distribute sticker')
    } finally {
      setLoading(false)
    }
  }

  const handleClearSignature = () => {
    sigPadRef.current?.clear()
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-lg max-w-2xl w-full max-h-screen overflow-y-auto">
        <div className="p-6 border-b">
          <h2 className="text-2xl font-bold">Distribute Vehicle Sticker</h2>
        </div>

        <form onSubmit={handleSubmit} className="p-6">
          {/* Request Details */}
          <div className="mb-6 p-4 bg-gray-50 rounded-lg">
            <h3 className="font-semibold mb-2">Request Details</h3>
            <div className="grid grid-cols-2 gap-4 text-sm">
              <div>
                <p className="text-gray-600">Household:</p>
                <p className="font-medium">{request.household.household_name}</p>
              </div>
              <div>
                <p className="text-gray-600">Residence:</p>
                <p className="font-medium">
                  {request.household.residence_unit?.property.name} -{' '}
                  {request.household.residence_unit?.unit_number}
                </p>
              </div>
              <div>
                <p className="text-gray-600">Vehicle Plate:</p>
                <p className="font-medium">{request.vehicle_plate_number}</p>
              </div>
              <div>
                <p className="text-gray-600">Vehicle:</p>
                <p className="font-medium">
                  {request.vehicle_make} {request.vehicle_color && `• ${request.vehicle_color}`}
                </p>
              </div>
              <div className="col-span-2">
                <p className="text-gray-600">Owner Name:</p>
                <p className="font-medium">{request.owner_name}</p>
              </div>
            </div>
          </div>

          {/* Sticker Code Input */}
          <div className="mb-6">
            <label htmlFor="sticker_code" className="block text-sm font-medium mb-2">
              Sticker Code / RFID Number *
            </label>
            <input
              type="text"
              id="sticker_code"
              value={stickerCode}
              onChange={(e) => setStickerCode(e.target.value)}
              placeholder="Enter sticker RFID code"
              className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              required
            />
            <p className="text-xs text-gray-600 mt-1">
              Enter the unique RFID code from the physical sticker
            </p>
          </div>

          {/* Signature Pad */}
          <div className="mb-6">
            <label className="block text-sm font-medium mb-2">
              Recipient Signature *
            </label>
            <div className="border-2 border-dashed border-gray-300 rounded-lg overflow-hidden bg-white">
              <SignatureCanvas
                ref={sigPadRef}
                canvasProps={{
                  className: 'w-full h-48',
                }}
              />
            </div>
            <button
              type="button"
              onClick={handleClearSignature}
              className="mt-2 text-sm text-blue-600 hover:text-blue-700"
            >
              Clear Signature
            </button>
            <p className="text-xs text-gray-600 mt-1">
              Signature from person collecting the sticker
            </p>
          </div>

          {/* Action Buttons */}
          <div className="flex gap-3">
            <button
              type="submit"
              disabled={loading}
              className="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
            >
              {loading ? 'Distributing...' : 'Mark as Distributed'}
            </button>
            <button
              type="button"
              onClick={onClose}
              disabled={loading}
              className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50"
            >
              Cancel
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}
