import { createEmailService, type EmailService } from '@basecase/email';
import type { NextApiRequest, NextApiResponse } from 'next';

// Initialize the email service
const emailService = createEmailService({
  apiKey: process.env.RESEND_API_KEY!,
  from: process.env.RESEND_FROM_EMAIL || 'noreply@yourdomain.com',
  appName: 'Basecase',
  baseUrl: process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000',
});

// Example 1: Send verification email from an API route
export async function sendVerificationHandler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  const { email, verificationToken } = req.body;

  try {
    const result = await emailService.sendEmailVerification({
      to: email,
      verificationUrl: `${process.env.NEXT_PUBLIC_APP_URL}/verify?token=${verificationToken}`,
      userEmail: email,
    });

    return res.status(200).json({
      success: true,
      message: 'Verification email sent',
      data: result.data,
    });
  } catch (error) {
    console.error('Failed to send verification email:', error);
    return res.status(500).json({
      success: false,
      error: 'Failed to send email',
    });
  }
}

// Example 2: Send notification emails
export async function notifyUser(
  userId: string,
  notification: {
    title: string;
    message: string;
    actionUrl?: string;
    actionText?: string;
  }
) {
  // Get user email from database (example)
  const userEmail = 'user@example.com'; // Replace with actual user lookup

  try {
    await emailService.sendNotification({
      to: userEmail,
      title: notification.title,
      message: notification.message,
      actionUrl: notification.actionUrl,
      actionText: notification.actionText || 'View Details',
      userEmail,
    });

    console.log(`Notification sent to user ${userId}`);
  } catch (error) {
    console.error(`Failed to notify user ${userId}:`, error);
    throw error;
  }
}

// Example 3: Batch email sending
export async function sendBatchWelcomeEmails(
  users: Array<{ email: string; name: string }>
) {
  const results = await Promise.allSettled(
    users.map((user) =>
      emailService.sendWelcomeEmail({
        to: user.email,
        firstName: user.name,
        userEmail: user.email,
        dashboardUrl: '/dashboard',
      })
    )
  );

  const successful = results.filter((r) => r.status === 'fulfilled').length;
  const failed = results.filter((r) => r.status === 'rejected').length;

  console.log(`Sent ${successful} welcome emails, ${failed} failed`);

  return { successful, failed, total: users.length };
}

// Example 4: Send templated emails dynamically
export async function sendDynamicEmail(
  template:
    | 'email-verification'
    | 'magic-link'
    | 'welcome'
    | 'notification'
    | 'password-reset',
  recipient: string,
  props: any
) {
  try {
    const result = await emailService.sendTemplatedEmail(template, {
      to: recipient,
      ...props,
    });

    return { success: true, data: result.data };
  } catch (error) {
    console.error(`Failed to send ${template} email:`, error);
    return { success: false, error };
  }
}

// Example 5: Custom email with attachments
export async function sendInvoiceEmail(
  customerEmail: string,
  invoiceData: {
    invoiceNumber: string;
    amount: number;
    dueDate: string;
    pdfBuffer: Buffer;
  }
) {
  try {
    const result = await emailService.sendEmail({
      from: process.env.RESEND_FROM_EMAIL || 'billing@yourdomain.com',
      to: customerEmail,
      subject: `Invoice #${invoiceData.invoiceNumber}`,
      html: `
        <h2>Invoice #${invoiceData.invoiceNumber}</h2>
        <p>Amount Due: $${invoiceData.amount}</p>
        <p>Due Date: ${invoiceData.dueDate}</p>
        <p>Please find your invoice attached.</p>
      `,
      attachments: [
        {
          filename: `invoice-${invoiceData.invoiceNumber}.pdf`,
          content: invoiceData.pdfBuffer,
        },
      ],
    });

    return { success: true, data: result.data };
  } catch (error) {
    console.error('Failed to send invoice email:', error);
    throw error;
  }
}

// Example 6: Email queue implementation
class EmailQueue {
  private queue: Array<() => Promise<any>> = [];
  private processing = false;

  constructor(private emailService: EmailService) {}

  async add(emailTask: () => Promise<any>) {
    this.queue.push(emailTask);
    if (!this.processing) {
      this.process();
    }
  }

  private async process() {
    this.processing = true;

    while (this.queue.length > 0) {
      const task = this.queue.shift();
      if (task) {
        try {
          await task();
          // Add delay to respect rate limits
          await new Promise((resolve) => setTimeout(resolve, 100));
        } catch (error) {
          console.error('Email queue error:', error);
        }
      }
    }

    this.processing = false;
  }
}

// Usage
const emailQueue = new EmailQueue(emailService);

// Add emails to queue
emailQueue.add(() =>
  emailService.sendWelcomeEmail({
    to: 'user1@example.com',
    firstName: 'User 1',
    userEmail: 'user1@example.com',
  })
);

emailQueue.add(() =>
  emailService.sendNotification({
    to: 'user2@example.com',
    title: 'New Message',
    message: 'You have a new message',
    userEmail: 'user2@example.com',
  })
);
