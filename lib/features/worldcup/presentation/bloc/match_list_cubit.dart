import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/world_cup_match_repository.dart';
import 'match_list_state.dart';

/// Cubit for managing World Cup match list state
class MatchListCubit extends Cubit<MatchListState> {
  final WorldCupMatchRepository _matchRepository;
  StreamSubscription<List<WorldCupMatch>>? _liveMatchesSubscription;

  MatchListCubit({
    required WorldCupMatchRepository matchRepository,
  })  : _matchRepository = matchRepository,
        super(MatchListState.initial());

  /// Initialize and load matches
  Future<void> init() async {
    await loadMatches();
    _subscribeLiveMatches();
  }

  /// Load all matches
  Future<void> loadMatches() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final matches = await _matchRepository.getAllMatches();
      final liveMatches = await _matchRepository.getLiveMatches();

      // Sort by date
      matches.sort((a, b) {
        if (a.dateTime == null && b.dateTime == null) return 0;
        if (a.dateTime == null) return 1;
        if (b.dateTime == null) return -1;
        return a.dateTime!.compareTo(b.dateTime!);
      });

      emit(state.copyWith(
        matches: matches,
        liveMatches: liveMatches,
        isLoading: false,
        lastUpdated: DateTime.now(),
      ));

      // Apply current filter
      _applyFilter();
    } catch (e) {
      debugPrint('Error loading matches: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load matches: $e',
      ));
    }
  }

  /// Refresh matches from API
  Future<void> refreshMatches() async {
    emit(state.copyWith(isRefreshing: true));

    try {
      final matches = await _matchRepository.refreshMatches();

      matches.sort((a, b) {
        if (a.dateTime == null && b.dateTime == null) return 0;
        if (a.dateTime == null) return 1;
        if (b.dateTime == null) return -1;
        return a.dateTime!.compareTo(b.dateTime!);
      });

      emit(state.copyWith(
        matches: matches,
        isRefreshing: false,
        lastUpdated: DateTime.now(),
      ));

      _applyFilter();
    } catch (e) {
      debugPrint('Error refreshing matches: $e');
      emit(state.copyWith(
        isRefreshing: false,
        errorMessage: 'Failed to refresh matches: $e',
      ));
    }
  }

  /// Subscribe to live match updates
  void _subscribeLiveMatches() {
    _liveMatchesSubscription?.cancel();
    _liveMatchesSubscription = _matchRepository.watchLiveMatches().listen(
      (liveMatches) {
        emit(state.copyWith(liveMatches: liveMatches));

        // Update matches list with live data
        if (liveMatches.isNotEmpty) {
          final updatedMatches = state.matches.map((match) {
            final liveMatch = liveMatches.firstWhere(
              (m) => m.matchId == match.matchId,
              orElse: () => match,
            );
            return liveMatch;
          }).toList();

          emit(state.copyWith(matches: updatedMatches));
          _applyFilter();
        }
      },
      onError: (e) {
        debugPrint('Error in live matches stream: $e');
      },
    );
  }

  /// Set filter and apply
  void setFilter(MatchListFilter filter) {
    emit(state.copyWith(
      filter: filter,
      clearStage: true,
      clearGroup: true,
      clearTeam: true,
      clearDate: true,
    ));
    _applyFilter();
  }

  /// Filter by stage
  void filterByStage(MatchStage? stage) {
    emit(state.copyWith(
      selectedStage: stage,
      clearStage: stage == null,
      filter: MatchListFilter.all,
    ));
    _applyFilter();
  }

  /// Filter by group
  void filterByGroup(String? groupLetter) {
    emit(state.copyWith(
      selectedGroup: groupLetter,
      clearGroup: groupLetter == null,
      filter: MatchListFilter.groupStage,
    ));
    _applyFilter();
  }

  /// Filter by team
  void filterByTeam(String? teamCode) {
    emit(state.copyWith(
      selectedTeamCode: teamCode,
      clearTeam: teamCode == null,
      filter: MatchListFilter.all,
    ));
    _applyFilter();
  }

  /// Filter by date
  void filterByDate(DateTime? date) {
    emit(state.copyWith(
      selectedDate: date,
      clearDate: date == null,
      filter: MatchListFilter.all,
    ));
    _applyFilter();
  }

  /// Clear all filters
  void clearFilters() {
    emit(state.copyWith(
      filter: MatchListFilter.all,
      clearStage: true,
      clearGroup: true,
      clearTeam: true,
      clearDate: true,
    ));
    _applyFilter();
  }

  /// Apply current filter to matches
  void _applyFilter() {
    List<WorldCupMatch> filtered = List.from(state.matches);

    // Apply main filter
    switch (state.filter) {
      case MatchListFilter.today:
        final now = DateTime.now();
        filtered = filtered.where((m) {
          if (m.dateTime == null) return false;
          return m.dateTime!.year == now.year &&
                 m.dateTime!.month == now.month &&
                 m.dateTime!.day == now.day;
        }).toList();
        break;

      case MatchListFilter.upcoming:
        filtered = filtered.where((m) =>
          m.status == MatchStatus.scheduled
        ).toList();
        break;

      case MatchListFilter.live:
        filtered = filtered.where((m) => m.isLive).toList();
        break;

      case MatchListFilter.completed:
        filtered = filtered.where((m) =>
          m.status == MatchStatus.completed
        ).toList();
        // Sort completed by most recent first
        filtered.sort((a, b) {
          if (a.dateTime == null && b.dateTime == null) return 0;
          if (a.dateTime == null) return 1;
          if (b.dateTime == null) return -1;
          return b.dateTime!.compareTo(a.dateTime!);
        });
        break;

      case MatchListFilter.groupStage:
        filtered = filtered.where((m) =>
          m.stage == MatchStage.groupStage
        ).toList();
        break;

      case MatchListFilter.knockout:
        filtered = filtered.where((m) =>
          m.stage != MatchStage.groupStage
        ).toList();
        break;

      case MatchListFilter.all:
      default:
        // No filtering
        break;
    }

    // Apply stage filter
    if (state.selectedStage != null) {
      filtered = filtered.where((m) =>
        m.stage == state.selectedStage
      ).toList();
    }

    // Apply group filter
    if (state.selectedGroup != null) {
      filtered = filtered.where((m) =>
        m.group?.toUpperCase() == state.selectedGroup!.toUpperCase()
      ).toList();
    }

    // Apply team filter
    if (state.selectedTeamCode != null) {
      final teamCode = state.selectedTeamCode!.toUpperCase();
      filtered = filtered.where((m) =>
        m.homeTeamCode?.toUpperCase() == teamCode ||
        m.awayTeamCode?.toUpperCase() == teamCode
      ).toList();
    }

    // Apply date filter
    if (state.selectedDate != null) {
      final date = state.selectedDate!;
      filtered = filtered.where((m) {
        if (m.dateTime == null) return false;
        return m.dateTime!.year == date.year &&
               m.dateTime!.month == date.month &&
               m.dateTime!.day == date.day;
      }).toList();
    }

    emit(state.copyWith(filteredMatches: filtered));
  }

  /// Get matches for a specific date
  Future<List<WorldCupMatch>> getMatchesForDate(DateTime date) async {
    return state.matches.where((m) {
      if (m.dateTime == null) return false;
      return m.dateTime!.year == date.year &&
             m.dateTime!.month == date.month &&
             m.dateTime!.day == date.day;
    }).toList();
  }

  /// Get upcoming matches
  Future<List<WorldCupMatch>> getUpcomingMatches({int limit = 5}) async {
    final upcoming = state.matches
        .where((m) => m.status == MatchStatus.scheduled && m.dateTime != null)
        .toList();

    upcoming.sort((a, b) => a.dateTime!.compareTo(b.dateTime!));
    return upcoming.take(limit).toList();
  }

  @override
  Future<void> close() {
    _liveMatchesSubscription?.cancel();
    return super.close();
  }
}
