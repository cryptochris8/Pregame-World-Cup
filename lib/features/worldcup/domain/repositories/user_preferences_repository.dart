import '../entities/entities.dart';

/// Repository interface for user preferences (favorites, settings)
abstract class UserPreferencesRepository {
  /// Get current user preferences
  Future<UserPreferences> getPreferences();

  /// Save user preferences
  Future<void> savePreferences(UserPreferences preferences);

  /// Stream of preference changes
  Stream<UserPreferences> watchPreferences();

  /// Add a team to favorites
  Future<UserPreferences> addFavoriteTeam(String teamCode);

  /// Remove a team from favorites
  Future<UserPreferences> removeFavoriteTeam(String teamCode);

  /// Toggle team favorite status
  Future<UserPreferences> toggleFavoriteTeam(String teamCode);

  /// Add a match to favorites
  Future<UserPreferences> addFavoriteMatch(String matchId);

  /// Remove a match from favorites
  Future<UserPreferences> removeFavoriteMatch(String matchId);

  /// Toggle match favorite status
  Future<UserPreferences> toggleFavoriteMatch(String matchId);

  /// Check if team is favorited
  Future<bool> isTeamFavorite(String teamCode);

  /// Check if match is favorited
  Future<bool> isMatchFavorite(String matchId);

  /// Get list of favorite team codes
  Future<List<String>> getFavoriteTeamCodes();

  /// Get list of favorite match IDs
  Future<List<String>> getFavoriteMatchIds();

  /// Update notification settings
  Future<UserPreferences> updateNotificationSettings({
    bool? notifyFavoriteTeamMatches,
    bool? notifyLiveUpdates,
    bool? notifyGoals,
  });

  /// Clear all preferences (reset)
  Future<void> clearPreferences();
}
