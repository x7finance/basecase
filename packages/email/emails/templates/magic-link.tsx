import {
  Body,
  Button,
  Container,
  Head,
  Heading,
  Hr,
  Html,
  Preview,
  Section,
  Text,
} from '@react-email/components';
import type { MagicLinkEmailProps } from '../types';

export function MagicLinkTemplate({
  loginCode,
  magicLinkUrl,
  userEmail,
  appName = 'Basecase',
}: MagicLinkEmailProps) {
  return (
    <Html>
      <Head />
      <Preview>Log in to {appName} with this magic link</Preview>
      <Body style={main}>
        <Container style={container}>
          <Heading style={h1}>Login to {appName}</Heading>

          <Text style={text}>Hi{userEmail ? ` ${userEmail}` : ''},</Text>

          <Text style={text}>
            Click the button below to log in to your account:
          </Text>

          <Section style={buttonContainer}>
            <Button href={magicLinkUrl} style={button}>
              Log in to {appName}
            </Button>
          </Section>

          <Hr style={hr} />

          <Text style={text}>
            Or, copy and paste this temporary login code:
          </Text>

          <code style={code}>{loginCode}</code>

          <Text style={smallText}>
            This magic link and code will expire in 10 minutes for security
            reasons.
          </Text>

          <Hr style={hr} />

          <Text style={footerText}>
            If you didn't try to login, you can safely ignore this email.
          </Text>

          <Text style={hint}>
            Hint: You can set a permanent password in your account settings.
          </Text>
        </Container>
      </Body>
    </Html>
  );
}

MagicLinkTemplate.PreviewProps = {
  loginCode: 'sparo-ndigo-amurt-secan',
  magicLinkUrl: 'https://example.com/auth/magic-link?token=abc123',
  userEmail: 'user@example.com',
  appName: 'Basecase',
} as MagicLinkEmailProps;

export default MagicLinkTemplate;

const main = {
  backgroundColor: '#ffffff',
  fontFamily:
    '-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Oxygen-Sans,Ubuntu,Cantarell,"Helvetica Neue",sans-serif',
};

const container = {
  margin: '0 auto',
  padding: '20px 12px 48px',
  maxWidth: '550px',
};

const h1 = {
  color: '#333',
  fontSize: '24px',
  fontWeight: 'bold',
  lineHeight: '1.3',
  margin: '40px 0 20px',
  padding: '0',
  textAlign: 'center' as const,
};

const text = {
  color: '#333',
  fontSize: '16px',
  lineHeight: '1.6',
  margin: '24px 0',
};

const buttonContainer = {
  margin: '32px 0',
  textAlign: 'center' as const,
};

const button = {
  backgroundColor: '#2754C5',
  borderRadius: '8px',
  color: '#fff',
  display: 'inline-block',
  fontSize: '16px',
  fontWeight: '600',
  padding: '14px 28px',
  textDecoration: 'none',
  textAlign: 'center' as const,
};

const code = {
  display: 'inline-block',
  padding: '16px 24px',
  width: '100%',
  backgroundColor: '#f4f4f4',
  borderRadius: '5px',
  border: '1px solid #eee',
  color: '#333',
  fontSize: '18px',
  fontWeight: 'bold',
  letterSpacing: '2px',
  textAlign: 'center' as const,
  margin: '16px 0',
};

const hr = {
  borderColor: '#e6e6e6',
  margin: '32px 0',
};

const smallText = {
  color: '#666',
  fontSize: '14px',
  lineHeight: '1.5',
  margin: '16px 0',
};

const footerText = {
  color: '#999',
  fontSize: '14px',
  lineHeight: '1.5',
  margin: '24px 0 8px',
};

const hint = {
  color: '#999',
  fontSize: '13px',
  fontStyle: 'italic',
  lineHeight: '1.5',
  margin: '8px 0 32px',
};
