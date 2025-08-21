'use client';

import type { Team } from '@basecase/sports';
import { Loader } from '@/components/ui/loader';

type TeamListProps = {
  teams: Team[];
  selectedTeam: Team | null;
  onSelectTeam: (team: Team) => void;
  loading?: boolean;
  hasLeagueSelected: boolean;
};

export function TeamList({
  teams,
  selectedTeam,
  onSelectTeam,
  loading,
  hasLeagueSelected,
}: TeamListProps) {
  if (!hasLeagueSelected) {
    return (
      <div className="px-2 py-1 text-xs text-zinc-400">Select a league</div>
    );
  }

  if (loading) {
    return (
      <div className="flex justify-center px-2 py-4">
        <Loader size="sm" />
      </div>
    );
  }

  if (teams.length === 0) {
    return <div className="px-2 py-1 text-xs text-zinc-400">No teams</div>;
  }

  return (
    <>
      {teams.map((team) => (
        <button
          className={`w-full border-zinc-100 border-b px-2 py-0.5 text-left text-xs last:border-0 hover:bg-zinc-50 ${
            selectedTeam?.idTeam === team.idTeam ? 'bg-zinc-100' : ''
          }`}
          key={team.idTeam}
          onClick={() => onSelectTeam(team)}
          type="button"
        >
          <div className="truncate text-zinc-900">{team.strTeam}</div>
          {team.strStadium && (
            <div
              className="truncate text-zinc-500"
              style={{ fontSize: '10px' }}
            >
              {team.strStadium}
            </div>
          )}
        </button>
      ))}
    </>
  );
}
