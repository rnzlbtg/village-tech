import { z } from 'zod'

export const createUserSchema = z
  .object({
    email: z.string().email('Invalid email address'),
    full_name: z.string().min(2, 'Full name must be at least 2 characters'),
    phone: z.string().optional(),
    role: z.enum(['super_admin', 'admin_head', 'admin_officer', 'resident', 'sentinel'], {
      errorMap: () => ({ message: 'Please select a valid role' }),
    }),
    tenant_id: z.string().uuid().optional().nullable(),
    password: z
      .string()
      .min(8, 'Password must be at least 8 characters')
      .regex(/[A-Z]/, 'Password must contain at least one uppercase letter')
      .regex(/[a-z]/, 'Password must contain at least one lowercase letter')
      .regex(/[0-9]/, 'Password must contain at least one number'),
    confirm_password: z.string(),
  })
  .refine((data) => data.password === data.confirm_password, {
    message: "Passwords don't match",
    path: ['confirm_password'],
  })
  .refine(
    (data) => {
      // Super admins should not have a tenant_id
      if (data.role === 'super_admin') {
        return !data.tenant_id || data.tenant_id === ''
      }
      // All other roles require a tenant_id
      return !!data.tenant_id && data.tenant_id !== ''
    },
    {
      message: 'Super admins cannot be assigned to a tenant. Other roles must be assigned to a tenant.',
      path: ['tenant_id'],
    }
  )

export type CreateUserInput = z.infer<typeof createUserSchema>

export const updateUserSchema = z.object({
  id: z.string().uuid(),
  full_name: z.string().min(2, 'Full name must be at least 2 characters').optional(),
  phone: z.string().optional().nullable(),
  role: z
    .enum(['super_admin', 'admin_head', 'admin_officer', 'resident', 'sentinel'])
    .optional(),
  tenant_id: z.string().uuid().optional().nullable(),
  is_active: z.boolean().optional(),
})

export type UpdateUserInput = z.infer<typeof updateUserSchema>
