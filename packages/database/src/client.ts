import { env } from '@basecase/env';
import { init } from '@instantdb/react';
import schema from './schema';

const appId = env.NEXT_PUBLIC_INSTANT_APP_ID;

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

export const db = appId
  ? init({
      appId,
      schema,
    })
  : mockDb;
