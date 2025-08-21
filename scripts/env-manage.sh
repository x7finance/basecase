#!/bin/bash

# Environment Variables Management Script

# Fix terminal type for compatibility
export TERM=${TERM:-xterm-256color}

# External backup directory (outside app directory)
BACKUP_DIR="$HOME/.basecase-env-backups"
ENV_FILE=".env"

# Colors for better UX
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Helper function for password input
read_secret() {
    local prompt="$1"
    local var_name="$2"
    echo -n "$prompt"
    read -s value
    echo ""
    eval "$var_name=\"\$value\""
}

# Progress indicator
show_progress() {
    echo -e "${GREEN}✓${NC} $1"
}

show_header() {
    clear
    echo -e "${PURPLE}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║                                                          ║"
    echo "║              🔧 ENVIRONMENT MANAGER                     ║"
    echo "║                                                          ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

show_menu() {
    show_header
    echo -e "${CYAN}Manage your application's environment variables${NC}"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Available Options:${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${BOLD}1)${NC} 🚀 Setup      - Configure all environment variables"
    echo -e "  ${BOLD}2)${NC} ➕ Add        - Add or update specific variables"
    echo -e "  ${BOLD}3)${NC} 📋 Paste      - Paste entire .env file content"
    echo -e "  ${BOLD}4)${NC} 👁️  View       - Show current configuration"
    echo -e "  ${BOLD}5)${NC} 💾 Backup     - Save current env to backup"
    echo -e "  ${BOLD}6)${NC} 🔄 Restore    - Restore from backup"
    echo -e "  ${BOLD}7)${NC} 📁 List       - Show available backups"
    echo -e "  ${BOLD}8)${NC} ❌ Exit       - Exit the manager"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

setup_env() {
    show_header
    echo -e "${YELLOW}${BOLD}Environment Setup Wizard${NC}"
    echo -e "${CYAN}This will guide you through configuring all necessary variables${NC}"
    echo ""
    
    # Load existing domain/SSL if present - use export to make them available
    if [ -f "$ENV_FILE" ]; then
        while IFS='=' read -r key value; do
            # Skip comments and empty lines
            if [[ "$key" =~ ^#.*$ ]] || [ -z "$key" ]; then
                continue
            fi
            # Export the variable so it's available in this function
            export "$key=$value"
        done < "$ENV_FILE"
    fi
    
    # Check if domain is set
    if [ -z "$DOMAIN" ]; then
        echo -e "${RED}⚠️  Domain not configured!${NC}"
        echo -e "${CYAN}Please run ${BOLD}./scripts/setup.sh${NC} first${NC}"
        echo ""
        read -p "Press Enter to continue..."
        return
    fi
    
    echo -e "${GREEN}✓ Domain configured:${NC} ${BOLD}$DOMAIN${NC}"
    echo ""
    
    # Required vs Optional tracking
    required_count=0
    optional_count=0
    
    # InstantDB (Required)
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Database Configuration ${RED}(Required)${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${DIM}Get these from https://instantdb.com after creating your app${NC}"
    echo ""
    
    while true; do
        read -p "$(echo -e ${BOLD})InstantDB App ID: $(echo -e ${NC})" NEW_INSTANT_APP_ID
        if [ -z "$NEW_INSTANT_APP_ID" ]; then
            echo -e "${RED}❌ This field is required${NC}"
        else
            INSTANT_APP_ID="$NEW_INSTANT_APP_ID"
            show_progress "App ID saved"
            required_count=$((required_count + 1))
            break
        fi
    done
    
    while true; do
        read_secret "$(echo -e ${BOLD})InstantDB Admin Token: $(echo -e ${NC})" NEW_INSTANT_ADMIN_TOKEN
        if [ -z "$NEW_INSTANT_ADMIN_TOKEN" ]; then
            echo -e "${RED}❌ This field is required${NC}"
        else
            INSTANT_ADMIN_TOKEN="$NEW_INSTANT_ADMIN_TOKEN"
            show_progress "Admin token saved"
            required_count=$((required_count + 1))
            break
        fi
    done
    
    # Better Auth (Required - Auto Generated)
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Authentication Setup ${RED}(Required)${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    if [ -n "$BETTER_AUTH_SECRET" ]; then
        echo -e "${YELLOW}Existing auth secret detected. Keep it? (Y/n):${NC} "
        read -n 1 -r keep_secret
        echo ""
        if [[ ! $keep_secret =~ ^[Nn]$ ]]; then
            show_progress "Keeping existing auth secret"
        else
            BETTER_AUTH_SECRET=$(openssl rand -base64 32)
            show_progress "Generated new auth secret"
        fi
    else
        echo -e "${CYAN}Generating secure authentication secret...${NC}"
        BETTER_AUTH_SECRET=$(openssl rand -base64 32)
        show_progress "Generated auth secret"
    fi
    required_count=$((required_count + 1))
    
    # App URLs (Auto-configured from domain)
    NEXT_PUBLIC_APP_URL="https://$DOMAIN"
    BETTER_AUTH_TRUSTED_ORIGINS="https://$DOMAIN"
    show_progress "Configured app URLs from domain"
    required_count=$((required_count + 1))
    
    # Optional Services
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Optional Services${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${DIM}Press Enter to skip any optional service${NC}"
    echo ""
    
    # Email Service
    echo -e "${CYAN}${BOLD}📧 Email Service (Resend)${NC}"
    echo -e "${DIM}For transactional emails and notifications${NC}"
    read -p "Resend API Key (optional): " RESEND_API_KEY
    if [ -n "$RESEND_API_KEY" ]; then
        echo -e "${CYAN}Configuring email settings...${NC}"
        
        # Suggest email domain based on main domain
        DEFAULT_EMAIL_DOMAIN="mail.$DOMAIN"
        read -p "Email domain (default: $DEFAULT_EMAIL_DOMAIN): " EMAIL_DOMAIN
        EMAIL_DOMAIN=${EMAIL_DOMAIN:-$DEFAULT_EMAIL_DOMAIN}
        
        DEFAULT_FROM_EMAIL="noreply@$EMAIL_DOMAIN"
        read -p "From email (default: $DEFAULT_FROM_EMAIL): " RESEND_FROM_EMAIL
        RESEND_FROM_EMAIL=${RESEND_FROM_EMAIL:-$DEFAULT_FROM_EMAIL}
        
        show_progress "Email service configured"
        optional_count=$((optional_count + 1))
    else
        echo -e "${DIM}→ Skipping email service${NC}"
    fi
    
    echo ""
    
    # OAuth Providers
    echo -e "${CYAN}${BOLD}🔐 OAuth Providers${NC}"
    echo -e "${DIM}For social login (Google, GitHub, etc.)${NC}"
    
    # Google OAuth
    read -p "Configure Google OAuth? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${DIM}Get credentials from https://console.cloud.google.com/${NC}"
        read -p "Google Client ID: " GOOGLE_CLIENT_ID
        read_secret "Google Client Secret: " GOOGLE_CLIENT_SECRET
        show_progress "Google OAuth configured"
        optional_count=$((optional_count + 1))
    else
        echo -e "${DIM}→ Skipping Google OAuth${NC}"
    fi
    
    # GitHub OAuth
    read -p "Configure GitHub OAuth? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${DIM}Get credentials from https://github.com/settings/developers${NC}"
        read -p "GitHub Client ID: " GITHUB_CLIENT_ID
        read_secret "GitHub Client Secret: " GITHUB_CLIENT_SECRET
        show_progress "GitHub OAuth configured"
        optional_count=$((optional_count + 1))
    else
        echo -e "${DIM}→ Skipping GitHub OAuth${NC}"
    fi
    
    echo ""
    
    # Analytics
    echo -e "${CYAN}${BOLD}📊 Analytics${NC}"
    read -p "Google Analytics ID (optional): " GA_MEASUREMENT_ID
    if [ -n "$GA_MEASUREMENT_ID" ]; then
        show_progress "Analytics configured"
        optional_count=$((optional_count + 1))
    else
        echo -e "${DIM}→ Skipping analytics${NC}"
    fi
    
    # Debug: Show what we're about to write
    echo ""
    echo -e "${CYAN}Writing configuration to .env...${NC}"
    
    # Write to .env file
    cat > "$ENV_FILE" << EOF
# ============================================
# BASECASE ENVIRONMENT VARIABLES
# Generated: $(date)
# ============================================

# Core Configuration
DOMAIN=${DOMAIN:-}
SSL_EMAIL=${SSL_EMAIL:-}

# Application URLs
NEXT_PUBLIC_APP_URL=$NEXT_PUBLIC_APP_URL
BETTER_AUTH_TRUSTED_ORIGINS=$BETTER_AUTH_TRUSTED_ORIGINS
APP_DOMAIN=$DOMAIN

# InstantDB
INSTANT_APP_ID=$INSTANT_APP_ID
NEXT_PUBLIC_INSTANT_APP_ID=$INSTANT_APP_ID
INSTANT_ADMIN_TOKEN=$INSTANT_ADMIN_TOKEN

# Authentication
BETTER_AUTH_SECRET=$BETTER_AUTH_SECRET

# Email Service
RESEND_API_KEY=${RESEND_API_KEY:-}
EMAIL_DOMAIN=${EMAIL_DOMAIN:-}
RESEND_FROM_EMAIL=${RESEND_FROM_EMAIL:-}

# OAuth Providers
GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID:-}
GOOGLE_CLIENT_SECRET=${GOOGLE_CLIENT_SECRET:-}
GITHUB_CLIENT_ID=${GITHUB_CLIENT_ID:-}
GITHUB_CLIENT_SECRET=${GITHUB_CLIENT_SECRET:-}

# Analytics
NEXT_PUBLIC_GA_MEASUREMENT_ID=${GA_MEASUREMENT_ID:-}

# Runtime Configuration
BUN_ENV=production
PORT=3001
EOF

    # Verify file was written
    if [ -f "$ENV_FILE" ]; then
        echo -e "${GREEN}✓ Configuration saved to .env${NC}"
        local line_count=$(wc -l < "$ENV_FILE")
        echo -e "${CYAN}File contains $line_count lines${NC}"
    else
        echo -e "${RED}❌ Error: Failed to write .env file${NC}"
    fi
    
    # Auto backup after setup
    backup_env "auto-setup" "silent"
    
    # Success summary
    echo ""
    echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}${BOLD}✅ Configuration Complete!${NC}"
    echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}Summary:${NC}"
    echo -e "  • ${BOLD}Required services:${NC} $required_count configured ✓"
    echo -e "  • ${BOLD}Optional services:${NC} $optional_count configured"
    echo -e "  • ${BOLD}Backup created:${NC} ~/.basecase-env-backups/"
    echo ""
    echo -e "${YELLOW}${BOLD}🚀 Your application is ready to deploy!${NC}"
    echo ""
    read -p "Press Enter to continue..."
}

paste_env() {
    show_header
    echo -e "${YELLOW}${BOLD}Paste Environment Variables${NC}"
    echo -e "${CYAN}Paste your entire .env file content below${NC}"
    echo -e "${CYAN}When done, press Ctrl+D on a new line${NC}"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # Create temp file for pasted content
    local temp_file="/tmp/env_paste_$$"
    cat > "$temp_file"
    
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Validate the pasted content
    local valid_lines=0
    local invalid_lines=0
    
    while IFS= read -r line; do
        # Skip empty lines and comments
        if [[ -z "$line" ]] || [[ "$line" =~ ^[[:space:]]*# ]]; then
            continue
        fi
        
        # Check if line is valid env format
        if [[ "$line" =~ ^[A-Z_][A-Z0-9_]*=.*$ ]]; then
            valid_lines=$((valid_lines + 1))
        else
            invalid_lines=$((invalid_lines + 1))
            echo -e "${RED}Invalid line: $line${NC}"
        fi
    done < "$temp_file"
    
    echo ""
    if [ $invalid_lines -gt 0 ]; then
        echo -e "${RED}Found $invalid_lines invalid lines${NC}"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            rm -f "$temp_file"
            echo -e "${YELLOW}Cancelled${NC}"
            read -p "Press Enter to continue..."
            return
        fi
    fi
    
    echo -e "${GREEN}Found $valid_lines valid environment variables${NC}"
    echo ""
    
    # Backup current env if exists
    if [ -f "$ENV_FILE" ]; then
        backup_env "pre-paste" "silent"
        echo -e "${CYAN}Current .env backed up${NC}"
    fi
    
    # Check if domain and SSL are set
    local has_domain=false
    local has_ssl=false
    
    if grep -q "^DOMAIN=" "$temp_file"; then
        has_domain=true
    fi
    if grep -q "^SSL_EMAIL=" "$temp_file"; then
        has_ssl=true
    fi
    
    # If domain/SSL not in paste but exist in current, preserve them
    if [ -f "$ENV_FILE" ]; then
        if ! $has_domain && grep -q "^DOMAIN=" "$ENV_FILE"; then
            local current_domain=$(grep "^DOMAIN=" "$ENV_FILE")
            echo "$current_domain" >> "$temp_file"
            echo -e "${CYAN}Preserved existing domain configuration${NC}"
        fi
        if ! $has_ssl && grep -q "^SSL_EMAIL=" "$ENV_FILE"; then
            local current_ssl=$(grep "^SSL_EMAIL=" "$ENV_FILE")
            echo "$current_ssl" >> "$temp_file"
            echo -e "${CYAN}Preserved existing SSL email configuration${NC}"
        fi
    fi
    
    # Copy to actual env file
    cp "$temp_file" "$ENV_FILE"
    rm -f "$temp_file"
    
    # Auto backup after paste
    backup_env "auto-paste" "silent"
    
    echo ""
    echo -e "${GREEN}✅ Environment variables imported successfully!${NC}"
    echo -e "${CYAN}$valid_lines variables have been saved${NC}"
    echo ""
    read -p "Press Enter to continue..."
}

add_variable() {
    show_header
    echo -e "${YELLOW}${BOLD}Add/Update Environment Variable${NC}"
    echo -e "${CYAN}Add a new variable or update an existing one${NC}"
    echo ""
    
    # Show common variable suggestions
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Common Variables:${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${DIM}• API keys (STRIPE_SECRET_KEY, OPENAI_API_KEY, etc.)${NC}"
    echo -e "${DIM}• Database URLs (DATABASE_URL, REDIS_URL, etc.)${NC}"
    echo -e "${DIM}• Feature flags (ENABLE_FEATURE_X=true)${NC}"
    echo -e "${DIM}• External services (SLACK_WEBHOOK_URL, etc.)${NC}"
    echo ""
    
    read -p "$(echo -e ${BOLD})Variable name: $(echo -e ${NC})" VAR_NAME
    
    if [ -z "$VAR_NAME" ]; then
        echo -e "${RED}❌ Variable name cannot be empty${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    # Check if it's a sensitive variable
    if [[ "$VAR_NAME" =~ (SECRET|TOKEN|PASSWORD|KEY|API) ]]; then
        read_secret "$(echo -e ${BOLD})Variable value (hidden): $(echo -e ${NC})" VAR_VALUE
    else
        read -p "$(echo -e ${BOLD})Variable value: $(echo -e ${NC})" VAR_VALUE
    fi
    
    if [ -z "$VAR_VALUE" ]; then
        echo -e "${RED}❌ Variable value cannot be empty${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    # Check if variable exists
    if grep -q "^$VAR_NAME=" "$ENV_FILE" 2>/dev/null; then
        # Show current value (masked if sensitive)
        current_value=$(grep "^$VAR_NAME=" "$ENV_FILE" | cut -d'=' -f2-)
        if [[ "$VAR_NAME" =~ (SECRET|TOKEN|PASSWORD|KEY|API) ]]; then
            masked="${current_value:0:4}****"
            echo -e "${YELLOW}Current value: $masked${NC}"
        else
            echo -e "${YELLOW}Current value: $current_value${NC}"
        fi
        
        read -p "Update this variable? (Y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            echo -e "${YELLOW}Cancelled${NC}"
            read -p "Press Enter to continue..."
            return
        fi
        
        # Update existing
        sed -i.bak "s|^$VAR_NAME=.*|$VAR_NAME=$VAR_VALUE|" "$ENV_FILE"
        rm -f "$ENV_FILE.bak"
        show_progress "Updated: $VAR_NAME"
    else
        # Add new
        echo "" >> "$ENV_FILE"
        echo "$VAR_NAME=$VAR_VALUE" >> "$ENV_FILE"
        show_progress "Added: $VAR_NAME"
    fi
    
    # Auto backup after change
    backup_env "auto-add" "silent"
    
    echo ""
    echo -e "${GREEN}✅ Variable saved and backup created${NC}"
    echo ""
    read -p "Press Enter to continue..."
}

view_env() {
    show_header
    
    if [ ! -f "$ENV_FILE" ]; then
        echo -e "${RED}❌ No .env file found${NC}"
        echo -e "${CYAN}Run setup first to create one${NC}"
        echo ""
        read -p "Press Enter to continue..."
        return
    fi
    
    echo -e "${YELLOW}${BOLD}Current Environment Variables${NC}"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Categories for organized display
    echo -e "${BOLD}Core Configuration:${NC}"
    grep -E "^(DOMAIN|SSL_EMAIL|NEXT_PUBLIC_APP_URL|APP_DOMAIN|BETTER_AUTH_TRUSTED_ORIGINS)=" "$ENV_FILE" 2>/dev/null | while IFS='=' read -r key value; do
        if [ -n "$value" ]; then
            echo -e "  ${CYAN}$key${NC} = $value"
        fi
    done || true
    
    echo ""
    echo -e "${BOLD}Database:${NC}"
    grep -E "^(INSTANT_APP_ID|NEXT_PUBLIC_INSTANT_APP_ID)=" "$ENV_FILE" 2>/dev/null | while IFS='=' read -r key value; do
        if [ -n "$value" ]; then
            echo -e "  ${CYAN}$key${NC} = $value"
        fi
    done || true
    
    # Show masked admin token
    if grep -q "^INSTANT_ADMIN_TOKEN=" "$ENV_FILE" 2>/dev/null; then
        token=$(grep "^INSTANT_ADMIN_TOKEN=" "$ENV_FILE" | cut -d'=' -f2-)
        if [ -n "$token" ]; then
            masked="${token:0:8}****${token: -4}"
            echo -e "  ${CYAN}INSTANT_ADMIN_TOKEN${NC} = $masked"
        fi
    fi
    
    echo ""
    echo -e "${BOLD}Authentication:${NC}"
    if grep -q "^BETTER_AUTH_SECRET=" "$ENV_FILE" 2>/dev/null; then
        secret=$(grep "^BETTER_AUTH_SECRET=" "$ENV_FILE" | cut -d'=' -f2-)
        if [ -n "$secret" ]; then
            echo -e "  ${CYAN}BETTER_AUTH_SECRET${NC} = ****${secret: -4}"
        fi
    fi
    
    # Show runtime configuration
    echo ""
    echo -e "${BOLD}Runtime Configuration:${NC}"
    if grep -q "^BUN_ENV=" "$ENV_FILE" 2>/dev/null; then
        bun_env=$(grep "^BUN_ENV=" "$ENV_FILE" | cut -d'=' -f2-)
        echo -e "  ${CYAN}BUN_ENV${NC} = $bun_env"
    fi
    if grep -q "^PORT=" "$ENV_FILE" 2>/dev/null; then
        port=$(grep "^PORT=" "$ENV_FILE" | cut -d'=' -f2-)
        echo -e "  ${CYAN}PORT${NC} = $port"
    fi
    
    # Check for configured services
    echo ""
    echo -e "${BOLD}Configured Services:${NC}"
    
    services_configured=0
    
    if grep -q "^RESEND_API_KEY=." "$ENV_FILE" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Email service (Resend)"
        services_configured=$((services_configured + 1))
    fi
    
    if grep -q "^GOOGLE_CLIENT_ID=." "$ENV_FILE" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Google OAuth"
        services_configured=$((services_configured + 1))
    fi
    
    if grep -q "^GITHUB_CLIENT_ID=." "$ENV_FILE" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} GitHub OAuth"
        services_configured=$((services_configured + 1))
    fi
    
    if grep -q "^NEXT_PUBLIC_GA_MEASUREMENT_ID=." "$ENV_FILE" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Google Analytics"
        services_configured=$((services_configured + 1))
    fi
    
    if [ $services_configured -eq 0 ]; then
        echo -e "  ${DIM}No optional services configured${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${DIM}Sensitive values are masked for security${NC}"
    echo ""
    read -p "Press Enter to continue..."
}

backup_env() {
    local label="${1:-manual}"
    local silent="${2:-}"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$BACKUP_DIR/env_${timestamp}_${label}.backup"
    
    if [ ! -f "$ENV_FILE" ]; then
        if [ -z "$silent" ]; then
            echo -e "${RED}❌ No .env file to backup${NC}"
            read -p "Press Enter to continue..."
        fi
        return
    fi
    
    cp "$ENV_FILE" "$backup_file"
    
    if [ -z "$silent" ]; then
        show_header
        echo -e "${YELLOW}${BOLD}Backup Created${NC}"
        echo ""
        echo -e "${GREEN}✅ Backup saved successfully!${NC}"
        echo ""
        echo -e "${CYAN}Location:${NC}"
        echo -e "  $backup_file"
        echo ""
        echo -e "${CYAN}Backup contains:${NC}"
        local var_count=$(grep -c "^[A-Z].*=" "$ENV_FILE" || echo "0")
        echo -e "  • ${BOLD}$var_count${NC} environment variables"
        echo -e "  • Created: $(date)"
        echo ""
        read -p "Press Enter to continue..."
    fi
}

restore_env() {
    show_header
    echo -e "${YELLOW}${BOLD}Restore from Backup${NC}"
    echo ""
    
    # List available backups
    local backups=($(ls -t "$BACKUP_DIR"/*.backup 2>/dev/null))
    
    if [ ${#backups[@]} -eq 0 ]; then
        echo -e "${RED}❌ No backups found${NC}"
        echo -e "${CYAN}Backups are created automatically when you:${NC}"
        echo -e "  • Complete setup"
        echo -e "  • Add/update variables"
        echo -e "  • Manually create backups${NC}"
        echo ""
        read -p "Press Enter to continue..."
        return
    fi
    
    echo -e "${CYAN}Select a backup to restore:${NC}"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    for i in "${!backups[@]}"; do
        local filename=$(basename "${backups[$i]}")
        local filedate=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "${backups[$i]}" 2>/dev/null || stat -c "%y" "${backups[$i]}" 2>/dev/null | cut -d' ' -f1,2)
        local filesize=$(wc -l < "${backups[$i]}" | tr -d ' ')
        
        # Parse the label from filename
        local label=$(echo "$filename" | sed 's/env_[0-9]*_//; s/.backup//')
        
        # Format label nicely
        case "$label" in
            auto-setup) label="${GREEN}Setup${NC}" ;;
            auto-add) label="${YELLOW}Variable Added${NC}" ;;
            manual) label="${CYAN}Manual Backup${NC}" ;;
            pre-restore) label="${DIM}Pre-restore${NC}" ;;
            *) label="${CYAN}$label${NC}" ;;
        esac
        
        printf "  ${BOLD}%2d)${NC} %-20s ${DIM}│${NC} %s ${DIM}│${NC} %s lines\n" $((i+1)) "$label" "$filedate" "$filesize"
    done
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${BOLD}0)${NC} Cancel"
    echo ""
    
    read -p "$(echo -e ${BOLD})Select backup (number): $(echo -e ${NC})" choice
    
    if [ "$choice" = "0" ]; then
        echo -e "${YELLOW}Cancelled${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#backups[@]}" ]; then
        local selected="${backups[$((choice-1))]}"
        
        echo ""
        echo -e "${YELLOW}⚠️  This will replace your current .env file${NC}"
        read -p "Continue? (y/N): " -n 1 -r
        echo ""
        
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Cancelled${NC}"
            read -p "Press Enter to continue..."
            return
        fi
        
        # Backup current before restoring
        if [ -f "$ENV_FILE" ]; then
            backup_env "pre-restore" "silent"
        fi
        
        cp "$selected" "$ENV_FILE"
        echo ""
        show_progress "Environment restored from backup"
        echo -e "${GREEN}✅ Restore complete!${NC}"
        echo ""
        read -p "Press Enter to continue..."
    else
        echo -e "${RED}❌ Invalid selection${NC}"
        read -p "Press Enter to continue..."
    fi
}

list_backups() {
    show_header
    echo -e "${YELLOW}${BOLD}Available Backups${NC}"
    echo -e "${CYAN}Location: ~/.basecase-env-backups/${NC}"
    echo ""
    
    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR"/*.backup 2>/dev/null)" ]; then
        echo -e "${RED}No backups found${NC}"
        echo ""
        echo -e "${CYAN}Backups are created automatically when you:${NC}"
        echo -e "  • Complete setup"
        echo -e "  • Add/update variables"
        echo -e "  • Manually create backups"
        echo ""
        read -p "Press Enter to continue..."
        return
    fi
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    printf "${BOLD}%-30s %-20s %10s${NC}\n" "Backup Name" "Date Created" "Size"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    local total_size=0
    local count=0
    
    for backup in $(ls -t "$BACKUP_DIR"/*.backup 2>/dev/null | head -20); do
        local filename=$(basename "$backup")
        local filedate=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$backup" 2>/dev/null || stat -c "%y" "$backup" 2>/dev/null | cut -d' ' -f1,2)
        local filesize=$(du -h "$backup" | cut -f1)
        
        # Parse and format the label
        local shortname=$(echo "$filename" | sed 's/env_[0-9]*_//; s/.backup//')
        
        # Color code by type
        case "$shortname" in
            auto-setup) shortname="${GREEN}[Setup]${NC}" ;;
            auto-add) shortname="${YELLOW}[Added]${NC}" ;;
            manual) shortname="${CYAN}[Manual]${NC}" ;;
            pre-restore) shortname="${DIM}[Pre-restore]${NC}" ;;
        esac
        
        printf "%-40s %-20s %10s\n" "$shortname" "$filedate" "$filesize"
        count=$((count + 1))
    done
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Total: $count backups${NC}"
    echo ""
    
    # Cleanup suggestion if too many backups
    if [ $count -gt 50 ]; then
        echo -e "${YELLOW}💡 Tip: You have many backups. Consider cleaning old ones:${NC}"
        echo -e "${DIM}   rm $BACKUP_DIR/env_*.backup${NC}"
        echo ""
    fi
    
    read -p "Press Enter to continue..."
}

# Quick mode for setup command
if [ "$1" = "setup" ]; then
    setup_env
    exit 0
fi

# Main interactive loop
while true; do
    show_menu
    read -p "$(echo -e ${BOLD})Select option: $(echo -e ${NC})" choice
    
    case $choice in
        1) setup_env ;;
        2) add_variable ;;
        3) paste_env ;;
        4) view_env ;;
        5) backup_env "manual" ;;
        6) restore_env ;;
        7) list_backups ;;
        8) 
            echo ""
            echo -e "${GREEN}Thanks for using Basecase Environment Manager!${NC}"
            echo ""
            exit 0 
            ;;
        *) 
            echo -e "${RED}Invalid option. Please select 1-8${NC}"
            sleep 1
            ;;
    esac
done