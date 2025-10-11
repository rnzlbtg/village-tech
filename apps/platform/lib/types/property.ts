export interface Property {
  id: string
  tenant_id: string
  name: string
  address: string
  property_type?: 'residential' | 'commercial' | 'mixed'
  total_units?: number
  total_floors?: number
  year_built?: number
  lot_size?: number
  created_at: string
  updated_at: string
}

export interface PropertyWithCounts extends Property {
  residence_count: number
  occupied_count: number
}
