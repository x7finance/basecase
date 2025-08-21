import { Heading, Link, Text } from '@react-email/components';

import type { PasswordResetEmailProps } from '../types';
import { BaseEmailTemplate, styles } from './base';

export function PasswordResetTemplate({
  resetUrl,
  // userEmail,
  appName = 'Basecase',
  expiresIn = '1 hour',
  baseUrl,
}: PasswordResetEmailProps) {
  return (
    <BaseEmailTemplate
      appName={appName}
      baseUrl={baseUrl}
      preview="Reset your password"
    >
      <Heading style={styles.h1}>Reset your password</Heading>

      <Text style={styles.text}>
        We received a request to reset your password for your {appName} account.
      </Text>

      <Link
        href={resetUrl}
        style={{
          ...styles.link,
          display: 'block',
          marginBottom: '16px',
        }}
        target="_blank"
      >
        Click here to reset your password
      </Link>

      <Text style={{ ...styles.text, marginBottom: '14px' }}>
        Or, copy and paste this link into your browser:
      </Text>

      <code style={styles.code}>{resetUrl}</code>

      <Text style={styles.mutedText}>
        This link will expire in {expiresIn} for security reasons.
      </Text>

      <Text style={styles.mutedText}>
        If you didn't request a password reset, you can safely ignore this
        email. Your password won't be changed.
      </Text>
    </BaseEmailTemplate>
  );
}

PasswordResetTemplate.PreviewProps = {
  resetUrl: 'https://example.com/reset-password?token=abc123',
  userEmail: 'user@example.com',
  appName: 'Basecase',
  expiresIn: '1 hour',
} as PasswordResetEmailProps;

export default PasswordResetTemplate;
