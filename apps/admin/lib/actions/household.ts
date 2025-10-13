'use server'

import { createClient, createAdminClient } from '@/lib/supabase/server'
import { requireAdmin, getTenantId } from '@/lib/auth/helpers'
import { revalidatePath } from 'next/cache'
import {
  createHouseholdSchema,
  updateHouseholdSchema,
  createHouseholdHeadSchema,
  addHouseholdMemberSchema,
} from '@/lib/validations/household'

export async function createHousehold(formData: FormData) {
  try {
    await requireAdmin()
    const tenantId = await getTenantId()

    if (!tenantId) {
      return { success: false, error: 'Tenant ID not found' }
    }

    const data = createHouseholdSchema.parse({
      residence_unit_id: formData.get('residence_unit_id'),
      household_name: formData.get('household_name'),
      move_in_date: formData.get('move_in_date') || undefined,
      notes: formData.get('notes') || undefined,
    })

    const supabase = await createClient()

    // Check if residence unit already has an active household
    const { data: existingHousehold } = await supabase
      .from('households')
      .select('id')
      .eq('residence_unit_id', data.residence_unit_id)
      .eq('status', 'active')
      .single()

    if (existingHousehold) {
      return {
        success: false,
        error: 'This residence unit already has an active household',
      }
    }

    // Create household
    const { data: household, error } = await supabase
      .from('households')
      .insert({
        ...data,
        tenant_id: tenantId,
        status: 'active',
      })
      .select()
      .single()

    if (error) {
      console.error('Error creating household:', error)
      return { success: false, error: error.message }
    }

    revalidatePath('/households')
    return { success: true, data: household }
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
    const adminClient = createAdminClient()

    // Check duplicate email
    const { data: existingUser } = await adminClient.auth.admin.listUsers()
    const emailExists = existingUser?.users.some((u) => u.email === headData.email)

    if (emailExists) {
      return { success: false, error: 'Email address is already in use' }
    }

    // Create auth user for household head
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
        tenant_id: tenantId,
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

    // TODO: Send welcome email with login credentials

    revalidatePath('/households')
    return { success: true, data: household, message: 'Household and household head created successfully' }
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
