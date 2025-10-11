export type AdminRole = 'admin_head' | 'admin_officer'

export interface AdminUser {
  id: string
  tenant_id: string
  email: string
  first_name: string
  last_name: string
  phone_number?: string
  role: AdminRole
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface AdminUserWithTenant extends AdminUser {
  tenant: {
    id: string
    name: string
  }
}
