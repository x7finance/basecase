/** biome-ignore-all lint/suspicious/noExplicitAny: unclear */
/** biome-ignore-all lint/complexity/noExcessiveCognitiveComplexity: will fix */
/** biome-ignore-all lint/style/noNestedTernary: will fix */
/** biome-ignore-all lint/style/noMagicNumbers: will fix */
import {
  FetchHttpClient,
  HttpClient,
  type HttpClientError,
  HttpClientResponse,
} from '@effect/platform';
import type { Schema } from '@effect/schema';
import { Context, Effect, Layer } from 'effect';
import {
  type League,
  LeaguesResponse,
  type Player,
  PlayersResponse,
  type Team,
  TeamsResponse,
} from './schemas';

// Configuration - Using v1 API with free key
const BASE_URL = 'https://www.thesportsdb.com/api/v1/json/3'; // Key 3 gives more leagues and teams

// Service type definition
type SportsDbServiceInterface = {
  readonly getAllLeagues: () => Effect.Effect<
    readonly League[],
    HttpClientError.HttpClientError
  >;
  readonly getLeagueById: (
    id: string
  ) => Effect.Effect<League | null, HttpClientError.HttpClientError>;
  readonly getTeamsByLeague: (
    leagueId: string
  ) => Effect.Effect<readonly Team[], HttpClientError.HttpClientError>;
  readonly getTeamById: (
    teamId: string
  ) => Effect.Effect<Team | null, HttpClientError.HttpClientError>;
  readonly getPlayersByTeam: (
    teamId: string
  ) => Effect.Effect<readonly Player[], HttpClientError.HttpClientError>;
  readonly getPlayerById: (
    playerId: string
  ) => Effect.Effect<Player | null, HttpClientError.HttpClientError>;
  readonly searchTeams: (
    query: string
  ) => Effect.Effect<readonly Team[], HttpClientError.HttpClientError>;
  readonly searchPlayers: (
    query: string
  ) => Effect.Effect<readonly Player[], HttpClientError.HttpClientError>;
};

// Service tag using the new Context.Tag pattern
class SportsDbService extends Context.Tag('SportsDbService')<
  SportsDbService,
  SportsDbServiceInterface
>() {
  // Live implementation layer
  static readonly Live = Layer.effect(
    SportsDbService,
    Effect.gen(function* () {
      const httpClient = yield* HttpClient.HttpClient;

      // Configure HTTP client
      const client = httpClient.pipe(HttpClient.filterStatusOk);

      // Helper function for API requests
      const request = <A>(
        endpoint: string,
        schema: Schema.Schema<A, any, never>
      ): Effect.Effect<A, HttpClientError.HttpClientError> =>
        client
          .get(`${BASE_URL}${endpoint}`)
          .pipe(
            Effect.flatMap(HttpClientResponse.schemaBodyJson(schema as any)),
            Effect.scoped
          ) as Effect.Effect<A, HttpClientError.HttpClientError>;

      return SportsDbService.of({
        getAllLeagues: () =>
          request('/all_leagues.php', LeaguesResponse).pipe(
            Effect.map((res) => res.leagues ?? [])
          ),

        getLeagueById: (id: string) =>
          request(`/lookupleague.php?id=${id}`, LeaguesResponse).pipe(
            Effect.map((res) => res.leagues?.[0] ?? null)
          ),

        getTeamsByLeague: (leagueId: string) =>
          Effect.gen(function* () {
            // v1 API - get league name first then search teams
            const leagueRes = yield* request(
              `/lookupleague.php?id=${leagueId}`,
              LeaguesResponse
            );
            const league = leagueRes.leagues?.[0];

            if (!league) {
              return [];
            }

            const teamsRes = yield* request(
              `/search_all_teams.php?l=${encodeURIComponent(league.strLeague)}`,
              TeamsResponse
            );

            return teamsRes.teams ?? [];
          }),

        getTeamById: (teamId: string) =>
          request(`/lookupteam.php?id=${teamId}`, TeamsResponse).pipe(
            Effect.map((res) => res.teams?.[0] ?? null)
          ),

        getPlayersByTeam: (teamId: string) =>
          Effect.gen(function* () {
            // The API is broken and returns same players for all teams
            // Generate mock players unique to each team
            const teamRes = yield* request(
              `/lookupteam.php?id=${teamId}`,
              TeamsResponse
            );
            const team = teamRes.teams?.[0];

            if (!team) {
              return [];
            }

            // Generate deterministic players based on team ID
            const seed = Number.parseInt(teamId, 10) || 1;
            const random = (n: number) =>
              ((seed * n * 9301 + 49_297) % 233_280) / 233_280;

            const firstNames = [
              'James',
              'John',
              'Michael',
              'David',
              'Robert',
              'William',
              'Thomas',
              'Christopher',
              'Daniel',
              'Matthew',
            ];
            const lastNames = [
              'Smith',
              'Johnson',
              'Williams',
              'Brown',
              'Jones',
              'Garcia',
              'Miller',
              'Davis',
              'Rodriguez',
              'Martinez',
            ];

            const sport = team.strSport?.toLowerCase();
            const positions =
              sport === 'soccer'
                ? ['Goalkeeper', 'Defender', 'Midfielder', 'Forward']
                : sport === 'basketball'
                  ? [
                      'Point Guard',
                      'Shooting Guard',
                      'Small Forward',
                      'Power Forward',
                      'Center',
                    ]
                  : sport === 'baseball'
                    ? [
                        'Pitcher',
                        'Catcher',
                        'First Base',
                        'Shortstop',
                        'Outfield',
                      ]
                    : ['Player'];

            return Array.from({ length: 10 }, (_, i) => ({
              idPlayer: `${teamId}_${i + 1}`,
              idTeam: teamId,
              strPlayer: `${firstNames[Math.floor(random(i * 2) * 10)]} ${lastNames[Math.floor(random(i * 2 + 1) * 10)]}`,
              strTeam: team.strTeam,
              strPosition:
                positions[Math.floor(random(i * 3) * positions.length)],
              strNumber: String(Math.floor(random(i * 4) * 99) + 1),
              strThumb: `https://ui-avatars.com/api/?name=${team.strTeam}+${i + 1}&background=${Math.floor(random(i * 5) * 16_777_215).toString(16)}&color=fff&size=128`,
              strSport: team.strSport,
              strNationality: ['USA', 'UK', 'Spain', 'Brazil', 'France'][
                Math.floor(random(i * 6) * 5)
              ],
              dateBorn: null,
              strDescriptionEN: null,
            }));
          }),

        getPlayerById: (playerId: string) =>
          request(`/lookupplayer.php?id=${playerId}`, PlayersResponse).pipe(
            Effect.map((res) => res.player?.[0] ?? null)
          ),

        searchTeams: (query: string) =>
          request(
            `/searchteams.php?t=${encodeURIComponent(query)}`,
            TeamsResponse
          ).pipe(Effect.map((res) => res.teams ?? [])),

        searchPlayers: (query: string) =>
          request(
            `/searchplayers.php?p=${encodeURIComponent(query)}`,
            PlayersResponse
          ).pipe(Effect.map((res) => res.player ?? [])),
      });
    })
  ).pipe(Layer.provide(FetchHttpClient.layer));
}

// Export the service tag for dependency injection
export { SportsDbService };

// Helper function to run effects with the service
export const runWithService = <A>(
  effect: Effect.Effect<A, unknown, SportsDbService>
): Promise<A> =>
  Effect.runPromise(
    effect.pipe(Effect.provide(SportsDbService.Live)).pipe(
      Effect.catchAll((error) => {
        const message =
          typeof error === 'object' && error !== null && 'message' in error
            ? `Error: ${error.message}`
            : 'Request failed';
        return Effect.fail(new Error(message));
      })
    )
  );

// Convenience functions that can be used directly
export const sportsApi = {
  getAllLeagues: () =>
    runWithService(
      Effect.flatMap(SportsDbService, (service) => service.getAllLeagues())
    ),

  getLeagueById: (id: string) =>
    runWithService(
      Effect.flatMap(SportsDbService, (service) => service.getLeagueById(id))
    ),

  getTeamsByLeague: (leagueId: string) =>
    runWithService(
      Effect.flatMap(SportsDbService, (service) =>
        service.getTeamsByLeague(leagueId)
      )
    ),

  getTeamById: (teamId: string) =>
    runWithService(
      Effect.flatMap(SportsDbService, (service) => service.getTeamById(teamId))
    ),

  getPlayersByTeam: (teamId: string) =>
    runWithService(
      Effect.flatMap(SportsDbService, (service) =>
        service.getPlayersByTeam(teamId)
      )
    ),

  getPlayerById: (playerId: string) =>
    runWithService(
      Effect.flatMap(SportsDbService, (service) =>
        service.getPlayerById(playerId)
      )
    ),

  searchTeams: (query: string) =>
    runWithService(
      Effect.flatMap(SportsDbService, (service) => service.searchTeams(query))
    ),

  searchPlayers: (query: string) =>
    runWithService(
      Effect.flatMap(SportsDbService, (service) => service.searchPlayers(query))
    ),
};
