import { z } from 'zod'

export const createPropertySchema = z.object({
  tenant_id: z.string().uuid('Invalid tenant ID'),
  name: z.string().min(3, 'Property name must be at least 3 characters').max(255),
  address: z.string().min(5, 'Address must be at least 5 characters'),
  property_type: z.enum(['residential', 'commercial', 'mixed']).optional(),
  total_units: z.number().int().min(1, 'Must have at least 1 unit').optional(),
  total_floors: z.number().int().min(1).optional(),
  year_built: z.number().int().min(1800).max(new Date().getFullYear()).optional(),
  lot_size: z.number().positive().optional(),
})

export const updatePropertySchema = createPropertySchema.extend({
  id: z.string().uuid('Invalid property ID'),
}).partial().required({ id: true })

export type CreatePropertyInput = z.infer<typeof createPropertySchema>
export type UpdatePropertyInput = z.infer<typeof updatePropertySchema>
