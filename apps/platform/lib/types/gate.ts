export interface Gate {
  id: string
  tenant_id: string
  name: string
  location: string
  gate_type?: 'main' | 'pedestrian' | 'vehicle' | 'service' | 'emergency'
  operational_status: 'active' | 'maintenance' | 'inactive'
  equipment_config?: Record<string, any>
  notes?: string
  created_at: string
  updated_at: string
}
