import { z } from 'zod'

// Association settings categories
export const settingsCategorySchema = z.enum(['general', 'billing', 'notifications', 'security'])

// General settings schema
const generalSettingsSchema = z.object({
  association_name: z.string().min(3, 'Association name must be at least 3 characters').max(255).optional(),
  operating_hours: z.object({
    start: z.string().regex(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/, 'Invalid time format (HH:MM)').optional(),
    end: z.string().regex(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/, 'Invalid time format (HH:MM)').optional(),
  }).optional(),
  timezone: z.string().optional(),
  language: z.string().optional(),
}).optional()

// Billing settings schema
const billingSettingsSchema = z.object({
  currency: z.string().length(3, 'Currency must be 3-letter code (e.g., PHP, USD)').optional(),
  payment_methods: z.array(z.string()).optional(),
  billing_cycle: z.enum(['monthly', 'quarterly', 'annually']).optional(),
  due_day: z.number().int().min(1).max(31).optional(),
  late_fee_percentage: z.number().min(0).max(100).optional(),
  grace_period_days: z.number().int().min(0).max(90).optional(),
}).optional()

// Notification settings schema
const notificationSettingsSchema = z.object({
  email_enabled: z.boolean().optional(),
  sms_enabled: z.boolean().optional(),
  push_enabled: z.boolean().optional(),
  notification_channels: z.object({
    billing: z.array(z.enum(['email', 'sms', 'push'])).optional(),
    announcements: z.array(z.enum(['email', 'sms', 'push'])).optional(),
    emergencies: z.array(z.enum(['email', 'sms', 'push'])).optional(),
  }).optional(),
}).optional()

// Security settings schema
const securitySettingsSchema = z.object({
  two_factor_required: z.boolean().optional(),
  session_timeout_minutes: z.number().int().min(5).max(1440).optional(),
  password_expiry_days: z.number().int().min(0).max(365).optional(),
  max_login_attempts: z.number().int().min(3).max(10).optional(),
}).optional()

// Complete settings object schema
export const settingsValueSchema = z.object({
  general: generalSettingsSchema,
  billing: billingSettingsSchema,
  notifications: notificationSettingsSchema,
  security: securitySettingsSchema,
})

// Update association settings schema
export const updateAssociationSettingsSchema = z.object({
  tenant_id: z.string().uuid('Invalid tenant ID'),
  settings: settingsValueSchema,
})

export type SettingsCategory = z.infer<typeof settingsCategorySchema>
export type SettingsValue = z.infer<typeof settingsValueSchema>
export type UpdateAssociationSettingsInput = z.infer<typeof updateAssociationSettingsSchema>
