'use server'

import { createClient } from '@/lib/supabase/server'
import { getTenantId } from '@/lib/auth/helpers'
import { revalidatePath } from 'next/cache'

export async function getProperties() {
  try {
    const tenantId = await getTenantId()
    if (!tenantId) {
      throw new Error('No tenant ID found')
    }

    const supabase = await createClient()

    const { data: properties, error } = await supabase
      .from('properties')
      .select(`
        *,
        residence_units (count)
      `)
      .eq('tenant_id', tenantId)
      .order('name')

    if (error) {
      console.error('Error fetching properties:', error)
      return []
    }

    return properties || []
  } catch (error) {
    console.error('Error in getProperties:', error)
    return []
  }
}

export async function getProperty(propertyId: string) {
  try {
    const tenantId = await getTenantId()
    if (!tenantId) {
      throw new Error('No tenant ID found')
    }

    const supabase = await createClient()

    const { data: property, error } = await supabase
      .from('properties')
      .select('*')
      .eq('id', propertyId)
      .eq('tenant_id', tenantId)
      .single()

    if (error) {
      console.error('Error fetching property:', error)
      return { success: false, error: error.message }
    }

    return { success: true, data: property }
  } catch (error) {
    console.error('Error in getProperty:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to fetch property',
    }
  }
}

export async function createProperty(formData: FormData) {
  try {
    const tenantId = await getTenantId()
    if (!tenantId) {
      throw new Error('No tenant ID found')
    }

    const supabase = await createClient()

    const data = {
      tenant_id: tenantId,
      name: formData.get('name') as string,
      address: formData.get('address') as string,
      property_type: formData.get('property_type') as string || undefined,
    }

    const { data: property, error } = await supabase
      .from('properties')
      .insert([data])
      .select()
      .single()

    if (error) {
      console.error('Error creating property:', error)
      return {
        success: false,
        error: error.message,
      }
    }

    revalidatePath('/properties')

    return {
      success: true,
      data: property,
    }
  } catch (error) {
    console.error('Error in createProperty:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to create property',
    }
  }
}

export async function updateProperty(propertyId: string, formData: FormData) {
  try {
    const tenantId = await getTenantId()
    if (!tenantId) {
      throw new Error('No tenant ID found')
    }

    const supabase = await createClient()

    const data = {
      name: formData.get('name') as string,
      address: formData.get('address') as string,
      property_type: formData.get('property_type') as string || undefined,
    }

    const { data: property, error } = await supabase
      .from('properties')
      .update(data)
      .eq('id', propertyId)
      .eq('tenant_id', tenantId)
      .select()
      .single()

    if (error) {
      console.error('Error updating property:', error)
      return {
        success: false,
        error: error.message,
      }
    }

    revalidatePath('/properties')
    revalidatePath(`/properties/${propertyId}`)

    return {
      success: true,
      data: property,
    }
  } catch (error) {
    console.error('Error in updateProperty:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to update property',
    }
  }
}

export async function deleteProperty(propertyId: string) {
  try {
    const tenantId = await getTenantId()
    if (!tenantId) {
      throw new Error('No tenant ID found')
    }

    const supabase = await createClient()

    // Check if property has residence units
    const { count } = await supabase
      .from('residence_units')
      .select('*', { count: 'exact', head: true })
      .eq('property_id', propertyId)

    if (count && count > 0) {
      return {
        success: false,
        error: `Cannot delete property with ${count} residence unit(s). Please delete all units first.`,
      }
    }

    const { error } = await supabase
      .from('properties')
      .delete()
      .eq('id', propertyId)
      .eq('tenant_id', tenantId)

    if (error) {
      console.error('Error deleting property:', error)
      return {
        success: false,
        error: error.message,
      }
    }

    revalidatePath('/properties')

    return {
      success: true,
    }
  } catch (error) {
    console.error('Error in deleteProperty:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to delete property',
    }
  }
}
