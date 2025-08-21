# Deployment Guide

This guide covers deploying the Basecase application to a VPS (Ubuntu 24.04).

## Prerequisites

-   Ubuntu 24.04 VPS (Hetzner, DigitalOcean, Linode, etc.)
-   Domain name (optional, but recommended for SSL)
-   SSH access to your server

## Initial Server Setup

### 1. Run the Setup Script

SSH into your server and run the automated setup script:

```bash
# Download and run the setup script
curl -fsSL https://raw.githubusercontent.com/YOUR_REPO/main/setup.sh | sudo bash
```

Or manually:

```bash
# Copy setup.sh to your server
scp setup.sh root@YOUR_SERVER_IP:/tmp/

# SSH into server
ssh root@YOUR_SERVER_IP

# Run setup script
chmod +x /tmp/setup.sh
sudo /tmp/setup.sh
```

The setup script will:

-   Install Bun runtime
-   Install Claude Code CLI
-   Configure Nginx as reverse proxy
-   Set up SSL with Let's Encrypt (if domain provided)
-   Configure firewall and fail2ban
-   Create systemd service for the app
-   Set up basic monitoring

### 2. Deploy Your Application

After the initial setup, deploy your application:

```bash
# Switch to app user
su - appuser

# Navigate to app directory
cd /home/appuser/app

# Clone your repository
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git .

# Create environment file
cp apps/web/.env.example apps/web/.env.local

# Edit environment variables
nano apps/web/.env.local
```

### 3. Configure Environment Variables

Create `apps/web/.env.local` with your production values:

```bash
# Required
NEXT_PUBLIC_INSTANT_APP_ID=your_instant_app_id
INSTANT_APP_ID=your_instant_app_id
INSTANT_ADMIN_TOKEN=your_instant_admin_token
BETTER_AUTH_SECRET=your_secret_key
NEXT_PUBLIC_APP_URL=https://yourdomain.com

# Optional
NEXT_PUBLIC_GA_MEASUREMENT_ID=G-XXXXXXXXXX
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
GITHUB_CLIENT_ID=your_github_client_id
GITHUB_CLIENT_SECRET=your_github_client_secret
```

### 4. Build and Start Application

```bash
# Install dependencies
bun install

# Build the application
bun run build

# Start with systemd
sudo systemctl start basecase
sudo systemctl enable basecase

# Or start with PM2 (alternative)
pm2 start ecosystem.config.js --env production
pm2 save
```

## Deployment Methods

### Method 1: Using Systemd (Recommended)

The setup script creates a systemd service. To manage it:

```bash
# Start application
sudo systemctl start basecase

# Stop application
sudo systemctl stop basecase

# Restart application
sudo systemctl restart basecase

# View status
sudo systemctl status basecase

# View logs
sudo journalctl -u basecase -f

# Enable auto-start on boot
sudo systemctl enable basecase
```

### Method 2: Using PM2

PM2 provides better process management and monitoring:

```bash
# Install PM2
bun install -g pm2

# Start application
pm2 start ecosystem.config.js --env production

# Save configuration
pm2 save

# Setup startup script
pm2 startup

# View status
pm2 status

# View logs
pm2 logs

# Monitor resources
pm2 monit
```

### Method 3: Manual Deployment Script

Use the included deployment script for updates:

```bash
cd /home/appuser/app

# Full deployment
./scripts/deploy.sh

# Skip git pull (if manually updating)
./scripts/deploy.sh --skip-pull

# Skip build (use existing build)
./scripts/deploy.sh --skip-build

# Clear all caches
./scripts/deploy.sh --clear-cache
```

## Continuous Deployment

### GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to VPS

on:
    push:
        branches: [main]

jobs:
    deploy:
        runs-on: ubuntu-latest
        steps:
            - uses: actions/checkout@v3

            - name: Deploy to VPS
              uses: appleboy/ssh-action@v0.1.5
              with:
                  host: ${{ secrets.HOST }}
                  username: ${{ secrets.USERNAME }}
                  key: ${{ secrets.SSH_KEY }}
                  script: |
                      cd /home/appuser/app
                      git pull origin main
                      bun install
                      bun run build
                      sudo systemctl restart basecase
```

Add secrets in GitHub:

-   `HOST`: Your server IP
-   `USERNAME`: appuser
-   `SSH_KEY`: Your private SSH key

## Monitoring

### Built-in Health Check

The setup script includes a health check that runs every 5 minutes:

```bash
# View health check logs
tail -f /var/log/health-check.log

# Manually run health check
/usr/local/bin/health-check.sh
```

### Application Status

```bash
# Quick status check
app-status

# View application logs
app-logs

# Check resource usage
htop
```

### PM2 Monitoring (if using PM2)

```bash
# Real-time monitoring
pm2 monit

# Web dashboard (optional)
pm2 plus
```

## SSL Certificate Management

### Auto-renewal

Certbot automatically renews certificates. To verify:

```bash
# Test renewal
sudo certbot renew --dry-run

# Check timer
sudo systemctl status certbot.timer
```

### Manual renewal

```bash
sudo certbot renew
sudo systemctl reload nginx
```

## Troubleshooting

### Application Won't Start

```bash
# Check logs
sudo journalctl -u basecase -n 100

# Check environment variables
cat apps/web/.env.local

# Test build locally
bun run build
```

### Nginx Issues

```bash
# Test configuration
sudo nginx -t

# Reload configuration
sudo systemctl reload nginx

# Check error logs
sudo tail -f /var/log/nginx/error.log
```

### Port Already in Use

```bash
# Find process using port 3001
sudo lsof -i :3001

# Kill process
sudo kill -9 <PID>
```

### Database Connection Issues

-   Verify InstantDB credentials in `.env.local`
-   Check network connectivity to InstantDB
-   Ensure environment variables are loaded

## Performance Optimization

### 1. Enable Nginx Caching

Edit `/etc/nginx/sites-available/basecase`:

```nginx
location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2)$ {
    expires 30d;
    add_header Cache-Control "public, immutable";
}
```

### 2. Enable Brotli Compression

```bash
sudo apt-get install nginx-module-brotli
```

Add to nginx config:

```nginx
brotli on;
brotli_comp_level 6;
brotli_types text/plain text/css text/javascript application/javascript application/json;
```

### 3. Increase File Descriptors

Edit `/etc/security/limits.conf`:

```
appuser soft nofile 65536
appuser hard nofile 65536
```

## Backup Strategy

### Database

InstantDB handles backups automatically. For additional backup:

```bash
# Export data via InstantDB admin API
curl -H "Authorization: Bearer $INSTANT_ADMIN_TOKEN" \
  https://api.instantdb.com/v1/apps/$INSTANT_APP_ID/export
```

### Application Files

```bash
# Backup script
#!/bin/bash
tar -czf /backup/app-$(date +%Y%m%d).tar.gz \
  /home/appuser/app \
  --exclude=node_modules \
  --exclude=.next
```

## Security Checklist

-   [ ] SSH keys configured (password auth disabled)
-   [ ] Firewall enabled (only ports 22, 80, 443 open)
-   [ ] Fail2ban protecting SSH
-   [ ] SSL certificates installed
-   [ ] Environment variables secured
-   [ ] Regular security updates applied
-   [ ] Application logs monitored
-   [ ] Resource limits configured

## Rollback Procedure

If deployment fails:

```bash
# Revert to previous commit
cd /home/appuser/app
git log --oneline -5  # Find previous commit
git reset --hard <COMMIT_HASH>

# Reinstall dependencies and rebuild
bun install
bun run build

# Restart application
sudo systemctl restart basecase
```

## Support

For issues:

1. Check application logs: `sudo journalctl -u basecase -f`
2. Check nginx logs: `sudo tail -f /var/log/nginx/error.log`
3. Verify environment variables are set correctly
4. Ensure all required services are running: `app-status`
