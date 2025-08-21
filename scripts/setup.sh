#!/bin/bash

# Initial Setup Script - Domain and SSL Configuration

set -e

# Fix terminal type for compatibility
export TERM=${TERM:-xterm-256color}

# Colors for better UX
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

clear

echo -e "${PURPLE}${BOLD}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                                                          ║"
echo "║                   🚀 BASECASE SETUP                     ║"
echo "║                                                          ║"
echo "║         Welcome to your application setup wizard         ║"
echo "║                                                          ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${CYAN}This quick setup will configure your domain and SSL settings.${NC}"
echo -e "${CYAN}It should take less than 30 seconds.${NC}"
echo ""

# Check if .env already exists
if [ -f .env ] && grep -q "DOMAIN=" .env 2>/dev/null; then
    source .env
    echo -e "${YELLOW}⚠️  Existing configuration detected:${NC}"
    echo -e "   Domain: ${BOLD}$DOMAIN${NC}"
    echo -e "   SSL Email: ${BOLD}$SSL_EMAIL${NC}"
    echo ""
    read -p "Do you want to reconfigure? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}✅ Keeping existing configuration${NC}"
        echo ""
        echo -e "${CYAN}Next step: ${BOLD}./scripts/env-manage.sh setup${NC}"
        exit 0
    fi
    echo ""
fi

# Domain input with validation
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Step 1 of 2: Domain Configuration${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}Enter your domain name (without https://)${NC}"
echo -e "${CYAN}Example: myapp.com or app.example.com${NC}"
echo ""

while true; do
    read -p "$(echo -e ${BOLD})Domain: $(echo -e ${NC})" DOMAIN
    
    # Basic domain validation
    if [ -z "$DOMAIN" ]; then
        echo -e "${RED}❌ Domain cannot be empty. Please try again.${NC}"
    elif [[ ! "$DOMAIN" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$ ]]; then
        echo -e "${RED}❌ Invalid domain format. Please enter a valid domain.${NC}"
    else
        echo -e "${GREEN}✓ Domain looks good!${NC}"
        break
    fi
done

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Step 2 of 2: SSL Certificate Email${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}This email will be used for SSL certificate notifications${NC}"
echo -e "${CYAN}(Let's Encrypt will send renewal reminders here)${NC}"
echo ""

# Email validation
while true; do
    read -p "$(echo -e ${BOLD})Email: $(echo -e ${NC})" SSL_EMAIL
    
    if [ -z "$SSL_EMAIL" ]; then
        echo -e "${RED}❌ Email cannot be empty. Please try again.${NC}"
    elif [[ ! "$SSL_EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        echo -e "${RED}❌ Invalid email format. Please enter a valid email.${NC}"
    else
        echo -e "${GREEN}✓ Email looks good!${NC}"
        break
    fi
done

# Confirmation
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Please confirm your settings:${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${BOLD}Domain:${NC}     $DOMAIN"
echo -e "  ${BOLD}SSL Email:${NC}  $SSL_EMAIL"
echo ""

read -p "$(echo -e ${BOLD})Is this correct? (Y/n): $(echo -e ${NC})" -n 1 -r
echo ""
if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo -e "${YELLOW}Setup cancelled. Please run the script again.${NC}"
    exit 1
fi

# Create initial .env with just these values
cat > .env << EOF
# Core Configuration
DOMAIN=$DOMAIN
SSL_EMAIL=$SSL_EMAIL
EOF

echo ""
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}${BOLD}✅ Initial Setup Complete!${NC}"
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}Your domain and SSL settings have been saved.${NC}"
echo ""
echo -e "${YELLOW}${BOLD}📋 Next Step:${NC}"
echo -e "${CYAN}Run the following command to configure your application:${NC}"
echo ""
echo -e "  ${BOLD}./scripts/env-manage.sh setup${NC}"
echo ""
echo -e "${CYAN}This will guide you through setting up databases, authentication,${NC}"
echo -e "${CYAN}and other services your application needs.${NC}"
echo ""