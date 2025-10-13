/**
 * Email Notification System
 *
 * For MVP, this uses console logging to simulate email sending.
 * In production, integrate with Resend, SendGrid, or Supabase Edge Functions.
 */

export type EmailNotification = {
  to: string
  subject: string
  html: string
  text?: string
}

/**
 * Send email notification
 *
 * @param notification - Email details
 * @returns Success status
 */
export async function sendEmail(notification: EmailNotification): Promise<{ success: boolean; error?: string }> {
  'use server'
  try {
    // MVP: Log email instead of sending
    console.log('📧 Email Notification:', {
      to: notification.to,
      subject: notification.subject,
      preview: notification.text?.substring(0, 100) || notification.html.substring(0, 100),
    })

    // TODO: Production implementation
    // const response = await fetch('https://api.resend.com/emails', {
    //   method: 'POST',
    //   headers: {
    //     'Authorization': `Bearer ${process.env.RESEND_API_KEY}`,
    //     'Content-Type': 'application/json',
    //   },
    //   body: JSON.stringify({
    //     from: process.env.EMAIL_FROM,
    //     to: notification.to,
    //     subject: notification.subject,
    //     html: notification.html,
    //     text: notification.text,
    //   }),
    // })

    return { success: true }
  } catch (error) {
    console.error('Email notification error:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error',
    }
  }
}

/**
 * Email Templates
 */

export function stickerApprovedEmail(params: {
  householdHeadName: string
  vehiclePlate: string
  pickupInstructions: string
}) {
  const subject = 'Vehicle Sticker Request Approved'
  const html = `
    <h2>Vehicle Sticker Approved</h2>
    <p>Dear ${params.householdHeadName},</p>
    <p>Your vehicle sticker request for <strong>${params.vehiclePlate}</strong> has been approved.</p>
    <h3>Pickup Instructions:</h3>
    <p>${params.pickupInstructions}</p>
    <p>Please bring a valid ID when collecting your sticker.</p>
    <p>Best regards,<br/>Community Administration</p>
  `
  const text = `
    Vehicle Sticker Approved

    Dear ${params.householdHeadName},

    Your vehicle sticker request for ${params.vehiclePlate} has been approved.

    Pickup Instructions:
    ${params.pickupInstructions}

    Please bring a valid ID when collecting your sticker.

    Best regards,
    Community Administration
  `
  return { subject, html, text }
}

export function stickerRejectedEmail(params: {
  householdHeadName: string
  vehiclePlate: string
  rejectionReason: string
}) {
  const subject = 'Vehicle Sticker Request Rejected'
  const html = `
    <h2>Vehicle Sticker Request Update</h2>
    <p>Dear ${params.householdHeadName},</p>
    <p>Unfortunately, your vehicle sticker request for <strong>${params.vehiclePlate}</strong> has been rejected.</p>
    <h3>Reason:</h3>
    <p>${params.rejectionReason}</p>
    <p>If you have any questions, please contact the community administration office.</p>
    <p>Best regards,<br/>Community Administration</p>
  `
  const text = `
    Vehicle Sticker Request Update

    Dear ${params.householdHeadName},

    Unfortunately, your vehicle sticker request for ${params.vehiclePlate} has been rejected.

    Reason:
    ${params.rejectionReason}

    If you have any questions, please contact the community administration office.

    Best regards,
    Community Administration
  `
  return { subject, html, text }
}

export function constructionPermitApprovedEmail(params: {
  householdHeadName: string
  permitReference: string
  projectDescription: string
  startDate: string
  endDate: string
  authorizedWorkers: string[]
}) {
  const subject = `Construction Permit Approved - ${params.permitReference}`
  const html = `
    <h2>Construction Permit Approved</h2>
    <p>Dear ${params.householdHeadName},</p>
    <p>Your construction permit <strong>${params.permitReference}</strong> has been approved.</p>
    <h3>Project Details:</h3>
    <ul>
      <li><strong>Description:</strong> ${params.projectDescription}</li>
      <li><strong>Start Date:</strong> ${params.startDate}</li>
      <li><strong>End Date:</strong> ${params.endDate}</li>
    </ul>
    <h3>Authorized Workers:</h3>
    <ul>
      ${params.authorizedWorkers.map(worker => `<li>${worker}</li>`).join('')}
    </ul>
    <p>Please ensure all workers carry proper identification when entering the community.</p>
    <p>Best regards,<br/>Community Administration</p>
  `
  const text = `
    Construction Permit Approved

    Dear ${params.householdHeadName},

    Your construction permit ${params.permitReference} has been approved.

    Project Details:
    - Description: ${params.projectDescription}
    - Start Date: ${params.startDate}
    - End Date: ${params.endDate}

    Authorized Workers:
    ${params.authorizedWorkers.map(w => `- ${w}`).join('\n')}

    Please ensure all workers carry proper identification when entering the community.

    Best regards,
    Community Administration
  `
  return { subject, html, text }
}

export function welcomeHouseholdHeadEmail(params: {
  householdHeadName: string
  email: string
  temporaryPassword: string
  loginUrl: string
}) {
  const subject = 'Welcome to Your Community Portal'
  const html = `
    <h2>Welcome to Your Community</h2>
    <p>Dear ${params.householdHeadName},</p>
    <p>Your household account has been created. You can now access the community portal to manage your household, request services, and stay updated with community announcements.</p>
    <h3>Your Login Credentials:</h3>
    <ul>
      <li><strong>Email:</strong> ${params.email}</li>
      <li><strong>Temporary Password:</strong> ${params.temporaryPassword}</li>
    </ul>
    <p><a href="${params.loginUrl}">Click here to login</a></p>
    <p><strong>Important:</strong> Please change your password after your first login.</p>
    <p>Best regards,<br/>Community Administration</p>
  `
  const text = `
    Welcome to Your Community

    Dear ${params.householdHeadName},

    Your household account has been created. You can now access the community portal.

    Your Login Credentials:
    - Email: ${params.email}
    - Temporary Password: ${params.temporaryPassword}

    Login URL: ${params.loginUrl}

    Important: Please change your password after your first login.

    Best regards,
    Community Administration
  `
  return { subject, html, text }
}
