import 'dart:convert';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../worldcup/presentation/bloc/mock_repositories.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

/// A test subclass that forces getPreferences to throw,
/// simulating an unexpected error in the Future chain.
class FailingUserPreferencesRepository extends UserPreferencesRepositoryImpl {
  FailingUserPreferencesRepository({
    required super.sharedPreferences,
    super.firestore,
    super.auth,
  });

  @override
  Future<UserPreferences> getPreferences() {
    return Future.error(Exception('simulated preferences failure'));
  }
}

void main() {
  const preferencesKey = 'world_cup_user_preferences';

  late SharedPreferences sharedPreferences;
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late UserPreferencesRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();

    // Return null for currentUser so _syncToFirestore is a no-op
    when(() => mockAuth.currentUser).thenReturn(null);

    repository = UserPreferencesRepositoryImpl(
      sharedPreferences: sharedPreferences,
      firestore: fakeFirestore,
      auth: mockAuth,
    );
  });

  tearDown(() {
    repository.dispose();
  });

  UserPreferencesRepositoryImpl createFreshRepository() {
    return UserPreferencesRepositoryImpl(
      sharedPreferences: sharedPreferences,
      firestore: fakeFirestore,
      auth: mockAuth,
    );
  }

  group('getPreferences', () {
    test('returns empty preferences when SharedPreferences is empty', () async {
      final prefs = await repository.getPreferences();

      expect(prefs.favoriteTeamCodes, isEmpty);
      expect(prefs.favoriteMatchIds, isEmpty);
      expect(prefs.notifyFavoriteTeamMatches, isTrue);
      expect(prefs.notifyLiveUpdates, isTrue);
      expect(prefs.notifyGoals, isTrue);
      expect(prefs.preferredTimezone, isNull);
    });

    test('loads preferences from SharedPreferences JSON', () async {
      final prefsMap = {
        'favoriteTeamCodes': ['USA', 'BRA'],
        'favoriteMatchIds': ['match_1', 'match_2'],
        'notifyFavoriteTeamMatches': false,
        'notifyLiveUpdates': true,
        'notifyGoals': false,
        'preferredTimezone': 'America/New_York',
      };
      await sharedPreferences.setString(preferencesKey, json.encode(prefsMap));

      // Create a fresh repository so cache is empty
      final freshRepo = createFreshRepository();
      addTearDown(() => freshRepo.dispose());

      final prefs = await freshRepo.getPreferences();

      expect(prefs.favoriteTeamCodes, ['USA', 'BRA']);
      expect(prefs.favoriteMatchIds, ['match_1', 'match_2']);
      expect(prefs.notifyFavoriteTeamMatches, isFalse);
      expect(prefs.notifyLiveUpdates, isTrue);
      expect(prefs.notifyGoals, isFalse);
      expect(prefs.preferredTimezone, 'America/New_York');
    });

    test('returns empty preferences when JSON is corrupted', () async {
      await sharedPreferences.setString(preferencesKey, '{invalid json!!!');

      final freshRepo = createFreshRepository();
      addTearDown(() => freshRepo.dispose());

      final prefs = await freshRepo.getPreferences();

      expect(prefs.favoriteTeamCodes, isEmpty);
      expect(prefs.favoriteMatchIds, isEmpty);
      expect(prefs.notifyFavoriteTeamMatches, isTrue);
    });

    test('returns cached preferences on subsequent calls', () async {
      // Save some preferences so the cache gets populated
      final prefs = TestDataFactory.createUserPreferences(
        favoriteTeamCodes: ['USA'],
      );
      await repository.savePreferences(prefs);

      // Verify cache is set
      final first = await repository.getPreferences();
      expect(first.favoriteTeamCodes, ['USA']);

      // Manually write different data to SharedPreferences (bypassing cache)
      final newMap = {
        'favoriteTeamCodes': ['GER'],
        'favoriteMatchIds': <String>[],
        'notifyFavoriteTeamMatches': true,
        'notifyLiveUpdates': true,
        'notifyGoals': true,
      };
      await sharedPreferences.setString(preferencesKey, json.encode(newMap));

      // Second call should return cached version (USA), not the new data (GER)
      final second = await repository.getPreferences();
      expect(second.favoriteTeamCodes, ['USA']);
    });
  });

  group('savePreferences', () {
    test('persists preferences as JSON to SharedPreferences', () async {
      final prefs = TestDataFactory.createUserPreferences(
        favoriteTeamCodes: ['ARG', 'FRA'],
        favoriteMatchIds: ['match_5'],
        notifyFavoriteTeamMatches: false,
        notifyLiveUpdates: false,
        notifyGoals: true,
      );

      await repository.savePreferences(prefs);

      final storedJson = sharedPreferences.getString(preferencesKey);
      expect(storedJson, isNotNull);
      final decoded = json.decode(storedJson!) as Map<String, dynamic>;
      expect(decoded['favoriteTeamCodes'], ['ARG', 'FRA']);
      expect(decoded['favoriteMatchIds'], ['match_5']);
      expect(decoded['notifyFavoriteTeamMatches'], isFalse);
      expect(decoded['notifyLiveUpdates'], isFalse);
      expect(decoded['notifyGoals'], isTrue);
    });

    test('emits saved preferences to stream', () async {
      final prefs = TestDataFactory.createUserPreferences(
        favoriteTeamCodes: ['ESP'],
      );

      final stream = repository.watchPreferences();
      // watchPreferences emits current value first, then subsequent saves
      // We need to skip the initial emission and capture the save emission
      final future = stream.skip(1).first;

      // Small delay to ensure the initial emission from watchPreferences fires first
      await Future.delayed(Duration.zero);

      await repository.savePreferences(prefs);

      final emitted = await future;
      expect(emitted.favoriteTeamCodes, ['ESP']);
    });

    test('updates cache so getPreferences returns new value', () async {
      final prefs = TestDataFactory.createUserPreferences(
        favoriteTeamCodes: ['ITA'],
      );

      await repository.savePreferences(prefs);

      final loaded = await repository.getPreferences();
      expect(loaded.favoriteTeamCodes, ['ITA']);
    });
  });

  group('addFavoriteTeam', () {
    test('adds a new team to empty favorites', () async {
      final result = await repository.addFavoriteTeam('USA');

      expect(result.favoriteTeamCodes, contains('USA'));
      expect(result.favoriteTeamCodes.length, 1);

      // Verify persisted
      final loaded = await repository.getPreferences();
      expect(loaded.favoriteTeamCodes, contains('USA'));
    });

    test('adds a second team to existing favorites', () async {
      await repository.addFavoriteTeam('USA');
      final result = await repository.addFavoriteTeam('BRA');

      expect(result.favoriteTeamCodes, containsAll(['USA', 'BRA']));
      expect(result.favoriteTeamCodes.length, 2);
    });

    test('is idempotent - does not duplicate existing team', () async {
      await repository.addFavoriteTeam('USA');
      final result = await repository.addFavoriteTeam('USA');

      expect(result.favoriteTeamCodes.length, 1);
      expect(result.favoriteTeamCodes, ['USA']);
    });

    test('stores team code in uppercase', () async {
      final result = await repository.addFavoriteTeam('usa');

      expect(result.favoriteTeamCodes, contains('USA'));
    });
  });

  group('removeFavoriteTeam', () {
    test('removes an existing team from favorites', () async {
      await repository.addFavoriteTeam('USA');
      await repository.addFavoriteTeam('BRA');

      final result = await repository.removeFavoriteTeam('USA');

      expect(result.favoriteTeamCodes, ['BRA']);
    });

    test('handles removing a team that is not in favorites', () async {
      await repository.addFavoriteTeam('USA');

      final result = await repository.removeFavoriteTeam('GER');

      expect(result.favoriteTeamCodes, ['USA']);
    });

    test('is case-insensitive', () async {
      await repository.addFavoriteTeam('USA');

      final result = await repository.removeFavoriteTeam('usa');

      expect(result.favoriteTeamCodes, isEmpty);
    });
  });

  group('toggleFavoriteTeam', () {
    test('adds team when not present', () async {
      final result = await repository.toggleFavoriteTeam('ARG');

      expect(result.favoriteTeamCodes, contains('ARG'));
    });

    test('removes team when already present', () async {
      await repository.addFavoriteTeam('ARG');

      final result = await repository.toggleFavoriteTeam('ARG');

      expect(result.favoriteTeamCodes, isEmpty);
    });

    test('toggling twice returns to original state', () async {
      await repository.toggleFavoriteTeam('FRA');
      final result = await repository.toggleFavoriteTeam('FRA');

      expect(result.favoriteTeamCodes, isEmpty);
    });
  });

  group('addFavoriteMatch', () {
    test('adds a new match to empty favorites', () async {
      final result = await repository.addFavoriteMatch('match_1');

      expect(result.favoriteMatchIds, contains('match_1'));
      expect(result.favoriteMatchIds.length, 1);
    });

    test('adds a second match to existing favorites', () async {
      await repository.addFavoriteMatch('match_1');
      final result = await repository.addFavoriteMatch('match_2');

      expect(result.favoriteMatchIds, containsAll(['match_1', 'match_2']));
      expect(result.favoriteMatchIds.length, 2);
    });

    test('is idempotent - does not duplicate existing match', () async {
      await repository.addFavoriteMatch('match_1');
      final result = await repository.addFavoriteMatch('match_1');

      expect(result.favoriteMatchIds.length, 1);
    });
  });

  group('removeFavoriteMatch', () {
    test('removes an existing match from favorites', () async {
      await repository.addFavoriteMatch('match_1');
      await repository.addFavoriteMatch('match_2');

      final result = await repository.removeFavoriteMatch('match_1');

      expect(result.favoriteMatchIds, ['match_2']);
    });

    test('handles removing a match that is not in favorites', () async {
      await repository.addFavoriteMatch('match_1');

      final result = await repository.removeFavoriteMatch('match_99');

      expect(result.favoriteMatchIds, ['match_1']);
    });
  });

  group('toggleFavoriteMatch', () {
    test('adds match when not present', () async {
      final result = await repository.toggleFavoriteMatch('match_3');

      expect(result.favoriteMatchIds, contains('match_3'));
    });

    test('removes match when already present', () async {
      await repository.addFavoriteMatch('match_3');

      final result = await repository.toggleFavoriteMatch('match_3');

      expect(result.favoriteMatchIds, isEmpty);
    });

    test('toggling twice returns to original state', () async {
      await repository.toggleFavoriteMatch('match_5');
      final result = await repository.toggleFavoriteMatch('match_5');

      expect(result.favoriteMatchIds, isEmpty);
    });
  });

  group('isTeamFavorite', () {
    test('returns false when no favorites', () async {
      final result = await repository.isTeamFavorite('USA');

      expect(result, isFalse);
    });

    test('returns true for a favorited team', () async {
      await repository.addFavoriteTeam('USA');

      final result = await repository.isTeamFavorite('USA');

      expect(result, isTrue);
    });

    test('returns false for a non-favorited team', () async {
      await repository.addFavoriteTeam('USA');

      final result = await repository.isTeamFavorite('BRA');

      expect(result, isFalse);
    });

    test('is case-insensitive', () async {
      await repository.addFavoriteTeam('USA');

      expect(await repository.isTeamFavorite('usa'), isTrue);
      expect(await repository.isTeamFavorite('Usa'), isTrue);
    });
  });

  group('isMatchFavorite', () {
    test('returns false when no favorites', () async {
      final result = await repository.isMatchFavorite('match_1');

      expect(result, isFalse);
    });

    test('returns true for a favorited match', () async {
      await repository.addFavoriteMatch('match_1');

      final result = await repository.isMatchFavorite('match_1');

      expect(result, isTrue);
    });

    test('returns false for a non-favorited match', () async {
      await repository.addFavoriteMatch('match_1');

      final result = await repository.isMatchFavorite('match_99');

      expect(result, isFalse);
    });
  });

  group('getFavoriteTeamCodes', () {
    test('returns empty list when no favorites', () async {
      final result = await repository.getFavoriteTeamCodes();

      expect(result, isEmpty);
    });

    test('returns all favorited team codes', () async {
      await repository.addFavoriteTeam('USA');
      await repository.addFavoriteTeam('BRA');
      await repository.addFavoriteTeam('GER');

      final result = await repository.getFavoriteTeamCodes();

      expect(result, ['USA', 'BRA', 'GER']);
      expect(result.length, 3);
    });
  });

  group('getFavoriteMatchIds', () {
    test('returns empty list when no favorites', () async {
      final result = await repository.getFavoriteMatchIds();

      expect(result, isEmpty);
    });

    test('returns all favorited match IDs', () async {
      await repository.addFavoriteMatch('match_1');
      await repository.addFavoriteMatch('match_2');

      final result = await repository.getFavoriteMatchIds();

      expect(result, ['match_1', 'match_2']);
      expect(result.length, 2);
    });
  });

  group('updateNotificationSettings', () {
    test('updates notifyFavoriteTeamMatches flag', () async {
      final result = await repository.updateNotificationSettings(
        notifyFavoriteTeamMatches: false,
      );

      expect(result.notifyFavoriteTeamMatches, isFalse);
      expect(result.notifyLiveUpdates, isTrue); // unchanged
      expect(result.notifyGoals, isTrue); // unchanged
    });

    test('updates notifyLiveUpdates flag', () async {
      final result = await repository.updateNotificationSettings(
        notifyLiveUpdates: false,
      );

      expect(result.notifyFavoriteTeamMatches, isTrue); // unchanged
      expect(result.notifyLiveUpdates, isFalse);
      expect(result.notifyGoals, isTrue); // unchanged
    });

    test('updates notifyGoals flag', () async {
      final result = await repository.updateNotificationSettings(
        notifyGoals: false,
      );

      expect(result.notifyFavoriteTeamMatches, isTrue); // unchanged
      expect(result.notifyLiveUpdates, isTrue); // unchanged
      expect(result.notifyGoals, isFalse);
    });

    test('updates multiple flags at once', () async {
      final result = await repository.updateNotificationSettings(
        notifyFavoriteTeamMatches: false,
        notifyLiveUpdates: false,
        notifyGoals: false,
      );

      expect(result.notifyFavoriteTeamMatches, isFalse);
      expect(result.notifyLiveUpdates, isFalse);
      expect(result.notifyGoals, isFalse);
    });

    test('preserves existing favorites when updating settings', () async {
      await repository.addFavoriteTeam('USA');
      await repository.addFavoriteMatch('match_1');

      final result = await repository.updateNotificationSettings(
        notifyGoals: false,
      );

      expect(result.favoriteTeamCodes, ['USA']);
      expect(result.favoriteMatchIds, ['match_1']);
      expect(result.notifyGoals, isFalse);
    });

    test('persists updated settings to SharedPreferences', () async {
      await repository.updateNotificationSettings(
        notifyFavoriteTeamMatches: false,
      );

      final storedJson = sharedPreferences.getString(preferencesKey);
      expect(storedJson, isNotNull);
      final decoded = json.decode(storedJson!) as Map<String, dynamic>;
      expect(decoded['notifyFavoriteTeamMatches'], isFalse);
    });
  });

  group('clearPreferences', () {
    test('removes data from SharedPreferences', () async {
      await repository.addFavoriteTeam('USA');
      expect(sharedPreferences.getString(preferencesKey), isNotNull);

      await repository.clearPreferences();

      expect(sharedPreferences.getString(preferencesKey), isNull);
    });

    test('resets cached preferences so getPreferences returns empty', () async {
      await repository.addFavoriteTeam('USA');
      await repository.addFavoriteTeam('BRA');
      await repository.addFavoriteMatch('match_1');

      await repository.clearPreferences();

      final prefs = await repository.getPreferences();
      expect(prefs.favoriteTeamCodes, isEmpty);
      expect(prefs.favoriteMatchIds, isEmpty);
      expect(prefs.notifyFavoriteTeamMatches, isTrue);
      expect(prefs.notifyLiveUpdates, isTrue);
      expect(prefs.notifyGoals, isTrue);
    });

    test('emits empty preferences to stream', () async {
      await repository.addFavoriteTeam('USA');

      final stream = repository.watchPreferences();
      // Skip the initial emission from watchPreferences
      final future = stream.skip(1).first;
      await Future.delayed(Duration.zero);

      await repository.clearPreferences();

      final emitted = await future;
      expect(emitted.favoriteTeamCodes, isEmpty);
      expect(emitted.favoriteMatchIds, isEmpty);
    });
  });

  group('watchPreferences', () {
    test('emits current preferences on subscription', () async {
      await repository.addFavoriteTeam('USA');

      final stream = repository.watchPreferences();
      final emitted = await stream.first;

      expect(emitted.favoriteTeamCodes, contains('USA'));
    });

    test('emits updates when preferences are saved', () async {
      final stream = repository.watchPreferences();
      final emissions = <UserPreferences>[];
      final subscription = stream.listen(emissions.add);
      addTearDown(() => subscription.cancel());

      // Wait for initial emission
      await Future.delayed(const Duration(milliseconds: 50));

      await repository.addFavoriteTeam('BRA');

      // Wait for the emission to propagate
      await Future.delayed(const Duration(milliseconds: 50));

      // Should have initial emission + one from addFavoriteTeam
      expect(emissions.length, greaterThanOrEqualTo(2));
      expect(emissions.last.favoriteTeamCodes, contains('BRA'));
    });

    test('emits empty preferences when underlying Future fails', () async {
      final failingRepo = FailingUserPreferencesRepository(
        sharedPreferences: sharedPreferences,
        firestore: fakeFirestore,
        auth: mockAuth,
      );
      addTearDown(() => failingRepo.dispose());

      final stream = failingRepo.watchPreferences();
      final first = await stream.first;

      expect(first.favoriteTeamCodes, isEmpty);
      expect(first.favoriteMatchIds, isEmpty);
      expect(first.notifyFavoriteTeamMatches, isTrue);
    });
  });

  group('dispose', () {
    test('closes the stream controller so no more events are emitted', () async {
      final repo = createFreshRepository();

      // Subscribe before dispose
      final stream = repo.watchPreferences();
      final emissions = <UserPreferences>[];
      final subscription = stream.listen(
        emissions.add,
        onDone: () {},
      );

      // Wait for the initial emission
      await Future.delayed(const Duration(milliseconds: 50));
      final countBefore = emissions.length;

      repo.dispose();

      // After dispose, the stream should complete (onDone called)
      // Verify that the subscription received the done event
      await Future.delayed(const Duration(milliseconds: 50));
      expect(emissions.length, countBefore); // no new emissions after dispose
      await subscription.cancel();
    });

    test('can be called without error', () {
      final repo = createFreshRepository();

      // dispose should not throw
      expect(() => repo.dispose(), returnsNormally);
    });
  });
}
