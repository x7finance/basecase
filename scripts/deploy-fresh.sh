#!/bin/bash

# Deploy Script - Full deployment from GitHub

set -e

# Fix terminal type for compatibility
export TERM=${TERM:-xterm-256color}

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=========================================="
echo "     Basecase Deploy Script"
echo -e "==========================================${NC}"

# Configuration
APP_DIR="/opt/basecase"
PM2_APP_NAME="basecase"

# Allow running as root or regular user
# if [ "$EUID" -eq 0 ]; then 
#    echo -e "${YELLOW}Warning: Running as root${NC}"
# fi

echo -e "${YELLOW}Starting deployment...${NC}"

# Navigate to app directory
cd "$APP_DIR"

# Pull latest code from GitHub (force overwrite local)
echo -e "${YELLOW}📥 Pulling latest code from GitHub...${NC}"
git fetch origin main
git reset --hard origin/main

# Install dependencies
echo -e "${YELLOW}📦 Installing dependencies...${NC}"
bun install

# Build the application
echo -e "${YELLOW}🔨 Building application...${NC}"
bun run build

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${RED}⚠️  Warning: .env file not found!${NC}"
    echo "Run ./scripts/env-manage.sh setup to configure"
    exit 1
fi

# Copy .env to all apps and packages that need it
echo -e "${YELLOW}📋 Distributing .env to all packages...${NC}"
cp .env apps/web/.env
[ -d "packages/auth" ] && cp .env packages/auth/.env
[ -d "packages/email" ] && cp .env packages/email/.env
[ -d "packages/database" ] && cp .env packages/database/.env
# Copy to any other app directories
for dir in apps/*/; do
    if [ -d "$dir" ]; then
        cp .env "$dir/.env"
        echo -e "${GREEN}  ✓ Copied to $dir${NC}"
    fi
done

# Restart PM2 process
echo -e "${YELLOW}🔄 Restarting PM2 process...${NC}"
pm2 restart "$PM2_APP_NAME" || pm2 start bun --name "$PM2_APP_NAME" -- run start

# Save PM2 configuration
pm2 save

echo ""
echo -e "${GREEN}✅ Deployment complete!${NC}"
echo ""
echo "Check status with: pm2 status"
echo "View logs with: pm2 logs $PM2_APP_NAME"