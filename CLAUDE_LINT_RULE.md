# Linting and Type Checking Rule

## IMPORTANT: Always run these checks before finishing any task

Before completing any coding task, you MUST:

1. **Run Biome linting and auto-fix:**

    ```bash
    bunx biome check --write --unsafe .
    ```

    This will fix most formatting and linting issues automatically.

2. **Check TypeScript types:**

    ```bash
    bunx tsc --noEmit
    ```

    This ensures there are no type errors in the codebase.

3. **Fix any remaining issues:**
    - If Biome reports errors that can't be auto-fixed, manually fix them
    - If TypeScript reports errors (outside of node_modules), fix them
    - Common issues to watch for:
        - Unused imports/variables
        - Missing type annotations
        - Incorrect parameter types
        - Console statements (remove unless necessary)

## Why this matters:

-   Clean, linted code is easier to maintain
-   Type safety prevents runtime errors
-   Consistent formatting improves readability
-   CI/CD pipelines often fail on linting/type errors

## Note on current state:

-   Some Biome rules like `noNestedTernary` and CSS at-rules warnings can be ignored if they're stylistic preferences
-   TypeScript errors in node_modules (especially from Effect and Zod) can be ignored as they're external dependencies
-   Focus on fixing errors in the app code under `apps/`, `packages/`, and root files
