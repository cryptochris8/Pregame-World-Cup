import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';
import 'mock_repositories.dart';

void main() {
  group('TeamsSortOption', () {
    test('has expected values', () {
      expect(TeamsSortOption.values, hasLength(4));
      expect(TeamsSortOption.values, contains(TeamsSortOption.alphabetical));
      expect(TeamsSortOption.values, contains(TeamsSortOption.worldRanking));
      expect(TeamsSortOption.values, contains(TeamsSortOption.confederation));
      expect(TeamsSortOption.values, contains(TeamsSortOption.group));
    });
  });

  group('TeamsState', () {
    final testTeams = [
      TestDataFactory.createTeam(
        teamCode: 'USA',
        countryName: 'United States',
        worldRanking: 11,
        confederation: Confederation.concacaf,
        group: 'A',
        worldCupTitles: 0,
        isHostNation: true,
      ),
      TestDataFactory.createTeam(
        teamCode: 'BRA',
        countryName: 'Brazil',
        worldRanking: 1,
        confederation: Confederation.conmebol,
        group: 'B',
        worldCupTitles: 5,
        isHostNation: false,
      ),
      TestDataFactory.createTeam(
        teamCode: 'GER',
        countryName: 'Germany',
        worldRanking: 3,
        confederation: Confederation.uefa,
        group: 'A',
        worldCupTitles: 4,
        isHostNation: false,
      ),
      TestDataFactory.createTeam(
        teamCode: 'MEX',
        countryName: 'Mexico',
        worldRanking: 15,
        confederation: Confederation.concacaf,
        group: 'B',
        worldCupTitles: 0,
        isHostNation: true,
      ),
    ];

    group('Constructor', () {
      test('creates state with default values', () {
        const state = TeamsState();

        expect(state.teams, isEmpty);
        expect(state.displayTeams, isEmpty);
        expect(state.selectedTeam, isNull);
        expect(state.sortOption, equals(TeamsSortOption.alphabetical));
        expect(state.selectedConfederation, isNull);
        expect(state.selectedGroup, isNull);
        expect(state.searchQuery, isNull);
        expect(state.showFavoritesOnly, isFalse);
        expect(state.isLoading, isFalse);
        expect(state.isRefreshing, isFalse);
        expect(state.errorMessage, isNull);
        expect(state.lastUpdated, isNull);
      });

      test('creates state with custom values', () {
        final now = DateTime.now();
        final state = TeamsState(
          teams: testTeams,
          displayTeams: testTeams.sublist(0, 2),
          selectedTeam: testTeams[0],
          sortOption: TeamsSortOption.worldRanking,
          selectedConfederation: Confederation.concacaf,
          selectedGroup: 'A',
          searchQuery: 'USA',
          showFavoritesOnly: true,
          isLoading: true,
          isRefreshing: true,
          errorMessage: 'Test error',
          lastUpdated: now,
        );

        expect(state.teams, equals(testTeams));
        expect(state.displayTeams, hasLength(2));
        expect(state.selectedTeam, equals(testTeams[0]));
        expect(state.sortOption, equals(TeamsSortOption.worldRanking));
        expect(state.selectedConfederation, equals(Confederation.concacaf));
        expect(state.selectedGroup, equals('A'));
        expect(state.searchQuery, equals('USA'));
        expect(state.showFavoritesOnly, isTrue);
        expect(state.isLoading, isTrue);
        expect(state.isRefreshing, isTrue);
        expect(state.errorMessage, equals('Test error'));
        expect(state.lastUpdated, equals(now));
      });
    });

    group('initial factory', () {
      test('creates initial state with loading true', () {
        final state = TeamsState.initial();

        expect(state.teams, isEmpty);
        expect(state.displayTeams, isEmpty);
        expect(state.isLoading, isTrue);
        expect(state.isRefreshing, isFalse);
        expect(state.errorMessage, isNull);
      });
    });

    group('copyWith', () {
      test('copies with updated fields', () {
        final original = TeamsState(teams: testTeams);
        final updated = original.copyWith(
          displayTeams: testTeams.sublist(0, 2),
          sortOption: TeamsSortOption.worldRanking,
          isLoading: true,
        );

        expect(updated.teams, equals(original.teams));
        expect(updated.displayTeams, hasLength(2));
        expect(updated.sortOption, equals(TeamsSortOption.worldRanking));
        expect(updated.isLoading, isTrue);
      });

      test('preserves unchanged fields', () {
        final original = TeamsState(
          teams: testTeams,
          sortOption: TeamsSortOption.alphabetical,
          selectedConfederation: Confederation.concacaf,
        );
        final updated = original.copyWith(isLoading: true);

        expect(updated.teams, equals(original.teams));
        expect(updated.sortOption, equals(TeamsSortOption.alphabetical));
        expect(updated.selectedConfederation, equals(Confederation.concacaf));
        expect(updated.isLoading, isTrue);
      });

      test('clears selected team when clearSelectedTeam is true', () {
        final original = TeamsState(selectedTeam: testTeams[0]);
        final updated = original.copyWith(clearSelectedTeam: true);

        expect(updated.selectedTeam, isNull);
      });

      test('clears confederation when clearConfederation is true', () {
        final original = TeamsState(selectedConfederation: Confederation.uefa);
        final updated = original.copyWith(clearConfederation: true);

        expect(updated.selectedConfederation, isNull);
      });

      test('clears group when clearGroup is true', () {
        final original = TeamsState(selectedGroup: 'A');
        final updated = original.copyWith(clearGroup: true);

        expect(updated.selectedGroup, isNull);
      });

      test('clears search when clearSearch is true', () {
        final original = TeamsState(searchQuery: 'Brazil');
        final updated = original.copyWith(clearSearch: true);

        expect(updated.searchQuery, isNull);
      });

      test('clears error when clearError is true', () {
        final original = TeamsState(errorMessage: 'Error');
        final updated = original.copyWith(clearError: true);

        expect(updated.errorMessage, isNull);
      });
    });

    group('getTeamByCode', () {
      test('returns team when code matches', () {
        final state = TeamsState(teams: testTeams);
        final team = state.getTeamByCode('USA');

        expect(team, isNotNull);
        expect(team?.teamCode, equals('USA'));
      });

      test('returns team with case-insensitive match', () {
        final state = TeamsState(teams: testTeams);
        final team = state.getTeamByCode('usa');

        expect(team, isNotNull);
        expect(team?.teamCode, equals('USA'));
      });

      test('returns null when code does not match', () {
        final state = TeamsState(teams: testTeams);
        final team = state.getTeamByCode('XXX');

        expect(team, isNull);
      });

      test('returns null when teams list is empty', () {
        const state = TeamsState();
        final team = state.getTeamByCode('USA');

        expect(team, isNull);
      });
    });

    group('getTeamsByConfederation', () {
      test('returns teams from specified confederation', () {
        final state = TeamsState(teams: testTeams);
        final concacafTeams = state.getTeamsByConfederation(Confederation.concacaf);

        expect(concacafTeams, hasLength(2));
        expect(concacafTeams.every((t) => t.confederation == Confederation.concacaf), isTrue);
      });

      test('returns empty list when no teams from confederation', () {
        final state = TeamsState(teams: testTeams);
        final afcTeams = state.getTeamsByConfederation(Confederation.afc);

        expect(afcTeams, isEmpty);
      });
    });

    group('getTeamsByGroup', () {
      test('returns teams from specified group', () {
        final state = TeamsState(teams: testTeams);
        final groupATeams = state.getTeamsByGroup('A');

        expect(groupATeams, hasLength(2));
        expect(groupATeams.every((t) => t.group?.toUpperCase() == 'A'), isTrue);
      });

      test('returns teams with case-insensitive match', () {
        final state = TeamsState(teams: testTeams);
        final groupATeams = state.getTeamsByGroup('a');

        expect(groupATeams, hasLength(2));
      });

      test('returns empty list when no teams in group', () {
        final state = TeamsState(teams: testTeams);
        final groupCTeams = state.getTeamsByGroup('C');

        expect(groupCTeams, isEmpty);
      });
    });

    group('hostNations getter', () {
      test('returns only host nations', () {
        final state = TeamsState(teams: testTeams);
        final hosts = state.hostNations;

        expect(hosts, hasLength(2));
        expect(hosts.every((t) => t.isHostNation), isTrue);
        expect(hosts.map((t) => t.teamCode), containsAll(['USA', 'MEX']));
      });

      test('returns empty list when no host nations', () {
        final noHosts = [
          TestDataFactory.createTeam(teamCode: 'BRA', isHostNation: false),
        ];
        final state = TeamsState(teams: noHosts);

        expect(state.hostNations, isEmpty);
      });
    });

    group('topTitleHolders getter', () {
      test('returns teams sorted by titles descending', () {
        final state = TeamsState(teams: testTeams);
        final titleHolders = state.topTitleHolders;

        expect(titleHolders, hasLength(2));
        expect(titleHolders[0].teamCode, equals('BRA')); // 5 titles
        expect(titleHolders[1].teamCode, equals('GER')); // 4 titles
      });

      test('excludes teams with zero titles', () {
        final state = TeamsState(teams: testTeams);
        final titleHolders = state.topTitleHolders;

        expect(titleHolders.every((t) => t.worldCupTitles > 0), isTrue);
        expect(titleHolders.any((t) => t.teamCode == 'USA'), isFalse);
        expect(titleHolders.any((t) => t.teamCode == 'MEX'), isFalse);
      });

      test('returns empty list when no teams have titles', () {
        final noTitles = [
          TestDataFactory.createTeam(teamCode: 'USA', worldCupTitles: 0),
          TestDataFactory.createTeam(teamCode: 'MEX', worldCupTitles: 0),
        ];
        final state = TeamsState(teams: noTitles);

        expect(state.topTitleHolders, isEmpty);
      });
    });

    group('allGroups getter', () {
      test('returns sorted list of unique groups', () {
        final state = TeamsState(teams: testTeams);
        final groups = state.allGroups;

        expect(groups, hasLength(2));
        expect(groups, equals(['A', 'B']));
      });

      test('excludes teams with null group', () {
        final teamsWithNull = [
          ...testTeams,
          TestDataFactory.createTeam(teamCode: 'ARG', group: null),
        ];
        final state = TeamsState(teams: teamsWithNull);
        final groups = state.allGroups;

        expect(groups, hasLength(2));
        expect(groups, equals(['A', 'B']));
      });

      test('returns empty list when no teams have groups', () {
        final noGroups = [
          TestDataFactory.createTeam(teamCode: 'USA', group: null),
        ];
        final state = TeamsState(teams: noGroups);

        expect(state.allGroups, isEmpty);
      });

      test('deduplicates groups', () {
        final duplicateGroups = [
          TestDataFactory.createTeam(teamCode: 'USA', group: 'A'),
          TestDataFactory.createTeam(teamCode: 'GER', group: 'A'),
          TestDataFactory.createTeam(teamCode: 'BRA', group: 'A'),
        ];
        final state = TeamsState(teams: duplicateGroups);
        final groups = state.allGroups;

        expect(groups, hasLength(1));
        expect(groups, equals(['A']));
      });
    });

    group('Equatable', () {
      test('two states with same props are equal', () {
        final state1 = TeamsState(teams: testTeams);
        final state2 = TeamsState(teams: testTeams);

        expect(state1, equals(state2));
      });

      test('two states with different teams are not equal', () {
        final state1 = TeamsState(teams: testTeams);
        final state2 = TeamsState(teams: testTeams.sublist(0, 2));

        expect(state1, isNot(equals(state2)));
      });

      test('two states with different sort options are not equal', () {
        final state1 = TeamsState(sortOption: TeamsSortOption.alphabetical);
        final state2 = TeamsState(sortOption: TeamsSortOption.worldRanking);

        expect(state1, isNot(equals(state2)));
      });

      test('props contains all fields', () {
        final state = TeamsState(teams: testTeams);

        expect(state.props, hasLength(12));
        expect(state.props, contains(state.teams));
        expect(state.props, contains(state.displayTeams));
        expect(state.props, contains(state.selectedTeam));
        expect(state.props, contains(state.sortOption));
        expect(state.props, contains(state.selectedConfederation));
        expect(state.props, contains(state.selectedGroup));
        expect(state.props, contains(state.searchQuery));
        expect(state.props, contains(state.showFavoritesOnly));
        expect(state.props, contains(state.isLoading));
        expect(state.props, contains(state.isRefreshing));
        expect(state.props, contains(state.errorMessage));
        expect(state.props, contains(state.lastUpdated));
      });
    });
  });
}
