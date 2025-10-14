'use server'

/**
 * Household Management Server Actions
 *
 * SECURITY NOTE: This file contains auth user creation that bypasses RLS.
 * - Uses createAdminClient() with service role to create auth users
 * - tenant_id is set by application code, not enforced by database
 * - Acceptable for MVP/development but should be improved for production
 *
 * Production Security Improvements:
 * 1. Implement invitation-based signup flow (see migration 036_secure_household_head_creation.sql)
 * 2. OR use Supabase Auth Hooks to set tenant_id from invitation
 * 3. Remove service role usage from user creation
 *
 * See docs/SECURITY_AUTH_DESIGN.md for detailed analysis and solutions.
 */

import { createClient, createAdminClient } from '@/lib/supabase/server'
import { requireAdmin, getTenantId } from '@/lib/auth/helpers'
import { revalidatePath } from 'next/cache'
import {
  createHouseholdSchema,
  updateHouseholdSchema,
  createHouseholdHeadSchema,
  addHouseholdMemberSchema,
} from '@/lib/validations/household'
import { sendWelcomeEmail, getTenantEmailSettings } from '@/lib/email/send'

export async function createHousehold(formData: FormData) {
  try {
    await requireAdmin()
    const tenantId = await getTenantId()

    if (!tenantId) {
      return { success: false, error: 'Tenant ID not found' }
    }

    const supabase = await createClient()
    const adminClient = await createAdminClient()

    // Parse household head data
    const headData = {
      first_name: formData.get('first_name') as string,
      last_name: formData.get('last_name') as string,
      email: formData.get('email') as string,
      phone_number: formData.get('phone_number') as string,
      date_of_birth: formData.get('date_of_birth') as string || undefined,
      password: formData.get('password') as string,
    }

    // Validate household head data using schema
    const validation = createHouseholdHeadSchema.safeParse(headData)
    if (!validation.success) {
      const errorMessages = validation.error.errors.map(e => `${e.path.join('.')}: ${e.message}`).join(', ')
      return { success: false, error: `Validation error: ${errorMessages}` }
    }

    // Validate required residence unit fields
    const propertyId = formData.get('property_id') as string
    const unitNumber = formData.get('unit_number') as string
    const unitAddress = formData.get('unit_address') as string

    if (!propertyId || !unitNumber || !unitAddress) {
      return { success: false, error: 'Property, unit number, and unit address are required' }
    }

    // Check duplicate email in auth system (case-insensitive)
    const { data: existingUser } = await adminClient.auth.admin.listUsers()
    const emailExists = existingUser?.users.some((u) => u.email?.toLowerCase() === headData.email.toLowerCase())

    if (emailExists) {
      return {
        success: false,
        error: 'This email address is already registered. Please use a different email or contact support if this is an error.'
      }
    }

    // Check duplicate unit number within property
    const { data: existingUnit } = await supabase
      .from('residence_units')
      .select('id')
      .eq('property_id', propertyId)
      .eq('unit_number', unitNumber)
      .single()

    if (existingUnit) {
      return {
        success: false,
        error: `Unit number "${unitNumber}" already exists in this property. Please choose a different unit number.`
      }
    }

    // Step 1: Create residence unit
    const unitData = {
      tenant_id: tenantId,
      property_id: formData.get('property_id') as string,
      unit_number: formData.get('unit_number') as string,
      unit_type: formData.get('unit_type') as string || 'residential',
      address: formData.get('unit_address') as string || undefined,
      status: 'occupied',
    }

    const { data: residenceUnit, error: unitError } = await supabase
      .from('residence_units')
      .insert(unitData)
      .select()
      .single()

    if (unitError) {
      console.error('Error creating residence unit:', unitError)
      return { success: false, error: unitError.message }
    }

    // Step 3: Create auth user for household head
    // TODO: SECURITY CONCERN - This uses service role and bypasses RLS
    // The tenant_id is set by application code, not enforced by database
    // For production, implement invitation-based flow (see migration 036_secure_household_head_creation.sql)
    // or Supabase Auth Hooks (see docs/SECURITY_AUTH_DESIGN.md)
    // Current implementation is acceptable for MVP/development but should be improved before production
    const { data: authUser, error: authError } = await adminClient.auth.admin.createUser({
      email: headData.email,
      password: headData.password,
      email_confirm: true,
      user_metadata: {
        first_name: headData.first_name,
        last_name: headData.last_name,
        phone_number: headData.phone_number,
        role: 'household_head',
      },
      app_metadata: {
        role: 'household_head',
        tenant_id: tenantId, // ⚠️ Manually set - no database enforcement
      },
    })

    if (authError || !authUser.user) {
      // Rollback: delete residence unit
      await supabase
        .from('residence_units')
        .delete()
        .eq('id', residenceUnit.id)

      console.error('Error creating auth user:', authError)
      return { success: false, error: authError?.message || 'Failed to create user account' }
    }

    // Step 4: Create household linked to residence unit
    // Generate household name from first and last name
    const householdName = `${headData.first_name} ${headData.last_name} Household`

    const householdData = {
      tenant_id: tenantId,
      residence_unit_id: residenceUnit.id,
      household_head_id: authUser.user.id,
      household_name: householdName,
      move_in_date: formData.get('move_in_date') as string || undefined,
      notes: formData.get('notes') as string || undefined,
      status: formData.get('status') as string || 'active',
    }

    const { data: household, error: householdError } = await supabase
      .from('households')
      .insert(householdData)
      .select()
      .single()

    if (householdError) {
      // Rollback: delete auth user and residence unit
      await adminClient.auth.admin.deleteUser(authUser.user.id)
      await supabase
        .from('residence_units')
        .delete()
        .eq('id', residenceUnit.id)

      console.error('Error creating household:', householdError)
      return { success: false, error: householdError.message }
    }

    // Step 5: Create household member record for the head
    const { error: memberError } = await supabase.from('household_members').insert({
      household_id: household.id,
      first_name: headData.first_name,
      last_name: headData.last_name,
      relationship: 'head',
      email: headData.email,
      phone_number: headData.phone_number,
      date_of_birth: headData.date_of_birth,
      is_primary_contact: true,
    })

    if (memberError) {
      console.error('Error creating household member:', memberError)
      // Continue anyway - household is created
    }

    // Step 6: Send welcome email to household head
    try {
      const emailSettings = await getTenantEmailSettings(tenantId)
      await sendWelcomeEmail({
        householdHeadName: `${headData.first_name} ${headData.last_name}`,
        email: headData.email,
        temporaryPassword: headData.password,
        unitNumber: unitData.unit_number,
        ...emailSettings,
      })
      console.log('Welcome email sent successfully to:', headData.email)
    } catch (emailError) {
      console.error('Error sending welcome email:', emailError)
      // Don't fail the entire operation if email fails
      // The household was created successfully
    }

    revalidatePath('/households')
    return { success: true, data: household, message: 'Household, unit, and household head created successfully. Welcome email sent.' }
  } catch (error) {
    console.error('Error in createHousehold:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to create household',
    }
  }
}

export async function createHouseholdWithHead(formData: FormData) {
  try {
    await requireAdmin()
    const tenantId = await getTenantId()

    if (!tenantId) {
      return { success: false, error: 'Tenant ID not found' }
    }

    // Parse household data
    const householdData = createHouseholdSchema.parse({
      residence_unit_id: formData.get('residence_unit_id'),
      household_name: formData.get('household_name'),
      move_in_date: formData.get('move_in_date') || undefined,
      notes: formData.get('notes') || undefined,
    })

    // Parse household head data
    const headData = createHouseholdHeadSchema.parse({
      first_name: formData.get('first_name'),
      last_name: formData.get('last_name'),
      email: formData.get('email'),
      phone_number: formData.get('phone_number'),
      date_of_birth: formData.get('date_of_birth') || undefined,
      id_document_type: formData.get('id_document_type') || undefined,
      id_document_number: formData.get('id_document_number') || undefined,
      password: formData.get('password'),
    })

    const supabase = await createClient()
    const adminClient = await createAdminClient()

    // Check duplicate email
    const { data: existingUser } = await adminClient.auth.admin.listUsers()
    const emailExists = existingUser?.users.some((u) => u.email === headData.email)

    if (emailExists) {
      return { success: false, error: 'Email address is already in use' }
    }

    // Create auth user for household head
    // TODO: SECURITY CONCERN - This uses service role and bypasses RLS
    // See comment in createHousehold() function above for details
    // For production: Use invitation system or Auth Hooks (see docs/SECURITY_AUTH_DESIGN.md)
    const { data: authUser, error: authError } = await adminClient.auth.admin.createUser({
      email: headData.email,
      password: headData.password,
      email_confirm: true,
      user_metadata: {
        first_name: headData.first_name,
        last_name: headData.last_name,
        phone_number: headData.phone_number,
        role: 'household_head',
      },
      app_metadata: {
        role: 'household_head',
        tenant_id: tenantId, // ⚠️ Manually set - no database enforcement
      },
    })

    if (authError || !authUser.user) {
      console.error('Error creating auth user:', authError)
      return { success: false, error: authError?.message || 'Failed to create user account' }
    }

    // Create household
    const { data: household, error: householdError } = await supabase
      .from('households')
      .insert({
        ...householdData,
        tenant_id: tenantId,
        household_head_id: authUser.user.id,
        status: 'active',
      })
      .select()
      .single()

    if (householdError) {
      // Rollback: delete auth user
      await adminClient.auth.admin.deleteUser(authUser.user.id)
      return { success: false, error: householdError.message }
    }

    // Create household member record for the head
    const { error: memberError } = await supabase.from('household_members').insert({
      household_id: household.id,
      first_name: headData.first_name,
      last_name: headData.last_name,
      relationship: 'head',
      email: headData.email,
      phone_number: headData.phone_number,
      date_of_birth: headData.date_of_birth,
      id_document_type: headData.id_document_type,
      id_document_number: headData.id_document_number,
      is_primary_contact: true,
    })

    if (memberError) {
      console.error('Error creating household member:', memberError)
      // Continue anyway - household is created
    }

    // Send welcome email with login credentials
    try {
      const emailSettings = await getTenantEmailSettings(tenantId)

      // Get residence unit info for email
      const { data: residenceUnit } = await supabase
        .from('residence_units')
        .select('unit_number')
        .eq('id', householdData.residence_unit_id)
        .single()

      await sendWelcomeEmail({
        householdHeadName: `${headData.first_name} ${headData.last_name}`,
        email: headData.email,
        temporaryPassword: headData.password,
        unitNumber: residenceUnit?.unit_number || 'N/A',
        ...emailSettings,
      })
      console.log('Welcome email sent successfully to:', headData.email)
    } catch (emailError) {
      console.error('Error sending welcome email:', emailError)
      // Don't fail the entire operation if email fails
    }

    revalidatePath('/households')
    return { success: true, data: household, message: 'Household and household head created successfully. Welcome email sent.' }
  } catch (error) {
    console.error('Error in createHouseholdWithHead:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to create household',
    }
  }
}

export async function updateHousehold(householdId: string, formData: FormData) {
  try {
    await requireAdmin()
    const tenantId = await getTenantId()

    if (!tenantId) {
      return { success: false, error: 'Tenant ID not found' }
    }

    const data = updateHouseholdSchema.parse({
      household_name: formData.get('household_name') || undefined,
      move_in_date: formData.get('move_in_date') || undefined,
      move_out_date: formData.get('move_out_date') || undefined,
      status: formData.get('status') || undefined,
      notes: formData.get('notes') || undefined,
    })

    const supabase = await createClient()

    const { data: household, error } = await supabase
      .from('households')
      .update(data)
      .eq('id', householdId)
      .eq('tenant_id', tenantId)
      .select()
      .single()

    if (error) {
      console.error('Error updating household:', error)
      return { success: false, error: error.message }
    }

    revalidatePath('/households')
    revalidatePath(`/households/${householdId}`)
    return { success: true, data: household }
  } catch (error) {
    console.error('Error in updateHousehold:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to update household',
    }
  }
}

export async function addHouseholdMember(householdId: string, formData: FormData) {
  try {
    await requireAdmin()
    const tenantId = await getTenantId()

    if (!tenantId) {
      return { success: false, error: 'Tenant ID not found' }
    }

    const data = addHouseholdMemberSchema.parse({
      first_name: formData.get('first_name'),
      last_name: formData.get('last_name'),
      relationship: formData.get('relationship'),
      date_of_birth: formData.get('date_of_birth') || undefined,
      phone_number: formData.get('phone_number') || undefined,
      email: formData.get('email') || undefined,
      is_primary_contact: formData.get('is_primary_contact') === 'true',
      id_document_type: formData.get('id_document_type') || undefined,
      id_document_number: formData.get('id_document_number') || undefined,
      emergency_contact_name: formData.get('emergency_contact_name') || undefined,
      emergency_contact_phone: formData.get('emergency_contact_phone') || undefined,
    })

    const supabase = await createClient()

    // Verify household belongs to tenant
    const { data: household } = await supabase
      .from('households')
      .select('id')
      .eq('id', householdId)
      .eq('tenant_id', tenantId)
      .single()

    if (!household) {
      return { success: false, error: 'Household not found' }
    }

    const { data: member, error } = await supabase
      .from('household_members')
      .insert({
        ...data,
        household_id: householdId,
      })
      .select()
      .single()

    if (error) {
      console.error('Error adding household member:', error)
      return { success: false, error: error.message }
    }

    revalidatePath(`/households/${householdId}`)
    return { success: true, data: member }
  } catch (error) {
    console.error('Error in addHouseholdMember:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to add household member',
    }
  }
}
