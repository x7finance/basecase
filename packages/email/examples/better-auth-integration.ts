import {
  createBetterAuthEmailHandlers,
  getBetterAuthEmailConfig,
} from '@basecase/email';
import { betterAuth } from 'better-auth';
import { prismaAdapter } from 'better-auth/adapters/prisma';

// Example 1: Basic Better Auth integration with email verification
export const authWithEmail = betterAuth({
  appName: 'Basecase',
  database: prismaAdapter(prisma, {
    provider: 'postgresql',
  }),

  emailAndPassword: {
    enabled: true,
    autoSignIn: true,
    minPasswordLength: 8,
    maxPasswordLength: 20,
    requireEmailVerification: true,
  },

  // Get the complete email configuration
  ...getBetterAuthEmailConfig({
    resendApiKey: process.env.RESEND_API_KEY!,
    from: process.env.RESEND_FROM_EMAIL || 'onboarding@resend.dev',
    appName: 'Basecase',
    baseUrl: process.env.NEXT_PUBLIC_APP_URL,
  }),
});

// Example 2: Custom email handlers for more control
const emailHandlers = createBetterAuthEmailHandlers({
  resendApiKey: process.env.RESEND_API_KEY!,
  from: process.env.RESEND_FROM_EMAIL || 'onboarding@resend.dev',
  appName: 'Basecase',
  baseUrl: process.env.NEXT_PUBLIC_APP_URL,
});

export const authWithCustomEmails = betterAuth({
  appName: 'Basecase',
  database: prismaAdapter(prisma, {
    provider: 'postgresql',
  }),

  emailAndPassword: {
    enabled: true,
    autoSignIn: true,
    minPasswordLength: 8,
    maxPasswordLength: 20,
    requireEmailVerification: true,
  },

  emailVerification: {
    sendOnSignUp: true,
    autoSignInAfterVerification: true,
    sendVerificationEmail: async ({ user, url }) => {
      // Custom logic before sending
      console.log(`Sending verification to ${user.email}`);

      // Use the email handler
      await emailHandlers.sendVerificationEmail({ user, url });

      // Custom logic after sending
      // e.g., log to analytics, update database, etc.
    },
  },

  // Add magic link support
  magicLink: {
    enabled: true,
    sendMagicLink: emailHandlers.sendMagicLinkEmail,
  },

  // Add password reset support
  forgetPassword: {
    enabled: true,
    sendResetPassword: emailHandlers.sendPasswordResetEmail,
  },
});

// Example 3: Send welcome email on successful signup
export const authWithWelcomeEmail = betterAuth({
  appName: 'Basecase',
  database: prismaAdapter(prisma, {
    provider: 'postgresql',
  }),

  emailAndPassword: {
    enabled: true,
    autoSignIn: true,
    requireEmailVerification: false, // No verification required for this example
  },

  // Custom hooks
  hooks: {
    after: [
      {
        matcher: (context) => context.path === '/signup',
        handler: async (context) => {
          if (context.response?.user) {
            // Send welcome email after successful signup
            await emailHandlers.sendWelcomeEmail({
              user: context.response.user,
              dashboardUrl: '/dashboard',
            });
          }
          return context;
        },
      },
    ],
  },
});
