import '../entities/bracket.dart';
import '../entities/world_cup_match.dart';

/// Repository interface for World Cup Bracket (knockout stage) data
abstract class BracketRepository {
  /// Fetches the complete knockout bracket
  Future<WorldCupBracket> getBracket();

  /// Fetches matches for a specific knockout stage
  Future<List<BracketMatch>> getMatchesByStage(MatchStage stage);

  /// Fetches a specific bracket match by ID
  Future<BracketMatch?> getBracketMatchById(String matchId);

  /// Gets the path a team took through the knockout stage
  /// Returns list of matches from R32 to their last match
  Future<List<BracketMatch>> getTeamKnockoutPath(String teamCode);

  /// Gets upcoming knockout matches
  Future<List<BracketMatch>> getUpcomingKnockoutMatches({int limit = 8});

  /// Gets live knockout matches
  Future<List<BracketMatch>> getLiveKnockoutMatches();

  /// Gets completed knockout matches
  Future<List<BracketMatch>> getCompletedKnockoutMatches();

  /// Gets the next match after a completed match (where winner advances to)
  Future<BracketMatch?> getNextMatch(String matchId);

  /// Gets the semi-final matches
  Future<List<BracketMatch>> getSemiFinals();

  /// Gets the final match
  Future<BracketMatch?> getFinalMatch();

  /// Gets the third-place match
  Future<BracketMatch?> getThirdPlaceMatch();

  /// Updates a bracket match with new data
  Future<void> updateBracketMatch(BracketMatch match);

  /// Advances a team to the next round after a match completes
  Future<void> advanceTeam(String matchId, String winnerCode);

  /// Updates the full bracket
  Future<void> updateBracket(WorldCupBracket bracket);

  /// Refreshes bracket data from the API
  Future<WorldCupBracket> refreshBracket();

  /// Clears the local cache
  Future<void> clearCache();

  /// Stream of bracket updates
  Stream<WorldCupBracket> watchBracket();

  /// Stream of a specific match updates
  Stream<BracketMatch?> watchBracketMatch(String matchId);
}
