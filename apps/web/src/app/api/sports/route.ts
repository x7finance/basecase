import {
  getAllLeagues,
  getLeagueById,
  getPlayerById,
  getPlayersByTeam,
  getTeamById,
  getTeamsByLeague,
  runEffectSafe,
  searchPlayers,
  searchTeams,
} from '@basecase/sports/server';
import { type NextRequest, NextResponse } from 'next/server';

// Handler functions for each resource type
async function handleLeagues(id: string | null) {
  if (id) {
    return await runEffectSafe(() => getLeagueById(id));
  }
  return await runEffectSafe(getAllLeagues);
}

async function handleTeams(
  id: string | null,
  leagueId: string | null,
  query: string | null
) {
  if (id) {
    return await runEffectSafe(() => getTeamById(id));
  }
  if (leagueId) {
    return await runEffectSafe(() => getTeamsByLeague(leagueId));
  }
  if (query) {
    return await runEffectSafe(() => searchTeams(query));
  }
  return {
    success: false,
    error: 'League ID or search query required for teams',
  };
}

async function handlePlayers(
  id: string | null,
  teamId: string | null,
  query: string | null
) {
  if (id) {
    return await runEffectSafe(() => getPlayerById(id));
  }
  if (teamId) {
    return await runEffectSafe(() => getPlayersByTeam(teamId));
  }
  if (query) {
    return await runEffectSafe(() => searchPlayers(query));
  }
  return {
    success: false,
    error: 'Team ID or search query required for players',
  };
}

// Consolidated sports API endpoint
export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const resource = searchParams.get('resource');
  const id = searchParams.get('id');
  const query = searchParams.get('q');
  const leagueId = searchParams.get('leagueId');
  const teamId = searchParams.get('teamId');

  try {
    let result: { success: boolean; data?: unknown; error?: string };

    switch (resource) {
      case 'leagues':
        result = await handleLeagues(id);
        break;
      case 'teams':
        result = await handleTeams(id, leagueId, query);
        break;
      case 'players':
        result = await handlePlayers(id, teamId, query);
        break;
      default:
        return NextResponse.json(
          {
            success: false,
            error: 'Invalid resource. Use: leagues, teams, or players',
          },
          { status: 400 }
        );
    }

    if (!result.success) {
      return NextResponse.json(result, { status: 400 });
    }
    return NextResponse.json(result);
  } catch (error) {
    return NextResponse.json(
      {
        success: false,
        error:
          error instanceof Error ? error.message : 'Unknown error occurred',
      },
      { status: 500 }
    );
  }
}
