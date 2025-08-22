# Basecase Operations Guide

This document provides comprehensive instructions for managing, monitoring, and troubleshooting all services in the Basecase production environment.

## Table of Contents
- [Architecture Overview](#architecture-overview)
- [Service Management](#service-management)
- [Checking Service Status](#checking-service-status)
- [Viewing Logs](#viewing-logs)
- [Database Operations](#database-operations)
- [Troubleshooting](#troubleshooting)
- [Health Checks](#health-checks)
- [Emergency Procedures](#emergency-procedures)

## Architecture Overview

Basecase consists of the following key components:

1. **Next.js Application** - Main web application (Port 3001)
2. **InstantDB** - Self-hosted real-time database (Port 8888)
3. **PostgreSQL** - Database backend for InstantDB
4. **Nginx** - Reverse proxy and SSL termination (Ports 80/443)
5. **PM2** - Node.js process manager for the application

## Service Management

### Starting Services

```bash
# Start all services
sudo systemctl start nginx
sudo systemctl start instantdb
cd /opt/basecase && pm2 start ecosystem.config.js

# Start individual services
sudo systemctl start nginx
sudo systemctl start instantdb
cd /opt/basecase && pm2 start basecase
```

### Stopping Services

```bash
# Stop all services
sudo systemctl stop nginx
sudo systemctl stop instantdb
cd /opt/basecase && pm2 stop all

# Stop individual services
sudo systemctl stop nginx
sudo systemctl stop instantdb
cd /opt/basecase && pm2 stop basecase
```

### Restarting Services

```bash
# Restart all services (recommended order)
sudo systemctl restart instantdb
sleep 3  # Wait for InstantDB to be ready
cd /opt/basecase && pm2 restart all
sudo systemctl restart nginx

# Restart individual services
sudo systemctl restart nginx
sudo systemctl restart instantdb
cd /opt/basecase && pm2 restart basecase

# Graceful reload (zero-downtime)
cd /opt/basecase && pm2 reload basecase
sudo nginx -s reload
```

### Enable/Disable Auto-start

```bash
# Enable services to start on boot
sudo systemctl enable nginx
sudo systemctl enable instantdb
cd /opt/basecase && pm2 startup
cd /opt/basecase && pm2 save

# Disable auto-start
sudo systemctl disable nginx
sudo systemctl disable instantdb
cd /opt/basecase && pm2 unstartup
```

## Checking Service Status

### Quick Status Check

```bash
# All services at once
echo "=== Service Status ==="
sudo systemctl status nginx --no-pager | head -10
sudo systemctl status instantdb --no-pager | head -10
pm2 status

# Check if services are running
sudo systemctl is-active nginx
sudo systemctl is-active instantdb
pm2 list
```

### Detailed Status Information

```bash
# Nginx status and configuration test
sudo systemctl status nginx
sudo nginx -t  # Test configuration

# InstantDB status
sudo systemctl status instantdb
curl -s http://localhost:8888/runtime/health || echo "InstantDB not responding"

# PM2 application status
pm2 describe basecase
pm2 info basecase

# Check listening ports
sudo netstat -tlnp | grep -E "(3001|8888|80|443)"
sudo lsof -i :3001  # Check what's using port 3001
sudo lsof -i :8888  # Check what's using port 8888
```

### Process Information

```bash
# Check process details
ps aux | grep -E "(node|java|nginx|postgres)" | grep -v grep

# Check memory usage
pm2 monit  # Interactive monitoring
pm2 status  # Quick memory/CPU view

# System resources
htop  # Interactive process viewer
free -h  # Memory usage
df -h  # Disk usage
```

## Viewing Logs

### Application Logs (PM2)

```bash
# View real-time logs
pm2 logs basecase  # All logs
pm2 logs basecase --lines 100  # Last 100 lines
pm2 logs basecase --err  # Only error logs
pm2 logs basecase --out  # Only output logs

# View log files directly
tail -f /root/.pm2/logs/basecase-out.log  # Output log
tail -f /root/.pm2/logs/basecase-error.log  # Error log
tail -100 /root/.pm2/logs/basecase-error.log  # Last 100 error lines

# Search logs
grep -i "error" /root/.pm2/logs/basecase-error.log | tail -20
grep -i "instantdb" /root/.pm2/logs/basecase-out.log | tail -20

# Clear logs
pm2 flush  # Clear all PM2 logs
pm2 flush basecase  # Clear specific app logs
```

### InstantDB Logs

```bash
# View InstantDB service logs
sudo journalctl -u instantdb -f  # Real-time logs
sudo journalctl -u instantdb -n 100  # Last 100 lines
sudo journalctl -u instantdb --since "1 hour ago"  # Last hour
sudo journalctl -u instantdb --since today  # Today's logs
sudo journalctl -u instantdb -p err  # Only errors

# Search InstantDB logs
sudo journalctl -u instantdb | grep -i "error" | tail -20
sudo journalctl -u instantdb | grep -i "websocket" | tail -20
```

### Nginx Logs

```bash
# Access logs
tail -f /var/log/nginx/access.log  # Real-time access log
tail -100 /var/log/nginx/access.log  # Last 100 requests
grep "instant" /var/log/nginx/access.log | tail -20  # InstantDB requests

# Error logs
tail -f /var/log/nginx/error.log  # Real-time error log
tail -100 /var/log/nginx/error.log  # Last 100 errors
grep -i "websocket" /var/log/nginx/error.log | tail -20  # WebSocket errors

# Site-specific logs (if configured)
tail -f /var/log/nginx/basecase_access.log
tail -f /var/log/nginx/basecase_error.log
```

### PostgreSQL Logs

```bash
# PostgreSQL logs
sudo tail -f /var/log/postgresql/postgresql-*.log
sudo journalctl -u postgresql -f
sudo -u postgres psql -c "SELECT * FROM pg_stat_activity WHERE state != 'idle';"
```

## Database Operations

### InstantDB Schema Management

```bash
# Check current schema
sudo -u postgres psql instant -c "SELECT DISTINCT etype, COUNT(*) as attr_count FROM attrs WHERE app_id = '3f44e818-bbda-49ac-bce4-9e0af53827f8' GROUP BY etype;"

# Check app configuration
sudo -u postgres psql instant -c "SELECT id, title FROM apps WHERE title = 'basecase';"

# Verify attributes
sudo -u postgres psql instant -c "SELECT etype, label FROM attrs WHERE app_id = '3f44e818-bbda-49ac-bce4-9e0af53827f8' ORDER BY etype, label;"
```

### Running Migrations

```bash
# InstantDB schema migrations
cd /opt/basecase/scripts

# Run a migration
sudo -u postgres psql instant < instantdb-migrate.sql

# Check migration status
sudo -u postgres psql instant -c "SELECT COUNT(*) FROM attrs WHERE app_id = '3f44e818-bbda-49ac-bce4-9e0af53827f8';"

# Create backup before migration
sudo -u postgres pg_dump instant > /tmp/instant_backup_$(date +%Y%m%d_%H%M%S).sql
```

### Database Backup

```bash
# Backup InstantDB database
sudo -u postgres pg_dump instant > /opt/backups/instant_$(date +%Y%m%d).sql

# Backup with compression
sudo -u postgres pg_dump instant | gzip > /opt/backups/instant_$(date +%Y%m%d).sql.gz

# Restore from backup
sudo -u postgres psql instant < /opt/backups/instant_20240821.sql
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Application Won't Start

```bash
# Check for port conflicts
sudo lsof -i :3001
sudo kill -9 $(sudo lsof -t -i:3001)  # Force kill process on port

# Check PM2 errors
pm2 logs basecase --err --lines 50
pm2 describe basecase  # Check restart count

# Restart with fresh state
pm2 delete basecase
cd /opt/basecase && pm2 start ecosystem.config.js
```

#### 2. InstantDB Connection Errors

```bash
# Check InstantDB is running
sudo systemctl status instantdb
curl http://localhost:8888/runtime/health

# Check WebSocket connectivity
curl -i -N \
  -H "Connection: Upgrade" \
  -H "Upgrade: websocket" \
  -H "Sec-WebSocket-Key: test" \
  -H "Sec-WebSocket-Version: 13" \
  https://basecase.space/instant/runtime/session

# Restart InstantDB
sudo systemctl restart instantdb
sleep 5
cd /opt/basecase && pm2 restart basecase
```

#### 3. Authentication Errors

```bash
# Check for schema validation errors
tail -50 /root/.pm2/logs/basecase-error.log | grep -i "validation"

# Verify auth entities exist
sudo -u postgres psql instant -c "SELECT etype, COUNT(*) FROM attrs WHERE app_id = '3f44e818-bbda-49ac-bce4-9e0af53827f8' AND etype IN ('users', 'sessions', 'accounts', 'verifications') GROUP BY etype;"

# Re-run auth migration if needed
cd /opt/basecase/scripts
sudo -u postgres psql instant < instantdb-complete-migration.sql
sudo systemctl restart instantdb
```

#### 4. Nginx 502 Bad Gateway

```bash
# Check upstream services
curl http://localhost:3001  # Check app
curl http://localhost:8888  # Check InstantDB

# Check Nginx configuration
sudo nginx -t
sudo cat /etc/nginx/sites-enabled/basecase

# Restart services in order
sudo systemctl restart instantdb
sleep 3
cd /opt/basecase && pm2 restart basecase
sudo systemctl restart nginx
```

### Debug Mode

```bash
# Enable debug logging in application
cd /opt/basecase
echo "DEBUG=* pm2 restart basecase" | bash

# Enable verbose PM2 logs
pm2 set pm2:log-level debug
pm2 restart basecase

# Monitor real-time metrics
pm2 monit
```

## Health Checks

### Automated Health Check Script

Create and run this health check script:

```bash
cat << 'EOF' > /opt/basecase/scripts/health_check.sh
#!/bin/bash

echo "==================================="
echo "   BASECASE HEALTH CHECK REPORT   "
echo "==================================="
echo "Timestamp: $(date)"
echo ""

# Service Status
echo "SERVICE STATUS:"
echo "---------------"
printf "%-15s: " "Nginx"
sudo systemctl is-active nginx || echo "STOPPED"
printf "%-15s: " "InstantDB"
sudo systemctl is-active instantdb || echo "STOPPED"
printf "%-15s: " "Basecase App"
pm2 describe basecase | grep status | awk '{print $4}' || echo "STOPPED"
echo ""

# Port Status
echo "PORT STATUS:"
echo "------------"
for port in 80 443 3001 8888; do
    printf "Port %-5s: " "$port"
    if sudo lsof -i :$port > /dev/null 2>&1; then
        echo "LISTENING"
    else
        echo "NOT LISTENING"
    fi
done
echo ""

# Database Status
echo "DATABASE STATUS:"
echo "----------------"
printf "PostgreSQL: "
sudo systemctl is-active postgresql || echo "STOPPED"
printf "InstantDB App: "
sudo -u postgres psql instant -t -c "SELECT title FROM apps WHERE title = 'basecase';" 2>/dev/null | xargs || echo "NOT FOUND"
printf "Auth Entities: "
sudo -u postgres psql instant -t -c "SELECT COUNT(DISTINCT etype) FROM attrs WHERE app_id = '3f44e818-bbda-49ac-bce4-9e0af53827f8';" 2>/dev/null | xargs || echo "0"
printf "Total Attrs: "
sudo -u postgres psql instant -t -c "SELECT COUNT(*) FROM attrs WHERE app_id = '3f44e818-bbda-49ac-bce4-9e0af53827f8';" 2>/dev/null | xargs || echo "0"
echo ""

# Recent Errors
echo "RECENT ERRORS (last 5 min):"
echo "---------------------------"
printf "App Errors: "
find /root/.pm2/logs/basecase-error.log -mmin -5 -exec grep -c "Error" {} \; 2>/dev/null | xargs || echo "0"
printf "Nginx Errors: "
sudo grep -c "error" /var/log/nginx/error.log 2>/dev/null || echo "0"
echo ""

# System Resources
echo "SYSTEM RESOURCES:"
echo "-----------------"
free -h | grep Mem | awk '{printf "Memory: %s / %s (%.1f%%)\n", $3, $2, ($3/$2)*100}'
df -h / | tail -1 | awk '{printf "Disk: %s / %s (%s)\n", $3, $2, $5}'
echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
echo ""

# API Endpoints
echo "API HEALTH:"
echo "-----------"
printf "App Homepage: "
curl -s -o /dev/null -w "%{http_code}" http://localhost:3001 || echo "FAIL"
echo ""
printf "Auth API: "
curl -s -o /dev/null -w "%{http_code}" http://localhost:3001/api/auth/session || echo "FAIL"
echo ""
printf "InstantDB: "
curl -s -o /dev/null -w "%{http_code}" http://localhost:8888/runtime/health || echo "FAIL"
echo ""

echo "==================================="
EOF

chmod +x /opt/basecase/scripts/health_check.sh
bash /opt/basecase/scripts/health_check.sh
```

### Quick Health Commands

```bash
# One-liner service check
for s in nginx instantdb; do echo -n "$s: "; sudo systemctl is-active $s; done; echo -n "basecase: "; pm2 describe basecase | grep status | awk '{print $4}'

# Check all endpoints
curl -s http://localhost:3001 > /dev/null && echo "App: OK" || echo "App: FAIL"
curl -s http://localhost:8888/runtime/health > /dev/null && echo "InstantDB: OK" || echo "InstantDB: FAIL"

# Memory check
pm2 status | grep basecase
free -h | grep Mem
```

## Emergency Procedures

### Complete System Restart

```bash
# Stop everything
cd /opt/basecase && pm2 stop all
sudo systemctl stop nginx
sudo systemctl stop instantdb

# Clear logs and temp files
pm2 flush
sudo rm -f /var/log/nginx/error.log.1
sudo rm -f /var/log/nginx/access.log.1

# Start in correct order
sudo systemctl start instantdb
sleep 5  # Wait for InstantDB
cd /opt/basecase && pm2 start ecosystem.config.js
sudo systemctl start nginx

# Verify
bash /opt/basecase/scripts/health_check.sh
```

### Emergency Database Recovery

```bash
# Stop services
cd /opt/basecase && pm2 stop all
sudo systemctl stop instantdb

# Backup current state
sudo -u postgres pg_dump instant > /tmp/instant_emergency_$(date +%Y%m%d_%H%M%S).sql

# Restore from last known good backup
sudo -u postgres psql instant < /opt/backups/instant_last_good.sql

# Restart services
sudo systemctl start instantdb
cd /opt/basecase && pm2 start basecase
```

### Force Kill Stuck Processes

```bash
# Find and kill Node.js processes
pkill -f node
pkill -f "pm2"

# Kill Java processes (InstantDB)
pkill -f java

# Clear PM2
pm2 kill
pm2 resurrect  # Restore saved process list
```

### Rollback Deployment

```bash
# Stop application
cd /opt/basecase && pm2 stop basecase

# Checkout previous version
cd /opt/basecase
git stash
git checkout HEAD~1  # Or specific commit/tag

# Rebuild and restart
bun install
bun run build
pm2 restart basecase
```

## Monitoring Setup

### Setting Up Alerts

```bash
# PM2 monitoring
pm2 install pm2-logrotate  # Rotate logs automatically
pm2 set pm2-logrotate:max_size 100M
pm2 set pm2-logrotate:retain 7

# System monitoring with PM2
pm2 install pm2-server-monit
pm2 install pm2-auto-pull  # Auto-pull git changes
```

### Log Rotation

```bash
# Configure logrotate for nginx
sudo cat << 'EOF' > /etc/logrotate.d/nginx
/var/log/nginx/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 www-data adm
    sharedscripts
    postrotate
        [ -f /var/run/nginx.pid ] && kill -USR1 `cat /var/run/nginx.pid`
    endscript
}
EOF

# Configure PM2 log rotation
pm2 install pm2-logrotate
pm2 set pm2-logrotate:retain 7
pm2 set pm2-logrotate:compress true
pm2 set pm2-logrotate:dateFormat YYYY-MM-DD_HH-mm-ss
```

## Useful Aliases

Add these to `/root/.bashrc` for quick access:

```bash
# Service management
alias bc-status='bash /opt/basecase/scripts/health_check.sh'
alias bc-restart='cd /opt/basecase && pm2 restart basecase'
alias bc-logs='pm2 logs basecase'
alias bc-errors='tail -50 /root/.pm2/logs/basecase-error.log'

# InstantDB
alias idb-status='sudo systemctl status instantdb'
alias idb-restart='sudo systemctl restart instantdb'
alias idb-logs='sudo journalctl -u instantdb -f'

# Database
alias db-instant='sudo -u postgres psql instant'
alias db-attrs='sudo -u postgres psql instant -c "SELECT etype, label FROM attrs WHERE app_id = \"3f44e818-bbda-49ac-bce4-9e0af53827f8\" ORDER BY etype, label;"'

# Apply aliases
source ~/.bashrc
```

## Contact and Support

For urgent issues:
1. Check this guide first
2. Run the health check script: `bash /opt/basecase/scripts/health_check.sh`
3. Check recent errors: `bc-errors`
4. Restart services if needed: `bc-restart`

---

**Last Updated:** August 2024
**Version:** 1.0.0