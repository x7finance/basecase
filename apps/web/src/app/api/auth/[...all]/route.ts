import { auth, toNextJsHandler } from '@basecase/auth/server';

// Handle case where auth is null (when env vars aren't set)
const authHandler = auth
  ? toNextJsHandler(auth)
  : {
      POST: () => new Response('Auth not configured', { status: 503 }),
      GET: () => new Response('Auth not configured', { status: 503 }),
    };

export const { POST, GET } = authHandler;
