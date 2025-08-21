const { config } = require('dotenv');
const { resolve } = require('node:path');

// Load environment variables from .env file
const envPath = resolve(__dirname, '.env');
const result = config({ path: envPath });

if (result.error) {
  // biome-ignore lint/suspicious/noConsole: Need to log error if .env fails to load
  console.error('Failed to load .env file:', result.error);
}

module.exports = {
  apps: [
    {
      name: 'basecase',
      script: 'bun',
      args: 'run start:prod',
      cwd: './apps/web',
      env: {
        ...process.env, // Include all environment variables from .env
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
      kill_timeout: 5000,
      min_uptime: '10s',
      max_restarts: 10,
      env_production: {
        ...process.env, // Include all environment variables from .env
        NODE_ENV: 'production',
        BUN_ENV: 'production',
        PORT: 3001,
      },
    },
  ],
};
