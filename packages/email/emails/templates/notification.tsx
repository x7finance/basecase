import {
  Body,
  Button,
  Container,
  Head,
  Heading,
  Html,
  Preview,
  Section,
  Text,
} from '@react-email/components';
import type { NotificationEmailProps } from '../types';

export function NotificationTemplate({
  title,
  message,
  actionUrl,
  actionText,
  userEmail,
  appName = 'Basecase',
}: NotificationEmailProps) {
  return (
    <Html>
      <Head />
      <Preview>{title}</Preview>
      <Body style={main}>
        <Container style={container}>
          <Section style={header}>
            <Text style={appNameText}>{appName}</Text>
          </Section>

          <Heading style={h1}>{title}</Heading>

          <Text style={text}>{message}</Text>

          {actionUrl && actionText && (
            <Section style={buttonContainer}>
              <Button href={actionUrl} style={button}>
                {actionText}
              </Button>
            </Section>
          )}

          <Section style={footer}>
            <Text style={footerText}>
              This notification was sent to {userEmail}
            </Text>
            <Text style={footerText}>
              You received this email because you have notifications enabled for{' '}
              {appName}.
            </Text>
          </Section>
        </Container>
      </Body>
    </Html>
  );
}

NotificationTemplate.PreviewProps = {
  title: 'New Activity in Your Project',
  message:
    'John Doe commented on your recent update: "Great work on this feature! The implementation looks solid."',
  actionUrl: 'https://example.com/projects/123',
  actionText: 'View Comment',
  userEmail: 'user@example.com',
  appName: 'Basecase',
} as NotificationEmailProps;

export default NotificationTemplate;

const main = {
  backgroundColor: '#f4f4f5',
  fontFamily:
    '-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Ubuntu,sans-serif',
};

const container = {
  backgroundColor: '#ffffff',
  margin: '40px auto',
  padding: '0',
  borderRadius: '8px',
  boxShadow: '0 1px 3px rgba(0, 0, 0, 0.1)',
  maxWidth: '580px',
  overflow: 'hidden',
};

const header = {
  backgroundColor: '#2754C5',
  padding: '20px',
  textAlign: 'center' as const,
};

const appNameText = {
  color: '#ffffff',
  fontSize: '18px',
  fontWeight: '600',
  margin: '0',
};

const h1 = {
  color: '#18181b',
  fontSize: '22px',
  fontWeight: '600',
  lineHeight: '1.3',
  margin: '0',
  padding: '30px 30px 20px',
};

const text = {
  color: '#3f3f46',
  fontSize: '16px',
  lineHeight: '1.6',
  margin: '0',
  padding: '0 30px 30px',
};

const buttonContainer = {
  padding: '0 30px 30px',
};

const button = {
  backgroundColor: '#2754C5',
  borderRadius: '6px',
  color: '#fff',
  display: 'inline-block',
  fontSize: '15px',
  fontWeight: '600',
  lineHeight: '1',
  padding: '12px 24px',
  textDecoration: 'none',
  textAlign: 'center' as const,
};

const footer = {
  borderTop: '1px solid #e4e4e7',
  padding: '20px 30px',
};

const footerText = {
  color: '#71717a',
  fontSize: '13px',
  lineHeight: '1.5',
  margin: '0 0 8px',
};
