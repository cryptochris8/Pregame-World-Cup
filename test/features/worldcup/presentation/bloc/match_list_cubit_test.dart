import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';

import 'mock_repositories.dart';

void main() {
  late MockWorldCupMatchRepository mockRepository;
  late MatchListCubit cubit;

  setUp(() {
    mockRepository = MockWorldCupMatchRepository();
    cubit = MatchListCubit(matchRepository: mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('MatchListCubit', () {
    final testMatches = TestDataFactory.createMatchList(count: 5);
    final liveMatch = TestDataFactory.createMatch(
      matchId: 'live_1',
      status: MatchStatus.inProgress,
      homeScore: 1,
      awayScore: 0,
    );

    test('initial state is correct', () {
      expect(cubit.state, equals(MatchListState.initial()));
      expect(cubit.state.isLoading, isTrue);
      expect(cubit.state.matches, isEmpty);
    });

    blocTest<MatchListCubit, MatchListState>(
      'loadMatches emits loaded state with matches',
      build: () {
        when(() => mockRepository.getAllMatches())
            .thenAnswer((_) async => testMatches);
        when(() => mockRepository.getLiveMatches())
            .thenAnswer((_) async => []);
        when(() => mockRepository.watchLiveMatches())
            .thenAnswer((_) => Stream.value([]));
        return cubit;
      },
      act: (cubit) => cubit.loadMatches(),
      expect: () => [
        // Loading state
        isA<MatchListState>()
            .having((s) => s.isLoading, 'isLoading', true),
        // Loaded state
        isA<MatchListState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.matches.length, 'matches length', 5),
        // After filter applied
        isA<MatchListState>()
            .having((s) => s.filteredMatches.length, 'filtered length', 5),
      ],
      verify: (_) {
        verify(() => mockRepository.getAllMatches()).called(1);
        verify(() => mockRepository.getLiveMatches()).called(1);
      },
    );

    blocTest<MatchListCubit, MatchListState>(
      'loadMatches handles errors',
      build: () {
        when(() => mockRepository.getAllMatches())
            .thenThrow(Exception('Network error'));
        when(() => mockRepository.getLiveMatches())
            .thenAnswer((_) async => []);
        return cubit;
      },
      act: (cubit) => cubit.loadMatches(),
      expect: () => [
        isA<MatchListState>().having((s) => s.isLoading, 'isLoading', true),
        isA<MatchListState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.errorMessage, 'has error', isNotNull),
      ],
    );

    blocTest<MatchListCubit, MatchListState>(
      'setFilter updates filter and applies it',
      build: () {
        when(() => mockRepository.getAllMatches())
            .thenAnswer((_) async => testMatches);
        when(() => mockRepository.getLiveMatches())
            .thenAnswer((_) async => []);
        when(() => mockRepository.watchLiveMatches())
            .thenAnswer((_) => Stream.value([]));
        return cubit;
      },
      seed: () => MatchListState(
        matches: testMatches,
        filteredMatches: testMatches,
        filter: MatchListFilter.all,
      ),
      act: (cubit) => cubit.setFilter(MatchListFilter.upcoming),
      expect: () => [
        isA<MatchListState>()
            .having((s) => s.filter, 'filter', MatchListFilter.upcoming)
            .having((s) => s.filteredMatches, 'filtered', isNotEmpty),
      ],
    );

    blocTest<MatchListCubit, MatchListState>(
      'filterByGroup filters matches by group',
      build: () => cubit,
      seed: () => MatchListState(
        matches: [
          TestDataFactory.createMatch(group: 'A'),
          TestDataFactory.createMatch(matchId: 'm2', group: 'B'),
          TestDataFactory.createMatch(matchId: 'm3', group: 'A'),
        ],
        filteredMatches: const [],
        filter: MatchListFilter.all,
      ),
      act: (cubit) => cubit.filterByGroup('A'),
      expect: () => [
        isA<MatchListState>()
            .having((s) => s.selectedGroup, 'selectedGroup', 'A')
            .having((s) => s.filter, 'filter', MatchListFilter.groupStage),
        isA<MatchListState>()
            .having((s) => s.filteredMatches.length, 'filtered count', 2),
      ],
    );

    blocTest<MatchListCubit, MatchListState>(
      'clearFilters resets all filters',
      build: () => cubit,
      seed: () => MatchListState(
        matches: testMatches,
        filteredMatches: [testMatches.first],
        filter: MatchListFilter.live,
        selectedGroup: 'A',
        selectedTeamCode: 'USA',
      ),
      act: (cubit) => cubit.clearFilters(),
      expect: () => [
        isA<MatchListState>()
            .having((s) => s.filter, 'filter', MatchListFilter.all)
            .having((s) => s.selectedGroup, 'group', isNull)
            .having((s) => s.selectedTeamCode, 'team', isNull),
        isA<MatchListState>()
            .having((s) => s.filteredMatches.length, 'all matches', 5),
      ],
    );

    blocTest<MatchListCubit, MatchListState>(
      'refreshMatches calls repository and updates state',
      build: () {
        when(() => mockRepository.refreshMatches())
            .thenAnswer((_) async => testMatches);
        when(() => mockRepository.watchLiveMatches())
            .thenAnswer((_) => Stream.value([]));
        return cubit;
      },
      seed: () => const MatchListState(
        matches: [],
        filteredMatches: [],
        isLoading: false,
      ),
      act: (cubit) => cubit.refreshMatches(),
      expect: () => [
        isA<MatchListState>().having((s) => s.isRefreshing, 'refreshing', true),
        isA<MatchListState>()
            .having((s) => s.isRefreshing, 'refreshing', false)
            .having((s) => s.matches.length, 'matches', 5),
        isA<MatchListState>(),
      ],
      verify: (_) {
        verify(() => mockRepository.refreshMatches()).called(1);
      },
    );
  });
}
