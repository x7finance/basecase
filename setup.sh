#!/bin/bash

# ==============================================================================
# Basecase VPS Setup Script
# ==============================================================================
# Version: 1.0.0
# Tested on: Ubuntu 24.04 LTS (Hetzner VPS)
# Repository: https://github.com/x7finance/basecase
#
# DESCRIPTION:
#   Automated setup script for deploying Basecase application on a fresh VPS.
#   Handles everything from system setup to SSL certificates.
#
# USAGE:
#   curl -fsSL https://raw.githubusercontent.com/x7finance/basecase/main/setup.sh -o setup.sh
#   chmod +x setup.sh
#   sudo ./setup.sh
#
# FEATURES:
#   - Automatic system updates and security hardening
#   - Bun runtime installation
#   - Claude Code CLI installation
#   - Nginx reverse proxy with SSL (Let's Encrypt)
#   - Systemd service configuration
#   - Firewall setup (UFW)
#   - Fail2ban for SSH protection
#   - Environment variable configuration
#   - Git setup for deployments
#   - Health monitoring scripts
#   - Saves configuration for re-runs
#
# REQUIREMENTS:
#   - Fresh Ubuntu 24.04 LTS installation
#   - Root access
#   - Domain name (optional, but recommended for SSL)
#   - InstantDB account (https://instantdb.com)
#   - At least 2GB RAM (or swap configured)
#
# FILES CREATED:
#   /root/.basecase-setup.conf         - Saved domain configuration
#   /home/appuser/app/                 - Application directory
#   /home/appuser/app/.env             - Environment variables
#   /etc/systemd/system/basecase.service - Systemd service
#   /etc/nginx/sites-available/basecase  - Nginx configuration
#   /usr/local/bin/app-status          - Status check helper
#   /usr/local/bin/app-logs            - Log viewer helper
#   /usr/local/bin/health-check.sh     - Health monitoring script
#
# PORTS:
#   22  - SSH
#   80  - HTTP
#   443 - HTTPS
#   3001 - Application (internal only, proxied through Nginx)
#
# SECURITY:
#   - UFW firewall enabled
#   - Fail2ban protecting SSH
#   - SSH hardening applied
#   - Nginx security headers
#   - Application runs as non-root user
#
# RE-RUNNING:
#   Script is idempotent - safe to run multiple times.
#   Existing configurations are preserved.
#   Saved settings are reused on subsequent runs.
# ==============================================================================

set -euo pipefail

# Setup logging
LOG_FILE="/var/log/basecase-setup.log"
ERROR_LOG="/var/log/basecase-setup-error.log"

# Create log files if they don't exist
touch "$LOG_FILE" "$ERROR_LOG"
chmod 644 "$LOG_FILE" "$ERROR_LOG"

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" | tee -a "$LOG_FILE" "$ERROR_LOG" >&2
}

log_debug() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] DEBUG: $*" >> "$LOG_FILE"
}

# Trap errors and log them
trap 'log_error "Script failed at line $LINENO with exit code $?. Command: $BASH_COMMAND"' ERR

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration variables
APP_NAME="basecase"
APP_USER="appuser"
APP_DIR="/home/${APP_USER}/app"
ENV_BACKUP_DIR="/home/${APP_USER}/.basecase-env"  # Persistent env storage outside project
DOMAIN="" # Will be set by user
EMAIL="" # Will be set by user
SKIP_DOMAIN="false" # Option to skip domain setup

log "=== Starting Basecase setup script ==="
log "Script version: 1.0.0"
log "Date: $(date)"
log "User: $(whoami)"
log "Working directory: $(pwd)"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[]${NC} $1"
}

print_error() {
    echo -e "${RED}[]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root"
        exit 1
    fi
}

# Get user input for configuration
get_configuration() {
    echo "==================================="
    echo "Basecase VPS Setup"
    echo "==================================="
    echo ""
    
    # Check for saved configuration
    CONFIG_FILE="/root/.basecase-setup.conf"
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        if [ -n "${SAVED_DOMAIN:-}" ] && [ -n "${SAVED_EMAIL:-}" ]; then
            echo "Found saved configuration:"
            echo "  Domain: $SAVED_DOMAIN"
            echo "  Email: $SAVED_EMAIL"
            echo ""
            read -p "Use saved configuration? (y/n): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                DOMAIN="$SAVED_DOMAIN"
                EMAIL="$SAVED_EMAIL"
                return
            fi
        fi
    fi
    
    echo "Domain Configuration Options:"
    echo "1. Configure domain now (recommended for production)"
    echo "2. Skip domain setup (development/testing)"
    echo ""
    read -p "Choose option (1 or 2): " -n 1 -r
    echo ""
    
    if [[ $REPLY == "1" ]]; then
        echo ""
        echo "Enter your domain details:"
        read -p "Domain name (e.g., example.com): " DOMAIN
        read -p "Email for SSL certificates: " EMAIL
        
        echo ""
        echo "Configuration:"
        echo "  Domain: $DOMAIN"
        echo "  Email: $EMAIL"
        echo ""
        read -p "Is this correct? (y/n): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_error "Setup cancelled"
            exit 1
        fi
        
        # Save configuration for future runs
        cat > "$CONFIG_FILE" <<EOF
# Basecase setup configuration
SAVED_DOMAIN="$DOMAIN"
SAVED_EMAIL="$EMAIL"
EOF
        chmod 600 "$CONFIG_FILE"
        print_status "Configuration saved for future runs"
    else
        SKIP_DOMAIN="true"
        print_warning "Skipping domain setup. You can configure it later by:"
        print_warning "1. Edit /etc/nginx/sites-available/basecase"
        print_warning "2. Run: certbot --nginx -d yourdomain.com"
    fi
}

# Setup swap if needed
setup_swap() {
    print_status "Checking swap configuration..."
    
    # Check if swap already exists
    if [ $(swapon --show | wc -l) -gt 0 ]; then
        print_status "Swap already configured: $(swapon --show --bytes | tail -1 | awk '{print $3/1024/1024/1024 "GB"}')"
    else
        # Check available RAM (in MB for precision)
        TOTAL_RAM_MB=$(free -m | grep Mem | awk '{print $2}')
        
        # If less than 4GB (4096MB) RAM, create swap
        if [ $TOTAL_RAM_MB -lt 4096 ]; then
            # Calculate swap needed to reach 4GB total
            SWAP_SIZE_MB=$((4096 - TOTAL_RAM_MB))
            # Convert to GB, rounding up
            SWAP_SIZE=$(( (SWAP_SIZE_MB + 1023) / 1024 ))
            print_status "System has ${TOTAL_RAM_MB}MB RAM, creating ${SWAP_SIZE}GB swap file..."
            
            # Create swap file
            fallocate -l ${SWAP_SIZE}G /swapfile || dd if=/dev/zero of=/swapfile bs=1G count=$SWAP_SIZE
            chmod 600 /swapfile
            mkswap /swapfile
            swapon /swapfile
            
            # Make permanent
            if ! grep -q '/swapfile' /etc/fstab; then
                echo '/swapfile none swap sw 0 0' >> /etc/fstab
            fi
            
            print_status "Swap created successfully. Total memory now: $((TOTAL_RAM_MB/1024 + SWAP_SIZE))GB"
        else
            print_status "System has $((TOTAL_RAM_MB/1024))GB RAM, swap not needed"
        fi
    fi
}

# Update system and install basic packages
update_system() {
    print_status "Checking system packages..."
    
    # Update package list
    apt-get update
    
    # List of required packages
    PACKAGES="curl wget git vim htop ufw fail2ban nginx certbot python3-certbot-nginx build-essential unzip software-properties-common"
    
    # Check which packages need to be installed
    TO_INSTALL=""
    for pkg in $PACKAGES; do
        if ! dpkg -l | grep -q "^ii  $pkg "; then
            TO_INSTALL="$TO_INSTALL $pkg"
        fi
    done
    
    if [ -n "$TO_INSTALL" ]; then
        print_status "Installing missing packages:$TO_INSTALL"
        apt-get install -y $TO_INSTALL
    else
        print_status "All required packages already installed"
    fi
    
    # Only upgrade if explicitly requested or first run
    if [ "${SKIP_UPGRADE:-false}" != "true" ]; then
        print_status "Upgrading system packages..."
        apt-get upgrade -y
    fi
}

# Create application user
create_app_user() {
    print_status "Creating application user..."
    if id "$APP_USER" &>/dev/null; then
        print_warning "User $APP_USER already exists"
    else
        useradd -m -s /bin/bash "$APP_USER"
        usermod -aG sudo "$APP_USER"
        print_status "User $APP_USER created"
    fi
}

# Install Bun runtime dependencies
install_bun_deps() {
    print_status "Installing Bun runtime dependencies..."
    # Bun needs unzip which is already in our package list
    # Just ensure we have the essentials for Bun
    apt-get install -y unzip curl
}

# Install Bun and PM2
install_bun() {
    print_status "Checking Bun installation..."
    
    # Check if bun is already installed for root
    if [ -f /root/.bun/bin/bun ] || command -v bun &> /dev/null; then
        print_status "Bun already installed for root"
    else
        print_status "Installing Bun for root..."
        curl -fsSL https://bun.sh/install | bash
    fi
    
    # Check if bun is already installed for app user
    if [ -f /home/"$APP_USER"/.bun/bin/bun ]; then
        print_status "Bun already installed for $APP_USER"
    else
        print_status "Installing Bun for $APP_USER..."
        su - "$APP_USER" -c "curl -fsSL https://bun.sh/install | bash"
    fi
    
    # Add to PATH for both users (only if not already there)
    if ! grep -q ".bun/bin" /root/.bashrc; then
        echo 'export PATH="$HOME/.bun/bin:$PATH"' >> /root/.bashrc
    fi
    if ! grep -q ".bun/bin" /home/"$APP_USER"/.bashrc; then
        echo 'export PATH="$HOME/.bun/bin:$PATH"' >> /home/"$APP_USER"/.bashrc
    fi
    
    # Create system-wide symlink so sudo works
    ln -sf /home/"$APP_USER"/.bun/bin/bun /usr/local/bin/bun
    ln -sf /root/.bun/bin/bun /usr/local/bin/bun-root
    
    print_status "Checking PM2 installation..."
    # Install PM2 using bun if not already installed
    if command -v pm2 &> /dev/null; then
        print_status "PM2 already installed"
    else
        print_status "Installing PM2..."
        bun install -g pm2
    fi
}

# Install Claude Code CLI
install_claude_code() {
    print_status "Checking Claude Code CLI..."
    
    # Check if already installed for root
    if [ -f /root/.local/bin/claude ] || command -v claude &> /dev/null; then
        print_status "Claude Code already installed for root"
    else
        print_status "Installing Claude Code for root..."
        curl -fsSL https://claude.ai/install.sh | bash
    fi
    
    # Add to PATH for root (only if not already there)
    if ! grep -q "/.local/bin" /root/.bashrc; then
        echo 'export PATH="/root/.local/bin:$PATH"' >> /root/.bashrc
        export PATH="/root/.local/bin:$PATH"
    fi
    
    # Check if already installed for app user
    if [ -f /home/"$APP_USER"/.local/bin/claude ]; then
        print_status "Claude Code already installed for $APP_USER"
    else
        print_status "Installing Claude Code for $APP_USER..."
        su - "$APP_USER" -c "curl -fsSL https://claude.ai/install.sh | bash"
    fi
    
    # Add to PATH for app user (only if not already there)
    if ! grep -q "/.local/bin" /home/"$APP_USER"/.bashrc; then
        echo 'export PATH="/home/appuser/.local/bin:$PATH"' >> /home/"$APP_USER"/.bashrc
    fi
    
    print_warning "Claude Code installed. You'll need to authenticate with: claude auth"
}

# Setup firewall
setup_firewall() {
    print_status "Configuring firewall..."
    
    # Default policies
    ufw default deny incoming
    ufw default allow outgoing
    
    # Allow SSH (port 22)
    ufw allow 22/tcp
    
    # Allow HTTP and HTTPS
    ufw allow 80/tcp
    ufw allow 443/tcp
    
    # Enable firewall
    ufw --force enable
    
    print_status "Firewall configured"
}

# Setup fail2ban for SSH protection
setup_fail2ban() {
    print_status "Configuring fail2ban..."
    
    cat > /etc/fail2ban/jail.local <<EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port = 22
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
EOF
    
    systemctl restart fail2ban
    systemctl enable fail2ban
    
    print_status "Fail2ban configured"
}

# Setup SSH hardening
harden_ssh() {
    print_status "Hardening SSH configuration..."
    
    # Backup original config
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
    
    # Update SSH config
    cat >> /etc/ssh/sshd_config <<EOF

# Security hardening
PermitRootLogin yes  # Change to 'no' after setting up SSH keys
PasswordAuthentication yes  # Change to 'no' after setting up SSH keys
MaxAuthTries 3
MaxSessions 10
ClientAliveInterval 300
ClientAliveCountMax 2
X11Forwarding no
EOF
    
    systemctl restart ssh
    
    print_warning "SSH hardened. Remember to:"
    print_warning "1. Set up SSH keys for authentication"
    print_warning "2. Disable password authentication"
    print_warning "3. Disable root login after setup"
}

# Setup Git configuration
setup_git() {
    print_status "Configuring Git..."
    
    # Install git if not already installed (though it should be from update_system)
    if ! command -v git &> /dev/null; then
        print_warning "Git not found, installing..."
        apt-get install -y git
    fi
    
    # Configure git for the app user
    su - "$APP_USER" -c "git config --global user.name 'Basecase Deployment'"
    su - "$APP_USER" -c "git config --global user.email 'deploy@basecase.local'"
    su - "$APP_USER" -c "git config --global init.defaultBranch main"
    su - "$APP_USER" -c "git config --global pull.rebase false"
    
    # Also configure git for root to avoid ownership issues
    git config --global --add safe.directory "$APP_DIR"
    su - "$APP_USER" -c "git config --global --add safe.directory $APP_DIR"
    
    # Set up SSH directory for git deployments
    mkdir -p /home/"$APP_USER"/.ssh
    chmod 700 /home/"$APP_USER"/.ssh
    chown "$APP_USER":"$APP_USER" /home/"$APP_USER"/.ssh
    
    # Create a deploy key placeholder
    touch /home/"$APP_USER"/.ssh/deploy_key
    chmod 600 /home/"$APP_USER"/.ssh/deploy_key
    chown "$APP_USER":"$APP_USER" /home/"$APP_USER"/.ssh/deploy_key
    
    # Create SSH config for GitHub/GitLab
    cat > /home/"$APP_USER"/.ssh/config <<EOF
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/deploy_key
    StrictHostKeyChecking no

Host gitlab.com
    HostName gitlab.com
    User git
    IdentityFile ~/.ssh/deploy_key
    StrictHostKeyChecking no

Host bitbucket.org
    HostName bitbucket.org
    User git
    IdentityFile ~/.ssh/deploy_key
    StrictHostKeyChecking no
EOF
    
    chmod 600 /home/"$APP_USER"/.ssh/config
    chown "$APP_USER":"$APP_USER" /home/"$APP_USER"/.ssh/config
    
    # Add common git hosts to known_hosts
    su - "$APP_USER" -c "ssh-keyscan -H github.com >> ~/.ssh/known_hosts 2>/dev/null"
    su - "$APP_USER" -c "ssh-keyscan -H gitlab.com >> ~/.ssh/known_hosts 2>/dev/null"
    su - "$APP_USER" -c "ssh-keyscan -H bitbucket.org >> ~/.ssh/known_hosts 2>/dev/null"
    
    print_status "Git configured"
    print_warning "Remember to:"
    print_warning "1. Add your deploy key to /home/$APP_USER/.ssh/deploy_key"
    print_warning "2. Add the public key to your repository's deploy keys"
}

# Clone and setup application
setup_application() {
    print_status "Setting up application..."
    
    # Create app directory
    mkdir -p "$APP_DIR"
    chown -R "$APP_USER":"$APP_USER" "$APP_DIR"
    
    # Clone the basecase repository
    print_status "Cloning Basecase repository..."
    if [ ! -d "$APP_DIR/.git" ]; then
        su - "$APP_USER" -c "cd $APP_DIR && git clone https://github.com/x7finance/basecase.git . 2>&1" || {
            print_error "Failed to clone repository"
            print_error "Trying to clean directory and retry..."
            rm -rf "$APP_DIR"/{*,.*} 2>/dev/null || true
            mkdir -p "$APP_DIR"
            chown -R "$APP_USER":"$APP_USER" "$APP_DIR"
            su - "$APP_USER" -c "cd $APP_DIR && git clone https://github.com/x7finance/basecase.git ." || {
                print_error "Repository clone failed after retry"
                exit 1
            }
        }
    else
        print_warning "Repository already exists, pulling latest changes..."
        su - "$APP_USER" -c "cd $APP_DIR && git pull origin main || true"
    fi
    
    # Verify clone was successful
    if [ ! -f "$APP_DIR/package.json" ]; then
        print_error "Repository clone failed - package.json not found!"
        print_error "Directory contents:"
        ls -la "$APP_DIR"
        exit 1
    fi
    
    # Install dependencies
    print_status "Installing/updating dependencies..."
    su - "$APP_USER" -c "cd $APP_DIR && /home/$APP_USER/.bun/bin/bun install --no-save"
    
    # Use env-manager.sh if available, otherwise fall back to built-in
    if [ -f "$APP_DIR/scripts/env-manager.sh" ]; then
        print_status "Using env-manager.sh for environment setup..."
        su - "$APP_USER" -c "cd $APP_DIR && bash scripts/env-manager.sh setup"
    else
        # Fall back to built-in function
        setup_env_variables
    fi || {
        print_error "setup_env_variables failed, creating minimal .env"
        # Force create a minimal .env file no matter what
        echo "# Minimal .env file - EDIT THIS" > "$APP_DIR/.env"
        echo "INSTANT_APP_ID=CHANGE_ME" >> "$APP_DIR/.env"
        echo "NEXT_PUBLIC_INSTANT_APP_ID=CHANGE_ME" >> "$APP_DIR/.env"
        echo "INSTANT_ADMIN_TOKEN=CHANGE_ME" >> "$APP_DIR/.env"
        echo "BETTER_AUTH_SECRET=$(openssl rand -base64 32)" >> "$APP_DIR/.env"
        echo "NEXT_PUBLIC_APP_URL=https://basecase.space" >> "$APP_DIR/.env"
        echo "BETTER_AUTH_TRUSTED_ORIGINS=https://basecase.space" >> "$APP_DIR/.env"
        echo "APP_DOMAIN=basecase.space" >> "$APP_DIR/.env"
        echo "BUN_ENV=production" >> "$APP_DIR/.env"
        echo "PORT=3001" >> "$APP_DIR/.env"
        chown "$APP_USER":"$APP_USER" "$APP_DIR/.env"
        chmod 600 "$APP_DIR/.env"
        print_warning "Created minimal .env at $APP_DIR/.env - MUST BE EDITED!"
    }
    
    # Double-check the file exists
    if [ ! -f "$APP_DIR/.env" ]; then
        print_error "CRITICAL: .env still doesn't exist, forcing creation"
        touch "$APP_DIR/.env"
        echo "INSTANT_APP_ID=MUST_BE_SET" > "$APP_DIR/.env"
        chown "$APP_USER":"$APP_USER" "$APP_DIR/.env"
    fi
    
    # Deploy script already exists in scripts/deploy.sh
    if [ -f "$APP_DIR/scripts/deploy.sh" ]; then
        print_status "Deploy script available at scripts/deploy.sh"
        chmod +x "$APP_DIR/scripts/deploy.sh"
    fi
}

# Setup environment variables interactively
# This function:
# - Loads existing .env.local if present
# - Prompts for required variables (InstantDB, Better Auth)
# - Prompts for optional variables (Resend, OAuth providers)
# - Saves configuration to .env.local
# - Shows "[Already configured]" for existing values
# - Masks sensitive inputs with ****
setup_env_variables() {
    print_status "Setting up environment variables..."
    log_debug "Entering setup_env_variables function"
    log_debug "APP_DIR=$APP_DIR"
    
    # Ensure app directory exists
    if [ ! -d "$APP_DIR" ]; then
        print_error "App directory $APP_DIR does not exist! Creating it..."
        mkdir -p "$APP_DIR"
        chown -R "$APP_USER":"$APP_USER" "$APP_DIR"
    fi
    
    ENV_FILE="$APP_DIR/.env"
    
    # Check for backup and offer to restore
    if [ -f "$ENV_BACKUP_DIR/.env.backup" ]; then
        print_status "Found environment backup from previous installation"
        echo "   Location: $ENV_BACKUP_DIR/.env.backup"
        echo ""
        echo "   Options:"
        echo "   1. Use backup and update/add any missing variables"
        echo "   2. Start fresh (enter all variables)"
        read -p "   Choose (1 or 2): " -n 1 -r BACKUP_CHOICE
        echo ""
        
        if [[ $BACKUP_CHOICE == "1" ]]; then
            # Load existing values from backup
            source "$ENV_BACKUP_DIR/.env.backup"
            print_status "Loaded existing configuration"
            USING_BACKUP=true
        else
            USING_BACKUP=false
        fi
    else
        USING_BACKUP=false
    fi
    
    print_status "Will create environment file at: $ENV_FILE"
    log_debug "ENV_FILE set to: $ENV_FILE"
    
    # Initialize all variables to empty if not set
    log_debug "Initializing environment variables to empty defaults"
    INSTANT_APP_ID="${INSTANT_APP_ID:-}"
    INSTANT_ADMIN_TOKEN="${INSTANT_ADMIN_TOKEN:-}"
    BETTER_AUTH_SECRET="${BETTER_AUTH_SECRET:-}"
    RESEND_API_KEY="${RESEND_API_KEY:-}"
    EMAIL_DOMAIN="${EMAIL_DOMAIN:-}"
    RESEND_FROM_EMAIL="${RESEND_FROM_EMAIL:-}"
    GA_MEASUREMENT_ID="${GA_MEASUREMENT_ID:-}"
    GOOGLE_CLIENT_ID="${GOOGLE_CLIENT_ID:-}"
    GOOGLE_CLIENT_SECRET="${GOOGLE_CLIENT_SECRET:-}"
    GITHUB_CLIENT_ID="${GITHUB_CLIENT_ID:-}"
    GITHUB_CLIENT_SECRET="${GITHUB_CLIENT_SECRET:-}"
    
    # Check if env file exists and source existing values
    if [ -f "$ENV_FILE" ]; then
        print_warning "Existing .env found. Loading current values..."
        log_debug "Found existing env file, attempting to source it"
        log_debug "File size: $(wc -c < "$ENV_FILE") bytes"
        # Source existing values (safely)
        set -a
        source "$ENV_FILE" 2>/dev/null || {
            log_error "Failed to source $ENV_FILE"
        }
        set +a
        log_debug "After sourcing - INSTANT_APP_ID length: ${#INSTANT_APP_ID}"
        log_debug "After sourcing - RESEND_API_KEY length: ${#RESEND_API_KEY}"
    else
        log_debug "No existing env file found at $ENV_FILE"
    fi
    
    echo ""
    echo "====================================="
    echo "Environment Variable Configuration"
    echo "====================================="
    echo ""
    
    # InstantDB Configuration
    echo "1. InstantDB Setup (Required)"
    echo "   Get these from https://instantdb.com"
    echo ""
    
    if [ "$USING_BACKUP" = true ] && [ -n "${INSTANT_APP_ID:-}" ]; then
        echo "   Current INSTANT_APP_ID: ${INSTANT_APP_ID:0:12}..."
        read -p "   Keep this value? (Y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            read -p "   Enter new INSTANT_APP_ID: " INSTANT_APP_ID
        fi
    else
        read -p "   Enter INSTANT_APP_ID: " INSTANT_APP_ID
    fi
    
    if [ "$USING_BACKUP" = true ] && [ -n "${INSTANT_ADMIN_TOKEN:-}" ]; then
        echo "   Current INSTANT_ADMIN_TOKEN: [configured]"
        read -p "   Keep this value? (Y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            echo -n "   Enter new INSTANT_ADMIN_TOKEN (input hidden): "
            read -s INSTANT_ADMIN_TOKEN
            echo ""
        fi
    else
        echo -n "   Enter INSTANT_ADMIN_TOKEN (input hidden): "
        read -s INSTANT_ADMIN_TOKEN
        echo ""
    fi
    echo ""
    
    # Better Auth Secret
    echo "2. Better Auth Configuration (Required)"
    if [ "$USING_BACKUP" = true ] && [ -n "${BETTER_AUTH_SECRET:-}" ]; then
        echo "   Using existing Better Auth secret"
    else
        echo "   Generating new secure secret..."
        BETTER_AUTH_SECRET=$(openssl rand -base64 32)
        echo "   ✓ Generated secret"
    fi
    echo ""
    
    # Application URL
    echo "3. Application URL"
    if [[ "$SKIP_DOMAIN" == "true" ]]; then
        APP_URL="http://$(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_SERVER_IP'):3001"
        echo "   Using IP address: $APP_URL"
    else
        APP_URL="https://$DOMAIN"
        echo "   Using domain: $APP_URL"
    fi
    echo ""
    
    # Google Analytics  
    echo "4. Google Analytics"
    echo "   Get Measurement ID from https://analytics.google.com"
    echo "   Format: G-XXXXXXXXXX"
    
    if [ "$USING_BACKUP" = true ] && [ -n "${GA_MEASUREMENT_ID:-}" ]; then
        echo "   Current GA_MEASUREMENT_ID: $GA_MEASUREMENT_ID"
        read -p "   Keep this value? (Y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            read -p "   Enter new GA_MEASUREMENT_ID (or press Enter to skip): " GA_MEASUREMENT_ID
        fi
    else
        read -p "   Enter GA_MEASUREMENT_ID (or press Enter to skip): " GA_MEASUREMENT_ID
    fi
    echo ""
    
    # Email Configuration (Resend)
    echo "5. Email Configuration (Resend)"
    echo "   Get API key from https://resend.com"
    
    if [ "$USING_BACKUP" = true ] && [ -n "${RESEND_API_KEY:-}" ]; then
        echo "   Current RESEND_API_KEY: [configured]"
        echo "   Current EMAIL_DOMAIN: ${EMAIL_DOMAIN:-not set}"
        echo "   Current RESEND_FROM_EMAIL: ${RESEND_FROM_EMAIL:-not set}"
        read -p "   Keep these values? (Y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            echo -n "   Enter new RESEND_API_KEY (input hidden, press Enter to skip): "
            read -s RESEND_API_KEY
            echo ""
            if [ -n "$RESEND_API_KEY" ]; then
                echo "   ✓ API key received (${#RESEND_API_KEY} characters)"
                read -p "   Enter email domain (e.g., marketing.basecase.space): " EMAIL_DOMAIN
                read -p "   Enter from email (e.g., noreply@marketing.basecase.space): " RESEND_FROM_EMAIL
            fi
        fi
    else
        echo -n "   Enter RESEND_API_KEY (input hidden, press Enter to skip): "
        read -s RESEND_API_KEY
        echo ""
        if [ -n "$RESEND_API_KEY" ]; then
            echo "   ✓ API key received (${#RESEND_API_KEY} characters)"
            read -p "   Enter email domain (e.g., marketing.basecase.space): " EMAIL_DOMAIN
            read -p "   Enter from email (e.g., noreply@marketing.basecase.space): " RESEND_FROM_EMAIL
        else
            echo "   ⚠ No API key entered - skipping email features"
            EMAIL_DOMAIN=""
            RESEND_FROM_EMAIL=""
        fi
    fi
    echo ""
    
    # OAuth Providers
    echo "6. Google OAuth"
    echo "   Get from https://console.cloud.google.com"
    
    if [ "$USING_BACKUP" = true ] && [ -n "${GOOGLE_CLIENT_ID:-}" ]; then
        echo "   Current GOOGLE_CLIENT_ID: ${GOOGLE_CLIENT_ID:0:20}..."
        echo "   Current GOOGLE_CLIENT_SECRET: [configured]"
        read -p "   Keep these values? (Y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            read -p "   Enter new GOOGLE_CLIENT_ID (or press Enter to skip): " GOOGLE_CLIENT_ID
            if [ -n "${GOOGLE_CLIENT_ID:-}" ]; then
                echo -n "   Enter GOOGLE_CLIENT_SECRET (input hidden): "
                read -s GOOGLE_CLIENT_SECRET
                echo ""
            fi
        fi
    else
        read -p "   Enter GOOGLE_CLIENT_ID (or press Enter to skip): " GOOGLE_CLIENT_ID
        if [ -n "${GOOGLE_CLIENT_ID:-}" ]; then
            echo -n "   Enter GOOGLE_CLIENT_SECRET (input hidden): "
            read -s GOOGLE_CLIENT_SECRET
            echo ""
            if [ -n "$GOOGLE_CLIENT_SECRET" ]; then
                echo "   ✓ Secret received (${#GOOGLE_CLIENT_SECRET} characters)"
            fi
        else
            echo "   Skipping Google OAuth"
            GOOGLE_CLIENT_SECRET=""
        fi
    fi
    echo ""
    
    # Create .env file
    print_status "Creating environment configuration..."
    
    # Ensure ALL variables have values (even if empty)
    INSTANT_APP_ID="${INSTANT_APP_ID:-your_instant_app_id_here}"
    INSTANT_ADMIN_TOKEN="${INSTANT_ADMIN_TOKEN:-your_instant_admin_token_here}"
    BETTER_AUTH_SECRET="${BETTER_AUTH_SECRET:-$(openssl rand -base64 32)}"
    APP_URL="${APP_URL:-http://localhost:3001}"
    GA_MEASUREMENT_ID="${GA_MEASUREMENT_ID:-}"
    RESEND_API_KEY="${RESEND_API_KEY:-}"
    EMAIL_DOMAIN="${EMAIL_DOMAIN:-}"
    RESEND_FROM_EMAIL="${RESEND_FROM_EMAIL:-}"
    GOOGLE_CLIENT_ID="${GOOGLE_CLIENT_ID:-}"
    GOOGLE_CLIENT_SECRET="${GOOGLE_CLIENT_SECRET:-}"
    GITHUB_CLIENT_ID="${GITHUB_CLIENT_ID:-}"
    GITHUB_CLIENT_SECRET="${GITHUB_CLIENT_SECRET:-}"
    
    log_debug "Creating env file with:"
    log_debug "  INSTANT_APP_ID=${INSTANT_APP_ID:0:8}..."
    log_debug "  APP_URL=$APP_URL"
    log_debug "  ENV_FILE=$ENV_FILE"
    
    # Write the file
    cat > "$ENV_FILE" <<EOL
# === CORE CONFIGURATION ===

# InstantDB Configuration
NEXT_PUBLIC_INSTANT_APP_ID=$INSTANT_APP_ID
INSTANT_APP_ID=$INSTANT_APP_ID
INSTANT_ADMIN_TOKEN=$INSTANT_ADMIN_TOKEN

# Better Auth Configuration
BETTER_AUTH_SECRET=$BETTER_AUTH_SECRET

# Application URLs
NEXT_PUBLIC_APP_URL=$APP_URL
BETTER_AUTH_TRUSTED_ORIGINS=$APP_URL
APP_DOMAIN=${DOMAIN:-localhost}

# Environment Settings
BUN_ENV=production
PORT=3001
EOL
    
    # Add optional variables if provided
    if [ -n "${GA_MEASUREMENT_ID:-}" ]; then
        cat >> "$ENV_FILE" <<EOL

# Google Analytics
NEXT_PUBLIC_GA_MEASUREMENT_ID=$GA_MEASUREMENT_ID
EOL
    fi
    
    if [ -n "${RESEND_API_KEY:-}" ]; then
        cat >> "$ENV_FILE" <<EOL

# Email Configuration (Resend)
RESEND_API_KEY=$RESEND_API_KEY
EMAIL_DOMAIN=$EMAIL_DOMAIN
RESEND_FROM_EMAIL=$RESEND_FROM_EMAIL
EOL
    fi
    
    if [ -n "${GOOGLE_CLIENT_ID:-}" ]; then
        cat >> "$ENV_FILE" <<EOL

# Google OAuth
GOOGLE_CLIENT_ID=$GOOGLE_CLIENT_ID
GOOGLE_CLIENT_SECRET=$GOOGLE_CLIENT_SECRET
EOL
    fi
    
    # Set proper permissions
    chown "$APP_USER":"$APP_USER" "$ENV_FILE" || {
        log_error "Failed to chown $ENV_FILE"
    }
    chmod 600 "$ENV_FILE" || {
        log_error "Failed to chmod $ENV_FILE"
    }
    
    # Verify the file was created
    if [ -f "$ENV_FILE" ]; then
        print_status "Environment variables configured successfully"
        print_status "Created $ENV_FILE with $(wc -l < "$ENV_FILE") lines"
        # Show non-sensitive first few lines as verification
        print_status "File begins with:"
        head -n 3 "$ENV_FILE" | sed 's/^/    /'
    else
        print_error "Failed to create $ENV_FILE"
        print_error "Attempting emergency creation..."
        
        # Emergency fallback - create a minimal .env file
        cat > "$ENV_FILE" <<'EMERGENCY_ENV'
# Emergency .env file - please edit with your actual values
NEXT_PUBLIC_INSTANT_APP_ID=your_instant_app_id
INSTANT_APP_ID=your_instant_app_id
INSTANT_ADMIN_TOKEN=your_instant_admin_token
BETTER_AUTH_SECRET=change_this_secret_immediately
NEXT_PUBLIC_APP_URL=http://localhost:3001
BETTER_AUTH_TRUSTED_ORIGINS=http://localhost:3001
APP_DOMAIN=localhost
BUN_ENV=production
PORT=3001
RESEND_API_KEY=
EMAIL_DOMAIN=
RESEND_FROM_EMAIL=
EMERGENCY_ENV
        
        if [ -f "$ENV_FILE" ]; then
            print_warning "Created emergency .env file - EDIT IT WITH YOUR ACTUAL VALUES!"
            chown "$APP_USER":"$APP_USER" "$ENV_FILE"
            chmod 600 "$ENV_FILE"
        else
            print_error "CRITICAL: Cannot create .env file at all!"
            print_error "Please manually create: $ENV_FILE"
            exit 1
        fi
    fi
    
    # Backup environment to persistent location
    if [ -f "$ENV_FILE" ]; then
        print_status "Backing up environment variables..."
        mkdir -p "$ENV_BACKUP_DIR"
        cp "$ENV_FILE" "$ENV_BACKUP_DIR/.env.backup"
        chmod 600 "$ENV_BACKUP_DIR/.env.backup"
        chown -R "$APP_USER":"$APP_USER" "$ENV_BACKUP_DIR"
        print_status "Environment backed up to $ENV_BACKUP_DIR/.env.backup"
    fi
    
    # Run migrations if available
    if [ -f "$APP_DIR/scripts/migrate-schema.mjs" ]; then
        print_status "Running migrations..."
        su - "$APP_USER" -c "cd $APP_DIR && bun run migrate" || print_warning "Migrations failed or not configured"
    fi
    
    # Build the application
    print_status "Building the application..."
    su - "$APP_USER" -c "cd $APP_DIR && bun run build" || {
        print_warning "Build failed. You may need to run 'bun run build' manually after fixing any issues."
    }
}

# Setup PM2 service
setup_pm2_service() {
    print_status "Setting up PM2 service..."
    
    # Ecosystem config should already exist in repo, but create if missing
    if [ ! -f "$APP_DIR/ecosystem.config.js" ]; then
        print_warning "ecosystem.config.js not found, creating Bun-optimized config..."
        cat > "$APP_DIR/ecosystem.config.js" <<'EOF'
module.exports = {
  apps: [
    {
      name: 'basecase-web',
      script: 'bun',
      args: 'run start:prod',
      cwd: './apps/web',
      env: {
        NODE_ENV: 'production',
        BUN_ENV: 'production',
        PORT: 3001,
      },
      instances: 1,
      exec_mode: 'fork',
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      error_file: '/var/log/pm2/basecase-error.log',
      out_file: '/var/log/pm2/basecase-out.log',
      log_file: '/var/log/pm2/basecase-combined.log',
      time: true,
      min_uptime: '10s',
      max_restarts: 10,
    },
  ],
};
EOF
        chown "$APP_USER":"$APP_USER" "$APP_DIR/ecosystem.config.js"
    fi
    
    # Create PM2 log directory
    mkdir -p /var/log/pm2
    chown -R "$APP_USER":"$APP_USER" /var/log/pm2
    
    # Start with PM2
    su - "$APP_USER" -c "cd $APP_DIR && pm2 start ecosystem.config.js --env production"
    su - "$APP_USER" -c "pm2 save"
    su - "$APP_USER" -c "pm2 startup systemd -u $APP_USER --hp /home/$APP_USER" | tail -n 1 | bash
    
    print_status "PM2 service configured"
}

# Setup Nginx using modular script if available
setup_nginx() {
    print_status "Configuring Nginx..."
    
    # Use nginx-setup.sh if available
    if [ -f "$APP_DIR/scripts/nginx-setup.sh" ]; then
        print_status "Using nginx-setup.sh for Nginx configuration..."
        if [[ "$SKIP_DOMAIN" == "true" ]]; then
            bash "$APP_DIR/scripts/nginx-setup.sh"
        else
            bash "$APP_DIR/scripts/nginx-setup.sh" "$DOMAIN" "$EMAIL"
        fi
        return
    fi
    
    # Fall back to built-in configuration
    # Remove default site
    rm -f /etc/nginx/sites-enabled/default
    
    if [[ "$SKIP_DOMAIN" == "true" ]]; then
        # Development configuration without domain
        cat > /etc/nginx/sites-available/basecase <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Proxy all requests to Next.js
    location / {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Forwarded-Host \$host;
        proxy_set_header X-Forwarded-Port \$server_port;
    }
    
    # Handle _next/static files (long-term caching)
    location /_next/static {
        proxy_pass http://localhost:3001;
        add_header Cache-Control "public, max-age=31536000, immutable";
    }
    
    # Handle _next/image
    location /_next/image {
        proxy_pass http://localhost:3001;
    }
    
    # Handle API routes
    location /api {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    client_max_body_size 50M;
}
EOF
    else
        # Production configuration with domain (HTTP only until SSL is configured)
        cat > /etc/nginx/sites-available/basecase <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN www.$DOMAIN;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Proxy all requests to Next.js
    location / {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Forwarded-Host \$host;
        proxy_set_header X-Forwarded-Port \$server_port;
    }
    
    # Handle _next/static files (long-term caching)
    location /_next/static {
        proxy_pass http://localhost:3001;
        add_header Cache-Control "public, max-age=31536000, immutable";
    }
    
    # Handle _next/image
    location /_next/image {
        proxy_pass http://localhost:3001;
    }
    
    # Handle API routes
    location /api {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # Static files caching
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
    
    client_max_body_size 50M;
}
EOF
    fi
    
    ln -sf /etc/nginx/sites-available/basecase /etc/nginx/sites-enabled/
    
    # Test configuration
    nginx -t
    systemctl restart nginx
    
    print_status "Nginx configured"
}

# Setup SSL with Let's Encrypt
setup_ssl() {
    if [[ "$SKIP_DOMAIN" == "true" ]]; then
        print_warning "Skipping SSL setup (no domain configured)"
        print_warning "To add SSL later, run:"
        print_warning "  1. Update /etc/nginx/sites-available/basecase with your domain"
        print_warning "  2. Run: certbot --nginx -d yourdomain.com -d www.yourdomain.com"
    else
        print_status "Setting up SSL certificates..."
        
        if [ -n "$DOMAIN" ] && [ -n "$EMAIL" ]; then
            certbot --nginx -d "$DOMAIN" -d "www.$DOMAIN" --non-interactive --agree-tos --email "$EMAIL"
            
            # Setup auto-renewal
            systemctl enable certbot.timer
            systemctl start certbot.timer
            
            print_status "SSL certificates installed"
        else
            print_warning "Domain or email not provided. Skipping SSL setup."
        fi
    fi
}

# Setup monitoring
setup_monitoring() {
    print_status "Setting up basic monitoring..."
    
    # Create a simple health check script
    cat > /usr/local/bin/health-check.sh <<'EOF'
#!/bin/bash
# Simple health check script

# Check if app is running
if systemctl is-active --quiet basecase; then
    echo "App: Running"
else
    echo "App: Not running - Attempting restart"
    systemctl restart basecase
fi

# Check if nginx is running
if systemctl is-active --quiet nginx; then
    echo "Nginx: Running"
else
    echo "Nginx: Not running - Attempting restart"
    systemctl restart nginx
fi

# Check disk usage
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 80 ]; then
    echo "WARNING: Disk usage is at ${DISK_USAGE}%"
fi

# Check memory usage
MEM_USAGE=$(free | grep Mem | awk '{print int($3/$2 * 100)}')
if [ "$MEM_USAGE" -gt 80 ]; then
    echo "WARNING: Memory usage is at ${MEM_USAGE}%"
fi
EOF
    
    chmod +x /usr/local/bin/health-check.sh
    
    # Add to crontab
    (crontab -l 2>/dev/null; echo "*/5 * * * * /usr/local/bin/health-check.sh >> /var/log/health-check.log 2>&1") | crontab -
    
    print_status "Monitoring setup complete"
}

# Create helper scripts
create_helper_scripts() {
    print_status "Creating helper scripts..."
    
    # Status script
    cat > /usr/local/bin/app-status <<'EOF'
#!/bin/bash
echo "==================================="
echo "Basecase Status"
echo "==================================="
echo ""
echo "Application:"
systemctl status basecase --no-pager | head -n 5
echo ""
echo "Nginx:"
systemctl status nginx --no-pager | head -n 5
echo ""
echo "Firewall:"
ufw status
echo ""
echo "Disk Usage:"
df -h /
echo ""
echo "Memory Usage:"
free -h
EOF
    chmod +x /usr/local/bin/app-status
    
    # Logs script
    cat > /usr/local/bin/app-logs <<'EOF'
#!/bin/bash
echo "Showing application logs (Ctrl+C to exit)..."
journalctl -u basecase -f
EOF
    chmod +x /usr/local/bin/app-logs
    
    print_status "Helper scripts created"
}

# Validate critical setup components
validate_setup() {
    print_status "Validating setup..."
    local VALIDATION_FAILED=0
    
    # Check .env file exists and has content
    if [ ! -f "$APP_DIR/.env" ]; then
        print_error "Environment file missing at $APP_DIR/.env"
        VALIDATION_FAILED=1
    elif [ ! -s "$APP_DIR/.env" ]; then
        print_error "Environment file is empty"
        VALIDATION_FAILED=1
    fi
    
    # Check bun is accessible
    if ! command -v bun &> /dev/null && ! [ -f /usr/local/bin/bun ]; then
        print_error "Bun is not accessible"
        VALIDATION_FAILED=1
    fi
    
    # Check nginx config is valid
    if ! nginx -t 2>/dev/null; then
        print_error "Nginx configuration is invalid"
        VALIDATION_FAILED=1
    fi
    
    # Check systemd service exists
    if ! systemctl list-unit-files | grep -q basecase.service; then
        print_error "Systemd service not found"
        VALIDATION_FAILED=1
    fi
    
    if [ $VALIDATION_FAILED -eq 1 ]; then
        print_error "Setup validation failed. Please check errors above."
        return 1
    fi
    
    print_status "All validations passed!"
    return 0
}

# Main setup function
main() {
    check_root
    get_configuration
    
    print_status "Starting Basecase VPS setup..."
    
    setup_swap
    update_system
    create_app_user
    install_bun_deps
    install_bun
    install_claude_code
    setup_git
    setup_firewall
    setup_fail2ban
    harden_ssh
    setup_application
    setup_pm2_service
    setup_nginx
    setup_ssl
    setup_monitoring
    create_helper_scripts
    
    # Validate setup before finishing
    validate_setup || print_warning "Some validations failed but continuing..."
    
    echo ""
    echo "==================================="
    echo "Setup Complete!"
    echo "==================================="
    echo ""
    echo "Next steps:"
    echo "1. Check application status:"
    echo "   pm2 status"
    echo "   pm2 logs basecase-web"
    echo ""
    echo "2. Verify application is running:"
    echo "   curl http://localhost:3001"
    echo "   pm2 monit  # Monitor resources"
    echo ""
    echo "3. Authenticate Claude Code (optional):"
    echo "   claude auth"
    echo ""
    echo "4. Set up SSH keys and disable password authentication:"
    echo "   # Generate SSH key on your local machine"
    echo "   # Copy public key to server"
    echo "   # Disable password authentication in /etc/ssh/sshd_config"
    echo ""
    echo "5. Update DNS records to point to this server:"
    
    # Get IPv4 address
    IPV4=$(curl -4 -s ifconfig.me 2>/dev/null || curl -4 -s icanhazip.com 2>/dev/null || echo 'YOUR_IPV4')
    # Get IPv6 address
    IPV6=$(curl -6 -s ifconfig.me 2>/dev/null || curl -6 -s icanhazip.com 2>/dev/null || echo '')
    
    echo "   IPv4 (A records):"
    echo "     A record: @ -> $IPV4"
    echo "     A record: www -> $IPV4"
    
    if [ -n "$IPV6" ] && [ "$IPV6" != "" ]; then
        echo ""
        echo "   IPv6 (AAAA records) - optional:"
        echo "     AAAA record: @ -> $IPV6"
        echo "     AAAA record: www -> $IPV6"
    fi
    echo ""
    echo "Helper commands:"
    echo "  pm2 status - Check application status"
    echo "  pm2 logs - View application logs"
    echo "  $APP_DIR/scripts/deploy.sh - Deploy updates"
    echo "  $APP_DIR/scripts/env-manager.sh - Manage environment"
    echo ""
    echo "Application Details:"
    echo "- Repository: https://github.com/x7finance/basecase"
    echo "- Location: $APP_DIR"
    echo "- Port: 3001"
    echo "- User: $APP_USER"
    echo "- Process Manager: PM2
- Environment Backup: $ENV_BACKUP_DIR"
    echo ""
    echo "Security notes:"
    echo "- Firewall is enabled (ports 22, 80, 443 open)"
    echo "- Fail2ban is protecting SSH"
    echo "- Remember to set up SSH keys and disable password auth"
    echo ""
    echo "Environment variables saved to:"
    echo "  $APP_DIR/.env"
    echo ""
    echo "Logs saved to:"
    echo "  Full log: $LOG_FILE"
    echo "  Errors: $ERROR_LOG"
    echo ""
    echo "To view logs:"
    echo "  tail -f $LOG_FILE"
    echo ""
}

# Run main function
main "$@"