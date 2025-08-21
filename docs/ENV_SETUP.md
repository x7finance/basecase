# Environment Variables Setup Guide

This guide provides detailed instructions for setting up all required and optional environment variables for the basecase application.

## Required Environment Variables

### 1. InstantDB Configuration

**Service:** [InstantDB](https://instantdb.com)  
InstantDB is a real-time graph database that powers our data layer.

```bash
# Public app ID (used in client-side code)
NEXT_PUBLIC_INSTANT_APP_ID=your_instant_app_id

# Private admin token (used in server-side code)
INSTANT_APP_ID=your_instant_app_id
INSTANT_ADMIN_TOKEN=your_instant_admin_token
```

**How to get these:**

1. Go to [InstantDB](https://instantdb.com)
2. Sign up for a free account
3. Create a new app
4. Navigate to your app dashboard
5. Find your App ID and Admin Token in the settings

### 2. Better Auth Configuration

**Service:** Self-managed  
Better Auth handles our authentication system.

```bash
# Secret key for JWT signing (generate with: openssl rand -base64 32)
BETTER_AUTH_SECRET=your_generated_secret_key
```

**How to generate:**

```bash
openssl rand -base64 32
```

### 3. Application URL

```bash
# The public URL of your application (used for OAuth callbacks)
NEXT_PUBLIC_APP_URL=http://localhost:3001  # Development
# NEXT_PUBLIC_APP_URL=https://yourdomain.com  # Production
```

## Optional Environment Variables

### 1. Google Analytics

**Service:** [Google Analytics](https://analytics.google.com)

```bash
# Google Analytics Measurement ID
NEXT_PUBLIC_GA_MEASUREMENT_ID=G-XXXXXXXXXX
```

**How to get this:**

1. Go to [Google Analytics](https://analytics.google.com)
2. Create a new property or select existing one
3. Go to Admin → Data Streams
4. Select your web stream
5. Copy the Measurement ID (starts with G-)

### 2. OAuth Providers

#### Google OAuth

**Service:** [Google Cloud Console](https://console.cloud.google.com)

```bash
# Google OAuth credentials
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
NEXT_PUBLIC_GOOGLE_CONFIGURED=true  # Set when Google OAuth is configured
```

**How to get these:**

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project or select existing one
3. Enable Google+ API
4. Go to Credentials → Create Credentials → OAuth 2.0 Client ID
5. Set application type to "Web application"
6. Add authorized redirect URIs:
    - Development: `http://localhost:3001/api/auth/callback/google`
    - Production: `https://yourdomain.com/api/auth/callback/google`
7. Copy the Client ID and Client Secret

#### GitHub OAuth

**Service:** [GitHub Developer Settings](https://github.com/settings/developers)

```bash
# GitHub OAuth credentials
GITHUB_CLIENT_ID=your_github_client_id
GITHUB_CLIENT_SECRET=your_github_client_secret
NEXT_PUBLIC_GITHUB_CONFIGURED=true  # Set when GitHub OAuth is configured
```

**How to get these:**

1. Go to [GitHub Settings → Developer settings → OAuth Apps](https://github.com/settings/developers)
2. Click "New OAuth App"
3. Fill in the application details:
    - Application name: Your app name
    - Homepage URL: Your app URL
    - Authorization callback URL:
        - Development: `http://localhost:3001/api/auth/callback/github`
        - Production: `https://yourdomain.com/api/auth/callback/github`
4. Copy the Client ID and generate a Client Secret

### 3. Additional Configuration

```bash
# Trusted origins for CORS (comma-separated list)
BETTER_AUTH_TRUSTED_ORIGINS=http://localhost:3001,https://yourdomain.com

# Bun environment
BUN_ENV=development  # or 'production'
```

## Complete .env.local Example

Create a `.env.local` file in the `apps/web` directory with the following content:

```bash
# === REQUIRED VARIABLES ===

# InstantDB Configuration
NEXT_PUBLIC_INSTANT_APP_ID=your_instant_app_id
INSTANT_APP_ID=your_instant_app_id
INSTANT_ADMIN_TOKEN=your_instant_admin_token

# Better Auth Configuration
BETTER_AUTH_SECRET=your_generated_secret_key

# Application Configuration
NEXT_PUBLIC_APP_URL=http://localhost:3001

# === OPTIONAL VARIABLES ===

# Google Analytics (optional)
# NEXT_PUBLIC_GA_MEASUREMENT_ID=G-XXXXXXXXXX

# Google OAuth (optional)
# GOOGLE_CLIENT_ID=your_google_client_id
# GOOGLE_CLIENT_SECRET=your_google_client_secret
# NEXT_PUBLIC_GOOGLE_CONFIGURED=true

# GitHub OAuth (optional)
# GITHUB_CLIENT_ID=your_github_client_id
# GITHUB_CLIENT_SECRET=your_github_client_secret
# NEXT_PUBLIC_GITHUB_CONFIGURED=true

# Additional Configuration
BETTER_AUTH_TRUSTED_ORIGINS=http://localhost:3001
BUN_ENV=development
```

## Deployment Notes

### Vercel

1. Go to your project settings in Vercel dashboard
2. Navigate to "Environment Variables"
3. Add each variable from your `.env.local`
4. Redeploy your application

### Other Platforms

Most deployment platforms (Netlify, Railway, Render, etc.) have similar environment variable configuration in their dashboard settings.

## Security Notes

-   **Never commit** `.env.local` or any file containing secrets to version control
-   Use different credentials for development and production
-   Rotate secrets regularly
-   Use strong, randomly generated secrets for `BETTER_AUTH_SECRET`

## Troubleshooting

If you see errors like:

-   "INSTANT_APP_ID is required" - Make sure you've set up InstantDB credentials
-   "Auth not configured" - Check that `BETTER_AUTH_SECRET` is set
-   OAuth not working - Ensure callback URLs match exactly (including trailing slashes)

## Quick Setup Script

You can use this script to quickly generate a template `.env.local` file:

```bash
cat > apps/web/.env.local << 'EOF'
# === REQUIRED VARIABLES ===
NEXT_PUBLIC_INSTANT_APP_ID=
INSTANT_APP_ID=
INSTANT_ADMIN_TOKEN=
BETTER_AUTH_SECRET=$(openssl rand -base64 32)
NEXT_PUBLIC_APP_URL=http://localhost:3001
BETTER_AUTH_TRUSTED_ORIGINS=http://localhost:3001
BUN_ENV=development
EOF

echo "Created .env.local template. Please fill in the InstantDB credentials."
```
