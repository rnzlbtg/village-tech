'use server'

import { revalidatePath } from 'next/cache'
import { createClient } from '@/lib/supabase/server'
import { getTenantId, getUserId, requireAdmin } from '@/lib/auth/helpers'
import {
  createFeeStructureSchema,
  generateInvoicesSchema,
  type CreateFeeStructureInput,
  type GenerateInvoicesInput,
} from '@/lib/validations/payments'

/**
 * T084: Create fee structure for configuring billing periods
 */
export async function createFeeStructure(input: CreateFeeStructureInput) {
  try {
    await requireAdmin()
    const supabase = await createClient()
    const tenantId = await getTenantId()

    const data = createFeeStructureSchema.parse(input)

    // Store fee structure in association_settings
    const { data: settings, error } = await supabase
      .from('association_settings')
      .upsert(
        {
          tenant_id: tenantId,
          association_fee_amount: data.fee_amount,
          billing_period: data.billing_period,
          due_day_of_month: data.due_day_of_month || 1,
          late_fee_amount: data.late_fee_amount || 0,
          late_fee_grace_days: data.late_fee_grace_days || 0,
          updated_at: new Date().toISOString(),
        },
        {
          onConflict: 'tenant_id',
        }
      )
      .select()
      .single()

    if (error) {
      console.error('Error creating fee structure:', error)
      return { success: false, error: error.message }
    }

    revalidatePath('/fees/structure')

    return {
      success: true,
      data: settings,
      message: 'Fee structure configured successfully',
    }
  } catch (error) {
    console.error('Error in createFeeStructure:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to create fee structure',
    }
  }
}

/**
 * T085: Generate invoices for all households based on fee schedule
 */
export async function generateInvoices(input: GenerateInvoicesInput) {
  try {
    await requireAdmin()
    const supabase = await createClient()
    const tenantId = await getTenantId()

    const data = generateInvoicesSchema.parse(input)

    // Get fee structure
    const { data: settings, error: settingsError } = await supabase
      .from('association_settings')
      .select('association_fee_amount, billing_period, due_day_of_month')
      .eq('tenant_id', tenantId)
      .single()

    if (settingsError || !settings) {
      return { success: false, error: 'Fee structure not configured' }
    }

    // Get all active households
    const { data: households, error: householdsError } = await supabase
      .from('households')
      .select('id, household_name')
      .eq('tenant_id', tenantId)
      .eq('status', 'active')

    if (householdsError || !households) {
      return { success: false, error: 'Failed to fetch households' }
    }

    // Calculate due date
    const billingDate = new Date(data.billing_date)
    const dueDate = new Date(billingDate)
    dueDate.setDate(settings.due_day_of_month || 1)
    if (dueDate <= billingDate) {
      dueDate.setMonth(dueDate.getMonth() + 1)
    }

    // Generate invoice number prefix
    const year = billingDate.getFullYear()
    const month = String(billingDate.getMonth() + 1).padStart(2, '0')

    // Create invoices for all households
    const invoices = households.map((household, index) => ({
      tenant_id: tenantId,
      household_id: household.id,
      invoice_number: `INV-${year}-${month}-${String(index + 1).padStart(4, '0')}`,
      invoice_type: 'association_fee',
      description: `${settings.billing_period} Association Fee - ${billingDate.toLocaleDateString('en-US', { month: 'long', year: 'numeric' })}`,
      total_amount: settings.association_fee_amount,
      amount_paid: 0,
      status: 'unpaid',
      due_date: dueDate.toISOString().split('T')[0],
    }))

    const { data: createdInvoices, error: invoicesError } = await supabase
      .from('invoices')
      .insert(invoices)
      .select()

    if (invoicesError) {
      console.error('Error creating invoices:', invoicesError)
      return { success: false, error: 'Failed to generate invoices' }
    }

    revalidatePath('/fees/invoices')

    return {
      success: true,
      data: {
        invoice_count: createdInvoices.length,
        total_amount: settings.association_fee_amount * createdInvoices.length,
        due_date: dueDate.toISOString().split('T')[0],
      },
      message: `Generated ${createdInvoices.length} invoices successfully`,
    }
  } catch (error) {
    console.error('Error in generateInvoices:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to generate invoices',
    }
  }
}
