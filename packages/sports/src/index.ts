/** biome-ignore-all lint/performance/noBarrelFile: because */

export type { ApiResponse } from './client';

export { createApiClient, sportsApi as clientApi } from './client';

export type {
  League as LeagueType,
  LeaguesResponse as LeaguesResponseType,
  Player as PlayerType,
  PlayersResponse as PlayersResponseType,
  Team as TeamType,
  TeamsResponse as TeamsResponseType,
} from './schemas';

export {
  League,
  LeaguesResponse,
  Player,
  PlayersResponse,
  Team,
  TeamsResponse,
} from './schemas';

export {
  getAllLeagues,
  getLeagueById,
  getPlayerById,
  getPlayersByTeam,
  getTeamById,
  getTeamsByLeague,
  runEffectSafe,
  searchPlayers,
  searchTeams,
} from './server';

// Export the new Effect service
export { runWithService, SportsDbService, sportsApi } from './sports-service';
