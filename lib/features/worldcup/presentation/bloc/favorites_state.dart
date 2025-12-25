import 'package:equatable/equatable.dart';
import '../../domain/entities/entities.dart';

/// State for favorites/user preferences management
class FavoritesState extends Equatable {
  /// Current user preferences
  final UserPreferences preferences;

  /// Whether preferences are loading
  final bool isLoading;

  /// Error message if any
  final String? errorMessage;

  /// Favorite teams loaded from repository
  final List<NationalTeam> favoriteTeams;

  /// Favorite matches loaded from repository
  final List<WorldCupMatch> favoriteMatches;

  const FavoritesState({
    this.preferences = const UserPreferences(),
    this.isLoading = false,
    this.errorMessage,
    this.favoriteTeams = const [],
    this.favoriteMatches = const [],
  });

  @override
  List<Object?> get props => [
        preferences,
        isLoading,
        errorMessage,
        favoriteTeams,
        favoriteMatches,
      ];

  /// Initial state
  factory FavoritesState.initial() => const FavoritesState(isLoading: true);

  /// Check if a team is favorited
  bool isTeamFavorite(String teamCode) =>
      preferences.isTeamFavorite(teamCode);

  /// Check if a match is favorited
  bool isMatchFavorite(String matchId) =>
      preferences.isMatchFavorite(matchId);

  /// Number of favorite teams
  int get favoriteTeamCount => preferences.favoriteTeamCodes.length;

  /// Number of favorite matches
  int get favoriteMatchCount => preferences.favoriteMatchIds.length;

  /// Whether there are any favorites
  bool get hasFavorites => favoriteTeamCount > 0 || favoriteMatchCount > 0;

  /// Create a copy with updated fields
  FavoritesState copyWith({
    UserPreferences? preferences,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    List<NationalTeam>? favoriteTeams,
    List<WorldCupMatch>? favoriteMatches,
  }) {
    return FavoritesState(
      preferences: preferences ?? this.preferences,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      favoriteTeams: favoriteTeams ?? this.favoriteTeams,
      favoriteMatches: favoriteMatches ?? this.favoriteMatches,
    );
  }
}
