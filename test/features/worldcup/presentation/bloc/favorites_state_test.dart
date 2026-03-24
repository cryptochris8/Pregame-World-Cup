import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';

import 'mock_repositories.dart';

void main() {
  group('FavoritesState', () {
    late UserPreferences testPreferences;
    late NationalTeam testTeamUSA;
    late NationalTeam testTeamBRA;
    late WorldCupMatch testMatch1;
    late WorldCupMatch testMatch2;

    setUp(() {
      testPreferences = TestDataFactory.createUserPreferences(
        favoriteTeamCodes: ['USA', 'BRA'],
        favoriteMatchIds: ['match_1', 'match_2'],
      );
      testTeamUSA = TestDataFactory.createTeam(teamCode: 'USA', countryName: 'United States');
      testTeamBRA = TestDataFactory.createTeam(teamCode: 'BRA', countryName: 'Brazil');
      testMatch1 = TestDataFactory.createMatch(matchId: 'match_1');
      testMatch2 = TestDataFactory.createMatch(matchId: 'match_2');
    });

    // -------------------------------------------------------
    // 1. Constructor and default values
    // -------------------------------------------------------
    test('constructor creates instance with default values', () {
      const state = FavoritesState();

      expect(state.preferences, equals(const UserPreferences()));
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.favoriteTeams, isEmpty);
      expect(state.favoriteMatches, isEmpty);
    });

    test('constructor creates instance with provided values', () {
      final favoriteTeams = [testTeamUSA, testTeamBRA];
      final favoriteMatches = [testMatch1, testMatch2];

      final state = FavoritesState(
        preferences: testPreferences,
        isLoading: true,
        errorMessage: 'Test error',
        favoriteTeams: favoriteTeams,
        favoriteMatches: favoriteMatches,
      );

      expect(state.preferences, equals(testPreferences));
      expect(state.isLoading, isTrue);
      expect(state.errorMessage, equals('Test error'));
      expect(state.favoriteTeams, equals(favoriteTeams));
      expect(state.favoriteMatches, equals(favoriteMatches));
    });

    // -------------------------------------------------------
    // 2. Factory: initial
    // -------------------------------------------------------
    test('initial() creates loading state', () {
      final state = FavoritesState.initial();

      expect(state.preferences, equals(const UserPreferences()));
      expect(state.isLoading, isTrue);
      expect(state.errorMessage, isNull);
      expect(state.favoriteTeams, isEmpty);
      expect(state.favoriteMatches, isEmpty);
    });

    // -------------------------------------------------------
    // 3. copyWith method
    // -------------------------------------------------------
    test('copyWith preserves existing values when no parameters provided', () {
      final favoriteTeams = [testTeamUSA];
      final favoriteMatches = [testMatch1];

      final original = FavoritesState(
        preferences: testPreferences,
        isLoading: true,
        errorMessage: 'Error',
        favoriteTeams: favoriteTeams,
        favoriteMatches: favoriteMatches,
      );

      final copied = original.copyWith();

      expect(copied.preferences, equals(original.preferences));
      expect(copied.isLoading, equals(original.isLoading));
      expect(copied.errorMessage, equals(original.errorMessage));
      expect(copied.favoriteTeams, equals(original.favoriteTeams));
      expect(copied.favoriteMatches, equals(original.favoriteMatches));
    });

    test('copyWith updates only provided values', () {
      const original = FavoritesState(
        isLoading: false,
        errorMessage: 'Old error',
      );

      const newPreferences = UserPreferences(favoriteTeamCodes: ['USA']);

      final copied = original.copyWith(
        preferences: newPreferences,
        isLoading: true,
      );

      expect(copied.preferences, equals(newPreferences)); // Changed
      expect(copied.isLoading, isTrue); // Changed
      expect(copied.errorMessage, equals('Old error')); // Unchanged
    });

    test('copyWith can clear error with clearError flag', () {
      const original = FavoritesState(
        errorMessage: 'Some error',
      );

      final copied = original.copyWith(clearError: true);

      expect(copied.errorMessage, isNull);
    });

    test('copyWith can update favoriteTeams list', () {
      const original = FavoritesState();
      final newTeams = [testTeamUSA, testTeamBRA];

      final copied = original.copyWith(favoriteTeams: newTeams);

      expect(copied.favoriteTeams, equals(newTeams));
      expect(copied.favoriteTeams.length, equals(2));
    });

    test('copyWith can update favoriteMatches list', () {
      const original = FavoritesState();
      final newMatches = [testMatch1, testMatch2];

      final copied = original.copyWith(favoriteMatches: newMatches);

      expect(copied.favoriteMatches, equals(newMatches));
      expect(copied.favoriteMatches.length, equals(2));
    });

    test('copyWith can update preferences', () {
      const original = FavoritesState();
      const newPreferences = UserPreferences(
        favoriteTeamCodes: ['GER', 'FRA'],
        notifyGoals: true,
      );

      final copied = original.copyWith(preferences: newPreferences);

      expect(copied.preferences, equals(newPreferences));
      expect(copied.preferences.favoriteTeamCodes, equals(['GER', 'FRA']));
    });

    // -------------------------------------------------------
    // 4. Equatable (props)
    // -------------------------------------------------------
    test('two states with same values are equal', () {
      final favoriteTeams = [testTeamUSA];
      final favoriteMatches = [testMatch1];

      final state1 = FavoritesState(
        preferences: testPreferences,
        isLoading: false,
        errorMessage: null,
        favoriteTeams: favoriteTeams,
        favoriteMatches: favoriteMatches,
      );

      final state2 = FavoritesState(
        preferences: testPreferences,
        isLoading: false,
        errorMessage: null,
        favoriteTeams: favoriteTeams,
        favoriteMatches: favoriteMatches,
      );

      expect(state1, equals(state2));
    });

    test('two states with different values are not equal', () {
      const state1 = FavoritesState(isLoading: false);
      const state2 = FavoritesState(isLoading: true);

      expect(state1, isNot(equals(state2)));
    });

    test('states with different preferences are not equal', () {
      const prefs1 = UserPreferences(favoriteTeamCodes: ['USA']);
      const prefs2 = UserPreferences(favoriteTeamCodes: ['BRA']);

      const state1 = FavoritesState(preferences: prefs1);
      const state2 = FavoritesState(preferences: prefs2);

      expect(state1, isNot(equals(state2)));
    });

    test('states with different favoriteTeams are not equal', () {
      final state1 = FavoritesState(favoriteTeams: [testTeamUSA]);
      final state2 = FavoritesState(favoriteTeams: [testTeamBRA]);

      expect(state1, isNot(equals(state2)));
    });

    // -------------------------------------------------------
    // 5. isTeamFavorite method
    // -------------------------------------------------------
    test('isTeamFavorite returns true for favorited team', () {
      const preferences = UserPreferences(favoriteTeamCodes: ['USA', 'BRA']);
      const state = FavoritesState(preferences: preferences);

      expect(state.isTeamFavorite('USA'), isTrue);
      expect(state.isTeamFavorite('BRA'), isTrue);
    });

    test('isTeamFavorite returns false for non-favorited team', () {
      const preferences = UserPreferences(favoriteTeamCodes: ['USA']);
      const state = FavoritesState(preferences: preferences);

      expect(state.isTeamFavorite('MEX'), isFalse);
      expect(state.isTeamFavorite('BRA'), isFalse);
    });

    test('isTeamFavorite returns false when no favorites', () {
      const state = FavoritesState();

      expect(state.isTeamFavorite('USA'), isFalse);
    });

    // -------------------------------------------------------
    // 6. isMatchFavorite method
    // -------------------------------------------------------
    test('isMatchFavorite returns true for favorited match', () {
      const preferences = UserPreferences(favoriteMatchIds: ['match_1', 'match_2']);
      const state = FavoritesState(preferences: preferences);

      expect(state.isMatchFavorite('match_1'), isTrue);
      expect(state.isMatchFavorite('match_2'), isTrue);
    });

    test('isMatchFavorite returns false for non-favorited match', () {
      const preferences = UserPreferences(favoriteMatchIds: ['match_1']);
      const state = FavoritesState(preferences: preferences);

      expect(state.isMatchFavorite('match_2'), isFalse);
      expect(state.isMatchFavorite('match_3'), isFalse);
    });

    test('isMatchFavorite returns false when no favorites', () {
      const state = FavoritesState();

      expect(state.isMatchFavorite('match_1'), isFalse);
    });

    // -------------------------------------------------------
    // 7. favoriteTeamCount getter
    // -------------------------------------------------------
    test('favoriteTeamCount returns correct count', () {
      const preferences = UserPreferences(favoriteTeamCodes: ['USA', 'BRA', 'GER']);
      const state = FavoritesState(preferences: preferences);

      expect(state.favoriteTeamCount, equals(3));
    });

    test('favoriteTeamCount returns zero when no favorites', () {
      const state = FavoritesState();

      expect(state.favoriteTeamCount, equals(0));
    });

    // -------------------------------------------------------
    // 8. favoriteMatchCount getter
    // -------------------------------------------------------
    test('favoriteMatchCount returns correct count', () {
      const preferences = UserPreferences(favoriteMatchIds: ['match_1', 'match_2']);
      const state = FavoritesState(preferences: preferences);

      expect(state.favoriteMatchCount, equals(2));
    });

    test('favoriteMatchCount returns zero when no favorites', () {
      const state = FavoritesState();

      expect(state.favoriteMatchCount, equals(0));
    });

    // -------------------------------------------------------
    // 9. hasFavorites getter
    // -------------------------------------------------------
    test('hasFavorites returns true when has favorite teams', () {
      const preferences = UserPreferences(favoriteTeamCodes: ['USA']);
      const state = FavoritesState(preferences: preferences);

      expect(state.hasFavorites, isTrue);
    });

    test('hasFavorites returns true when has favorite matches', () {
      const preferences = UserPreferences(favoriteMatchIds: ['match_1']);
      const state = FavoritesState(preferences: preferences);

      expect(state.hasFavorites, isTrue);
    });

    test('hasFavorites returns true when has both favorite teams and matches', () {
      const preferences = UserPreferences(
        favoriteTeamCodes: ['USA'],
        favoriteMatchIds: ['match_1'],
      );
      const state = FavoritesState(preferences: preferences);

      expect(state.hasFavorites, isTrue);
    });

    test('hasFavorites returns false when no favorites', () {
      const state = FavoritesState();

      expect(state.hasFavorites, isFalse);
    });

    test('hasFavorites returns false when lists are empty', () {
      const preferences = UserPreferences(
        favoriteTeamCodes: [],
        favoriteMatchIds: [],
      );
      const state = FavoritesState(preferences: preferences);

      expect(state.hasFavorites, isFalse);
    });

    // -------------------------------------------------------
    // 10. favoriteTeams list
    // -------------------------------------------------------
    test('favoriteTeams list contains correct teams', () {
      final teams = [testTeamUSA, testTeamBRA];
      final state = FavoritesState(favoriteTeams: teams);

      expect(state.favoriteTeams, equals(teams));
      expect(state.favoriteTeams.length, equals(2));
      expect(state.favoriteTeams[0].teamCode, equals('USA'));
      expect(state.favoriteTeams[1].teamCode, equals('BRA'));
    });

    test('favoriteTeams can be empty', () {
      const state = FavoritesState(favoriteTeams: []);

      expect(state.favoriteTeams, isEmpty);
    });

    // -------------------------------------------------------
    // 11. favoriteMatches list
    // -------------------------------------------------------
    test('favoriteMatches list contains correct matches', () {
      final matches = [testMatch1, testMatch2];
      final state = FavoritesState(favoriteMatches: matches);

      expect(state.favoriteMatches, equals(matches));
      expect(state.favoriteMatches.length, equals(2));
      expect(state.favoriteMatches[0].matchId, equals('match_1'));
      expect(state.favoriteMatches[1].matchId, equals('match_2'));
    });

    test('favoriteMatches can be empty', () {
      const state = FavoritesState(favoriteMatches: []);

      expect(state.favoriteMatches, isEmpty);
    });
  });
}
