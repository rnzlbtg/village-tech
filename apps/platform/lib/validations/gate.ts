import { z } from 'zod'

export const createGateSchema = z.object({
  tenant_id: z.string().uuid('Invalid tenant ID'),
  name: z.string().min(2, 'Gate name must be at least 2 characters').max(100),
  location: z
    .string()
    .min(3, 'Location must be at least 3 characters')
    .optional()
    .or(z.literal('')),
  gate_type: z.enum(['main', 'pedestrian', 'vehicle', 'service', 'emergency']).optional(),
  operational_status: z.enum(['active', 'maintenance', 'inactive']).default('active'),
  equipment_config: z.record(z.string(), z.any()).optional(),
  description: z.string().max(1000).optional(),
})

export const updateGateSchema = createGateSchema.extend({
  id: z.string().uuid('Invalid gate ID'),
}).partial().required({ id: true })

export type CreateGateInput = z.infer<typeof createGateSchema>
export type UpdateGateInput = z.infer<typeof updateGateSchema>
