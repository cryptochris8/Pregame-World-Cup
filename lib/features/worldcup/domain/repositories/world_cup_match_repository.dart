import '../entities/world_cup_match.dart';

/// Repository interface for World Cup match data
abstract class WorldCupMatchRepository {
  /// Fetches all matches for the World Cup 2026 tournament
  /// Returns a list of all 104 matches
  Future<List<WorldCupMatch>> getAllMatches();

  /// Fetches matches by stage (group stage, round of 32, etc.)
  Future<List<WorldCupMatch>> getMatchesByStage(MatchStage stage);

  /// Fetches matches for a specific group (A-L)
  Future<List<WorldCupMatch>> getMatchesByGroup(String groupLetter);

  /// Fetches matches for a specific date
  Future<List<WorldCupMatch>> getMatchesByDate(DateTime date);

  /// Fetches matches for a specific team (by FIFA code)
  Future<List<WorldCupMatch>> getMatchesByTeam(String teamCode);

  /// Fetches matches at a specific venue
  Future<List<WorldCupMatch>> getMatchesByVenue(String venueId);

  /// Fetches a single match by ID
  Future<WorldCupMatch?> getMatchById(String matchId);

  /// Fetches upcoming matches (not yet completed)
  /// [limit] specifies the maximum number of matches to return
  Future<List<WorldCupMatch>> getUpcomingMatches({int limit = 10});

  /// Fetches live matches (currently in progress)
  Future<List<WorldCupMatch>> getLiveMatches();

  /// Fetches today's matches
  Future<List<WorldCupMatch>> getTodaysMatches();

  /// Fetches completed matches
  /// [limit] specifies the maximum number of matches to return
  Future<List<WorldCupMatch>> getCompletedMatches({int limit = 10});

  /// Fetches matches for a specific match day in group stage (1, 2, or 3)
  Future<List<WorldCupMatch>> getMatchesByGroupMatchDay(int matchDay);

  /// Updates a match with new data (for live score updates)
  Future<void> updateMatch(WorldCupMatch match);

  /// Refreshes match data from the API
  Future<List<WorldCupMatch>> refreshMatches();

  /// Clears the local cache of matches
  Future<void> clearCache();

  /// Stream of live match updates
  Stream<List<WorldCupMatch>> watchLiveMatches();

  /// Stream of a specific match updates
  Stream<WorldCupMatch?> watchMatch(String matchId);
}
