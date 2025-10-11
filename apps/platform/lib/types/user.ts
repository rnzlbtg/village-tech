export interface User {
  id: string
  email: string
  full_name: string
  phone?: string | null
  role: 'super_admin' | 'admin_head' | 'admin_officer' | 'resident' | 'sentinel'
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
