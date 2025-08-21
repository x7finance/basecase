#!/bin/bash
# ==============================================================================
# Quick Redeploy Script for Basecase
# ==============================================================================
# Purpose: One-liner to completely redeploy after rm -rf
# Usage: curl -fsSL https://raw.githubusercontent.com/x7finance/basecase/main/redeploy.sh | bash
# ==============================================================================

set -euo pipefail

APP_DIR="/home/appuser/app"
ENV_BACKUP_DIR="/home/appuser/.basecase-env"

echo "====================================="
echo "Basecase Quick Redeploy"
echo "====================================="
echo ""

# Check if running as appuser or root
if [ "$(whoami)" != "appuser" ] && [ "$(whoami)" != "root" ]; then
    echo "Run as appuser or root"
    exit 1
fi

# Function to run as appuser
run_as_app() {
    if [ "$(whoami)" = "root" ]; then
        su - appuser -c "$1"
    else
        eval "$1"
    fi
}

# Step 1: Clone repository
echo "[1/5] Cloning repository..."
if [ -d "$APP_DIR/.git" ]; then
    echo "Repository exists, pulling latest..."
    run_as_app "cd $APP_DIR && git pull origin main"
else
    echo "Cloning fresh repository..."
    run_as_app "git clone https://github.com/x7finance/basecase.git $APP_DIR"
fi

# Step 2: Restore environment from backup
echo "[2/5] Restoring environment..."
if [ -f "$ENV_BACKUP_DIR/.env.backup" ]; then
    echo "Found backup at $ENV_BACKUP_DIR/.env.backup"
    run_as_app "cp $ENV_BACKUP_DIR/.env.backup $APP_DIR/.env"
    echo "✓ Environment restored"
else
    echo "No backup found. Please run:"
    echo "  cd $APP_DIR && ./scripts/env-manager.sh setup"
    exit 1
fi

# Step 3: Install dependencies
echo "[3/5] Installing dependencies..."
run_as_app "cd $APP_DIR && bun install"

# Step 4: Build application
echo "[4/5] Building application..."
run_as_app "cd $APP_DIR && bun run build"

# Step 5: Restart with PM2
echo "[5/5] Restarting application..."
if run_as_app "pm2 list | grep -q basecase-web"; then
    run_as_app "cd $APP_DIR && pm2 reload ecosystem.config.js --update-env"
else
    run_as_app "cd $APP_DIR && pm2 start ecosystem.config.js --env production"
fi
run_as_app "pm2 save"

echo ""
echo "====================================="
echo "Redeploy Complete!"
echo "====================================="
echo ""
run_as_app "pm2 status"
echo ""
echo "Your application is running at http://localhost:3001"
echo "View logs: pm2 logs basecase-web"
echo ""