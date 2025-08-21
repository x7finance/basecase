import {
  Body,
  Button,
  Container,
  Head,
  Heading,
  Html,
  Link,
  Preview,
  Section,
  Text,
} from '@react-email/components';
import type { EmailVerificationProps } from '../types';

const baseUrl = process.env.VERCEL_URL
  ? `https://${process.env.VERCEL_URL}`
  : process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000';

export function EmailVerificationTemplate({
  verificationUrl,
  userEmail: _userEmail,
  appName = 'Basecase',
  baseUrl: customBaseUrl,
}: EmailVerificationProps) {
  const _url = customBaseUrl || baseUrl;

  return (
    <Html>
      <Head />
      <Preview>Verify your email address for {appName}</Preview>
      <Body style={main}>
        <Container style={container}>
          <Heading style={h1}>Verify Your Email Address</Heading>

          <Text style={text}>Hi there,</Text>

          <Text style={text}>
            Thanks for signing up for {appName}! Please verify your email
            address by clicking the button below:
          </Text>

          <Section style={buttonContainer}>
            <Button href={verificationUrl} style={button}>
              Verify Email Address
            </Button>
          </Section>

          <Text style={text}>
            Or copy and paste this URL into your browser:
          </Text>

          <Link href={verificationUrl} style={link}>
            {verificationUrl}
          </Link>

          <Text style={{ ...text, marginTop: '24px' }}>
            This verification link will expire in 24 hours for security reasons.
          </Text>

          <Text style={footerText}>
            If you didn't create an account with {appName}, you can safely
            ignore this email.
          </Text>

          <Section style={footer}>
            <Text style={footerText}>{appName} - Secure and Simple</Text>
          </Section>
        </Container>
      </Body>
    </Html>
  );
}

EmailVerificationTemplate.PreviewProps = {
  verificationUrl: 'https://example.com/verify?token=abc123',
  userEmail: 'user@example.com',
  appName: 'Basecase',
} as EmailVerificationProps;

export default EmailVerificationTemplate;

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
  backgroundColor: '#2754C5',
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
