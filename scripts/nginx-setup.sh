#!/bin/bash

# Nginx Setup Script

set -e

# Fix terminal type for compatibility
export TERM=${TERM:-xterm-256color}

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Configuration
APP_PORT=3001

echo -e "${BLUE}${BOLD}Nginx Configuration Setup${NC}"
echo ""

# Load domain from .env
if [ -f .env ]; then
    source .env
else
    echo -e "${RED}Error: .env file not found. Run setup.sh first${NC}"
    exit 1
fi

if [ -z "$DOMAIN" ]; then
    echo -e "${RED}Error: Domain not configured${NC}"
    exit 1
fi

echo -e "${CYAN}Configuring nginx for: ${BOLD}$DOMAIN${NC}"
echo ""

# Create nginx config
sudo tee /etc/nginx/sites-available/basecase > /dev/null << EOF
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:$APP_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Enable site
sudo ln -sf /etc/nginx/sites-available/basecase /etc/nginx/sites-enabled/

# Test configuration
echo -e "${CYAN}Testing nginx configuration...${NC}"
sudo nginx -t

# Reload nginx
echo -e "${CYAN}Reloading nginx...${NC}"
sudo systemctl reload nginx

echo ""
echo -e "${GREEN}✅ Nginx configured successfully!${NC}"
echo ""

# SSL Setup with Certbot
if [ -n "$SSL_EMAIL" ]; then
    echo -e "${YELLOW}Setting up SSL with Let's Encrypt...${NC}"
    
    # Install certbot if not present
    if ! command -v certbot &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y certbot python3-certbot-nginx
    fi
    
    # Get SSL certificate
    sudo certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos --email "$SSL_EMAIL"
    
    echo -e "${GREEN}✅ SSL configured successfully!${NC}"
else
    echo -e "${YELLOW}⚠️  SSL email not configured. Skipping SSL setup.${NC}"
    echo -e "${CYAN}To add SSL later, run:${NC}"
    echo -e "  sudo certbot --nginx -d $DOMAIN"
fi

echo ""
echo -e "${GREEN}Your site is now available at:${NC}"
if [ -n "$SSL_EMAIL" ]; then
    echo -e "  ${BOLD}https://$DOMAIN${NC}"
else
    echo -e "  ${BOLD}http://$DOMAIN${NC}"
fi
echo ""