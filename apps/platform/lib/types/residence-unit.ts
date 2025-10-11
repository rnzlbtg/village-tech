export interface ResidenceUnit {
  id: string
  tenant_id: string
  property_id: string
  unit_number: string
  floor_number?: number
  unit_type?: 'apartment' | 'house' | 'townhouse' | 'condo' | 'studio' | 'other'
  bedrooms?: number
  bathrooms?: number
  square_meters?: number
  parking_slots?: number
  is_occupied: boolean
  notes?: string
  created_at: string
  updated_at: string
}
