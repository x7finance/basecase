# Basecase

A modern, production-ready web application starter built with Bun, Next.js 15, InstantDB, and Better Auth.

## Technology Stack

### Core Runtime

-   **Bun** - All-in-one JavaScript runtime, package manager, and bundler
    -   Fast npm-compatible package management
    -   Built-in TypeScript execution
    -   Native test runner and bundler

### Frontend Framework

-   **Next.js 15** - Full-stack React framework
    -   App Router with React Server Components
    -   Built-in API routes
    -   Turbopack for fast development builds
    -   Automatic code splitting and optimization

### UI & Styling

-   **Tailwind CSS v4** - Utility-first CSS framework
    -   Just-in-time compilation
    -   Automatic unused CSS removal
    -   Custom design system support
-   **shadcn/ui** - Copy-paste React components
    -   Built on Base UI primitives
    -   Fully customizable and accessible
    -   Dark mode support via next-themes
-   **Phosphor Icons** - Flexible and consistent icon system

### State & Data Management

-   **InstantDB** - Real-time graph database
    -   Zero-latency optimistic updates
    -   Built-in permissions system
    -   Automatic conflict resolution
    -   Real-time subscriptions
-   **TanStack Query** - Powerful async state management
    -   Data fetching and caching
    -   Optimistic updates
    -   Background refetching
-   **TanStack Form** - Type-safe form management
    -   Built-in validation
    -   Field-level error handling
-   **Zod** - TypeScript-first schema validation

### Authentication

-   **Better Auth** - Modern authentication library
    -   Email/password authentication
    -   OAuth providers (Google, GitHub)
    -   Session management
    -   Type-safe throughout
-   **InstantDB Auth Adapter** - Seamless integration
    -   Automatic session sync
    -   Real-time auth state
    -   Secure token management

### Developer Experience

-   **TypeScript** - End-to-end type safety
-   **Biome** - Fast formatter and linter
    -   Replaces ESLint and Prettier
    -   Zero-config setup
-   **OxLint** - Rust-based linter for additional checks
-   **Ultracite** - Code formatting tool
-   **Husky** - Git hooks for code quality
    -   Pre-commit formatting
    -   Commit message validation
-   **Lint-staged** - Run linters on staged files only

### Infrastructure & Deployment

-   **VPS Setup Script** - Automated Ubuntu 24 server configuration
    -   Nginx reverse proxy with SSL/TLS
    -   Let's Encrypt certificates with auto-renewal
    -   UFW firewall configuration
    -   Fail2ban for SSH protection
    -   Systemd service management
    -   Health monitoring and auto-restart
-   **Claude Code CLI** - AI-powered development assistance

### Animation & Interaction

-   **tw-animate-css** - Tailwind-based animations
-   **Sonner** - Beautiful toast notifications
-   **class-variance-authority** - Component variant management
-   **clsx** - Conditional className utility

### Analytics

-   **Google Analytics 4** - Website analytics and user tracking
    -   Privacy-friendly implementation
    -   Automatic pageview tracking
    -   Custom event support
    -   Performance monitoring

## Quick Start

```bash
# Install dependencies
bun install

# Set up environment variables (ONE file in root directory)
cp .env.example .env
# Edit .env with your credentials

# Start development server
bun run dev

# Or start specific apps
bun run dev:web    # Web app only
```

The web application runs at [http://localhost:3001](http://localhost:3001)

Visit http://localhost:3001 to see your application.

## Documentation

All documentation is available in the [`/docs`](./docs) directory:

-   📚 [Development Guide](./docs/DEVELOPMENT.md) - Local development setup
-   🔐 [Environment Setup](./docs/ENV_SETUP.md) - Configure environment variables
-   🚀 [Deployment Guide](./docs/DEPLOYMENT.md) - Deploy to production
-   🏗️ [Architecture](./docs/ARCHITECTURE.md) - Technical architecture
-   🔧 [Git Setup](./docs/GIT_SETUP.md) - Repository and deployment configuration

## Project Structure

```
basecase/
├── apps/web/          # Next.js application
├── packages/          # Shared packages
│   ├── auth/         # Authentication
│   └── database/     # Database client
├── scripts/          # Deployment scripts
└── docs/            # Documentation
```

## Scripts

```bash
# Development
bun run dev          # Start dev server
bun run build        # Build for production
bun run start        # Start production server

# Code Quality
bun run check-types  # TypeScript checking
bun run check        # Run linter
```

## Deployment

Quick automated deployment to Ubuntu 24 VPS:

```bash
# Run on your Ubuntu 24 server
curl -fsSL https://raw.githubusercontent.com/x7finance/basecase/main/setup.sh | sudo bash
```

The script will:

-   Install Bun, Git, Nginx, and dependencies
-   Clone the basecase repository
-   Prompt you for environment variables (InstantDB, Better Auth, etc.)
-   Build and configure the application
-   Set up SSL certificates (if domain provided)
-   Configure firewall and security

See [Deployment Guide](./docs/DEPLOYMENT.md) for detailed instructions.

## License

MIT
