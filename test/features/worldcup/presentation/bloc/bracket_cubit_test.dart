import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';

import 'mock_repositories.dart';

void main() {
  late MockBracketRepository mockRepository;
  late BracketCubit cubit;

  setUp(() {
    mockRepository = MockBracketRepository();
    cubit = BracketCubit(bracketRepository: mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('BracketCubit', () {
    final testBracket = TestDataFactory.createBracket();

    test('initial state is correct', () {
      expect(cubit.state, equals(BracketState.initial()));
      expect(cubit.state.isLoading, isTrue);
      expect(cubit.state.bracket, isNull);
    });

    blocTest<BracketCubit, BracketState>(
      'loadBracket emits loaded state with bracket',
      build: () {
        when(() => mockRepository.getBracket())
            .thenAnswer((_) async => testBracket);
        return cubit;
      },
      act: (cubit) => cubit.loadBracket(),
      expect: () => [
        isA<BracketState>().having((s) => s.isLoading, 'isLoading', true),
        isA<BracketState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.bracket, 'bracket', isNotNull),
        // Focus on active round
        isA<BracketState>(),
      ],
      verify: (_) {
        verify(() => mockRepository.getBracket()).called(1);
      },
    );

    blocTest<BracketCubit, BracketState>(
      'loadBracket handles errors',
      build: () {
        when(() => mockRepository.getBracket())
            .thenThrow(Exception('Network error'));
        return cubit;
      },
      act: (cubit) => cubit.loadBracket(),
      expect: () => [
        isA<BracketState>().having((s) => s.isLoading, 'isLoading', true),
        isA<BracketState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.errorMessage, 'has error', isNotNull),
      ],
    );

    blocTest<BracketCubit, BracketState>(
      'setViewMode updates view mode',
      build: () => cubit,
      seed: () => BracketState(
        bracket: testBracket,
        viewMode: BracketViewMode.full,
        isLoading: false,
      ),
      act: (cubit) => cubit.setViewMode(BracketViewMode.byRound),
      expect: () => [
        isA<BracketState>()
            .having((s) => s.viewMode, 'mode', BracketViewMode.byRound),
      ],
    );

    blocTest<BracketCubit, BracketState>(
      'focusRound updates focused round',
      build: () => cubit,
      seed: () => BracketState(
        bracket: testBracket,
        isLoading: false,
      ),
      act: (cubit) => cubit.focusRound(MatchStage.quarterFinal),
      expect: () => [
        isA<BracketState>()
            .having((s) => s.focusedRound, 'round', MatchStage.quarterFinal),
      ],
    );

    blocTest<BracketCubit, BracketState>(
      'clearFocusedRound clears focus',
      build: () => cubit,
      seed: () => BracketState(
        bracket: testBracket,
        focusedRound: MatchStage.quarterFinal,
        isLoading: false,
      ),
      act: (cubit) => cubit.clearFocusedRound(),
      expect: () => [
        isA<BracketState>().having((s) => s.focusedRound, 'round', isNull),
      ],
    );

    blocTest<BracketCubit, BracketState>(
      'selectMatch updates selectedMatch',
      build: () => cubit,
      seed: () => BracketState(
        bracket: testBracket,
        isLoading: false,
      ),
      act: (cubit) => cubit.selectMatch(testBracket.roundOf16.first),
      expect: () => [
        isA<BracketState>()
            .having((s) => s.selectedMatch, 'match', testBracket.roundOf16.first),
      ],
    );

    blocTest<BracketCubit, BracketState>(
      'clearSelectedMatch clears selection',
      build: () => cubit,
      seed: () => BracketState(
        bracket: testBracket,
        selectedMatch: testBracket.roundOf16.first,
        isLoading: false,
      ),
      act: (cubit) => cubit.clearSelectedMatch(),
      expect: () => [
        isA<BracketState>().having((s) => s.selectedMatch, 'match', isNull),
      ],
    );

    test('getTeamPath returns matches involving team', () {
      cubit.emit(BracketState(
        bracket: testBracket,
        isLoading: false,
      ));

      final path = cubit.getTeamPath('USA');
      expect(path, isNotEmpty);
    });

    test('getLiveMatches returns live bracket matches', () {
      // Create bracket with a live match
      final liveMatch = TestDataFactory.createBracketMatch(
        matchId: 'live_qf',
        stage: MatchStage.quarterFinal,
        matchNumberInStage: 1,
        homeSlot: TestDataFactory.createBracketSlot(
          slotId: 'live_qf_home',
          stage: MatchStage.quarterFinal,
          teamCode: 'USA',
          teamNameOrPlaceholder: 'United States',
          score: 1,
        ),
        awaySlot: TestDataFactory.createBracketSlot(
          slotId: 'live_qf_away',
          stage: MatchStage.quarterFinal,
          teamCode: 'BRA',
          teamNameOrPlaceholder: 'Brazil',
          score: 1,
        ),
        status: MatchStatus.inProgress,
        dateTime: DateTime.now(),
      );

      final bracketWithLive = WorldCupBracket(
        roundOf32: testBracket.roundOf32,
        roundOf16: testBracket.roundOf16,
        quarterFinals: [liveMatch, ...testBracket.quarterFinals.skip(1)],
        semiFinals: testBracket.semiFinals,
        thirdPlace: testBracket.thirdPlace,
        finalMatch: testBracket.finalMatch,
      );

      cubit.emit(BracketState(
        bracket: bracketWithLive,
        isLoading: false,
      ));

      final liveMatches = cubit.getLiveMatches();
      expect(liveMatches.length, 1);
      expect(liveMatches.first.matchId, 'live_qf');
    });

    test('getUpcomingMatches returns scheduled matches', () {
      cubit.emit(BracketState(
        bracket: testBracket,
        isLoading: false,
      ));

      final upcoming = cubit.getUpcomingMatches(limit: 4);
      expect(upcoming.length, lessThanOrEqualTo(4));
    });

    blocTest<BracketCubit, BracketState>(
      'refreshBracket calls repository and updates state',
      build: () {
        when(() => mockRepository.refreshBracket())
            .thenAnswer((_) async => testBracket);
        return cubit;
      },
      seed: () => const BracketState(
        bracket: null,
        isLoading: false,
      ),
      act: (cubit) => cubit.refreshBracket(),
      expect: () => [
        isA<BracketState>().having((s) => s.isRefreshing, 'refreshing', true),
        isA<BracketState>()
            .having((s) => s.isRefreshing, 'refreshing', false)
            .having((s) => s.bracket, 'bracket', isNotNull),
      ],
      verify: (_) {
        verify(() => mockRepository.refreshBracket()).called(1);
      },
    );
  });
}
