import { sportsApi } from './sports-service';

// Utility function to run service methods and handle errors for API routes
export const runEffectSafe = async <T>(
  serviceMethod: () => Promise<T>
): Promise<{ success: true; data: T } | { success: false; error: string }> => {
  try {
    const result = await serviceMethod();
    return { success: true, data: result };
  } catch (error) {
    const errorMessage =
      error instanceof Error ? error.message : 'Unknown error occurred';
    return { success: false, error: errorMessage };
  }
};

// Export service methods for direct use in API routes
export const getAllLeagues = () => sportsApi.getAllLeagues();
export const getLeagueById = (id: string) => sportsApi.getLeagueById(id);
export const getTeamsByLeague = (leagueId: string) =>
  sportsApi.getTeamsByLeague(leagueId);
export const getTeamById = (teamId: string) => sportsApi.getTeamById(teamId);
export const getPlayersByTeam = (teamId: string) =>
  sportsApi.getPlayersByTeam(teamId);
export const getPlayerById = (playerId: string) =>
  sportsApi.getPlayerById(playerId);
export const searchTeams = (query: string) => sportsApi.searchTeams(query);
export const searchPlayers = (query: string) => sportsApi.searchPlayers(query);
