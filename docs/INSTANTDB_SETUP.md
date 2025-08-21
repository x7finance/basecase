# InstantDB Setup & Migration Guide

## Initial Setup

When setting up the project with InstantDB for the first time:

1. **Add InstantDB credentials to .env**:

    ```bash
    INSTANT_APP_ID=your-app-id-here
    ```

2. **Run the setup command**:

    ```bash
    bun run setup
    ```

    This will:

    - Set up environment variables
    - Authenticate with InstantDB (if needed)
    - Apply initial schema migrations

## Automatic Schema Migrations

Schema migrations are now **automatic** and integrated into the development workflow:

-   **During Development**: Running `bun run dev` automatically checks and applies schema changes
-   **During Build**: Running `bun run build` also applies migrations
-   **Manual Migration**: Run `bun run migrate` to manually apply schema changes

## How It Works

1. **Automatic Detection**: The migration script checks for schema changes before starting the dev server
2. **Auto-confirmation**: Schema changes are automatically applied without manual confirmation
3. **Safe Failures**: If migration fails, the dev server still starts (won't block development)
4. **Environment Aware**: Only runs when `INSTANT_APP_ID` is configured

## Schema Location

The schema is defined in: `packages/database/src/schema.ts`

The root `instant.schema.ts` file re-exports this schema for InstantDB CLI compatibility.

## Ubuntu Server Deployment

For deployment on Ubuntu servers:

1. Ensure environment variables are set in `.env` or through your deployment platform
2. The migration runs automatically as part of the build process
3. No manual intervention needed after initial setup

## Troubleshooting

If migrations fail:

1. **Manual migration**: Run `bunx instant-cli@latest push schema` and confirm with `yes`
2. **Check authentication**: Run `bunx instant-cli@latest whoami` to verify authentication
3. **Re-authenticate if needed**: Run `bunx instant-cli@latest login`

## CI/CD Integration

For CI/CD pipelines, ensure:

1. `INSTANT_APP_ID` is set as an environment variable
2. Authentication is handled (use `INSTANT_CLI_AUTH_TOKEN` if available)
3. Run `bun run build` which includes migrations
