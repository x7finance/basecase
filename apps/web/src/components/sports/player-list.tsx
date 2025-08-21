'use client';

import type { Player } from '@basecase/sports';
import Image from 'next/image';
import { Loader } from '@/components/ui/loader';

type PlayerListProps = {
  players: Player[];
  loading?: boolean;
  hasTeamSelected: boolean;
};

export function PlayerList({
  players,
  loading,
  hasTeamSelected,
}: PlayerListProps) {
  if (!hasTeamSelected) {
    return <div className="px-2 py-1 text-xs text-zinc-400">Select a team</div>;
  }

  if (loading) {
    return (
      <div className="flex justify-center px-2 py-4">
        <Loader size="sm" />
      </div>
    );
  }

  if (players.length === 0) {
    return <div className="px-2 py-1 text-xs text-zinc-400">No players</div>;
  }

  return (
    <>
      {players.map((player) => (
        <div
          className="flex items-center gap-2 border-zinc-100 border-b px-2 py-0.5 text-xs last:border-0 hover:bg-zinc-50"
          key={player.idPlayer}
        >
          {player.strThumb && (
            <Image
              alt=""
              className="h-6 w-6 flex-shrink-0 rounded-sm object-cover"
              height={24}
              src={player.strThumb}
              width={24}
            />
          )}
          <div className="min-w-0 flex-1">
            <div className="truncate text-zinc-900">{player.strPlayer}</div>
            {player.strPosition && (
              <div
                className="truncate text-zinc-500"
                style={{ fontSize: '10px' }}
              >
                {player.strPosition}
              </div>
            )}
          </div>
        </div>
      ))}
    </>
  );
}
