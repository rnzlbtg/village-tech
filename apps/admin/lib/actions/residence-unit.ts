'use server'

import { createClient } from '@/lib/supabase/server'
import { getTenantId } from '@/lib/auth/helpers'
import { revalidatePath } from 'next/cache'

export async function getResidenceUnits(propertyId: string) {
  try {
    const tenantId = await getTenantId()
    if (!tenantId) {
      throw new Error('No tenant ID found')
    }

    const supabase = await createClient()

    // First verify the property belongs to this tenant
    const { data: property } = await supabase
      .from('properties')
      .select('id')
      .eq('id', propertyId)
      .eq('tenant_id', tenantId)
      .single()

    if (!property) {
      return []
    }

    const { data: units, error } = await supabase
      .from('residence_units')
      .select('*')
      .eq('property_id', propertyId)
      .order('unit_number')

    if (error) {
      console.error('Error fetching residence units:', error)
      return []
    }

    return units || []
  } catch (error) {
    console.error('Error in getResidenceUnits:', error)
    return []
  }
}

export async function createResidenceUnit(propertyId: string, formData: FormData) {
  try {
    const tenantId = await getTenantId()
    if (!tenantId) {
      throw new Error('No tenant ID found')
    }

    const supabase = await createClient()

    // Verify the property belongs to this tenant
    const { data: property } = await supabase
      .from('properties')
      .select('id')
      .eq('id', propertyId)
      .eq('tenant_id', tenantId)
      .single()

    if (!property) {
      return {
        success: false,
        error: 'Property not found',
      }
    }

    const data = {
      property_id: propertyId,
      unit_number: formData.get('unit_number') as string,
      floor_number: formData.get('floor_number')
        ? parseInt(formData.get('floor_number') as string)
        : undefined,
      unit_type: formData.get('unit_type') as string || undefined,
      bedrooms: formData.get('bedrooms')
        ? parseInt(formData.get('bedrooms') as string)
        : undefined,
      bathrooms: formData.get('bathrooms')
        ? parseFloat(formData.get('bathrooms') as string)
        : undefined,
      square_meters: formData.get('square_meters')
        ? parseFloat(formData.get('square_meters') as string)
        : undefined,
      parking_slots: formData.get('parking_slots')
        ? parseInt(formData.get('parking_slots') as string)
        : undefined,
    }

    const { data: unit, error } = await supabase
      .from('residence_units')
      .insert([data])
      .select()
      .single()

    if (error) {
      console.error('Error creating residence unit:', error)
      return {
        success: false,
        error: error.message,
      }
    }

    revalidatePath(`/properties/${propertyId}`)
    revalidatePath('/properties')

    return {
      success: true,
      data: unit,
    }
  } catch (error) {
    console.error('Error in createResidenceUnit:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to create residence unit',
    }
  }
}

export async function deleteResidenceUnit(unitId: string) {
  try {
    const tenantId = await getTenantId()
    if (!tenantId) {
      throw new Error('No tenant ID found')
    }

    const supabase = await createClient()

    // Verify the unit's property belongs to this tenant
    const { data: unit } = await supabase
      .from('residence_units')
      .select('property_id, properties!inner(tenant_id)')
      .eq('id', unitId)
      .single()

    if (!unit || (unit.properties as any).tenant_id !== tenantId) {
      return {
        success: false,
        error: 'Residence unit not found',
      }
    }

    // Check if unit has households
    const { count } = await supabase
      .from('households')
      .select('*', { count: 'exact', head: true })
      .eq('residence_unit_id', unitId)

    if (count && count > 0) {
      return {
        success: false,
        error: `Cannot delete unit with ${count} household(s). Please delete all households first.`,
      }
    }

    const { error } = await supabase
      .from('residence_units')
      .delete()
      .eq('id', unitId)

    if (error) {
      console.error('Error deleting residence unit:', error)
      return {
        success: false,
        error: error.message,
      }
    }

    revalidatePath(`/properties/${unit.property_id}`)
    revalidatePath('/properties')

    return {
      success: true,
    }
  } catch (error) {
    console.error('Error in deleteResidenceUnit:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to delete residence unit',
    }
  }
}
