'use server'

import { createClient } from '@/lib/supabase/server'
import { createGateSchema, updateGateSchema } from '@/lib/validations/gate'
import { revalidatePath } from 'next/cache'
import { requireSuperAdmin } from '@/lib/auth/helpers'

export async function createGate(formData: FormData) {
  try {
    await requireSuperAdmin()

    const supabase = await createClient()

    // Parse equipment config JSON if provided
    let equipmentConfig = null
    const equipmentConfigStr = formData.get('equipment_config')
    if (equipmentConfigStr && equipmentConfigStr !== '') {
      try {
        equipmentConfig = JSON.parse(equipmentConfigStr as string)
      } catch (e) {
        return {
          success: false,
          error: 'Invalid equipment configuration JSON',
        }
      }
    }

    const data = createGateSchema.parse({
      tenant_id: formData.get('tenant_id'),
      name: formData.get('name'),
      location: formData.get('location') || undefined,
      gate_type: formData.get('gate_type') || undefined,
      operational_status:
        (formData.get('operational_status') as 'active' | 'maintenance' | 'inactive') || 'active',
      equipment_config: equipmentConfig || undefined,
      description: formData.get('description') || undefined,
    })

    const { data: gate, error } = await supabase
      .from('gates')
      .insert([data])
      .select()
      .single()

    if (error) {
      console.error('Error creating gate:', error)
      return {
        success: false,
        error: error.message,
      }
    }

    revalidatePath(`/tenants/${data.tenant_id}/gates`)

    return {
      success: true,
      data: gate,
    }
  } catch (error) {
    console.error('Error in createGate:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to create gate',
    }
  }
}

export async function updateGate(formData: FormData) {
  try {
    await requireSuperAdmin()

    const supabase = await createClient()

    // Parse equipment config JSON if provided
    let equipmentConfig = undefined
    const equipmentConfigStr = formData.get('equipment_config')
    if (equipmentConfigStr && equipmentConfigStr !== '') {
      try {
        equipmentConfig = JSON.parse(equipmentConfigStr as string)
      } catch (e) {
        return {
          success: false,
          error: 'Invalid equipment configuration JSON',
        }
      }
    }

    const data = updateGateSchema.parse({
      id: formData.get('id'),
      tenant_id: formData.get('tenant_id') || undefined,
      name: formData.get('name') || undefined,
      location: formData.get('location') || undefined,
      gate_type: formData.get('gate_type') || undefined,
      operational_status: formData.get('operational_status') || undefined,
      equipment_config: equipmentConfig,
      description: formData.get('description') || undefined,
    })

    const { id, ...updateData } = data

    const { data: gate, error } = await supabase
      .from('gates')
      .update(updateData)
      .eq('id', id)
      .select()
      .single()

    if (error) {
      console.error('Error updating gate:', error)
      return {
        success: false,
        error: error.message,
      }
    }

    revalidatePath(`/tenants/${gate.tenant_id}/gates`)

    return {
      success: true,
      data: gate,
    }
  } catch (error) {
    console.error('Error in updateGate:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to update gate',
    }
  }
}

export async function deleteGate(gateId: string) {
  try {
    await requireSuperAdmin()

    const supabase = await createClient()

    const { error } = await supabase
      .from('gates')
      .delete()
      .eq('id', gateId)

    if (error) {
      console.error('Error deleting gate:', error)
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
    console.error('Error in deleteGate:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to delete gate',
    }
  }
}

export async function getGates(tenantId: string) {
  try {
    const supabase = await createClient()

    const { data: gates, error } = await supabase
      .from('gates')
      .select('*')
      .eq('tenant_id', tenantId)
      .order('name')

    if (error) {
      console.error('Error fetching gates:', error)
      return []
    }

    return gates || []
  } catch (error) {
    console.error('Error in getGates:', error)
    return []
  }
}

export async function getGate(gateId: string) {
  try {
    const supabase = await createClient()

    const { data: gate, error } = await supabase
      .from('gates')
      .select('*')
      .eq('id', gateId)
      .single()

    if (error) {
      console.error('Error fetching gate:', error)
      return { success: false, error: error.message }
    }

    return { success: true, data: gate }
  } catch (error) {
    console.error('Error in getGate:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to fetch gate',
    }
  }
}
