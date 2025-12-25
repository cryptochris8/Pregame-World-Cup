import 'package:cloud_firestore/cloud_firestore.dart';

/// Types of user interactions for learning
enum UserInteractionType {
  venueSelection,
  venueRating,
  recommendationFeedback,
  gameView,
  socialShare,
}

/// Entity representing a user interaction for AI learning
class UserInteraction {
  final String interactionId;
  final String userId;
  final UserInteractionType type;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  const UserInteraction({
    required this.interactionId,
    required this.userId,
    required this.type,
    required this.timestamp,
    required this.data,
  });

  /// Create from Firestore document
  factory UserInteraction.fromFirestore(DocumentSnapshot doc) {
    final data = Map<String, dynamic>.from(doc.data() as Map);
    
    return UserInteraction(
      interactionId: doc.id,
      userId: data['userId'] as String,
      type: UserInteractionType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => UserInteractionType.venueSelection,
      ),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      data: Map<String, dynamic>.from(data['data'] ?? {}),
    );
  }

  /// Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.toString(),
      'timestamp': Timestamp.fromDate(timestamp),
      'data': data,
    };
  }

  /// Create copy with new data
  UserInteraction copyWith({
    String? interactionId,
    String? userId,
    UserInteractionType? type,
    DateTime? timestamp,
    Map<String, dynamic>? data,
  }) {
    return UserInteraction(
      interactionId: interactionId ?? this.interactionId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      data: data ?? this.data,
    );
  }

  @override
  String toString() {
    return 'UserInteraction(id: $interactionId, type: $type, userId: $userId, timestamp: $timestamp)';
  }
} 