'use server'

import { revalidatePath } from 'next/cache'
import { createClient } from '@/lib/supabase/server'
import { getTenantId, getUserId, requireAdmin } from '@/lib/auth/helpers'
import {
  recordPaymentSchema,
  recordPartialPaymentSchema,
  voidPaymentSchema,
  type RecordPaymentInput,
  type RecordPartialPaymentInput,
  type VoidPaymentInput,
} from '@/lib/validations/payments'

/**
 * T086: Record payment with receipt generation
 */
export async function recordPayment(input: RecordPaymentInput) {
  try {
    await requireAdmin()
    const supabase = await createClient()
    const tenantId = await getTenantId()
    const userId = await getUserId()

    const data = recordPaymentSchema.parse(input)

    // Get invoice details
    const { data: invoice, error: invoiceError } = await supabase
      .from('invoices')
      .select(`
        *,
        household:households!inner(
          id,
          household_name,
          tenant_id
        )
      `)
      .eq('id', data.invoice_id)
      .eq('household.tenant_id', tenantId)
      .single()

    if (invoiceError || !invoice) {
      return { success: false, error: 'Invoice not found' }
    }

    // Validate payment amount
    if (data.amount > invoice.amount_due) {
      return { success: false, error: 'Payment amount exceeds invoice balance' }
    }

    // T095: Generate receipt number using database function
    const { data: receiptData } = await supabase.rpc('generate_receipt_number', {
      p_tenant_id: tenantId,
    })

    const receiptNumber = receiptData || `RCP-${new Date().getFullYear()}-${Date.now().toString().slice(-6)}`

    // Create payment log
    const { data: payment, error: paymentError } = await supabase
      .from('payment_logs')
      .insert({
        tenant_id: tenantId,
        receipt_number: receiptNumber,
        household_id: invoice.household_id,
        invoice_id: data.invoice_id,
        amount: data.amount,
        payment_method: data.payment_method,
        payment_date: data.payment_date,
        check_number: data.check_number,
        check_bank: data.check_bank,
        check_date: data.check_date,
        status: 'completed',
        recorded_by: userId,
        notes: data.notes,
      })
      .select()
      .single()

    if (paymentError) {
      console.error('Error creating payment log:', paymentError)
      return { success: false, error: 'Failed to record payment' }
    }

    // T097: Update invoice status (handled by database trigger update_invoice_status)
    // Manually update invoice amount_paid
    const newAmountPaid = Number(invoice.amount_paid) + data.amount
    const { error: updateError } = await supabase
      .from('invoices')
      .update({
        amount_paid: newAmountPaid,
        updated_at: new Date().toISOString(),
      })
      .eq('id', data.invoice_id)

    if (updateError) {
      console.error('Error updating invoice:', updateError)
      // Don't return error, payment is recorded
    }

    revalidatePath('/fees/invoices')
    revalidatePath('/fees/payments')

    return {
      success: true,
      data: {
        payment,
        receipt_number: receiptNumber,
      },
      message: 'Payment recorded successfully',
    }
  } catch (error) {
    console.error('Error in recordPayment:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to record payment',
    }
  }
}

/**
 * T087: Record partial payment with multiple invoice allocations
 */
export async function recordPartialPayment(input: RecordPartialPaymentInput) {
  try {
    await requireAdmin()
    const supabase = await createClient()
    const tenantId = await getTenantId()
    const userId = await getUserId()

    const data = recordPartialPaymentSchema.parse(input)

    // Get household details
    const { data: household, error: householdError } = await supabase
      .from('households')
      .select('id, household_name, tenant_id')
      .eq('id', data.household_id)
      .eq('tenant_id', tenantId)
      .single()

    if (householdError || !household) {
      return { success: false, error: 'Household not found' }
    }

    // Generate receipt number
    const { data: receiptData } = await supabase.rpc('generate_receipt_number', {
      p_tenant_id: tenantId,
    })

    const receiptNumber = receiptData || `RCP-${new Date().getFullYear()}-${Date.now().toString().slice(-6)}`

    // Create payment log
    const { data: payment, error: paymentError } = await supabase
      .from('payment_logs')
      .insert({
        tenant_id: tenantId,
        receipt_number: receiptNumber,
        household_id: data.household_id,
        invoice_id: data.allocations[0]?.invoice_id, // Primary invoice
        amount: data.total_amount,
        payment_method: data.payment_method,
        payment_date: data.payment_date,
        check_number: data.check_number,
        check_bank: data.check_bank,
        status: 'completed',
        recorded_by: userId,
        notes: data.notes,
      })
      .select()
      .single()

    if (paymentError) {
      console.error('Error creating payment log:', paymentError)
      return { success: false, error: 'Failed to record payment' }
    }

    // Update all allocated invoices
    for (const allocation of data.allocations) {
      const { data: invoice } = await supabase
        .from('invoices')
        .select('amount_paid')
        .eq('id', allocation.invoice_id)
        .single()

      if (invoice) {
        const newAmountPaid = Number(invoice.amount_paid) + allocation.amount
        await supabase
          .from('invoices')
          .update({
            amount_paid: newAmountPaid,
            updated_at: new Date().toISOString(),
          })
          .eq('id', allocation.invoice_id)
      }
    }

    revalidatePath('/fees/invoices')
    revalidatePath('/fees/payments')

    return {
      success: true,
      data: {
        payment,
        receipt_number: receiptNumber,
      },
      message: 'Partial payment recorded successfully',
    }
  } catch (error) {
    console.error('Error in recordPartialPayment:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to record partial payment',
    }
  }
}

/**
 * T088: Void payment for corrections with notes
 */
export async function voidPayment(input: VoidPaymentInput) {
  try {
    await requireAdmin()
    const supabase = await createClient()
    const tenantId = await getTenantId()

    const data = voidPaymentSchema.parse(input)

    // Get payment details
    const { data: payment, error: paymentError } = await supabase
      .from('payment_logs')
      .select('*, invoice_id, amount')
      .eq('id', data.payment_id)
      .eq('tenant_id', tenantId)
      .single()

    if (paymentError || !payment) {
      return { success: false, error: 'Payment not found' }
    }

    if (payment.status === 'voided') {
      return { success: false, error: 'Payment is already voided' }
    }

    // Void the payment
    const { error: voidError } = await supabase
      .from('payment_logs')
      .update({
        status: 'voided',
        notes: data.void_reason,
        updated_at: new Date().toISOString(),
      })
      .eq('id', data.payment_id)

    if (voidError) {
      return { success: false, error: 'Failed to void payment' }
    }

    // Reverse invoice amount_paid if invoice exists
    if (payment.invoice_id) {
      const { data: invoice } = await supabase
        .from('invoices')
        .select('amount_paid')
        .eq('id', payment.invoice_id)
        .single()

      if (invoice) {
        const newAmountPaid = Math.max(0, Number(invoice.amount_paid) - Number(payment.amount))
        await supabase
          .from('invoices')
          .update({
            amount_paid: newAmountPaid,
            updated_at: new Date().toISOString(),
          })
          .eq('id', payment.invoice_id)
      }
    }

    revalidatePath('/fees/payments')
    revalidatePath('/fees/invoices')

    return {
      success: true,
      message: 'Payment voided successfully',
    }
  } catch (error) {
    console.error('Error in voidPayment:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to void payment',
    }
  }
}
