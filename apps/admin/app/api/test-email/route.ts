import { NextResponse } from 'next/server'
import emailService from '@/lib/email/resend-service'

export async function POST(request: Request) {
  try {
    const { to, subject, testType } = await request.json()

    if (!to || !subject) {
      return NextResponse.json({
        success: false,
        error: 'Missing required fields: to, subject',
      }, { status: 400 })
    }

    const testEmails = {
      welcome: {
        subject: '🎉 Test: Welcome to Village Tech Community',
        html: `
          <h2>Test Email - Welcome</h2>
          <p>This is a test welcome email from Village Tech Community.</p>
          <p><strong>Recipient:</strong> ${to}</p>
          <p><strong>Test Type:</strong> Welcome Email</p>
          <p><strong>Sent at:</strong> ${new Date().toLocaleString()}</p>
          <hr>
          <p><em>This is a test email. If you received this, your email service is working correctly!</em></p>
        `,
        text: `Test Email - Welcome\n\nThis is a test welcome email from Village Tech Community.\n\nRecipient: ${to}\nTest Type: Welcome Email\nSent at: ${new Date().toLocaleString()}\n\n---\nThis is a test email. If you received this, your email service is working correctly!`,
      },
      sticker: {
        subject: '🚗 Test: Vehicle Sticker Request Approved',
        html: `
          <h2>Test Email - Sticker Approval</h2>
          <p>This is a test sticker approval email from Village Tech Community.</p>
          <p><strong>Recipient:</strong> ${to}</p>
          <p><strong>Test Type:</strong> Sticker Approval</p>
          <p><strong>Vehicle Plate:</strong> TEST-123</p>
          <p><strong>Sent at:</strong> ${new Date().toLocaleString()}</p>
          <hr>
          <p><em>This is a test email. If you received this, your email service is working correctly!</em></p>
        `,
        text: `Test Email - Sticker Approval\n\nThis is a test sticker approval email from Village Tech Community.\n\nRecipient: ${to}\nTest Type: Sticker Approval\nVehicle Plate: TEST-123\nSent at: ${new Date().toLocaleString()}\n\n---\nThis is a test email. If you received this, your email service is working correctly!`,
      },
      custom: {
        subject: subject,
        html: `
          <h2>Test Email - Custom</h2>
          <p>This is a custom test email from Village Tech Community.</p>
          <p><strong>Recipient:</strong> ${to}</p>
          <p><strong>Subject:</strong> ${subject}</p>
          <p><strong>Sent at:</strong> ${new Date().toLocaleString()}</p>
          <hr>
          <p><em>This is a test email. If you received this, your email service is working correctly!</em></p>
        `,
        text: `Test Email - Custom\n\nThis is a custom test email from Village Tech Community.\n\nRecipient: ${to}\nSubject: ${subject}\nSent at: ${new Date().toLocaleString()}\n\n---\nThis is a test email. If you received this, your email service is working correctly!`,
      },
    }

    const emailContent = testEmails[testType] || testEmails.custom

    const result = await emailService.sendEmail({
      to,
      subject: emailContent.subject,
      html: emailContent.html,
      text: emailContent.text,
    })

    if (result.success) {
      return NextResponse.json({
        success: true,
        data: {
          messageId: result.messageId,
          to,
          subject: emailContent.subject,
          testType,
          sentAt: new Date().toISOString(),
          environment: process.env.NODE_ENV || 'development',
          mockMode: !emailService.isConfigured(),
        },
      })
    } else {
      return NextResponse.json({
        success: false,
        error: result.error,
      }, { status: 500 })
    }
  } catch (error) {
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error',
    }, { status: 500 })
  }
}

// Also support GET requests for easy testing
export async function GET() {
  const testEmail = {
    to: 'test@example.com',
    subject: 'Test Email from Village Tech',
    testType: 'welcome',
  }

  return NextResponse.json({
    message: 'Use POST request to send test email',
    example: {
      url: '/api/test-email',
      method: 'POST',
      body: testEmail,
      curl: `curl -X POST http://localhost:3001/api/test-email -H "Content-Type: application/json" -d '${JSON.stringify(testEmail)}'`,
    },
  })
}