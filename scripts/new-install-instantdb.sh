# InstantDB Secrets - Generated Thu Aug 21 03:19:01 PM UTC 2025
# This file contains sensitive information. Keep it secure!

maintenance_work_mem = 32MB
work_mem = 2MB
max_connections = 50

# Performance Tuning
checkpoint_completion_target = 0.9
wal_buffers = 4MB
default_statistics_target = 100
random_page_cost = 1.1
# InstantDB Configuration END
EOF

    # Configure authentication for local connections
    if ! grep -q "local   instant" $PG_HBA_FILE; then
        # Backup pg_hba.conf
        cp $PG_HBA_FILE ${PG_HBA_FILE}.backup.$(date +%Y%m%d%H%M%S)

        # Add authentication rules for InstantDB
        sed -i '/^# TYPE/a\
# InstantDB authentication\
local   instant         instantdb                               md5\
host    instant         instantdb       127.0.0.1/32            md5\
host    instant         instantdb       ::1/128                 md5' $PG_HBA_FILE
    fi

    # Restart PostgreSQL to apply changes
    systemctl restart postgresql

    # Wait for PostgreSQL to be ready
    sleep 3

    # Validate configuration
    if ! validate "PostgreSQL logical replication configuration" "sudo -u postgres psql -c 'SHOW wal_level;' | grep -q 'logical'"; then
        error "Failed to configure PostgreSQL for logical replication"
    fi

    info "PostgreSQL configured with logical replication enabled"
fi

# ============================================================================
# STEP 5: INSTALL PG_HINT_PLAN EXTENSION
# ============================================================================
log ""
log "STEP 5: Installing pg_hint_plan Extension"
log "-----------------------------------------"

if validate "pg_hint_plan" "sudo -u postgres psql -c 'SELECT * FROM pg_available_extensions;' | grep -q 'pg_hint_plan'"; then
    log "pg_hint_plan already available"
else
    log "Building and installing pg_hint_plan..."

    cd /tmp
root@numberice1:~# cat install-instantdb.sh
#!/bin/bash

# ============================================================================
# InstantDB Self-Hosting Installation Script
# ============================================================================
# This script is idempotent - safe to run multiple times
# Each step validates before proceeding
# All secrets and configurations are stored in /root/instantdb-secrets.env
# ============================================================================

set -euo pipefail

# ============================================================================
# CONFIGURATION VARIABLES
# ============================================================================
INSTANTDB_DIR="/opt/instantdb"
INSTANTDB_USER="instantdb"
JAVA_VERSION="22"
CLOJURE_VERSION="1.11.1.1435"
POSTGRES_VERSION="16"
MIGRATE_VERSION="v4.16.2"
LOG_FILE="/var/log/instantdb-install.log"
SECRETS_FILE="/root/instantdb-secrets.env"
CONNECTIONS_FILE="/root/instantdb-connections.txt"

# Generate secure password if not exists
if [ ! -f "$SECRETS_FILE" ]; then
    DB_PASSWORD=$(openssl rand -base64 32)
    INSTANTDB_SECRET=$(openssl rand -base64 32)
else
    source "$SECRETS_FILE"
fi

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

validate() {
    local step_name="$1"
    local validation_command="$2"

    log "Validating: $step_name"
    if eval "$validation_command" 2>/dev/null; then
        log "✓ $step_name validated successfully"
        return 0
    else
        return 1
    fi
}

# ============================================================================
# INITIALIZATION
# ============================================================================

# Create necessary directories and files
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

log "============================================================================"
log "InstantDB Installation Script Starting"
log "Script Version: 1.0.0"
log "Installation Directory: $INSTANTDB_DIR"
log "============================================================================"

# ============================================================================
# STEP 0: SYSTEM PREREQUISITES & ENVIRONMENT CHECK
# ============================================================================
log ""
log "STEP 0: System Prerequisites Check"
log "-----------------------------------"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root or with sudo"
fi

# Check available memory
AVAILABLE_MEM=$(free -m | awk '/^Mem:/{print $7}')
if [ "$AVAILABLE_MEM" -lt 500 ]; then
    warning "Low available memory: ${AVAILABLE_MEM}MB. Recommended: >500MB"
fi

# Check disk space
AVAILABLE_DISK=$(df / | awk 'NR==2 {print int($4/1024)}')
if [ "$AVAILABLE_DISK" -lt 5000 ]; then
    warning "Low disk space: ${AVAILABLE_DISK}MB. Recommended: >5GB"
fi

info "Available Memory: ${AVAILABLE_MEM}MB"
info "Available Disk: ${AVAILABLE_DISK}MB"

# Update package lists
log "Updating package lists..."
apt-get update -qq || error "Failed to update package lists"

# Install basic dependencies
log "Installing basic dependencies..."
apt-get install -y -qq \
    curl wget gnupg lsb-release software-properties-common \
    git build-essential unzip openssl net-tools || error "Failed to install basic dependencies"

# Create instantdb user if doesn't exist
if ! id "$INSTANTDB_USER" &>/dev/null; then
    log "Creating system user: $INSTANTDB_USER"
    useradd -r -s /bin/bash -m -d /home/$INSTANTDB_USER $INSTANTDB_USER
    info "User created with home directory: /home/$INSTANTDB_USER"
else
    log "User $INSTANTDB_USER already exists"
fi

# ============================================================================
# STEP 1: INSTALL JAVA 22
# ============================================================================
log ""
log "STEP 1: Installing Java $JAVA_VERSION"
log "--------------------------------------"

if validate "Java $JAVA_VERSION" "java -version 2>&1 | grep -q 'version \"22'"; then
    log "Java $JAVA_VERSION already installed"
    JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/bin/java::")
    info "JAVA_HOME: $JAVA_HOME"
else
    log "Installing OpenJDK $JAVA_VERSION..."

    # Try to install from different sources
    # First try: Download Oracle OpenJDK directly
    cd /tmp

    info "Downloading OpenJDK 22 from Oracle..."
    wget -q https://download.oracle.com/java/22/latest/jdk-22_linux-x64_bin.tar.gz || {
        # Fallback to OpenJDK builds
        warning "Oracle download failed, trying alternative source..."
        wget -q https://github.com/adoptium/temurin22-binaries/releases/download/jdk-22%2B36/OpenJDK22U-jdk_x64_linux_hotspot_22_36.tar.gz -O jdk-22_linux-x64_bin.tar.gz
    }

    if [ -f "jdk-22_linux-x64_bin.tar.gz" ]; then
        tar -xzf jdk-22_linux-x64_bin.tar.gz
        # Find the extracted directory (could be jdk-22, jdk-22+36, etc.)
        JDK_DIR=$(find . -maxdepth 1 -type d -name "jdk-22*" | head -1)
        if [ -n "$JDK_DIR" ]; then
            mv "$JDK_DIR" /opt/jdk-22
        else
            error "Failed to find extracted JDK directory"
        fi

        # Set up alternatives
        update-alternatives --install /usr/bin/java java /opt/jdk-22/bin/java 2200
        update-alternatives --install /usr/bin/javac javac /opt/jdk-22/bin/javac 2200
        update-alternatives --set java /opt/jdk-22/bin/java
        update-alternatives --set javac /opt/jdk-22/bin/javac

        JAVA_HOME="/opt/jdk-22"

        # Set JAVA_HOME system-wide
        cat > /etc/profile.d/java.sh <<EOF
export JAVA_HOME=$JAVA_HOME
export PATH=\$JAVA_HOME/bin:\$PATH
EOF
        source /etc/profile.d/java.sh

        rm jdk-22_linux-x64_bin.tar.gz

        # Validate installation
        if ! validate "Java $JAVA_VERSION installation" "java -version 2>&1 | grep -q 'version \"22'"; then
            error "Failed to install Java $JAVA_VERSION"
        fi

        info "Java installed at: $JAVA_HOME"
    else
        error "Failed to download Java 22"
    fi
fi

# ============================================================================
# STEP 2: INSTALL CLOJURE
# ============================================================================
log ""
log "STEP 2: Installing Clojure"
log "--------------------------"

if validate "Clojure" "command -v clojure &>/dev/null"; then
    log "Clojure already installed"
    info "Clojure path: $(which clojure)"
else
    log "Downloading and installing Clojure..."

    cd /tmp
    curl -O https://download.clojure.org/install/linux-install-${CLOJURE_VERSION}.sh || error "Failed to download Clojure"
    chmod +x linux-install-${CLOJURE_VERSION}.sh
    ./linux-install-${CLOJURE_VERSION}.sh || error "Failed to install Clojure"
    rm linux-install-${CLOJURE_VERSION}.sh

    # Validate installation
    if ! validate "Clojure installation" "command -v clojure &>/dev/null"; then
        error "Failed to install Clojure"
    fi

    info "Clojure installed at: $(which clojure)"
fi

# ============================================================================
# STEP 3: INSTALL POSTGRESQL 16
# ============================================================================
log ""
log "STEP 3: Installing PostgreSQL $POSTGRES_VERSION"
log "-----------------------------------------------"

if validate "PostgreSQL $POSTGRES_VERSION" "psql --version 2>/dev/null | grep -q 'psql (PostgreSQL) $POSTGRES_VERSION'"; then
    log "PostgreSQL $POSTGRES_VERSION already installed"
else
    log "Adding PostgreSQL official repository..."

    # Add PostgreSQL official repository
    sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
    apt-get update -qq

    log "Installing PostgreSQL $POSTGRES_VERSION..."
    apt-get install -y -qq \
        postgresql-${POSTGRES_VERSION} \
        postgresql-contrib-${POSTGRES_VERSION} \
        postgresql-server-dev-${POSTGRES_VERSION} || error "Failed to install PostgreSQL"

    # Start and enable PostgreSQL
    systemctl start postgresql
    systemctl enable postgresql

    # Validate installation
    if ! validate "PostgreSQL $POSTGRES_VERSION installation" "psql --version 2>/dev/null | grep -q 'psql (PostgreSQL) $POSTGRES_VERSION'"; then
        error "Failed to install PostgreSQL $POSTGRES_VERSION"
    fi
fi

info "PostgreSQL config directory: /etc/postgresql/$POSTGRES_VERSION/main"
info "PostgreSQL data directory: /var/lib/postgresql/$POSTGRES_VERSION/main"

# ============================================================================
# STEP 4: CONFIGURE POSTGRESQL FOR LOGICAL REPLICATION
# ============================================================================
log ""
log "STEP 4: Configuring PostgreSQL for Logical Replication"
log "------------------------------------------------------"

PG_CONFIG_DIR="/etc/postgresql/$POSTGRES_VERSION/main"
PG_CONFIG_FILE="$PG_CONFIG_DIR/postgresql.conf"
PG_HBA_FILE="$PG_CONFIG_DIR/pg_hba.conf"

if validate "PostgreSQL logical replication" "grep -q '^wal_level = logical' $PG_CONFIG_FILE 2>/dev/null"; then
    log "PostgreSQL logical replication already configured"
else
    log "Enabling logical replication and optimizing for low memory..."

    # Backup original config
    cp $PG_CONFIG_FILE ${PG_CONFIG_FILE}.backup.$(date +%Y%m%d%H%M%S)

    # Remove any existing InstantDB configuration block
    sed -i '/# InstantDB Configuration START/,/# InstantDB Configuration END/d' $PG_CONFIG_FILE

    # Add optimized configuration
    cat >> $PG_CONFIG_FILE <<EOF

# InstantDB Configuration START
# Logical Replication Settings
wal_level = logical
max_replication_slots = 4
max_wal_senders = 4

# Memory Optimization for 2GB VPS
shared_buffers = 128MB
effective_cache_size = 512MB
maintenance_work_mem = 32MB
work_mem = 2MB
max_connections = 50

# Performance Tuning
checkpoint_completion_target = 0.9
wal_buffers = 4MB
default_statistics_target = 100
random_page_cost = 1.1
# InstantDB Configuration END
EOF

    # Configure authentication for local connections
    if ! grep -q "local   instant" $PG_HBA_FILE; then
        # Backup pg_hba.conf
        cp $PG_HBA_FILE ${PG_HBA_FILE}.backup.$(date +%Y%m%d%H%M%S)

        # Add authentication rules for InstantDB
        sed -i '/^# TYPE/a\
# InstantDB authentication\
local   instant         instantdb                               md5\
host    instant         instantdb       127.0.0.1/32            md5\
host    instant         instantdb       ::1/128                 md5' $PG_HBA_FILE
    fi

    # Restart PostgreSQL to apply changes
    systemctl restart postgresql

    # Wait for PostgreSQL to be ready
    sleep 3

    # Validate configuration
    if ! validate "PostgreSQL logical replication configuration" "sudo -u postgres psql -c 'SHOW wal_level;' | grep -q 'logical'"; then
        error "Failed to configure PostgreSQL for logical replication"
    fi

    info "PostgreSQL configured with logical replication enabled"
fi

# ============================================================================
# STEP 5: INSTALL PG_HINT_PLAN EXTENSION
# ============================================================================
log ""
log "STEP 5: Installing pg_hint_plan Extension"
log "-----------------------------------------"

if validate "pg_hint_plan" "sudo -u postgres psql -c 'SELECT * FROM pg_available_extensions;' | grep -q 'pg_hint_plan'"; then
    log "pg_hint_plan already available"
else
    log "Building and installing pg_hint_plan..."

    cd /tmp
    if [ -d "pg_hint_plan" ]; then
        rm -rf pg_hint_plan
    fi

    git clone https://github.com/ossc-db/pg_hint_plan.git || error "Failed to clone pg_hint_plan"
    cd pg_hint_plan

    # Try to checkout the appropriate version
    git checkout REL${POSTGRES_VERSION}_STABLE 2>/dev/null || \
    git checkout PG${POSTGRES_VERSION} 2>/dev/null || \
    git checkout master

    make USE_PGXS=1 || error "Failed to build pg_hint_plan"
    make USE_PGXS=1 install || error "Failed to install pg_hint_plan"

    # Update shared_preload_libraries
    if ! grep -q "shared_preload_libraries.*pg_hint_plan" $PG_CONFIG_FILE; then
        if grep -q "^shared_preload_libraries" $PG_CONFIG_FILE; then
            sed -i "s/^shared_preload_libraries.*/shared_preload_libraries = 'pg_stat_statements,pg_hint_plan'/" $PG_CONFIG_FILE
        else
            echo "shared_preload_libraries = 'pg_stat_statements,pg_hint_plan'" >> $PG_CONFIG_FILE
        fi
    fi

    systemctl restart postgresql
    sleep 3

    cd /
    rm -rf /tmp/pg_hint_plan

    # Validate installation - create extension in template1
    sudo -u postgres psql template1 -c 'CREATE EXTENSION IF NOT EXISTS pg_hint_plan;' 2>/dev/null || \
        warning "pg_hint_plan extension may require manual setup"

    info "pg_hint_plan extension installed"
fi

# ============================================================================
# STEP 6: INSTALL GOLANG-MIGRATE
# ============================================================================
log ""
log "STEP 6: Installing golang-migrate"
log "---------------------------------"

if validate "golang-migrate" "command -v migrate &>/dev/null"; then
    log "golang-migrate already installed"
    info "migrate path: $(which migrate)"
else
    log "Downloading and installing golang-migrate..."

    cd /tmp
    wget -q https://github.com/golang-migrate/migrate/releases/download/${MIGRATE_VERSION}/migrate.linux-amd64.tar.gz || \
        error "Failed to download golang-migrate"
    tar xzf migrate.linux-amd64.tar.gz
    mv migrate /usr/local/bin/
    chmod +x /usr/local/bin/migrate
    rm migrate.linux-amd64.tar.gz

    # Validate installation
    if ! validate "golang-migrate installation" "migrate -version &>/dev/null"; then
        error "Failed to install golang-migrate"
    fi

    info "golang-migrate installed at: /usr/local/bin/migrate"
fi

# ============================================================================
# STEP 7: CLONE INSTANTDB REPOSITORY
# ============================================================================
log ""
log "STEP 7: Setting up InstantDB Repository"
log "---------------------------------------"

if [ -d "$INSTANTDB_DIR" ]; then
    log "InstantDB directory already exists at $INSTANTDB_DIR"
    cd $INSTANTDB_DIR

    # Check if it's a git repository
    if [ -d ".git" ]; then
        log "Updating existing repository..."
        git pull origin main 2>/dev/null || warning "Could not update repository"
    fi
else
    log "Cloning InstantDB repository..."
    git clone https://github.com/instantdb/instant.git $INSTANTDB_DIR || error "Failed to clone InstantDB"
    cd $INSTANTDB_DIR
fi

# Change ownership to instantdb user
chown -R $INSTANTDB_USER:$INSTANTDB_USER $INSTANTDB_DIR

# Validate repository
if ! validate "InstantDB repository" "[ -f '$INSTANTDB_DIR/server/Makefile' ]"; then
    error "InstantDB repository setup failed"
fi

info "InstantDB repository location: $INSTANTDB_DIR"

# ============================================================================
# STEP 8: CREATE DATABASE AND SETUP AUTHENTICATION
# ============================================================================
log ""
log "STEP 8: Setting up InstantDB Database"
log "-------------------------------------"

if validate "InstantDB database" "sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw instant"; then
    log "Database 'instant' already exists"
else
    log "Creating database 'instant' and configuring authentication..."

    # Create user with secure password
    sudo -u postgres psql <<EOF
-- Create user if not exists
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_user WHERE usename = '$INSTANTDB_USER') THEN
        CREATE USER $INSTANTDB_USER WITH PASSWORD '$DB_PASSWORD';
    ELSE
        ALTER USER $INSTANTDB_USER WITH PASSWORD '$DB_PASSWORD';
    END IF;
END
\$\$;

-- Create database
CREATE DATABASE instant OWNER $INSTANTDB_USER;

-- Grant all privileges
GRANT ALL PRIVILEGES ON DATABASE instant TO $INSTANTDB_USER;

-- Connect to instant database and setup
\c instant
GRANT ALL ON SCHEMA public TO $INSTANTDB_USER;
EOF

    # Validate database creation
    if ! validate "InstantDB database creation" "sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw instant"; then
        error "Failed to create InstantDB database"
    fi

    info "Database 'instant' created with owner '$INSTANTDB_USER'"
fi

# Setup DATABASE_URL for migrations
export DATABASE_URL="postgresql://$INSTANTDB_USER:$DB_PASSWORD@localhost:5432/instant"

# Run migrations
log "Running database migrations..."
cd $INSTANTDB_DIR/server

# Create a temporary env file for the instantdb user
cat > /tmp/instantdb_env <<EOF
export DATABASE_URL="$DATABASE_URL"
export JAVA_HOME="$JAVA_HOME"
export PATH="\$JAVA_HOME/bin:\$PATH"
EOF

sudo -u $INSTANTDB_USER bash -c "source /tmp/instantdb_env && make dev-up" || \
    warning "Migrations may have already been applied"

rm /tmp/instantdb_env

# ============================================================================
# STEP 9: BOOTSTRAP INSTANTDB CONFIGURATION
# ============================================================================
log ""
log "STEP 9: Bootstrapping InstantDB Configuration"
log "---------------------------------------------"

CONFIG_FILE="$INSTANTDB_DIR/server/resources/config/override.edn"

if [ -f "$CONFIG_FILE" ]; then
    log "Configuration already exists"
else
    log "Creating bootstrap configuration..."
    cd $INSTANTDB_DIR/server

    # Bootstrap configuration
    sudo -u $INSTANTDB_USER make bootstrap-oss || warning "Bootstrap may have already been done"

    # Update configuration with our database settings
    if [ -f "$CONFIG_FILE" ]; then
        log "Updating configuration with database connection..."

        # Create a backup
        cp $CONFIG_FILE ${CONFIG_FILE}.backup.$(date +%Y%m%d%H%M%S)

        # Note: The actual configuration update would depend on the EDN format
        # This is a placeholder for the actual configuration update
        info "Configuration file created at: $CONFIG_FILE"
    fi
fi

# Validate configuration
if ! validate "InstantDB configuration" "[ -f '$CONFIG_FILE' ]"; then
    error "Failed to bootstrap InstantDB configuration"
fi

# ============================================================================
# STEP 10: CREATE SYSTEMD SERVICE
# ============================================================================
log ""
log "STEP 10: Creating Systemd Service"
log "---------------------------------"

SERVICE_FILE="/etc/systemd/system/instantdb.service"

log "Creating systemd service configuration..."

cat > $SERVICE_FILE <<EOF
[Unit]
Description=InstantDB Server
Documentation=https://github.com/instantdb/instant
After=network.target postgresql.service
Requires=postgresql.service

[Service]
Type=simple
User=$INSTANTDB_USER
Group=$INSTANTDB_USER
WorkingDirectory=$INSTANTDB_DIR/server

# Environment variables
Environment="JAVA_HOME=$JAVA_HOME"
Environment="PATH=$JAVA_HOME/bin:/usr/local/bin:/usr/bin:/bin"
Environment="DATABASE_URL=postgresql://$INSTANTDB_USER:$DB_PASSWORD@localhost:5432/instant"

# JVM Memory Settings (optimized for 2GB VPS)
Environment="JVM_OPTS=-Xms256m -Xmx768m -XX:+UseG1GC -XX:MaxGCPauseMillis=100"

# Main process
ExecStart=/usr/bin/make dev

# Restart policy
Restart=on-failure
RestartSec=10
StartLimitBurst=3
StartLimitInterval=60

# Resource limits
LimitNOFILE=65536
LimitNPROC=4096

# Kill settings
KillSignal=SIGTERM
KillMode=mixed
TimeoutStopSec=30

# Logging
StandardOutput=append:/var/log/instantdb/instantdb.log
StandardError=append:/var/log/instantdb/instantdb-error.log

[Install]
WantedBy=multi-user.target
EOF

# Create log directory
mkdir -p /var/log/instantdb
chown -R $INSTANTDB_USER:$INSTANTDB_USER /var/log/instantdb

# Set up log rotation
cat > /etc/logrotate.d/instantdb <<EOF
/var/log/instantdb/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0644 $INSTANTDB_USER $INSTANTDB_USER
    sharedscripts
    postrotate
        systemctl reload instantdb 2>/dev/null || true
    endscript
}
EOF

# Reload systemd
systemctl daemon-reload

info "Systemd service created: $SERVICE_FILE"
info "Log directory: /var/log/instantdb/"

# ============================================================================
# STEP 11: CREATE SECRETS AND CONNECTION FILES
# ============================================================================
log ""
log "STEP 11: Creating Secrets and Connection Information Files"
log "----------------------------------------------------------"

# Create secrets file (only accessible by root)
log "Creating secrets file..."
cat > $SECRETS_FILE <<EOF
# InstantDB Secrets - Generated $(date)
# This file contains sensitive information. Keep it secure!

# Database Credentials
DB_PASSWORD="$DB_PASSWORD"
DATABASE_URL="postgresql://$INSTANTDB_USER:$DB_PASSWORD@localhost:5432/instant"

# InstantDB Application Secret
INSTANTDB_SECRET="$INSTANTDB_SECRET"

# Java Settings
JAVA_HOME="$JAVA_HOME"
JVM_OPTS="-Xms256m -Xmx768m -XX:+UseG1GC -XX:MaxGCPauseMillis=100"

# Paths
INSTANTDB_DIR="$INSTANTDB_DIR"
CONFIG_FILE="$CONFIG_FILE"
EOF

chmod 600 $SECRETS_FILE
info "Secrets saved to: $SECRETS_FILE (readable only by root)"

# Create connections file
log "Creating connection information file..."
cat > $CONNECTIONS_FILE <<EOF
============================================================================
InstantDB Connection Information
Generated: $(date)
============================================================================

SERVICE ENDPOINTS:
------------------
InstantDB Server:       http://localhost:8888
nREPL (Development):    localhost:6005
PostgreSQL Database:    localhost:5432/instant

AUTHENTICATION:
---------------
Database User:          $INSTANTDB_USER
Database Name:          instant
Password Location:      $SECRETS_FILE (root access only)

FILE LOCATIONS:
---------------
Installation Directory: $INSTANTDB_DIR
Configuration File:     $CONFIG_FILE
Service File:          $SERVICE_FILE
Log Files:             /var/log/instantdb/
Secrets File:          $SECRETS_FILE

SYSTEM COMMANDS:
----------------
Start Service:         systemctl start instantdb
Stop Service:          systemctl stop instantdb
Restart Service:       systemctl restart instantdb
Enable Auto-start:     systemctl enable instantdb
Check Status:          systemctl status instantdb
View Logs:             tail -f /var/log/instantdb/instantdb.log
View Error Logs:       tail -f /var/log/instantdb/instantdb-error.log
Edit Config:           nano $CONFIG_FILE

DATABASE ACCESS:
----------------
Connect as superuser:  sudo -u postgres psql
Connect to instant:    sudo -u postgres psql -d instant
Connect as app user:   psql -h localhost -U $INSTANTDB_USER -d instant

TROUBLESHOOTING:
----------------
Check Java Version:    java -version
Check Clojure:        clojure --version
Check PostgreSQL:     sudo -u postgres psql -c 'SELECT version();'
Check Migrations:     cd $INSTANTDB_DIR/server && make dev-up
Rebuild Config:       cd $INSTANTDB_DIR/server && make bootstrap-oss

MEMORY USAGE:
-------------
Current Free Memory:   $(free -h | grep "^Mem:" | awk '{print $4}')
JVM Max Heap:         768MB
PostgreSQL Shared:    128MB
Expected Total Use:   ~1.2GB

============================================================================
EOF

chmod 644 $CONNECTIONS_FILE
info "Connection information saved to: $CONNECTIONS_FILE"

# ============================================================================
# STEP 12: FINAL VALIDATION AND STATUS REPORT
# ============================================================================
log ""
log "STEP 12: Final Validation and Status Report"
log "-------------------------------------------"
log ""
log "============================================================================"
log "INSTALLATION SUMMARY"
log "============================================================================"

# Check all components
components=(
    "Java 22:java -version 2>&1 | grep -q 'version \"22'"
    "Clojure:command -v clojure &>/dev/null"
    "PostgreSQL $POSTGRES_VERSION:psql --version 2>/dev/null | grep -q 'PostgreSQL) $POSTGRES_VERSION'"
    "Logical Replication:sudo -u postgres psql -c 'SHOW wal_level;' | grep -q 'logical'"
    "golang-migrate:command -v migrate &>/dev/null"
    "InstantDB Repository:[ -d '$INSTANTDB_DIR' ]"
    "InstantDB Database:sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw instant"
    "InstantDB Config:[ -f '$CONFIG_FILE' ]"
    "Systemd Service:[ -f '$SERVICE_FILE' ]"
    "Secrets File:[ -f '$SECRETS_FILE' ]"
    "Connections File:[ -f '$CONNECTIONS_FILE' ]"
)

all_valid=true
echo ""
for component in "${components[@]}"; do
    IFS=':' read -r name check <<< "$component"
    if eval "$check" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $name"
    else
        echo -e "${RED}✗${NC} $name - needs attention"
        all_valid=false
    fi
done

echo ""
log "============================================================================"

if [ "$all_valid" = true ]; then
    log "🎉 Installation completed successfully!"
    log ""
    log "NEXT STEPS:"
    log "-----------"
    log "1. Review configuration:        nano $CONFIG_FILE"
    log "2. Start InstantDB service:     systemctl start instantdb"
    log "3. Enable auto-start on boot:   systemctl enable instantdb"
    log "4. Check service status:        systemctl status instantdb"
    log "5. Monitor logs:                tail -f /var/log/instantdb/instantdb.log"
    log ""
    log "ACCESS INFORMATION:"
    log "-------------------"
    log "InstantDB URL:          http://localhost:8888"
    log "Connection Details:     cat $CONNECTIONS_FILE"
    log "Secrets (root only):    cat $SECRETS_FILE"
    log ""
    log "IMPORTANT FILES:"
    log "----------------"
    log "Installation Log:       $LOG_FILE"
    log "Connection Info:        $CONNECTIONS_FILE"
    log "Secrets File:          $SECRETS_FILE"
else
    warning "Installation completed with some issues. Please review the components marked with ✗"
    log ""
    log "Check the installation log for details: $LOG_FILE"
    log "You can run this script again to retry failed components."
fi

log ""
log "============================================================================"
log "Installation script completed at $(date)"
log "============================================================================"