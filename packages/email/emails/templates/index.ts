/** biome-ignore-all lint/performance/noBarrelFile: this is a barrel file */
export {
  default as EmailVerification,
  EmailVerificationTemplate,
} from './email-verification';
export { default as MagicLink, MagicLinkTemplate } from './magic-link';
export { default as Notification, NotificationTemplate } from './notification';
export {
  default as PasswordReset,
  PasswordResetTemplate,
} from './password-reset';
export { default as Welcome, WelcomeTemplate } from './welcome';
