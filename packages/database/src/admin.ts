import { env } from '@basecase/env';
import { init } from '@instantdb/admin';
import schema from './schema';

// Only initialize if we have the required env vars (server-side only)
export const adminDb =
  env.INSTANT_APP_ID && env.INSTANT_ADMIN_TOKEN
    ? init({
        appId: env.INSTANT_APP_ID,
        adminToken: env.INSTANT_ADMIN_TOKEN,
        schema,
        // Use local InstantDB if base URL is configured
        ...(env.INSTANT_BASE_URL && {
          apiURI: env.INSTANT_BASE_URL,
          disableValidation: true, // Disable schema validation for self-hosted InstantDB
        }),
      })
    : null;
