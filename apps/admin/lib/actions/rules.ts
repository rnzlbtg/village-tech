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
    const userId = await getUserId()

    const data = createVillageRulesSchema.parse(input)

    // Create village rules in association_settings or a dedicated village_rules table
    // For MVP, store in association_settings as JSONB
    const rulesData = {
      title: data.title,
      content: data.content,
      effective_date: data.effective_date,
      category: data.category || 'general',
      version: 1,
      created_by: userId,
      created_at: new Date().toISOString(),
      published: false,
    }

    // Get existing settings
    const { data: settings, error: settingsError } = await supabase
      .from('association_settings')
      .select('village_rules')
      .eq('tenant_id', tenantId)
      .single()

    const existingRules = settings?.village_rules || []
    const newRulesArray = [...existingRules, { id: crypto.randomUUID(), ...rulesData }]

    // Update settings with new rules
    const { error } = await supabase
      .from('association_settings')
      .upsert(
        {
          tenant_id: tenantId,
          village_rules: newRulesArray,
          updated_at: new Date().toISOString(),
        },
        { onConflict: 'tenant_id' }
      )

    if (error) {
      console.error('Error creating village rules:', error)
      return { success: false, error: error.message }
    }

    revalidatePath('/rules')

    return {
      success: true,
      message: 'Village rules created successfully',
      data: { id: newRulesArray[newRulesArray.length - 1].id },
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

    // Get existing rules
    const { data: settings, error: settingsError } = await supabase
      .from('association_settings')
      .select('village_rules')
      .eq('tenant_id', tenantId)
      .single()

    if (settingsError || !settings) {
      return { success: false, error: 'Village rules not found' }
    }

    const existingRules = settings.village_rules || []
    const ruleIndex = existingRules.findIndex((rule: any) => rule.id === data.rules_id)

    if (ruleIndex === -1) {
      return { success: false, error: 'Rule not found' }
    }

    // Update the rule
    const updatedRule = {
      ...existingRules[ruleIndex],
      ...(data.title && { title: data.title }),
      ...(data.content && { content: data.content }),
      ...(data.effective_date && { effective_date: data.effective_date }),
      ...(data.category && { category: data.category }),
      version: existingRules[ruleIndex].version + 1,
      updated_at: new Date().toISOString(),
    }

    existingRules[ruleIndex] = updatedRule

    // Save updated rules
    const { error } = await supabase
      .from('association_settings')
      .update({
        village_rules: existingRules,
        updated_at: new Date().toISOString(),
      })
      .eq('tenant_id', tenantId)

    if (error) {
      return { success: false, error: 'Failed to update village rules' }
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

    const data = setCurfewTimesSchema.parse(input)

    // Store curfew in association_settings
    const { error } = await supabase
      .from('association_settings')
      .upsert(
        {
          tenant_id: tenantId,
          curfew_settings: {
            start_time: data.start_time,
            end_time: data.end_time,
            days_of_week: data.days_of_week,
            affected_gates: data.affected_gates || [],
            active: data.active !== false,
            updated_at: new Date().toISOString(),
          },
          updated_at: new Date().toISOString(),
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

    const data = publishRulesSchema.parse(input)

    // Get existing rules
    const { data: settings, error: settingsError } = await supabase
      .from('association_settings')
      .select('village_rules')
      .eq('tenant_id', tenantId)
      .single()

    if (settingsError || !settings) {
      return { success: false, error: 'Village rules not found' }
    }

    const existingRules = settings.village_rules || []
    const ruleIndex = existingRules.findIndex((rule: any) => rule.id === data.rules_id)

    if (ruleIndex === -1) {
      return { success: false, error: 'Rule not found' }
    }

    // Mark rule as published
    existingRules[ruleIndex].published = true
    existingRules[ruleIndex].published_at = new Date().toISOString()

    // Save updated rules
    const { error } = await supabase
      .from('association_settings')
      .update({
        village_rules: existingRules,
        updated_at: new Date().toISOString(),
      })
      .eq('tenant_id', tenantId)

    if (error) {
      return { success: false, error: 'Failed to publish rules' }
    }

    // T108: Notify residents when new rules are published
    if (data.notify_residents !== false) {
      console.log('📢 Notification - Rules Published to Residents:', {
        rules_id: data.rules_id,
        title: existingRules[ruleIndex].title,
      })
    }

    // Notify guards
    if (data.notify_guards !== false) {
      console.log('📢 Notification - Rules Published to Guards:', {
        rules_id: data.rules_id,
        title: existingRules[ruleIndex].title,
      })
    }

    // T110: Create announcement linking rules publication
    const { error: announcementError } = await supabase.from('announcements').insert({
      tenant_id: tenantId,
      title: `New Village Rules: ${existingRules[ruleIndex].title}`,
      content: `New village rules have been published. Please review the updated community guidelines.`,
      priority: 'high',
      target_audience: ['residents', 'guards', 'security'],
      published_at: new Date().toISOString(),
      active: true,
      created_by: await getUserId(),
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
