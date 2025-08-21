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
import type { WelcomeEmailProps } from '../types';

export function WelcomeTemplate({
  firstName,
  appName = 'Basecase',
  dashboardUrl = '/dashboard',
  baseUrl,
}: WelcomeEmailProps) {
  const url =
    baseUrl || process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000';
  const fullDashboardUrl = dashboardUrl.startsWith('http')
    ? dashboardUrl
    : `${url}${dashboardUrl}`;

  return (
    <Html>
      <Head />
      <Preview>
        Welcome to {appName}, {firstName}!
      </Preview>
      <Body style={main}>
        <Container style={container}>
          <Heading style={h1}>Welcome to {appName}!</Heading>

          <Text style={text}>Hi {firstName},</Text>

          <Text style={text}>
            We're excited to have you on board! Your account has been
            successfully created and you're all set to start exploring {appName}
            .
          </Text>

          <Section style={featureSection}>
            <Heading style={h2}>Here's what you can do:</Heading>
            <ul style={list}>
              <li style={listItem}>Create and manage your projects</li>
              <li style={listItem}>Collaborate with your team</li>
              <li style={listItem}>Track your progress and analytics</li>
              <li style={listItem}>Customize your workspace</li>
            </ul>
          </Section>

          <Section style={buttonContainer}>
            <Button href={fullDashboardUrl} style={button}>
              Go to Dashboard
            </Button>
          </Section>

          <Hr style={hr} />

          <Section style={helpSection}>
            <Heading style={h3}>Need Help?</Heading>
            <Text style={smallText}>
              If you have any questions or need assistance, feel free to:
            </Text>
            <ul style={list}>
              <li style={listItem}>
                Check out our{' '}
                <Link href={`${url}/docs`} style={link}>
                  documentation
                </Link>
              </li>
              <li style={listItem}>
                Contact our{' '}
                <Link href={`${url}/support`} style={link}>
                  support team
                </Link>
              </li>
              <li style={listItem}>
                Join our{' '}
                <Link href={`${url}/community`} style={link}>
                  community
                </Link>
              </li>
            </ul>
          </Section>

          <Text style={footerText}>
            Happy building!
            <br />
            The {appName} Team
          </Text>
        </Container>
      </Body>
    </Html>
  );
}

WelcomeTemplate.PreviewProps = {
  firstName: 'John',
  userEmail: 'john@example.com',
  appName: 'Basecase',
  dashboardUrl: 'https://example.com/dashboard',
} as WelcomeEmailProps;

export default WelcomeTemplate;

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
  borderRadius: '8px',
  boxShadow: '0 2px 8px rgba(0, 0, 0, 0.05)',
  maxWidth: '600px',
};

const h1 = {
  color: '#2754C5',
  fontSize: '28px',
  fontWeight: '700',
  lineHeight: '1.3',
  margin: '0 0 20px',
  padding: '24px 20px 0',
  textAlign: 'center' as const,
};

const h2 = {
  color: '#333',
  fontSize: '20px',
  fontWeight: '600',
  lineHeight: '1.4',
  margin: '0 0 16px',
};

const h3 = {
  color: '#333',
  fontSize: '18px',
  fontWeight: '600',
  lineHeight: '1.4',
  margin: '0 0 12px',
};

const text = {
  color: '#555',
  fontSize: '16px',
  lineHeight: '1.6',
  margin: '16px 20px',
};

const featureSection = {
  padding: '20px',
  backgroundColor: '#f8f9fa',
  borderRadius: '6px',
  margin: '24px 20px',
};

const helpSection = {
  padding: '20px',
  margin: '24px 20px',
};

const list = {
  paddingLeft: '20px',
  margin: '12px 0',
};

const listItem = {
  color: '#555',
  fontSize: '15px',
  lineHeight: '1.8',
  margin: '8px 0',
};

const buttonContainer = {
  padding: '20px',
  textAlign: 'center' as const,
};

const button = {
  backgroundColor: '#2754C5',
  borderRadius: '6px',
  color: '#fff',
  display: 'inline-block',
  fontSize: '16px',
  fontWeight: '600',
  lineHeight: '1',
  padding: '16px 36px',
  textDecoration: 'none',
  textAlign: 'center' as const,
};

const link = {
  color: '#2754C5',
  textDecoration: 'underline',
};

const hr = {
  borderColor: '#e6e6e6',
  margin: '32px 20px',
};

const smallText = {
  color: '#666',
  fontSize: '14px',
  lineHeight: '1.5',
  margin: '8px 0 12px',
};

const footerText = {
  color: '#999',
  fontSize: '14px',
  lineHeight: '1.8',
  margin: '32px 20px 16px',
  textAlign: 'center' as const,
};
