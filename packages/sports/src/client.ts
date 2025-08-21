// Client-side utilities for working with sports data
// This could include React hooks, query functions, etc.

export type ApiResponse<T> =
  | { success: true; data: T }
  | { success: false; error: string };

// Base API client functions
export const createApiClient = (baseUrl = '/api/sports') => {
  const fetchJson = async <T>(endpoint: string): Promise<ApiResponse<T>> => {
    try {
      const response = await fetch(`${baseUrl}${endpoint}`);

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      const data = await response.json();
      return data as ApiResponse<T>;
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Network error';
      return { success: false, error: message };
    }
  };

  return {
    getAllLeagues: () => fetchJson('?resource=leagues'),
    getLeagueById: (id: string) => fetchJson(`?resource=leagues&id=${id}`),
    getTeamsByLeague: (leagueId: string) =>
      fetchJson(`?resource=teams&leagueId=${leagueId}`),
    getTeamById: (teamId: string) => fetchJson(`?resource=teams&id=${teamId}`),
    getPlayersByTeam: (teamId: string) =>
      fetchJson(`?resource=players&teamId=${teamId}`),
    getPlayerById: (playerId: string) =>
      fetchJson(`?resource=players&id=${playerId}`),
    searchTeams: (query: string) =>
      fetchJson(`?resource=teams&q=${encodeURIComponent(query)}`),
    searchPlayers: (query: string) =>
      fetchJson(`?resource=players&q=${encodeURIComponent(query)}`),
  };
};

// Default API client instance
export const sportsApi = createApiClient();
