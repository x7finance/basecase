import { env } from '@basecase/env';
import { init } from '@instantdb/react';
import schema from './schema';

const appId = env.NEXT_PUBLIC_INSTANT_APP_ID;
const baseUrl = env.NEXT_PUBLIC_INSTANT_BASE_URL;

// Create a mock db object that won't crash when accessed during build
const mockDb = {
  useAuth: () => ({ isLoading: false, user: null, error: null }),
  useQuery: () => ({ data: null, isLoading: false, error: null }),
  useMutation: () => [
    () => {
      /* mock mutation */
    },
    { isLoading: false, error: null },
  ],
  tx: {},
  auth: {
    signOut: () => Promise.resolve(),
    signInWithEmail: () => Promise.resolve({ user: null }),
    signInWithMagicCode: () => Promise.resolve({ user: null }),
    sendMagicCode: () => Promise.resolve(),
    createUserWithEmail: () => Promise.resolve({ user: null }),
  },
};

// Configure InstantDB with local instance URLs if provided
const instantConfig: any = {
  appId,
  schema,
};

// If local InstantDB base URL is provided, configure websocket and API URIs
if (baseUrl) {
  // For self-hosted InstantDB, configure the proper endpoints
  const wsUrl = baseUrl
    .replace('http://', 'ws://')
    .replace('https://', 'wss://');
  // WebSocket endpoint needs the /runtime/session path
  instantConfig.websocketURI = `${wsUrl}/runtime/session`;
  // API endpoint remains at the base URL
  instantConfig.apiURI = baseUrl;
}

export const db = appId
  ? init(instantConfig)
  : mockDb;
