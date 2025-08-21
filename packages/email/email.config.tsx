import { EmailVerificationTemplate } from './src/templates/email-verification';
import { MagicLinkTemplate } from './src/templates/magic-link';
import { NotificationTemplate } from './src/templates/notification';
import { PasswordResetTemplate } from './src/templates/password-reset';
import { WelcomeTemplate } from './src/templates/welcome';

export default {
  emails: [
    {
      name: 'Email Verification',
      component: EmailVerificationTemplate,
      props: EmailVerificationTemplate.PreviewProps,
    },
    {
      name: 'Magic Link',
      component: MagicLinkTemplate,
      props: MagicLinkTemplate.PreviewProps,
    },
    {
      name: 'Welcome',
      component: WelcomeTemplate,
      props: WelcomeTemplate.PreviewProps,
    },
    {
      name: 'Notification',
      component: NotificationTemplate,
      props: NotificationTemplate.PreviewProps,
    },
    {
      name: 'Password Reset',
      component: PasswordResetTemplate,
      props: PasswordResetTemplate.PreviewProps,
    },
  ],
};
