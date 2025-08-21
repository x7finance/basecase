// Helper to check if we're in a browser environment
/** biome-ignore-all lint/suspicious/noConsole: we want logging here */
const isBrowser = typeof window !== 'undefined';

// Validate required environment variables
const requiredVars = [
  'INSTANT_APP_ID',
  'INSTANT_ADMIN_TOKEN',
  'BETTER_AUTH_SECRET',
] as const;

const requiredPublicVars = [
  'NEXT_PUBLIC_INSTANT_APP_ID',
  'NEXT_PUBLIC_APP_URL',
] as const;

// Validation function
function validateEnv() {
  const missing: string[] = [];

  // Only validate server-side variables on server
  if (!isBrowser) {
    for (const varName of requiredVars) {
      if (!process.env[varName]) {
        missing.push(varName);
      }
    }
  }

  // Validate public variables
  for (const varName of requiredPublicVars) {
    if (!process.env[varName]) {
      missing.push(varName);
    }
  }

  if (missing.length > 0) {
    console.error('❌ Missing required environment variables:');
    for (const v of missing) {
      console.error(`   - ${v}`);
    }
    console.error('\n📝 Please create a .env file in the root directory');
    console.error('   Copy .env.example to .env and fill in your values\n');

    // Don't throw in production build to allow build to complete
    if (process.env.BUN_ENV !== 'production' && !process.env.VERCEL) {
      throw new Error(
        `Missing required environment variables: ${missing.join(', ')}`
      );
    }
  }
}

// Run validation
if (!isBrowser) {
  validateEnv();
}

// Export typed environment variables
export const env = {
  // InstantDB
  INSTANT_APP_ID: process.env.INSTANT_APP_ID,
  INSTANT_ADMIN_TOKEN: process.env.INSTANT_ADMIN_TOKEN,
  NEXT_PUBLIC_INSTANT_APP_ID: process.env.NEXT_PUBLIC_INSTANT_APP_ID,

  // Better Auth
  BETTER_AUTH_SECRET: process.env.BETTER_AUTH_SECRET,
  BETTER_AUTH_TRUSTED_ORIGINS:
    process.env.BETTER_AUTH_TRUSTED_ORIGINS || 'http://localhost:3001',

  // App
  NEXT_PUBLIC_APP_URL:
    process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3001',
  PORT: process.env.PORT || '3001',
  BUN_ENV: process.env.BUN_ENV || 'development',

  // Domain configuration
  APP_DOMAIN: process.env.APP_DOMAIN || 'localhost',
  EMAIL_DOMAIN: process.env.EMAIL_DOMAIN || 'resend.dev',

  // Optional - Google Analytics
  NEXT_PUBLIC_GA_MEASUREMENT_ID: process.env.NEXT_PUBLIC_GA_MEASUREMENT_ID,

  // Optional - OAuth
  GOOGLE_CLIENT_ID: process.env.GOOGLE_CLIENT_ID,
  GOOGLE_CLIENT_SECRET: process.env.GOOGLE_CLIENT_SECRET,
  NEXT_PUBLIC_GOOGLE_CONFIGURED: process.env.NEXT_PUBLIC_GOOGLE_CONFIGURED,

  GITHUB_CLIENT_ID: process.env.GITHUB_CLIENT_ID,
  GITHUB_CLIENT_SECRET: process.env.GITHUB_CLIENT_SECRET,
  NEXT_PUBLIC_GITHUB_CONFIGURED: process.env.NEXT_PUBLIC_GITHUB_CONFIGURED,

  // Optional - Email (Resend)
  RESEND_API_KEY: process.env.RESEND_API_KEY,
  RESEND_FROM_EMAIL: process.env.RESEND_FROM_EMAIL || 'onboarding@resend.dev',
} as const;

// Helper to get all public env vars for Next.js
export function getPublicEnv() {
  return Object.entries(env)
    .filter(([key]) => key.startsWith('NEXT_PUBLIC_'))
    .reduce(
      (acc, [key, value]) => {
        acc[key] = value;
        return acc;
      },
      {} as Record<string, string | undefined>
    );
}

export default env;
