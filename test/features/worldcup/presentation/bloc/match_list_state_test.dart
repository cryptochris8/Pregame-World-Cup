import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';

import 'mock_repositories.dart';

void main() {
  group('MatchListState', () {
    late WorldCupMatch testMatchScheduled;
    late WorldCupMatch testMatchLive;
    late WorldCupMatch testMatchCompleted;
    late WorldCupMatch testMatchToday;
    late DateTime testDateTime;
    late DateTime today;

    setUp(() {
      today = DateTime.now();
      testDateTime = DateTime(2026, 6, 15, 10, 30);

      testMatchScheduled = TestDataFactory.createMatch(
        matchId: 'match_1',
        status: MatchStatus.scheduled,
        dateTime: DateTime(2026, 7, 1, 18, 0),
      );

      testMatchLive = TestDataFactory.createMatch(
        matchId: 'match_2',
        status: MatchStatus.inProgress,
        dateTime: DateTime(2026, 6, 15, 14, 0),
      );

      testMatchCompleted = TestDataFactory.createMatch(
        matchId: 'match_3',
        status: MatchStatus.completed,
        homeScore: 2,
        awayScore: 1,
        dateTime: DateTime(2026, 6, 10, 18, 0),
      );

      testMatchToday = TestDataFactory.createMatch(
        matchId: 'match_today',
        status: MatchStatus.scheduled,
        dateTime: DateTime(today.year, today.month, today.day, 18, 0),
      );
    });

    // -------------------------------------------------------
    // 1. Constructor and default values
    // -------------------------------------------------------
    test('constructor creates instance with default values', () {
      const state = MatchListState();

      expect(state.matches, isEmpty);
      expect(state.filteredMatches, isEmpty);
      expect(state.liveMatches, isEmpty);
      expect(state.filter, equals(MatchListFilter.all));
      expect(state.selectedStage, isNull);
      expect(state.selectedGroup, isNull);
      expect(state.selectedTeamCode, isNull);
      expect(state.selectedDate, isNull);
      expect(state.isLoading, isFalse);
      expect(state.isRefreshing, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.lastUpdated, isNull);
    });

    test('constructor creates instance with provided values', () {
      final matches = [testMatchScheduled, testMatchLive];
      final filteredMatches = [testMatchLive];
      final liveMatches = [testMatchLive];

      final state = MatchListState(
        matches: matches,
        filteredMatches: filteredMatches,
        liveMatches: liveMatches,
        filter: MatchListFilter.live,
        selectedStage: MatchStage.groupStage,
        selectedGroup: 'A',
        selectedTeamCode: 'USA',
        selectedDate: testDateTime,
        isLoading: true,
        isRefreshing: true,
        errorMessage: 'Test error',
        lastUpdated: testDateTime,
      );

      expect(state.matches, equals(matches));
      expect(state.filteredMatches, equals(filteredMatches));
      expect(state.liveMatches, equals(liveMatches));
      expect(state.filter, equals(MatchListFilter.live));
      expect(state.selectedStage, equals(MatchStage.groupStage));
      expect(state.selectedGroup, equals('A'));
      expect(state.selectedTeamCode, equals('USA'));
      expect(state.selectedDate, equals(testDateTime));
      expect(state.isLoading, isTrue);
      expect(state.isRefreshing, isTrue);
      expect(state.errorMessage, equals('Test error'));
      expect(state.lastUpdated, equals(testDateTime));
    });

    // -------------------------------------------------------
    // 2. Factory methods
    // -------------------------------------------------------
    test('initial() creates loading state', () {
      final state = MatchListState.initial();

      expect(state.matches, isEmpty);
      expect(state.filter, equals(MatchListFilter.all));
      expect(state.isLoading, isTrue);
      expect(state.isRefreshing, isFalse);
    });

    test('loading() creates loading state', () {
      final state = MatchListState.loading();

      expect(state.matches, isEmpty);
      expect(state.isLoading, isTrue);
    });

    // -------------------------------------------------------
    // 3. MatchListFilter enum
    // -------------------------------------------------------
    test('MatchListFilter has correct values', () {
      expect(MatchListFilter.values.length, equals(8));
      expect(MatchListFilter.values, contains(MatchListFilter.all));
      expect(MatchListFilter.values, contains(MatchListFilter.favorites));
      expect(MatchListFilter.values, contains(MatchListFilter.today));
      expect(MatchListFilter.values, contains(MatchListFilter.upcoming));
      expect(MatchListFilter.values, contains(MatchListFilter.live));
      expect(MatchListFilter.values, contains(MatchListFilter.completed));
      expect(MatchListFilter.values, contains(MatchListFilter.groupStage));
      expect(MatchListFilter.values, contains(MatchListFilter.knockout));
    });

    test('MatchListFilter enum values are distinct', () {
      expect(MatchListFilter.all, isNot(equals(MatchListFilter.live)));
      expect(MatchListFilter.today, isNot(equals(MatchListFilter.upcoming)));
      expect(MatchListFilter.groupStage, isNot(equals(MatchListFilter.knockout)));
    });

    // -------------------------------------------------------
    // 4. copyWith method
    // -------------------------------------------------------
    test('copyWith preserves existing values when no parameters provided', () {
      final matches = [testMatchScheduled];
      final original = MatchListState(
        matches: matches,
        filteredMatches: matches,
        liveMatches: const [],
        filter: MatchListFilter.upcoming,
        selectedStage: MatchStage.roundOf16,
        selectedGroup: 'B',
        selectedTeamCode: 'BRA',
        selectedDate: testDateTime,
        isLoading: true,
        isRefreshing: true,
        errorMessage: 'Error',
        lastUpdated: testDateTime,
      );

      final copied = original.copyWith();

      expect(copied.matches, equals(original.matches));
      expect(copied.filteredMatches, equals(original.filteredMatches));
      expect(copied.liveMatches, equals(original.liveMatches));
      expect(copied.filter, equals(original.filter));
      expect(copied.selectedStage, equals(original.selectedStage));
      expect(copied.selectedGroup, equals(original.selectedGroup));
      expect(copied.selectedTeamCode, equals(original.selectedTeamCode));
      expect(copied.selectedDate, equals(original.selectedDate));
      expect(copied.isLoading, equals(original.isLoading));
      expect(copied.isRefreshing, equals(original.isRefreshing));
      expect(copied.errorMessage, equals(original.errorMessage));
      expect(copied.lastUpdated, equals(original.lastUpdated));
    });

    test('copyWith updates only provided values', () {
      const original = MatchListState(
        filter: MatchListFilter.all,
        isLoading: false,
      );

      final copied = original.copyWith(
        filter: MatchListFilter.live,
        isLoading: true,
      );

      expect(copied.filter, equals(MatchListFilter.live)); // Changed
      expect(copied.isLoading, isTrue); // Changed
    });

    test('copyWith can clear selectedStage with clearStage flag', () {
      const original = MatchListState(
        selectedStage: MatchStage.quarterFinal,
      );

      final copied = original.copyWith(clearStage: true);

      expect(copied.selectedStage, isNull);
    });

    test('copyWith can clear selectedGroup with clearGroup flag', () {
      const original = MatchListState(
        selectedGroup: 'A',
      );

      final copied = original.copyWith(clearGroup: true);

      expect(copied.selectedGroup, isNull);
    });

    test('copyWith can clear selectedTeamCode with clearTeam flag', () {
      const original = MatchListState(
        selectedTeamCode: 'USA',
      );

      final copied = original.copyWith(clearTeam: true);

      expect(copied.selectedTeamCode, isNull);
    });

    test('copyWith can clear selectedDate with clearDate flag', () {
      final original = MatchListState(
        selectedDate: testDateTime,
      );

      final copied = original.copyWith(clearDate: true);

      expect(copied.selectedDate, isNull);
    });

    test('copyWith can clear error with clearError flag', () {
      const original = MatchListState(
        errorMessage: 'Some error',
      );

      final copied = original.copyWith(clearError: true);

      expect(copied.errorMessage, isNull);
    });

    test('copyWith can update matches and filteredMatches', () {
      const original = MatchListState();
      final newMatches = [testMatchScheduled, testMatchLive];
      final newFiltered = [testMatchLive];

      final copied = original.copyWith(
        matches: newMatches,
        filteredMatches: newFiltered,
      );

      expect(copied.matches, equals(newMatches));
      expect(copied.filteredMatches, equals(newFiltered));
    });

    test('copyWith can update all filter fields', () {
      const original = MatchListState();
      final newDate = DateTime(2026, 6, 20);

      final copied = original.copyWith(
        filter: MatchListFilter.groupStage,
        selectedStage: MatchStage.roundOf16,
        selectedGroup: 'C',
        selectedTeamCode: 'GER',
        selectedDate: newDate,
      );

      expect(copied.filter, equals(MatchListFilter.groupStage));
      expect(copied.selectedStage, equals(MatchStage.roundOf16));
      expect(copied.selectedGroup, equals('C'));
      expect(copied.selectedTeamCode, equals('GER'));
      expect(copied.selectedDate, equals(newDate));
    });

    // -------------------------------------------------------
    // 5. Equatable (props)
    // -------------------------------------------------------
    test('two states with same values are equal', () {
      final matches = [testMatchScheduled];

      final state1 = MatchListState(
        matches: matches,
        filteredMatches: matches,
        liveMatches: const [],
        filter: MatchListFilter.all,
        isLoading: false,
        isRefreshing: false,
        errorMessage: null,
        lastUpdated: testDateTime,
      );

      final state2 = MatchListState(
        matches: matches,
        filteredMatches: matches,
        liveMatches: const [],
        filter: MatchListFilter.all,
        isLoading: false,
        isRefreshing: false,
        errorMessage: null,
        lastUpdated: testDateTime,
      );

      expect(state1, equals(state2));
    });

    test('two states with different values are not equal', () {
      const state1 = MatchListState(filter: MatchListFilter.all);
      const state2 = MatchListState(filter: MatchListFilter.live);

      expect(state1, isNot(equals(state2)));
    });

    test('states with different matches are not equal', () {
      final state1 = MatchListState(matches: [testMatchScheduled]);
      final state2 = MatchListState(matches: [testMatchLive]);

      expect(state1, isNot(equals(state2)));
    });

    test('states with different selectedGroup are not equal', () {
      const state1 = MatchListState(selectedGroup: 'A');
      const state2 = MatchListState(selectedGroup: 'B');

      expect(state1, isNot(equals(state2)));
    });

    // -------------------------------------------------------
    // 6. Computed getters: hasLiveMatches, counts
    // -------------------------------------------------------
    test('hasLiveMatches returns true when liveMatches is not empty', () {
      final state = MatchListState(liveMatches: [testMatchLive]);

      expect(state.hasLiveMatches, isTrue);
    });

    test('hasLiveMatches returns false when liveMatches is empty', () {
      const state = MatchListState(liveMatches: []);

      expect(state.hasLiveMatches, isFalse);
    });

    test('liveCount returns correct count', () {
      final state = MatchListState(liveMatches: [testMatchLive, testMatchLive]);

      expect(state.liveCount, equals(2));
    });

    test('liveCount returns zero when no live matches', () {
      const state = MatchListState();

      expect(state.liveCount, equals(0));
    });

    test('upcomingCount returns count of scheduled matches', () {
      final matches = [
        testMatchScheduled,
        testMatchLive,
        testMatchCompleted,
        TestDataFactory.createMatch(matchId: 'match_4', status: MatchStatus.scheduled),
      ];
      final state = MatchListState(matches: matches);

      expect(state.upcomingCount, equals(2)); // Two scheduled matches
    });

    test('upcomingCount returns zero when no scheduled matches', () {
      final matches = [testMatchLive, testMatchCompleted];
      final state = MatchListState(matches: matches);

      expect(state.upcomingCount, equals(0));
    });

    test('completedCount returns count of completed matches', () {
      final matches = [
        testMatchScheduled,
        testMatchLive,
        testMatchCompleted,
        TestDataFactory.createMatch(matchId: 'match_4', status: MatchStatus.completed),
      ];
      final state = MatchListState(matches: matches);

      expect(state.completedCount, equals(2)); // Two completed matches
    });

    test('completedCount returns zero when no completed matches', () {
      final matches = [testMatchScheduled, testMatchLive];
      final state = MatchListState(matches: matches);

      expect(state.completedCount, equals(0));
    });

    // -------------------------------------------------------
    // 7. Computed getter: todaysMatches
    // -------------------------------------------------------
    test('todaysMatches returns matches scheduled for today', () {
      final matchToday2 = TestDataFactory.createMatch(
        matchId: 'match_today_2',
        status: MatchStatus.scheduled,
        dateTime: DateTime(today.year, today.month, today.day, 20, 0),
      );

      final matches = [
        testMatchScheduled, // Future date
        testMatchCompleted, // Past date
        testMatchToday, // Today
        matchToday2, // Today
      ];
      final state = MatchListState(matches: matches);

      final todaysMatches = state.todaysMatches;

      expect(todaysMatches.length, equals(2));
      expect(todaysMatches, contains(testMatchToday));
      expect(todaysMatches, contains(matchToday2));
    });

    test('todaysMatches returns empty list when no matches today', () {
      final matches = [
        testMatchScheduled, // Future
        testMatchCompleted, // Past
      ];
      final state = MatchListState(matches: matches);

      expect(state.todaysMatches, isEmpty);
    });

    test('todaysMatches excludes matches with null dateTime', () {
      final matchNoDate = TestDataFactory.createMatch(
        matchId: 'match_no_date',
        status: MatchStatus.scheduled,
        dateTime: null,
      );

      final matches = [testMatchToday, matchNoDate];
      final state = MatchListState(matches: matches);

      final todaysMatches = state.todaysMatches;

      expect(todaysMatches.length, equals(1));
      expect(todaysMatches[0].matchId, equals('match_today'));
    });

    test('todaysMatches correctly compares year, month, and day', () {
      final tomorrow = today.add(const Duration(days: 1));
      final matchTomorrow = TestDataFactory.createMatch(
        matchId: 'match_tomorrow',
        status: MatchStatus.scheduled,
        dateTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 18, 0),
      );

      final matches = [testMatchToday, matchTomorrow];
      final state = MatchListState(matches: matches);

      final todaysMatches = state.todaysMatches;

      expect(todaysMatches.length, equals(1));
      expect(todaysMatches[0].matchId, equals('match_today'));
    });

    test('todaysMatches works at midnight', () {
      final midnight = DateTime(today.year, today.month, today.day, 0, 0);
      final matchAtMidnight = TestDataFactory.createMatch(
        matchId: 'match_midnight',
        status: MatchStatus.scheduled,
        dateTime: midnight,
      );

      final matches = [matchAtMidnight];
      final state = MatchListState(matches: matches);

      expect(state.todaysMatches.length, equals(1));
    });

    test('todaysMatches works at end of day', () {
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59);
      final matchEndOfDay = TestDataFactory.createMatch(
        matchId: 'match_eod',
        status: MatchStatus.scheduled,
        dateTime: endOfDay,
      );

      final matches = [matchEndOfDay];
      final state = MatchListState(matches: matches);

      expect(state.todaysMatches.length, equals(1));
    });
  });
}
