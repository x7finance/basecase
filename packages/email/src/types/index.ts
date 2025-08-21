export type BaseEmailProps = {
  baseUrl?: string;
};

export interface EmailVerificationProps extends BaseEmailProps {
  verificationUrl: string;
  userEmail: string;
  appName?: string;
}

export interface MagicLinkEmailProps extends BaseEmailProps {
  loginCode: string;
  magicLinkUrl: string;
  userEmail?: string;
  appName?: string;
}

export interface WelcomeEmailProps extends BaseEmailProps {
  firstName: string;
  userEmail: string;
  appName?: string;
  dashboardUrl?: string;
}

export interface NotificationEmailProps extends BaseEmailProps {
  title: string;
  message: string;
  actionUrl?: string;
  actionText?: string;
  userEmail: string;
  appName?: string;
}

export interface PasswordResetEmailProps extends BaseEmailProps {
  resetUrl: string;
  userEmail: string;
  appName?: string;
  expiresIn?: string;
}

export type EmailTemplate =
  | 'email-verification'
  | 'magic-link'
  | 'welcome'
  | 'notification'
  | 'password-reset';

export type SendEmailOptions = {
  from: string;
  to: string | string[];
  subject: string;
  react?: React.ReactElement;
  html?: string;
  text?: string;
  attachments?: Array<{
    filename: string;
    content: Buffer | string;
  }>;
  headers?: Record<string, string>;
  cc?: string | string[];
  bcc?: string | string[];
  replyTo?: string | string[];
};
