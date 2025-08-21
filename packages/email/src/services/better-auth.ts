import { EmailService } from './resend';

type BetterAuthEmailConfig = {
  resendApiKey: string;
  from?: string;
  appName?: string;
  baseUrl?: string;
};

export function createBetterAuthEmailHandlers(config: BetterAuthEmailConfig) {
  const emailService = new EmailService({
    apiKey: config.resendApiKey,
    from: config.from || 'onboarding@resend.dev',
    appName: config.appName || 'Basecase',
    baseUrl: config.baseUrl,
  });

  return {
    sendVerificationEmail: async ({
      user,
      url,
    }: {
      user: { email: string; name?: string };
      url: string;
    }) => {
      await emailService.sendEmailVerification({
        to: user.email,
        verificationUrl: url,
        userEmail: user.email,
      });
    },

    sendPasswordResetEmail: async ({
      user,
      url,
    }: {
      user: { email: string; name?: string };
      url: string;
    }) => {
      await emailService.sendPasswordReset({
        to: user.email,
        resetUrl: url,
        userEmail: user.email,
        expiresIn: '1 hour',
      });
    },

    sendMagicLinkEmail: async ({
      user,
      url,
      code,
    }: {
      user: { email: string; name?: string };
      url: string;
      code: string;
    }) => {
      await emailService.sendMagicLink({
        to: user.email,
        magicLinkUrl: url,
        loginCode: code,
        userEmail: user.email,
      });
    },

    sendWelcomeEmail: async ({
      user,
      dashboardUrl = '/dashboard',
    }: {
      user: { email: string; name?: string };
      dashboardUrl?: string;
    }) => {
      await emailService.sendWelcomeEmail({
        to: user.email,
        firstName: user.name || 'there',
        userEmail: user.email,
        dashboardUrl,
      });
    },
  };
}

export function getBetterAuthEmailConfig(config: BetterAuthEmailConfig) {
  const handlers = createBetterAuthEmailHandlers(config);

  return {
    emailVerification: {
      sendOnSignUp: true,
      autoSignInAfterVerification: true,
      sendVerificationEmail: handlers.sendVerificationEmail,
    },

    magicLink: {
      sendMagicLink: handlers.sendMagicLinkEmail,
    },

    forgetPassword: {
      sendResetPassword: handlers.sendPasswordResetEmail,
    },
  };
}
