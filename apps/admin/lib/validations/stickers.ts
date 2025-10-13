import { z } from 'zod'

export const createStickerProgramSchema = z.object({
  program_name: z.string().min(3, 'Program name must be at least 3 characters'),
  program_year: z.number().int().min(2020).max(2100),
  stickers_per_household: z.number().int().min(1).max(10),
  start_date: z.string(),
  end_date: z.string().optional(),
})

export const approveStickerRequestSchema = z.object({
  sticker_code: z.string().min(3, 'Sticker code is required'),
  notes: z.string().optional(),
})

export const rejectStickerRequestSchema = z.object({
  rejection_reason: z.string().min(10, 'Rejection reason must be at least 10 characters'),
})

export const distributeStickerSchema = z.object({
  recipient_signature_url: z.string().url('Invalid signature URL'),
  notes: z.string().optional(),
})

export const createStickerRequestSchema = z.object({
  household_id: z.string().uuid(),
  program_id: z.string().uuid(),
  vehicle_plate_number: z.string().min(2, 'Vehicle plate number is required'),
  vehicle_make: z.string().optional(),
  vehicle_model: z.string().optional(),
  vehicle_color: z.string().optional(),
  vehicle_type: z.enum(['car', 'suv', 'truck', 'motorcycle', 'van']),
})

export type CreateStickerProgramInput = z.infer<typeof createStickerProgramSchema>
export type ApproveStickerRequestInput = z.infer<typeof approveStickerRequestSchema>
export type RejectStickerRequestInput = z.infer<typeof rejectStickerRequestSchema>
export type DistributeStickerInput = z.infer<typeof distributeStickerSchema>
export type CreateStickerRequestInput = z.infer<typeof createStickerRequestSchema>
