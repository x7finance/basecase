import { i } from '@instantdb/react';

const _schema = i.schema({
  entities: {
    // System entities
    $files: i.entity({
      path: i.string().unique().indexed(),
      url: i.any(),
    }),
    $users: i.entity({
      email: i.string().unique().indexed(),
    }),
    // Authentication entities
    users: i.entity({
      id: i.string().unique(),
      createdAt: i.date(),
      email: i.string().unique(),
      emailVerified: i.boolean(),
      image: i.string().optional(),
      name: i.string(),
      updatedAt: i.date(),
    }),
    sessions: i.entity({
      id: i.string().unique(),
      createdAt: i.date(),
      expiresAt: i.date().indexed(),
      ipAddress: i.string().optional(),
      token: i.string(),
      updatedAt: i.date(),
      userAgent: i.string().optional(),
      userId: i.string(),
    }),
    accounts: i.entity({
      id: i.string().unique(),
      accessToken: i.string().optional(),
      accessTokenExpiresAt: i.date().optional(),
      accountId: i.string(),
      createdAt: i.date(),
      idToken: i.string().optional(),
      password: i.string().optional(),
      providerId: i.string(),
      refreshToken: i.string().optional(),
      refreshTokenExpiresAt: i.date().optional(),
      scope: i.string().optional(),
      updatedAt: i.date(),
      userId: i.string().indexed(),
    }),
    verifications: i.entity({
      id: i.string().unique(),
      createdAt: i.date().indexed(),
      expiresAt: i.date().indexed(),
      identifier: i.string(),
      updatedAt: i.date(),
      value: i.string(),
    }),
    // Optional entities for additional features (public profile example)
    profiles: i.entity({
      id: i.string().unique(),
      createdAt: i.date(),
      image: i.string().optional(),
      name: i.string(),
      updatedAt: i.date(),
    }),
  },
  links: {
    // Required links for auth
    users$user: {
      forward: {
        on: 'users',
        has: 'one',
        label: '$user',
        onDelete: 'cascade',
      },
      reverse: {
        on: '$users',
        has: 'one',
        label: 'user',
      },
    },
    sessionsUser: {
      forward: {
        on: 'sessions',
        has: 'one',
        label: 'user',
        onDelete: 'cascade',
      },
      reverse: {
        on: 'users',
        has: 'many',
        label: 'sessions',
      },
    },
    accountsUser: {
      forward: {
        on: 'accounts',
        has: 'one',
        label: 'user',
        onDelete: 'cascade',
      },
      reverse: {
        on: 'users',
        has: 'many',
        label: 'accounts',
      },
    },
    // Optional links (public profile example)
    profilesUser: {
      forward: {
        on: 'profiles',
        has: 'one',
        label: 'user',
        onDelete: 'cascade',
      },
      reverse: {
        on: 'users',
        has: 'one',
        label: 'profile',
      },
    },
  },
});

// This helps TypeScript display nicer intellisense
type _AppSchema = typeof _schema;
interface AppSchema extends _AppSchema {}
const schema: AppSchema = _schema;

export type { AppSchema };
export default schema;
