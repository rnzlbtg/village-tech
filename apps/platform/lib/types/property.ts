export interface Property {
  id: string
  tenant_id: string
  name: string
  address?: string
  description?: string
  property_type?: 'building' | 'lot' | 'section' | 'phase'
  total_units?: number
  created_at: string
  updated_at: string
}

export interface PropertyWithCounts extends Property {
  residence_count: number
  occupied_count: number
}
