'use server'

import { createClient } from '@/lib/supabase/server'
import { updateAssociationSettingsSchema } from '@/lib/validations/association-settings'
import { revalidatePath } from 'next/cache'

export async function getAssociationSettings(tenantId: string) {
  try {
    const supabase = await createClient()

    const { data, error } = await supabase
      .from('association_settings')
      .select('*')
      .eq('tenant_id', tenantId)
      .single()

    if (error) {
      // If no settings exist yet, return default structure
      if (error.code === 'PGRST116') {
        return {
          success: true,
          data: {
            tenant_id: tenantId,
            settings: {
              general: {},
              billing: {},
              notifications: {},
              security: {},
            },
          },
        }
      }
      console.error('Error fetching association settings:', error)
      return { success: false, error: error.message }
    }

    return { success: true, data }
  } catch (error) {
    console.error('Error in getAssociationSettings:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to fetch association settings',
    }
  }
}

export async function updateAssociationSettings(formData: FormData) {
  try {
    const supabase = await createClient()

    // Parse settings JSON from form
    const settingsStr = formData.get('settings')
    if (!settingsStr) {
      return {
        success: false,
        error: 'Settings data is required',
      }
    }

    let settings
    try {
      settings = JSON.parse(settingsStr as string)
    } catch (e) {
      return {
        success: false,
        error: 'Invalid settings JSON format',
      }
    }

    const data = updateAssociationSettingsSchema.parse({
      tenant_id: formData.get('tenant_id'),
      settings,
    })

    // Check if settings already exist
    const { data: existing } = await supabase
      .from('association_settings')
      .select('id')
      .eq('tenant_id', data.tenant_id)
      .single()

    let result

    if (existing) {
      // Update existing settings
      const { data: updated, error } = await supabase
        .from('association_settings')
        .update({ settings: data.settings })
        .eq('tenant_id', data.tenant_id)
        .select()
        .single()

      if (error) {
        console.error('Error updating association settings:', error)
        return {
          success: false,
          error: error.message,
        }
      }

      result = updated
    } else {
      // Create new settings
      const { data: created, error } = await supabase
        .from('association_settings')
        .insert([
          {
            tenant_id: data.tenant_id,
            settings: data.settings,
          },
        ])
        .select()
        .single()

      if (error) {
        console.error('Error creating association settings:', error)
        return {
          success: false,
          error: error.message,
        }
      }

      result = created
    }

    revalidatePath(`/tenants/${data.tenant_id}/settings`)

    return {
      success: true,
      data: result,
    }
  } catch (error) {
    console.error('Error in updateAssociationSettings:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to update association settings',
    }
  }
}
