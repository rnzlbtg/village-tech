import { z } from 'zod'

const adminRoles = ['admin_head', 'admin_officer', 'security_head', 'security_officer'] as const
const securityRoles = ['security_head', 'security_officer'] as const

export const createUserSchema = z.object({
  email: z.string().email('Invalid email address'),
  first_name: z.string().min(2, 'First name must be at least 2 characters'),
  last_name: z.string().min(2, 'Last name must be at least 2 characters'),
  role: z.enum(adminRoles, {
    errorMap: () => ({ message: 'Please select a valid role' })
  }),
  phone_number: z.string().min(10, 'Phone number must be at least 10 digits').optional().or(z.literal('')),
  password: z
    .string()
    .min(6, 'Password must be at least 6 characters'),
  is_active: z.boolean().default(true),
})

export const updateUserSchema = z.object({
  first_name: z.string().min(2, 'First name must be at least 2 characters').optional(),
  last_name: z.string().min(2, 'Last name must be at least 2 characters').optional(),
  role: z.enum(adminRoles).optional(),
  phone_number: z.string().min(10, 'Phone number must be at least 10 digits').optional().or(z.literal('')),
  is_active: z.boolean().optional(),
})

export const resetPasswordSchema = z.object({
  new_password: z
    .string()
    .min(6, 'Password must be at least 6 characters'),
  confirm_password: z.string(),
}).refine((data) => data.new_password === data.confirm_password, {
  message: "Passwords don't match",
  path: ["confirm_password"],
})

export type CreateUserInput = z.infer<typeof createUserSchema>
export type UpdateUserInput = z.infer<typeof updateUserSchema>
export type ResetPasswordInput = z.infer<typeof resetPasswordSchema>
export type AdminRole = typeof adminRoles[number]
export type SecurityRole = typeof securityRoles[number]