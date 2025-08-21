# Basecase Deployment Scripts

Clear, modular scripts for deploying Basecase to Ubuntu servers. Each script has a single purpose with no overlap.

## Quick Start

```bash
# On a fresh Ubuntu server:
sudo ./server-setup.sh     # One-time server preparation
./env-manager.sh setup      # Configure environment variables
./deploy.sh                 # Deploy the application
sudo ./nginx-setup.sh       # Configure Nginx
```

## Scripts Overview

### 🔧 server-setup.sh
**Purpose:** One-time server preparation  
**Run as:** root  
**When:** Once, on a fresh server  

Does:
- System updates
- Installs Bun, Node.js, PM2
- Creates app user
- Configures firewall & fail2ban
- Does NOT deploy code

### 🔐 env-manager.sh
**Purpose:** Manage environment variables  
**Run as:** appuser  
**When:** Initial setup & when env changes  

Features:
- Interactive setup with immediate feedback
- Backup to `/home/appuser/.basecase-env/`
- Restore from backup (survives `rm -rf`)
- Shows character count for hidden inputs

Commands:
```bash
./env-manager.sh setup    # Interactive setup
./env-manager.sh backup   # Backup current .env
./env-manager.sh restore  # Restore from backup
```

### 🚀 deploy.sh
**Purpose:** Deploy/update application  
**Run as:** appuser  
**When:** Every deployment  

Does:
- Git pull
- Environment setup (auto-restore from backup)
- Dependencies install
- Build application
- PM2 restart

Options:
```bash
./deploy.sh                    # Full deployment
./deploy.sh --skip-pull        # Skip git pull
./deploy.sh --skip-build       # Use existing build
./deploy.sh --use-systemd      # Use systemd instead of PM2
```

### 🌐 nginx-setup.sh
**Purpose:** Configure Nginx reverse proxy  
**Run as:** root  
**When:** Initial setup or domain changes  

Usage:
```bash
sudo ./nginx-setup.sh                              # IP-only setup
sudo ./nginx-setup.sh example.com                  # Domain without SSL
sudo ./nginx-setup.sh example.com admin@email.com  # Domain with SSL
```

Features:
- Proper Next.js `_next/static` handling
- SSL with Let's Encrypt
- Security headers
- Gzip compression

## Legacy Scripts

These scripts are kept for compatibility but use the new modular scripts above instead:

- `setup-env.sh` - Legacy env setup (use env-manager.sh)
- `setup-instantdb.sh` - InstantDB setup
- `migrate-schema.mjs` - Schema migration
- `setup-git-deploy.sh` - Git deploy keys setup
- `setup-pm2.sh` - PM2 setup
- `start-production.sh` - Production start script

## Deployment Flow

### First Time Setup
```bash
# 1. On your server as root
sudo ./scripts/server-setup.sh

# 2. As appuser, clone repository
su - appuser
git clone https://github.com/x7finance/basecase.git /home/appuser/app
cd /home/appuser/app

# 3. Setup environment
./scripts/env-manager.sh setup

# 4. Deploy
./scripts/deploy.sh

# 5. As root, configure Nginx
sudo ./scripts/nginx-setup.sh yourdomain.com your@email.com
```

### Updates
```bash
cd /home/appuser/app
./scripts/deploy.sh
```

### After `rm -rf /home/appuser/app`
```bash
# Clone again
git clone https://github.com/x7finance/basecase.git /home/appuser/app
cd /home/appuser/app

# Restore env from backup
./scripts/env-manager.sh restore

# Deploy
./scripts/deploy.sh
```

## Environment Backup

Your `.env` is automatically backed up to:
- `/home/appuser/.basecase-env/.env.backup` (latest)
- `/home/appuser/.basecase-env/.env.backup.TIMESTAMP` (history)

This survives `rm -rf` of the project directory.

## Monitoring

### PM2 Commands
```bash
pm2 status              # Check status
pm2 logs basecase-web   # View logs
pm2 monit               # Resource monitor
pm2 restart all         # Restart
```

### Nginx Commands
```bash
sudo nginx -t                  # Test config
sudo systemctl reload nginx    # Reload
sudo systemctl status nginx    # Status
```

## Troubleshooting

### Application not starting
```bash
pm2 logs basecase-web --lines 50
```

### Nginx 502 Bad Gateway
```bash
# Check if app is running
curl http://localhost:3001

# Check PM2
pm2 status
```

### Environment issues
```bash
# Check current env
cat .env

# Restore from backup
./scripts/env-manager.sh restore
```

## Security Notes

- Environment backups are stored with 600 permissions
- Sensitive inputs show character count, not content
- Firewall allows only ports 22, 80, 443
- Fail2ban protects SSH
- Remember to set up SSH keys and disable password auth