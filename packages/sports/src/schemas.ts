import { Schema } from '@effect/schema';

// Flexible schemas for TheSportsDB API responses
// Using NullOr for fields that can be null

export const League = Schema.Struct({
  idLeague: Schema.String,
  strLeague: Schema.String,
  strSport: Schema.String,
});

export const Team = Schema.Struct({
  idTeam: Schema.String,
  strTeam: Schema.String,
  strSport: Schema.String,
  strLeague: Schema.String,
  idLeague: Schema.String,
});

export const Player = Schema.Struct({
  idPlayer: Schema.String,
  idTeam: Schema.String,
  strPlayer: Schema.String,
});

export const LeaguesResponse = Schema.Struct({
  leagues: Schema.NullOr(Schema.Array(League)),
});

export const TeamsResponse = Schema.Struct({
  teams: Schema.NullOr(Schema.Array(Team)),
});

export const PlayersResponse = Schema.Struct({
  player: Schema.NullOr(Schema.Array(Player)),
});

// Export types
export type League = Schema.Schema.Type<typeof League>;
export type Team = Schema.Schema.Type<typeof Team>;
export type Player = Schema.Schema.Type<typeof Player>;
export type LeaguesResponse = Schema.Schema.Type<typeof LeaguesResponse>;
export type TeamsResponse = Schema.Schema.Type<typeof TeamsResponse>;
export type PlayersResponse = Schema.Schema.Type<typeof PlayersResponse>;
