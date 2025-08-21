# Git Setup Guide

This guide covers Git configuration for your Basecase deployment.

## Ubuntu Server Git Setup

Git is automatically installed and configured when you run the `setup.sh` script. The script:

1. Installs Git package
2. Configures Git for the deployment user
3. Sets up SSH keys for repository access
4. Configures known hosts for GitHub, GitLab, and Bitbucket

## Deploy Key Setup

### Automatic Setup (Recommended)

Use the provided script for easy deploy key configuration:

```bash
# Run on your server
sudo /home/appuser/app/scripts/setup-git-deploy.sh
```

The script provides an interactive menu to:

-   Generate new SSH deploy keys
-   Display public key for repository setup
-   Test Git connections
-   Clone your repository

### Manual Setup

#### 1. Generate SSH Key

On your **local machine**:

```bash
# Generate ED25519 key (recommended)
ssh-keygen -t ed25519 -f basecase_deploy_key -C "deploy@basecase"

# Or RSA key (if ED25519 not supported)
ssh-keygen -t rsa -b 4096 -f basecase_deploy_key -C "deploy@basecase"
```

#### 2. Copy Private Key to Server

```bash
# Copy private key to server
scp basecase_deploy_key root@YOUR_SERVER_IP:/home/appuser/.ssh/deploy_key

# Set proper permissions on server
ssh root@YOUR_SERVER_IP "chmod 600 /home/appuser/.ssh/deploy_key"
ssh root@YOUR_SERVER_IP "chown appuser:appuser /home/appuser/.ssh/deploy_key"
```

#### 3. Add Public Key to Repository

Add the contents of `basecase_deploy_key.pub` to your repository's deploy keys:

**GitHub:**

1. Go to Settings → Deploy keys
2. Click "Add deploy key"
3. Paste the public key
4. Give it a title (e.g., "Basecase VPS")
5. Check "Allow write access" if needed

**GitLab:**

1. Go to Settings → Repository → Deploy keys
2. Click "Add deploy key"
3. Paste the public key
4. Give it a title

**Bitbucket:**

1. Go to Settings → Access keys
2. Click "Add key"
3. Paste the public key
4. Give it a label

## Repository Cloning

### Using SSH (Private Repos)

```bash
# Switch to app user
su - appuser

# Navigate to app directory
cd /home/appuser/app

# Clone repository
git clone git@github.com:YOUR_USERNAME/YOUR_REPO.git .
```

### Using HTTPS (Public Repos)

```bash
# For public repositories, you can use HTTPS
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git .
```

## Git Configuration

The setup script configures Git with sensible defaults:

```bash
# User configuration
git config --global user.name "Basecase Deployment"
git config --global user.email "deploy@basecase.local"

# Default branch
git config --global init.defaultBranch main

# Pull strategy
git config --global pull.rebase false
```

## Deployment Workflow

### Manual Deployment

```bash
# Pull latest changes
cd /home/appuser/app
git pull origin main

# Install/update dependencies
bun install

# Build application
bun run build

# Restart service
sudo systemctl restart basecase
```

### Automated Deployment

Use the deployment script:

```bash
/home/appuser/app/scripts/deploy.sh
```

## Continuous Deployment

### GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to VPS

on:
    push:
        branches: [main]

jobs:
    deploy:
        runs-on: ubuntu-latest
        steps:
            - uses: actions/checkout@v4

            - name: Deploy to VPS
              uses: appleboy/ssh-action@v1.0.0
              with:
                  host: ${{ secrets.HOST }}
                  username: ${{ secrets.USERNAME }}
                  key: ${{ secrets.SSH_KEY }}
                  script: |
                      cd /home/appuser/app
                      git pull origin main
                      bun install --frozen-lockfile
                      bun run build
                      sudo systemctl restart basecase
```

### GitLab CI/CD

Create `.gitlab-ci.yml`:

```yaml
deploy:
    stage: deploy
    script:
        - ssh -o StrictHostKeyChecking=no $SSH_USER@$SSH_HOST "
          cd /home/appuser/app &&
          git pull origin main &&
          bun install --frozen-lockfile &&
          bun run build &&
          sudo systemctl restart basecase
          "
    only:
        - main
```

## Troubleshooting

### Permission Denied

```bash
# Check SSH key permissions
ls -la ~/.ssh/deploy_key
# Should show: -rw------- (600)

# Fix permissions if needed
chmod 600 ~/.ssh/deploy_key
```

### Host Key Verification Failed

```bash
# Add host to known_hosts
ssh-keyscan -H github.com >> ~/.ssh/known_hosts
```

### Cannot Clone Repository

1. Verify deploy key is added to repository
2. Test SSH connection:
    ```bash
    ssh -T git@github.com
    ```
3. Check SSH config:
    ```bash
    cat ~/.ssh/config
    ```

### Git Commands Fail

Ensure you're running commands as the app user:

```bash
su - appuser
```

## Security Best Practices

1. **Use Deploy Keys**: Never use personal SSH keys on servers
2. **Read-Only Access**: Grant write access only if necessary
3. **Separate Keys**: Use different keys for different servers
4. **Rotate Keys**: Periodically rotate deploy keys
5. **Audit Access**: Regularly review deploy key usage

## Useful Git Commands

```bash
# Check remote URL
git remote -v

# Change remote URL
git remote set-url origin NEW_URL

# Check current branch
git branch

# Switch branch
git checkout BRANCH_NAME

# Fetch without merging
git fetch origin

# Reset to remote state (careful!)
git reset --hard origin/main

# View recent commits
git log --oneline -10

# Check git status
git status
```
