import { z } from 'zod'

export const createResidenceUnitSchema = z.object({
  tenant_id: z.string().uuid('Invalid tenant ID'),
  property_id: z.string().uuid('Invalid property ID'),
  unit_number: z.string().min(1, 'Unit number is required').max(50),
  floor_number: z.number().int().min(0).optional(),
  unit_type: z.enum(['apartment', 'house', 'townhouse', 'condo', 'studio', 'other']).optional(),
  bedrooms: z.number().int().min(0).optional(),
  bathrooms: z.number().min(0).optional(),
  square_meters: z.number().positive().optional(),
  parking_slots: z.number().int().min(0).optional(),
  is_occupied: z.boolean().optional().default(false),
  notes: z.string().max(1000).optional(),
})

export const updateResidenceUnitSchema = createResidenceUnitSchema.extend({
  id: z.string().uuid('Invalid residence unit ID'),
}).partial().required({ id: true })

export type CreateResidenceUnitInput = z.infer<typeof createResidenceUnitSchema>
export type UpdateResidenceUnitInput = z.infer<typeof updateResidenceUnitSchema>
