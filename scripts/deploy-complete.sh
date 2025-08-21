#!/bin/bash

# Complete Basecase Deployment - Single Script for Full Site Launch
# 
# Usage: 
#   curl -fsSL https://raw.githubusercontent.com/x7finance/basecase/main/scripts/deploy-complete.sh -o deploy-complete.sh && chmod +x deploy-complete.sh && ./deploy-complete.sh
#
# This script is idempotent and can be run multiple times safely.

set -e

# Fix terminal type for compatibility
if [ -z "$TERM" ] || ! tput colors >/dev/null 2>&1; then
  export TERM=xterm
fi

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
REPO_URL="https://github.com/x7finance/basecase.git"
RAW_BASE_URL="https://raw.githubusercontent.com/x7finance/basecase/main/scripts"

# Function to download and execute a script
download_and_run() {
    local script_name="$1"
    local script_url="$RAW_BASE_URL/$script_name"
    local temp_script="/tmp/$script_name"
    
    echo -e "${CYAN}Downloading $script_name...${NC}"
    if curl -fsSL "$script_url" -o "$temp_script"; then
        chmod +x "$temp_script"
        echo -e "${CYAN}Running $script_name...${NC}"
        "$temp_script"
        rm -f "$temp_script"
    else
        echo -e "${RED}❌ Failed to download $script_name${NC}"
        exit 1
    fi
}

clear

echo -e "${PURPLE}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║               🚀 BASECASE COMPLETE DEPLOYMENT               ║"
echo "║                                                              ║"
echo "║            From Zero to Live Site in Minutes                ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${CYAN}This script will guide you through the complete deployment process:${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Deployment Steps:${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${BOLD}1)${NC} 🌐 Domain & SSL Configuration"
echo -e "  ${BOLD}2)${NC} 🔧 Environment Variables Setup"  
echo -e "  ${BOLD}3)${NC} 🌍 Web Server Configuration"
echo -e "  ${BOLD}4)${NC} 🚀 Application Deployment"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}⚠️  Requirements:${NC}"
echo -e "  • Fresh server with sudo access"
echo -e "  • Domain pointing to this server"
echo -e "  • InstantDB account (https://instantdb.com)"
echo ""

read -p "$(echo -e ${BOLD})Ready to begin? (Y/n): $(echo -e ${NC})" -n 1 -r
echo ""

if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo -e "${YELLOW}Deployment cancelled. Run this script when you're ready.${NC}"
    exit 0
fi

echo ""
echo -e "${GREEN}${BOLD}Starting Complete Deployment...${NC}"
echo ""

# Step 1: Domain and SSL Setup
echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}${BOLD}Step 1/4: Domain & SSL Configuration${NC}"
echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if domain is already configured
if [ -f .env ] && grep -q "DOMAIN=" .env 2>/dev/null; then
    source .env
    echo -e "${GREEN}✓ Domain already configured: ${BOLD}$DOMAIN${NC}"
    
    read -p "Reconfigure domain? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        download_and_run "setup.sh"
    else
        echo -e "${CYAN}Keeping existing domain configuration${NC}"
    fi
else
    download_and_run "setup.sh"
fi

# Save .env to temp location for later steps
if [ -f .env ]; then
    cp .env ~/.env-basecase-temp
fi

echo ""
echo -e "${GREEN}✅ Step 1 Complete: Domain configured${NC}"
echo ""

# Step 2: Environment Variables
echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}${BOLD}Step 2/4: Environment Variables Setup${NC}"
echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Restore .env from previous step if it exists
if [ -f ~/.env-basecase-temp ]; then
    cp ~/.env-basecase-temp .env
fi

# Check if environment is already configured
if [ -f .env ] && grep -q "INSTANT_APP_ID=" .env 2>/dev/null && grep -q "BETTER_AUTH_SECRET=" .env 2>/dev/null; then
    echo -e "${GREEN}✓ Environment already configured${NC}"
    
    read -p "Reconfigure environment? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Download env-manage.sh and run setup
        temp_env_script="/tmp/env-manage.sh"
        curl -fsSL "$RAW_BASE_URL/env-manage.sh" -o "$temp_env_script"
        chmod +x "$temp_env_script"
        "$temp_env_script" setup
        rm -f "$temp_env_script"
    else
        echo -e "${CYAN}Keeping existing environment configuration${NC}"
    fi
else
    echo -e "${CYAN}Running environment setup...${NC}"
    echo -e "${YELLOW}This will configure your database, authentication, and services${NC}"
    echo ""
    
    # Download env-manage.sh and run setup
    temp_env_script="/tmp/env-manage.sh"
    curl -fsSL "$RAW_BASE_URL/env-manage.sh" -o "$temp_env_script"
    "$temp_env_script" setup
    rm -f "$temp_env_script"
fi

# Update temp .env file
if [ -f .env ]; then
    cp .env ~/.env-basecase-temp
fi

echo ""
echo -e "${GREEN}✅ Step 2 Complete: Environment configured${NC}"
echo ""

# Step 3: Web Server Configuration
echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}${BOLD}Step 3/4: Web Server Configuration${NC}"
echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if nginx is already configured
if [ -f /etc/nginx/sites-enabled/basecase ]; then
    echo -e "${GREEN}✓ Nginx already configured${NC}"
    
    read -p "Reconfigure nginx? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        download_and_run "nginx-setup.sh"
    else
        echo -e "${CYAN}Keeping existing nginx configuration${NC}"
    fi
else
    echo -e "${CYAN}Configuring nginx and SSL certificates...${NC}"
    download_and_run "nginx-setup.sh"
fi

echo ""
echo -e "${GREEN}✅ Step 3 Complete: Web server configured${NC}"
echo ""

# Step 4: Application Deployment
echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}${BOLD}Step 4/4: Application Deployment${NC}"
echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Setup app directory and clone repo
if [ ! -d "$APP_DIR" ]; then
    echo -e "${CYAN}Creating app directory: $APP_DIR${NC}"
    sudo mkdir -p "$APP_DIR"
    sudo chown $(whoami):$(whoami) "$APP_DIR"
    
    echo -e "${CYAN}Cloning repository from GitHub...${NC}"
    git clone "$REPO_URL" "$APP_DIR"
elif [ ! -d "$APP_DIR/.git" ]; then
    echo -e "${CYAN}Initializing git repository in existing directory...${NC}"
    cd "$APP_DIR"
    git init
    git remote add origin "$REPO_URL"
    git fetch origin main
    git reset --hard origin/main
else
    echo -e "${GREEN}✓ Repository already cloned${NC}"
fi

# Change to app directory
cd "$APP_DIR"

# Copy .env file to app directory if it exists in current directory
if [ -f ~/.env-basecase-temp ]; then
    cp ~/.env-basecase-temp .env
    rm -f ~/.env-basecase-temp
elif [ -f .env ] && [ "$(pwd)" != "$APP_DIR" ]; then
    # Copy .env from current directory to app directory
    cp .env "$APP_DIR/.env"
fi

echo -e "${CYAN}Deploying application from GitHub...${NC}"
download_and_run "deploy-fresh.sh"

echo ""
echo -e "${GREEN}✅ Step 4 Complete: Application deployed${NC}"
echo ""

# Final Success Message
clear

echo -e "${GREEN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║               🎉 DEPLOYMENT SUCCESSFUL! 🎉                  ║"
echo "║                                                              ║"
echo "║                Your site is now LIVE!                       ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Load domain from .env to show the final URL
if [ -f .env ]; then
    source .env
    echo -e "${CYAN}${BOLD}🌟 Your site is available at:${NC}"
    echo ""
    if [ -n "$SSL_EMAIL" ]; then
        echo -e "  ${BOLD}${GREEN}https://$DOMAIN${NC}"
    else
        echo -e "  ${BOLD}${BLUE}http://$DOMAIN${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Could not load domain from .env${NC}"
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Deployment Summary:${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${GREEN}✓${NC} Domain and SSL configured"
echo -e "  ${GREEN}✓${NC} Environment variables set"
echo -e "  ${GREEN}✓${NC} Web server (nginx) configured"
echo -e "  ${GREEN}✓${NC} Application deployed and running"
echo -e "  ${GREEN}✓${NC} PM2 process manager configured"
echo ""

echo -e "${YELLOW}${BOLD}📋 Useful Commands:${NC}"
echo -e "  • Check status: ${BOLD}pm2 status${NC}"
echo -e "  • View logs: ${BOLD}pm2 logs basecase${NC}"
echo -e "  • Redeploy from GitHub: ${BOLD}./scripts/deploy-fresh.sh${NC}"
echo -e "  • Manage environment: ${BOLD}./scripts/env-manage.sh${NC}"
echo -e "  • Update nginx config: ${BOLD}./scripts/nginx-setup.sh${NC}"
echo ""

echo -e "${CYAN}💡 To redeploy after making changes:${NC}"
echo -e "  • For GitHub changes: ${BOLD}./scripts/deploy-fresh.sh${NC}"
echo -e "  • For local changes: ${BOLD}./scripts/redeploy.sh${NC}"
echo ""

echo -e "${GREEN}${BOLD}🎯 Your Basecase application is ready!${NC}"
echo ""