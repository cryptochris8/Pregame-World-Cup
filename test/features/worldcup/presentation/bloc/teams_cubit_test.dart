import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';

import 'mock_repositories.dart';

void main() {
  late MockNationalTeamRepository mockRepository;
  late TeamsCubit cubit;

  setUp(() {
    mockRepository = MockNationalTeamRepository();
    cubit = TeamsCubit(teamRepository: mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('TeamsCubit', () {
    final testTeams = TestDataFactory.createTeamList(count: 16);

    test('initial state is correct', () {
      expect(cubit.state, equals(TeamsState.initial()));
      expect(cubit.state.isLoading, isTrue);
      expect(cubit.state.teams, isEmpty);
    });

    blocTest<TeamsCubit, TeamsState>(
      'loadTeams emits loaded state with teams',
      build: () {
        when(() => mockRepository.getAllTeams())
            .thenAnswer((_) async => testTeams);
        return cubit;
      },
      act: (cubit) => cubit.loadTeams(),
      expect: () => [
        isA<TeamsState>().having((s) => s.isLoading, 'isLoading', true),
        isA<TeamsState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.teams.length, 'teams length', 16),
        // After filters applied
        isA<TeamsState>()
            .having((s) => s.displayTeams.length, 'display length', 16),
      ],
      verify: (_) {
        verify(() => mockRepository.getAllTeams()).called(1);
      },
    );

    blocTest<TeamsCubit, TeamsState>(
      'loadTeams handles errors',
      build: () {
        when(() => mockRepository.getAllTeams())
            .thenThrow(Exception('Network error'));
        return cubit;
      },
      act: (cubit) => cubit.loadTeams(),
      expect: () => [
        isA<TeamsState>().having((s) => s.isLoading, 'isLoading', true),
        isA<TeamsState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.errorMessage, 'has error', isNotNull),
      ],
    );

    blocTest<TeamsCubit, TeamsState>(
      'setSortOption changes sort order',
      build: () => cubit,
      seed: () => TeamsState(
        teams: testTeams,
        displayTeams: testTeams,
        sortOption: TeamsSortOption.alphabetical,
        isLoading: false,
      ),
      act: (cubit) => cubit.setSortOption(TeamsSortOption.fifaRanking),
      expect: () => [
        isA<TeamsState>()
            .having((s) => s.sortOption, 'sort', TeamsSortOption.fifaRanking)
            .having((s) => s.displayTeams.first.fifaRanking, 'first ranking', 1),
      ],
    );

    blocTest<TeamsCubit, TeamsState>(
      'filterByConfederation filters teams',
      build: () => cubit,
      seed: () => TeamsState(
        teams: [
          TestDataFactory.createTeam(fifaCode: 'USA', confederation: Confederation.concacaf),
          TestDataFactory.createTeam(fifaCode: 'BRA', confederation: Confederation.conmebol),
          TestDataFactory.createTeam(fifaCode: 'MEX', confederation: Confederation.concacaf),
        ],
        displayTeams: const [],
        isLoading: false,
      ),
      act: (cubit) => cubit.filterByConfederation(Confederation.concacaf),
      expect: () => [
        isA<TeamsState>()
            .having((s) => s.selectedConfederation, 'conf', Confederation.concacaf),
        isA<TeamsState>()
            .having((s) => s.displayTeams.length, 'filtered count', 2),
      ],
    );

    blocTest<TeamsCubit, TeamsState>(
      'search filters teams by name',
      build: () => cubit,
      seed: () => TeamsState(
        teams: [
          TestDataFactory.createTeam(fifaCode: 'USA', countryName: 'United States'),
          TestDataFactory.createTeam(fifaCode: 'BRA', countryName: 'Brazil'),
          TestDataFactory.createTeam(fifaCode: 'URU', countryName: 'Uruguay'),
        ],
        displayTeams: const [],
        isLoading: false,
      ),
      act: (cubit) => cubit.search('United'),
      expect: () => [
        isA<TeamsState>().having((s) => s.searchQuery, 'query', 'United'),
        isA<TeamsState>()
            .having((s) => s.displayTeams.length, 'filtered count', 1)
            .having((s) => s.displayTeams.first.fifaCode, 'found', 'USA'),
      ],
    );

    blocTest<TeamsCubit, TeamsState>(
      'clearFilters resets all filters',
      build: () => cubit,
      seed: () => TeamsState(
        teams: testTeams,
        displayTeams: [testTeams.first],
        sortOption: TeamsSortOption.fifaRanking,
        selectedConfederation: Confederation.uefa,
        searchQuery: 'test',
        isLoading: false,
      ),
      act: (cubit) => cubit.clearFilters(),
      expect: () => [
        isA<TeamsState>()
            .having((s) => s.sortOption, 'sort', TeamsSortOption.alphabetical)
            .having((s) => s.selectedConfederation, 'conf', isNull)
            .having((s) => s.searchQuery, 'query', isNull),
        isA<TeamsState>()
            .having((s) => s.displayTeams.length, 'all teams', 16),
      ],
    );

    blocTest<TeamsCubit, TeamsState>(
      'selectTeam updates selectedTeam',
      build: () => cubit,
      seed: () => TeamsState(
        teams: testTeams,
        displayTeams: testTeams,
        isLoading: false,
      ),
      act: (cubit) => cubit.selectTeam(testTeams.first),
      expect: () => [
        isA<TeamsState>()
            .having((s) => s.selectedTeam, 'selected', testTeams.first),
      ],
    );

    test('getTeamsByConfederation groups teams correctly', () {
      cubit.emit(TeamsState(
        teams: [
          TestDataFactory.createTeam(fifaCode: 'USA', confederation: Confederation.concacaf),
          TestDataFactory.createTeam(fifaCode: 'BRA', confederation: Confederation.conmebol),
          TestDataFactory.createTeam(fifaCode: 'MEX', confederation: Confederation.concacaf),
          TestDataFactory.createTeam(fifaCode: 'GER', confederation: Confederation.uefa),
        ],
        displayTeams: const [],
        isLoading: false,
      ));

      final byConf = cubit.getTeamsByConfederation();
      expect(byConf[Confederation.concacaf]?.length, 2);
      expect(byConf[Confederation.conmebol]?.length, 1);
      expect(byConf[Confederation.uefa]?.length, 1);
    });

    test('getConfederationCounts returns correct counts', () {
      cubit.emit(TeamsState(
        teams: [
          TestDataFactory.createTeam(fifaCode: 'USA', confederation: Confederation.concacaf),
          TestDataFactory.createTeam(fifaCode: 'BRA', confederation: Confederation.conmebol),
          TestDataFactory.createTeam(fifaCode: 'MEX', confederation: Confederation.concacaf),
        ],
        displayTeams: const [],
        isLoading: false,
      ));

      final counts = cubit.getConfederationCounts();
      expect(counts[Confederation.concacaf], 2);
      expect(counts[Confederation.conmebol], 1);
    });
  });
}
