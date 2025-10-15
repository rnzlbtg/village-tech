'use server'

import { revalidatePath } from 'next/cache'
import { createClient } from '@/lib/supabase/server'
import { getTenantId, getUserId, requireAdmin } from '@/lib/auth/helpers'
import {
  computeRoadFeeSchema,
  approveConstructionPermitSchema,
  rejectConstructionPermitSchema,
  markPermitCompleteSchema,
  holdPermitSchema,
  type ComputeRoadFeeInput,
  type ApproveConstructionPermitInput,
  type RejectConstructionPermitInput,
  type MarkPermitCompleteInput,
  type HoldPermitInput,
} from '@/lib/validations/permits'
import { sendEmail, constructionPermitApprovedEmail } from '@/lib/notifications/email'

/**
 * T056: Compute road fee based on project type and duration
 *
 * Fee structure:
 * - Renovation: $50/month
 * - New Construction: $100/month
 * - Addition/Extension: $75/month
 * - Minimum 1 month charge
 */
export async function computeRoadFee(input: ComputeRoadFeeInput) {
  try {
    const data = computeRoadFeeSchema.parse(input)

    // Calculate project duration in months
    const startDate = new Date(data.start_date)
    const endDate = new Date(data.end_date)
    const durationMs = endDate.getTime() - startDate.getTime()
    const durationDays = Math.ceil(durationMs / (1000 * 60 * 60 * 24))
    const durationMonths = Math.max(1, Math.ceil(durationDays / 30))

    // Fee rates by project type
    const feeRates: Record<string, number> = {
      renovation: 50,
      new_construction: 100,
      'addition/extension': 75,
      landscaping: 30,
      repair: 25,
    }

    const ratePerMonth = feeRates[data.project_type] || 50
    const totalFee = ratePerMonth * durationMonths

    return {
      success: true,
      fee: totalFee,
      breakdown: {
        project_type: data.project_type,
        duration_days: durationDays,
        duration_months: durationMonths,
        rate_per_month: ratePerMonth,
        total_fee: totalFee,
      },
    }
  } catch (error) {
    console.error('Error computing road fee:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to compute road fee',
    }
  }
}

/**
 * T057: Approve construction permit with payment validation
 */
export async function approveConstructionPermit(input: ApproveConstructionPermitInput) {
  try {
    await requireAdmin()
    const supabase = await createClient()
    const tenantId = await getTenantId()
    const userId = await getUserId()

    const data = approveConstructionPermitSchema.parse(input)

    // Get permit with household info
    const { data: permit, error: permitError } = await supabase
      .from('construction_permits')
      .select(`
        *,
        household:households!inner(
          id,
          household_name,
          tenant_id,
          household_head_id
        )
      `)
      .eq('id', data.permit_id)
      .eq('household.tenant_id', tenantId)
      .single()

    if (permitError || !permit) {
      return { success: false, error: 'Construction permit not found' }
    }

    // Check permit status
    if (permit.permit_status !== 'pending') {
      return { success: false, error: `Permit is already ${permit.permit_status}` }
    }

    // Validate payment if required
    if (permit.road_fee_amount > 0 && permit.payment_deadline) {
      return {
        success: false,
        error: 'Payment must be completed before approval',
      }
    }

    // Approve the permit
    const { error: updateError } = await supabase
      .from('construction_permits')
      .update({
        permit_status: 'approved',
        approved_at: new Date().toISOString(),
        approved_by: userId,
      })
      .eq('id', data.permit_id)

    if (updateError) {
      return { success: false, error: 'Failed to approve construction permit' }
    }

    // T067: Send notification to household head
    if (permit.household.household_head_id) {
      const { data: householdHead } = await supabase
        .from('user_profiles')
        .select('first_name, last_name, email')
        .eq('id', permit.household.household_head_id)
        .single()

      if (householdHead?.email) {
        const workerNames = Array.isArray(permit.authorized_workers)
          ? permit.authorized_workers.map((w: any) => w.name || 'Unknown')
          : []

        const emailTemplate = constructionPermitApprovedEmail({
          householdHeadName: householdHead ? `${householdHead.first_name} ${householdHead.last_name}` : 'Resident',
          permitReference: permit.permit_reference,
          projectDescription: permit.project_description,
          startDate: new Date(permit.start_date).toLocaleDateString(),
          endDate: new Date(permit.estimated_end_date).toLocaleDateString(),
          authorizedWorkers: workerNames,
        })

        await sendEmail({
          to: householdHead.email,
          subject: emailTemplate.subject,
          html: emailTemplate.html,
          text: emailTemplate.text,
        })
      }
    }

    // T068: Send notification to guard house (logged for MVP)
    console.log('📋 Guard House Notification:', {
      permit_reference: permit.permit_reference,
      household: permit.household.household_name,
      authorized_workers: permit.authorized_workers,
      start_date: permit.start_date,
      end_date: permit.end_date,
    })

    revalidatePath('/permits')

    return {
      success: true,
      message: 'Construction permit approved successfully',
    }
  } catch (error) {
    console.error('Error in approveConstructionPermit:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to approve permit',
    }
  }
}

/**
 * T058: Reject construction permit with rejection reason
 */
export async function rejectConstructionPermit(input: RejectConstructionPermitInput) {
  try {
    await requireAdmin()
    const supabase = await createClient()
    const tenantId = await getTenantId()

    const data = rejectConstructionPermitSchema.parse(input)

    // Get permit
    const { data: permit, error: permitError } = await supabase
      .from('construction_permits')
      .select(`
        *,
        household:households!inner(tenant_id, household_head_id)
      `)
      .eq('id', data.permit_id)
      .eq('household.tenant_id', tenantId)
      .single()

    if (permitError || !permit) {
      return { success: false, error: 'Construction permit not found' }
    }

    // Check permit status
    if (permit.permit_status !== 'pending') {
      return { success: false, error: `Permit is already ${permit.permit_status}` }
    }

    // Reject the permit (store reason in notes or add rejection_reason column)
    const { error: updateError } = await supabase
      .from('construction_permits')
      .update({
        permit_status: 'rejected',
        rejection_reason: data.rejection_reason,
      })
      .eq('id', data.permit_id)

    if (updateError) {
      return { success: false, error: 'Failed to reject construction permit' }
    }

    // TODO: Send rejection notification to household head
    console.log('📧 Permit Rejection Notification:', {
      permit_id: data.permit_id,
      reason: data.rejection_reason,
    })

    revalidatePath('/permits')

    return {
      success: true,
      message: 'Construction permit rejected',
    }
  } catch (error) {
    console.error('Error in rejectConstructionPermit:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to reject permit',
    }
  }
}

/**
 * T059: Mark permit as complete and revoke worker access
 */
export async function markPermitComplete(input: MarkPermitCompleteInput) {
  try {
    await requireAdmin()
    const supabase = await createClient()
    const tenantId = await getTenantId()

    const data = markPermitCompleteSchema.parse(input)

    // Get permit
    const { data: permit, error: permitError } = await supabase
      .from('construction_permits')
      .select(`
        *,
        household:households!inner(tenant_id)
      `)
      .eq('id', data.permit_id)
      .eq('household.tenant_id', tenantId)
      .single()

    if (permitError || !permit) {
      return { success: false, error: 'Construction permit not found' }
    }

    // Check permit status
    if (permit.permit_status !== 'approved') {
      return {
        success: false,
        error: `Cannot complete permit with status: ${permit.permit_status}`,
      }
    }

    // Mark as completed
    const { error: updateError } = await supabase
      .from('construction_permits')
      .update({
        permit_status: 'completed',
        actual_end_date: new Date().toISOString().split('T')[0],
      })
      .eq('id', data.permit_id)

    if (updateError) {
      return { success: false, error: 'Failed to mark permit as complete' }
    }

    // Worker access revocation would be handled by guard app checking permit status
    console.log('✅ Permit Completed - Worker Access Revoked:', {
      permit_id: data.permit_id,
      permit_reference: permit.permit_reference,
    })

    revalidatePath('/permits')

    return {
      success: true,
      message: 'Construction permit marked as complete',
    }
  } catch (error) {
    console.error('Error in markPermitComplete:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to complete permit',
    }
  }
}

/**
 * T060: Hold permit for payment deadline violations
 */
export async function holdPermit(input: HoldPermitInput) {
  try {
    await requireAdmin()
    const supabase = await createClient()
    const tenantId = await getTenantId()

    const data = holdPermitSchema.parse(input)

    // Get permit
    const { data: permit, error: permitError } = await supabase
      .from('construction_permits')
      .select(`
        *,
        household:households!inner(tenant_id, household_head_id)
      `)
      .eq('id', data.permit_id)
      .eq('household.tenant_id', tenantId)
      .single()

    if (permitError || !permit) {
      return { success: false, error: 'Construction permit not found' }
    }

    // Hold the permit (add 'on_hold' to status enum if not exists)
    const { error: updateError } = await supabase
      .from('construction_permits')
      .update({
        permit_status: 'on_hold',
      })
      .eq('id', data.permit_id)

    if (updateError) {
      return { success: false, error: 'Failed to place permit on hold' }
    }

    // Notify household and guard house
    console.log('⚠️ Permit Placed on Hold:', {
      permit_id: data.permit_id,
      reason: data.hold_reason,
    })

    revalidatePath('/permits')

    return {
      success: true,
      message: 'Construction permit placed on hold',
    }
  } catch (error) {
    console.error('Error in holdPermit:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to hold permit',
    }
  }
}

/**
 * Resume a held permit
 */
export async function unholdPermit(input: { permit_id: string }) {
  try {
    await requireAdmin()
    const supabase = await createClient()
    const tenantId = await getTenantId()

    // Get permit
    const { data: permit, error: permitError } = await supabase
      .from('construction_permits')
      .select(`
        *,
        household:households!inner(tenant_id)
      `)
      .eq('id', input.permit_id)
      .eq('household.tenant_id', tenantId)
      .single()

    if (permitError || !permit) {
      return { success: false, error: 'Construction permit not found' }
    }

    // Check if permit is on hold
    if (permit.permit_status !== 'on_hold') {
      return {
        success: false,
        error: 'Only held permits can be resumed',
      }
    }

    // Resume the permit
    const { error: updateError } = await supabase
      .from('construction_permits')
      .update({
        permit_status: 'approved',
      })
      .eq('id', input.permit_id)

    if (updateError) {
      return { success: false, error: 'Failed to resume permit' }
    }

    // Notify household and guard house
    console.log('✅ Permit Resumed:', {
      permit_id: input.permit_id,
      permit_reference: permit.permit_reference,
    })

    revalidatePath('/permits')

    return {
      success: true,
      message: 'Construction permit resumed successfully',
    }
  } catch (error) {
    console.error('Error in unholdPermit:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to resume permit',
    }
  }
}

