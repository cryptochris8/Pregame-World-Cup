import 'package:cloud_firestore/cloud_firestore.dart';

/// Game comment entity for social features
class GameComment {
  final String commentId;
  final String userId;
  final String gameId;
  final String userDisplayName;
  final String? userProfileImageUrl;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likes;
  final List<String> likedBy; // User IDs who liked this comment
  final String? parentCommentId; // For replies to comments
  final List<String> replies; // Comment IDs of replies

  GameComment({
    required this.commentId,
    required this.userId,
    required this.gameId,
    required this.userDisplayName,
    this.userProfileImageUrl,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.likes = 0,
    this.likedBy = const [],
    this.parentCommentId,
    this.replies = const [],
  });

  /// Factory method to create from Firestore document
  factory GameComment.fromFirestore(Map<String, dynamic> data, String docId) {
    return GameComment(
      commentId: docId,
      userId: data['userId'] ?? '',
      gameId: data['gameId'] ?? '',
      userDisplayName: data['userDisplayName'] ?? 'Anonymous',
      userProfileImageUrl: data['userProfileImageUrl'] as String?,
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      parentCommentId: data['parentCommentId'] as String?,
      replies: List<String>.from(data['replies'] ?? []),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'gameId': gameId,
      'userDisplayName': userDisplayName,
      'userProfileImageUrl': userProfileImageUrl,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'likes': likes,
      'likedBy': likedBy,
      'parentCommentId': parentCommentId,
      'replies': replies,
    };
  }

  /// Create a copy with updated fields
  GameComment copyWith({
    String? userDisplayName,
    String? userProfileImageUrl,
    String? content,
    DateTime? updatedAt,
    int? likes,
    List<String>? likedBy,
    List<String>? replies,
  }) {
    return GameComment(
      commentId: commentId,
      userId: userId,
      gameId: gameId,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      userProfileImageUrl: userProfileImageUrl ?? this.userProfileImageUrl,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
      parentCommentId: parentCommentId,
      replies: replies ?? this.replies,
    );
  }
} 