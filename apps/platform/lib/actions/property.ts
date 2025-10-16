'use server'

import { createClient } from '@/lib/supabase/server'
import { createPropertySchema, updatePropertySchema } from '@/lib/validations/property'
import { revalidatePath } from 'next/cache'
import { requireSuperAdmin } from '@/lib/auth/helpers'

export async function createProperty(formData: FormData) {
  try {
    await requireSuperAdmin()

    const supabase = await createClient()

    const data = createPropertySchema.parse({
      tenant_id: formData.get('tenant_id'),
      name: formData.get('name'),
      address: formData.get('address'),
      property_type: formData.get('property_type') || undefined,
      total_units: formData.get('total_units')
        ? parseInt(formData.get('total_units') as string)
        : undefined,
      total_floors: formData.get('total_floors')
        ? parseInt(formData.get('total_floors') as string)
        : undefined,
      year_built: formData.get('year_built')
        ? parseInt(formData.get('year_built') as string)
        : undefined,
      lot_size: formData.get('lot_size')
        ? parseFloat(formData.get('lot_size') as string)
        : undefined,
    })

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

    revalidatePath(`/tenants/${data.tenant_id}/properties`)

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

export async function updateProperty(formData: FormData) {
  try {
    await requireSuperAdmin()

    const supabase = await createClient()

    const data = updatePropertySchema.parse({
      id: formData.get('id'),
      tenant_id: formData.get('tenant_id') || undefined,
      name: formData.get('name') || undefined,
      address: formData.get('address') || undefined,
      property_type: formData.get('property_type') || undefined,
      total_units: formData.get('total_units')
        ? parseInt(formData.get('total_units') as string)
        : undefined,
      total_floors: formData.get('total_floors')
        ? parseInt(formData.get('total_floors') as string)
        : undefined,
      year_built: formData.get('year_built')
        ? parseInt(formData.get('year_built') as string)
        : undefined,
      lot_size: formData.get('lot_size')
        ? parseFloat(formData.get('lot_size') as string)
        : undefined,
    })

    const { id, ...updateData } = data

    const { data: property, error } = await supabase
      .from('properties')
      .update(updateData)
      .eq('id', id)
      .select()
      .single()

    if (error) {
      console.error('Error updating property:', error)
      return {
        success: false,
        error: error.message,
      }
    }

    revalidatePath(`/tenants/${property.tenant_id}/properties`)

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
    await requireSuperAdmin()

    const supabase = await createClient()

    // Check if property has residences
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

    if (error) {
      console.error('Error deleting property:', error)
      return {
        success: false,
        error: error.message,
      }
    }

    revalidatePath('/tenants')

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

export async function getProperties(tenantId: string) {
  try {
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
    const supabase = await createClient()

    const { data: property, error } = await supabase
      .from('properties')
      .select('*')
      .eq('id', propertyId)
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
