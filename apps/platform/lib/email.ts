import { Resend } from 'resend'

// Initialize Resend only if API key is available
const resendApiKey = process.env.RESEND_API_KEY
const resend = resendApiKey ? new Resend(resendApiKey) : null

interface AdminWelcomeEmailProps {
  email: string
  firstName: string
  lastName: string
  password: string
  tenantName: string
  adminLoginUrl: string
}

export async function sendAdminWelcomeEmail({
  email,
  firstName,
  lastName,
  password,
  tenantName,
  adminLoginUrl,
}: AdminWelcomeEmailProps) {
  // Check if Resend is configured
  if (!resend) {
    console.error('Resend API key not configured. Please set RESEND_API_KEY in environment variables.')
    return { success: false, error: 'Email service not configured' }
  }

  try {
    const { data, error } = await resend.emails.send({
      from: process.env.RESEND_FROM_EMAIL || 'noreply@village-tech.com',
      to: [email],
      subject: `Welcome to ${tenantName} - Your Admin Account is Ready`,
      html: `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Welcome to ${tenantName}</title>
          <style>
            body {
              font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
              line-height: 1.6;
              color: #333;
              max-width: 600px;
              margin: 0 auto;
              padding: 20px;
            }
            .header {
              background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
              color: white;
              padding: 30px;
              border-radius: 10px 10px 0 0;
              text-align: center;
            }
            .content {
              background: white;
              padding: 30px;
              border-radius: 0 0 10px 10px;
              box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            }
            .credentials {
              background: #f8f9fa;
              border-left: 4px solid #667eea;
              padding: 20px;
              margin: 20px 0;
              border-radius: 5px;
            }
            .btn {
              display: inline-block;
              background: #667eea;
              color: white;
              padding: 12px 24px;
              text-decoration: none;
              border-radius: 5px;
              margin: 20px 0;
            }
            .btn:hover {
              background: #5a6fd8;
            }
            .footer {
              text-align: center;
              margin-top: 30px;
              padding-top: 20px;
              border-top: 1px solid #eee;
              color: #666;
              font-size: 14px;
            }
            .highlight {
              background: #fff3cd;
              border: 1px solid #ffeaa7;
              padding: 15px;
              border-radius: 5px;
              margin: 20px 0;
            }
          </style>
        </head>
        <body>
          <div class="header">
            <h1>Welcome to ${tenantName}</h1>
            <p>Your Administrator Account is Ready</p>
          </div>

          <div class="content">
            <p>Dear ${firstName} ${lastName},</p>

            <p>Congratulations! Your administrator account for <strong>${tenantName}</strong> has been successfully created. You now have full access to manage the residential community through our admin dashboard.</p>

            <div class="highlight">
              <strong>🔐 Important Security Notice:</strong> Please log in immediately and change your temporary password to ensure your account remains secure.
            </div>

            <div class="credentials">
              <h3>Your Login Credentials:</h3>
              <p><strong>Admin Login URL:</strong> <a href="${adminLoginUrl}">${adminLoginUrl}</a></p>
              <p><strong>Email:</strong> ${email}</p>
              <p><strong>Temporary Password:</strong> <code style="background: #e9ecef; padding: 2px 6px; border-radius: 3px;">${password}</code></p>
            </div>

            <a href="${adminLoginUrl}" class="btn">Log In to Admin Dashboard</a>

            <h3>What's Next?</h3>
            <ol>
              <li><strong>Log In:</strong> Use the credentials above to access your admin dashboard</li>
              <li><strong>Change Password:</strong> Update your temporary password immediately</li>
              <li><strong>Complete Your Profile:</strong> Add additional information and preferences</li>
              <li><strong>Start Managing:</strong> Configure properties, residents, and community settings</li>
            </ol>

            <h3>Need Help?</h3>
            <p>If you encounter any issues or have questions about using the admin dashboard, please don't hesitate to reach out to our support team.</p>

            <p>We're excited to have you as part of the ${tenantName} management team!</p>

            <p>Best regards,<br>
            The Village Tech Team</p>
          </div>

          <div class="footer">
            <p>This is an automated message. Please do not reply to this email.</p>
            <p>© 2024 Village Tech. All rights reserved.</p>
          </div>
        </body>
        </html>
      `,
    })

    if (error) {
      console.error('Email sending failed:', error)
      return { success: false, error: error.message }
    }

    return { success: true, data }
  } catch (error) {
    console.error('Email service error:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to send email'
    }
  }
}