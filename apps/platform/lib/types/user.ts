export interface User {
  id: string
  email: string
  first_name: string
  last_name: string
  phone_number?: string | null
  role: 'super_admin' | 'admin_head' | 'admin_officer' | 'household_head' | 'guard'
  tenant_id?: string | null
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface UserWithTenant extends User {
  tenant?: {
    id: string
    name: string
  } | null
}
