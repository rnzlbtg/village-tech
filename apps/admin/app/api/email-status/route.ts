import { NextResponse } from 'next/server'
import emailService from '@/lib/email/resend-service'

export async function GET() {
  try {
    const status = emailService.getStatus()

    return NextResponse.json({
      success: true,
      data: {
        ...status,
        service: 'Resend',
        documentation: 'https://resend.com/docs',
        setupInstructions: {
          step1: 'Create a Resend account at https://resend.com',
          step2: 'Get your API key from the dashboard',
          step3: 'Add and verify your domain',
          step4: 'Set RESEND_API_KEY and EMAIL_FROM in .env.local',
          step5: 'Restart the development server',
        },
        environmentVariables: {
          RESEND_API_KEY: status.hasApiKey ? '✅ Set' : '❌ Missing',
          EMAIL_FROM: status.hasFromEmail ? '✅ Set' : '❌ Missing',
        },
        testCommand: 'curl http://localhost:3001/api/email-status',
      }
    })
  } catch (error) {
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error',
    }, { status: 500 })
  }
}