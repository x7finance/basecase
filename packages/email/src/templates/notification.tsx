import { Button, Heading, Section, Text } from '@react-email/components';

import type { NotificationEmailProps } from '../types';
import { BaseEmailTemplate, styles } from './base';

export function NotificationTemplate({
  title,
  message,
  actionUrl,
  actionText,
  // userEmail,
  appName = 'Basecase',
  baseUrl,
}: NotificationEmailProps) {
  return (
    <BaseEmailTemplate appName={appName} baseUrl={baseUrl} preview={title}>
      <Heading style={styles.h1}>{title}</Heading>

      <Text style={styles.text}>{message}</Text>

      {actionUrl && actionText && (
        <Section style={styles.buttonContainer}>
          <Button href={actionUrl} style={styles.button}>
            {actionText}
          </Button>
        </Section>
      )}

      <Text style={styles.mutedText}>
        You're receiving this notification because you're subscribed to updates
        from {appName}.
      </Text>
    </BaseEmailTemplate>
  );
}

NotificationTemplate.PreviewProps = {
  title: 'New Feature Available',
  message:
    "We've just released a new feature that we think you'll love. Check it out and let us know what you think!",
  actionUrl: 'https://example.com/features',
  actionText: 'View Feature',
  userEmail: 'user@example.com',
  appName: 'Basecase',
} as NotificationEmailProps;

export default NotificationTemplate;
