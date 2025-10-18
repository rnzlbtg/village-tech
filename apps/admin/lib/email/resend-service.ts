import { Resend } from 'resend'

export type EmailMessage = {
  to: string | string[]
  subject: string
  html: string
  text?: string
  from?: string
  replyTo?: string
}

/**
 * Production email service using Resend
 *
 * To set up:
 * 1. Create a Resend account at https://resend.com
 * 2. Get your API key from the dashboard
 * 3. Add your domain and verify it
 * 4. Set RESEND_API_KEY and EMAIL_FROM in your .env.local
 */
class ResendEmailService {
  private resend: Resend | null = null
  private isInitialized = false

  constructor() {
    this.initialize()
  }

  private initialize() {
    try {
      const apiKey = process.env.RESEND_API_KEY

      if (!apiKey) {
        console.warn('⚠️ RESEND_API_KEY not found in environment variables. Using mock email service.')
        this.isInitialized = false
        return
      }

      this.resend = new Resend(apiKey)
      this.isInitialized = true
      console.log('✅ Resend email service initialized')
    } catch (error) {
      console.error('❌ Failed to initialize Resend service:', error)
      this.isInitialized = false
    }
  }

  /**
   * Send email using Resend (production) or mock (development)
   */
  async sendEmail(message: EmailMessage): Promise<{ success: boolean; error?: string; messageId?: string }> {
    try {
      // Mock sending for development/testing
      if (!this.isInitialized || process.env.NODE_ENV === 'development') {
        return this.sendMockEmail(message)
      }

      // Production sending with Resend
      if (!this.resend) {
        throw new Error('Resend client not initialized')
      }

      const from = message.from || process.env.EMAIL_FROM
      if (!from) {
        throw new Error('EMAIL_FROM not configured in environment variables')
      }

      console.log('📧 Sending email via Resend:', {
        from,
        to: Array.isArray(message.to) ? message.to : [message.to],
        subject: message.subject,
        preview: message.text?.substring(0, 100) || message.html.substring(0, 100),
      })

      const { data, error } = await this.resend.emails.send({
        from,
        to: Array.isArray(message.to) ? message.to : [message.to],
        subject: message.subject,
        html: message.html,
        text: message.text,
        replyTo: message.replyTo,
      })

      if (error) {
        console.error('❌ Resend API error:', error)
        return {
          success: false,
          error: error.message,
        }
      }

      console.log('✅ Email sent successfully:', data?.id)
      return {
        success: true,
        messageId: data?.id,
      }
    } catch (error) {
      console.error('❌ Email sending error:', error)
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
      }
    }
  }

  /**
   * Mock email sending for development
   */
  private sendMockEmail(message: EmailMessage): { success: boolean; error?: string; messageId?: string } {
    console.log('📧 MOCK EMAIL (Development Mode):', {
      to: Array.isArray(message.to) ? message.to : [message.to],
      subject: message.subject,
      from: message.from || process.env.EMAIL_FROM || 'noreply@yourdomain.com',
      preview: message.text?.substring(0, 200) || message.html.substring(0, 200),
      htmlLength: message.html.length,
      textLength: message.text?.length || 0,
    })

    // In development, you can view emails at:
    // - Supabase Inbucket: http://localhost:54324 (if using Supabase local)
    // - MailHog (if configured)
    // - Or just check the console logs

    const mockId = `mock_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`

    return {
      success: true,
      messageId: mockId,
    }
  }

  /**
   * Check if email service is properly configured
   */
  isConfigured(): boolean {
    return this.isInitialized && !!process.env.RESEND_API_KEY && !!process.env.EMAIL_FROM
  }

  /**
   * Get configuration status
   */
  getStatus(): {
    isConfigured: boolean
    hasApiKey: boolean
    hasFromEmail: boolean
    environment: string
  } {
    return {
      isConfigured: this.isConfigured(),
      hasApiKey: !!process.env.RESEND_API_KEY,
      hasFromEmail: !!process.env.EMAIL_FROM,
      environment: process.env.NODE_ENV || 'development',
    }
  }
}

// Singleton instance
const emailService = new ResendEmailService()

export default emailService
export { ResendEmailService }