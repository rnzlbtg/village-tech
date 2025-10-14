'use client'

import { useState } from 'react'
import { Plus, X } from 'lucide-react'
import { Gate } from '@/lib/types/gate'
import GateList from './GateList'
import GateForm from './GateForm'

interface GatesPageClientProps {
  gates: Gate[]
  tenantId: string
}

export default function GatesPageClient({ gates, tenantId }: GatesPageClientProps) {
  const [isModalOpen, setIsModalOpen] = useState(false)
  const [editingGate, setEditingGate] = useState<Gate | null>(null)

  const openModal = (gate?: Gate) => {
    setEditingGate(gate || null)
    setIsModalOpen(true)
  }

  const closeModal = () => {
    setIsModalOpen(false)
    setEditingGate(null)
  }

  return (
    <>
      <div className="space-y-6">
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-2xl font-bold text-gray-800">Gates & Entrances</h1>
            <p className="text-gray-600 mt-1">Manage entry points and gate equipment</p>
          </div>
          <button
            onClick={() => openModal()}
            className="bg-primary hover:bg-secondary text-white px-4 py-2 rounded-lg flex items-center transition-colors duration-200"
          >
            <Plus className="h-5 w-5 mr-2" />
            Add Gate
          </button>
        </div>

        <div className="bg-white rounded-lg shadow p-4">
          <div className="flex items-center justify-between mb-4">
            <p className="text-sm text-gray-600">
              <span className="font-semibold text-gray-800">{gates.length}</span>{' '}
              {gates.length === 1 ? 'gate' : 'gates'} total
            </p>
          </div>
        </div>

        <GateList gates={gates} tenantId={tenantId} onEditGate={openModal} />
      </div>

      {/* Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-xl max-w-4xl w-full max-h-[90vh] overflow-y-auto">
            {/* Modal Header */}
            <div className="sticky top-0 bg-white border-b px-6 py-4 flex justify-between items-center">
              <h2 className="text-xl font-bold text-gray-800">
                {editingGate ? 'Edit Gate' : 'Add New Gate'}
              </h2>
              <button
                onClick={closeModal}
                className="text-gray-500 hover:text-gray-700 transition-colors"
              >
                <X className="h-6 w-6" />
              </button>
            </div>

            {/* Modal Content */}
            <div className="p-6">
              <GateForm
                tenantId={tenantId}
                initialData={editingGate || undefined}
                mode={editingGate ? 'edit' : 'create'}
                onSuccess={closeModal}
              />
            </div>
          </div>
        </div>
      )}
    </>
  )
}
