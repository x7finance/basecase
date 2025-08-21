'use client';

import { LeagueList } from '@/components/sports/league-list';
import { PlayerList } from '@/components/sports/player-list';
import { TeamList } from '@/components/sports/team-list';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { useSportsData } from '@/hooks/use-sports-data';

export default function SportsPage() {
  const {
    leagues,
    teams,
    players,
    selectedLeague,
    selectedTeam,
    teamsLoading,
    playersLoading,
    leaguesLoading,
    searchQuery,
    setSelectedLeague,
    setSelectedTeam,
    setSearchQuery,
    handleSearch,
  } = useSportsData();

  return (
    <div className="bg-white">
      <div className="pt-4 pb-16">
        <div className="mx-auto max-w-[650px] px-4">
          <Card variant="primary">
            <div className="flex items-center justify-between py-2">
              <div>
                <h1 className="font-bold text-xs text-zinc-900">Sports Data</h1>
                <p className="text-xs text-zinc-600">
                  Browse leagues, teams, and players
                </p>
              </div>
              <Badge size="sm" variant="muted">
                DEMO
              </Badge>
            </div>
          </Card>

          <div className="mt-2 hidden gap-2">
            <Input
              className="h-8 flex-1 border-zinc-300 text-xs focus:border-zinc-400"
              onChange={(e) => setSearchQuery(e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && handleSearch()}
              placeholder="Search teams..."
              type="text"
              value={searchQuery}
            />
            <Button
              className="h-8 px-3 text-xs"
              onClick={handleSearch}
              variant="secondary"
            >
              Search
            </Button>
          </div>

          <div className="mt-2 grid grid-cols-3 gap-2">
            {/* Leagues Column */}
            <div className="flex flex-col">
              <div className="flex h-7 items-center justify-between border-black border-b-2 px-2">
                <h2 className="font-medium text-xs text-zinc-900">
                  Leagues{' '}
                  {leagues.length > 0 && (
                    <span className="font-mono font-normal">
                      ({leagues.length})
                    </span>
                  )}
                </h2>
              </div>
              <div className="custom-scrollbar h-96 overflow-y-auto border-zinc-200 border-b">
                <LeagueList
                  leagues={leagues}
                  loading={leaguesLoading}
                  onSelectLeague={setSelectedLeague}
                  selectedLeague={selectedLeague}
                />
              </div>
            </div>

            {/* Teams Column */}
            <div className="flex flex-col">
              <div className="flex h-7 items-center justify-between border-zinc-400 border-b px-2">
                <h2 className="font-medium text-xs text-zinc-900">
                  Teams{' '}
                  {teams.length > 0 && (
                    <span className="font-mono font-normal">
                      ({teams.length})
                    </span>
                  )}
                </h2>
              </div>
              <div className="custom-scrollbar h-96 overflow-y-auto border-zinc-200 border-b">
                <TeamList
                  hasLeagueSelected={!!selectedLeague}
                  loading={teamsLoading}
                  onSelectTeam={setSelectedTeam}
                  selectedTeam={selectedTeam}
                  teams={teams}
                />
              </div>
            </div>

            {/* Players Column */}
            <div className="flex flex-col">
              <div className="flex h-7 items-center justify-between border-zinc-400 border-b px-2">
                <h2 className="font-medium text-xs text-zinc-900">
                  Players{' '}
                  {players.length > 0 && (
                    <span className="font-mono font-normal">
                      ({players.length})
                    </span>
                  )}
                </h2>
              </div>
              <div className="custom-scrollbar h-96 overflow-y-auto border-zinc-200 border-b">
                <PlayerList
                  hasTeamSelected={!!selectedTeam}
                  loading={playersLoading}
                  players={players}
                />
              </div>
            </div>
          </div>

          {/* Compact Stats Bar */}
          <div className="mt-2 flex gap-3 font-mono text-xs text-zinc-500">
            {selectedLeague && <span>{selectedLeague.strLeague}</span>}
            {selectedTeam && <span>• {selectedTeam.strTeam}</span>}
          </div>
        </div>
      </div>
    </div>
  );
}
