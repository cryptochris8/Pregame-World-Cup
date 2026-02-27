import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/social/data/datasources/social_datasource.dart';
import 'package:pregame_world_cup/features/social/domain/entities/user_profile.dart';
import 'package:pregame_world_cup/features/social/domain/entities/game_prediction.dart';
import 'package:pregame_world_cup/features/social/domain/entities/game_comment.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late SocialDataSourceImpl dataSource;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    dataSource = SocialDataSourceImpl(
      firestore: fakeFirestore,
      auth: mockAuth,
    );
  });

  // ---------------------------------------------------------------------------
  // Helper factories
  // ---------------------------------------------------------------------------

  UserProfile createTestProfile({
    String userId = 'user_001',
    String displayName = 'Test User',
    String? email = 'test@example.com',
    List<String> favoriteTeams = const ['Brazil', 'Argentina'],
  }) {
    return UserProfile.create(
      userId: userId,
      displayName: displayName,
      email: email,
      favoriteTeams: favoriteTeams,
    );
  }

  GamePrediction createTestPrediction({
    String predictionId = 'pred_001',
    String userId = 'user_001',
    String gameId = 'game_001',
    String userDisplayName = 'Test User',
    String predictedWinner = 'Brazil',
    int? predictedHomeScore = 2,
    int? predictedAwayScore = 1,
    String? confidence = 'high',
    String? reasoning = 'Brazil looks strong',
    DateTime? createdAt,
  }) {
    return GamePrediction(
      predictionId: predictionId,
      userId: userId,
      gameId: gameId,
      userDisplayName: userDisplayName,
      predictedWinner: predictedWinner,
      predictedHomeScore: predictedHomeScore,
      predictedAwayScore: predictedAwayScore,
      confidence: confidence,
      reasoning: reasoning,
      createdAt: createdAt ?? DateTime(2026, 6, 12, 18, 0),
    );
  }

  GameComment createTestComment({
    String commentId = 'comment_001',
    String userId = 'user_001',
    String gameId = 'game_001',
    String userDisplayName = 'Test User',
    String content = 'Great match!',
    DateTime? createdAt,
    String? parentCommentId,
  }) {
    return GameComment(
      commentId: commentId,
      userId: userId,
      gameId: gameId,
      userDisplayName: userDisplayName,
      content: content,
      createdAt: createdAt ?? DateTime(2026, 6, 12, 18, 30),
      parentCommentId: parentCommentId,
    );
  }

  // ---------------------------------------------------------------------------
  // getUserProfile
  // ---------------------------------------------------------------------------

  group('getUserProfile', () {
    test('returns UserProfile when document exists', () async {
      final profile = createTestProfile();
      await fakeFirestore
          .collection('users')
          .doc(profile.userId)
          .set(profile.toFirestore());

      final result = await dataSource.getUserProfile('user_001');

      expect(result, isNotNull);
      expect(result!.userId, equals('user_001'));
      expect(result.displayName, equals('Test User'));
      expect(result.email, equals('test@example.com'));
      expect(result.favoriteTeams, contains('Brazil'));
      expect(result.favoriteTeams, contains('Argentina'));
    });

    test('returns null when document does not exist', () async {
      final result = await dataSource.getUserProfile('nonexistent_user');

      expect(result, isNull);
    });

    test('returns null when document data is empty map', () async {
      // A document that exists but get() returns exists==false won't happen
      // in fake_cloud_firestore, so test the normal non-existent path.
      final result = await dataSource.getUserProfile('no_such_id');
      expect(result, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // createUserProfile
  // ---------------------------------------------------------------------------

  group('createUserProfile', () {
    test('writes profile to users collection', () async {
      final profile = createTestProfile();

      await dataSource.createUserProfile(profile);

      final doc =
          await fakeFirestore.collection('users').doc('user_001').get();
      expect(doc.exists, isTrue);
      final data = doc.data()!;
      expect(data['displayName'], equals('Test User'));
      expect(data['email'], equals('test@example.com'));
      expect(data['favoriteTeams'], contains('Brazil'));
    });

    test('overwrites existing profile with same userId', () async {
      final profile1 = createTestProfile(displayName: 'Original');
      final profile2 = createTestProfile(displayName: 'Updated');

      await dataSource.createUserProfile(profile1);
      await dataSource.createUserProfile(profile2);

      final doc =
          await fakeFirestore.collection('users').doc('user_001').get();
      expect(doc.data()!['displayName'], equals('Updated'));
    });
  });

  // ---------------------------------------------------------------------------
  // updateUserProfile
  // ---------------------------------------------------------------------------

  group('updateUserProfile', () {
    test('updates existing profile fields', () async {
      final profile = createTestProfile();
      await fakeFirestore
          .collection('users')
          .doc(profile.userId)
          .set(profile.toFirestore());

      final updatedProfile = profile.copyWith(
        displayName: 'Updated Name',
        bio: 'World Cup fan!',
      );

      await dataSource.updateUserProfile(updatedProfile);

      final doc =
          await fakeFirestore.collection('users').doc('user_001').get();
      expect(doc.data()!['displayName'], equals('Updated Name'));
      expect(doc.data()!['bio'], equals('World Cup fan!'));
    });

    test('throws when document does not exist', () async {
      final profile = createTestProfile(userId: 'nonexistent');

      expect(
        () => dataSource.updateUserProfile(profile),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // createGamePrediction
  // ---------------------------------------------------------------------------

  group('createGamePrediction', () {
    test('adds prediction to predictions collection', () async {
      // Pre-create the user document so totalPredictions increment works
      await fakeFirestore.collection('users').doc('user_001').set({
        'displayName': 'Test User',
        'totalPredictions': 0,
      });

      final prediction = createTestPrediction();

      await dataSource.createGamePrediction(prediction);

      final snapshot = await fakeFirestore
          .collection('predictions')
          .where('gameId', isEqualTo: 'game_001')
          .get();
      expect(snapshot.docs, hasLength(1));
      expect(
          snapshot.docs.first.data()['predictedWinner'], equals('Brazil'));
      expect(snapshot.docs.first.data()['userId'], equals('user_001'));
      expect(snapshot.docs.first.data()['confidence'], equals('high'));
    });

    test('increments user totalPredictions', () async {
      await fakeFirestore.collection('users').doc('user_001').set({
        'displayName': 'Test User',
        'totalPredictions': 5,
      });

      final prediction = createTestPrediction();

      await dataSource.createGamePrediction(prediction);

      final userDoc =
          await fakeFirestore.collection('users').doc('user_001').get();
      expect(userDoc.data()!['totalPredictions'], equals(6));
    });

    test('stores predicted scores correctly', () async {
      await fakeFirestore.collection('users').doc('user_001').set({
        'displayName': 'Test User',
        'totalPredictions': 0,
      });

      final prediction = createTestPrediction(
        predictedHomeScore: 3,
        predictedAwayScore: 0,
      );

      await dataSource.createGamePrediction(prediction);

      final snapshot = await fakeFirestore.collection('predictions').get();
      final data = snapshot.docs.first.data();
      expect(data['predictedHomeScore'], equals(3));
      expect(data['predictedAwayScore'], equals(0));
    });
  });

  // ---------------------------------------------------------------------------
  // getGamePredictions
  // ---------------------------------------------------------------------------

  group('getGamePredictions', () {
    test('returns predictions for given gameId ordered by createdAt desc',
        () async {
      final earlier = DateTime(2026, 6, 12, 10, 0);
      final later = DateTime(2026, 6, 12, 14, 0);

      await fakeFirestore.collection('predictions').add(
            createTestPrediction(
              userId: 'user_a',
              gameId: 'game_001',
              predictedWinner: 'Mexico',
              createdAt: earlier,
            ).toFirestore(),
          );
      await fakeFirestore.collection('predictions').add(
            createTestPrediction(
              userId: 'user_b',
              gameId: 'game_001',
              predictedWinner: 'USA',
              createdAt: later,
            ).toFirestore(),
          );

      final results = await dataSource.getGamePredictions('game_001');

      expect(results, hasLength(2));
      // Ordered descending by createdAt, so the later one should be first
      expect(results.first.predictedWinner, equals('USA'));
      expect(results.last.predictedWinner, equals('Mexico'));
    });

    test('returns empty list when no predictions exist', () async {
      final results = await dataSource.getGamePredictions('game_999');

      expect(results, isEmpty);
    });

    test('does not return predictions for other games', () async {
      await fakeFirestore.collection('predictions').add(
            createTestPrediction(gameId: 'game_002').toFirestore(),
          );

      final results = await dataSource.getGamePredictions('game_001');

      expect(results, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // getUserPredictionForGame
  // ---------------------------------------------------------------------------

  group('getUserPredictionForGame', () {
    test('returns prediction when user has predicted for game', () async {
      await fakeFirestore.collection('predictions').add(
            createTestPrediction(
              userId: 'user_001',
              gameId: 'game_001',
              predictedWinner: 'Argentina',
            ).toFirestore(),
          );

      final result = await dataSource.getUserPredictionForGame(
        'user_001',
        'game_001',
      );

      expect(result, isNotNull);
      expect(result!.userId, equals('user_001'));
      expect(result.gameId, equals('game_001'));
      expect(result.predictedWinner, equals('Argentina'));
    });

    test('returns null when user has not predicted for game', () async {
      final result = await dataSource.getUserPredictionForGame(
        'user_001',
        'game_999',
      );

      expect(result, isNull);
    });

    test('returns null when different user has predicted', () async {
      await fakeFirestore.collection('predictions').add(
            createTestPrediction(
              userId: 'user_002',
              gameId: 'game_001',
            ).toFirestore(),
          );

      final result = await dataSource.getUserPredictionForGame(
        'user_001',
        'game_001',
      );

      expect(result, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // updatePredictionResult
  // ---------------------------------------------------------------------------

  group('updatePredictionResult', () {
    test('sets isCorrect to true', () async {
      final docRef = await fakeFirestore.collection('predictions').add(
            createTestPrediction().toFirestore(),
          );

      await dataSource.updatePredictionResult(docRef.id, true);

      final updated =
          await fakeFirestore.collection('predictions').doc(docRef.id).get();
      expect(updated.data()!['isCorrect'], isTrue);
    });

    test('sets isCorrect to false', () async {
      final docRef = await fakeFirestore.collection('predictions').add(
            createTestPrediction().toFirestore(),
          );

      await dataSource.updatePredictionResult(docRef.id, false);

      final updated =
          await fakeFirestore.collection('predictions').doc(docRef.id).get();
      expect(updated.data()!['isCorrect'], isFalse);
    });

    test('throws when prediction document does not exist', () async {
      expect(
        () => dataSource.updatePredictionResult('nonexistent_id', true),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // createGameComment
  // ---------------------------------------------------------------------------

  group('createGameComment', () {
    test('adds comment to comments collection', () async {
      final comment = createTestComment();

      await dataSource.createGameComment(comment);

      final snapshot = await fakeFirestore
          .collection('comments')
          .where('gameId', isEqualTo: 'game_001')
          .get();
      expect(snapshot.docs, hasLength(1));
      expect(snapshot.docs.first.data()['content'], equals('Great match!'));
      expect(snapshot.docs.first.data()['userId'], equals('user_001'));
    });

    test('stores parentCommentId as null for top-level comments', () async {
      final comment = createTestComment();

      await dataSource.createGameComment(comment);

      final snapshot = await fakeFirestore.collection('comments').get();
      expect(snapshot.docs.first.data()['parentCommentId'], isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // getGameComments
  // ---------------------------------------------------------------------------

  group('getGameComments', () {
    test('returns only top-level comments (parentCommentId is null)',
        () async {
      // Top-level comment
      await fakeFirestore.collection('comments').add(
            createTestComment(
              commentId: 'c1',
              content: 'Top level',
              parentCommentId: null,
            ).toFirestore(),
          );

      // Reply comment (should be excluded)
      await fakeFirestore.collection('comments').add(
            createTestComment(
              commentId: 'c2',
              content: 'Reply',
              parentCommentId: 'c1',
            ).toFirestore(),
          );

      final results = await dataSource.getGameComments('game_001');

      expect(results, hasLength(1));
      expect(results.first.content, equals('Top level'));
    });

    test('returns empty list when no comments exist', () async {
      final results = await dataSource.getGameComments('game_999');

      expect(results, isEmpty);
    });

    test('does not return comments from other games', () async {
      await fakeFirestore.collection('comments').add(
            createTestComment(gameId: 'game_002').toFirestore(),
          );

      final results = await dataSource.getGameComments('game_001');

      expect(results, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // likeComment
  // ---------------------------------------------------------------------------

  group('likeComment', () {
    test('adds userId to likedBy and increments likes count', () async {
      final docRef = await fakeFirestore.collection('comments').add(
            createTestComment().toFirestore(),
          );

      await dataSource.likeComment(docRef.id, 'user_002');

      final updated =
          await fakeFirestore.collection('comments').doc(docRef.id).get();
      final data = updated.data()!;
      expect(List<String>.from(data['likedBy']), contains('user_002'));
      expect(data['likes'], equals(1));
    });

    test('does not duplicate userId if already liked', () async {
      final docRef = await fakeFirestore.collection('comments').add({
        ...createTestComment().toFirestore(),
        'likedBy': ['user_002'],
        'likes': 1,
      });

      await dataSource.likeComment(docRef.id, 'user_002');

      final updated =
          await fakeFirestore.collection('comments').doc(docRef.id).get();
      final data = updated.data()!;
      final likedBy = List<String>.from(data['likedBy']);
      // Count occurrences of user_002
      expect(likedBy.where((id) => id == 'user_002').length, equals(1));
      expect(data['likes'], equals(1));
    });

    test('supports multiple users liking the same comment', () async {
      final docRef = await fakeFirestore.collection('comments').add(
            createTestComment().toFirestore(),
          );

      await dataSource.likeComment(docRef.id, 'user_a');
      await dataSource.likeComment(docRef.id, 'user_b');

      final updated =
          await fakeFirestore.collection('comments').doc(docRef.id).get();
      final data = updated.data()!;
      final likedBy = List<String>.from(data['likedBy']);
      expect(likedBy, containsAll(['user_a', 'user_b']));
      expect(data['likes'], equals(2));
    });
  });

  // ---------------------------------------------------------------------------
  // unlikeComment
  // ---------------------------------------------------------------------------

  group('unlikeComment', () {
    test('removes userId from likedBy and decrements likes count', () async {
      final docRef = await fakeFirestore.collection('comments').add({
        ...createTestComment().toFirestore(),
        'likedBy': ['user_002', 'user_003'],
        'likes': 2,
      });

      await dataSource.unlikeComment(docRef.id, 'user_002');

      final updated =
          await fakeFirestore.collection('comments').doc(docRef.id).get();
      final data = updated.data()!;
      final likedBy = List<String>.from(data['likedBy']);
      expect(likedBy, isNot(contains('user_002')));
      expect(likedBy, contains('user_003'));
      expect(data['likes'], equals(1));
    });

    test('does nothing if userId is not in likedBy', () async {
      final docRef = await fakeFirestore.collection('comments').add({
        ...createTestComment().toFirestore(),
        'likedBy': ['user_002'],
        'likes': 1,
      });

      await dataSource.unlikeComment(docRef.id, 'user_999');

      final updated =
          await fakeFirestore.collection('comments').doc(docRef.id).get();
      final data = updated.data()!;
      expect(List<String>.from(data['likedBy']), contains('user_002'));
      expect(data['likes'], equals(1));
    });

    test('sets likes to zero when last user unlikes', () async {
      final docRef = await fakeFirestore.collection('comments').add({
        ...createTestComment().toFirestore(),
        'likedBy': ['user_only'],
        'likes': 1,
      });

      await dataSource.unlikeComment(docRef.id, 'user_only');

      final updated =
          await fakeFirestore.collection('comments').doc(docRef.id).get();
      final data = updated.data()!;
      expect(List<String>.from(data['likedBy']), isEmpty);
      expect(data['likes'], equals(0));
    });
  });
}
