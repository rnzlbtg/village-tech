# Email System Documentation

## Overview

The email system sends automated welcome emails to household heads when their accounts are created. Currently, it's configured to use Supabase's built-in email functionality, but can be easily integrated with third-party email services.

## Current Implementation

- **Welcome Email**: Sent automatically when a household head is created
- **Email Template**: Professional HTML email with login credentials
- **Development**: Emails are logged to console
- **Production**: Configure SMTP or integrate with email service

## Files

- `templates.ts` - Email HTML/text templates
- `send.ts` - Email sending logic and utilities

## Development Testing

### Local Development with Supabase

Supabase local development uses **Inbucket** for email testing:

1. Start Supabase locally: `supabase start`
2. Access Inbucket UI: http://localhost:54324
3. Create a household - email will appear in Inbucket
4. View email content and test links

### Console Logging

Currently, email content is logged to the console for debugging:

```typescript
console.log('Welcome Email Generated:', {
  to: data.email,
  subject,
  preview: text.substring(0, 200)
})
```

## Production Setup

### Option 1: Supabase SMTP (Recommended for small-medium scale)

1. Go to Supabase Dashboard → Project Settings → Auth
2. Configure SMTP settings:
   - SMTP Host
   - SMTP Port
   - SMTP User
   - SMTP Password
   - Sender Email
   - Sender Name
3. Test email delivery

### Option 2: SendGrid (Recommended for scale)

1. Install SendGrid:
```bash
npm install @sendgrid/mail
```

2. Add API key to `.env.local`:
```bash
SENDGRID_API_KEY=your_api_key
```

3. Update `send.ts`:
```typescript
import sgMail from '@sendgrid/mail'

sgMail.setApiKey(process.env.SENDGRID_API_KEY!)

export async function sendCustomEmail({ to, subject, html, text }) {
  await sgMail.send({
    to,
    from: 'noreply@yourdomain.com', // Must be verified domain
    subject,
    html,
    text,
  })
  return { success: true }
}
```

### Option 3: Resend (Modern alternative)

1. Install Resend:
```bash
npm install resend
```

2. Add API key to `.env.local`:
```bash
RESEND_API_KEY=your_api_key
```

3. Update `send.ts`:
```typescript
import { Resend } from 'resend'

const resend = new Resend(process.env.RESEND_API_KEY)

export async function sendCustomEmail({ to, subject, html, text }) {
  await resend.emails.send({
    from: 'Village Tech <noreply@yourdomain.com>',
    to,
    subject,
    html,
    text,
  })
  return { success: true }
}
```

### Option 4: AWS SES (Enterprise)

1. Install AWS SDK:
```bash
npm install @aws-sdk/client-ses
```

2. Configure AWS credentials

3. Update `send.ts`:
```typescript
import { SESClient, SendEmailCommand } from '@aws-sdk/client-ses'

const ses = new SESClient({ region: 'us-east-1' })

export async function sendCustomEmail({ to, subject, html, text }) {
  const command = new SendEmailCommand({
    Source: 'noreply@yourdomain.com',
    Destination: { ToAddresses: [to] },
    Message: {
      Subject: { Data: subject },
      Body: {
        Html: { Data: html },
        Text: { Data: text },
      },
    },
  })

  await ses.send(command)
  return { success: true }
}
```

## Environment Variables

Add to `.env.local`:

```bash
# Email Service Configuration
SENDGRID_API_KEY=your_sendgrid_key          # For SendGrid
RESEND_API_KEY=your_resend_key              # For Resend
AWS_ACCESS_KEY_ID=your_aws_key              # For AWS SES
AWS_SECRET_ACCESS_KEY=your_aws_secret       # For AWS SES

# Application URLs
NEXT_PUBLIC_RESIDENCE_APP_URL=https://residence.yourdomain.com

# Support Contact
SUPPORT_EMAIL=support@yourdomain.com
SUPPORT_PHONE=+1234567890
```

## Email Template Customization

### Modify Welcome Email

Edit `templates.ts` → `generateWelcomeEmail()`:

```typescript
export function generateWelcomeEmail(data: WelcomeEmailData) {
  // Customize subject line
  const subject = `Welcome to ${data.communityName}!`

  // Customize HTML content
  const html = `...`

  // Customize plain text content
  const text = `...`

  return { subject, html, text }
}
```

### Add New Email Templates

Create new functions in `templates.ts`:

```typescript
export function generatePasswordResetEmail(data: PasswordResetData) {
  // Implementation
}

export function generatePaymentReminderEmail(data: PaymentReminderData) {
  // Implementation
}
```

## Error Handling

Email sending errors are caught and logged but **do not fail** the household creation:

```typescript
try {
  await sendWelcomeEmail(data)
  console.log('Welcome email sent successfully')
} catch (emailError) {
  console.error('Error sending welcome email:', emailError)
  // Household is still created successfully
}
```

## Testing

### Manual Testing

1. Create a household through the admin app
2. Check console logs for email content
3. In production: verify email delivery to recipient

### Test Email Template

Create a test page to preview email templates:

```typescript
// app/test/email-preview/page.tsx
import { generateWelcomeEmail } from '@/lib/email/templates'

export default function EmailPreviewPage() {
  const { html } = generateWelcomeEmail({
    householdHeadName: 'John Doe',
    email: 'john@example.com',
    temporaryPassword: 'Test123!',
    communityName: 'Test Village',
    unitNumber: '101',
    residenceAppUrl: 'https://residence.example.com',
    supportEmail: 'support@example.com',
  })

  return <div dangerouslySetInnerHTML={{ __html: html }} />
}
```

## Security Considerations

1. **Never log passwords in production** - Remove console.log statements
2. **Use environment variables** for API keys
3. **Verify email domains** with your email service
4. **Implement rate limiting** to prevent abuse
5. **Use HTTPS** for all email links
6. **Consider email encryption** for sensitive data

## Future Enhancements

- [ ] Email queue system for bulk sending
- [ ] Email delivery tracking
- [ ] Unsubscribe functionality
- [ ] Email templates admin UI
- [ ] Multi-language support
- [ ] Email scheduling
- [ ] Attachment support
- [ ] Email analytics

## Support

For issues or questions about the email system:
- Check Supabase logs for delivery errors
- Verify SMTP/API configuration
- Test with a known working email address
- Check spam folder
- Verify domain reputation
