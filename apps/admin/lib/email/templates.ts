// Email templates for household notifications

export interface WelcomeEmailData {
  householdHeadName: string
  email: string
  temporaryPassword: string
  communityName: string
  unitNumber: string
  residenceAppUrl: string
  supportEmail: string
  supportPhone?: string
}

export function generateWelcomeEmail(data: WelcomeEmailData): {
  subject: string
  html: string
  text: string
} {
  const subject = `Welcome to ${data.communityName} - Your Residence App Access`

  const html = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { background-color: #4F46E5; color: white; padding: 30px; text-align: center; border-radius: 8px 8px 0 0; }
    .content { background-color: #f9fafb; padding: 30px; border: 1px solid #e5e7eb; }
    .credentials-box { background-color: white; padding: 20px; border-left: 4px solid #4F46E5; margin: 20px 0; }
    .button { display: inline-block; background-color: #4F46E5; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; margin: 20px 0; }
    .footer { background-color: #f3f4f6; padding: 20px; text-align: center; font-size: 12px; color: #6b7280; border-radius: 0 0 8px 8px; }
    .warning { background-color: #fef3c7; padding: 15px; border-left: 4px solid #f59e0b; margin: 20px 0; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>Welcome to ${data.communityName}!</h1>
    </div>

    <div class="content">
      <h2>Hello ${data.householdHeadName},</h2>

      <p>Welcome to your new home at <strong>${data.communityName}</strong>! Your account has been created for Unit <strong>${data.unitNumber}</strong>.</p>

      <p>You now have access to the Residence App, where you can:</p>
      <ul>
        <li>Request vehicle stickers</li>
        <li>Apply for construction permits</li>
        <li>View community announcements</li>
        <li>Pay association fees</li>
        <li>Access village rules and regulations</li>
        <li>Update your household information</li>
      </ul>

      <div class="credentials-box">
        <h3>Your Login Credentials</h3>
        <p><strong>Email:</strong> ${data.email}</p>
        <p><strong>Temporary Password:</strong> <code style="background-color: #f3f4f6; padding: 4px 8px; border-radius: 4px; font-size: 16px;">${data.temporaryPassword}</code></p>
      </div>

      <div class="warning">
        <strong>⚠️ Important - Temporary Password:</strong> This is a simple temporary password for your first login only. You will be <strong>required to create a secure password</strong> (with uppercase, lowercase, numbers, and special characters) when you first log in.
      </div>

      <div style="text-align: center;">
        <a href="${data.residenceAppUrl}" class="button">Access Residence App</a>
      </div>

      <h3>Next Steps:</h3>
      <ol>
        <li>Click the button above or visit <a href="${data.residenceAppUrl}">${data.residenceAppUrl}</a></li>
        <li>Log in using your email and temporary password</li>
        <li>You'll be prompted to create a new secure password</li>
        <li>Complete your profile with additional information</li>
        <li>Start using the Residence App features!</li>
      </ol>

      <p>If you have any questions or need assistance, please don't hesitate to contact us:</p>
      <ul>
        <li><strong>Email:</strong> ${data.supportEmail}</li>
        ${data.supportPhone ? `<li><strong>Phone:</strong> ${data.supportPhone}</li>` : ''}
      </ul>

      <p>We're excited to have you as part of our community!</p>

      <p>Best regards,<br>
      <strong>${data.communityName} Management Team</strong></p>
    </div>

    <div class="footer">
      <p>This is an automated message. Please do not reply to this email.</p>
      <p>© ${new Date().getFullYear()} ${data.communityName}. All rights reserved.</p>
    </div>
  </div>
</body>
</html>
`

  const text = `
Welcome to ${data.communityName}!

Hello ${data.householdHeadName},

Welcome to your new home at ${data.communityName}! Your account has been created for Unit ${data.unitNumber}.

You now have access to the Residence App, where you can:
- Request vehicle stickers
- Apply for construction permits
- View community announcements
- Pay association fees
- Access village rules and regulations
- Update your household information

YOUR LOGIN CREDENTIALS:
Email: ${data.email}
Temporary Password: ${data.temporaryPassword}

⚠️ IMPORTANT: This is a temporary password. For your security, you will be required to change your password upon your first login.

NEXT STEPS:
1. Visit ${data.residenceAppUrl}
2. Log in using your email and temporary password
3. You'll be prompted to create a new secure password
4. Complete your profile with additional information
5. Start using the Residence App features!

If you have any questions or need assistance, please contact us:
Email: ${data.supportEmail}
${data.supportPhone ? `Phone: ${data.supportPhone}` : ''}

We're excited to have you as part of our community!

Best regards,
${data.communityName} Management Team

---
This is an automated message. Please do not reply to this email.
© ${new Date().getFullYear()} ${data.communityName}. All rights reserved.
`

  return { subject, html, text }
}
