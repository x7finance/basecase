# @basecase/email

Email package for Basecase using React Email and Resend.

## Features

- Pre-built email templates using React Email
- Resend integration for sending emails
- Better Auth integration support
- TypeScript support
- Email preview during development

## Available Templates

- **Email Verification**: For verifying user email addresses
- **Magic Link**: Passwordless login via email
- **Welcome**: Welcome new users after signup
- **Notification**: General notifications and alerts
- **Password Reset**: Password reset requests

## Important: No Build Required!

**React Email templates don't need a build step for production.** Templates are rendered to HTML at runtime when emails are sent. The "build" command only creates a static preview site for development, which is optional.

## Development

### Preview Templates

Run the email development server to preview templates:

```bash
cd packages/email
bun run dev
```

This will start the React Email preview server at http://localhost:3000

## Usage

### Basic Usage with Resend

```typescript
import { createEmailService } from '@basecase/email';

// Create email service instance
const emailService = createEmailService({
  apiKey: process.env.RESEND_API_KEY!,
  from: 'noreply@yourdomain.com',
  appName: 'Your App',
  baseUrl: 'https://yourapp.com',
});

// Send verification email
await emailService.sendEmailVerification({
  to: 'user@example.com',
  verificationUrl: 'https://yourapp.com/verify?token=xxx',
  userEmail: 'user@example.com',
});

// Send welcome email
await emailService.sendWelcomeEmail({
  to: 'user@example.com',
  firstName: 'John',
  userEmail: 'user@example.com',
  dashboardUrl: '/dashboard',
});
```

### Integration with Better Auth

```typescript
import { betterAuth } from 'better-auth';
import { prismaAdapter } from 'better-auth/adapters/prisma';
import { getBetterAuthEmailConfig } from '@basecase/email';

const emailConfig = getBetterAuthEmailConfig({
  resendApiKey: process.env.RESEND_API_KEY!,
  from: 'noreply@yourdomain.com',
  appName: 'Your App',
  baseUrl: process.env.NEXT_PUBLIC_APP_URL,
});

export const auth = betterAuth({
  appName: 'Your App',
  database: prismaAdapter(prisma),
  
  emailAndPassword: {
    enabled: true,
    requireEmailVerification: true,
  },
  
  // Use the email configuration
  ...emailConfig,
});
```

### Custom Email Sending

```typescript
import { EmailService } from '@basecase/email';
import { NotificationTemplate } from '@basecase/email/templates';

const emailService = new EmailService({
  apiKey: process.env.RESEND_API_KEY!,
  from: 'notifications@yourdomain.com',
});

// Send custom notification
await emailService.sendNotification({
  to: 'user@example.com',
  title: 'New Activity in Your Project',
  message: 'Someone commented on your post...',
  actionUrl: 'https://yourapp.com/posts/123',
  actionText: 'View Comment',
  userEmail: 'user@example.com',
});
```

## Environment Variables

Add these to your `.env` file:

```env
RESEND_API_KEY=re_xxxxxxxxxxxxx
RESEND_FROM_EMAIL=noreply@yourdomain.com
```

## API Reference

### EmailService

Main service class for sending emails.

#### Methods

- `sendEmailVerification(props)` - Send email verification
- `sendMagicLink(props)` - Send magic link for passwordless login
- `sendWelcomeEmail(props)` - Send welcome email to new users
- `sendNotification(props)` - Send general notifications
- `sendPasswordReset(props)` - Send password reset email
- `sendTemplatedEmail(template, props)` - Send email using template name

### Better Auth Handlers

- `createBetterAuthEmailHandlers(config)` - Create email handlers for Better Auth
- `getBetterAuthEmailConfig(config)` - Get Better Auth configuration with email handlers

## License

MIT