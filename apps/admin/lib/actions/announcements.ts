'use server'

import { revalidatePath } from 'next/cache'
import { createClient } from '@/lib/supabase/server'
import { getTenantId, getUserId, requireAdmin } from '@/lib/auth/helpers'
import {
  createAnnouncementSchema,
  editAnnouncementSchema,
  deleteAnnouncementSchema,
  type CreateAnnouncementInput,
  type EditAnnouncementInput,
  type DeleteAnnouncementInput,
} from '@/lib/validations/announcements'

/**
 * T071: Create announcement with file upload integration
 */
export async function createAnnouncement(input: CreateAnnouncementInput) {
  try {
    await requireAdmin()
    const supabase = await createClient()
    const tenantId = await getTenantId()
    const userId = await getUserId()

    const data = createAnnouncementSchema.parse(input)

    // Create announcement
    const { data: announcement, error } = await supabase
      .from('announcements')
      .insert({
        tenant_id: tenantId,
        title: data.title,
        content: data.content,
        priority: data.priority || 'normal',
        target_audience: data.target_audience,
        attachment_urls: data.attachment_urls || [],
        expires_at: data.expires_at,
        published_by: userId,
        published_at: new Date().toISOString(),
        is_published: true,
      })
      .select()
      .single()

    if (error) {
      console.error('Error creating announcement:', error)
      return { success: false, error: error.message }
    }

    // T081: Send push notifications for urgent announcements
    if (data.priority === 'urgent') {
      console.log('📢 Urgent Announcement - Push Notifications:', {
        announcement_id: announcement.id,
        target_audience: data.target_audience,
        title: data.title,
      })
      // TODO: Integrate with Firebase Cloud Messaging or similar service
    }

    revalidatePath('/announcements')

    return {
      success: true,
      data: announcement,
      message: 'Announcement created successfully',
    }
  } catch (error) {
    console.error('Error in createAnnouncement:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to create announcement',
    }
  }
}

/**
 * T072: Edit announcement
 */
export async function editAnnouncement(input: EditAnnouncementInput) {
  try {
    await requireAdmin()
    const supabase = await createClient()
    const tenantId = await getTenantId()

    const data = editAnnouncementSchema.parse(input)

    // Verify announcement belongs to tenant
    const { data: existing, error: checkError } = await supabase
      .from('announcements')
      .select('id')
      .eq('id', data.announcement_id)
      .eq('tenant_id', tenantId)
      .single()

    if (checkError || !existing) {
      return { success: false, error: 'Announcement not found' }
    }

    // Update announcement
    const updateData: any = {}
    if (data.title !== undefined) updateData.title = data.title
    if (data.content !== undefined) updateData.content = data.content
    if (data.priority !== undefined) updateData.priority = data.priority
    if (data.target_audience !== undefined) updateData.target_audience = data.target_audience
    if (data.attachment_urls !== undefined) updateData.attachment_urls = data.attachment_urls
    if (data.expires_at !== undefined) updateData.expires_at = data.expires_at

    const { error: updateError } = await supabase
      .from('announcements')
      .update(updateData)
      .eq('id', data.announcement_id)

    if (updateError) {
      return { success: false, error: 'Failed to update announcement' }
    }

    revalidatePath('/announcements')

    return {
      success: true,
      message: 'Announcement updated successfully',
    }
  } catch (error) {
    console.error('Error in editAnnouncement:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to edit announcement',
    }
  }
}

/**
 * T073: Delete announcement (soft delete)
 */
export async function deleteAnnouncement(input: DeleteAnnouncementInput) {
  try {
    await requireAdmin()
    const supabase = await createClient()
    const tenantId = await getTenantId()

    const data = deleteAnnouncementSchema.parse(input)

    // Verify announcement belongs to tenant
    const { data: existing, error: checkError } = await supabase
      .from('announcements')
      .select('id')
      .eq('id', data.announcement_id)
      .eq('tenant_id', tenantId)
      .single()

    if (checkError || !existing) {
      return { success: false, error: 'Announcement not found' }
    }

    // Soft delete by setting is_published to false
    const { error: deleteError } = await supabase
      .from('announcements')
      .update({ is_published: false })
      .eq('id', data.announcement_id)

    if (deleteError) {
      return { success: false, error: 'Failed to delete announcement' }
    }

    revalidatePath('/announcements')

    return {
      success: true,
      message: 'Announcement deleted successfully',
    }
  } catch (error) {
    console.error('Error in deleteAnnouncement:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to delete announcement',
    }
  }
}

/**
 * Upload announcement file to Supabase Storage (T083)
 */
export async function uploadAnnouncementFile(file: File) {
  try {
    await requireAdmin()
    const supabase = await createClient()
    const tenantId = await getTenantId()

    // Validate file type
    const allowedTypes = ['application/pdf', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'image/jpeg', 'image/png']
    if (!allowedTypes.includes(file.type)) {
      return {
        success: false,
        error: 'Invalid file type. Only PDF, DOCX, JPEG, and PNG are allowed.',
      }
    }

    // Validate file size (10MB)
    if (file.size > 10 * 1024 * 1024) {
      return {
        success: false,
        error: 'File size must be less than 10MB',
      }
    }

    // Generate file path: tenant_id/announcements/timestamp-filename
    const timestamp = Date.now()
    const filePath = `${tenantId}/announcements/${timestamp}-${file.name}`

    // Upload to Supabase Storage
    const { data, error } = await supabase.storage
      .from('announcement-files')
      .upload(filePath, file)

    if (error) {
      console.error('File upload error:', error)
      return { success: false, error: 'Failed to upload file' }
    }

    // Get public URL
    const {
      data: { publicUrl },
    } = supabase.storage.from('announcement-files').getPublicUrl(filePath)

    return {
      success: true,
      file_url: publicUrl,
      file_path: filePath,
    }
  } catch (error) {
    console.error('Error in uploadAnnouncementFile:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to upload file',
    }
  }
}
