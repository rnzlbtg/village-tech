import { z } from 'zod'

export const createFeeStructureSchema = z.object({
  fee_amount: z.number().min(0, 'Amount must be positive'),
  billing_period: z.enum(['monthly', 'quarterly', 'annually']),
  due_day_of_month: z.number().min(1).max(31).optional(),
  late_fee_amount: z.number().min(0).optional(),
  late_fee_grace_days: z.number().min(0).optional(),
  description: z.string().optional(),
})

export const recordPaymentSchema = z.object({
  invoice_id: z.string().uuid(),
  amount: z.number().min(0, 'Payment amount must be positive'),
  payment_method: z.enum(['cash', 'check', 'bank_transfer', 'online']),
  payment_date: z.string(),
  check_number: z.string().optional(),
  check_bank: z.string().optional(),
  check_date: z.string().optional(),
  notes: z.string().optional(),
})

export const recordPartialPaymentSchema = z.object({
  household_id: z.string().uuid(),
  total_amount: z.number().min(0, 'Payment amount must be positive'),
  payment_method: z.enum(['cash', 'check', 'bank_transfer', 'online']),
  allocations: z
    .array(
      z.object({
        invoice_id: z.string().uuid(),
        amount: z.number().min(0),
      })
    )
    .min(1, 'At least one invoice allocation is required'),
  payment_date: z.string(),
  check_number: z.string().optional(),
  check_bank: z.string().optional(),
  notes: z.string().optional(),
})

export const voidPaymentSchema = z.object({
  payment_id: z.string().uuid(),
  void_reason: z.string().min(10, 'Void reason must be at least 10 characters'),
})

export const generateInvoicesSchema = z.object({
  billing_date: z.string(),
  notes: z.string().optional(),
})

export type CreateFeeStructureInput = z.infer<typeof createFeeStructureSchema>
export type RecordPaymentInput = z.infer<typeof recordPaymentSchema>
export type RecordPartialPaymentInput = z.infer<typeof recordPartialPaymentSchema>
export type VoidPaymentInput = z.infer<typeof voidPaymentSchema>
export type GenerateInvoicesInput = z.infer<typeof generateInvoicesSchema>
