'use server'

import { createClient } from '@/lib/supabase/server'
import { createTenantSchema, updateTenantSchema } from '@/lib/validations/tenant'
import { revalidatePath } from 'next/cache'
import { requireSuperAdmin } from '@/lib/auth/helpers'

export async function createTenant(formData: FormData) {
  try {
    // Check authorization
    await requireSuperAdmin()

    const supabase = await createClient()

    // Parse and validate form data
    const data = createTenantSchema.parse({
      name: formData.get('name'),
      address: formData.get('address'),
      city: formData.get('city') || undefined,
      state: formData.get('state') || undefined,
      country: formData.get('country') || 'Philippines',
      postal_code: formData.get('postal_code') || undefined,
      contact_name: formData.get('contact_name') || undefined,
      contact_email: formData.get('contact_email') || undefined,
      contact_phone: formData.get('contact_phone') || undefined,
      subscription_status:
        (formData.get('subscription_status') as 'active' | 'inactive' | 'suspended' | 'trial') ||
        'active',
      subscription_plan: formData.get('subscription_plan') || undefined,
      max_users: formData.get('max_users')
        ? parseInt(formData.get('max_users') as string)
        : undefined,
      max_residences: formData.get('max_residences')
        ? parseInt(formData.get('max_residences') as string)
        : undefined,
    })

    // Check for duplicate tenant name
    const { data: existingTenant } = await supabase
      .from('tenants')
      .select('id')
      .eq('name', data.name)
      .single()

    if (existingTenant) {
      return {
        success: false,
        error: 'A community with this name already exists',
      }
    }

    // Create tenant
    const { data: tenant, error } = await supabase
      .from('tenants')
      .insert([data])
      .select()
      .single()

    if (error) {
      console.error('Error creating tenant:', error)
      return {
        success: false,
        error: error.message,
      }
    }

    // Revalidate tenant list page
    revalidatePath('/tenants')

    return {
      success: true,
      data: tenant,
    }
  } catch (error) {
    console.error('Error in createTenant:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to create tenant',
    }
  }
}

export async function updateTenant(formData: FormData) {
  try {
    // Check authorization
    await requireSuperAdmin()

    const supabase = await createClient()

    // Parse and validate form data
    const data = updateTenantSchema.parse({
      id: formData.get('id'),
      name: formData.get('name') || undefined,
      address: formData.get('address') || undefined,
      city: formData.get('city') || undefined,
      state: formData.get('state') || undefined,
      country: formData.get('country') || undefined,
      postal_code: formData.get('postal_code') || undefined,
      contact_name: formData.get('contact_name') || undefined,
      contact_email: formData.get('contact_email') || undefined,
      contact_phone: formData.get('contact_phone') || undefined,
      subscription_status: formData.get('subscription_status') as
        | 'active'
        | 'inactive'
        | 'suspended'
        | 'trial'
        | undefined,
      subscription_plan: formData.get('subscription_plan') || undefined,
      max_users: formData.get('max_users')
        ? parseInt(formData.get('max_users') as string)
        : undefined,
      max_residences: formData.get('max_residences')
        ? parseInt(formData.get('max_residences') as string)
        : undefined,
    })

    const { id, ...updateData } = data

    // Update tenant
    const { data: tenant, error } = await supabase
      .from('tenants')
      .update(updateData)
      .eq('id', id)
      .select()
      .single()

    if (error) {
      console.error('Error updating tenant:', error)
      return {
        success: false,
        error: error.message,
      }
    }

    // Revalidate tenant pages
    revalidatePath('/tenants')
    revalidatePath(`/tenants/${id}`)

    return {
      success: true,
      data: tenant,
    }
  } catch (error) {
    console.error('Error in updateTenant:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to update tenant',
    }
  }
}

export async function deleteTenant(tenantId: string) {
  try {
    // Check authorization
    await requireSuperAdmin()

    const supabase = await createClient()

    // Check if tenant has associated data (properties, users, etc.)
    const { count: propertyCount } = await supabase
      .from('properties')
      .select('*', { count: 'exact', head: true })
      .eq('tenant_id', tenantId)

    if (propertyCount && propertyCount > 0) {
      return {
        success: false,
        error:
          'Cannot delete tenant with existing properties. Please remove all properties first.',
      }
    }

    // Delete tenant (CASCADE will handle related records)
    const { error } = await supabase.from('tenants').delete().eq('id', tenantId)

    if (error) {
      console.error('Error deleting tenant:', error)
      return {
        success: false,
        error: error.message,
      }
    }

    // Revalidate tenant list page
    revalidatePath('/tenants')

    return {
      success: true,
    }
  } catch (error) {
    console.error('Error in deleteTenant:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to delete tenant',
    }
  }
}

export async function getTenants() {
  try {
    const supabase = await createClient()

    const { data, error } = await supabase
      .from('tenants')
      .select('*')
      .order('created_at', { ascending: false })

    if (error) {
      throw error
    }

    return data
  } catch (error) {
    console.error('Error fetching tenants:', error)
    return []
  }
}

export async function getTenant(tenantId: string) {
  try {
    const supabase = await createClient()

    const { data, error } = await supabase
      .from('tenants')
      .select('*')
      .eq('id', tenantId)
      .single()

    if (error) {
      console.error('Error fetching tenant:', error)
      return { success: false, error: error.message }
    }

    return { success: true, data }
  } catch (error) {
    console.error('Error fetching tenant:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to fetch tenant',
    }
  }
}
