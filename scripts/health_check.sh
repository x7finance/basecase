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
if [ -f /root/.pm2/logs/basecase-error.log ]; then
    error_count=$(find /root/.pm2/logs/basecase-error.log -mmin -5 -exec grep -c "Error" {} \; 2>/dev/null)
    echo "${error_count:-0}"
else
    echo "0"
fi
printf "Nginx Errors: "
if [ -f /var/log/nginx/error.log ]; then
    nginx_errors=$(sudo tail -1000 /var/log/nginx/error.log 2>/dev/null | grep -c "error" || echo "0")
    echo "$nginx_errors"
else
    echo "0"
fi
echo ""

# System Resources
echo "SYSTEM RESOURCES:"
echo "-----------------"
free -h | grep Mem | awk '{printf "Memory: %s / %s (%.1f%% used)\n", $3, $2, ($3/$2)*100}'
df -h / | tail -1 | awk '{printf "Disk: %s / %s (%s used)\n", $3, $2, $5}'
echo "Load Average:$(uptime | awk -F'load average:' '{print $2}')"
echo ""

# API Endpoints
echo "API HEALTH:"
echo "-----------"
printf "App Homepage: "
response=$(curl -s -o /dev/null -w "%{http_code}" -m 5 http://localhost:3001 2>/dev/null)
if [ "$response" = "200" ] || [ "$response" = "304" ]; then
    echo "OK ($response)"
else
    echo "FAIL ($response)"
fi

printf "Auth API: "
response=$(curl -s -o /dev/null -w "%{http_code}" -m 5 http://localhost:3001/api/auth/session 2>/dev/null)
if [ "$response" = "200" ] || [ "$response" = "401" ]; then
    echo "OK ($response)"
else
    echo "FAIL ($response)"
fi

printf "InstantDB: "
response=$(curl -s -o /dev/null -w "%{http_code}" -m 5 http://localhost:8888/runtime/health 2>/dev/null)
if [ "$response" = "200" ] || [ "$response" = "404" ]; then
    echo "OK ($response)"
else
    echo "FAIL ($response)"
fi
echo ""

# WebSocket Check
echo "WEBSOCKET STATUS:"
echo "-----------------"
printf "InstantDB WS: "
ws_response=$(curl -s -o /dev/null -w "%{http_code}" -m 5 \
  -H "Connection: Upgrade" \
  -H "Upgrade: websocket" \
  -H "Sec-WebSocket-Key: test" \
  -H "Sec-WebSocket-Version: 13" \
  https://basecase.space/instant/runtime/session 2>/dev/null)
if [ "$ws_response" = "101" ] || [ "$ws_response" = "426" ]; then
    echo "OK ($ws_response)"
else
    echo "FAIL ($ws_response)"
fi
echo ""

# PM2 Process Details
echo "PM2 PROCESS DETAILS:"
echo "--------------------"
pm2 list | grep basecase || echo "No PM2 processes found"
echo ""

# Last 5 Errors
echo "LAST 5 ERRORS:"
echo "--------------"
if [ -f /root/.pm2/logs/basecase-error.log ]; then
    errors=$(tail -100 /root/.pm2/logs/basecase-error.log | grep -i "error" | tail -5)
    if [ -n "$errors" ]; then
        echo "$errors" | head -5
    else
        echo "No recent errors found"
    fi
else
    echo "Error log not found"
fi
echo ""

echo "==================================="
echo "Health check complete!"
echo "====================================="