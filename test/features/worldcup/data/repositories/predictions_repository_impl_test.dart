import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../worldcup/presentation/bloc/mock_repositories.dart';

void main() {
  late SharedPreferences sharedPreferences;
  late PredictionsRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
    repository = PredictionsRepositoryImpl(
      sharedPreferences: sharedPreferences,
    );
  });

  tearDown(() {
    repository.dispose();
  });

  group('getAllPredictions', () {
    test('returns empty list when no predictions stored', () async {
      final result = await repository.getAllPredictions();
      expect(result, isEmpty);
    });

    test('returns cached predictions on second call', () async {
      final prediction = TestDataFactory.createPrediction();
      await repository.savePrediction(prediction);

      final first = await repository.getAllPredictions();
      final second = await repository.getAllPredictions();
      expect(first, equals(second));
      expect(first.length, 1);
    });

    test('returns predictions from SharedPreferences', () async {
      final prediction = TestDataFactory.createPrediction();
      final jsonString = json.encode([prediction.toMap()]);
      SharedPreferences.setMockInitialValues({
        'world_cup_predictions': jsonString,
      });
      sharedPreferences = await SharedPreferences.getInstance();
      repository = PredictionsRepositoryImpl(
        sharedPreferences: sharedPreferences,
      );

      final result = await repository.getAllPredictions();
      expect(result.length, 1);
      expect(result.first.matchId, prediction.matchId);
    });

    test('returns empty list on corrupted JSON', () async {
      SharedPreferences.setMockInitialValues({
        'world_cup_predictions': 'not valid json',
      });
      sharedPreferences = await SharedPreferences.getInstance();
      repository = PredictionsRepositoryImpl(
        sharedPreferences: sharedPreferences,
      );

      final result = await repository.getAllPredictions();
      expect(result, isEmpty);
    });
  });

  group('getPredictionForMatch', () {
    test('returns null when no prediction exists', () async {
      final result = await repository.getPredictionForMatch('nonexistent');
      expect(result, isNull);
    });

    test('returns prediction when it exists', () async {
      final prediction = TestDataFactory.createPrediction(matchId: 'match_5');
      await repository.savePrediction(prediction);

      final result = await repository.getPredictionForMatch('match_5');
      expect(result, isNotNull);
      expect(result!.matchId, 'match_5');
    });
  });

  group('savePrediction', () {
    test('saves new prediction', () async {
      final prediction = TestDataFactory.createPrediction();
      final result = await repository.savePrediction(prediction);

      expect(result.matchId, prediction.matchId);
      final all = await repository.getAllPredictions();
      expect(all.length, 1);
    });

    test('updates existing prediction for same match', () async {
      final prediction1 = TestDataFactory.createPrediction(
        predictionId: 'pred_1',
        matchId: 'match_1',
        predictedHomeScore: 1,
        predictedAwayScore: 0,
      );
      final prediction2 = TestDataFactory.createPrediction(
        predictionId: 'pred_2',
        matchId: 'match_1',
        predictedHomeScore: 3,
        predictedAwayScore: 2,
      );

      await repository.savePrediction(prediction1);
      await repository.savePrediction(prediction2);

      final all = await repository.getAllPredictions();
      expect(all.length, 1);
      expect(all.first.predictedHomeScore, 3);
    });

    test('persists to SharedPreferences', () async {
      final prediction = TestDataFactory.createPrediction();
      await repository.savePrediction(prediction);

      final stored = sharedPreferences.getString('world_cup_predictions');
      expect(stored, isNotNull);
      final decoded = json.decode(stored!) as List;
      expect(decoded.length, 1);
    });
  });

  group('updatePrediction', () {
    test('updates prediction by predictionId', () async {
      final prediction = TestDataFactory.createPrediction(
        predictionId: 'pred_1',
        predictedHomeScore: 1,
      );
      await repository.savePrediction(prediction);

      final updated = prediction.copyWith(predictedHomeScore: 4);
      final result = await repository.updatePrediction(updated);

      expect(result.predictedHomeScore, 4);
      expect(result.updatedAt, isNotNull);
    });

    test('throws when prediction not found', () async {
      final prediction = TestDataFactory.createPrediction(
        predictionId: 'nonexistent',
      );

      expect(
        () => repository.updatePrediction(prediction),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('deletePrediction', () {
    test('deletes prediction by id', () async {
      final prediction = TestDataFactory.createPrediction(predictionId: 'del_me');
      await repository.savePrediction(prediction);

      await repository.deletePrediction('del_me');
      final all = await repository.getAllPredictions();
      expect(all, isEmpty);
    });
  });

  group('deletePredictionForMatch', () {
    test('deletes prediction by matchId', () async {
      final prediction = TestDataFactory.createPrediction(matchId: 'match_del');
      await repository.savePrediction(prediction);

      await repository.deletePredictionForMatch('match_del');
      final all = await repository.getAllPredictions();
      expect(all, isEmpty);
    });

    test('does nothing when no prediction for match', () async {
      final prediction = TestDataFactory.createPrediction(matchId: 'match_keep');
      await repository.savePrediction(prediction);

      await repository.deletePredictionForMatch('nonexistent');
      final all = await repository.getAllPredictions();
      expect(all.length, 1);
    });
  });

  group('getUpcomingPredictions', () {
    test('returns only pending predictions', () async {
      final pending = TestDataFactory.createPrediction(
        predictionId: 'p1',
        matchId: 'm1',
      );
      final evaluated = TestDataFactory.createPrediction(
        predictionId: 'p2',
        matchId: 'm2',
        actualOutcome: PredictionOutcome.correct,
        resultCorrect: true,
        pointsEarned: 1,
      );

      await repository.savePrediction(pending);
      await repository.savePrediction(evaluated);

      final upcoming = await repository.getUpcomingPredictions();
      expect(upcoming.length, 1);
      expect(upcoming.first.matchId, 'm1');
    });
  });

  group('getCompletedPredictions', () {
    test('returns only evaluated predictions', () async {
      final pending = TestDataFactory.createPrediction(
        predictionId: 'p1',
        matchId: 'm1',
      );
      final evaluated = TestDataFactory.createPrediction(
        predictionId: 'p2',
        matchId: 'm2',
        actualOutcome: PredictionOutcome.incorrect,
      );

      await repository.savePrediction(pending);
      await repository.savePrediction(evaluated);

      final completed = await repository.getCompletedPredictions();
      expect(completed.length, 1);
      expect(completed.first.matchId, 'm2');
    });
  });

  group('getPredictionStats', () {
    test('returns empty stats for no predictions', () async {
      final stats = await repository.getPredictionStats();
      expect(stats.totalPredictions, 0);
      expect(stats.correctResults, 0);
    });

    test('calculates stats correctly', () async {
      await repository.savePrediction(TestDataFactory.createPrediction(
        predictionId: 'p1',
        matchId: 'm1',
        actualOutcome: PredictionOutcome.correct,
        resultCorrect: true,
        exactScoreCorrect: true,
        pointsEarned: 3,
      ));
      await repository.savePrediction(TestDataFactory.createPrediction(
        predictionId: 'p2',
        matchId: 'm2',
        actualOutcome: PredictionOutcome.incorrect,
      ));
      await repository.savePrediction(TestDataFactory.createPrediction(
        predictionId: 'p3',
        matchId: 'm3',
      ));

      final stats = await repository.getPredictionStats();
      expect(stats.totalPredictions, 3);
      expect(stats.correctResults, 1);
      expect(stats.exactScores, 1);
      expect(stats.totalPoints, 3);
      expect(stats.pendingPredictions, 1);
    });
  });

  group('hasPredictionForMatch', () {
    test('returns false when no prediction', () async {
      expect(await repository.hasPredictionForMatch('none'), isFalse);
    });

    test('returns true when prediction exists', () async {
      await repository.savePrediction(
        TestDataFactory.createPrediction(matchId: 'exists'),
      );
      expect(await repository.hasPredictionForMatch('exists'), isTrue);
    });
  });

  group('createPrediction', () {
    test('creates new prediction with generated id', () async {
      final result = await repository.createPrediction(
        matchId: 'new_match',
        predictedHomeScore: 2,
        predictedAwayScore: 1,
        homeTeamCode: 'BRA',
        homeTeamName: 'Brazil',
        awayTeamCode: 'ARG',
        awayTeamName: 'Argentina',
      );

      expect(result.matchId, 'new_match');
      expect(result.predictedHomeScore, 2);
      expect(result.predictionId, isNotEmpty);
    });

    test('updates existing prediction for same match', () async {
      await repository.createPrediction(
        matchId: 'dup_match',
        predictedHomeScore: 1,
        predictedAwayScore: 0,
      );

      final updated = await repository.createPrediction(
        matchId: 'dup_match',
        predictedHomeScore: 3,
        predictedAwayScore: 2,
      );

      expect(updated.predictedHomeScore, 3);
      final all = await repository.getAllPredictions();
      expect(all.length, 1);
    });
  });

  group('evaluatePredictions', () {
    test('evaluates matching completed matches', () async {
      await repository.savePrediction(TestDataFactory.createPrediction(
        predictionId: 'p1',
        matchId: 'match_1',
        predictedHomeScore: 2,
        predictedAwayScore: 1,
      ));

      final completedMatch = TestDataFactory.createMatch(
        matchId: 'match_1',
        homeScore: 2,
        awayScore: 1,
        status: MatchStatus.completed,
      );

      await repository.evaluatePredictions([completedMatch]);

      final prediction = await repository.getPredictionForMatch('match_1');
      expect(prediction!.resultCorrect, isTrue);
      expect(prediction.exactScoreCorrect, isTrue);
      expect(prediction.pointsEarned, 3);
    });

    test('awards 1 point for correct result but wrong score', () async {
      await repository.savePrediction(TestDataFactory.createPrediction(
        predictionId: 'p1',
        matchId: 'match_1',
        predictedHomeScore: 3,
        predictedAwayScore: 0,
      ));

      final completedMatch = TestDataFactory.createMatch(
        matchId: 'match_1',
        homeScore: 2,
        awayScore: 1,
        status: MatchStatus.completed,
      );

      await repository.evaluatePredictions([completedMatch]);

      final prediction = await repository.getPredictionForMatch('match_1');
      expect(prediction!.resultCorrect, isTrue);
      expect(prediction.exactScoreCorrect, isFalse);
      expect(prediction.pointsEarned, 1);
    });

    test('awards 0 points for incorrect prediction', () async {
      await repository.savePrediction(TestDataFactory.createPrediction(
        predictionId: 'p1',
        matchId: 'match_1',
        predictedHomeScore: 2,
        predictedAwayScore: 0,
      ));

      final completedMatch = TestDataFactory.createMatch(
        matchId: 'match_1',
        homeScore: 0,
        awayScore: 3,
        status: MatchStatus.completed,
      );

      await repository.evaluatePredictions([completedMatch]);

      final prediction = await repository.getPredictionForMatch('match_1');
      expect(prediction!.resultCorrect, isFalse);
      expect(prediction.pointsEarned, 0);
    });

    test('skips already evaluated predictions', () async {
      await repository.savePrediction(TestDataFactory.createPrediction(
        predictionId: 'p1',
        matchId: 'match_1',
        actualOutcome: PredictionOutcome.correct,
        resultCorrect: true,
        pointsEarned: 3,
      ));

      final completedMatch = TestDataFactory.createMatch(
        matchId: 'match_1',
        homeScore: 0,
        awayScore: 5,
        status: MatchStatus.completed,
      );

      await repository.evaluatePredictions([completedMatch]);

      final prediction = await repository.getPredictionForMatch('match_1');
      expect(prediction!.pointsEarned, 3);
    });

    test('skips matches that are not completed', () async {
      await repository.savePrediction(TestDataFactory.createPrediction(
        predictionId: 'p1',
        matchId: 'match_1',
      ));

      final scheduledMatch = TestDataFactory.createMatch(
        matchId: 'match_1',
        status: MatchStatus.scheduled,
      );

      await repository.evaluatePredictions([scheduledMatch]);

      final prediction = await repository.getPredictionForMatch('match_1');
      expect(prediction!.isPending, isTrue);
    });
  });

  group('clearAllPredictions', () {
    test('removes all predictions', () async {
      await repository.savePrediction(
        TestDataFactory.createPrediction(predictionId: 'p1', matchId: 'm1'),
      );
      await repository.savePrediction(
        TestDataFactory.createPrediction(predictionId: 'p2', matchId: 'm2'),
      );

      await repository.clearAllPredictions();

      final all = await repository.getAllPredictions();
      expect(all, isEmpty);
    });

    test('clears SharedPreferences keys', () async {
      await repository.savePrediction(TestDataFactory.createPrediction());
      await repository.clearAllPredictions();

      expect(
        sharedPreferences.getString('world_cup_predictions'),
        isNull,
      );
    });
  });

  group('watchPredictions', () {
    test('emits current predictions', () async {
      await repository.savePrediction(TestDataFactory.createPrediction());

      final stream = repository.watchPredictions();
      final first = await stream.first;
      expect(first.length, 1);
    });
  });

  group('watchPredictionStats', () {
    test('emits current stats', () async {
      final stream = repository.watchPredictionStats();
      final first = await stream.first;
      expect(first.totalPredictions, 0);
    });
  });
}
