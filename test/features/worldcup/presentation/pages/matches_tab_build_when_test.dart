import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';

import '../bloc/mock_repositories.dart';

void main() {
  final testMatches = TestDataFactory.createMatchList(count: 5);

  group('MatchesTab buildWhen - MatchListCubit', () {
    /// Helper that replicates the buildWhen logic from MatchesTab for
    /// MatchListCubit's BlocBuilder.
    bool matchListBuildWhen(MatchListState previous, MatchListState current) {
      return previous.matches != current.matches ||
          previous.filteredMatches != current.filteredMatches ||
          previous.filter != current.filter ||
          previous.selectedDate != current.selectedDate ||
          previous.isLoading != current.isLoading ||
          previous.errorMessage != current.errorMessage ||
          previous.liveCount != current.liveCount ||
          previous.upcomingCount != current.upcomingCount ||
          previous.completedCount != current.completedCount;
    }

    test('skips rebuild when only lastUpdated changes', () {
      final state1 = MatchListState(
        matches: testMatches,
        filteredMatches: testMatches,
        filter: MatchListFilter.all,
        isLoading: false,
        lastUpdated: DateTime(2026, 6, 1, 10, 0),
      );
      final state2 = state1.copyWith(
        lastUpdated: DateTime(2026, 6, 1, 10, 1),
      );

      expect(matchListBuildWhen(state1, state2), isFalse,
          reason: 'Should not rebuild when only lastUpdated changes');
    });

    test('skips rebuild when only isRefreshing changes', () {
      final state1 = MatchListState(
        matches: testMatches,
        filteredMatches: testMatches,
        filter: MatchListFilter.all,
        isLoading: false,
        isRefreshing: false,
      );
      final state2 = state1.copyWith(isRefreshing: true);

      expect(matchListBuildWhen(state1, state2), isFalse,
          reason: 'Should not rebuild when only isRefreshing changes');
    });

    test('triggers rebuild when matches change', () {
      final state1 = MatchListState(
        matches: testMatches,
        filteredMatches: testMatches,
        filter: MatchListFilter.all,
        isLoading: false,
      );
      final newMatches = TestDataFactory.createMatchList(count: 3);
      final state2 = state1.copyWith(
        matches: newMatches,
        filteredMatches: newMatches,
      );

      expect(matchListBuildWhen(state1, state2), isTrue,
          reason: 'Should rebuild when matches list changes');
    });

    test('triggers rebuild when filter changes', () {
      final state1 = MatchListState(
        matches: testMatches,
        filteredMatches: testMatches,
        filter: MatchListFilter.all,
        isLoading: false,
      );
      final state2 = state1.copyWith(filter: MatchListFilter.live);

      expect(matchListBuildWhen(state1, state2), isTrue,
          reason: 'Should rebuild when filter changes');
    });

    test('triggers rebuild when isLoading changes', () {
      final state1 = MatchListState(
        matches: testMatches,
        filteredMatches: testMatches,
        filter: MatchListFilter.all,
        isLoading: false,
      );
      final state2 = state1.copyWith(isLoading: true);

      expect(matchListBuildWhen(state1, state2), isTrue,
          reason: 'Should rebuild when isLoading changes');
    });

    test('triggers rebuild when selectedDate changes', () {
      final state1 = MatchListState(
        matches: testMatches,
        filteredMatches: testMatches,
        filter: MatchListFilter.all,
        isLoading: false,
      );
      final state2 = state1.copyWith(selectedDate: DateTime(2026, 6, 15));

      expect(matchListBuildWhen(state1, state2), isTrue,
          reason: 'Should rebuild when selectedDate changes');
    });

    test('triggers rebuild when errorMessage changes', () {
      final state1 = MatchListState(
        matches: testMatches,
        filteredMatches: testMatches,
        filter: MatchListFilter.all,
        isLoading: false,
      );
      final state2 = state1.copyWith(errorMessage: 'Network error');

      expect(matchListBuildWhen(state1, state2), isTrue,
          reason: 'Should rebuild when errorMessage changes');
    });
  });

  group('MatchesTab buildWhen - FavoritesCubit', () {
    /// Helper that replicates the buildWhen logic from MatchesTab for
    /// FavoritesCubit's BlocBuilder.
    bool favoritesBuildWhen(FavoritesState previous, FavoritesState current) {
      return !listEquals(
        previous.preferences.favoriteMatchIds,
        current.preferences.favoriteMatchIds,
      );
    }

    test('skips rebuild when only isLoading changes', () {
      final prefs = TestDataFactory.createUserPreferences(
        favoriteMatchIds: ['match_1', 'match_2'],
      );
      final state1 = FavoritesState(preferences: prefs, isLoading: false);
      final state2 = state1.copyWith(isLoading: true);

      expect(favoritesBuildWhen(state1, state2), isFalse,
          reason: 'Should not rebuild when only isLoading changes');
    });

    test('skips rebuild when only favoriteTeamCodes change', () {
      final prefs1 = TestDataFactory.createUserPreferences(
        favoriteTeamCodes: ['USA'],
        favoriteMatchIds: ['match_1'],
      );
      final prefs2 = TestDataFactory.createUserPreferences(
        favoriteTeamCodes: ['USA', 'BRA'],
        favoriteMatchIds: ['match_1'],
      );
      final state1 = FavoritesState(preferences: prefs1, isLoading: false);
      final state2 = FavoritesState(preferences: prefs2, isLoading: false);

      expect(favoritesBuildWhen(state1, state2), isFalse,
          reason: 'Should not rebuild when only favoriteTeamCodes change');
    });

    test('skips rebuild when only errorMessage changes', () {
      final prefs = TestDataFactory.createUserPreferences(
        favoriteMatchIds: ['match_1'],
      );
      final state1 = FavoritesState(preferences: prefs, isLoading: false);
      final state2 = state1.copyWith(errorMessage: 'Something went wrong');

      expect(favoritesBuildWhen(state1, state2), isFalse,
          reason: 'Should not rebuild when only errorMessage changes');
    });

    test('triggers rebuild when favoriteMatchIds change', () {
      final prefs1 = TestDataFactory.createUserPreferences(
        favoriteMatchIds: ['match_1'],
      );
      final prefs2 = TestDataFactory.createUserPreferences(
        favoriteMatchIds: ['match_1', 'match_2'],
      );
      final state1 = FavoritesState(preferences: prefs1, isLoading: false);
      final state2 = FavoritesState(preferences: prefs2, isLoading: false);

      expect(favoritesBuildWhen(state1, state2), isTrue,
          reason: 'Should rebuild when favoriteMatchIds change');
    });

    test('triggers rebuild when a favorite match is removed', () {
      final prefs1 = TestDataFactory.createUserPreferences(
        favoriteMatchIds: ['match_1', 'match_2'],
      );
      final prefs2 = TestDataFactory.createUserPreferences(
        favoriteMatchIds: ['match_1'],
      );
      final state1 = FavoritesState(preferences: prefs1, isLoading: false);
      final state2 = FavoritesState(preferences: prefs2, isLoading: false);

      expect(favoritesBuildWhen(state1, state2), isTrue,
          reason: 'Should rebuild when a favorite match is removed');
    });
  });

  group('MatchesTab buildWhen - PredictionsCubit', () {
    /// Helper that replicates the buildWhen logic from MatchesTab for
    /// PredictionsCubit's BlocBuilder.
    bool predictionsBuildWhen(
        PredictionsState previous, PredictionsState current) {
      return previous.predictions != current.predictions;
    }

    test('skips rebuild when only isSaving changes', () {
      final pred = TestDataFactory.createPrediction(matchId: 'match_1');
      final state1 = PredictionsState(predictions: [pred], isSaving: false);
      final state2 = state1.copyWith(isSaving: true);

      expect(predictionsBuildWhen(state1, state2), isFalse,
          reason: 'Should not rebuild when only isSaving changes');
    });

    test('skips rebuild when only successMessage changes', () {
      final pred = TestDataFactory.createPrediction(matchId: 'match_1');
      final state1 = PredictionsState(predictions: [pred]);
      final state2 = state1.copyWith(successMessage: 'Saved!');

      expect(predictionsBuildWhen(state1, state2), isFalse,
          reason: 'Should not rebuild when only successMessage changes');
    });

    test('skips rebuild when only isLoading changes', () {
      final pred = TestDataFactory.createPrediction(matchId: 'match_1');
      final state1 = PredictionsState(predictions: [pred], isLoading: false);
      final state2 = state1.copyWith(isLoading: true);

      expect(predictionsBuildWhen(state1, state2), isFalse,
          reason: 'Should not rebuild when only isLoading changes');
    });

    test('skips rebuild when only errorMessage changes', () {
      final pred = TestDataFactory.createPrediction(matchId: 'match_1');
      final state1 = PredictionsState(predictions: [pred]);
      final state2 = state1.copyWith(errorMessage: 'Network error');

      expect(predictionsBuildWhen(state1, state2), isFalse,
          reason: 'Should not rebuild when only errorMessage changes');
    });

    test('triggers rebuild when predictions list changes', () {
      final pred1 = TestDataFactory.createPrediction(matchId: 'match_1');
      final pred2 = TestDataFactory.createPrediction(
        predictionId: 'pred_2',
        matchId: 'match_2',
      );
      final state1 = PredictionsState(predictions: [pred1]);
      final state2 = PredictionsState(predictions: [pred1, pred2]);

      expect(predictionsBuildWhen(state1, state2), isTrue,
          reason: 'Should rebuild when predictions list changes');
    });

    test('triggers rebuild when a prediction is updated', () {
      final pred1 = TestDataFactory.createPrediction(
        matchId: 'match_1',
        predictedHomeScore: 2,
        predictedAwayScore: 1,
      );
      final pred1Updated = TestDataFactory.createPrediction(
        matchId: 'match_1',
        predictedHomeScore: 3,
        predictedAwayScore: 0,
      );
      final state1 = PredictionsState(predictions: [pred1]);
      final state2 = PredictionsState(predictions: [pred1Updated]);

      expect(predictionsBuildWhen(state1, state2), isTrue,
          reason: 'Should rebuild when a prediction score changes');
    });
  });

  group('Match counts calculation', () {
    test('groups matches by local date correctly', () {
      final matches = [
        TestDataFactory.createMatch(
          matchId: 'a',
          dateTime: DateTime(2026, 6, 11, 10, 0),
        ),
        TestDataFactory.createMatch(
          matchId: 'b',
          dateTime: DateTime(2026, 6, 11, 18, 0),
        ),
        TestDataFactory.createMatch(
          matchId: 'c',
          dateTime: DateTime(2026, 6, 12, 14, 0),
        ),
      ];

      final counts = _computeMatchCounts(matches);
      final june11 = DateTime(2026, 6, 11);
      final june12 = DateTime(2026, 6, 12);

      expect(counts[june11], equals(2));
      expect(counts[june12], equals(1));
    });

    test('returns empty map for empty matches list', () {
      final counts = _computeMatchCounts([]);
      expect(counts, isEmpty);
    });

    test('skips matches with null dateTime', () {
      final matches = [
        TestDataFactory.createMatch(matchId: 'a', dateTime: null),
        TestDataFactory.createMatch(
          matchId: 'b',
          dateTime: DateTime(2026, 6, 11, 10, 0),
        ),
      ];

      final counts = _computeMatchCounts(matches);
      expect(counts.length, equals(1));
    });
  });
}

/// Helper that mirrors the _calculateMatchCounts logic for testing.
Map<DateTime, int> _computeMatchCounts(List<WorldCupMatch> matches) {
  final Map<DateTime, int> counts = {};
  for (final match in matches) {
    if (match.dateTime != null) {
      final localDateTime = match.dateTime!.toLocal();
      final dateOnly = DateTime(
        localDateTime.year,
        localDateTime.month,
        localDateTime.day,
      );
      counts[dateOnly] = (counts[dateOnly] ?? 0) + 1;
    }
  }
  return counts;
}
