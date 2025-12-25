import '../entities/group.dart';

/// Repository interface for World Cup Group data
abstract class GroupRepository {
  /// Fetches all 12 groups (A-L)
  Future<List<WorldCupGroup>> getAllGroups();

  /// Fetches a single group by letter (A-L)
  Future<WorldCupGroup?> getGroupByLetter(String groupLetter);

  /// Fetches groups that are currently active (matches being played)
  Future<List<WorldCupGroup>> getActiveGroups();

  /// Fetches completed groups (all matches finished)
  Future<List<WorldCupGroup>> getCompletedGroups();

  /// Gets the standings for a specific group
  Future<List<GroupTeamStanding>> getGroupStandings(String groupLetter);

  /// Gets teams that have qualified from all groups
  /// Returns top 2 from each group + best 8 third-place teams
  Future<List<GroupTeamStanding>> getQualifiedTeams();

  /// Gets the best third-place teams across all groups
  Future<List<GroupTeamStanding>> getBestThirdPlaceTeams();

  /// Updates a group with new standings (after match results)
  Future<void> updateGroup(WorldCupGroup group);

  /// Updates standings for a specific group
  Future<void> updateGroupStandings(
    String groupLetter,
    List<GroupTeamStanding> standings,
  );

  /// Recalculates group standings based on match results
  Future<WorldCupGroup> recalculateStandings(String groupLetter);

  /// Refreshes group data from the API
  Future<List<WorldCupGroup>> refreshGroups();

  /// Clears the local cache of groups
  Future<void> clearCache();

  /// Stream of all group updates
  Stream<List<WorldCupGroup>> watchGroups();

  /// Stream of a specific group's updates
  Stream<WorldCupGroup?> watchGroup(String groupLetter);
}
