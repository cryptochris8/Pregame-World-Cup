import 'dart:convert';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../worldcup/presentation/bloc/mock_repositories.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late SharedPreferences sharedPreferences;
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late PredictionsRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();

    // Return null for currentUser so Firestore sync is a no-op by default
    when(() => mockAuth.currentUser).thenReturn(null);

    repository = PredictionsRepositoryImpl(
      sharedPreferences: sharedPreferences,
      firestore: fakeFirestore,
      firebaseAuth: mockAuth,
    );
  });

  tearDown(() {
    repository.dispose();
  });

  PredictionsRepositoryImpl createFreshRepository() {
    return PredictionsRepositoryImpl(
      sharedPreferences: sharedPreferences,
      firestore: fakeFirestore,
      firebaseAuth: mockAuth,
    );
  }

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
      repository = createFreshRepository();

      final result = await repository.getAllPredictions();
      expect(result.length, 1);
      expect(result.first.matchId, prediction.matchId);
    });

    test('returns empty list on corrupted JSON', () async {
      SharedPreferences.setMockInitialValues({
        'world_cup_predictions': 'not valid json',
      });
      sharedPreferences = await SharedPreferences.getInstance();
      repository = createFreshRepository();

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

    test('syncs to Firestore when user is logged in', () async {
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('user_123');
      when(() => mockUser.displayName).thenReturn('Test User');
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      final prediction = TestDataFactory.createPrediction(matchId: 'match_fs');
      await repository.savePrediction(prediction);

      // Verify Firestore document was created
      final doc = await fakeFirestore
          .collection('user_predictions')
          .doc('user_123')
          .collection('predictions')
          .doc('match_fs')
          .get();

      expect(doc.exists, isTrue);
      expect(doc.data()!['matchId'], 'match_fs');
      expect(doc.data()!['userId'], 'user_123');
      expect(doc.data()!['predictedHomeScore'], 2);
      expect(doc.data()!['predictedAwayScore'], 1);
    });

    test('stamps userId onto prediction when user is logged in', () async {
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('user_stamp');
      when(() => mockUser.displayName).thenReturn('Stamped User');
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      final prediction = TestDataFactory.createPrediction(matchId: 'match_stamp');
      final result = await repository.savePrediction(prediction);

      expect(result.userId, 'user_stamp');
    });

    test('updates leaderboard when user is logged in', () async {
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('user_lb');
      when(() => mockUser.displayName).thenReturn('Leaderboard User');
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      await repository.savePrediction(
        TestDataFactory.createPrediction(matchId: 'm1'),
      );

      final leaderboardDoc = await fakeFirestore
          .collection('prediction_leaderboard')
          .doc('user_lb')
          .get();

      expect(leaderboardDoc.exists, isTrue);
      expect(leaderboardDoc.data()!['totalPredictions'], 1);
      expect(leaderboardDoc.data()!['displayName'], 'Leaderboard User');
    });

    test('does not fail when user is not logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final prediction = TestDataFactory.createPrediction();
      final result = await repository.savePrediction(prediction);

      // Should still save locally without error
      expect(result.matchId, prediction.matchId);
      final all = await repository.getAllPredictions();
      expect(all.length, 1);
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

    test('syncs updated prediction to Firestore', () async {
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('user_upd');
      when(() => mockUser.displayName).thenReturn('Update User');
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      final prediction = TestDataFactory.createPrediction(
        predictionId: 'pred_upd',
        matchId: 'match_upd',
        predictedHomeScore: 1,
      );
      await repository.savePrediction(prediction);

      final updated = prediction.copyWith(predictedHomeScore: 4);
      await repository.updatePrediction(updated);

      final doc = await fakeFirestore
          .collection('user_predictions')
          .doc('user_upd')
          .collection('predictions')
          .doc('match_upd')
          .get();

      expect(doc.exists, isTrue);
      expect(doc.data()!['predictedHomeScore'], 4);
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

    test('deletes from Firestore when user is logged in', () async {
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('user_del');
      when(() => mockUser.displayName).thenReturn('Del User');
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      final prediction = TestDataFactory.createPrediction(
        predictionId: 'del_fs',
        matchId: 'match_del_fs',
      );
      await repository.savePrediction(prediction);

      // Verify it exists first
      var doc = await fakeFirestore
          .collection('user_predictions')
          .doc('user_del')
          .collection('predictions')
          .doc('match_del_fs')
          .get();
      expect(doc.exists, isTrue);

      await repository.deletePrediction('del_fs');

      // Verify it was deleted from Firestore
      doc = await fakeFirestore
          .collection('user_predictions')
          .doc('user_del')
          .collection('predictions')
          .doc('match_del_fs')
          .get();
      expect(doc.exists, isFalse);
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

    test('stamps userId when user is logged in', () async {
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('user_create');
      when(() => mockUser.displayName).thenReturn('Create User');
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      final result = await repository.createPrediction(
        matchId: 'new_match_uid',
        predictedHomeScore: 1,
        predictedAwayScore: 0,
      );

      expect(result.userId, 'user_create');
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

    test('syncs evaluated predictions and leaderboard to Firestore', () async {
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('user_eval');
      when(() => mockUser.displayName).thenReturn('Eval User');
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      await repository.savePrediction(TestDataFactory.createPrediction(
        predictionId: 'p1',
        matchId: 'match_eval',
        predictedHomeScore: 2,
        predictedAwayScore: 1,
      ));

      final completedMatch = TestDataFactory.createMatch(
        matchId: 'match_eval',
        homeScore: 2,
        awayScore: 1,
        status: MatchStatus.completed,
      );

      await repository.evaluatePredictions([completedMatch]);

      // Check leaderboard was updated
      final leaderboardDoc = await fakeFirestore
          .collection('prediction_leaderboard')
          .doc('user_eval')
          .get();

      expect(leaderboardDoc.exists, isTrue);
      expect(leaderboardDoc.data()!['totalPoints'], 3);
      expect(leaderboardDoc.data()!['correctExact'], 1);
      expect(leaderboardDoc.data()!['correctOutcome'], 1);
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

    test('clears Firestore predictions and leaderboard', () async {
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('user_clear');
      when(() => mockUser.displayName).thenReturn('Clear User');
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      await repository.savePrediction(
        TestDataFactory.createPrediction(predictionId: 'p1', matchId: 'm1'),
      );
      await repository.savePrediction(
        TestDataFactory.createPrediction(predictionId: 'p2', matchId: 'm2'),
      );

      await repository.clearAllPredictions();

      // Verify Firestore predictions cleared
      final snapshot = await fakeFirestore
          .collection('user_predictions')
          .doc('user_clear')
          .collection('predictions')
          .get();
      expect(snapshot.docs, isEmpty);

      // Verify leaderboard cleared
      final leaderboardDoc = await fakeFirestore
          .collection('prediction_leaderboard')
          .doc('user_clear')
          .get();
      expect(leaderboardDoc.exists, isFalse);
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

  group('syncToFirestore', () {
    test('does nothing when user is not logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      await repository.savePrediction(TestDataFactory.createPrediction());
      await repository.syncToFirestore();

      // No Firestore documents should exist
      final snapshot = await fakeFirestore.collection('user_predictions').get();
      expect(snapshot.docs, isEmpty);
    });

    test('syncs all local predictions to Firestore', () async {
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('user_sync');
      when(() => mockUser.displayName).thenReturn('Sync User');
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      // Save predictions locally (user is logged out at this point for save)
      when(() => mockAuth.currentUser).thenReturn(null);
      await repository.savePrediction(
        TestDataFactory.createPrediction(predictionId: 'p1', matchId: 'm1'),
      );
      await repository.savePrediction(
        TestDataFactory.createPrediction(predictionId: 'p2', matchId: 'm2'),
      );

      // Now log in and sync
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      await repository.syncToFirestore();

      final snapshot = await fakeFirestore
          .collection('user_predictions')
          .doc('user_sync')
          .collection('predictions')
          .get();

      expect(snapshot.docs.length, 2);

      // Verify leaderboard was updated
      final leaderboardDoc = await fakeFirestore
          .collection('prediction_leaderboard')
          .doc('user_sync')
          .get();
      expect(leaderboardDoc.exists, isTrue);
      expect(leaderboardDoc.data()!['totalPredictions'], 2);
    });
  });

  group('syncFromFirestore', () {
    test('does nothing when user is not logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      await repository.syncFromFirestore();

      final all = await repository.getAllPredictions();
      expect(all, isEmpty);
    });

    test('pulls predictions from Firestore to local', () async {
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('user_pull');
      when(() => mockUser.displayName).thenReturn('Pull User');
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      // Seed Firestore directly (simulating predictions from another device)
      await fakeFirestore
          .collection('user_predictions')
          .doc('user_pull')
          .collection('predictions')
          .doc('match_remote')
          .set({
        'predictionId': 'pred_remote',
        'matchId': 'match_remote',
        'userId': 'user_pull',
        'predictedHomeScore': 3,
        'predictedAwayScore': 0,
        'predictedOutcome': 'pending',
        'pointsEarned': 0,
        'exactScoreCorrect': false,
        'resultCorrect': false,
        'homeTeamCode': 'BRA',
        'homeTeamName': 'Brazil',
        'awayTeamCode': 'GER',
        'awayTeamName': 'Germany',
        'createdAt': DateTime(2026, 6, 10).toIso8601String(),
      });

      await repository.syncFromFirestore();

      final all = await repository.getAllPredictions();
      expect(all.length, 1);
      expect(all.first.matchId, 'match_remote');
      expect(all.first.predictedHomeScore, 3);
      expect(all.first.homeTeamCode, 'BRA');
    });

    test('merges remote predictions with local ones', () async {
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('user_merge');
      when(() => mockUser.displayName).thenReturn('Merge User');
      // Save a local prediction while logged out
      when(() => mockAuth.currentUser).thenReturn(null);
      await repository.savePrediction(
        TestDataFactory.createPrediction(
          predictionId: 'local_pred',
          matchId: 'match_local',
        ),
      );

      // Now log in
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      // Seed a different prediction in Firestore
      await fakeFirestore
          .collection('user_predictions')
          .doc('user_merge')
          .collection('predictions')
          .doc('match_remote2')
          .set({
        'predictionId': 'pred_remote2',
        'matchId': 'match_remote2',
        'userId': 'user_merge',
        'predictedHomeScore': 1,
        'predictedAwayScore': 1,
        'predictedOutcome': 'pending',
        'pointsEarned': 0,
        'exactScoreCorrect': false,
        'resultCorrect': false,
        'createdAt': DateTime(2026, 6, 10).toIso8601String(),
      });

      await repository.syncFromFirestore();

      final all = await repository.getAllPredictions();
      expect(all.length, 2);
      expect(all.any((p) => p.matchId == 'match_local'), isTrue);
      expect(all.any((p) => p.matchId == 'match_remote2'), isTrue);
    });

    test('uses more recent version when same match exists locally and remotely', () async {
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('user_recent');
      when(() => mockUser.displayName).thenReturn('Recent User');

      // Save a local prediction (older)
      when(() => mockAuth.currentUser).thenReturn(null);
      await repository.savePrediction(
        TestDataFactory.createPrediction(
          predictionId: 'local_p',
          matchId: 'match_conflict',
          predictedHomeScore: 1,
          predictedAwayScore: 0,
          createdAt: DateTime(2026, 6, 1),
        ),
      );

      when(() => mockAuth.currentUser).thenReturn(mockUser);

      // Seed a newer version in Firestore
      await fakeFirestore
          .collection('user_predictions')
          .doc('user_recent')
          .collection('predictions')
          .doc('match_conflict')
          .set({
        'predictionId': 'remote_p',
        'matchId': 'match_conflict',
        'userId': 'user_recent',
        'predictedHomeScore': 4,
        'predictedAwayScore': 2,
        'predictedOutcome': 'pending',
        'pointsEarned': 0,
        'exactScoreCorrect': false,
        'resultCorrect': false,
        'createdAt': DateTime(2026, 6, 15).toIso8601String(),
      });

      await repository.syncFromFirestore();

      final all = await repository.getAllPredictions();
      expect(all.length, 1);
      expect(all.first.predictedHomeScore, 4);
      expect(all.first.predictedAwayScore, 2);
    });

    test('does not overwrite local with older remote', () async {
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('user_keep_local');
      when(() => mockUser.displayName).thenReturn('KeepLocal User');

      // Save a local prediction (newer)
      when(() => mockAuth.currentUser).thenReturn(null);
      await repository.savePrediction(
        TestDataFactory.createPrediction(
          predictionId: 'local_newer',
          matchId: 'match_keep',
          predictedHomeScore: 5,
          predictedAwayScore: 0,
          createdAt: DateTime(2026, 6, 20),
        ),
      );

      when(() => mockAuth.currentUser).thenReturn(mockUser);

      // Seed an older version in Firestore
      await fakeFirestore
          .collection('user_predictions')
          .doc('user_keep_local')
          .collection('predictions')
          .doc('match_keep')
          .set({
        'predictionId': 'remote_older',
        'matchId': 'match_keep',
        'userId': 'user_keep_local',
        'predictedHomeScore': 1,
        'predictedAwayScore': 1,
        'predictedOutcome': 'pending',
        'pointsEarned': 0,
        'exactScoreCorrect': false,
        'resultCorrect': false,
        'createdAt': DateTime(2026, 6, 5).toIso8601String(),
      });

      await repository.syncFromFirestore();

      final all = await repository.getAllPredictions();
      expect(all.length, 1);
      expect(all.first.predictedHomeScore, 5); // local version kept
    });
  });

  group('Firestore document structure', () {
    test('stores correct fields in prediction document', () async {
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('user_fields');
      when(() => mockUser.displayName).thenReturn('Fields User');
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      await repository.savePrediction(
        TestDataFactory.createPrediction(
          predictionId: 'pred_fields',
          matchId: 'match_fields',
          predictedHomeScore: 2,
          predictedAwayScore: 1,
          homeTeamCode: 'USA',
          homeTeamName: 'United States',
          awayTeamCode: 'MEX',
          awayTeamName: 'Mexico',
        ),
      );

      final doc = await fakeFirestore
          .collection('user_predictions')
          .doc('user_fields')
          .collection('predictions')
          .doc('match_fields')
          .get();

      final data = doc.data()!;
      expect(data['userId'], 'user_fields');
      expect(data['matchId'], 'match_fields');
      expect(data['predictionId'], 'pred_fields');
      expect(data['predictedHomeScore'], 2);
      expect(data['predictedAwayScore'], 1);
      expect(data['homeTeamCode'], 'USA');
      expect(data['homeTeamName'], 'United States');
      expect(data['awayTeamCode'], 'MEX');
      expect(data['awayTeamName'], 'Mexico');
      expect(data['predictedOutcome'], isNotNull);
      expect(data['createdAt'], isNotNull);
    });

    test('stores correct fields in leaderboard document', () async {
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('user_lb_fields');
      when(() => mockUser.displayName).thenReturn('LB Fields User');
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      // Save evaluated predictions for meaningful stats
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
        actualOutcome: PredictionOutcome.correct,
        resultCorrect: true,
        pointsEarned: 1,
      ));
      await repository.savePrediction(TestDataFactory.createPrediction(
        predictionId: 'p3',
        matchId: 'm3',
      ));

      final doc = await fakeFirestore
          .collection('prediction_leaderboard')
          .doc('user_lb_fields')
          .get();

      final data = doc.data()!;
      expect(data['userId'], 'user_lb_fields');
      expect(data['displayName'], 'LB Fields User');
      expect(data['totalPredictions'], 3);
      expect(data['correctExact'], 1);
      expect(data['correctOutcome'], 2);
      expect(data['totalPoints'], 4);
      expect(data['pendingPredictions'], 1);
    });
  });
}
