'use client';

import { env } from '@basecase/env';

import { createAuthClient } from 'better-auth/react';

const authClient = createAuthClient({
  baseURL: env.NEXT_PUBLIC_APP_URL,
});

export const signIn = authClient.signIn;
export const signOut = authClient.signOut;
export const signUp = authClient.signUp;
export const useSession = authClient.useSession;

export { authClient };
