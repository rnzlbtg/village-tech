# Email Setup for Tenant Creation

This document explains how to configure the email functionality for sending welcome emails to newly created admin users.

## Prerequisites

1. **Resend Account**: Sign up at [resend.com](https://resend.com)
2. **Verified Domain**: Add and verify your sending domain in Resend
3. **API Key**: Get your Resend API key from the dashboard
4. **Dependencies**: The following packages are automatically installed:
   - `resend` - Email service
   - `@react-email/render` - HTML email rendering

## Environment Variables

Add these to your `.env.local` file:

```env
# Email Service (Resend)
RESEND_API_KEY=re_your_api_key_here
RESEND_FROM_EMAIL=noreply@yourdomain.com
NEXT_PUBLIC_ADMIN_APP_URL=http://localhost:3001
```

### Variables Explanation

- `RESEND_API_KEY`: Your Resend API key for sending emails
- `RESEND_FROM_EMAIL`: The email address to send from (must be verified in Resend)
- `NEXT_PUBLIC_ADMIN_APP_URL`: The URL to the admin application login page

## Email Template

The system sends a professional welcome email that includes:

- Personalized greeting with admin user's name
- Login URL to the admin dashboard
- Email address and temporary password
- Clear instructions for next steps
- Security reminders about changing password

## How It Works

1. **Tenant Creation**: Platform admin creates a new tenant and admin user
2. **Email Generation**: System generates a secure 12-character temporary password
3. **Email Sending**: Welcome email is automatically sent to the admin user
4. **Success Confirmation**: Platform admin sees confirmation that email was sent
5. **Fallback**: If email fails, credentials are still shown for manual sharing

## Email Content

The email includes:

- **Subject**: "Welcome to [Tenant Name] - Your Admin Account is Ready"
- **Login Credentials**: Email, temporary password, and admin login URL
- **Instructions**: How to log in and change password
- **Next Steps**: What to do after first login
- **Support Information**: How to get help if needed

## Testing

To test the email functionality:

1. Set up your Resend account and verify your domain
2. Add the environment variables to `.env.local`
3. Create a test tenant in the platform app
4. Check if the welcome email is received

## Troubleshooting

**Email not sending:**
- Check that `RESEND_API_KEY` is correct
- Verify that `RESEND_FROM_EMAIL` domain is verified in Resend
- Check server logs for error messages

**Template issues:**
- Email template is located in `lib/email.ts`
- HTML template uses inline CSS for email client compatibility
- All variables are properly escaped for security

## Security Notes

- Temporary passwords are 12 characters with mixed case, numbers, and symbols
- Emails contain sensitive information - ensure your sending domain is secure
- Consider implementing additional email verification if needed
- Monitor email deliverability and bounce rates