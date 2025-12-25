import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/entities.dart';

void main() {
  group('UserPreferences', () {
    test('empty factory creates default preferences', () {
      final prefs = UserPreferences.empty();

      expect(prefs.favoriteTeamCodes, isEmpty);
      expect(prefs.favoriteMatchIds, isEmpty);
      expect(prefs.notifyFavoriteTeamMatches, isTrue);
      expect(prefs.notifyLiveUpdates, isTrue);
      expect(prefs.notifyGoals, isTrue);
    });

    test('isTeamFavorite returns correct value', () {
      final prefs = UserPreferences(
        favoriteTeamCodes: ['USA', 'BRA', 'GER'],
      );

      expect(prefs.isTeamFavorite('USA'), isTrue);
      expect(prefs.isTeamFavorite('usa'), isTrue); // Case insensitive
      expect(prefs.isTeamFavorite('MEX'), isFalse);
    });

    test('isMatchFavorite returns correct value', () {
      final prefs = UserPreferences(
        favoriteMatchIds: ['match1', 'match2'],
      );

      expect(prefs.isMatchFavorite('match1'), isTrue);
      expect(prefs.isMatchFavorite('match3'), isFalse);
    });

    test('addFavoriteTeam adds team code', () {
      final prefs = UserPreferences.empty();
      final updated = prefs.addFavoriteTeam('USA');

      expect(updated.favoriteTeamCodes, contains('USA'));
      expect(updated.isTeamFavorite('USA'), isTrue);
    });

    test('addFavoriteTeam does not duplicate', () {
      final prefs = UserPreferences(favoriteTeamCodes: ['USA']);
      final updated = prefs.addFavoriteTeam('USA');

      expect(updated.favoriteTeamCodes.length, equals(1));
    });

    test('removeFavoriteTeam removes team code', () {
      final prefs = UserPreferences(favoriteTeamCodes: ['USA', 'BRA']);
      final updated = prefs.removeFavoriteTeam('USA');

      expect(updated.favoriteTeamCodes, isNot(contains('USA')));
      expect(updated.favoriteTeamCodes, contains('BRA'));
    });

    test('toggleFavoriteTeam toggles correctly', () {
      final prefs = UserPreferences.empty();

      // Add
      final added = prefs.toggleFavoriteTeam('USA');
      expect(added.isTeamFavorite('USA'), isTrue);

      // Remove
      final removed = added.toggleFavoriteTeam('USA');
      expect(removed.isTeamFavorite('USA'), isFalse);
    });

    test('addFavoriteMatch adds match ID', () {
      final prefs = UserPreferences.empty();
      final updated = prefs.addFavoriteMatch('match1');

      expect(updated.favoriteMatchIds, contains('match1'));
    });

    test('removeFavoriteMatch removes match ID', () {
      final prefs = UserPreferences(favoriteMatchIds: ['match1', 'match2']);
      final updated = prefs.removeFavoriteMatch('match1');

      expect(updated.favoriteMatchIds, isNot(contains('match1')));
      expect(updated.favoriteMatchIds, contains('match2'));
    });

    test('toggleFavoriteMatch toggles correctly', () {
      final prefs = UserPreferences.empty();

      // Add
      final added = prefs.toggleFavoriteMatch('match1');
      expect(added.isMatchFavorite('match1'), isTrue);

      // Remove
      final removed = added.toggleFavoriteMatch('match1');
      expect(removed.isMatchFavorite('match1'), isFalse);
    });

    test('fromMap and toMap round-trip correctly', () {
      final original = UserPreferences(
        favoriteTeamCodes: ['USA', 'BRA'],
        favoriteMatchIds: ['match1', 'match2'],
        notifyFavoriteTeamMatches: false,
        notifyLiveUpdates: true,
        notifyGoals: false,
        preferredTimezone: 'America/New_York',
      );

      final map = original.toMap();
      final restored = UserPreferences.fromMap(map);

      expect(restored.favoriteTeamCodes, equals(original.favoriteTeamCodes));
      expect(restored.favoriteMatchIds, equals(original.favoriteMatchIds));
      expect(restored.notifyFavoriteTeamMatches, equals(original.notifyFavoriteTeamMatches));
      expect(restored.notifyLiveUpdates, equals(original.notifyLiveUpdates));
      expect(restored.notifyGoals, equals(original.notifyGoals));
      expect(restored.preferredTimezone, equals(original.preferredTimezone));
    });

    test('copyWith creates correct copy', () {
      final original = UserPreferences.empty();
      final updated = original.copyWith(
        favoriteTeamCodes: ['USA'],
        notifyGoals: false,
      );

      expect(updated.favoriteTeamCodes, equals(['USA']));
      expect(updated.notifyGoals, isFalse);
      expect(updated.notifyLiveUpdates, isTrue); // Unchanged
    });
  });
}
