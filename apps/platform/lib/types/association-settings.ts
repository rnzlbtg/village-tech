export interface GeneralSettings {
  association_name?: string
  operating_hours?: {
    start?: string
    end?: string
  }
  timezone?: string
  language?: string
}

export interface BillingSettings {
  currency?: string
  payment_methods?: string[]
  billing_cycle?: 'monthly' | 'quarterly' | 'annually'
  due_day?: number
  late_fee_percentage?: number
  grace_period_days?: number
}

export interface NotificationSettings {
  email_enabled?: boolean
  sms_enabled?: boolean
  push_enabled?: boolean
  notification_channels?: {
    billing?: Array<'email' | 'sms' | 'push'>
    announcements?: Array<'email' | 'sms' | 'push'>
    emergencies?: Array<'email' | 'sms' | 'push'>
  }
}

export interface SecuritySettings {
  two_factor_required?: boolean
  session_timeout_minutes?: number
  password_expiry_days?: number
  max_login_attempts?: number
}

export interface AssociationSettings {
  id: string
  tenant_id: string
  settings: {
    general?: GeneralSettings
    billing?: BillingSettings
    notifications?: NotificationSettings
    security?: SecuritySettings
  }
  created_at: string
  updated_at: string
}

export type SettingsCategory = 'general' | 'billing' | 'notifications' | 'security'
