#!/bin/bash

# VPC Cleanup Script - Clean slate for testing deployments

set -e

# Fix terminal type for compatibility
export TERM=${TERM:-xterm-256color}

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Configuration
APP_DIR="/opt/basecase"
PM2_APP_NAME="basecase"

clear

echo -e "${RED}${BOLD}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                                                          ║"
echo "║              🧹 VPC CLEANUP SCRIPT                      ║"
echo "║                                                          ║"
echo "║         ⚠️  THIS WILL RESET YOUR ENVIRONMENT            ║"
echo "║                                                          ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${YELLOW}${BOLD}WARNING: This script will:${NC}"
echo -e "${RED}• Stop all PM2 processes${NC}"
echo -e "${RED}• Remove the application directory${NC}"
echo -e "${RED}• Clean up node/bun caches${NC}"
echo -e "${RED}• Remove environment files${NC}"
echo -e "${RED}• Clear nginx sites if configured${NC}"
echo ""
echo -e "${CYAN}This gives you a clean slate to test deployment${NC}"
echo ""

read -p "$(echo -e ${BOLD})Are you SURE you want to continue? Type 'yes' to confirm: $(echo -e ${NC})" confirm

if [ "$confirm" != "yes" ]; then
    echo -e "${GREEN}Cleanup cancelled. Nothing was changed.${NC}"
    exit 0
fi

echo ""
echo -e "${YELLOW}Starting cleanup...${NC}"
echo ""

# First, copy this script to a safe location so it doesn't delete itself!
SAFE_SCRIPT="/tmp/basecase-cleanup.sh"
echo -e "${CYAN}→ Copying cleanup script to safe location${NC}"
cp "$0" "$SAFE_SCRIPT"
chmod +x "$SAFE_SCRIPT"
echo -e "${GREEN}  ✓ Script saved to: $SAFE_SCRIPT${NC}"
echo ""

# If we're running from the app directory, switch to the safe copy
if [[ "$0" == *"/opt/basecase/"* ]]; then
    echo -e "${YELLOW}Switching to safe copy of script...${NC}"
    exec "$SAFE_SCRIPT" "$@"
    exit 0
fi

# Function to safely execute commands
safe_exec() {
    local cmd="$1"
    local desc="$2"
    
    echo -e "${CYAN}→ $desc${NC}"
    if eval "$cmd" 2>/dev/null; then
        echo -e "${GREEN}  ✓ Done${NC}"
    else
        echo -e "${YELLOW}  ⚠️  Skipped (not found or already clean)${NC}"
    fi
}

# 1. Stop PM2 processes
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Stopping Application Processes${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if command -v pm2 &> /dev/null; then
    safe_exec "pm2 delete $PM2_APP_NAME" "Stopping PM2 app: $PM2_APP_NAME"
    safe_exec "pm2 delete all" "Stopping all PM2 apps"
    safe_exec "pm2 kill" "Killing PM2 daemon"
else
    echo -e "${YELLOW}  PM2 not found, skipping${NC}"
fi

# Kill any lingering node/bun processes
safe_exec "pkill -f 'node.*basecase' || true" "Stopping Node processes"
safe_exec "pkill -f 'bun.*basecase' || true" "Stopping Bun processes"

echo ""

# 2. Clean application directory
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Cleaning Application Directory${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ -d "$APP_DIR" ]; then
    # Backup .env if it exists
    if [ -f "$APP_DIR/.env" ]; then
        echo -e "${CYAN}→ Backing up .env file${NC}"
        cp "$APP_DIR/.env" "/tmp/basecase.env.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "${GREEN}  ✓ Env backup saved to /tmp/${NC}"
    fi
    
    safe_exec "rm -rf $APP_DIR" "Removing $APP_DIR"
else
    echo -e "${YELLOW}  App directory not found${NC}"
fi

# Create fresh directory
safe_exec "mkdir -p $APP_DIR" "Creating fresh $APP_DIR"

echo ""

# 3. Clean package manager caches
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Cleaning Package Manager Caches${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Bun cache
if command -v bun &> /dev/null; then
    safe_exec "bun pm cache rm" "Clearing Bun cache"
fi

# NPM cache (in case it was used)
if command -v npm &> /dev/null; then
    safe_exec "npm cache clean --force" "Clearing NPM cache"
fi

# Clear global node_modules that might interfere
safe_exec "rm -rf ~/.bun/install/cache/*" "Clearing Bun install cache"

echo ""

# 4. Clean nginx configuration (if exists)
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Cleaning Web Server Configuration${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ -f "/etc/nginx/sites-enabled/basecase" ]; then
    safe_exec "sudo rm -f /etc/nginx/sites-enabled/basecase" "Removing nginx site config"
    safe_exec "sudo rm -f /etc/nginx/sites-available/basecase" "Removing nginx site available"
    safe_exec "sudo nginx -t && sudo systemctl reload nginx" "Reloading nginx"
else
    echo -e "${YELLOW}  No nginx configuration found${NC}"
fi

echo ""

# 5. Clean systemd services (if any)
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Cleaning System Services${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ -f "/etc/systemd/system/basecase.service" ]; then
    safe_exec "sudo systemctl stop basecase" "Stopping basecase service"
    safe_exec "sudo systemctl disable basecase" "Disabling basecase service"
    safe_exec "sudo rm -f /etc/systemd/system/basecase.service" "Removing service file"
    safe_exec "sudo systemctl daemon-reload" "Reloading systemd"
else
    echo -e "${YELLOW}  No systemd service found${NC}"
fi

echo ""

# 6. Clean temp files and logs
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Cleaning Temporary Files and Logs${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

safe_exec "rm -rf /tmp/basecase*" "Cleaning temp files"
safe_exec "rm -rf ~/.pm2/logs/*" "Cleaning PM2 logs"
safe_exec "rm -rf /var/log/basecase*" "Cleaning app logs"

echo ""

# 7. Reset git configuration (optional)
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Git Repository Status${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

read -p "Do you want to clone a fresh copy of the repository? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Repository URL (or press Enter to skip): " REPO_URL
    if [ -n "$REPO_URL" ]; then
        cd /opt
        safe_exec "git clone $REPO_URL basecase" "Cloning fresh repository"
    fi
else
    echo -e "${CYAN}  Skipping repository clone${NC}"
fi

echo ""

# Summary
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}${BOLD}✅ Cleanup Complete!${NC}"
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}Your VPC is now clean and ready for fresh deployment.${NC}"
echo ""
echo -e "${YELLOW}${BOLD}Next Steps:${NC}"
echo -e "1. ${CYAN}cd $APP_DIR${NC}"
echo -e "2. ${CYAN}git clone <your-repo> .${NC} (if not done above)"
echo -e "3. ${CYAN}./scripts/setup.sh${NC} - Configure domain"
echo -e "4. ${CYAN}./scripts/env-manage.sh setup${NC} - Configure environment"
echo -e "5. ${CYAN}./scripts/deploy-fresh.sh${NC} - Deploy application"
echo ""

# Show env backup location if it exists
if [ -f "/tmp/basecase.env.backup."* ] 2>/dev/null; then
    echo -e "${GREEN}💡 Tip: Your previous .env was backed up to:${NC}"
    ls -la /tmp/basecase.env.backup.* | tail -1
    echo -e "${CYAN}You can restore it with: ./scripts/env-manage.sh${NC} (option 5)"
    echo ""
fi

echo -e "${PURPLE}Good luck with your deployment! 🚀${NC}"
echo ""

# Remind about the safe copy
echo -e "${DIM}Note: This cleanup script is available at:${NC}"
echo -e "${CYAN}$SAFE_SCRIPT${NC}"
echo -e "${DIM}You can run it again if needed.${NC}"
echo ""