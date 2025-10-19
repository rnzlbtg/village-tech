# Supabase Auth Email Setup Guide

## Overview

Village Tech uses Supabase Authentication for user management. This guide covers email configuration for authentication emails like password resets and email verifications.

## Supabase Email Configuration Options

### Option 1: Use Supabase's Built-in Email Service (Recommended)

Supabase provides a built-in email service that works out of the box for development and can be configured for production.

#### Development Setup
For local development, Supabase automatically uses **Inbucket** for email testing:
- **URL**: http://localhost:54324
- **Username**: Any email works
- **Password**: No password required

#### Production Setup

1. **Navigate to Supabase Dashboard** → Authentication → Settings
2. **Enable Custom SMTP** (recommended for production)
3. **Configure SMTP Settings**:

```bash
# SMTP Provider Options
# Option A: Resend (Recommended)
SMTP_HOST: smtp.resend.com
SMTP_PORT: 465
SMTP_USER: resend
SMTP_PASS: your_resend_api_key
SMTP_SENDER: noreply@yourdomain.com

# Option B: SendGrid
SMTP_HOST: smtp.sendgrid.net
SMTP_PORT: 587
SMTP_USER: apikey
SMTP_PASS: your_sendgrid_api_key
SMTP_SENDER: noreply@yourdomain.com

# Option C: AWS SES
SMTP_HOST: email-smtp.us-east-1.amazonaws.com
SMTP_PORT: 587
SMTP_USER: your_aws_access_key
SMTP_PASS: your_aws_secret_key
SMTP_SENDER: noreply@yourdomain.com
```

### Option 2: Use Resend via Supabase Edge Functions

For advanced email customization, use Resend through Supabase Edge Functions:

```typescript
// supabase/functions/send-auth-email/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { Resend } from 'https://esm.sh/resend@2.0.0'

const resend = new Resend(Deno.env.get('RESEND_API_KEY'))

serve(async (req) => {
  const { to, subject, html, text } = await req.json()

  const { data, error } = await resend.emails.send({
    from: 'noreply@yourdomain.com',
    to,
    subject,
    html,
    text,
  })

  return new Response(JSON.stringify({ data, error }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
```

## Email Templates Configuration

### 1. Password Reset Email

**Template Location**: Supabase Dashboard → Authentication → Email Templates

**Default Template**:
```html
<h2>Password Reset</h2>
<p>Hello {{ .User.Email }},</p>
<p>Click <a href="{{ .ConfirmationURL }}">here</a> to reset your password.</p>
<p>This link expires in 24 hours.</p>
```

**Custom Template (Village Tech)**:
```html
<div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
  <div style="background: #105640; padding: 20px; text-align: center;">
    <h1 style="color: white; margin: 0;">Village Tech</h1>
    <p style="color: #a3d9c6; margin: 5px 0 0 0;">Community Management System</p>
  </div>

  <div style="padding: 30px; background: #f9fafb;">
    <h2 style="color: #105640; margin-top: 0;">Password Reset Request</h2>

    <p>Hello {{ .User.FirstName }},</p>

    <p>We received a request to reset your password for your Village Tech account. Click the button below to proceed:</p>

    <div style="text-align: center; margin: 30px 0;">
      <a href="{{ .ConfirmationURL }}"
         style="background: #105640; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block;">
        Reset Password
      </a>
    </div>

    <p style="color: #666; font-size: 14px;">
      Or copy and paste this link into your browser:<br>
      <span style="word-break: break-all;">{{ .ConfirmationURL }}</span>
    </p>

    <p style="color: #666; font-size: 14px;">
      <strong>Note:</strong> This link expires in 24 hours for security reasons.
    </p>
  </div>

  <div style="background: #e5e7eb; padding: 20px; text-align: center; font-size: 12px; color: #666;">
    <p>If you didn't request this password reset, you can safely ignore this email.</p>
    <p>© 2024 Village Tech Community. All rights reserved.</p>
  </div>
</div>
```

### 2. Email Confirmation Template

```html
<div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
  <div style="background: #105640; padding: 20px; text-align: center;">
    <h1 style="color: white; margin: 0;">Village Tech</h1>
    <p style="color: #a3d9c6; margin: 5px 0 0 0;">Community Management System</p>
  </div>

  <div style="padding: 30px; background: #f9fafb;">
    <h2 style="color: #105640; margin-top: 0;">Confirm Your Email Address</h2>

    <p>Hello {{ .User.FirstName }},</p>

    <p>Thank you for joining Village Tech! Please confirm your email address to complete your registration:</p>

    <div style="text-align: center; margin: 30px 0;">
      <a href="{{ .ConfirmationURL }}"
         style="background: #105640; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block;">
        Confirm Email
      </a>
    </div>

    <p style="color: #666; font-size: 14px;">
      Or copy and paste this link into your browser:<br>
      <span style="word-break: break-all;">{{ .ConfirmationURL }}</span>
    </p>
  </div>

  <div style="background: #e5e7eb; padding: 20px; text-align: center; font-size: 12px; color: #666;">
    <p>© 2024 Village Tech Community. All rights reserved.</p>
  </div>
</div>
```

## Configuration Checklist

### Development Environment
- [ ] Supabase local development running
- [ ] Inbucket accessible at http://localhost:54324
- [ ] Test email sending via auth flows

### Production Environment
- [ ] Custom SMTP configured in Supabase Dashboard
- [ ] Email templates customized with branding
- [ ] Sender email domain verified
- [ ] SPF/DKIM records configured (optional but recommended)

### Testing Checklist
- [ ] Password reset email delivery
- [ ] Email confirmation delivery
- [ ] Email rendering on mobile devices
- [ ] Email links working correctly
- [ ] Email security (expiry, one-time use)

## Testing Authentication Emails

### 1. Test Password Reset
```bash
# In your Admin App, trigger password reset for a test user
# Check email at your SMTP provider or http://localhost:54324
```

### 2. Test Email Confirmation
```bash
# Create a new user with email confirmation required
# Verify confirmation email is received
```

### 3. Check Email Headers
```bash
# Verify email headers include:
# - Proper sender information
# - Reply-to addresses
# - Security headers (SPF/DKIM if configured)
```

## Security Considerations

### 1. Link Security
- **Expiration**: Password reset links expire in 24 hours
- **One-time Use**: Links become invalid after first use
- **HTTPS**: All links should use HTTPS in production

### 2. Email Security
- **Rate Limiting**: Limit password reset requests
- **Verification**: Verify email ownership before sensitive operations
- **Logging**: Log authentication email events

### 3. Privacy Compliance
- **Data Minimization**: Only send necessary user data
- **Unsubscribe Option**: Include unsubscribe if applicable
- **GDPR Compliance**: Follow email marketing regulations

## Troubleshooting

### Common Issues

#### 1. Emails Not Sending
```bash
# Check Supabase logs
# Verify SMTP configuration
# Test SMTP credentials
```

#### 2. Emails Going to Spam
```bash
# Check sender reputation
# Verify SPF/DKIM records
# Review email content for spam triggers
```

#### 3. Links Not Working
```bash
# Verify confirmation URL format
# Check redirect configuration
# Test link expiration
```

## Monitoring

### Supabase Dashboard
- **Email Metrics**: Monitor delivery rates
- **Authentication Events**: Track password resets, confirmations
- **User Activity**: Monitor authentication patterns

### External Monitoring
- **Email Provider Analytics**: Track open/click rates
- **SMTP Logs**: Monitor delivery issues
- **User Feedback**: Collect email feedback

## Support Resources

- **Supabase Auth Documentation**: https://supabase.com/docs/guides/auth
- **Email Provider Documentation**: Check your SMTP provider's docs
- **Village Tech Issues**: Create issue in project repository