import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/user_preferences_repository.dart';
import '../../domain/repositories/national_team_repository.dart';
import '../../domain/repositories/world_cup_match_repository.dart';
import 'favorites_state.dart';

/// Cubit for managing user favorites (teams and matches)
class FavoritesCubit extends Cubit<FavoritesState> {
  final UserPreferencesRepository _preferencesRepository;
  final NationalTeamRepository? _teamRepository;
  final WorldCupMatchRepository? _matchRepository;

  StreamSubscription<UserPreferences>? _preferencesSubscription;

  FavoritesCubit({
    required UserPreferencesRepository preferencesRepository,
    NationalTeamRepository? teamRepository,
    WorldCupMatchRepository? matchRepository,
  })  : _preferencesRepository = preferencesRepository,
        _teamRepository = teamRepository,
        _matchRepository = matchRepository,
        super(FavoritesState.initial());

  /// Initialize and load preferences
  Future<void> init() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final preferences = await _preferencesRepository.getPreferences();
      emit(state.copyWith(
        preferences: preferences,
        isLoading: false,
      ));

      // Load favorite teams and matches
      await _loadFavoriteEntities();

      // Subscribe to preference changes
      _subscribeToPreferences();
    } catch (e) {
      // Debug output removed
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load preferences: $e',
      ));
    }
  }

  /// Subscribe to preference changes
  void _subscribeToPreferences() {
    _preferencesSubscription?.cancel();
    _preferencesSubscription = _preferencesRepository.watchPreferences().listen(
      (preferences) {
        emit(state.copyWith(preferences: preferences));
        _loadFavoriteEntities();
      },
      onError: (e) {
        // Debug output removed
      },
    );
  }

  /// Load favorite teams and matches entities
  Future<void> _loadFavoriteEntities() async {
    // Load favorite teams
    final teamRepo = _teamRepository;
    if (teamRepo != null && state.preferences.favoriteTeamCodes.isNotEmpty) {
      try {
        final teams = <NationalTeam>[];
        for (final code in state.preferences.favoriteTeamCodes) {
          final team = await teamRepo.getTeamByCode(code);
          if (team != null) {
            teams.add(team);
          }
        }
        emit(state.copyWith(favoriteTeams: teams));
      } catch (e) {
        // Debug output removed
      }
    }

    // Load favorite matches
    final matchRepo = _matchRepository;
    if (matchRepo != null && state.preferences.favoriteMatchIds.isNotEmpty) {
      try {
        final matches = <WorldCupMatch>[];
        for (final matchId in state.preferences.favoriteMatchIds) {
          final match = await matchRepo.getMatchById(matchId);
          if (match != null) {
            matches.add(match);
          }
        }
        emit(state.copyWith(favoriteMatches: matches));
      } catch (e) {
        // Debug output removed
      }
    }
  }

  /// Toggle team favorite status
  Future<void> toggleFavoriteTeam(String teamCode) async {
    try {
      final updated = await _preferencesRepository.toggleFavoriteTeam(teamCode);
      emit(state.copyWith(preferences: updated));
      await _loadFavoriteEntities();
    } catch (e) {
      // Debug output removed
      emit(state.copyWith(errorMessage: 'Failed to update favorite: $e'));
    }
  }

  /// Add team to favorites
  Future<void> addFavoriteTeam(String teamCode) async {
    try {
      final updated = await _preferencesRepository.addFavoriteTeam(teamCode);
      emit(state.copyWith(preferences: updated));
      await _loadFavoriteEntities();
    } catch (e) {
      // Debug output removed
      emit(state.copyWith(errorMessage: 'Failed to add favorite: $e'));
    }
  }

  /// Remove team from favorites
  Future<void> removeFavoriteTeam(String teamCode) async {
    try {
      final updated = await _preferencesRepository.removeFavoriteTeam(teamCode);
      emit(state.copyWith(preferences: updated));
      await _loadFavoriteEntities();
    } catch (e) {
      // Debug output removed
      emit(state.copyWith(errorMessage: 'Failed to remove favorite: $e'));
    }
  }

  /// Toggle match favorite status
  Future<void> toggleFavoriteMatch(String matchId) async {
    try {
      final updated = await _preferencesRepository.toggleFavoriteMatch(matchId);
      emit(state.copyWith(preferences: updated));
      await _loadFavoriteEntities();
    } catch (e) {
      // Debug output removed
      emit(state.copyWith(errorMessage: 'Failed to update favorite: $e'));
    }
  }

  /// Add match to favorites
  Future<void> addFavoriteMatch(String matchId) async {
    try {
      final updated = await _preferencesRepository.addFavoriteMatch(matchId);
      emit(state.copyWith(preferences: updated));
      await _loadFavoriteEntities();
    } catch (e) {
      // Debug output removed
      emit(state.copyWith(errorMessage: 'Failed to add favorite: $e'));
    }
  }

  /// Remove match from favorites
  Future<void> removeFavoriteMatch(String matchId) async {
    try {
      final updated = await _preferencesRepository.removeFavoriteMatch(matchId);
      emit(state.copyWith(preferences: updated));
      await _loadFavoriteEntities();
    } catch (e) {
      // Debug output removed
      emit(state.copyWith(errorMessage: 'Failed to remove favorite: $e'));
    }
  }

  /// Update notification settings
  Future<void> updateNotificationSettings({
    bool? notifyFavoriteTeamMatches,
    bool? notifyLiveUpdates,
    bool? notifyGoals,
  }) async {
    try {
      final updated = await _preferencesRepository.updateNotificationSettings(
        notifyFavoriteTeamMatches: notifyFavoriteTeamMatches,
        notifyLiveUpdates: notifyLiveUpdates,
        notifyGoals: notifyGoals,
      );
      emit(state.copyWith(preferences: updated));
    } catch (e) {
      // Debug output removed
      emit(state.copyWith(errorMessage: 'Failed to update settings: $e'));
    }
  }

  /// Check if a team is favorited
  bool isTeamFavorite(String teamCode) => state.isTeamFavorite(teamCode);

  /// Check if a match is favorited
  bool isMatchFavorite(String matchId) => state.isMatchFavorite(matchId);

  /// Clear all favorites
  Future<void> clearFavorites() async {
    try {
      await _preferencesRepository.clearPreferences();
      emit(state.copyWith(
        preferences: UserPreferences.empty(),
        favoriteTeams: [],
        favoriteMatches: [],
      ));
    } catch (e) {
      // Debug output removed
      emit(state.copyWith(errorMessage: 'Failed to clear favorites: $e'));
    }
  }

  /// Clear error message
  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  @override
  Future<void> close() {
    _preferencesSubscription?.cancel();
    return super.close();
  }
}
