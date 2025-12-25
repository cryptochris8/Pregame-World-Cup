import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/bracket_repository.dart';
import 'bracket_state.dart';

/// Cubit for managing World Cup knockout bracket state
class BracketCubit extends Cubit<BracketState> {
  final BracketRepository _bracketRepository;

  BracketCubit({
    required BracketRepository bracketRepository,
  })  : _bracketRepository = bracketRepository,
        super(BracketState.initial());

  /// Initialize and load bracket
  Future<void> init() async {
    await loadBracket();
  }

  /// Load the bracket
  Future<void> loadBracket() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final bracket = await _bracketRepository.getBracket();

      emit(state.copyWith(
        bracket: bracket,
        isLoading: false,
        lastUpdated: DateTime.now(),
      ));

      // Auto-focus on current active round
      final activeRound = state.currentActiveRound;
      if (activeRound != null) {
        emit(state.copyWith(focusedRound: activeRound));
      }
    } catch (e) {
      debugPrint('Error loading bracket: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load bracket: $e',
      ));
    }
  }

  /// Refresh bracket from API
  Future<void> refreshBracket() async {
    emit(state.copyWith(isRefreshing: true));

    try {
      final bracket = await _bracketRepository.refreshBracket();

      emit(state.copyWith(
        bracket: bracket,
        isRefreshing: false,
        lastUpdated: DateTime.now(),
      ));

      // Refresh selected match if one is selected
      if (state.selectedMatch != null) {
        final matchId = state.selectedMatch!.matchId;
        final updated = _findMatchById(bracket, matchId);
        if (updated != null) {
          emit(state.copyWith(selectedMatch: updated));
        }
      }
    } catch (e) {
      debugPrint('Error refreshing bracket: $e');
      emit(state.copyWith(
        isRefreshing: false,
        errorMessage: 'Failed to refresh bracket: $e',
      ));
    }
  }

  /// Find match by ID in bracket
  BracketMatch? _findMatchById(WorldCupBracket bracket, String matchId) {
    // Search all rounds
    for (final match in bracket.roundOf32) {
      if (match.matchId == matchId) return match;
    }
    for (final match in bracket.roundOf16) {
      if (match.matchId == matchId) return match;
    }
    for (final match in bracket.quarterFinals) {
      if (match.matchId == matchId) return match;
    }
    for (final match in bracket.semiFinals) {
      if (match.matchId == matchId) return match;
    }
    if (bracket.thirdPlace?.matchId == matchId) {
      return bracket.thirdPlace;
    }
    if (bracket.finalMatch?.matchId == matchId) {
      return bracket.finalMatch;
    }
    return null;
  }

  /// Set view mode
  void setViewMode(BracketViewMode mode) {
    emit(state.copyWith(viewMode: mode));
  }

  /// Focus on a specific round
  void focusRound(MatchStage round) {
    emit(state.copyWith(focusedRound: round));
  }

  /// Clear focused round (show all)
  void clearFocusedRound() {
    emit(state.copyWith(clearFocusedRound: true));
  }

  /// Select a match for detail view
  void selectMatch(BracketMatch match) {
    emit(state.copyWith(selectedMatch: match));
  }

  /// Clear selected match
  void clearSelectedMatch() {
    emit(state.copyWith(clearSelectedMatch: true));
  }

  /// Get a team's path through the bracket
  List<BracketMatch> getTeamPath(String teamCode) {
    if (state.bracket == null) return [];

    final path = <BracketMatch>[];
    final code = teamCode.toUpperCase();

    // Check all rounds
    for (final match in state.bracket!.roundOf32) {
      if (_matchInvolvesTeam(match, code)) path.add(match);
    }
    for (final match in state.bracket!.roundOf16) {
      if (_matchInvolvesTeam(match, code)) path.add(match);
    }
    for (final match in state.bracket!.quarterFinals) {
      if (_matchInvolvesTeam(match, code)) path.add(match);
    }
    for (final match in state.bracket!.semiFinals) {
      if (_matchInvolvesTeam(match, code)) path.add(match);
    }
    if (state.bracket!.thirdPlace != null &&
        _matchInvolvesTeam(state.bracket!.thirdPlace!, code)) {
      path.add(state.bracket!.thirdPlace!);
    }
    if (state.bracket!.finalMatch != null &&
        _matchInvolvesTeam(state.bracket!.finalMatch!, code)) {
      path.add(state.bracket!.finalMatch!);
    }

    return path;
  }

  /// Check if a match involves a specific team
  bool _matchInvolvesTeam(BracketMatch match, String teamCode) {
    return match.homeSlot.teamCode?.toUpperCase() == teamCode ||
           match.awaySlot.teamCode?.toUpperCase() == teamCode;
  }

  /// Check if a match is currently live
  bool _isMatchLive(BracketMatch match) {
    return match.status == MatchStatus.inProgress ||
           match.status == MatchStatus.halfTime ||
           match.status == MatchStatus.extraTime ||
           match.status == MatchStatus.penalties;
  }

  /// Get winner of the tournament
  String? getTournamentWinner() {
    if (state.bracket?.finalMatch == null) return null;
    final finalMatch = state.bracket!.finalMatch!;
    if (!finalMatch.isComplete) return null;
    return finalMatch.winnerCode;
  }

  /// Get matches that are currently live
  List<BracketMatch> getLiveMatches() {
    if (state.bracket == null) return [];

    final live = <BracketMatch>[];

    // Check all rounds
    for (final match in state.bracket!.roundOf32) {
      if (_isMatchLive(match)) live.add(match);
    }
    for (final match in state.bracket!.roundOf16) {
      if (_isMatchLive(match)) live.add(match);
    }
    for (final match in state.bracket!.quarterFinals) {
      if (_isMatchLive(match)) live.add(match);
    }
    for (final match in state.bracket!.semiFinals) {
      if (_isMatchLive(match)) live.add(match);
    }
    if (state.bracket!.thirdPlace != null && _isMatchLive(state.bracket!.thirdPlace!)) {
      live.add(state.bracket!.thirdPlace!);
    }
    if (state.bracket!.finalMatch != null && _isMatchLive(state.bracket!.finalMatch!)) {
      live.add(state.bracket!.finalMatch!);
    }

    return live;
  }

  /// Get upcoming matches (next to be played)
  List<BracketMatch> getUpcomingMatches({int limit = 4}) {
    if (state.bracket == null) return [];

    final upcoming = <BracketMatch>[];

    // Collect scheduled matches from all rounds
    void addScheduled(List<BracketMatch> matches) {
      for (final match in matches) {
        if (!match.isComplete && !_isMatchLive(match) &&
            match.homeSlot.teamCode != null &&
            match.awaySlot.teamCode != null) {
          upcoming.add(match);
        }
      }
    }

    addScheduled(state.bracket!.roundOf32);
    addScheduled(state.bracket!.roundOf16);
    addScheduled(state.bracket!.quarterFinals);
    addScheduled(state.bracket!.semiFinals);

    if (state.bracket!.thirdPlace != null) {
      addScheduled([state.bracket!.thirdPlace!]);
    }
    if (state.bracket!.finalMatch != null) {
      addScheduled([state.bracket!.finalMatch!]);
    }

    // Sort by date
    upcoming.sort((a, b) {
      if (a.dateTime == null && b.dateTime == null) return 0;
      if (a.dateTime == null) return 1;
      if (b.dateTime == null) return -1;
      return a.dateTime!.compareTo(b.dateTime!);
    });

    return upcoming.take(limit).toList();
  }
}
