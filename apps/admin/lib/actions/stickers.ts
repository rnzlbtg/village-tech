'use server'

import { revalidatePath } from 'next/cache'
import { createClient } from '@/lib/supabase/server'
import { getTenantId, getUserId, requireAdmin } from '@/lib/auth/helpers'
import {
  setStickerProgramSchema,
  approveStickerRequestSchema,
  rejectStickerRequestSchema,
  distributeStickerSchema,
  type SetStickerProgramInput,
  type ApproveStickerRequestInput,
  type RejectStickerRequestInput,
  type DistributeStickerInput,
} from '@/lib/validations/stickers'
import { sendEmail, stickerApprovedEmail, stickerRejectedEmail } from '@/lib/notifications/email'
import { generateStickerReceipt, type StickerReceiptData } from '@/lib/pdf/sticker-receipt'

/**
 * Set sticker program configuration for tenant
 * Configures vehicle sticker allocation limits per household
 */
export async function setStickerProgram(input: SetStickerProgramInput) {
  try {
    await requireAdmin()
    const supabase = await createClient()
    const tenantId = await getTenantId()

    // Validate input
    const data = setStickerProgramSchema.parse(input)

    // Check if active program already exists
    const { data: existingProgram } = await supabase
      .from('sticker_programs')
      .select('id')
      .eq('tenant_id', tenantId)
      .eq('is_active', true)
      .maybeSingle()

    if (existingProgram) {
      // Deactivate existing program
      await supabase
        .from('sticker_programs')
        .update({ is_active: false })
        .eq('id', existingProgram.id)
    }

    // Create new sticker program
    const { data: program, error } = await supabase
      .from('sticker_programs')
      .insert({
        tenant_id: tenantId,
        program_name: data.program_name,
        program_year: data.program_year,
        stickers_per_household: data.stickers_per_household,
        start_date: data.effective_date,
        end_date: data.expiry_date,
        is_active: true,
      })
      .select()
      .single()

    if (error) {
      console.error('Error creating sticker program:', error)
      return { success: false, error: error.message }
    }

    revalidatePath('/stickers')
    revalidatePath('/stickers/program')

    return { success: true, data: program }
  } catch (error) {
    console.error('Error in setStickerProgram:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to set sticker program',
    }
  }
}

/**
 * Approve a sticker request
 * Validates allocation limits before approval
 */
export async function approveStickerRequest(input: ApproveStickerRequestInput) {
  try {
    await requireAdmin()
    const supabase = await createClient()
    const tenantId = await getTenantId()
    const userId = await getUserId()

    // Validate input
    const data = approveStickerRequestSchema.parse(input)

    // Get sticker request with household info
    const { data: request, error: requestError } = await supabase
      .from('sticker_requests')
      .select(`
        *,
        household:households!inner(
          id,
          household_name,
          tenant_id,
          household_head_id
        )
      `)
      .eq('id', data.request_id)
      .eq('household.tenant_id', tenantId)
      .single()

    if (requestError || !request) {
      return { success: false, error: 'Sticker request not found' }
    }

    // Check if request is already processed
    if (request.request_status !== 'pending') {
      return { success: false, error: `Request is already ${request.request_status}` }
    }

    // Get active sticker program
    const { data: program, error: programError } = await supabase
      .from('sticker_programs')
      .select('stickers_per_household')
      .eq('tenant_id', tenantId)
      .eq('is_active', true)
      .single()

    if (programError || !program) {
      return { success: false, error: 'No active sticker program found' }
    }

    // Count existing approved/distributed stickers for household
    const { count: existingStickers, error: countError } = await supabase
      .from('sticker_requests')
      .select('*', { count: 'exact', head: true })
      .eq('household_id', request.household_id)
      .in('request_status', ['approved', 'distributed'])

    if (countError) {
      return { success: false, error: 'Failed to check allocation limit' }
    }

    // Validate allocation limit
    if (existingStickers !== null && existingStickers >= program.stickers_per_household) {
      return {
        success: false,
        error: `Household has reached allocation limit of ${program.stickers_per_household} stickers`,
      }
    }

    // Approve the request
    const { error: updateError } = await supabase
      .from('sticker_requests')
      .update({
        request_status: 'approved',
        reviewed_at: new Date().toISOString(),
        reviewed_by: userId,
      })
      .eq('id', data.request_id)

    if (updateError) {
      return { success: false, error: 'Failed to approve sticker request' }
    }

    // T053: Send notification to household head
    if (request.household.household_head_id) {
      const { data: householdHead } = await supabase
        .from('user_profiles')
        .select('first_name, last_name, email')
        .eq('id', request.household.household_head_id)
        .single()

      if (householdHead?.email) {
        const pickupInstructions =
          'Please visit the admin office during business hours (Mon-Fri, 9 AM - 5 PM) to collect your sticker. Bring a valid ID for verification.'

        const emailTemplate = stickerApprovedEmail({
          householdHeadName: householdHead ? `${householdHead.first_name} ${householdHead.last_name}` : 'Resident',
          vehiclePlate: request.vehicle_plate,
          pickupInstructions,
        })

        await sendEmail({
          to: householdHead.email,
          subject: emailTemplate.subject,
          html: emailTemplate.html,
          text: emailTemplate.text,
        })
      }
    }

    revalidatePath('/stickers')

    return {
      success: true,
      message: 'Sticker request approved successfully',
    }
  } catch (error) {
    console.error('Error in approveStickerRequest:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to approve sticker request',
    }
  }
}

/**
 * Reject a sticker request with reason
 */
export async function rejectStickerRequest(input: RejectStickerRequestInput) {
  try {
    await requireAdmin()
    const supabase = await createClient()
    const tenantId = await getTenantId()

    // Validate input
    const data = rejectStickerRequestSchema.parse(input)

    // Get sticker request
    const { data: request, error: requestError } = await supabase
      .from('sticker_requests')
      .select(`
        *,
        household:households!inner(tenant_id, household_head_id)
      `)
      .eq('id', data.request_id)
      .eq('household.tenant_id', tenantId)
      .single()

    if (requestError || !request) {
      return { success: false, error: 'Sticker request not found' }
    }

    // Check if request is already processed
    if (request.request_status !== 'pending') {
      return { success: false, error: `Request is already ${request.request_status}` }
    }

    // Reject the request
    const { error: updateError } = await supabase
      .from('sticker_requests')
      .update({
        request_status: 'rejected',
        rejection_reason: data.rejection_reason,
      })
      .eq('id', data.request_id)

    if (updateError) {
      return { success: false, error: 'Failed to reject sticker request' }
    }

    // T054: Send notification to household head
    if (request.household.household_head_id) {
      const { data: householdHead } = await supabase
        .from('user_profiles')
        .select('first_name, last_name, email')
        .eq('id', request.household.household_head_id)
        .single()

      if (householdHead?.email) {
        const emailTemplate = stickerRejectedEmail({
          householdHeadName: householdHead ? `${householdHead.first_name} ${householdHead.last_name}` : 'Resident',
          vehiclePlate: request.vehicle_plate,
          rejectionReason: data.rejection_reason,
        })

        await sendEmail({
          to: householdHead.email,
          subject: emailTemplate.subject,
          html: emailTemplate.html,
          text: emailTemplate.text,
        })
      }
    }

    revalidatePath('/stickers')

    return {
      success: true,
      message: 'Sticker request rejected',
    }
  } catch (error) {
    console.error('Error in rejectStickerRequest:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to reject sticker request',
    }
  }
}

/**
 * Mark sticker as physically distributed
 * Records signature and creates rfid_stickers record
 */
export async function distributeStickerPhysical(input: DistributeStickerInput) {
  try {
    await requireAdmin()
    const supabase = await createClient()
    const tenantId = await getTenantId()

    // Validate input
    const data = distributeStickerSchema.parse(input)

    // Get sticker request
    const { data: request, error: requestError } = await supabase
      .from('sticker_requests')
      .select(`
        *,
        household:households!inner(
          id,
          tenant_id,
          household_name,
          residence_unit:residence_units(unit_number)
        )
      `)
      .eq('id', data.request_id)
      .eq('household.tenant_id', tenantId)
      .single()

    if (requestError || !request) {
      return { success: false, error: 'Sticker request not found' }
    }

    // Check if request is approved
    if (request.request_status !== 'approved') {
      return {
        success: false,
        error: `Cannot distribute sticker with status: ${request.request_status}`,
      }
    }

    // Check if sticker code already exists
    const { data: existingSticker } = await supabase
      .from('rfid_stickers')
      .select('id')
      .eq('sticker_code', data.sticker_code)
      .maybeSingle()

    if (existingSticker) {
      return { success: false, error: 'Sticker code already exists' }
    }

    // Create rfid_stickers record
    const { error: stickerError } = await supabase
      .from('rfid_stickers')
      .insert({
        tenant_id: tenantId,
        household_id: request.household_id,
        sticker_request_id: data.request_id,
        sticker_code: data.sticker_code,
        vehicle_plate: request.vehicle_plate,
        vehicle_make: request.vehicle_make,
        vehicle_color: request.vehicle_color,
        owner_name: request.owner_name,
        status: 'active',
        issued_at: data.distributed_at || new Date().toISOString(),
      })

    if (stickerError) {
      console.error('Error creating rfid_stickers record:', stickerError)
      return { success: false, error: 'Failed to create sticker record' }
    }

    // Update sticker request as distributed
    const { error: updateError } = await supabase
      .from('sticker_requests')
      .update({
        request_status: 'distributed',
        sticker_code: data.sticker_code,
        distributed_at: data.distributed_at || new Date().toISOString(),
        distributed_by: await getUserId(),
        recipient_signature_url: data.signature,
      })
      .eq('id', data.request_id)

    if (updateError) {
      console.error('Error updating sticker request:', updateError)
      // Rollback: delete the rfid_stickers record
      await supabase
        .from('rfid_stickers')
        .delete()
        .eq('sticker_code', data.sticker_code)

      return { success: false, error: 'Failed to update distribution status' }
    }

    // T055: Generate distribution receipt
    const adminUserId = await getUserId()
    const { data: adminProfile } = adminUserId
      ? await supabase
          .from('user_profiles')
          .select('first_name, last_name')
          .eq('id', adminUserId)
          .single()
      : { data: null }

    const { data: tenant } = await supabase.from('tenants').select('name').eq('id', tenantId).single()

    const receiptNumber = `STK-${new Date().getFullYear()}-${data.sticker_code.slice(-6)}`

    const receiptData: StickerReceiptData = {
      receipt_number: receiptNumber,
      sticker_code: data.sticker_code,
      household_name: request.household.household_name,
      residence_unit: request.household.residence_unit?.unit_number || 'N/A',
      vehicle_plate: request.vehicle_plate,
      vehicle_make: request.vehicle_make,
      vehicle_color: request.vehicle_color,
      owner_name: request.owner_name,
      distributed_at: data.distributed_at || new Date().toISOString(),
      distributed_by: adminProfile ? `${adminProfile.first_name} ${adminProfile.last_name}` : 'Admin',
      signature: data.signature,
      tenant_name: tenant?.name,
    }

    const receipt = generateStickerReceipt(receiptData)

    revalidatePath('/stickers')

    return {
      success: true,
      message: 'Sticker distributed successfully',
      sticker_code: data.sticker_code,
      receipt: receipt,
      receipt_number: receiptNumber,
    }
  } catch (error) {
    console.error('Error in distributeStickerPhysical:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to distribute sticker',
    }
  }
}
