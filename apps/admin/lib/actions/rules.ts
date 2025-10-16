'use server'

import { revalidatePath } from 'next/cache'
import { createClient } from '@/lib/supabase/server'
import { getTenantId, getUserId, requireAdmin } from '@/lib/auth/helpers'
import { z } from 'zod'

const createVillageRulesSchema = z.object({
  title: z.string().min(3, 'Title is required'),
  content: z.string().min(50, 'Rules content must be at least 50 characters'),
  effective_date: z.string(),
  category: z.enum(['general', 'security', 'construction', 'parking', 'noise', 'pets', 'other']).optional(),
})

const updateVillageRulesSchema = z.object({
  rules_id: z.string().uuid(),
  title: z.string().min(3).optional(),
  content: z.string().min(50).optional(),
  effective_date: z.string().optional(),
  category: z.string().optional(),
})

const setCurfewTimesSchema = z.object({
  start_time: z.string(), // HH:MM format
  end_time: z.string(),
  days_of_week: z.array(z.enum(['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'])),
  affected_gates: z.array(z.string().uuid()).optional(),
  active: z.boolean().optional(),
})

const publishRulesSchema = z.object({
  rules_id: z.string().uuid(),
  notify_residents: z.boolean().optional(),
  notify_guards: z.boolean().optional(),
})

export type CreateVillageRulesInput = z.infer<typeof createVillageRulesSchema>
export type UpdateVillageRulesInput = z.infer<typeof updateVillageRulesSchema>
export type SetCurfewTimesInput = z.infer<typeof setCurfewTimesSchema>
export type PublishRulesInput = z.infer<typeof publishRulesSchema>

/**
 * T100: Create village rules with effective dates
 */
export async function createVillageRules(input: CreateVillageRulesInput) {
  try {
    await requireAdmin()
    const supabase = await createClient()
    const tenantId = await getTenantId()

    const data = createVillageRulesSchema.parse(input)

    // Create village rule in the dedicated village_rules table
    const { data: rule, error } = await supabase
      .from('village_rules')
      .insert({
        tenant_id: tenantId,
        rule_category: data.category || 'general',
        title: data.title,
        description: data.content,
        effective_date: data.effective_date,
        is_active: true,
        published: false,
        version: 1,
        display_order: 0,
      })
      .select()
      .single()

    if (error) {
      console.error('Error creating village rules:', error)
      return { success: false, error: error.message }
    }

    revalidatePath('/rules')

    return {
      success: true,
      message: 'Village rules created successfully',
      data: { id: rule.id },
    }
  } catch (error) {
    console.error('Error in createVillageRules:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to create village rules',
    }
  }
}

/**
 * T101: Update village rules for revisions
 */
export async function updateVillageRules(input: UpdateVillageRulesInput) {
  try {
    await requireAdmin()
    const supabase = await createClient()
    const tenantId = await getTenantId()

    const data = updateVillageRulesSchema.parse(input)

    // Update the rule in the village_rules table
    const updateData: any = {}
    if (data.title) updateData.title = data.title
    if (data.content) updateData.description = data.content
    if (data.effective_date) updateData.effective_date = data.effective_date
    if (data.category) updateData.rule_category = data.category

    const { error } = await supabase
      .from('village_rules')
      .update(updateData)
      .eq('id', data.rules_id)
      .eq('tenant_id', tenantId)

    if (error) {
      console.error('Error updating village rules:', error)
      return { success: false, error: error.message }
    }

    revalidatePath('/rules')

    return {
      success: true,
      message: 'Village rules updated successfully',
    }
  } catch (error) {
    console.error('Error in updateVillageRules:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to update village rules',
    }
  }
}

/**
 * T102: Set curfew times for gate access restrictions
 */
export async function setCurfewTimes(input: SetCurfewTimesInput) {
  try {
    await requireAdmin()
    const supabase = await createClient()
    const tenantId = await getTenantId()
    const userId = await getUserId()

    const data = setCurfewTimesSchema.parse(input)

    // Store curfew in the dedicated curfew_settings table
    const { error } = await supabase
      .from('curfew_settings')
      .upsert(
        {
          tenant_id: tenantId,
          start_time: data.start_time,
          end_time: data.end_time,
          days_of_week: data.days_of_week,
          active: data.active !== false,
          updated_by: userId,
        },
        { onConflict: 'tenant_id' }
      )

    if (error) {
      console.error('Error setting curfew times:', error)
      return { success: false, error: error.message }
    }

    // T109: Notify guard house when curfew times are updated
    console.log('📢 Guard House Notification - Curfew Updated:', {
      start_time: data.start_time,
      end_time: data.end_time,
      days_of_week: data.days_of_week,
    })

    revalidatePath('/rules')

    return {
      success: true,
      message: 'Curfew times configured successfully',
    }
  } catch (error) {
    console.error('Error in setCurfewTimes:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to set curfew times',
    }
  }
}

/**
 * T103: Publish rules to distribute to all user groups
 */
export async function publishRules(input: PublishRulesInput) {
  try {
    await requireAdmin()
    const supabase = await createClient()
    const tenantId = await getTenantId()
    const userId = await getUserId()

    const data = publishRulesSchema.parse(input)

    // Get the rule to publish
    const { data: rule, error: fetchError } = await supabase
      .from('village_rules')
      .select('*')
      .eq('id', data.rules_id)
      .eq('tenant_id', tenantId)
      .single()

    if (fetchError || !rule) {
      return { success: false, error: 'Rule not found' }
    }

    // Mark rule as published
    const { error } = await supabase
      .from('village_rules')
      .update({
        published: true,
        published_at: new Date().toISOString(),
        published_by: userId,
      })
      .eq('id', data.rules_id)
      .eq('tenant_id', tenantId)

    if (error) {
      console.error('Error publishing rules:', error)
      return { success: false, error: error.message }
    }

    // T108: Notify residents when new rules are published
    if (data.notify_residents !== false) {
      console.log('📢 Notification - Rules Published to Residents:', {
        rules_id: data.rules_id,
        title: rule.title,
      })
    }

    // Notify guards
    if (data.notify_guards !== false) {
      console.log('📢 Notification - Rules Published to Guards:', {
        rules_id: data.rules_id,
        title: rule.title,
      })
    }

    // T110: Create announcement linking rules publication
    const { error: announcementError } = await supabase.from('announcements').insert({
      tenant_id: tenantId,
      title: `New Village Rules: ${rule.title}`,
      content: `New village rules have been published. Please review the updated community guidelines.`,
      priority: 'high',
      target_audience: ['residents', 'guards', 'security'],
      published_at: new Date().toISOString(),
      is_published: true,
      published_by: userId,
    })

    if (announcementError) {
      console.error('Failed to create announcement:', announcementError)
    }

    revalidatePath('/rules')
    revalidatePath('/announcements')

    return {
      success: true,
      message: 'Village rules published successfully',
    }
  } catch (error) {
    console.error('Error in publishRules:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to publish rules',
    }
  }
}

/**
 * Get village rules for display
 */
export async function getVillageRules() {
  try {
    await requireAdmin()
    const supabase = await createClient()
    const tenantId = await getTenantId()

    // Get rules from the village_rules table
    const { data: rules, error } = await supabase
      .from('village_rules')
      .select('*')
      .eq('tenant_id', tenantId)
      .order('display_order', { ascending: true })
      .order('created_at', { ascending: false })

    if (error) {
      console.error('Error fetching village rules:', error)
      return { success: false, error: error.message }
    }

    // Transform the data to match the expected format for the UI
    const transformedRules = rules?.map(rule => ({
      id: rule.id,
      title: rule.title,
      content: rule.description,
      category: rule.rule_category,
      effective_date: rule.effective_date,
      published: rule.published,
      published_at: rule.published_at,
      version: rule.version,
      is_active: rule.is_active,
      created_at: rule.created_at,
      updated_at: rule.updated_at,
    })) || []

    return { success: true, data: transformedRules }
  } catch (error) {
    console.error('Error in getVillageRules:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to fetch village rules',
    }
  }
}

/**
 * Get curfew settings for display
 */
export async function getCurfewSettings() {
  try {
    await requireAdmin()
    const supabase = await createClient()
    const tenantId = await getTenantId()

    // Get curfew settings from the dedicated curfew_settings table
    const { data: settings, error } = await supabase
      .from('curfew_settings')
      .select('*')
      .eq('tenant_id', tenantId)
      .single()

    if (error) {
      if (error.code === 'PGRST116') {
        // No settings found yet, return null
        return { success: true, data: null }
      }
      console.error('Error fetching curfew settings:', error)
      return { success: false, error: error.message }
    }

    // Transform the data to match the expected format for the UI
    const transformedSettings = settings ? {
      start_time: settings.start_time,
      end_time: settings.end_time,
      days_of_week: settings.days_of_week,
      active: settings.active,
      grace_period_minutes: settings.grace_period_minutes,
      notification_advance_minutes: settings.notification_advance_minutes,
      updated_at: settings.updated_at,
    } : null

    return { success: true, data: transformedSettings }
  } catch (error) {
    console.error('Error in getCurfewSettings:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to fetch curfew settings',
    }
  }
}
