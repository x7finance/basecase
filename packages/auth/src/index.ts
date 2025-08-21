/** biome-ignore-all lint/performance/noBarrelFile: this is a barrel file */
export type { Session, User } from 'better-auth';
export {
  authClient,
  signIn,
  signOut,
  signUp,
  useSession,
} from './client';
export { useInstantAuth } from './instant-auth-wrapper';
export { auth } from './server';
