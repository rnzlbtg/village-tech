import { z } from 'zod'

export const createPropertySchema = z.object({
  tenant_id: z.string().uuid('Invalid tenant ID'),
  name: z.string().min(3, 'Property name must be at least 3 characters').max(255),
  address: z.string().optional(),
  description: z.string().optional(),
  property_type: z.enum(['building', 'lot', 'section', 'phase']).optional(),
  total_units: z.number().int().min(0).optional(),
})

export const updatePropertySchema = createPropertySchema.extend({
  id: z.string().uuid('Invalid property ID'),
}).partial().required({ id: true })

export type CreatePropertyInput = z.infer<typeof createPropertySchema>
export type UpdatePropertyInput = z.infer<typeof updatePropertySchema>
