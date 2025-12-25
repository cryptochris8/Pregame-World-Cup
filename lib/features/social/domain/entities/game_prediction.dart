import 'package:cloud_firestore/cloud_firestore.dart';

/// Game prediction entity for social features
class GamePrediction {
  final String predictionId;
  final String userId;
  final String gameId;
  final String userDisplayName;
  final String? userProfileImageUrl;
  final String predictedWinner; // Team name
  final int? predictedAwayScore;
  final int? predictedHomeScore;
  final String? confidence; // 'low', 'medium', 'high'
  final String? reasoning; // User's explanation for their prediction
  final DateTime createdAt;
  final bool? isCorrect; // Set after game completion
  final int likes; // Number of likes from other users
  final List<String> likedBy; // User IDs who liked this prediction

  GamePrediction({
    required this.predictionId,
    required this.userId,
    required this.gameId,
    required this.userDisplayName,
    this.userProfileImageUrl,
    required this.predictedWinner,
    this.predictedAwayScore,
    this.predictedHomeScore,
    this.confidence,
    this.reasoning,
    required this.createdAt,
    this.isCorrect,
    this.likes = 0,
    this.likedBy = const [],
  });

  /// Factory method to create from Firestore document
  factory GamePrediction.fromFirestore(Map<String, dynamic> data, String docId) {
    return GamePrediction(
      predictionId: docId,
      userId: data['userId'] ?? '',
      gameId: data['gameId'] ?? '',
      userDisplayName: data['userDisplayName'] ?? 'Anonymous',
      userProfileImageUrl: data['userProfileImageUrl'] as String?,
      predictedWinner: data['predictedWinner'] ?? '',
      predictedAwayScore: data['predictedAwayScore'] as int?,
      predictedHomeScore: data['predictedHomeScore'] as int?,
      confidence: data['confidence'] as String?,
      reasoning: data['reasoning'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCorrect: data['isCorrect'] as bool?,
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'gameId': gameId,
      'userDisplayName': userDisplayName,
      'userProfileImageUrl': userProfileImageUrl,
      'predictedWinner': predictedWinner,
      'predictedAwayScore': predictedAwayScore,
      'predictedHomeScore': predictedHomeScore,
      'confidence': confidence,
      'reasoning': reasoning,
      'createdAt': Timestamp.fromDate(createdAt),
      'isCorrect': isCorrect,
      'likes': likes,
      'likedBy': likedBy,
    };
  }

  /// Create a copy with updated fields
  GamePrediction copyWith({
    String? userDisplayName,
    String? userProfileImageUrl,
    String? predictedWinner,
    int? predictedAwayScore,
    int? predictedHomeScore,
    String? confidence,
    String? reasoning,
    bool? isCorrect,
    int? likes,
    List<String>? likedBy,
  }) {
    return GamePrediction(
      predictionId: predictionId,
      userId: userId,
      gameId: gameId,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      userProfileImageUrl: userProfileImageUrl ?? this.userProfileImageUrl,
      predictedWinner: predictedWinner ?? this.predictedWinner,
      predictedAwayScore: predictedAwayScore ?? this.predictedAwayScore,
      predictedHomeScore: predictedHomeScore ?? this.predictedHomeScore,
      confidence: confidence ?? this.confidence,
      reasoning: reasoning ?? this.reasoning,
      createdAt: createdAt,
      isCorrect: isCorrect ?? this.isCorrect,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
    );
  }
} 