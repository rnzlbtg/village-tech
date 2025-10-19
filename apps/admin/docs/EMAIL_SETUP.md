# Email Service Setup Guide - Village Tech Admin App

## Overview

The Village Tech Admin App uses **Resend** for email delivery. This guide covers setup, configuration, and testing of the email service.

## Prerequisites

- Node.js 20+
- Admin App running locally
- Resend account (free tier available)

## Step 1: Set Up Resend Account

1. **Create Account**: Visit [https://resend.com](https://resend.com) and sign up
2. **Get API Key**: Navigate to Settings → API Keys → Create API Key
3. **Add Domain**:
   - Go to Domains → Add Domain
   - Add your domain (e.g., `yourdomain.com`)
   - **DNS Configuration**: Add the DNS records provided by Resend to your domain's DNS settings
4. **Verify Domain**: Wait for DNS propagation (usually 5-15 minutes)

## Step 2: Configure Environment Variables

Create or update your `.env.local` file in the Admin app:

```bash
# Email Configuration (Resend)
RESEND_API_KEY=re_your_actual_api_key_here
EMAIL_FROM=noreply@yourdomain.com
EMAIL_FROM_NAME=Village Tech Community

# Residence App URL (for welcome emails)
NEXT_PUBLIC_RESIDENCE_APP_URL=http://localhost:3000
```

### Environment Variables Explained

| Variable | Required | Description | Example |
|----------|-----------|-------------|---------|
| `RESEND_API_KEY` | ✅ | Your Resend API key | `re_xxxxxxxxxxxxxx` |
| `EMAIL_FROM` | ✅ | From email address (must be verified domain) | `noreply@yourdomain.com` |
| `EMAIL_FROM_NAME` | ❌ | Display name for emails | `Village Tech Community` |
| `NEXT_PUBLIC_RESIDENCE_APP_URL` | ❌ | URL for Residence App login links | `https://app.yourdomain.com` |

## Step 3: Test Email Configuration

### Check Email Status
```bash
curl http://localhost:3001/api/email-status
```

### Send Test Email
```bash
curl -X POST http://localhost:3001/api/test-email \
  -H "Content-Type: application/json" \
  -d '{
    "to": "your-email@example.com",
    "subject": "Test Email from Village Tech",
    "testType": "welcome"
  }'
```

### Test Different Email Types
```bash
# Test sticker approval email
curl -X POST http://localhost:3001/api/test-email \
  -H "Content-Type: application/json" \
  -d '{
    "to": "your-email@example.com",
    "subject": "Sticker Approval Test",
    "testType": "sticker"
  }'

# Test custom email
curl -X POST http://localhost:3001/api/test-email \
  -H "Content-Type: application/json" \
  -d '{
    "to": "your-email@example.com",
    "subject": "Custom Test Email",
    "testType": "custom"
  }'
```

## Step 4: Email Templates

The system includes these automated email templates:

### 1. Welcome Email
- **Trigger**: When new household head is created
- **Content**: Login credentials and getting started guide
- **Template**: `lib/email/templates.ts`

### 2. Sticker Approval Email
- **Trigger**: When vehicle sticker request is approved
- **Content**: Pickup instructions and vehicle details
- **Template**: `lib/notifications/email.ts`

### 3. Sticker Rejection Email
- **Trigger**: When vehicle sticker request is rejected
- **Content**: Rejection reason and next steps
- **Template**: `lib/notifications/email.ts`

### 4. Construction Permit Email
- **Trigger**: When construction permit is approved
- **Content**: Permit details and authorized workers
- **Template**: `lib/notifications/email.ts`

## Step 5: Production Deployment

### Domain Verification Checklist
- [ ] DNS records added to domain
- [ ] Domain verified in Resend dashboard
- [ ] Test emails delivered successfully
- [ ] SPF/DKIM records configured (optional but recommended)

### Environment Setup
- [ ] `RESEND_API_KEY` set in production environment
- [ ] `EMAIL_FROM` uses verified domain
- [ ] `NEXT_PUBLIC_RESIDENCE_APP_URL` points to production Residence App

### Testing Checklist
- [ ] Send test email from production environment
- [ ] Verify email delivery to inbox (not spam)
- [ ] Test all email templates
- [ ] Check email formatting on mobile devices

## Step 6: Troubleshooting

### Common Issues

#### 1. Email Not Sending
```bash
# Check email service status
curl http://localhost:3001/api/email-status

# Check environment variables
echo $RESEND_API_KEY
echo $EMAIL_FROM
```

#### 2. Domain Not Verified
- **Solution**: Complete DNS setup in Resend dashboard
- **Wait**: DNS propagation can take up to 24 hours
- **Check**: Use DNS lookup tools to verify records

#### 3. Emails Going to Spam
- **Solution**: Set up SPF and DKIM records
- **Content**: Avoid spam-like content in emails
- **Sender**: Use consistent sender information

#### 4. API Key Issues
```bash
# Test API key validity
curl -X POST https://api.resend.com/emails \
  -H "Authorization: Bearer re_your_api_key" \
  -H "Content-Type: application/json" \
  -d '{
    "from": "noreply@yourdomain.com",
    "to": "test@example.com",
    "subject": "Test",
    "html": "<p>Test</p>"
  }'
```

### Debug Mode

For development, the system automatically uses mock mode if:
- `NODE_ENV=development`
- `RESEND_API_KEY` is not set
- `EMAIL_FROM` is not set

Mock emails are logged to console with prefix `📧 MOCK EMAIL`.

## Step 7: Monitoring and Analytics

### Resend Dashboard
- **Email Delivery**: Monitor delivery rates
- **Open Rates**: Track email engagement
- **Bounce Rates**: Identify delivery issues
- **API Usage**: Monitor API calls and limits

### Local Monitoring
```bash
# View email logs
tail -f logs/app.log | grep "Email"

# Check Resend service status
curl http://localhost:3001/api/email-status
```

## Alternative Email Services

If you prefer a different email service, you can easily replace Resend:

### SendGrid
```bash
npm install @sendgrid/mail
```

### AWS SES
```bash
npm install @aws-sdk/client-ses
```

### Postmark
```bash
npm install postmark
```

Update `lib/email/resend-service.ts` to use the preferred service.

## Security Considerations

1. **API Key Security**: Never commit API keys to version control
2. **Domain Security**: Use HTTPS for all email links
3. **Rate Limiting**: Monitor API usage to avoid limits
4. **Data Privacy**: Ensure compliance with email regulations

## Support

- **Resend Documentation**: https://resend.com/docs
- **Resend Status**: https://status.resend.com
- **Village Tech Issues**: Create issue in project repository