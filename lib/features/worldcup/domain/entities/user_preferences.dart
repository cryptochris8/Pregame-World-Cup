import 'package:equatable/equatable.dart';

/// User preferences for World Cup features
/// Stores favorite teams, matches, and user settings
class UserPreferences extends Equatable {
  /// List of favorite team FIFA codes
  final List<String> favoriteTeamCodes;

  /// List of favorite match IDs
  final List<String> favoriteMatchIds;

  /// Whether to receive notifications for favorite team matches
  final bool notifyFavoriteTeamMatches;

  /// Whether to receive notifications for live match updates
  final bool notifyLiveUpdates;

  /// Whether to receive notifications for goals
  final bool notifyGoals;

  /// Preferred timezone for match times
  final String? preferredTimezone;

  /// Last updated timestamp
  final DateTime? updatedAt;

  const UserPreferences({
    this.favoriteTeamCodes = const [],
    this.favoriteMatchIds = const [],
    this.notifyFavoriteTeamMatches = true,
    this.notifyLiveUpdates = true,
    this.notifyGoals = true,
    this.preferredTimezone,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        favoriteTeamCodes,
        favoriteMatchIds,
        notifyFavoriteTeamMatches,
        notifyLiveUpdates,
        notifyGoals,
        preferredTimezone,
      ];

  /// Check if a team is favorited
  bool isTeamFavorite(String teamCode) =>
      favoriteTeamCodes.contains(teamCode.toUpperCase());

  /// Check if a match is favorited
  bool isMatchFavorite(String matchId) => favoriteMatchIds.contains(matchId);

  /// Create empty preferences
  factory UserPreferences.empty() => const UserPreferences();

  /// Create from JSON map
  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      favoriteTeamCodes: (map['favoriteTeamCodes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      favoriteMatchIds: (map['favoriteMatchIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      notifyFavoriteTeamMatches:
          map['notifyFavoriteTeamMatches'] as bool? ?? true,
      notifyLiveUpdates: map['notifyLiveUpdates'] as bool? ?? true,
      notifyGoals: map['notifyGoals'] as bool? ?? true,
      preferredTimezone: map['preferredTimezone'] as String?,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String)
          : null,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toMap() {
    return {
      'favoriteTeamCodes': favoriteTeamCodes,
      'favoriteMatchIds': favoriteMatchIds,
      'notifyFavoriteTeamMatches': notifyFavoriteTeamMatches,
      'notifyLiveUpdates': notifyLiveUpdates,
      'notifyGoals': notifyGoals,
      'preferredTimezone': preferredTimezone,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  UserPreferences copyWith({
    List<String>? favoriteTeamCodes,
    List<String>? favoriteMatchIds,
    bool? notifyFavoriteTeamMatches,
    bool? notifyLiveUpdates,
    bool? notifyGoals,
    String? preferredTimezone,
    DateTime? updatedAt,
  }) {
    return UserPreferences(
      favoriteTeamCodes: favoriteTeamCodes ?? this.favoriteTeamCodes,
      favoriteMatchIds: favoriteMatchIds ?? this.favoriteMatchIds,
      notifyFavoriteTeamMatches:
          notifyFavoriteTeamMatches ?? this.notifyFavoriteTeamMatches,
      notifyLiveUpdates: notifyLiveUpdates ?? this.notifyLiveUpdates,
      notifyGoals: notifyGoals ?? this.notifyGoals,
      preferredTimezone: preferredTimezone ?? this.preferredTimezone,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Add a team to favorites
  UserPreferences addFavoriteTeam(String teamCode) {
    if (isTeamFavorite(teamCode)) return this;
    return copyWith(
      favoriteTeamCodes: [...favoriteTeamCodes, teamCode.toUpperCase()],
      updatedAt: DateTime.now(),
    );
  }

  /// Remove a team from favorites
  UserPreferences removeFavoriteTeam(String teamCode) {
    return copyWith(
      favoriteTeamCodes: favoriteTeamCodes
          .where((code) => code.toUpperCase() != teamCode.toUpperCase())
          .toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Toggle team favorite status
  UserPreferences toggleFavoriteTeam(String teamCode) {
    if (isTeamFavorite(teamCode)) {
      return removeFavoriteTeam(teamCode);
    }
    return addFavoriteTeam(teamCode);
  }

  /// Add a match to favorites
  UserPreferences addFavoriteMatch(String matchId) {
    if (isMatchFavorite(matchId)) return this;
    return copyWith(
      favoriteMatchIds: [...favoriteMatchIds, matchId],
      updatedAt: DateTime.now(),
    );
  }

  /// Remove a match from favorites
  UserPreferences removeFavoriteMatch(String matchId) {
    return copyWith(
      favoriteMatchIds:
          favoriteMatchIds.where((id) => id != matchId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Toggle match favorite status
  UserPreferences toggleFavoriteMatch(String matchId) {
    if (isMatchFavorite(matchId)) {
      return removeFavoriteMatch(matchId);
    }
    return addFavoriteMatch(matchId);
  }
}
