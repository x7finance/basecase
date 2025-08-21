# Domain Setup Guide

## Quick Setup

When running the setup script, you'll be prompted to:

1. Choose whether to configure a domain now or skip for later
2. If configuring now, enter your domain name and email

## DNS Configuration

Before running the setup script with a domain, configure your DNS:

### Required DNS Records

```
Type  | Name | Value            | TTL
------|------|------------------|------
A     | @    | YOUR_SERVER_IP   | 3600
A     | www  | YOUR_SERVER_IP   | 3600
```

### Finding Your Server IP

```bash
ssh root@your-server
curl ifconfig.me
```

## Adding Domain After Initial Setup

If you skipped domain configuration during setup:

### 1. Update Nginx Configuration

```bash
sudo nano /etc/nginx/sites-available/basecase
```

Replace the server_name line:

```nginx
server_name yourdomain.com www.yourdomain.com;
```

### 2. Test and Reload Nginx

```bash
sudo nginx -t
sudo systemctl reload nginx
```

### 3. Get SSL Certificate

```bash
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

### 4. Enable Auto-renewal

```bash
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer
```

## Multiple Domains

To add additional domains:

```bash
sudo certbot --nginx -d newdomain.com -d www.newdomain.com --expand
```

## Troubleshooting

### Domain Not Accessible

1. Check DNS propagation: `nslookup yourdomain.com`
2. Verify firewall: `sudo ufw status`
3. Check Nginx: `sudo nginx -t && sudo systemctl status nginx`

### SSL Certificate Issues

1. Test renewal: `sudo certbot renew --dry-run`
2. Check logs: `sudo journalctl -u certbot`
3. Manual renewal: `sudo certbot renew`

## Security Note

Always use HTTPS in production. The setup script automatically:

-   Redirects HTTP to HTTPS
-   Configures secure headers
-   Sets up auto-renewal for certificates
