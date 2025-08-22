#!/usr/bin/env node

// fetch is available globally in Node.js 18+

// InstantDB backend configuration
const INSTANT_APP_ID = '3f44e818-bbda-49ac-bce4-9e0af53827f8';
const INSTANT_ADMIN_TOKEN = '83726309-8173-46b3-9fd5-3a7297a48905';
const INSTANT_BASE_URL = 'http://localhost:8888';

// Define the schema that better-auth expects
const schema = {
  attrs: {
    // Better Auth entities
    users: {
      id: { type: "string", unique: true },
      name: { type: "string", optional: true },
      email: { type: "string", unique: true, indexed: true },
      emailVerified: { type: "boolean", optional: true },
      image: { type: "string", optional: true },
      createdAt: { type: "date" },
      updatedAt: { type: "date" }
    },
    sessions: {
      id: { type: "string", unique: true },
      token: { type: "string", unique: true },
      expiresAt: { type: "date", indexed: true },
      ipAddress: { type: "string", optional: true },
      userAgent: { type: "string", optional: true },
      userId: { type: "string", indexed: true },
      createdAt: { type: "date" },
      updatedAt: { type: "date" }
    },
    accounts: {
      id: { type: "string", unique: true },
      accountId: { type: "string" },
      providerId: { type: "string" },
      userId: { type: "string", indexed: true },
      accessToken: { type: "string", optional: true },
      refreshToken: { type: "string", optional: true },
      idToken: { type: "string", optional: true },
      accessTokenExpiresAt: { type: "date", optional: true },
      refreshTokenExpiresAt: { type: "date", optional: true },
      scope: { type: "string", optional: true },
      password: { type: "string", optional: true },
      createdAt: { type: "date" },
      updatedAt: { type: "date" }
    },
    verifications: {
      id: { type: "string", unique: true },
      identifier: { type: "string", indexed: true },
      value: { type: "string" },
      expiresAt: { type: "date", indexed: true },
      createdAt: { type: "date" },
      updatedAt: { type: "date" }
    },
    // Additional entities from our schema
    profiles: {
      id: { type: "string", unique: true },
      name: { type: "string" },
      image: { type: "string", optional: true },
      createdAt: { type: "date" },
      updatedAt: { type: "date" }
    }
  },
  links: {
    // Link sessions to users
    sessionsUser: {
      forward: {
        on: "sessions",
        has: "one",
        label: "user"
      },
      reverse: {
        on: "users",
        has: "many",
        label: "sessions"
      }
    },
    // Link accounts to users
    accountsUser: {
      forward: {
        on: "accounts",
        has: "one",
        label: "user"
      },
      reverse: {
        on: "users",
        has: "many",
        label: "accounts"
      }
    },
    // Link profiles to users
    profilesUser: {
      forward: {
        on: "profiles",
        has: "one",
        label: "user"
      },
      reverse: {
        on: "users",
        has: "one",
        label: "profile"
      }
    }
  }
};

async function migrateSchema() {
  console.log('🚀 Starting InstantDB schema migration...');
  console.log(`📍 Target: ${INSTANT_BASE_URL}`);
  console.log(`🔑 App ID: ${INSTANT_APP_ID}`);
  
  try {
    // First, check if the backend is accessible
    const healthCheck = await fetch(`${INSTANT_BASE_URL}/`);
    if (!healthCheck.ok) {
      throw new Error(`InstantDB backend not accessible at ${INSTANT_BASE_URL}`);
    }
    console.log('✅ InstantDB backend is accessible');
    
    // Try to push the schema via the admin API
    const response = await fetch(`${INSTANT_BASE_URL}/runtime/admin/migrate_schema`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${INSTANT_ADMIN_TOKEN}`
      },
      body: JSON.stringify({
        app_id: INSTANT_APP_ID,
        attrs: schema.attrs,
        links: schema.links
      })
    });
    
    if (response.ok) {
      const result = await response.text();
      console.log('✅ Schema migration successful!');
      console.log('Response:', result);
    } else {
      const error = await response.text();
      console.error('❌ Schema migration failed:', response.status, error);
      
      // If the admin endpoint doesn't exist, provide alternative instructions
      if (response.status === 404) {
        console.log('\n📝 Note: The automatic migration endpoint is not available.');
        console.log('The schema has been defined in the application code.');
        console.log('InstantDB will validate entities at runtime.');
        console.log('\nEntities defined:');
        Object.keys(schema.attrs).forEach(entity => {
          const fields = Object.keys(schema.attrs[entity]);
          console.log(`  - ${entity}: ${fields.join(', ')}`);
        });
      }
    }
  } catch (error) {
    console.error('❌ Migration error:', error.message);
    
    // Output the schema for manual reference
    console.log('\n📋 Schema definition for manual configuration:');
    console.log(JSON.stringify(schema, null, 2));
  }
}

// Run the migration
migrateSchema().catch(console.error);