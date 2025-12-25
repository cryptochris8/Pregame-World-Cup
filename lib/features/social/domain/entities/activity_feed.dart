import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'activity_feed.g.dart';

@HiveType(typeId: 12)
class ActivityFeedItem extends Equatable {
  @HiveField(0)
  final String activityId;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final String userName;
  
  @HiveField(3)
  final String? userProfileImage;
  
  @HiveField(4)
  final ActivityType type;
  
  @HiveField(5)
  final String content;
  
  @HiveField(6)
  final DateTime createdAt;
  
  @HiveField(7)
  final Map<String, dynamic> metadata;
  
  @HiveField(8)
  final List<String> mentionedUsers;
  
  @HiveField(9)
  final List<String> tags;
  
  @HiveField(10)
  final String? relatedGameId;
  
  @HiveField(11)
  final String? relatedVenueId;
  
  @HiveField(12)
  final int likesCount;
  
  @HiveField(13)
  final int commentsCount;
  
  @HiveField(14)
  final bool isPublic;

  const ActivityFeedItem({
    required this.activityId,
    required this.userId,
    required this.userName,
    this.userProfileImage,
    required this.type,
    required this.content,
    required this.createdAt,
    this.metadata = const {},
    this.mentionedUsers = const [],
    this.tags = const [],
    this.relatedGameId,
    this.relatedVenueId,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isPublic = true,
  });

  factory ActivityFeedItem.createCheckIn({
    required String userId,
    required String userName,
    String? userProfileImage,
    required String venueName,
    required String venueId,
    String? gameId,
    String? note,
  }) {
    return ActivityFeedItem(
      activityId: '${userId}_checkin_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      userName: userName,
      userProfileImage: userProfileImage,
      type: ActivityType.checkIn,
      content: note?.isNotEmpty == true 
          ? 'Checked in at $venueName: $note'
          : 'Checked in at $venueName',
      createdAt: DateTime.now(),
      relatedVenueId: venueId,
      relatedGameId: gameId,
      metadata: {
        'venueName': venueName,
        'venueId': venueId,
        if (gameId != null) 'gameId': gameId,
        if (note != null) 'note': note,
      },
    );
  }

  factory ActivityFeedItem.createFriendConnection({
    required String userId,
    required String userName,
    String? userProfileImage,
    required String friendId,
    required String friendName,
  }) {
    return ActivityFeedItem(
      activityId: '${userId}_friend_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      userName: userName,
      userProfileImage: userProfileImage,
      type: ActivityType.friendConnection,
      content: 'Connected with $friendName',
      createdAt: DateTime.now(),
      metadata: {
        'friendId': friendId,
        'friendName': friendName,
      },
    );
  }

  factory ActivityFeedItem.createGameAttendance({
    required String userId,
    required String userName,
    String? userProfileImage,
    required String gameId,
    required String gameTitle,
    required String venue,
  }) {
    return ActivityFeedItem(
      activityId: '${userId}_game_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      userName: userName,
      userProfileImage: userProfileImage,
      type: ActivityType.gameAttendance,
      content: 'Attended $gameTitle at $venue',
      createdAt: DateTime.now(),
      relatedGameId: gameId,
      metadata: {
        'gameId': gameId,
        'gameTitle': gameTitle,
        'venue': venue,
      },
    );
  }

  factory ActivityFeedItem.createVenueReview({
    required String userId,
    required String userName,
    String? userProfileImage,
    required String venueId,
    required String venueName,
    required int rating,
    required String review,
  }) {
    return ActivityFeedItem(
      activityId: '${userId}_review_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      userName: userName,
      userProfileImage: userProfileImage,
      type: ActivityType.venueReview,
      content: 'Reviewed $venueName ($rating⭐): $review',
      createdAt: DateTime.now(),
      relatedVenueId: venueId,
      metadata: {
        'venueId': venueId,
        'venueName': venueName,
        'rating': rating,
        'review': review,
      },
    );
  }

  ActivityFeedItem copyWith({
    int? likesCount,
    int? commentsCount,
    Map<String, dynamic>? metadata,
  }) {
    return ActivityFeedItem(
      activityId: activityId,
      userId: userId,
      userName: userName,
      userProfileImage: userProfileImage,
      type: type,
      content: content,
      createdAt: createdAt,
      metadata: metadata ?? this.metadata,
      mentionedUsers: mentionedUsers,
      tags: tags,
      relatedGameId: relatedGameId,
      relatedVenueId: relatedVenueId,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isPublic: isPublic,
    );
  }

  // Helper getters
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  bool get hasInteractions => likesCount > 0 || commentsCount > 0;
  
  String get displayContent {
    if (content.length <= 100) return content;
    return '${content.substring(0, 97)}...';
  }

  @override
  List<Object?> get props => [
        activityId,
        userId,
        userName,
        userProfileImage,
        type,
        content,
        createdAt,
        metadata,
        mentionedUsers,
        tags,
        relatedGameId,
        relatedVenueId,
        likesCount,
        commentsCount,
        isPublic,
      ];
}

@HiveType(typeId: 13)
enum ActivityType {
  @HiveField(0)
  checkIn,
  
  @HiveField(1)
  friendConnection,
  
  @HiveField(2)
  gameAttendance,
  
  @HiveField(3)
  venueReview,
  
  @HiveField(4)
  photoShare,
  
  @HiveField(5)
  gameComment,
  
  @HiveField(6)
  teamFollow,
  
  @HiveField(7)
  achievement,
  
  @HiveField(8)
  groupJoin,
}

// Activity comment system
@HiveType(typeId: 14)
class ActivityComment extends Equatable {
  @HiveField(0)
  final String commentId;
  
  @HiveField(1)
  final String activityId;
  
  @HiveField(2)
  final String userId;
  
  @HiveField(3)
  final String userName;
  
  @HiveField(4)
  final String? userProfileImage;
  
  @HiveField(5)
  final String comment;
  
  @HiveField(6)
  final DateTime createdAt;
  
  @HiveField(7)
  final List<String> mentionedUsers;

  const ActivityComment({
    required this.commentId,
    required this.activityId,
    required this.userId,
    required this.userName,
    this.userProfileImage,
    required this.comment,
    required this.createdAt,
    this.mentionedUsers = const [],
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  @override
  List<Object?> get props => [
        commentId,
        activityId,
        userId,
        userName,
        userProfileImage,
        comment,
        createdAt,
        mentionedUsers,
      ];
}

// Activity like tracking
@HiveType(typeId: 15)
class ActivityLike extends Equatable {
  @HiveField(0)
  final String likeId;
  
  @HiveField(1)
  final String activityId;
  
  @HiveField(2)
  final String userId;
  
  @HiveField(3)
  final DateTime createdAt;

  const ActivityLike({
    required this.likeId,
    required this.activityId,
    required this.userId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [likeId, activityId, userId, createdAt];
} 