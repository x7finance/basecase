# Development Guide

This guide covers local development setup for the Basecase application.

## Prerequisites

-   Bun (latest version)
-   Git
-   A code editor (VS Code recommended)

## Installation

### 1. Install Bun

```bash
# macOS/Linux/WSL
curl -fsSL https://bun.sh/install | bash

# Windows (PowerShell)
powershell -c "irm bun.sh/install.ps1 | iex"
```

### 2. Clone Repository

```bash
git clone https://github.com/YOUR_USERNAME/basecase.git
cd basecase
```

### 3. Install Dependencies

```bash
bun install
```

### 4. Environment Setup

Create your environment file:

```bash
cp apps/web/.env.example apps/web/.env.local
```

Edit `apps/web/.env.local` with your configuration:

```env
# Required - Get from https://instantdb.com
NEXT_PUBLIC_INSTANT_APP_ID=your_app_id
INSTANT_APP_ID=your_app_id
INSTANT_ADMIN_TOKEN=your_admin_token

# Required - Generate with: openssl rand -base64 32
BETTER_AUTH_SECRET=your_secret_key

# Application URL
NEXT_PUBLIC_APP_URL=http://localhost:3001

# Environment
BUN_ENV=development

# Optional - Analytics
# NEXT_PUBLIC_GA_MEASUREMENT_ID=G-XXXXXXXXXX
```

See [ENV_SETUP.md](./ENV_SETUP.md) for detailed environment variable documentation.

## Running the Application

### Development Mode

```bash
# Start all apps in development mode
bun run dev

# Or start specific apps
bun run dev:web    # Web application only
```

The application will be available at:

-   Web App: http://localhost:3001

### Production Build

```bash
# Build all applications
bun run build

# Start production server
bun run start
```

## Project Structure

```
basecase/
├── apps/
│   └── web/              # Next.js web application
│       ├── src/
│       │   ├── app/      # App router pages
│       │   ├── components/
│       │   └── lib/
│       ├── next.config.ts
│       └── package.json
├── packages/
│   ├── auth/            # Authentication package
│   │   └── src/
│   │       ├── client.ts
│   │       ├── server.ts
│   │       └── index.ts
│   └── database/        # Database package
│       └── src/
│           ├── schema.ts
│           ├── client.ts
│           └── admin.ts
├── scripts/             # Deployment scripts
├── docs/                # Documentation
└── package.json         # Root package.json
```

## Available Scripts

### Root Level

-   `bun run dev` - Start all apps in development
-   `bun run build` - Build all apps
-   `bun run check-types` - Run TypeScript checks
-   `bun run check` - Run linting

### Web App (`apps/web`)

-   `bun run dev` - Start Next.js dev server
-   `bun run build` - Build for production
-   `bun run start` - Start production server
-   `bun run check-types` - Type checking

## Development Workflow

### 1. Feature Development

```bash
# Create feature branch
git checkout -b feature/your-feature

# Make changes
# ...

# Run type checks
bun run check-types

# Test build
bun run build

# Commit changes
git add .
git commit -m "feat: your feature description"

# Push to remote
git push origin feature/your-feature
```

### 2. Database Schema Changes

Edit the schema in `packages/database/src/schema.ts`:

```typescript
const schema = i.schema({
    entities: {
        // Your entities here
    },
})
```

The schema is automatically synced with InstantDB.

### 3. Authentication Changes

Modify auth configuration in `packages/auth/src/server.ts`:

```typescript
export const auth = betterAuth({
    // Your auth config
})
```

### 4. Adding Components

Create new components in `apps/web/src/components/`:

```typescript
// apps/web/src/components/my-component.tsx
export function MyComponent() {
    return <div>Component content</div>
}
```

## Common Tasks

### Adding Dependencies

```bash
# Add to root
bun add package-name

# Add to specific workspace
bun add package-name --cwd apps/web

# Add dev dependency
bun add -D package-name
```

### Database Operations

InstantDB provides real-time sync out of the box:

```typescript
import { db } from "@basecase/database"

// Query data
const { data, isLoading } = db.useQuery({ users: {} })

// Mutations
const addUser = () => {
    db.transact(db.tx.users[id()].update({ name: "John" }))
}
```

### Authentication

```typescript
import { signIn, signOut, useSession } from "@basecase/auth"

// Get session
const { data: session } = useSession()

// Sign in
await signIn.email({ email, password })

// Sign out
await signOut()
```

## Debugging

### Enable Debug Logs

```bash
# Set debug environment
BUN_ENV=development bun run dev
```

### Check TypeScript Errors

```bash
bun run check-types
```

### View Build Output

```bash
bun run build --debug
```

## Testing

### Manual Testing

1. Start development server
2. Test all auth flows
3. Verify database operations
4. Check responsive design
5. Test error states

### Type Checking

```bash
# Check all packages
bun run check-types

# Check specific package
cd packages/auth && bun run check-types
```

## Troubleshooting

### Port Already in Use

```bash
# Find process using port 3001
lsof -i :3001

# Kill process
kill -9 <PID>
```

### Build Errors

```bash
# Clear caches
rm -rf apps/web/.next
rm -rf node_modules
bun install
```

### Environment Variables Not Loading

1. Ensure `.env.local` exists in `apps/web/`
2. Restart the dev server
3. Check variable names match exactly

### TypeScript Errors

```bash
# Reinstall types
bun add -D @types/node @types/react @types/react-dom
```

## VS Code Setup

### Recommended Extensions

-   Tailwind CSS IntelliSense
-   TypeScript and JavaScript Language Features
-   Biome (if using Biome)
-   Prettier (if using Prettier)

### Settings

Create `.vscode/settings.json`:

```json
{
    "typescript.tsdk": "node_modules/typescript/lib",
    "typescript.enablePromptUseWorkspaceTsdk": true,
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "biomejs.biome"
}
```

## Best Practices

1. **Type Safety**: Always use TypeScript, avoid `any`
2. **Component Structure**: Keep components small and focused
3. **State Management**: Use React Query for server state
4. **Error Handling**: Always handle loading and error states
5. **Code Style**: Follow existing patterns in the codebase
6. **Commits**: Use conventional commits (feat:, fix:, docs:, etc.)

## Getting Help

-   Check existing documentation in `/docs`
-   Review code examples in the repository
-   Check InstantDB docs: https://instantdb.com/docs
-   Check Better Auth docs: https://better-auth.com/docs
