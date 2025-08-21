import { resolve } from 'node:path';
import { config } from 'dotenv';
import type { NextConfig } from 'next';

// Load environment variables from root .env file
const rootDir = resolve(__dirname, '../../');
const envPath = resolve(rootDir, '.env');
config({ path: envPath });

const nextConfig: NextConfig = {
  eslint: { ignoreDuringBuilds: true },
  typescript: { ignoreBuildErrors: true },
  productionBrowserSourceMaps: true,
  poweredByHeader: false,
  reactStrictMode: true,
  // Configure external image domains
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'lh3.googleusercontent.com',
        pathname: '/**',
      },
      {
        protocol: 'https',
        hostname: 'www.thesportsdb.com',
        pathname: '/**',
      },
      {
        protocol: 'https',
        hostname: 'r2.thesportsdb.com',
        pathname: '/**',
      },
      {
        protocol: 'https',
        hostname: 'ui-avatars.com',
        pathname: '/**',
      },
    ],
  },
  // Pass through all NEXT_PUBLIC_ env vars
  env: {
    NEXT_PUBLIC_INSTANT_APP_ID: process.env.NEXT_PUBLIC_INSTANT_APP_ID,
    NEXT_PUBLIC_APP_URL: process.env.NEXT_PUBLIC_APP_URL,
    NEXT_PUBLIC_GA_MEASUREMENT_ID: process.env.NEXT_PUBLIC_GA_MEASUREMENT_ID,
    NEXT_PUBLIC_GOOGLE_CONFIGURED: process.env.NEXT_PUBLIC_GOOGLE_CONFIGURED,
    NEXT_PUBLIC_GITHUB_CONFIGURED: process.env.NEXT_PUBLIC_GITHUB_CONFIGURED,
  },
  experimental: {
    ppr: true,
    dynamicOnHover: true,
    reactCompiler: true,
    useCache: true,
    clientSegmentCache: true,
    turbopackPersistentCaching: true,
  },
  turbopack: {
    moduleIds: 'named',
    resolveExtensions: [
      '.mdx',
      '.tsx',
      '.ts',
      '.jsx',
      '.js',
      '.mjs',
      '.json',
      '.css',
    ],
  },
  headers() {
    return Promise.resolve([
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-XSS-Protection',
            value: '1; mode=block',
          },
          {
            key: 'Strict-Transport-Security',
            value: 'max-age=63072000; includeSubDomains; preload',
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'Access-Control-Allow-Methods',
            value: 'GET, POST, PUT, DELETE, OPTIONS',
          },
          {
            key: 'Referrer-Policy',
            value: 'strict-origin-when-cross-origin',
          },
          {
            key: 'Permissions-Policy',
            value: 'camera=(), microphone=(self), geolocation=()',
          },
        ],
      },
    ]);
  },
};

export default nextConfig;
