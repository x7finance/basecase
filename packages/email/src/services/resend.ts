import { render } from '@react-email/render';
import { Resend } from 'resend';
import {
  EmailVerificationTemplate,
  MagicLinkTemplate,
  NotificationTemplate,
  PasswordResetTemplate,
  WelcomeTemplate,
} from '../templates';
import type {
  EmailTemplate,
  EmailVerificationProps,
  MagicLinkEmailProps,
  NotificationEmailProps,
  PasswordResetEmailProps,
  SendEmailOptions,
  WelcomeEmailProps,
} from '../types';

export class EmailService {
  private readonly resend: Resend;
  private readonly from: string;
  private readonly appName: string;
  private readonly baseUrl?: string;

  constructor(config: {
    apiKey: string;
    from?: string;
    appName?: string;
    baseUrl?: string;
  }) {
    this.resend = new Resend(config.apiKey);
    this.from = config.from || 'onboarding@resend.dev';
    this.appName = config.appName || 'Basecase';
    this.baseUrl = config.baseUrl;
  }

  async sendEmail(options: SendEmailOptions) {
    // Build email options for Resend
    const emailOptions = {
      from: options.from,
      to: options.to,
      subject: options.subject,
      ...(options.react && { react: options.react }),
      ...(options.html && { html: options.html }),
      ...(options.text && { text: options.text }),
      ...(options.attachments && { attachments: options.attachments }),
      ...(options.headers && { headers: options.headers }),
      ...(options.cc && { cc: options.cc }),
      ...(options.bcc && { bcc: options.bcc }),
      ...(options.replyTo && { replyTo: options.replyTo }),
    };

    const { data, error } = await this.resend.emails.send(emailOptions as Parameters<typeof this.resend.emails.send>[0]);

    if (error) {
      throw new Error(`Failed to send email: ${error.message}`);
    }

    return { success: true, data };
  }

  async sendEmailVerification(
    props: Omit<EmailVerificationProps, 'appName' | 'baseUrl'> & { to: string }
  ) {
    const { to, ...emailProps } = props;

    const emailHtml = await render(
      EmailVerificationTemplate({
        ...emailProps,
        appName: this.appName,
        baseUrl: this.baseUrl,
      })
    );

    return this.sendEmail({
      from: this.from,
      to,
      subject: `Verify your email for ${this.appName}`,
      react: EmailVerificationTemplate({
        ...emailProps,
        appName: this.appName,
        baseUrl: this.baseUrl,
      }),
      html: emailHtml,
    });
  }

  async sendMagicLink(
    props: Omit<MagicLinkEmailProps, 'appName' | 'baseUrl'> & { to: string }
  ) {
    const { to, ...emailProps } = props;

    const emailHtml = await render(
      MagicLinkTemplate({
        ...emailProps,
        appName: this.appName,
        baseUrl: this.baseUrl,
      })
    );

    return this.sendEmail({
      from: this.from,
      to,
      subject: `Your magic link for ${this.appName}`,
      react: MagicLinkTemplate({
        ...emailProps,
        appName: this.appName,
        baseUrl: this.baseUrl,
      }),
      html: emailHtml,
    });
  }

  async sendWelcomeEmail(
    props: Omit<WelcomeEmailProps, 'appName' | 'baseUrl'> & { to: string }
  ) {
    const { to, ...emailProps } = props;

    const emailHtml = await render(
      WelcomeTemplate({
        ...emailProps,
        appName: this.appName,
        baseUrl: this.baseUrl,
      })
    );

    return this.sendEmail({
      from: this.from,
      to,
      subject: `Welcome to ${this.appName}!`,
      react: WelcomeTemplate({
        ...emailProps,
        appName: this.appName,
        baseUrl: this.baseUrl,
      }),
      html: emailHtml,
    });
  }

  async sendNotification(
    props: Omit<NotificationEmailProps, 'appName' | 'baseUrl'> & { to: string }
  ) {
    const { to, title, ...emailProps } = props;

    const emailHtml = await render(
      NotificationTemplate({
        ...emailProps,
        title,
        appName: this.appName,
        baseUrl: this.baseUrl,
      })
    );

    return this.sendEmail({
      from: this.from,
      to,
      subject: title,
      react: NotificationTemplate({
        ...emailProps,
        title,
        appName: this.appName,
        baseUrl: this.baseUrl,
      }),
      html: emailHtml,
    });
  }

  async sendPasswordReset(
    props: Omit<PasswordResetEmailProps, 'appName' | 'baseUrl'> & { to: string }
  ) {
    const { to, ...emailProps } = props;

    const emailHtml = await render(
      PasswordResetTemplate({
        ...emailProps,
        appName: this.appName,
        baseUrl: this.baseUrl,
      })
    );

    return this.sendEmail({
      from: this.from,
      to,
      subject: `Reset your ${this.appName} password`,
      react: PasswordResetTemplate({
        ...emailProps,
        appName: this.appName,
        baseUrl: this.baseUrl,
      }),
      html: emailHtml,
    });
  }

  sendTemplatedEmail(
    template: EmailTemplate,
    props: any & { to: string }
  ) {
    switch (template) {
      case 'email-verification':
        return this.sendEmailVerification(props as any);
      case 'magic-link':
        return this.sendMagicLink(props as any);
      case 'welcome':
        return this.sendWelcomeEmail(props as any);
      case 'notification':
        return this.sendNotification(props as any);
      case 'password-reset':
        return this.sendPasswordReset(props as any);
      default:
        throw new Error(`Unknown email template: ${template}`);
    }
  }
}

export function createEmailService(config: {
  apiKey: string;
  from?: string;
  appName?: string;
  baseUrl?: string;
}) {
  return new EmailService(config);
}
