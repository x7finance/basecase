import { Button, Heading, Section, Text } from '@react-email/components';

import type { WelcomeEmailProps } from '../types';
import { BaseEmailTemplate, styles } from './base';

export function WelcomeTemplate({
  firstName,

  appName = 'Basecase',
  dashboardUrl = '/dashboard',
  baseUrl,
}: WelcomeEmailProps) {
  const fullDashboardUrl = dashboardUrl.startsWith('http')
    ? dashboardUrl
    : `${baseUrl || 'http://localhost:3001'}${dashboardUrl}`;

  return (
    <BaseEmailTemplate
      appName={appName}
      baseUrl={baseUrl}
      preview={`Welcome to ${appName}!`}
    >
      <Heading style={styles.h1}>Welcome to {appName}!</Heading>

      <Text style={styles.text}>Hi {firstName},</Text>

      <Text style={styles.text}>
        Thanks for signing up! We're excited to have you on board. Your account
        has been successfully created and you're ready to get started.
      </Text>

      <Section style={styles.buttonContainer}>
        <Button href={fullDashboardUrl} style={styles.button}>
          Go to Dashboard
        </Button>
      </Section>

      <Text style={styles.text}>
        Here are a few things you can do to get started:
      </Text>

      <Text style={{ ...styles.text, marginLeft: '20px' }}>
        • Complete your profile
        <br />• Explore the dashboard
        <br />• Check out our documentation
      </Text>

      <Text style={styles.mutedText}>
        If you have any questions, feel free to reply to this email. We're here
        to help!
      </Text>
    </BaseEmailTemplate>
  );
}

WelcomeTemplate.PreviewProps = {
  firstName: 'John',
  userEmail: 'john@example.com',
  appName: 'Basecase',
  dashboardUrl: '/dashboard',
} as WelcomeEmailProps;

export default WelcomeTemplate;
