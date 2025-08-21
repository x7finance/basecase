# Basecase Deployment Scripts

**Basecase** is a modern full-stack web application template built with Next.js, InstantDB, and Better Auth. It provides a solid foundation for building web applications with authentication, real-time database functionality, and production-ready deployment scripts.

## What is Basecase?

Basecase is a **monorepo starter template** that includes:

- 🚀 **Next.js 14** with App Router and React Server Components
- 🔐 **Better Auth** for authentication (email, OAuth providers)
- 📊 **InstantDB** for real-time database with reactive queries
- 🎨 **Tailwind CSS** + **shadcn/ui** for styling
- 📦 **Bun** for fast package management and runtime
- 🛠️ **TypeScript** for type safety
- 🔧 **Biome** for linting and formatting
- 📱 **Responsive design** with modern UI components

### Tech Stack
- **Frontend**: Next.js 14, React, TypeScript, Tailwind CSS, shadcn/ui
- **Database**: InstantDB (real-time, reactive database)
- **Authentication**: Better Auth (email, Google, GitHub OAuth)
- **Package Manager**: Bun
- **Deployment**: PM2, Nginx, Let's Encrypt SSL
- **Linting**: Biome, Oxlint, Ultracite

## Deployment Scripts

These scripts provide **one-command deployment** from a fresh server to a live, production-ready web application.

### 🚀 One-Command Complete Deployment

```bash
# Deploy everything from scratch:
curl -fsSL https://raw.githubusercontent.com/x7finance/basecase/main/scripts/deploy-complete.sh -o deploy-complete.sh && chmod +x deploy-complete.sh && ./deploy-complete.sh
```

This single command will:
1. Configure domain and SSL certificates
2. Set up all environment variables
3. Configure nginx reverse proxy
4. Clone and deploy the application
5. Start the application with PM2

### Individual Scripts

If you prefer to run steps individually or need to troubleshoot:

#### 🌐 `setup.sh`
**Purpose:** Domain and SSL configuration  
**When:** First time setup or domain changes  

Interactive setup for:
- Domain name validation
- SSL certificate email
- Basic .env file creation

#### 🔧 `env-manage.sh` 
**Purpose:** Environment variables management  
**When:** Initial setup or when configuration changes  

Features:
- Interactive wizard for all services
- InstantDB configuration
- OAuth provider setup (Google, GitHub)
- Email service (Resend)
- Analytics (Google Analytics)
- Automatic backups to `~/.basecase-env-backups/`

Commands:
```bash
./env-manage.sh setup     # Interactive setup wizard
./env-manage.sh           # Full management interface
```

#### 🌍 `nginx-setup.sh`
**Purpose:** Web server configuration  
**When:** After domain and environment setup  

Features:
- Reverse proxy configuration
- Automatic SSL with Let's Encrypt
- Next.js optimization
- Security headers

#### 🚀 `deploy-fresh.sh`
**Purpose:** Application deployment from GitHub  
**When:** Deploy updates or fresh installation  

Does:
- Git pull latest code
- Install dependencies with Bun
- Build application
- Configure PM2 process manager
- Distribute .env files to all packages

#### 🔄 `redeploy.sh`
**Purpose:** Deploy local code changes  
**When:** Development and testing  

Similar to `deploy-fresh.sh` but uses local code instead of pulling from GitHub.

## Supporting Scripts

#### 📊 `migrate-schema.mjs`
**Purpose:** InstantDB schema migration  
**When:** Automatically run before dev/build  

Migrates database schema changes to InstantDB. Called automatically by:
- `bun run dev`
- `bun run build` 
- `bun run migrate`

#### 🧹 `cleanup-vpc.sh` *(Optional)*
**Purpose:** Clean deployment for testing  
**When:** Development/testing only  

Removes:
- Nginx configurations
- PM2 processes  
- Application directory
- SSL certificates

⚠️ **Warning:** Only use for testing environments!

## Deployment Examples

### Complete Fresh Deployment
```bash
# Single command - everything from scratch:
curl -fsSL https://raw.githubusercontent.com/x7finance/basecase/main/scripts/deploy-complete.sh -o deploy-complete.sh && chmod +x deploy-complete.sh && ./deploy-complete.sh
```

### Manual Step-by-Step Deployment
```bash
# 1. Domain setup
./scripts/setup.sh

# 2. Environment configuration  
./scripts/env-manage.sh setup

# 3. Web server setup
./scripts/nginx-setup.sh

# 4. Application deployment
./scripts/deploy-fresh.sh
```

### Updates After Initial Deployment
```bash
# Deploy latest changes from GitHub
./scripts/deploy-fresh.sh

# Deploy local changes (for development)
./scripts/redeploy.sh

# Update environment variables
./scripts/env-manage.sh
```

### Environment Management

Your `.env` is automatically backed up to `~/.basecase-env-backups/` with timestamps:
- Survives server restarts and directory deletions
- Automatic backups on every configuration change
- Easy restore with `./scripts/env-manage.sh` → Restore option

## Management & Monitoring

### Application Status
```bash
# Check PM2 status
pm2 status

# View application logs
pm2 logs basecase

# Monitor resources
pm2 monit

# Restart application
pm2 restart basecase
```

### Web Server Status  
```bash
# Test nginx configuration
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx

# Check nginx status
sudo systemctl status nginx
```

### Environment Management
```bash
# View current configuration (masked secrets)
./scripts/env-manage.sh → View option

# Backup current environment
./scripts/env-manage.sh → Backup option

# List all backups
./scripts/env-manage.sh → List option
```

## Troubleshooting

### Site Not Loading
```bash
# 1. Check if application is running
pm2 status
curl http://localhost:3001

# 2. Check nginx
sudo nginx -t
sudo systemctl status nginx

# 3. Check logs
pm2 logs basecase --lines 50
sudo tail -f /var/log/nginx/error.log
```

### Database Issues
```bash
# Check environment variables
./scripts/env-manage.sh → View option

# Test database connection (check logs)
pm2 logs basecase | grep -i instant
```

### SSL Certificate Issues
```bash
# Check certificate status
sudo certbot certificates

# Renew certificates
sudo certbot renew --dry-run
```

## Requirements

- **Server**: Ubuntu 20.04+ with sudo access
- **Domain**: Pointing to server IP address  
- **Services**: InstantDB account (free tier available)
- **Optional**: Google OAuth, GitHub OAuth, Resend for email

## Security Features

- 🔒 **SSL certificates** via Let's Encrypt
- 🔐 **Environment variable encryption** (masked display)
- 🛡️ **Secure session management** with Better Auth
- 🚫 **Rate limiting** and CORS protection
- 📦 **Dependency security** with Bun's built-in checks