# 🔐 Authentication Setup Guide

## Quick Start (5 minutes)

### Step 1: Copy Environment Variables

```bash
# Copy the env file to the web app directory
cp .env.local apps/web/.env.local
```

### Step 2: Get InstantDB Credentials

1. Go to <https://instantdb.com>
2. Click "Sign Up" or "Sign In"
3. Click "Create App"
4. Copy your credentials:
    - **App ID**: Shown on dashboard
    - **Admin Token**: Click "Admin" → "Tokens" → "Create Token"

### Step 3: Update .env.local

Open `apps/web/.env.local` and replace:

-   `YOUR_INSTANT_APP_ID_HERE` with your App ID (use same value for both)
-   `YOUR_INSTANT_ADMIN_TOKEN_HERE` with your Admin Token

### Step 4: Generate Auth Secret

```bash
# Generate a secure secret
openssl rand -base64 32
```

Replace `GENERATE_32_CHAR_SECRET_RUN_COMMAND_ABOVE` with the generated value.

### Step 5: Push Schema to InstantDB

```bash
# Install InstantDB CLI
bun install -g @instantdb/cli

# Login to InstantDB
instant-cli login

# Navigate to project root
cd /path/to/basecase

# Push schema and permissions
instant-cli push schema
instant-cli push perms
```

### Step 6: Run the App

```bash
# Install dependencies
bun install

# Start development server
bun dev
```

Visit <http://localhost:3001> - You can now sign in with email/password!

---

## Optional: OAuth Setup

### Google OAuth

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create new project or select existing
3. Enable Google+ API:
    - Go to "APIs & Services" → "Library"
    - Search for "Google+ API"
    - Click "Enable"
4. Create OAuth credentials:
    - Go to "APIs & Services" → "Credentials"
    - Click "Create Credentials" → "OAuth client ID"
    - Choose "Web application"
    - Add authorized redirect URI: `http://localhost:3001/api/auth/callback/google`
    - Copy Client ID and Client Secret
5. Update `.env.local`:

    ```
    GOOGLE_CLIENT_ID=your-client-id
    GOOGLE_CLIENT_SECRET=your-client-secret
    NEXT_PUBLIC_GOOGLE_CONFIGURED=true
    ```

### GitHub OAuth

1. Go to [GitHub Developer Settings](https://github.com/settings/developers)
2. Click "New OAuth App"
3. Fill in:
    - Application name: Your app name
    - Homepage URL: `http://localhost:3001`
    - Authorization callback URL: `http://localhost:3001/api/auth/callback/github`
4. Copy Client ID and Client Secret
5. Update `.env.local`:

    ```
    GITHUB_CLIENT_ID=your-client-id
    GITHUB_CLIENT_SECRET=your-client-secret
    NEXT_PUBLIC_GITHUB_CONFIGURED=true
    ```

---

## Production Deployment

When deploying to production, update these in your production environment:

```bash
# Update URLs
NEXT_PUBLIC_APP_URL=https://yourdomain.com
BETTER_AUTH_TRUSTED_ORIGINS=https://yourdomain.com

# Update OAuth redirect URIs in provider dashboards:
# Google: https://yourdomain.com/api/auth/callback/google
# GitHub: https://yourdomain.com/api/auth/callback/github
```

---

## Troubleshooting

### "INSTANT_APP_ID is required" Error

-   Make sure you copied `.env.local` to `apps/web/` directory
-   Verify the file has your actual InstantDB credentials

### "Schema not found" Error

-   Run `instant-cli push schema` from project root
-   Make sure you're logged in: `instant-cli login`

### OAuth Not Working

-   Check that redirect URIs match exactly
-   For Google, ensure Google+ API is enabled
-   Add `NEXT_PUBLIC_[PROVIDER]_CONFIGURED=true` to show buttons

### Session Not Syncing

-   Check browser console for errors
-   Verify InstantDB permissions: `instant-cli push perms`
-   Clear browser localStorage and cookies

---

## Features Included

✅ Email/Password Authentication
✅ OAuth (Google, GitHub)
✅ Real-time Session Sync
✅ Secure Token Management
✅ Type-safe Throughout
✅ User Profile Support

---

## Need Help?

-   InstantDB Docs: <https://docs.instantdb.com>
-   Better Auth Docs: <https://better-auth.com>
-   File an issue: <https://github.com/yourusername/basecase/issues>
