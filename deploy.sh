#!/bin/bash

# Deploy script for basecase
SERVER="root@5.161.206.173"
REMOTE_DIR="/root/basecase"

echo "📦 Deploying to production..."

# Copy .env file to production
echo "📝 Copying .env file..."
scp .env $SERVER:$REMOTE_DIR/.env

# SSH into server and restart PM2
echo "🔄 Restarting application..."
ssh $SERVER << 'ENDSSH'
cd /root/basecase
pm2 delete basecase || true
pm2 start ecosystem.config.js --env production
pm2 save
ENDSSH

echo "✅ Deployment complete!"