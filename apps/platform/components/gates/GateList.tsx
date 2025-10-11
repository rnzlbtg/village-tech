import { Gate } from '@/lib/types/gate'
import GateCard from './GateCard'
import { DoorOpen } from 'lucide-react'

interface GateListProps {
  gates: Gate[]
  tenantId: string
}

export default function GateList({ gates, tenantId }: GateListProps) {
  if (gates.length === 0) {
    return (
      <div className="bg-white rounded-lg border p-12 text-center">
        <DoorOpen className="h-12 w-12 text-gray-400 mx-auto mb-4" />
        <h3 className="text-lg font-semibold text-gray-800 mb-2">No gates yet</h3>
        <p className="text-gray-600">
          Add gates and entrance points to track access to this community.
        </p>
      </div>
    )
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {gates.map((gate) => (
        <GateCard key={gate.id} gate={gate} tenantId={tenantId} />
      ))}
    </div>
  )
}
