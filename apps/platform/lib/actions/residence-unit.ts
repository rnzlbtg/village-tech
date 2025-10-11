'use server'

import { createClient } from '@/lib/supabase/server'
import { createResidenceUnitSchema, updateResidenceUnitSchema } from '@/lib/validations/residence-unit'
import { revalidatePath } from 'next/cache'
import { requireSuperAdmin } from '@/lib/auth/helpers'

export async function createResidenceUnit(formData: FormData) {
  try {
    await requireSuperAdmin()

    const supabase = await createClient()

    const data = createResidenceUnitSchema.parse({
      tenant_id: formData.get('tenant_id'),
      property_id: formData.get('property_id'),
      unit_number: formData.get('unit_number'),
      floor_number: formData.get('floor_number')
        ? parseInt(formData.get('floor_number') as string)
        : undefined,
      unit_type: formData.get('unit_type') || undefined,
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
      is_occupied: formData.get('is_occupied') === 'true',
      notes: formData.get('notes') || undefined,
    })

    // Check for duplicate unit number in same property
    const { data: existingUnit } = await supabase
      .from('residence_units')
      .select('id')
      .eq('property_id', data.property_id)
      .eq('unit_number', data.unit_number)
      .single()

    if (existingUnit) {
      return {
        success: false,
        error: 'A unit with this number already exists in this property',
      }
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

    revalidatePath(`/tenants/${data.tenant_id}/properties/${data.property_id}`)

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

export async function updateResidenceUnit(formData: FormData) {
  try {
    await requireSuperAdmin()

    const supabase = await createClient()

    const data = updateResidenceUnitSchema.parse({
      id: formData.get('id'),
      tenant_id: formData.get('tenant_id') || undefined,
      property_id: formData.get('property_id') || undefined,
      unit_number: formData.get('unit_number') || undefined,
      floor_number: formData.get('floor_number')
        ? parseInt(formData.get('floor_number') as string)
        : undefined,
      unit_type: formData.get('unit_type') || undefined,
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
      is_occupied: formData.get('is_occupied') === 'true' || undefined,
      notes: formData.get('notes') || undefined,
    })

    const { id, ...updateData } = data

    const { data: unit, error } = await supabase
      .from('residence_units')
      .update(updateData)
      .eq('id', id)
      .select()
      .single()

    if (error) {
      console.error('Error updating residence unit:', error)
      return {
        success: false,
        error: error.message,
      }
    }

    revalidatePath(`/tenants/${unit.tenant_id}/properties/${unit.property_id}`)

    return {
      success: true,
      data: unit,
    }
  } catch (error) {
    console.error('Error in updateResidenceUnit:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to update residence unit',
    }
  }
}

export async function deleteResidenceUnit(unitId: string) {
  try {
    await requireSuperAdmin()

    const supabase = await createClient()

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

    revalidatePath('/tenants')

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

export async function getResidenceUnits(propertyId: string) {
  try {
    const supabase = await createClient()

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
