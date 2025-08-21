import { Heading, Link, Text } from '@react-email/components';

import type { MagicLinkEmailProps } from '../types';
import { BaseEmailTemplate, styles } from './base';

export function MagicLinkTemplate({
  loginCode,
  magicLinkUrl,
  // userEmail,
  appName = 'Basecase',
  baseUrl,
}: MagicLinkEmailProps) {
  return (
    <BaseEmailTemplate
      appName={appName}
      baseUrl={baseUrl}
      preview="Log in with this magic link"
    >
      <Heading style={styles.h1}>Login</Heading>

      <Link
        href={magicLinkUrl}
        style={{
          ...styles.link,
          display: 'block',
          marginBottom: '16px',
        }}
        target="_blank"
      >
        Click here to log in with this magic link
      </Link>

      <Text style={{ ...styles.text, marginBottom: '14px' }}>
        Or, copy and paste this temporary login code:
      </Text>

      <code style={styles.code}>{loginCode}</code>

      <Text style={styles.mutedText}>
        If you didn't try to login, you can safely ignore this email.
      </Text>

      <Text style={styles.mutedText}>
        Hint: You can set a permanent password in Settings → My account.
      </Text>
    </BaseEmailTemplate>
  );
}

MagicLinkTemplate.PreviewProps = {
  loginCode: 'sparo-ndigo-amurt-secan',
  magicLinkUrl: 'https://example.com/magic-link?token=abc123',
  userEmail: 'user@example.com',
  appName: 'Basecase',
} as MagicLinkEmailProps;

export default MagicLinkTemplate;
