import { z } from 'zod'

// Password validation rules
const passwordSchema = z
  .string()
  .min(8, 'Password must be at least 8 characters')
  .regex(/[a-z]/, 'Password must contain at least one lowercase letter')
  .regex(/[A-Z]/, 'Password must contain at least one uppercase letter')
  .regex(/[0-9]/, 'Password must contain at least one number')
  .regex(/[^a-zA-Z0-9]/, 'Password must contain at least one special character')

// Admin user roles
export const adminRoleSchema = z.enum(['admin_head', 'admin_officer'])

// Create admin user schema
export const createAdminUserSchema = z.object({
  tenant_id: z.string().uuid('Invalid tenant ID'),
  email: z.string().email('Invalid email address'),
  password: passwordSchema,
  first_name: z.string().min(2, 'First name must be at least 2 characters').max(100),
  last_name: z.string().min(2, 'Last name must be at least 2 characters').max(100),
  phone_number: z
    .string()
    .regex(/^\+?[1-9]\d{1,14}$/, 'Invalid phone number format')
    .optional()
    .or(z.literal('')),
  role: adminRoleSchema,
})

// Update admin user schema
export const updateAdminUserSchema = z.object({
  id: z.string().uuid('Invalid user ID'),
  tenant_id: z.string().uuid('Invalid tenant ID').optional(),
  email: z.string().email('Invalid email address').optional(),
  first_name: z.string().min(2, 'First name must be at least 2 characters').max(100).optional(),
  last_name: z.string().min(2, 'Last name must be at least 2 characters').max(100).optional(),
  phone_number: z
    .string()
    .regex(/^\+?[1-9]\d{1,14}$/, 'Invalid phone number format')
    .optional()
    .or(z.literal('')),
  role: adminRoleSchema.optional(),
  is_active: z.boolean().optional(),
})

export type CreateAdminUserInput = z.infer<typeof createAdminUserSchema>
export type UpdateAdminUserInput = z.infer<typeof updateAdminUserSchema>
