import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/game_prediction.dart';
import '../../domain/entities/game_comment.dart';
import '../../../../core/services/logging_service.dart';

/// Data source for social features using Firebase Firestore
abstract class SocialDataSource {
  /// User Profile Methods
  Future<UserProfile?> getUserProfile(String userId);
  Future<void> createUserProfile(UserProfile profile);
  Future<void> updateUserProfile(UserProfile profile);
  
  /// Game Prediction Methods
  Future<void> createGamePrediction(GamePrediction prediction);
  Future<List<GamePrediction>> getGamePredictions(String gameId);
  Future<GamePrediction?> getUserPredictionForGame(String userId, String gameId);
  Future<void> updatePredictionResult(String predictionId, bool isCorrect);
  
  /// Game Comment Methods
  Future<void> createGameComment(GameComment comment);
  Future<List<GameComment>> getGameComments(String gameId);
  Future<void> likeComment(String commentId, String userId);
  Future<void> unlikeComment(String commentId, String userId);
}

class SocialDataSourceImpl implements SocialDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  SocialDataSourceImpl({
    required this.firestore,
    required this.auth,
  });

  // Collection references
  CollectionReference get _usersCollection => firestore.collection('users');
  CollectionReference get _predictionsCollection => firestore.collection('predictions');
  CollectionReference get _commentsCollection => firestore.collection('comments');

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromFirestore(Map<String, dynamic>.from(doc.data()! as Map), doc.id);
      }
      return null;
    } catch (e) {
      LoggingService.error('Error getting user profile: $e', tag: 'SocialDataSource');
      return null;
    }
  }

  @override
  Future<void> createUserProfile(UserProfile profile) async {
    try {
      await _usersCollection.doc(profile.userId).set(profile.toFirestore());
      LoggingService.info('Created user profile for ${profile.userId}', tag: 'SocialDataSource');
    } catch (e) {
      LoggingService.error('Error creating user profile: $e', tag: 'SocialDataSource');
      throw Exception('Failed to create user profile');
    }
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _usersCollection.doc(profile.userId).update(profile.toFirestore());
      LoggingService.info('Updated user profile for ${profile.userId}', tag: 'SocialDataSource');
    } catch (e) {
      LoggingService.error('Error updating user profile: $e', tag: 'SocialDataSource');
      throw Exception('Failed to update user profile');
    }
  }

  @override
  Future<void> createGamePrediction(GamePrediction prediction) async {
    try {
      // Create the prediction
      await _predictionsCollection.add(prediction.toFirestore());
      
      // Update user's prediction count
      await _updateUserPredictionCount(prediction.userId, 1);
      
      // Update game's prediction count
      await _updateGameSocialCount(prediction.gameId, 'userPredictions', 1);
    } catch (e) {
      LoggingService.error('Error creating game prediction: $e', tag: 'SocialDataSource');
      throw Exception('Failed to create prediction');
    }
  }

  @override
  Future<List<GamePrediction>> getGamePredictions(String gameId) async {
    try {
      final querySnapshot = await _predictionsCollection
          .where('gameId', isEqualTo: gameId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => GamePrediction.fromFirestore(
              Map<String, dynamic>.from(doc.data() as Map), doc.id))
          .toList();
    } catch (e) {
      LoggingService.error('Error getting game predictions: $e', tag: 'SocialDataSource');
      return [];
    }
  }

  @override
  Future<GamePrediction?> getUserPredictionForGame(String userId, String gameId) async {
    try {
      final querySnapshot = await _predictionsCollection
          .where('userId', isEqualTo: userId)
          .where('gameId', isEqualTo: gameId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return GamePrediction.fromFirestore(
            Map<String, dynamic>.from(doc.data() as Map), doc.id);
      }
      return null;
    } catch (e) {
      LoggingService.error('Error getting user prediction: $e', tag: 'SocialDataSource');
      return null;
    }
  }

  @override
  Future<void> updatePredictionResult(String predictionId, bool isCorrect) async {
    try {
      await _predictionsCollection.doc(predictionId).update({
        'isCorrect': isCorrect,
      });
    } catch (e) {
      LoggingService.error('Error updating prediction result: $e', tag: 'SocialDataSource');
      throw Exception('Failed to update prediction result');
    }
  }

  @override
  Future<void> createGameComment(GameComment comment) async {
    try {
      // Create the comment
      await _commentsCollection.add(comment.toFirestore());
      
      // Update game's comment count
      await _updateGameSocialCount(comment.gameId, 'userComments', 1);
    } catch (e) {
      LoggingService.error('Error creating game comment: $e', tag: 'SocialDataSource');
      throw Exception('Failed to create comment');
    }
  }

  @override
  Future<List<GameComment>> getGameComments(String gameId) async {
    try {
      final querySnapshot = await _commentsCollection
          .where('gameId', isEqualTo: gameId)
          .where('parentCommentId', isNull: true) // Only top-level comments
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => GameComment.fromFirestore(
              Map<String, dynamic>.from(doc.data() as Map), doc.id))
          .toList();
    } catch (e) {
      LoggingService.error('Error getting game comments: $e', tag: 'SocialDataSource');
      return [];
    }
  }

  @override
  Future<void> likeComment(String commentId, String userId) async {
    try {
      await firestore.runTransaction((transaction) async {
        final commentRef = _commentsCollection.doc(commentId);
        final commentDoc = await transaction.get(commentRef);
        
        if (commentDoc.exists) {
          final data = Map<String, dynamic>.from(commentDoc.data() as Map);
          final likedBy = List<String>.from(data['likedBy'] ?? []);
          
          if (!likedBy.contains(userId)) {
            likedBy.add(userId);
            transaction.update(commentRef, {
              'likedBy': likedBy,
              'likes': likedBy.length,
            });
          }
        }
      });
    } catch (e) {
      LoggingService.error('Error liking comment: $e', tag: 'SocialDataSource');
      throw Exception('Failed to like comment');
    }
  }

  @override
  Future<void> unlikeComment(String commentId, String userId) async {
    try {
      await firestore.runTransaction((transaction) async {
        final commentRef = _commentsCollection.doc(commentId);
        final commentDoc = await transaction.get(commentRef);
        
        if (commentDoc.exists) {
          final data = Map<String, dynamic>.from(commentDoc.data() as Map);
          final likedBy = List<String>.from(data['likedBy'] ?? []);
          
          if (likedBy.contains(userId)) {
            likedBy.remove(userId);
            transaction.update(commentRef, {
              'likedBy': likedBy,
              'likes': likedBy.length,
            });
          }
        }
      });
    } catch (e) {
      LoggingService.error('Error unliking comment: $e', tag: 'SocialDataSource');
      throw Exception('Failed to unlike comment');
    }
  }

  /// Helper method to update user's prediction count
  Future<void> _updateUserPredictionCount(String userId, int increment) async {
    try {
      await _usersCollection.doc(userId).update({
        'totalPredictions': FieldValue.increment(increment),
      });
    } catch (e) {
      LoggingService.error('Error updating user prediction count: $e', tag: 'SocialDataSource');
    }
  }

  /// Helper method to update game's social counts
  Future<void> _updateGameSocialCount(String gameId, String field, int increment) async {
    try {
      // This would update the games collection if we store social counts there
      // For now, we'll just log it since we're using the NCAA API data
      LoggingService.debug('Would update game $gameId $field by $increment', tag: 'SocialDataSource');
    } catch (e) {
      LoggingService.error('Error updating game social count: $e', tag: 'SocialDataSource');
    }
  }
} 