import {
  Body,
  Button,
  Container,
  Head,
  Heading,
  Hr,
  Html,
  Link,
  Preview,
  Section,
  Text,
} from '@react-email/components';
import type { PasswordResetEmailProps } from '../types';

export function PasswordResetTemplate({
  resetUrl,
  userEmail,
  appName = 'Basecase',
  expiresIn = '1 hour',
}: PasswordResetEmailProps) {
  return (
    <Html>
      <Head />
      <Preview>Reset your {appName} password</Preview>
      <Body style={main}>
        <Container style={container}>
          <Heading style={h1}>Reset Your Password</Heading>

          <Text style={text}>Hi there,</Text>

          <Text style={text}>
            We received a request to reset the password for your {appName}{' '}
            account associated with {userEmail}.
          </Text>

          <Text style={text}>
            Click the button below to reset your password:
          </Text>

          <Section style={buttonContainer}>
            <Button href={resetUrl} style={button}>
              Reset Password
            </Button>
          </Section>

          <Text style={smallText}>
            Or copy and paste this URL into your browser:
          </Text>

          <Link href={resetUrl} style={link}>
            {resetUrl}
          </Link>

          <Hr style={hr} />

          <Section style={warningSection}>
            <Text style={warningTitle}>Important Security Information:</Text>
            <ul style={list}>
              <li style={listItem}>This link will expire in {expiresIn}</li>
              <li style={listItem}>
                If you didn't request this, please ignore this email
              </li>
              <li style={listItem}>
                Your password won't change until you create a new one
              </li>
            </ul>
          </Section>

          <Text style={footerText}>
            For security reasons, this password reset link can only be used
            once. If you need to reset your password again, please request a new
            link.
          </Text>

          <Section style={footer}>
            <Text style={footerText}>— The {appName} Security Team</Text>
          </Section>
        </Container>
      </Body>
    </Html>
  );
}

PasswordResetTemplate.PreviewProps = {
  resetUrl: 'https://example.com/auth/reset-password?token=abc123',
  userEmail: 'user@example.com',
  appName: 'Basecase',
  expiresIn: '1 hour',
} as PasswordResetEmailProps;

export default PasswordResetTemplate;

const main = {
  backgroundColor: '#f6f9fc',
  fontFamily:
    '-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Ubuntu,sans-serif',
};

const container = {
  backgroundColor: '#ffffff',
  margin: '0 auto',
  padding: '20px 0 48px',
  marginBottom: '64px',
  borderRadius: '5px',
  boxShadow: '0 1px 3px rgba(0, 0, 0, 0.1)',
  maxWidth: '580px',
};

const h1 = {
  color: '#333',
  fontSize: '24px',
  fontWeight: '600',
  lineHeight: '1.3',
  margin: '0 0 20px',
  padding: '24px 20px 0',
  textAlign: 'center' as const,
};

const text = {
  color: '#555',
  fontSize: '16px',
  lineHeight: '1.6',
  margin: '16px 20px',
};

const buttonContainer = {
  padding: '20px',
  textAlign: 'center' as const,
};

const button = {
  backgroundColor: '#dc2626',
  borderRadius: '5px',
  color: '#fff',
  display: 'inline-block',
  fontSize: '16px',
  fontWeight: '600',
  lineHeight: '1',
  padding: '16px 32px',
  textDecoration: 'none',
  textAlign: 'center' as const,
};

const link = {
  color: '#2754C5',
  fontSize: '14px',
  margin: '16px 20px',
  textDecoration: 'underline',
  wordBreak: 'break-all' as const,
  display: 'block',
};

const hr = {
  borderColor: '#e6e6e6',
  margin: '32px 20px',
};

const warningSection = {
  backgroundColor: '#fef3c7',
  borderRadius: '6px',
  padding: '16px 20px',
  margin: '24px 20px',
};

const warningTitle = {
  color: '#92400e',
  fontSize: '15px',
  fontWeight: '600',
  margin: '0 0 12px',
};

const list = {
  margin: '8px 0',
  paddingLeft: '20px',
};

const listItem = {
  color: '#92400e',
  fontSize: '14px',
  lineHeight: '1.6',
  margin: '4px 0',
};

const smallText = {
  color: '#666',
  fontSize: '14px',
  lineHeight: '1.5',
  margin: '16px 20px',
};

const footer = {
  borderTop: '1px solid #e6e6e6',
  marginTop: '32px',
  paddingTop: '20px',
};

const footerText = {
  color: '#999',
  fontSize: '14px',
  lineHeight: '1.5',
  margin: '16px 20px',
  textAlign: 'center' as const,
};
