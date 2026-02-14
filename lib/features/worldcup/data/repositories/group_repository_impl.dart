import '../../domain/entities/entities.dart';
import '../../domain/repositories/group_repository.dart';
import '../datasources/world_cup_firestore_datasource.dart';
import '../datasources/world_cup_cache_datasource.dart';
import '../datasources/world_cup_api_datasource.dart';
import '../mock/world_cup_mock_data.dart';

/// Implementation of GroupRepository
class GroupRepositoryImpl implements GroupRepository {
  final WorldCupApiDataSource _apiDataSource;
  final WorldCupFirestoreDataSource _firestoreDataSource;
  final WorldCupCacheDataSource _cacheDataSource;

  GroupRepositoryImpl({
    required WorldCupApiDataSource apiDataSource,
    required WorldCupFirestoreDataSource firestoreDataSource,
    required WorldCupCacheDataSource cacheDataSource,
  })  : _apiDataSource = apiDataSource,
        _firestoreDataSource = firestoreDataSource,
        _cacheDataSource = cacheDataSource;

  @override
  Future<List<WorldCupGroup>> getAllGroups() async {
    try {
      // Try cache first
      final cached = await _cacheDataSource.getCachedGroups();
      if (cached != null && cached.isNotEmpty) {
        // Debug output removed
        return cached;
      }

      // Try Firestore
      try {
        final firestoreGroups = await _firestoreDataSource.getAllGroups();
        if (firestoreGroups.isNotEmpty) {
          await _cacheDataSource.cacheGroups(firestoreGroups);
          // Debug output removed
          return firestoreGroups;
        }
      } catch (e) {
        // Debug output removed
      }

      // Fetch from API
      try {
        final apiGroups = await refreshGroups();
        if (apiGroups.isNotEmpty) {
          return apiGroups;
        }
      } catch (e) {
        // Debug output removed
      }

      // Fallback to mock data for development/testing
      // Debug output removed
      final mockGroups = WorldCupMockData.groups;
      await _cacheDataSource.cacheGroups(mockGroups);
      return mockGroups;
    } catch (e) {
      // Debug output removed
      // Return mock data as final fallback
      return WorldCupMockData.groups;
    }
  }

  @override
  Future<WorldCupGroup?> getGroupByLetter(String groupLetter) async {
    try {
      // Try cache first
      final cached = await _cacheDataSource.getCachedGroup(groupLetter);
      if (cached != null) {
        return cached;
      }

      return await _firestoreDataSource.getGroupByLetter(groupLetter);
    } catch (e) {
      // Debug output removed
      return null;
    }
  }

  @override
  Future<List<WorldCupGroup>> getActiveGroups() async {
    try {
      final allGroups = await getAllGroups();
      return allGroups.where((g) => !g.isComplete && g.currentMatchDay > 0).toList();
    } catch (e) {
      // Debug output removed
      return [];
    }
  }

  @override
  Future<List<WorldCupGroup>> getCompletedGroups() async {
    try {
      final allGroups = await getAllGroups();
      return allGroups.where((g) => g.isComplete).toList();
    } catch (e) {
      // Debug output removed
      return [];
    }
  }

  @override
  Future<List<GroupTeamStanding>> getGroupStandings(String groupLetter) async {
    try {
      final group = await getGroupByLetter(groupLetter);
      return group?.sortedStandings ?? [];
    } catch (e) {
      // Debug output removed
      return [];
    }
  }

  @override
  Future<List<GroupTeamStanding>> getQualifiedTeams() async {
    try {
      final allGroups = await getAllGroups();
      final qualified = <GroupTeamStanding>[];

      for (final group in allGroups) {
        // Top 2 from each group
        final standings = group.sortedStandings;
        if (standings.length >= 2) {
          qualified.add(standings[0].copyWith(qualificationStatus: 'winner'));
          qualified.add(standings[1].copyWith(qualificationStatus: 'runner-up'));
        }
      }

      // Add best third-place teams
      final thirdPlace = await getBestThirdPlaceTeams();
      qualified.addAll(thirdPlace);

      return qualified;
    } catch (e) {
      // Debug output removed
      return [];
    }
  }

  @override
  Future<List<GroupTeamStanding>> getBestThirdPlaceTeams() async {
    try {
      final allGroups = await getAllGroups();
      final thirdPlaceTeams = <GroupTeamStanding>[];

      for (final group in allGroups) {
        final standings = group.sortedStandings;
        if (standings.length >= 3) {
          thirdPlaceTeams.add(standings[2].copyWith(
            qualificationStatus: 'third',
          ));
        }
      }

      // Sort by points, then goal difference, then goals scored
      thirdPlaceTeams.sort((a, b) {
        final pointsDiff = b.points.compareTo(a.points);
        if (pointsDiff != 0) return pointsDiff;

        final gdDiff = b.goalDifference.compareTo(a.goalDifference);
        if (gdDiff != 0) return gdDiff;

        return b.goalsFor.compareTo(a.goalsFor);
      });

      // Return best 8 third-place teams
      return thirdPlaceTeams.take(8).map((t) =>
        t.copyWith(hasQualified: true)
      ).toList();
    } catch (e) {
      // Debug output removed
      return [];
    }
  }

  @override
  Future<void> updateGroup(WorldCupGroup group) async {
    try {
      await _firestoreDataSource.saveGroup(group);
      await _cacheDataSource.clearCache('worldcup_groups');
    } catch (e) {
      // Debug output removed
      throw Exception('Failed to update group: $e');
    }
  }

  @override
  Future<void> updateGroupStandings(
    String groupLetter,
    List<GroupTeamStanding> standings,
  ) async {
    try {
      final group = await getGroupByLetter(groupLetter);
      if (group != null) {
        final updated = group.copyWith(
          standings: standings,
          updatedAt: DateTime.now(),
        );
        await updateGroup(updated);
      }
    } catch (e) {
      // Debug output removed
      throw Exception('Failed to update group standings: $e');
    }
  }

  @override
  Future<WorldCupGroup> recalculateStandings(String groupLetter) async {
    try {
      final group = await getGroupByLetter(groupLetter);
      if (group == null) {
        throw Exception('Group not found: $groupLetter');
      }

      // Apply tiebreaker rules
      final recalculated = WorldCupGroup.applyTiebreakers(group.standings);

      // Determine qualification status
      final updatedStandings = recalculated.map((s) {
        String? status;
        bool? qualified;

        if (s.position == 1) {
          status = 'winner';
          qualified = true;
        } else if (s.position == 2) {
          status = 'runner-up';
          qualified = true;
        } else if (s.position == 3) {
          status = 'third';
          // Third place qualification TBD
        } else {
          status = 'eliminated';
          qualified = false;
        }

        return s.copyWith(
          qualificationStatus: status,
          hasQualified: qualified,
        );
      }).toList();

      final updatedGroup = group.copyWith(
        standings: updatedStandings,
        isComplete: group.currentMatchDay >= 3,
        winnerTeamCode: updatedStandings.isNotEmpty ? updatedStandings[0].teamCode : null,
        runnerUpTeamCode: updatedStandings.length > 1 ? updatedStandings[1].teamCode : null,
        thirdPlaceTeamCode: updatedStandings.length > 2 ? updatedStandings[2].teamCode : null,
        updatedAt: DateTime.now(),
      );

      await updateGroup(updatedGroup);
      return updatedGroup;
    } catch (e) {
      // Debug output removed
      throw Exception('Failed to recalculate standings: $e');
    }
  }

  @override
  Future<List<WorldCupGroup>> refreshGroups() async {
    try {
      // Debug output removed
      final apiGroups = await _apiDataSource.fetchGroupStandings();

      if (apiGroups.isNotEmpty) {
        for (final group in apiGroups) {
          await _firestoreDataSource.saveGroup(group);
        }
        await _cacheDataSource.cacheGroups(apiGroups);
        // Debug output removed
        return apiGroups;
      }

      return [];
    } catch (e) {
      // Debug output removed
      throw Exception('Failed to refresh groups: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    await _cacheDataSource.clearCache('worldcup_groups');
  }

  @override
  Stream<List<WorldCupGroup>> watchGroups() {
    return _firestoreDataSource.watchGroups();
  }

  @override
  Stream<WorldCupGroup?> watchGroup(String groupLetter) {
    return _firestoreDataSource.watchGroup(groupLetter);
  }
}
