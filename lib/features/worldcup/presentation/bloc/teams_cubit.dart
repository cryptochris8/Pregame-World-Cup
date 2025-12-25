import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/national_team_repository.dart';
import 'teams_state.dart';

/// Cubit for managing World Cup national teams state
class TeamsCubit extends Cubit<TeamsState> {
  final NationalTeamRepository _teamRepository;

  TeamsCubit({
    required NationalTeamRepository teamRepository,
  })  : _teamRepository = teamRepository,
        super(TeamsState.initial());

  /// Initialize and load teams
  Future<void> init() async {
    await loadTeams();
  }

  /// Load all teams
  Future<void> loadTeams() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final teams = await _teamRepository.getAllTeams();

      emit(state.copyWith(
        teams: teams,
        isLoading: false,
        lastUpdated: DateTime.now(),
      ));

      // Apply initial sort/filter
      _applyFiltersAndSort();
    } catch (e) {
      debugPrint('Error loading teams: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load teams: $e',
      ));
    }
  }

  /// Refresh teams from API
  Future<void> refreshTeams() async {
    emit(state.copyWith(isRefreshing: true));

    try {
      final teams = await _teamRepository.refreshTeams();

      emit(state.copyWith(
        teams: teams,
        isRefreshing: false,
        lastUpdated: DateTime.now(),
      ));

      _applyFiltersAndSort();
    } catch (e) {
      debugPrint('Error refreshing teams: $e');
      emit(state.copyWith(
        isRefreshing: false,
        errorMessage: 'Failed to refresh teams: $e',
      ));
    }
  }

  /// Set sort option
  void setSortOption(TeamsSortOption option) {
    emit(state.copyWith(sortOption: option));
    _applyFiltersAndSort();
  }

  /// Filter by confederation
  void filterByConfederation(Confederation? confederation) {
    emit(state.copyWith(
      selectedConfederation: confederation,
      clearConfederation: confederation == null,
    ));
    _applyFiltersAndSort();
  }

  /// Filter by group
  void filterByGroup(String? groupLetter) {
    emit(state.copyWith(
      selectedGroup: groupLetter,
      clearGroup: groupLetter == null,
    ));
    _applyFiltersAndSort();
  }

  /// Search teams
  void search(String? query) {
    emit(state.copyWith(
      searchQuery: query,
      clearSearch: query == null || query.isEmpty,
    ));
    _applyFiltersAndSort();
  }

  /// Toggle favorites filter
  void toggleShowFavoritesOnly() {
    emit(state.copyWith(showFavoritesOnly: !state.showFavoritesOnly));
    _applyFiltersAndSort();
  }

  /// Set favorites filter
  void setShowFavoritesOnly(bool show) {
    emit(state.copyWith(showFavoritesOnly: show));
    _applyFiltersAndSort();
  }

  /// Clear all filters
  void clearFilters() {
    emit(state.copyWith(
      clearConfederation: true,
      clearGroup: true,
      clearSearch: true,
      showFavoritesOnly: false,
      sortOption: TeamsSortOption.alphabetical,
    ));
    _applyFiltersAndSort();
  }

  /// Select a team for detail view
  void selectTeam(NationalTeam team) {
    emit(state.copyWith(selectedTeam: team));
  }

  /// Select team by code
  Future<void> selectTeamByCode(String code) async {
    var team = state.getTeamByCode(code);

    if (team == null) {
      // Try loading from repository
      try {
        team = await _teamRepository.getTeamByCode(code);
      } catch (e) {
        debugPrint('Error loading team $code: $e');
      }
    }

    if (team != null) {
      emit(state.copyWith(selectedTeam: team));
    }
  }

  /// Clear selected team
  void clearSelectedTeam() {
    emit(state.copyWith(clearSelectedTeam: true));
  }

  /// Apply current filters and sort to teams list
  void _applyFiltersAndSort() {
    List<NationalTeam> filtered = List.from(state.teams);

    // Apply confederation filter
    if (state.selectedConfederation != null) {
      filtered = filtered.where(
        (t) => t.confederation == state.selectedConfederation,
      ).toList();
    }

    // Apply group filter
    if (state.selectedGroup != null) {
      filtered = filtered.where(
        (t) => t.group?.toUpperCase() == state.selectedGroup!.toUpperCase(),
      ).toList();
    }

    // Apply search
    if (state.searchQuery != null && state.searchQuery!.isNotEmpty) {
      final query = state.searchQuery!.toLowerCase();
      filtered = filtered.where((t) {
        return t.countryName.toLowerCase().contains(query) ||
               t.shortName.toLowerCase().contains(query) ||
               t.fifaCode.toLowerCase().contains(query);
      }).toList();
    }

    // Apply sort
    switch (state.sortOption) {
      case TeamsSortOption.alphabetical:
        filtered.sort((a, b) => a.countryName.compareTo(b.countryName));
        break;

      case TeamsSortOption.fifaRanking:
        filtered.sort((a, b) {
          if (a.fifaRanking == null && b.fifaRanking == null) return 0;
          if (a.fifaRanking == null) return 1;
          if (b.fifaRanking == null) return -1;
          return a.fifaRanking!.compareTo(b.fifaRanking!);
        });
        break;

      case TeamsSortOption.confederation:
        filtered.sort((a, b) {
          final confCompare = a.confederation.name.compareTo(b.confederation.name);
          if (confCompare != 0) return confCompare;
          return a.countryName.compareTo(b.countryName);
        });
        break;

      case TeamsSortOption.group:
        filtered.sort((a, b) {
          if (a.group == null && b.group == null) return 0;
          if (a.group == null) return 1;
          if (b.group == null) return -1;
          final groupCompare = a.group!.compareTo(b.group!);
          if (groupCompare != 0) return groupCompare;
          return a.countryName.compareTo(b.countryName);
        });
        break;
    }

    emit(state.copyWith(displayTeams: filtered));
  }

  /// Get teams grouped by confederation
  Map<Confederation, List<NationalTeam>> getTeamsByConfederation() {
    final map = <Confederation, List<NationalTeam>>{};

    for (final conf in Confederation.values) {
      final teams = state.teams.where((t) => t.confederation == conf).toList();
      if (teams.isNotEmpty) {
        map[conf] = teams..sort((a, b) => a.countryName.compareTo(b.countryName));
      }
    }

    return map;
  }

  /// Get teams grouped by group letter
  Map<String, List<NationalTeam>> getTeamsByGroup() {
    final map = <String, List<NationalTeam>>{};

    for (final team in state.teams) {
      if (team.group != null) {
        map.putIfAbsent(team.group!, () => []).add(team);
      }
    }

    // Sort groups and teams within groups
    final sortedMap = <String, List<NationalTeam>>{};
    final sortedKeys = map.keys.toList()..sort();

    for (final key in sortedKeys) {
      sortedMap[key] = map[key]!..sort((a, b) => a.countryName.compareTo(b.countryName));
    }

    return sortedMap;
  }

  /// Get confederations with team counts
  Map<Confederation, int> getConfederationCounts() {
    final counts = <Confederation, int>{};

    for (final team in state.teams) {
      counts[team.confederation] = (counts[team.confederation] ?? 0) + 1;
    }

    return counts;
  }
}
