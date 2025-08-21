# Centralized Environment Variables

This project uses a **single `.env` file in the root directory** for ALL environment variables. You no longer need to manage multiple `.env.local` files in different directories.

## Setup

### 1. Create Your Environment File

```bash
# From the root directory
cp .env.example .env
```

### 2. Edit the `.env` File

Open `.env` in your editor and add your configuration. This is the ONLY place you need to set environment variables.

## How It Works

### Architecture

```
basecase/
├── .env                    # ← ALL environment variables go here
├── .env.example           # ← Template with all required/optional vars
├── packages/
│   └── env/              # ← Centralized env loader package
│       └── index.ts      # ← Validates and exports typed env vars
└── apps/
    └── web/
        └── (no .env.local needed!)
```

### Technical Implementation

1. **Single Source of Truth**: The root `.env` file contains ALL environment variables
2. **Type Safety**: The `@basecase/env` package provides typed exports
3. **Validation**: Required variables are validated on startup
4. **Auto-loading**: Next.js config automatically loads from root `.env`

### Usage in Code

```typescript
// Instead of process.env.VARIABLE_NAME
// Use the typed env object:

import { env } from "@basecase/env"

// In any package or app:
const appId = env.NEXT_PUBLIC_INSTANT_APP_ID
const secret = env.BETTER_AUTH_SECRET
```

## Benefits

1. **Simplicity**: One file to manage all environment variables
2. **No Duplication**: No need to copy variables between directories
3. **Type Safety**: Full TypeScript support with autocomplete
4. **Validation**: Missing required variables are caught early
5. **Consistency**: All packages use the same configuration

## Migration from Old Setup

If you previously had `.env.local` files in various directories:

1. Copy all variables to the root `.env` file
2. Delete old `.env.local` files
3. Restart your development server

## Deployment

For production deployment:

1. Copy `.env.example` to your server
2. Fill in production values
3. The setup script will automatically use the root `.env`

## Troubleshooting

### "Missing required environment variables" Error

This means required variables are not set in your `.env` file. Check:

1. The `.env` file exists in the root directory
2. All required variables have values
3. No typos in variable names

### Variables Not Loading

1. Ensure `.env` is in the root directory (not in `apps/web/`)
2. Restart the development server after changes
3. Check that variable names match exactly (case-sensitive)

### Build Errors

The build will warn about missing variables but won't fail (to allow CI/CD). Always set variables before deployment.

## Required Variables

These MUST be set in `.env`:

-   `INSTANT_APP_ID` - InstantDB app ID
-   `INSTANT_ADMIN_TOKEN` - InstantDB admin token
-   `NEXT_PUBLIC_INSTANT_APP_ID` - Public InstantDB app ID
-   `BETTER_AUTH_SECRET` - Authentication secret
-   `NEXT_PUBLIC_APP_URL` - Application URL

## Optional Variables

These can be added as needed:

-   `NEXT_PUBLIC_GA_MEASUREMENT_ID` - Google Analytics
-   `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET` - Google OAuth
-   `GITHUB_CLIENT_ID` / `GITHUB_CLIENT_SECRET` - GitHub OAuth

See `.env.example` for the complete list with descriptions.
