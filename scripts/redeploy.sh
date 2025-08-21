#!/bin/bash

# Redeploy Script - Build local code and restart (NO git pull)

set -e

# Fix terminal type for compatibility
export TERM=${TERM:-xterm-256color}

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=========================================="
echo "     Basecase Redeploy (Local Build)"
echo -e "==========================================${NC}"

# Configuration
APP_DIR="/opt/basecase"
PM2_APP_NAME="basecase"

# Allow running as root or regular user
# if [ "$EUID" -eq 0 ]; then 
#    echo -e "${YELLOW}Warning: Running as root${NC}"
# fi

echo -e "${YELLOW}Starting local redeploy...${NC}"
echo -e "${YELLOW}⚠️  This will build LOCAL code without pulling from GitHub${NC}"
echo ""

# Navigate to app directory
cd "$APP_DIR"

# Show current git status
echo -e "${BLUE}Current git status:${NC}"
git status --short

echo ""
read -p "Continue with local build? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled"
    exit 1
fi

# Install dependencies (in case package.json changed)
echo -e "${YELLOW}📦 Installing dependencies...${NC}"
bun install

# Build the application with local code
echo -e "${YELLOW}🔨 Building application from local code...${NC}"
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
pm2 restart "$PM2_APP_NAME"

# Save PM2 configuration
pm2 save

echo ""
echo -e "${GREEN}✅ Local redeploy complete!${NC}"
echo ""
echo "Check status with: pm2 status"
echo "View logs with: pm2 logs $PM2_APP_NAME"
echo ""
echo -e "${YELLOW}Note: This deployed your LOCAL code changes${NC}"
echo -e "${YELLOW}To deploy from GitHub, use: ./scripts/deploy-fresh.sh${NC}"