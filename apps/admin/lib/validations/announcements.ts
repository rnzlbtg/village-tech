import { z } from 'zod'

export const createAnnouncementSchema = z.object({
  title: z.string().min(5, 'Title must be at least 5 characters'),
  content: z.string().min(20, 'Content must be at least 20 characters'),
  priority: z.enum(['normal', 'high', 'urgent']).default('normal'),
  target_audience: z
    .array(z.enum(['residents', 'guards', 'security', 'all']))
    .min(1, 'Select at least one target audience'),
  attachment_urls: z.array(z.string().url()).optional(),
  expires_at: z.string().optional(),
})

export const updateAnnouncementSchema = z.object({
  title: z.string().min(5, 'Title must be at least 5 characters').optional(),
  content: z.string().min(20, 'Content must be at least 20 characters').optional(),
  priority: z.enum(['normal', 'high', 'urgent']).optional(),
  target_audience: z
    .array(z.enum(['residents', 'guards', 'security', 'all']))
    .min(1)
    .optional(),
  attachment_urls: z.array(z.string().url()).optional(),
  expires_at: z.string().optional(),
})

export type CreateAnnouncementInput = z.infer<typeof createAnnouncementSchema>
export type UpdateAnnouncementInput = z.infer<typeof updateAnnouncementSchema>
