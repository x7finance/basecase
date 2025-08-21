import {
  Body,
  Container,
  Head,
  Html,
  Img,
  Link,
  Preview,
  Text,
} from '@react-email/components';
import type * as React from 'react';

export type BaseEmailProps = {
  preview: string;
  children: React.ReactNode;
  appName?: string;
  appLogo?: string;
  appTagline?: string;
  baseUrl?: string;
};

export function BaseEmailTemplate({
  preview,
  children,
  appName = 'Basecase',
  appLogo,
  appTagline = 'The modern foundation for your next project',
  baseUrl = 'http://localhost:3001',
}: BaseEmailProps) {
  return (
    <Html>
      <Head />
      <Body style={styles.main}>
        <Preview>{preview}</Preview>
        <Container style={styles.container}>
          {children}

          <div style={{ marginTop: '32px' }}>
            {appLogo && (
              <Img
                alt={`${appName} Logo`}
                height="32"
                src={appLogo}
                style={{ marginBottom: '12px' }}
                width="32"
              />
            )}
            <Text style={styles.footer}>
              <Link
                href={baseUrl}
                style={{ ...styles.footerLink }}
                target="_blank"
              >
                {appName}
              </Link>
              {appTagline && <>, {appTagline.toLowerCase()}</>}
            </Text>
          </div>
        </Container>
      </Body>
    </Html>
  );
}

// Shared styles for all emails
export const styles = {
  main: {
    backgroundColor: '#ffffff',
    fontFamily:
      "-apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen', 'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue', sans-serif",
  },
  container: {
    paddingLeft: '12px',
    paddingRight: '12px',
    margin: '0 auto',
    maxWidth: '580px',
  },
  h1: {
    color: '#333',
    fontFamily:
      "-apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen', 'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue', sans-serif",
    fontSize: '24px',
    fontWeight: 'bold',
    margin: '40px 0',
    padding: '0',
  },
  link: {
    color: '#10b981', // Emerald color
    fontFamily:
      "-apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen', 'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue', sans-serif",
    fontSize: '14px',
    textDecoration: 'underline',
  },
  text: {
    color: '#333',
    fontFamily:
      "-apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen', 'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue', sans-serif",
    fontSize: '14px',
    margin: '24px 0',
    lineHeight: '1.5',
  },
  mutedText: {
    color: '#ababab',
    fontFamily:
      "-apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen', 'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue', sans-serif",
    fontSize: '14px',
    margin: '14px 0',
    lineHeight: '1.5',
  },
  footer: {
    color: '#898989',
    fontFamily:
      "-apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen', 'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue', sans-serif",
    fontSize: '12px',
    lineHeight: '22px',
    marginTop: '12px',
    marginBottom: '24px',
  },
  footerLink: {
    color: '#898989',
    fontFamily:
      "-apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen', 'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue', sans-serif",
    fontSize: '12px',
    textDecoration: 'underline',
  },
  code: {
    display: 'inline-block' as const,
    padding: '16px 4.5%',
    width: '90.5%',
    backgroundColor: '#f4f4f4',
    borderRadius: '5px',
    border: '1px solid #eee',
    color: '#333',
    fontFamily: 'monospace',
    fontSize: '14px',
    textAlign: 'center' as const,
    margin: '16px 0',
  },
  button: {
    backgroundColor: '#10b981',
    borderRadius: '5px',
    color: '#fff',
    display: 'inline-block' as const,
    fontSize: '14px',
    fontWeight: '600',
    lineHeight: '1',
    padding: '12px 24px',
    textDecoration: 'none',
    textAlign: 'center' as const,
  },
  buttonContainer: {
    margin: '24px 0',
  },
};

export default BaseEmailTemplate;
