import '../entities/national_team.dart';

/// Repository interface for National Team data
abstract class NationalTeamRepository {
  /// Fetches all qualified teams for World Cup 2026 (48 teams)
  Future<List<NationalTeam>> getAllTeams();

  /// Fetches teams by confederation (UEFA, CONMEBOL, etc.)
  Future<List<NationalTeam>> getTeamsByConfederation(Confederation confederation);

  /// Fetches teams in a specific group (A-L)
  Future<List<NationalTeam>> getTeamsByGroup(String groupLetter);

  /// Fetches a single team by FIFA code (e.g., "USA", "GER", "BRA")
  Future<NationalTeam?> getTeamByCode(String fifaCode);

  /// Fetches host nation teams (USA, Mexico, Canada)
  Future<List<NationalTeam>> getHostNations();

  /// Fetches teams sorted by FIFA ranking
  Future<List<NationalTeam>> getTeamsByRanking();

  /// Searches teams by name or code
  Future<List<NationalTeam>> searchTeams(String query);

  /// Fetches teams that have won World Cups before
  Future<List<NationalTeam>> getPreviousChampions();

  /// Updates a team's information
  Future<void> updateTeam(NationalTeam team);

  /// Refreshes team data from the API
  Future<List<NationalTeam>> refreshTeams();

  /// Clears the local cache of teams
  Future<void> clearCache();

  /// Stream of team updates (for live ranking changes, etc.)
  Stream<List<NationalTeam>> watchTeams();

  /// Stream of a specific team's updates
  Stream<NationalTeam?> watchTeam(String fifaCode);
}
