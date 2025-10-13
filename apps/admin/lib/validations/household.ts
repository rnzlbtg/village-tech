import { z } from 'zod'

export const createHouseholdSchema = z.object({
  residence_unit_id: z.string().uuid('Invalid residence unit ID'),
  household_name: z.string().min(2, 'Household name must be at least 2 characters'),
  move_in_date: z.string().optional(),
  notes: z.string().optional(),
})

export const updateHouseholdSchema = z.object({
  household_name: z.string().min(2, 'Household name must be at least 2 characters').optional(),
  move_in_date: z.string().optional(),
  move_out_date: z.string().optional(),
  status: z.enum(['active', 'inactive', 'moved_out']).optional(),
  notes: z.string().optional(),
})

export const createHouseholdHeadSchema = z.object({
  first_name: z.string().min(2, 'First name must be at least 2 characters'),
  last_name: z.string().min(2, 'Last name must be at least 2 characters'),
  email: z.string().email('Invalid email address'),
  phone_number: z.string().min(10, 'Phone number must be at least 10 digits'),
  date_of_birth: z.string().optional(),
  id_document_type: z.string().optional(),
  id_document_number: z.string().optional(),
  password: z
    .string()
    .min(8, 'Password must be at least 8 characters')
    .regex(/[A-Z]/, 'Password must contain at least one uppercase letter')
    .regex(/[a-z]/, 'Password must contain at least one lowercase letter')
    .regex(/[0-9]/, 'Password must contain at least one number'),
})

export const addHouseholdMemberSchema = z.object({
  first_name: z.string().min(2, 'First name must be at least 2 characters'),
  last_name: z.string().min(2, 'Last name must be at least 2 characters'),
  relationship: z.enum([
    'head',
    'spouse',
    'child',
    'parent',
    'sibling',
    'relative',
    'helper',
    'tenant',
  ]),
  date_of_birth: z.string().optional(),
  phone_number: z.string().optional(),
  email: z.string().email('Invalid email').optional().or(z.literal('')),
  is_primary_contact: z.boolean().default(false),
  id_document_type: z.string().optional(),
  id_document_number: z.string().optional(),
  emergency_contact_name: z.string().optional(),
  emergency_contact_phone: z.string().optional(),
})

export type CreateHouseholdInput = z.infer<typeof createHouseholdSchema>
export type UpdateHouseholdInput = z.infer<typeof updateHouseholdSchema>
export type CreateHouseholdHeadInput = z.infer<typeof createHouseholdHeadSchema>
export type AddHouseholdMemberInput = z.infer<typeof addHouseholdMemberSchema>
