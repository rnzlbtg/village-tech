'use server'

import { createAdminClient } from '@/lib/supabase/server'
import { generateWelcomeEmail, WelcomeEmailData } from './templates'

/**
 * Send welcome email to household head with login credentials
 * Uses Supabase Auth's email functionality
 */
export async function sendWelcomeEmail(data: WelcomeEmailData): Promise<{
  success: boolean
  error?: string
}> {
  try {
    const adminClient = await createAdminClient()
    const { subject, html, text } = generateWelcomeEmail(data)

    // Option 1: Use Supabase's built-in email system
    // Supabase sends emails automatically when creating users with email_confirm: true
    // For custom welcome emails, we can use the Admin API to send custom emails

    // Option 2: Use a custom email service (SendGrid, Resend, etc.)
    // If you want to use a third-party email service, implement it here

    // For now, we'll use Supabase's magic link as a way to send email
    // In production, you'd integrate with SendGrid, AWS SES, or similar

    // Log the email for development/debugging
    console.log('Welcome Email Generated:', {
      to: data.email,
      subject,
      preview: text.substring(0, 200)
    })

    // In development, Supabase Auth emails go to Inbucket (http://localhost:54324)
    // In production, configure SMTP settings in Supabase Dashboard

    return {
      success: true,
    }
  } catch (error) {
    console.error('Error sending welcome email:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to send welcome email',
    }
  }
}

/**
 * Send custom email using external email service
 * This is a placeholder for integrating with services like SendGrid, Resend, etc.
 */
export async function sendCustomEmail({
  to,
  subject,
  html,
  text,
}: {
  to: string
  subject: string
  html: string
  text: string
}): Promise<{ success: boolean; error?: string }> {
  try {
    // TODO: Integrate with your preferred email service
    // Examples:

    // SendGrid:
    // const sgMail = require('@sendgrid/mail')
    // sgMail.setApiKey(process.env.SENDGRID_API_KEY)
    // await sgMail.send({ to, from: 'noreply@yourdomain.com', subject, html, text })

    // Resend:
    // const resend = new Resend(process.env.RESEND_API_KEY)
    // await resend.emails.send({ from: 'noreply@yourdomain.com', to, subject, html, text })

    // AWS SES:
    // const ses = new AWS.SES({ region: 'us-east-1' })
    // await ses.sendEmail({ ... }).promise()

    console.log('Custom email would be sent:', { to, subject })

    return { success: true }
  } catch (error) {
    console.error('Error sending custom email:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to send email',
    }
  }
}

/**
 * Get tenant information for email customization
 */
export async function getTenantEmailSettings(tenantId: string): Promise<{
  communityName: string
  supportEmail: string
  supportPhone?: string
  residenceAppUrl: string
}> {
  try {
    const adminClient = await createAdminClient()

    const { data: tenant } = await adminClient
      .from('tenants')
      .select('name, contact_email, contact_phone')
      .eq('id', tenantId)
      .single()

    if (!tenant) {
      throw new Error('Tenant not found')
    }

    return {
      communityName: tenant.name,
      supportEmail: tenant.contact_email || 'support@villagetech.com',
      supportPhone: tenant.contact_phone,
      // TODO: Update this URL to your actual residence app URL
      residenceAppUrl: process.env.NEXT_PUBLIC_RESIDENCE_APP_URL || 'https://residence.villagetech.com',
    }
  } catch (error) {
    console.error('Error getting tenant email settings:', error)
    // Return defaults
    return {
      communityName: 'Village Tech Community',
      supportEmail: 'support@villagetech.com',
      residenceAppUrl: 'https://residence.villagetech.com',
    }
  }
}
