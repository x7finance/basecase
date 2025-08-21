/** biome-ignore-all lint/performance/noBarrelFile: will fix */
import { adminDb } from '@basecase/database';
import { createBetterAuthEmailHandlers } from '@basecase/email';
import { env } from '@basecase/env';
import { instantDBAdapter } from '@daveyplate/better-auth-instantdb';
import { betterAuth } from 'better-auth';

export { toNextJsHandler } from 'better-auth/next-js';

// Create email handlers if Resend API key is provided
const emailHandlers = env.RESEND_API_KEY
  ? createBetterAuthEmailHandlers({
      resendApiKey: env.RESEND_API_KEY,
      from: env.RESEND_FROM_EMAIL,
      appName: 'Basecase',
      baseUrl: env.NEXT_PUBLIC_APP_URL,
    })
  : null;

// Build social providers config only if credentials are provided

const socialProviders: Record<
  string,
  { clientId: string; clientSecret: string }
> = {};

if (env.GOOGLE_CLIENT_ID && env.GOOGLE_CLIENT_SECRET) {
  socialProviders.google = {
    clientId: env.GOOGLE_CLIENT_ID,
    clientSecret: env.GOOGLE_CLIENT_SECRET,
  };
}

if (env.GITHUB_CLIENT_ID && env.GITHUB_CLIENT_SECRET) {
  socialProviders.github = {
    clientId: env.GITHUB_CLIENT_ID,
    clientSecret: env.GITHUB_CLIENT_SECRET,
  };
}

export const auth = adminDb
  ? betterAuth({
      database: instantDBAdapter({
        db: adminDb,
        usePlural: true,
        debugLogs: env.BUN_ENV === 'development',
      }),
      emailAndPassword: {
        enabled: true,
        autoSignIn: true,
        requireEmailVerification: false, // Allow users to sign in without verification
        // Send welcome email on signup if email handlers are available
        ...(emailHandlers && {
          sendResetPasswordToken: emailHandlers.sendPasswordResetEmail,
        }),
      },
      // Add email verification configuration if email handlers are available
      ...(emailHandlers && {
        emailVerification: {
          sendOnSignUp: true,
          autoSignInAfterVerification: true,
          sendVerificationEmail: emailHandlers.sendVerificationEmail,
        },
      }),
      ...(Object.keys(socialProviders).length > 0 && { socialProviders }),
      secret: env.BETTER_AUTH_SECRET,
      trustedOrigins: env.BETTER_AUTH_TRUSTED_ORIGINS?.split(',') || [
        'http://localhost:3001',
      ],
    })
  : null;
