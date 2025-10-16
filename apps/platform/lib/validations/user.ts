import { z } from 'zod'

export const createUserSchema = z
  .object({
    email: z.string().email('Invalid email address'),
    first_name: z.string().min(2, 'First name must be at least 2 characters'),
    last_name: z.string().min(2, 'Last name must be at least 2 characters'),
    phone_number: z.string().optional(),
    role: z.enum(['super_admin', 'admin_head', 'admin_officer', 'household_head', 'guard'], {
      errorMap: () => ({ message: 'Please select a valid role' }),
    }),
    tenant_id: z.string().optional().nullable(),
    password: z.string().min(8, 'Password must be at least 8 characters'),
  })
  .refine(
    (data) => {
      // Super admins should not have a tenant_id
      if (data.role === 'super_admin') {
        return !data.tenant_id || data.tenant_id === ''
      }
      // All other roles require a tenant_id - must be valid UUID
      if (!data.tenant_id || data.tenant_id === '') {
        return false
      }
      // Validate UUID format (allow all valid UUIDs including test UUIDs like 11111111-1111-1111-1111-111111111111)
      const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i
      return uuidRegex.test(data.tenant_id)
    },
    {
      message: 'Super admins cannot be assigned to a tenant. Other roles must be assigned to a tenant.',
      path: ['tenant_id'],
    }
  )

export type CreateUserInput = z.infer<typeof createUserSchema>

export const updateUserSchema = z.object({
  id: z.string().uuid(),
  first_name: z.string().min(2, 'First name must be at least 2 characters').optional(),
  last_name: z.string().min(2, 'Last name must be at least 2 characters').optional(),
  phone_number: z.string().optional().nullable(),
  role: z
    .enum(['super_admin', 'admin_head', 'admin_officer', 'household_head', 'guard'])
    .optional(),
  tenant_id: z.string().uuid().optional().nullable(),
  is_active: z.boolean().optional(),
})

export type UpdateUserInput = z.infer<typeof updateUserSchema>
