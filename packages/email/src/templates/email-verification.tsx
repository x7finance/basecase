import { Heading, Link, Text } from '@react-email/components';
import type { EmailVerificationProps } from '../types';
import { BaseEmailTemplate, styles } from './base';

export function EmailVerificationTemplate({
  verificationUrl,
  // userEmail,
  appName = 'Basecase',
  baseUrl,
}: EmailVerificationProps) {
  return (
    <BaseEmailTemplate
      appName={appName}
      baseUrl={baseUrl}
      preview="Verify your email address"
    >
      <Heading style={styles.h1}>Verify your email</Heading>

      <Link
        href={verificationUrl}
        style={{
          ...styles.link,
          display: 'block',
          marginBottom: '16px',
        }}
        target="_blank"
      >
        Click here to verify your email address
      </Link>

      <Text style={{ ...styles.text, marginBottom: '14px' }}>
        Or, copy and paste this link into your browser:
      </Text>

      <code style={styles.code}>{verificationUrl}</code>

      <Text style={styles.mutedText}>
        If you didn't create an account with {appName}, you can safely ignore
        this email.
      </Text>

      <Text style={styles.mutedText}>
        This verification link will expire in 24 hours for security reasons.
      </Text>
    </BaseEmailTemplate>
  );
}

EmailVerificationTemplate.PreviewProps = {
  verificationUrl: 'https://example.com/verify?token=abc123',
  userEmail: 'user@example.com',
  appName: 'Basecase',
} as EmailVerificationProps;

export default EmailVerificationTemplate;
