import { z } from 'zod'

export const createTenantSchema = z.object({
  name: z.string().min(3, 'Community name must be at least 3 characters').max(255),
  address: z.string().min(5, 'Address must be at least 5 characters'),
  city: z.string().min(2, 'City is required').optional(),
  state: z.string().min(2, 'State is required').optional(),
  country: z.string().default('Philippines'),
  postal_code: z.string().optional(),
  contact_name: z.string().min(2, 'Contact name is required').optional(),
  contact_email: z.string().email('Invalid email address').optional(),
  contact_phone: z.string().optional(),
  subscription_status: z
    .enum(['active', 'inactive', 'suspended', 'trial'])
    .default('active'),
  subscription_plan: z.string().optional(),
  max_users: z.number().int().positive().optional(),
  max_residences: z.number().int().positive().optional(),
})

export const updateTenantSchema = createTenantSchema.partial().extend({
  id: z.string().uuid(),
})

export type CreateTenantInput = z.infer<typeof createTenantSchema>
export type UpdateTenantInput = z.infer<typeof updateTenantSchema>
