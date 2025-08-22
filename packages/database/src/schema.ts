// Docs: https://www.instantdb.com/docs/modeling-data

import { i } from "@instantdb/react";

const _schema = i.schema({
  entities: {
    "$files": i.entity({
      "path": i.string().unique().indexed(),
      "url": i.string().optional(),
    }),
    "$users": i.entity({
      "email": i.string().unique().indexed().optional(),
    }),
    "accounts": i.entity({
      "id": i.string().unique().optional(),
      "accessToken": i.string().optional(),
      "accessTokenExpiresAt": i.date().optional(),
      "accountId": i.string(),
      "createdAt": i.date(),
      "idToken": i.string().optional(),
      "password": i.string().optional(),
      "providerId": i.string(),
      "refreshToken": i.string().optional(),
      "refreshTokenExpiresAt": i.date().optional(),
      "scope": i.string().optional(),
      "updatedAt": i.date(),
      "userId": i.string().indexed(),
    }),
    "profiles": i.entity({
      "id": i.string().unique().optional(),
      "createdAt": i.date(),
      "image": i.string().optional(),
      "name": i.string(),
      "updatedAt": i.date(),
    }),
    "sessions": i.entity({
      "id": i.string().unique().optional(),
      "createdAt": i.date(),
      "expiresAt": i.date().indexed(),
      "ipAddress": i.string().optional(),
      "token": i.string(),
      "updatedAt": i.date(),
      "userAgent": i.string().optional(),
      "userId": i.string(),
    }),
    "users": i.entity({
      "id": i.string().unique().optional(),
      "createdAt": i.date(),
      "email": i.string().unique(),
      "emailVerified": i.boolean(),
      "image": i.string().optional(),
      "name": i.string(),
      "updatedAt": i.date(),
    }),
    "verifications": i.entity({
      "id": i.string().unique().optional(),
      "createdAt": i.date().indexed(),
      "expiresAt": i.date().indexed(),
      "identifier": i.string(),
      "updatedAt": i.date(),
      "value": i.string(),
    }),
    "books": i.entity({
      "title": i.string(),
      "author": i.string(),
      "isbn": i.string().unique(),
      "publishedYear": i.number(),
      "genre": i.string(),
      "price": i.number(),
      "inStock": i.boolean(),
      "createdAt": i.date(),
    }),
  },
  links: {
    "accountsUser": {
      "forward": {
        "on": "accounts",
        "has": "one",
        "label": "user",
        "onDelete": "cascade"
      },
      "reverse": {
        "on": "users",
        "has": "many",
        "label": "accounts"
      }
    },
    "profilesUser": {
      "forward": {
        "on": "profiles",
        "has": "one",
        "label": "user",
        "onDelete": "cascade"
      },
      "reverse": {
        "on": "users",
        "has": "one",
        "label": "profile"
      }
    },
    "sessionsUser": {
      "forward": {
        "on": "sessions",
        "has": "one",
        "label": "user",
        "onDelete": "cascade"
      },
      "reverse": {
        "on": "users",
        "has": "many",
        "label": "sessions"
      }
    },
    "users$user": {
      "forward": {
        "on": "users",
        "has": "one",
        "label": "$user",
        "onDelete": "cascade"
      },
      "reverse": {
        "on": "$users",
        "has": "one",
        "label": "user"
      }
    }
  },
  rooms: {}
});

// This helps Typescript display nicer intellisense
type _AppSchema = typeof _schema;
interface AppSchema extends _AppSchema {}
const schema: AppSchema = _schema;

export type { AppSchema }
export default schema;