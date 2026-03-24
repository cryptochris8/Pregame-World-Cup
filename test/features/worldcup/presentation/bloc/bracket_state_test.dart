import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';

import 'mock_repositories.dart';

void main() {
  group('BracketState', () {
    late WorldCupBracket testBracket;
    late BracketMatch testMatch;
    late DateTime testDateTime;

    setUp(() {
      testBracket = TestDataFactory.createBracket();
      testMatch = TestDataFactory.createBracketMatch(
        matchId: 'test_match',
        stage: MatchStage.roundOf16,
      );
      testDateTime = DateTime(2026, 7, 1, 14, 0);
    });

    // -------------------------------------------------------
    // 1. Constructor and default values
    // -------------------------------------------------------
    test('constructor creates instance with default values', () {
      const state = BracketState();

      expect(state.bracket, isNull);
      expect(state.selectedMatch, isNull);
      expect(state.viewMode, equals(BracketViewMode.full));
      expect(state.focusedRound, isNull);
      expect(state.isLoading, isFalse);
      expect(state.isRefreshing, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.lastUpdated, isNull);
    });

    test('constructor creates instance with provided values', () {
      final state = BracketState(
        bracket: testBracket,
        selectedMatch: testMatch,
        viewMode: BracketViewMode.byRound,
        focusedRound: MatchStage.quarterFinal,
        isLoading: true,
        isRefreshing: true,
        errorMessage: 'Test error',
        lastUpdated: testDateTime,
      );

      expect(state.bracket, equals(testBracket));
      expect(state.selectedMatch, equals(testMatch));
      expect(state.viewMode, equals(BracketViewMode.byRound));
      expect(state.focusedRound, equals(MatchStage.quarterFinal));
      expect(state.isLoading, isTrue);
      expect(state.isRefreshing, isTrue);
      expect(state.errorMessage, equals('Test error'));
      expect(state.lastUpdated, equals(testDateTime));
    });

    // -------------------------------------------------------
    // 2. Factory: initial
    // -------------------------------------------------------
    test('initial() creates loading state', () {
      final state = BracketState.initial();

      expect(state.bracket, isNull);
      expect(state.selectedMatch, isNull);
      expect(state.viewMode, equals(BracketViewMode.full));
      expect(state.focusedRound, isNull);
      expect(state.isLoading, isTrue);
      expect(state.isRefreshing, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.lastUpdated, isNull);
    });

    // -------------------------------------------------------
    // 3. BracketViewMode enum
    // -------------------------------------------------------
    test('BracketViewMode has correct values', () {
      expect(BracketViewMode.values.length, equals(3));
      expect(BracketViewMode.values, contains(BracketViewMode.full));
      expect(BracketViewMode.values, contains(BracketViewMode.byRound));
      expect(BracketViewMode.values, contains(BracketViewMode.interactive));
    });

    test('BracketViewMode enum values are distinct', () {
      expect(BracketViewMode.full, isNot(equals(BracketViewMode.byRound)));
      expect(BracketViewMode.full, isNot(equals(BracketViewMode.interactive)));
      expect(BracketViewMode.byRound, isNot(equals(BracketViewMode.interactive)));
    });

    // -------------------------------------------------------
    // 4. copyWith method
    // -------------------------------------------------------
    test('copyWith preserves existing values when no parameters provided', () {
      final original = BracketState(
        bracket: testBracket,
        selectedMatch: testMatch,
        viewMode: BracketViewMode.byRound,
        focusedRound: MatchStage.semiFinal,
        isLoading: true,
        isRefreshing: true,
        errorMessage: 'Error',
        lastUpdated: testDateTime,
      );

      final copied = original.copyWith();

      expect(copied.bracket, equals(original.bracket));
      expect(copied.selectedMatch, equals(original.selectedMatch));
      expect(copied.viewMode, equals(original.viewMode));
      expect(copied.focusedRound, equals(original.focusedRound));
      expect(copied.isLoading, equals(original.isLoading));
      expect(copied.isRefreshing, equals(original.isRefreshing));
      expect(copied.errorMessage, equals(original.errorMessage));
      expect(copied.lastUpdated, equals(original.lastUpdated));
    });

    test('copyWith updates only provided values', () {
      final original = BracketState(
        bracket: testBracket,
        viewMode: BracketViewMode.full,
        isLoading: false,
      );

      final copied = original.copyWith(
        viewMode: BracketViewMode.byRound,
        isLoading: true,
      );

      expect(copied.bracket, equals(original.bracket));
      expect(copied.viewMode, equals(BracketViewMode.byRound)); // Changed
      expect(copied.isLoading, isTrue); // Changed
    });

    test('copyWith can clear selectedMatch with clearSelectedMatch flag', () {
      final original = BracketState(
        selectedMatch: testMatch,
      );

      final copied = original.copyWith(clearSelectedMatch: true);

      expect(copied.selectedMatch, isNull);
    });

    test('copyWith can clear focusedRound with clearFocusedRound flag', () {
      const original = BracketState(
        focusedRound: MatchStage.quarterFinal,
      );

      final copied = original.copyWith(clearFocusedRound: true);

      expect(copied.focusedRound, isNull);
    });

    test('copyWith can clear error with clearError flag', () {
      const original = BracketState(
        errorMessage: 'Some error',
      );

      final copied = original.copyWith(clearError: true);

      expect(copied.errorMessage, isNull);
    });

    test('copyWith can update bracket', () {
      const original = BracketState();
      final copied = original.copyWith(bracket: testBracket);

      expect(copied.bracket, equals(testBracket));
    });

    test('copyWith can update all view-related fields', () {
      const original = BracketState();
      final copied = original.copyWith(
        viewMode: BracketViewMode.interactive,
        focusedRound: MatchStage.final_,
      );

      expect(copied.viewMode, equals(BracketViewMode.interactive));
      expect(copied.focusedRound, equals(MatchStage.final_));
    });

    // -------------------------------------------------------
    // 5. Equatable (props)
    // -------------------------------------------------------
    test('two states with same values are equal', () {
      final state1 = BracketState(
        bracket: testBracket,
        selectedMatch: testMatch,
        viewMode: BracketViewMode.full,
        focusedRound: MatchStage.semiFinal,
        isLoading: false,
        isRefreshing: false,
        errorMessage: null,
        lastUpdated: testDateTime,
      );

      final state2 = BracketState(
        bracket: testBracket,
        selectedMatch: testMatch,
        viewMode: BracketViewMode.full,
        focusedRound: MatchStage.semiFinal,
        isLoading: false,
        isRefreshing: false,
        errorMessage: null,
        lastUpdated: testDateTime,
      );

      expect(state1, equals(state2));
    });

    test('two states with different values are not equal', () {
      final state1 = BracketState(
        bracket: testBracket,
        viewMode: BracketViewMode.full,
      );

      final state2 = BracketState(
        bracket: testBracket,
        viewMode: BracketViewMode.byRound,
      );

      expect(state1, isNot(equals(state2)));
    });

    test('states with different selectedMatch are not equal', () {
      final match2 = TestDataFactory.createBracketMatch(
        matchId: 'different',
        stage: MatchStage.quarterFinal,
      );

      final state1 = BracketState(selectedMatch: testMatch);
      final state2 = BracketState(selectedMatch: match2);

      expect(state1, isNot(equals(state2)));
    });

    // -------------------------------------------------------
    // 6. Computed methods: getMatchesForRound
    // -------------------------------------------------------
    test('getMatchesForRound returns empty list when bracket is null', () {
      const state = BracketState(bracket: null);

      expect(state.getMatchesForRound(MatchStage.roundOf16), isEmpty);
      expect(state.getMatchesForRound(MatchStage.quarterFinal), isEmpty);
    });

    test('getMatchesForRound returns correct matches for roundOf32', () {
      final state = BracketState(bracket: testBracket);

      final matches = state.getMatchesForRound(MatchStage.roundOf32);

      expect(matches, equals(testBracket.roundOf32));
      expect(matches.length, equals(16));
    });

    test('getMatchesForRound returns correct matches for roundOf16', () {
      final state = BracketState(bracket: testBracket);

      final matches = state.getMatchesForRound(MatchStage.roundOf16);

      expect(matches, equals(testBracket.roundOf16));
      expect(matches.length, equals(8));
    });

    test('getMatchesForRound returns correct matches for quarterFinal', () {
      final state = BracketState(bracket: testBracket);

      final matches = state.getMatchesForRound(MatchStage.quarterFinal);

      expect(matches, equals(testBracket.quarterFinals));
      expect(matches.length, equals(4));
    });

    test('getMatchesForRound returns correct matches for semiFinal', () {
      final state = BracketState(bracket: testBracket);

      final matches = state.getMatchesForRound(MatchStage.semiFinal);

      expect(matches, equals(testBracket.semiFinals));
      expect(matches.length, equals(2));
    });

    test('getMatchesForRound returns single match for thirdPlace', () {
      final state = BracketState(bracket: testBracket);

      final matches = state.getMatchesForRound(MatchStage.thirdPlace);

      expect(matches, equals([testBracket.thirdPlace]));
      expect(matches.length, equals(1));
    });

    test('getMatchesForRound returns single match for final', () {
      final state = BracketState(bracket: testBracket);

      final matches = state.getMatchesForRound(MatchStage.final_);

      expect(matches, equals([testBracket.finalMatch]));
      expect(matches.length, equals(1));
    });

    test('getMatchesForRound returns empty list for non-knockout stages', () {
      final state = BracketState(bracket: testBracket);

      expect(state.getMatchesForRound(MatchStage.groupStage), isEmpty);
    });

    test('getMatchesForRound handles null thirdPlace match', () {
      final bracketWithoutThirdPlace = WorldCupBracket(
        roundOf32: testBracket.roundOf32,
        roundOf16: testBracket.roundOf16,
        quarterFinals: testBracket.quarterFinals,
        semiFinals: testBracket.semiFinals,
        thirdPlace: null,
        finalMatch: testBracket.finalMatch,
      );
      final state = BracketState(bracket: bracketWithoutThirdPlace);

      final matches = state.getMatchesForRound(MatchStage.thirdPlace);

      expect(matches, isEmpty);
    });

    test('getMatchesForRound handles null finalMatch', () {
      final bracketWithoutFinal = WorldCupBracket(
        roundOf32: testBracket.roundOf32,
        roundOf16: testBracket.roundOf16,
        quarterFinals: testBracket.quarterFinals,
        semiFinals: testBracket.semiFinals,
        thirdPlace: testBracket.thirdPlace,
        finalMatch: null,
      );
      final state = BracketState(bracket: bracketWithoutFinal);

      final matches = state.getMatchesForRound(MatchStage.final_);

      expect(matches, isEmpty);
    });

    // -------------------------------------------------------
    // 7. Computed getter: isBracketComplete
    // -------------------------------------------------------
    test('isBracketComplete returns false when bracket is null', () {
      const state = BracketState(bracket: null);

      expect(state.isBracketComplete, isFalse);
    });

    test('isBracketComplete returns false when final match is null', () {
      final bracketWithoutFinal = WorldCupBracket(
        roundOf32: testBracket.roundOf32,
        roundOf16: testBracket.roundOf16,
        quarterFinals: testBracket.quarterFinals,
        semiFinals: testBracket.semiFinals,
        thirdPlace: testBracket.thirdPlace,
        finalMatch: null,
      );
      final state = BracketState(bracket: bracketWithoutFinal);

      expect(state.isBracketComplete, isFalse);
    });

    test('isBracketComplete returns false when final match is not complete', () {
      final incompleteFinal = TestDataFactory.createBracketMatch(
        matchId: 'final',
        stage: MatchStage.final_,
        status: MatchStatus.scheduled,
      );
      final bracketWithIncompleteFinal = WorldCupBracket(
        roundOf32: testBracket.roundOf32,
        roundOf16: testBracket.roundOf16,
        quarterFinals: testBracket.quarterFinals,
        semiFinals: testBracket.semiFinals,
        thirdPlace: testBracket.thirdPlace,
        finalMatch: incompleteFinal,
      );
      final state = BracketState(bracket: bracketWithIncompleteFinal);

      expect(state.isBracketComplete, isFalse);
    });

    test('isBracketComplete returns true when final match is complete', () {
      final completeFinal = TestDataFactory.createBracketMatch(
        matchId: 'final',
        stage: MatchStage.final_,
        status: MatchStatus.completed,
      );
      final completeBracket = WorldCupBracket(
        roundOf32: testBracket.roundOf32,
        roundOf16: testBracket.roundOf16,
        quarterFinals: testBracket.quarterFinals,
        semiFinals: testBracket.semiFinals,
        thirdPlace: testBracket.thirdPlace,
        finalMatch: completeFinal,
      );
      final state = BracketState(bracket: completeBracket);

      expect(state.isBracketComplete, isTrue);
    });

    // -------------------------------------------------------
    // 8. Computed getter: currentActiveRound
    // -------------------------------------------------------
    test('currentActiveRound returns null when bracket is null', () {
      const state = BracketState(bracket: null);

      expect(state.currentActiveRound, isNull);
    });

    test('currentActiveRound returns roundOf32 when it has incomplete matches', () {
      final incompleteR32 = testBracket.roundOf32.map((m) => TestDataFactory.createBracketMatch(
        matchId: m.matchId,
        stage: MatchStage.roundOf32,
        status: MatchStatus.scheduled,
      )).toList();

      final bracket = WorldCupBracket(
        roundOf32: incompleteR32,
        roundOf16: testBracket.roundOf16,
        quarterFinals: testBracket.quarterFinals,
        semiFinals: testBracket.semiFinals,
        thirdPlace: testBracket.thirdPlace,
        finalMatch: testBracket.finalMatch,
      );
      final state = BracketState(bracket: bracket);

      expect(state.currentActiveRound, equals(MatchStage.roundOf32));
    });

    test('currentActiveRound returns roundOf16 when roundOf32 is complete but roundOf16 is not', () {
      final completeR32 = testBracket.roundOf32.map((m) => TestDataFactory.createBracketMatch(
        matchId: m.matchId,
        stage: MatchStage.roundOf32,
        status: MatchStatus.completed,
      )).toList();

      final incompleteR16 = testBracket.roundOf16.map((m) => TestDataFactory.createBracketMatch(
        matchId: m.matchId,
        stage: MatchStage.roundOf16,
        status: MatchStatus.scheduled,
      )).toList();

      final bracket = WorldCupBracket(
        roundOf32: completeR32,
        roundOf16: incompleteR16,
        quarterFinals: testBracket.quarterFinals,
        semiFinals: testBracket.semiFinals,
        thirdPlace: testBracket.thirdPlace,
        finalMatch: testBracket.finalMatch,
      );
      final state = BracketState(bracket: bracket);

      expect(state.currentActiveRound, equals(MatchStage.roundOf16));
    });

    test('currentActiveRound returns null when all matches are complete', () {
      final completeR32 = testBracket.roundOf32.map((m) => TestDataFactory.createBracketMatch(
        matchId: m.matchId,
        stage: MatchStage.roundOf32,
        status: MatchStatus.completed,
      )).toList();

      final completeR16 = testBracket.roundOf16.map((m) => TestDataFactory.createBracketMatch(
        matchId: m.matchId,
        stage: MatchStage.roundOf16,
        status: MatchStatus.completed,
      )).toList();

      final completeQF = testBracket.quarterFinals.map((m) => TestDataFactory.createBracketMatch(
        matchId: m.matchId,
        stage: MatchStage.quarterFinal,
        status: MatchStatus.completed,
      )).toList();

      final completeSF = testBracket.semiFinals.map((m) => TestDataFactory.createBracketMatch(
        matchId: m.matchId,
        stage: MatchStage.semiFinal,
        status: MatchStatus.completed,
      )).toList();

      final completeThird = TestDataFactory.createBracketMatch(
        matchId: '3rd',
        stage: MatchStage.thirdPlace,
        status: MatchStatus.completed,
      );

      final completeFinal = TestDataFactory.createBracketMatch(
        matchId: 'final',
        stage: MatchStage.final_,
        status: MatchStatus.completed,
      );

      final bracket = WorldCupBracket(
        roundOf32: completeR32,
        roundOf16: completeR16,
        quarterFinals: completeQF,
        semiFinals: completeSF,
        thirdPlace: completeThird,
        finalMatch: completeFinal,
      );
      final state = BracketState(bracket: bracket);

      expect(state.currentActiveRound, isNull);
    });

    test('currentActiveRound returns final when only final is incomplete', () {
      final completeR32 = testBracket.roundOf32.map((m) => TestDataFactory.createBracketMatch(
        matchId: m.matchId,
        stage: MatchStage.roundOf32,
        status: MatchStatus.completed,
      )).toList();

      final completeR16 = testBracket.roundOf16.map((m) => TestDataFactory.createBracketMatch(
        matchId: m.matchId,
        stage: MatchStage.roundOf16,
        status: MatchStatus.completed,
      )).toList();

      final completeQF = testBracket.quarterFinals.map((m) => TestDataFactory.createBracketMatch(
        matchId: m.matchId,
        stage: MatchStage.quarterFinal,
        status: MatchStatus.completed,
      )).toList();

      final completeSF = testBracket.semiFinals.map((m) => TestDataFactory.createBracketMatch(
        matchId: m.matchId,
        stage: MatchStage.semiFinal,
        status: MatchStatus.completed,
      )).toList();

      final completeThird = TestDataFactory.createBracketMatch(
        matchId: '3rd',
        stage: MatchStage.thirdPlace,
        status: MatchStatus.completed,
      );

      final incompleteFinal = TestDataFactory.createBracketMatch(
        matchId: 'final',
        stage: MatchStage.final_,
        status: MatchStatus.scheduled,
      );

      final bracket = WorldCupBracket(
        roundOf32: completeR32,
        roundOf16: completeR16,
        quarterFinals: completeQF,
        semiFinals: completeSF,
        thirdPlace: completeThird,
        finalMatch: incompleteFinal,
      );
      final state = BracketState(bracket: bracket);

      expect(state.currentActiveRound, equals(MatchStage.final_));
    });
  });
}
