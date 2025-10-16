import { z } from 'zod'

export const computeRoadFeeSchema = z.object({
  project_type: z.enum(['renovation', 'new_construction', 'addition/extension', 'landscaping', 'repair']),
  start_date: z.string(),
  end_date: z.string(),
})

export const approveConstructionPermitSchema = z.object({
  permit_id: z.string().uuid(),
  road_fee_amount: z.number().min(0, 'Road fee must be a positive number').optional(),
  payment_deadline: z.string().optional(),
  authorized_workers: z
    .array(
      z.object({
        name: z.string().min(2),
        id_number: z.string().min(5),
        role: z.string(),
      })
    )
    .optional(),
  notes: z.string().optional(),
})

export const rejectConstructionPermitSchema = z.object({
  permit_id: z.string().uuid(),
  rejection_reason: z.string().min(10, 'Rejection reason must be at least 10 characters'),
})

export const recordPermitPaymentSchema = z.object({
  permit_id: z.string().uuid(),
  payment_amount: z.number().min(0, 'Payment amount must be positive'),
  payment_method: z.enum(['cash', 'check', 'bank_transfer', 'online']),
  payment_reference: z.string().optional(),
  notes: z.string().optional(),
})

export const markPermitCompleteSchema = z.object({
  permit_id: z.string().uuid(),
  actual_end_date: z.string().optional(),
  completion_notes: z.string().optional(),
})

export const holdPermitSchema = z.object({
  permit_id: z.string().uuid(),
  hold_reason: z.string().min(10, 'Reason must be at least 10 characters'),
})

export type ComputeRoadFeeInput = z.infer<typeof computeRoadFeeSchema>
export type ApproveConstructionPermitInput = z.infer<typeof approveConstructionPermitSchema>
export type RejectConstructionPermitInput = z.infer<typeof rejectConstructionPermitSchema>
export type RecordPermitPaymentInput = z.infer<typeof recordPermitPaymentSchema>
export type MarkPermitCompleteInput = z.infer<typeof markPermitCompleteSchema>
export type HoldPermitInput = z.infer<typeof holdPermitSchema>
