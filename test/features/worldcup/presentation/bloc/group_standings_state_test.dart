import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';

import 'mock_repositories.dart';

void main() {
  group('GroupStandingsState', () {
    late WorldCupGroup testGroupA;
    late WorldCupGroup testGroupB;
    late DateTime testDateTime;

    setUp(() {
      testGroupA = TestDataFactory.createGroup(groupLetter: 'A');
      testGroupB = TestDataFactory.createGroup(groupLetter: 'B');
      testDateTime = DateTime(2026, 6, 15, 10, 30);
    });

    // -------------------------------------------------------
    // 1. Constructor and default values
    // -------------------------------------------------------
    test('constructor creates instance with default values', () {
      const state = GroupStandingsState();

      expect(state.groups, isEmpty);
      expect(state.selectedGroup, isNull);
      expect(state.isLoading, isFalse);
      expect(state.isRefreshing, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.lastUpdated, isNull);
    });

    test('constructor creates instance with provided values', () {
      final groups = [testGroupA, testGroupB];
      final state = GroupStandingsState(
        groups: groups,
        selectedGroup: testGroupA,
        isLoading: true,
        isRefreshing: true,
        errorMessage: 'Test error',
        lastUpdated: testDateTime,
      );

      expect(state.groups, equals(groups));
      expect(state.selectedGroup, equals(testGroupA));
      expect(state.isLoading, isTrue);
      expect(state.isRefreshing, isTrue);
      expect(state.errorMessage, equals('Test error'));
      expect(state.lastUpdated, equals(testDateTime));
    });

    // -------------------------------------------------------
    // 2. Factory: initial
    // -------------------------------------------------------
    test('initial() creates loading state', () {
      final state = GroupStandingsState.initial();

      expect(state.groups, isEmpty);
      expect(state.selectedGroup, isNull);
      expect(state.isLoading, isTrue);
      expect(state.isRefreshing, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.lastUpdated, isNull);
    });

    // -------------------------------------------------------
    // 3. copyWith method
    // -------------------------------------------------------
    test('copyWith preserves existing values when no parameters provided', () {
      final groups = [testGroupA];
      final original = GroupStandingsState(
        groups: groups,
        selectedGroup: testGroupA,
        isLoading: true,
        isRefreshing: true,
        errorMessage: 'Error',
        lastUpdated: testDateTime,
      );

      final copied = original.copyWith();

      expect(copied.groups, equals(original.groups));
      expect(copied.selectedGroup, equals(original.selectedGroup));
      expect(copied.isLoading, equals(original.isLoading));
      expect(copied.isRefreshing, equals(original.isRefreshing));
      expect(copied.errorMessage, equals(original.errorMessage));
      expect(copied.lastUpdated, equals(original.lastUpdated));
    });

    test('copyWith updates only provided values', () {
      final original = GroupStandingsState(
        groups: [testGroupA],
        selectedGroup: testGroupA,
        isLoading: false,
        errorMessage: 'Old error',
      );

      final copied = original.copyWith(
        isLoading: true,
        errorMessage: 'New error',
      );

      expect(copied.groups, equals(original.groups));
      expect(copied.selectedGroup, equals(original.selectedGroup));
      expect(copied.isLoading, isTrue); // Changed
      expect(copied.errorMessage, equals('New error')); // Changed
    });

    test('copyWith can clear selectedGroup with clearSelectedGroup flag', () {
      final original = GroupStandingsState(
        selectedGroup: testGroupA,
      );

      final copied = original.copyWith(clearSelectedGroup: true);

      expect(copied.selectedGroup, isNull);
    });

    test('copyWith can clear error with clearError flag', () {
      const original = GroupStandingsState(
        errorMessage: 'Some error',
      );

      final copied = original.copyWith(clearError: true);

      expect(copied.errorMessage, isNull);
    });

    test('copyWith can update groups list', () {
      final original = GroupStandingsState(groups: [testGroupA]);
      final newGroups = [testGroupA, testGroupB];

      final copied = original.copyWith(groups: newGroups);

      expect(copied.groups, equals(newGroups));
      expect(copied.groups.length, equals(2));
    });

    test('copyWith can update lastUpdated', () {
      const original = GroupStandingsState();
      final newDateTime = DateTime(2026, 7, 1);

      final copied = original.copyWith(lastUpdated: newDateTime);

      expect(copied.lastUpdated, equals(newDateTime));
    });

    // -------------------------------------------------------
    // 4. Equatable (props)
    // -------------------------------------------------------
    test('two states with same values are equal', () {
      final state1 = GroupStandingsState(
        groups: [testGroupA],
        selectedGroup: testGroupA,
        isLoading: false,
        isRefreshing: false,
        errorMessage: null,
        lastUpdated: testDateTime,
      );

      final state2 = GroupStandingsState(
        groups: [testGroupA],
        selectedGroup: testGroupA,
        isLoading: false,
        isRefreshing: false,
        errorMessage: null,
        lastUpdated: testDateTime,
      );

      expect(state1, equals(state2));
    });

    test('two states with different values are not equal', () {
      final state1 = GroupStandingsState(
        groups: [testGroupA],
        isLoading: false,
      );

      final state2 = GroupStandingsState(
        groups: [testGroupA],
        isLoading: true,
      );

      expect(state1, isNot(equals(state2)));
    });

    test('states with different groups are not equal', () {
      final state1 = GroupStandingsState(groups: [testGroupA]);
      final state2 = GroupStandingsState(groups: [testGroupB]);

      expect(state1, isNot(equals(state2)));
    });

    test('states with different selectedGroup are not equal', () {
      final state1 = GroupStandingsState(selectedGroup: testGroupA);
      final state2 = GroupStandingsState(selectedGroup: testGroupB);

      expect(state1, isNot(equals(state2)));
    });

    // -------------------------------------------------------
    // 5. Computed getters and methods
    // -------------------------------------------------------
    test('getGroup returns correct group by letter (case insensitive)', () {
      final state = GroupStandingsState(
        groups: [testGroupA, testGroupB],
      );

      expect(state.getGroup('A'), equals(testGroupA));
      expect(state.getGroup('a'), equals(testGroupA));
      expect(state.getGroup('B'), equals(testGroupB));
      expect(state.getGroup('b'), equals(testGroupB));
    });

    test('getGroup returns null for non-existent group', () {
      final state = GroupStandingsState(
        groups: [testGroupA],
      );

      expect(state.getGroup('Z'), isNull);
      expect(state.getGroup(''), isNull);
    });

    test('getGroup returns null when groups list is empty', () {
      const state = GroupStandingsState(groups: []);

      expect(state.getGroup('A'), isNull);
    });

    test('groupLetters returns list of all group letters', () {
      final groupC = TestDataFactory.createGroup(groupLetter: 'C');
      final state = GroupStandingsState(
        groups: [testGroupA, testGroupB, groupC],
      );

      final letters = state.groupLetters;

      expect(letters, equals(['A', 'B', 'C']));
      expect(letters.length, equals(3));
    });

    test('groupLetters returns empty list when no groups', () {
      const state = GroupStandingsState(groups: []);

      expect(state.groupLetters, isEmpty);
    });

    test('groupLetters maintains order of groups', () {
      final groupD = TestDataFactory.createGroup(groupLetter: 'D');
      final state = GroupStandingsState(
        groups: [groupD, testGroupA, testGroupB],
      );

      expect(state.groupLetters, equals(['D', 'A', 'B']));
    });
  });
}
