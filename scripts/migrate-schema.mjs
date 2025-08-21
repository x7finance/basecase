#!/usr/bin/env node

import { spawn } from 'node:child_process';
import { existsSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

// Load .env file if it exists
const envPath = join(process.cwd(), '.env');
if (existsSync(envPath)) {
  const envContent = readFileSync(envPath, 'utf8');
  for (const line of envContent.split('\n')) {
    const [key, value] = line.split('=');
    if (key && value && !process.env[key]) {
      process.env[key] = value.trim();
    }
  }
}

const SCHEMA_PATH = join(process.cwd(), 'instant.schema.ts');

// Check if schema file exists
if (!existsSync(SCHEMA_PATH)) {
  process.exit(0);
}

// Check if INSTANT_APP_ID is set
if (!process.env.INSTANT_APP_ID) {
  process.exit(0);
}

const child = spawn('bunx', ['instant-cli@latest', 'push', 'schema'], {
  stdio: ['pipe', 'pipe', 'pipe'],
});

let _output = '';

child.stdout.on('data', (data) => {
  const text = data.toString();
  _output += text;

  // Auto-confirm when prompted
  if (text.includes('OK to proceed?')) {
    // Check if there are changes in the accumulated output
    const hasChanges =
      _output.includes('ADD ') ||
      _output.includes('UPDATE ') ||
      _output.includes('DELETE ');
    child.stdin.write(hasChanges ? 'yes\n' : 'no\n');
  }

  // Show progress
  if (text.includes('✓') || text.includes('Successfully')) {
    process.stdout.write(text);
  }
});

child.stderr.on('data', (_data) => {
  // Ignore stderr output
});

child.on('close', (_code) => {
  // Always exit successfully regardless of schema changes
  process.exit(0);
});

child.on('error', (_err) => {
  process.exit(0);
});
