# Architecture Overview

This document describes the technical architecture and design decisions of the Basecase application.

## Stack Overview

### Core Technologies

-   **Runtime**: Bun - Fast all-in-one JavaScript runtime
-   **Framework**: Next.js 15 - React framework with App Router
-   **Database**: InstantDB - Real-time graph database
-   **Authentication**: Better Auth - Modern auth library
-   **Styling**: Tailwind CSS v4 - Utility-first CSS
-   **UI Components**: Base UI - Unstyled, accessible components
-   **Icons**: Phosphor Icons - Flexible icon system

## Project Structure

```
basecase/
├── apps/                    # Application packages
│   └── web/                # Next.js web application
├── packages/               # Shared packages
│   ├── auth/              # Authentication logic
│   └── database/          # Database client and schema
├── scripts/               # Deployment and setup scripts
├── docs/                  # Documentation
└── [config files]         # Root configuration
```

### Monorepo Architecture

We use Bun workspaces for monorepo management:

-   **apps/**: Contains deployable applications
-   **packages/**: Shared code between applications
-   **scripts/**: Automation and deployment scripts
-   **docs/**: All documentation

## Data Layer

### InstantDB

InstantDB provides:

-   Real-time synchronization
-   Optimistic updates
-   Offline support
-   Graph-based queries
-   Built-in permissions

### Schema Design

```typescript
// packages/database/src/schema.ts
const schema = i.schema({
    entities: {
        users: i.entity({
            email: i.string().unique(),
            name: i.string().optional(),
            // ...
        }),
        sessions: i.entity({
            userId: i.string(),
            token: i.string(),
            // ...
        }),
    },
})
```

### Data Flow

1. **Client Components** → Use `db.useQuery()` for reactive data
2. **Server Components** → Use `adminDb` for server-side queries
3. **Mutations** → Use `db.transact()` for optimistic updates
4. **Real-time** → Automatic via InstantDB subscriptions

## Authentication Architecture

### Better Auth Integration

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   Client    │────▶│  Better Auth │────▶│  InstantDB  │
│  (Browser)  │     │   Middleware │     │   Adapter   │
└─────────────┘     └──────────────┘     └─────────────┘
```

### Auth Flow

1. **Sign Up/In** → Better Auth handles credentials
2. **Session Creation** → Stored in InstantDB
3. **Token Management** → JWT with refresh tokens
4. **Client State** → React hooks for session data

### Security Features

-   Password hashing with bcrypt
-   CSRF protection
-   Secure cookie configuration
-   OAuth provider support
-   Session refresh mechanism

## Frontend Architecture

### Next.js App Router

```
src/
├── app/                    # App Router pages
│   ├── layout.tsx         # Root layout
│   ├── page.tsx           # Home page
│   └── api/               # API routes
│       └── auth/[...all]/ # Auth endpoints
├── components/            # React components
│   ├── ui/               # Base UI components
│   └── [features]/       # Feature components
└── lib/                  # Utilities
```

### Component Philosophy

1. **Server Components by Default** - Better performance
2. **Client Components for Interactivity** - Use "use client" directive
3. **Composition over Inheritance** - Small, focused components
4. **Type Safety** - Full TypeScript coverage

### State Management

-   **Server State**: React Query + InstantDB
-   **Client State**: React hooks
-   **Form State**: React Hook Form
-   **Theme State**: next-themes

## API Design

### RESTful Endpoints

```
/api/auth/[...all]  → Better Auth handlers
```

### Data Fetching Patterns

```typescript
// Server Component
async function Page() {
    const data = await adminDb.query({ users: {} })
    return <UserList users={data.users} />
}

// Client Component
function UserList() {
    const { data, isLoading } = db.useQuery({ users: {} })
    // ...
}
```

## Deployment Architecture

### Production Setup

```
┌──────────┐     ┌─────────┐     ┌────────────┐
│  Nginx   │────▶│  Bun    │────▶│  Next.js   │
│  (Proxy) │     │ Runtime │     │    App     │
└──────────┘     └─────────┘     └────────────┘
                                        │
                                        ▼
                                  ┌──────────┐
                                  │InstantDB │
                                  │  Cloud   │
                                  └──────────┘
```

### Process Management

-   **Systemd**: Native Linux service management
-   **PM2**: Alternative with clustering support
-   **Health Checks**: Automated monitoring
-   **Log Rotation**: Prevent disk space issues

## Performance Optimizations

### Build-time

-   TypeScript with `skipLibCheck`
-   Next.js production optimizations
-   Tree shaking with Bun
-   CSS purging with Tailwind

### Runtime

-   Server Components for initial load
-   Streaming SSR
-   Image optimization
-   Font optimization
-   Prefetching

### Caching Strategy

1. **Static Assets**: 30-day cache headers
2. **API Responses**: InstantDB handles caching
3. **Build Cache**: `.next/cache` directory
4. **CDN**: CloudFlare/Vercel Edge Network

## Security Architecture

### Application Security

-   Environment variable validation
-   Input sanitization
-   SQL injection prevention (via InstantDB)
-   XSS protection (React default)
-   CSRF tokens

### Infrastructure Security

-   Firewall (UFW)
-   Fail2ban for SSH
-   SSL/TLS with Let's Encrypt
-   Security headers via Nginx
-   Regular security updates

## Scalability Considerations

### Vertical Scaling

-   Increase VPS resources
-   Optimize Bun runtime settings
-   Database connection pooling

### Horizontal Scaling

-   Load balancer (Nginx)
-   Multiple application instances
-   InstantDB handles data sync
-   Session sharing via database

## Development Workflow

### Git Flow

```
main
  ├── feature/new-feature
  ├── fix/bug-fix
  └── docs/documentation
```

### CI/CD Pipeline

1. **Push to main** → Trigger deployment
2. **Run checks** → Type checking, linting
3. **Build** → Create production bundle
4. **Deploy** → Update VPS
5. **Health check** → Verify deployment

## Monitoring and Observability

### Application Monitoring

-   Health check endpoints
-   Error tracking (can add Sentry)
-   Performance metrics
-   User analytics (Google Analytics)

### Infrastructure Monitoring

-   System resources (CPU, Memory, Disk)
-   Nginx access/error logs
-   Application logs via journald
-   Uptime monitoring

## Technology Decisions

### Why Bun?

-   Fast startup and execution
-   Built-in TypeScript support
-   Native test runner
-   Package manager included
-   Better performance than Node.js

### Why InstantDB?

-   Real-time by default
-   No backend needed
-   Optimistic updates
-   Graph queries
-   Built-in auth support

### Why Better Auth?

-   Modern, type-safe API
-   Flexible provider system
-   Database agnostic
-   Good InstantDB integration
-   Active development

### Why Next.js 15?

-   App Router for better DX
-   Server Components
-   Built-in optimizations
-   Great TypeScript support
-   Industry standard

## Future Considerations

### Potential Enhancements

1. **Edge Deployment** - Deploy to Vercel/Cloudflare
2. **Mobile App** - React Native with shared packages
3. **API Gateway** - tRPC or GraphQL layer
4. **Testing** - Playwright for E2E tests
5. **Monitoring** - OpenTelemetry integration

### Scaling Path

1. **Phase 1**: Single VPS (current)
2. **Phase 2**: Database optimization
3. **Phase 3**: CDN integration
4. **Phase 4**: Multi-region deployment
5. **Phase 5**: Microservices architecture
