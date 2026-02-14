import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/group_repository.dart';
import 'group_standings_state.dart';

/// Cubit for managing World Cup group standings state
class GroupStandingsCubit extends Cubit<GroupStandingsState> {
  final GroupRepository _groupRepository;

  GroupStandingsCubit({
    required GroupRepository groupRepository,
  })  : _groupRepository = groupRepository,
        super(GroupStandingsState.initial());

  /// Initialize and load all groups
  Future<void> init() async {
    await loadGroups();
  }

  /// Load all group standings
  Future<void> loadGroups() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final groups = await _groupRepository.getAllGroups();

      // Sort groups by letter (A-L)
      groups.sort((a, b) => a.groupLetter.compareTo(b.groupLetter));

      emit(state.copyWith(
        groups: groups,
        isLoading: false,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      // Debug output removed
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load group standings: $e',
      ));
    }
  }

  /// Refresh group standings
  Future<void> refreshGroups() async {
    emit(state.copyWith(isRefreshing: true));

    try {
      final groups = await _groupRepository.refreshGroups();

      groups.sort((a, b) => a.groupLetter.compareTo(b.groupLetter));

      emit(state.copyWith(
        groups: groups,
        isRefreshing: false,
        lastUpdated: DateTime.now(),
      ));

      // Refresh selected group if one is selected
      if (state.selectedGroup != null) {
        selectGroup(state.selectedGroup!.groupLetter);
      }
    } catch (e) {
      // Debug output removed
      emit(state.copyWith(
        isRefreshing: false,
        errorMessage: 'Failed to refresh group standings: $e',
      ));
    }
  }

  /// Select a group for detail view
  void selectGroup(String groupLetter) {
    final group = state.getGroup(groupLetter);
    if (group != null) {
      emit(state.copyWith(selectedGroup: group));
    }
  }

  /// Clear selected group
  void clearSelectedGroup() {
    emit(state.copyWith(clearSelectedGroup: true));
  }

  /// Get standings for a specific group
  Future<WorldCupGroup?> getGroup(String groupLetter) async {
    // Try from state first
    final cached = state.getGroup(groupLetter);
    if (cached != null) return cached;

    // Load from repository
    try {
      return await _groupRepository.getGroupByLetter(groupLetter);
    } catch (e) {
      // Debug output removed
      return null;
    }
  }

  /// Get team's current standing in their group
  GroupTeamStanding? getTeamStanding(String teamCode) {
    for (final group in state.groups) {
      try {
        final standing = group.standings.firstWhere(
          (s) => s.teamCode.toUpperCase() == teamCode.toUpperCase(),
        );
        return standing;
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  /// Check if a team qualifies (top 2 in group for standard format,
  /// or based on 48-team format with top 2 + best 3rd place teams)
  bool doesTeamQualify(String teamCode) {
    final standing = getTeamStanding(teamCode);
    if (standing == null) return false;

    // In 48-team format: Top 2 from each group qualify (24 teams)
    // Plus 8 best third-place teams qualify (32 total for Round of 32)
    // For now, we'll just check if they're in top 2
    return standing.position <= 2;
  }

  /// Get all teams that have qualified for knockout stage
  List<GroupTeamStanding> getQualifiedTeams() {
    final qualified = <GroupTeamStanding>[];

    for (final group in state.groups) {
      // Top 2 from each group
      final top2 = group.standings.where((s) => s.position <= 2);
      qualified.addAll(top2);
    }

    return qualified;
  }

  /// Get best third-place teams (for 48-team format)
  List<GroupTeamStanding> getBestThirdPlaceTeams() {
    final thirdPlace = <GroupTeamStanding>[];

    for (final group in state.groups) {
      try {
        final third = group.standings.firstWhere((s) => s.position == 3);
        thirdPlace.add(third);
      } catch (_) {
        continue;
      }
    }

    // Sort by points, goal difference, goals scored
    thirdPlace.sort((a, b) {
      if (a.points != b.points) return b.points.compareTo(a.points);
      if (a.goalDifference != b.goalDifference) {
        return b.goalDifference.compareTo(a.goalDifference);
      }
      return b.goalsFor.compareTo(a.goalsFor);
    });

    // Return top 8 third-place teams
    return thirdPlace.take(8).toList();
  }
}
