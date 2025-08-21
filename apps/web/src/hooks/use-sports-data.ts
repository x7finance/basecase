'use client';

import type { League, Player, Team } from '@basecase/sports';
import { useEffect, useState } from 'react';

export function useSportsData() {
  const [leagues, setLeagues] = useState<League[]>([]);
  const [teams, setTeams] = useState<Team[]>([]);
  const [players, setPlayers] = useState<Player[]>([]);
  const [selectedLeague, setSelectedLeague] = useState<League | null>(null);
  const [selectedTeam, setSelectedTeam] = useState<Team | null>(null);
  const [teamsLoading, setTeamsLoading] = useState(false);
  const [playersLoading, setPlayersLoading] = useState(false);
  const [leaguesLoading, setLeaguesLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');

  // Fetch leagues on mount
  useEffect(() => {
    setLeaguesLoading(true);
    fetch('/api/sports?resource=leagues')
      .then((res) => res.json())
      .then((data) => {
        if (data.success) {
          setLeagues(data.data);
        }
      })
      .finally(() => setLeaguesLoading(false));
  }, []);

  // Fetch teams when league is selected
  useEffect(() => {
    if (!selectedLeague) {
      setTeams([]);
      setSelectedTeam(null);
      return;
    }

    setTeamsLoading(true);
    setSelectedTeam(null); // Clear selected team when changing league
    setPlayers([]); // Clear players when changing league
    fetch(`/api/sports?resource=teams&leagueId=${selectedLeague.idLeague}`)
      .then((res) => res.json())
      .then((data) => {
        if (data.success) {
          setTeams(data.data);
        }
      })
      .finally(() => setTeamsLoading(false));
  }, [selectedLeague]);

  // Fetch players when team is selected
  useEffect(() => {
    if (!selectedTeam) {
      setPlayers([]);
      return;
    }

    setPlayersLoading(true);
    fetch(`/api/sports?resource=players&teamId=${selectedTeam.idTeam}`)
      .then((res) => res.json())
      .then((data) => {
        if (data.success) {
          setPlayers(data.data);
        }
      })
      .finally(() => setPlayersLoading(false));
  }, [selectedTeam]);

  const handleSearch = () => {
    if (!searchQuery.trim()) {
      return;
    }

    setTeamsLoading(true);
    fetch(`/api/sports?resource=teams&q=${encodeURIComponent(searchQuery)}`)
      .then((res) => res.json())
      .then((data) => {
        if (data.success) {
          setTeams(data.data);
          setSelectedLeague(null);
          setSelectedTeam(null);
        }
      })
      .finally(() => setTeamsLoading(false));
  };

  return {
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
  };
}
