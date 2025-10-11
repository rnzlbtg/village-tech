import { Database } from './database'

export type Tenant = Database['public']['Tables']['tenants']['Row']
export type InsertTenant = Database['public']['Tables']['tenants']['Insert']
export type UpdateTenant = Database['public']['Tables']['tenants']['Update']

export type TenantWithStats = Tenant & {
  property_count?: number
  residence_count?: number
  admin_count?: number
}
