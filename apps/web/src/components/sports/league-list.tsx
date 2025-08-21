'use client';

import type { League } from '@basecase/sports/types';
import { Loader } from '@/components/ui/loader';

const MAX_VISIBLE_LEAGUES = 50;

type LeagueListProps = {
  leagues: League[];
  selectedLeague: League | null;
  onSelectLeague: (league: League) => void;
  loading?: boolean;
};

export function LeagueList({
  leagues,
  selectedLeague,
  onSelectLeague,
  loading,
}: LeagueListProps) {
  if (loading) {
    return (
      <div className="flex justify-center px-2 py-4">
        <Loader size="sm" />
      </div>
    );
  }

  const visibleLeagues = leagues.slice(0, MAX_VISIBLE_LEAGUES);

  return (
    <>
      {visibleLeagues.map((league) => (
        <button
          className={`w-full border-zinc-100 border-b px-2 py-0.5 text-left text-xs last:border-0 hover:bg-zinc-50 ${
            selectedLeague?.idLeague === league.idLeague ? 'bg-zinc-100' : ''
          }`}
          key={league.idLeague}
          onClick={() => onSelectLeague(league)}
          type="button"
        >
          <div className="truncate text-zinc-900">{league.strLeague}</div>
          {league.strSport && (
            <div
              className="truncate text-zinc-500"
              style={{ fontSize: '10px' }}
            >
              {league.strSport}
            </div>
          )}
        </button>
      ))}
    </>
  );
}
