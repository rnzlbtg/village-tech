import { Gate } from '@/lib/types/gate'
import { DoorOpen, MapPin, Settings } from 'lucide-react'

interface GateCardProps {
  gate: Gate
  tenantId: string
  onEditClick?: (gate: Gate) => void
}

export default function GateCard({ gate, tenantId, onEditClick }: GateCardProps) {
  const statusColors = {
    active: 'bg-green-100 text-green-800',
    maintenance: 'bg-yellow-100 text-yellow-800',
    inactive: 'bg-gray-100 text-gray-800',
  }

  const typeLabels = {
    main: 'Main Entrance',
    pedestrian: 'Pedestrian',
    vehicle: 'Vehicle Only',
    service: 'Service',
    emergency: 'Emergency',
  }

  const handleClick = () => {
    if (onEditClick) {
      onEditClick(gate)
    }
  }

  return (
    <div
      onClick={handleClick}
      className="block bg-white border rounded-lg p-6 hover:shadow-lg transition-shadow duration-200 cursor-pointer"
    >
      <div className="flex items-start justify-between mb-4">
        <div className="flex items-center space-x-3">
          <div className="bg-primary-light p-3 rounded-lg">
            <DoorOpen className="h-6 w-6 text-primary" />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-gray-800">{gate.name}</h3>
            <span className="inline-block px-2 py-1 text-xs rounded-full bg-gray-100 text-gray-700 mt-1">
              {typeLabels[gate.gate_type || 'main']}
            </span>
          </div>
        </div>
      </div>

      <div className="space-y-2 text-sm text-gray-600">
        <div className="flex items-center space-x-2">
          <MapPin className="h-4 w-4" />
          <span>{gate.location}</span>
        </div>

        {gate.equipment_config && Object.keys(gate.equipment_config).length > 0 && (
          <div className="flex items-center space-x-2">
            <Settings className="h-4 w-4" />
            <span>{Object.keys(gate.equipment_config).length} equipment(s) configured</span>
          </div>
        )}

        <div className="mt-4 pt-4 border-t">
          <span
            className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
              statusColors[gate.operational_status]
            }`}
          >
            {gate.operational_status.charAt(0).toUpperCase() + gate.operational_status.slice(1)}
          </span>
        </div>
      </div>
    </div>
  )
}
