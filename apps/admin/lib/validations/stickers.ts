import { z } from 'zod'

export const setStickerProgramSchema = z.object({
  program_name: z.string().min(3, 'Program name must be at least 3 characters'),
  program_year: z.number().int().min(2020).max(2100),
  stickers_per_household: z.number().int().min(1).max(10),
  effective_date: z.string(),
  expiry_date: z.string().optional(),
})

export const approveStickerRequestSchema = z.object({
  request_id: z.string().uuid(),
})

export const rejectStickerRequestSchema = z.object({
  request_id: z.string().uuid(),
  rejection_reason: z.string().min(10, 'Rejection reason must be at least 10 characters'),
})

export const distributeStickerSchema = z.object({
  request_id: z.string().uuid(),
  sticker_code: z.string().min(3, 'Sticker code is required'),
  signature: z.string().optional(),
  distributed_at: z.string().optional(),
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

export type SetStickerProgramInput = z.infer<typeof setStickerProgramSchema>
export type ApproveStickerRequestInput = z.infer<typeof approveStickerRequestSchema>
export type RejectStickerRequestInput = z.infer<typeof rejectStickerRequestSchema>
export type DistributeStickerInput = z.infer<typeof distributeStickerSchema>
export type CreateStickerRequestInput = z.infer<typeof createStickerRequestSchema>
