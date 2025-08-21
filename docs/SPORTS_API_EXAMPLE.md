# TheSportsDB API Integration with Effect-TS

A robust, type-safe sports data API integration using Effect-TS in your Basecase project.

## Architecture Overview

This implementation follows Effect-TS patterns for functional programming with proper error handling, type safety, and composability.

### Key Features

-   **Type Safety**: Full TypeScript schemas for all API responses
-   **Error Handling**: Robust error handling with Effect-TS
-   **Modular Design**: Separate client/server utilities
-   **Caching**: Built-in caching for API responses
-   **Rate Limiting**: Respects API rate limits

## API Endpoints

All endpoints are available at `http://localhost:3001/api/sports/`

### League Endpoints

```bash
# Get all leagues
curl http://localhost:3001/api/sports/leagues

# Get league by ID
curl http://localhost:3001/api/sports/leagues/4328

# Get teams in a league
curl http://localhost:3001/api/sports/leagues/4328/teams
```

### Team Endpoints

```bash
# Search for teams
curl "http://localhost:3001/api/sports/search/teams?q=Arsenal"

# Get team by ID
curl http://localhost:3001/api/sports/teams/133604

# Get players in a team
curl http://localhost:3001/api/sports/teams/133604/players
```

### Player Endpoints

```bash
# Search for players
curl "http://localhost:3001/api/sports/search/players?q=Harry%20Kane"

# Get player by ID
curl http://localhost:3001/api/sports/players/34145937
```

## Using Effect-TS in Your Code

### Server-Side Usage

```typescript
import { Effect } from "effect"
import { getAllLeagues, searchTeams, getTeamById, runEffect } from "@basecase/sports/server"

// Using the Effect-TS service
const program = Effect.gen(function* () {
    // Get all leagues
    const leagues = yield* getAllLeagues()

    // Search for teams
    const teams = yield* searchTeams("Arsenal")

    // Get team details
    const team = yield* getTeamById("133604")

    return { leagues, teams, team }
})

// Run the effect
const result = await runEffect(program)
```

### Client-Side Usage

```typescript
import { sportsClient } from "@basecase/sports/client"

// Simple promise-based client
async function fetchSportsData() {
    // Get all leagues
    const leagues = await sportsClient.getAllLeagues()

    // Search for teams
    const teams = await sportsClient.searchTeams("Arsenal")

    // Get team details
    const team = await sportsClient.getTeamById("133604")

    return { leagues, teams, team }
}
```

### React Component Example

```tsx
"use client"

import { useState, useEffect } from "react"
import { sportsClient } from "@basecase/sports/client"
import type { Team, League } from "@basecase/sports"

export function SportsData() {
    const [leagues, setLeagues] = useState<League[]>([])
    const [selectedLeague, setSelectedLeague] = useState<string>("")
    const [teams, setTeams] = useState<Team[]>([])
    const [loading, setLoading] = useState(false)
    const [error, setError] = useState<string | null>(null)

    // Fetch leagues on mount
    useEffect(() => {
        sportsClient
            .getAllLeagues()
            .then((result) => {
                if (result.success) {
                    setLeagues(result.data)
                }
            })
            .catch((err) => setError(err.message))
    }, [])

    // Fetch teams when league is selected
    useEffect(() => {
        if (!selectedLeague) return

        setLoading(true)
        sportsClient
            .getTeamsByLeague(selectedLeague)
            .then((result) => {
                if (result.success) {
                    setTeams(result.data)
                }
            })
            .catch((err) => setError(err.message))
            .finally(() => setLoading(false))
    }, [selectedLeague])

    return (
        <div>
            <select onChange={(e) => setSelectedLeague(e.target.value)}>
                <option value="">Select a league</option>
                {leagues.map((league) => (
                    <option key={league.idLeague} value={league.idLeague}>
                        {league.strLeague}
                    </option>
                ))}
            </select>

            {loading && <p>Loading teams...</p>}
            {error && <p>Error: {error}</p>}

            <div className="grid grid-cols-3 gap-4">
                {teams.map((team) => (
                    <div key={team.idTeam} className="border p-4">
                        <h3>{team.strTeam}</h3>
                        <p>{team.strStadium}</p>
                    </div>
                ))}
            </div>
        </div>
    )
}
```

## Advanced Effect-TS Usage

### Composing Multiple API Calls

```typescript
import { Effect, pipe } from "effect"
import * as SportsService from "@basecase/sports/service"

const getLeagueWithTeams = (leagueId: string) =>
    pipe(
        Effect.all({
            league: SportsService.getLeagueById(leagueId),
            teams: SportsService.getTeamsByLeague(leagueId),
        }),
        Effect.map(({ league, teams }) => ({
            ...league,
            teams,
        }))
    )

// Usage
const enrichedLeague = await runEffect(getLeagueWithTeams("4328"))
```

### Error Handling with Effect

```typescript
import { Effect, Either } from "effect"
import { SportsError } from "@basecase/sports"

const safeSearch = (query: string) =>
    pipe(
        searchTeams(query),
        Effect.catchTag("SportsError", (error) =>
            Effect.succeed({
                success: false,
                error: error.message,
            })
        )
    )
```

### Using with React Query

```typescript
import { useQuery } from "@tanstack/react-query"
import { sportsClient } from "@basecase/sports/client"

export function useLeagues() {
    return useQuery({
        queryKey: ["leagues"],
        queryFn: () => sportsClient.getAllLeagues(),
        staleTime: 5 * 60 * 1000, // 5 minutes
    })
}

export function useTeams(leagueId: string) {
    return useQuery({
        queryKey: ["teams", leagueId],
        queryFn: () => sportsClient.getTeamsByLeague(leagueId),
        enabled: !!leagueId,
    })
}
```

## Type Definitions

All types are fully typed and exported from `@basecase/sports`:

```typescript
import type { League, Team, Player, Event, ApiResponse, SportsError } from "@basecase/sports"
```

## Error Handling

The API returns consistent error responses:

```typescript
interface ApiErrorResponse {
    success: false
    error: string
    details?: unknown
}

interface ApiSuccessResponse<T> {
    success: true
    data: T
}

type ApiResponse<T> = ApiSuccessResponse<T> | ApiErrorResponse
```

## Rate Limiting

The free API key has a rate limit of 30 requests per minute. The implementation includes:

-   Automatic retry with exponential backoff
-   Rate limit headers in responses
-   Proper error messages when limits are exceeded

## Testing

```typescript
import { describe, it, expect } from "bun:test"
import { runEffect, searchTeams } from "@basecase/sports/server"

describe("Sports API", () => {
    it("should search for teams", async () => {
        const result = await runEffect(searchTeams("Arsenal"))
        expect(result.success).toBe(true)
        expect(result.data).toBeInstanceOf(Array)
        expect(result.data[0].strTeam).toContain("Arsenal")
    })
})
```

## Environment Variables

The API key is configured in the sports package. To use a premium key:

```typescript
// packages/sports/src/config.ts
export const API_CONFIG = {
    apiKey: process.env.SPORTS_API_KEY || "3", // Use free key by default
    baseUrl: "https://www.thesportsdb.com/api/v1/json",
}
```

## Deployment Considerations

1. **API Key Security**: Store API keys in environment variables
2. **Caching**: Implement Redis or similar for production caching
3. **Rate Limiting**: Implement your own rate limiting to protect your endpoints
4. **Error Monitoring**: Use services like Sentry for error tracking
5. **Performance**: Consider implementing response caching and CDN

## Contributing

To extend the API integration:

1. Add new schemas in `packages/sports/src/schemas.ts`
2. Add service methods in `packages/sports/src/service.ts`
3. Export from server/client utilities
4. Create corresponding API routes in `apps/web/src/app/api/sports/`

## Resources

-   [TheSportsDB API Documentation](https://www.thesportsdb.com/api.php)
-   [Effect-TS Documentation](https://effect.website/)
-   [Next.js Route Handlers](https://nextjs.org/docs/app/building-your-application/routing/route-handlers)
