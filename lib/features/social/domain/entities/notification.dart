import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'notification.g.dart';

@HiveType(typeId: 16)
class SocialNotification extends Equatable {
  @HiveField(0)
  final String notificationId;
  
  @HiveField(1)
  final String userId; // recipient
  
  @HiveField(2)
  final String? fromUserId; // sender
  
  @HiveField(3)
  final String? fromUserName;
  
  @HiveField(4)
  final String? fromUserImage;
  
  @HiveField(5)
  final NotificationType type;
  
  @HiveField(6)
  final String title;
  
  @HiveField(7)
  final String message;
  
  @HiveField(8)
  final DateTime createdAt;
  
  @HiveField(9)
  final bool isRead;
  
  @HiveField(10)
  final Map<String, dynamic> data;
  
  @HiveField(11)
  final String? actionUrl;
  
  @HiveField(12)
  final NotificationPriority priority;

  const SocialNotification({
    required this.notificationId,
    required this.userId,
    this.fromUserId,
    this.fromUserName,
    this.fromUserImage,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.data = const {},
    this.actionUrl,
    this.priority = NotificationPriority.normal,
  });

  factory SocialNotification.friendRequest({
    required String userId,
    required String fromUserId,
    required String fromUserName,
    String? fromUserImage,
    required String connectionId,
  }) {
    return SocialNotification(
      notificationId: 'friend_request_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      fromUserId: fromUserId,
      fromUserName: fromUserName,
      fromUserImage: fromUserImage,
      type: NotificationType.friendRequest,
      title: 'New Friend Request',
      message: '$fromUserName sent you a friend request',
      createdAt: DateTime.now(),
      data: {
        'connectionId': connectionId,
        'fromUserId': fromUserId,
      },
      actionUrl: '/profile/$fromUserId',
      priority: NotificationPriority.high,
    );
  }

  factory SocialNotification.friendRequestAccepted({
    required String userId,
    required String fromUserId,
    required String fromUserName,
    String? fromUserImage,
  }) {
    return SocialNotification(
      notificationId: 'friend_accepted_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      fromUserId: fromUserId,
      fromUserName: fromUserName,
      fromUserImage: fromUserImage,
      type: NotificationType.friendRequestAccepted,
      title: 'Friend Request Accepted',
      message: '$fromUserName accepted your friend request',
      createdAt: DateTime.now(),
      data: {
        'fromUserId': fromUserId,
      },
      actionUrl: '/profile/$fromUserId',
    );
  }

  factory SocialNotification.activityLike({
    required String userId,
    required String fromUserId,
    required String fromUserName,
    String? fromUserImage,
    required String activityId,
    required String activityContent,
  }) {
    return SocialNotification(
      notificationId: 'activity_like_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      fromUserId: fromUserId,
      fromUserName: fromUserName,
      fromUserImage: fromUserImage,
      type: NotificationType.activityLike,
      title: 'Activity Liked',
      message: '$fromUserName liked your activity',
      createdAt: DateTime.now(),
      data: {
        'activityId': activityId,
        'activityContent': activityContent,
      },
      actionUrl: '/activity/$activityId',
    );
  }

  factory SocialNotification.activityComment({
    required String userId,
    required String fromUserId,
    required String fromUserName,
    String? fromUserImage,
    required String activityId,
    required String comment,
  }) {
    return SocialNotification(
      notificationId: 'activity_comment_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      fromUserId: fromUserId,
      fromUserName: fromUserName,
      fromUserImage: fromUserImage,
      type: NotificationType.activityComment,
      title: 'New Comment',
      message: '$fromUserName commented on your activity: "$comment"',
      createdAt: DateTime.now(),
      data: {
        'activityId': activityId,
        'comment': comment,
      },
      actionUrl: '/activity/$activityId',
    );
  }

  factory SocialNotification.gameInvite({
    required String userId,
    required String fromUserId,
    required String fromUserName,
    String? fromUserImage,
    required String gameId,
    required String gameTitle,
    required DateTime gameDate,
  }) {
    return SocialNotification(
      notificationId: 'game_invite_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      fromUserId: fromUserId,
      fromUserName: fromUserName,
      fromUserImage: fromUserImage,
      type: NotificationType.gameInvite,
      title: 'Game Invitation',
      message: '$fromUserName invited you to $gameTitle',
      createdAt: DateTime.now(),
      data: {
        'gameId': gameId,
        'gameTitle': gameTitle,
        'gameDate': gameDate.toIso8601String(),
      },
      actionUrl: '/game/$gameId',
      priority: NotificationPriority.high,
    );
  }

  factory SocialNotification.watchPartyInvite({
    required String userId,
    required String fromUserId,
    required String fromUserName,
    String? fromUserImage,
    required String watchPartyId,
    required String watchPartyName,
    required String gameName,
    required DateTime gameDateTime,
    String? personalMessage,
  }) {
    return SocialNotification(
      notificationId: 'watch_party_invite_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      fromUserId: fromUserId,
      fromUserName: fromUserName,
      fromUserImage: fromUserImage,
      type: NotificationType.watchPartyInvite,
      title: 'Watch Party Invitation',
      message: personalMessage != null && personalMessage.isNotEmpty
          ? '$fromUserName invited you to "$watchPartyName": $personalMessage'
          : '$fromUserName invited you to watch $gameName together',
      createdAt: DateTime.now(),
      data: {
        'watchPartyId': watchPartyId,
        'watchPartyName': watchPartyName,
        'gameName': gameName,
        'gameDateTime': gameDateTime.toIso8601String(),
      },
      actionUrl: '/watch-party/$watchPartyId',
      priority: NotificationPriority.high,
    );
  }

  factory SocialNotification.matchReminder({
    required String userId,
    required String matchId,
    required String matchName,
    required DateTime matchDateTime,
    required String timingDisplay,
    String? homeTeamCode,
    String? awayTeamCode,
    String? venueName,
  }) {
    return SocialNotification(
      notificationId: 'match_reminder_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: NotificationType.matchReminder,
      title: 'Match Starting Soon',
      message: '$matchName kicks off in $timingDisplay${venueName != null ? ' at $venueName' : ''}',
      createdAt: DateTime.now(),
      data: {
        'matchId': matchId,
        'matchName': matchName,
        'matchDateTime': matchDateTime.toIso8601String(),
        'homeTeamCode': homeTeamCode,
        'awayTeamCode': awayTeamCode,
        'venueName': venueName,
      },
      actionUrl: '/match/$matchId',
      priority: NotificationPriority.high,
    );
  }

  SocialNotification copyWith({
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return SocialNotification(
      notificationId: notificationId,
      userId: userId,
      fromUserId: fromUserId,
      fromUserName: fromUserName,
      fromUserImage: fromUserImage,
      type: type,
      title: title,
      message: message,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      actionUrl: actionUrl,
      priority: priority,
    );
  }

  SocialNotification markAsRead() => copyWith(isRead: true);

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

  bool get isRecent => DateTime.now().difference(createdAt).inHours < 24;
  bool get isActionable => type == NotificationType.friendRequest || 
                           type == NotificationType.gameInvite;

  @override
  List<Object?> get props => [
        notificationId,
        userId,
        fromUserId,
        fromUserName,
        fromUserImage,
        type,
        title,
        message,
        createdAt,
        isRead,
        data,
        actionUrl,
        priority,
      ];
}

@HiveType(typeId: 17)
enum NotificationType {
  @HiveField(0)
  friendRequest,

  @HiveField(1)
  friendRequestAccepted,

  @HiveField(2)
  activityLike,

  @HiveField(3)
  activityComment,

  @HiveField(4)
  gameInvite,

  @HiveField(5)
  venueRecommendation,

  @HiveField(6)
  newFollower,

  @HiveField(7)
  groupInvite,

  @HiveField(8)
  achievement,

  @HiveField(9)
  systemUpdate,

  @HiveField(10)
  watchPartyInvite,

  @HiveField(11)
  matchReminder,
}

@HiveType(typeId: 18)
enum NotificationPriority {
  @HiveField(0)
  low,
  
  @HiveField(1)
  normal,
  
  @HiveField(2)
  high,
  
  @HiveField(3)
  urgent,
}

// Notification preferences
@HiveType(typeId: 19)
class NotificationPreferences extends Equatable {
  @HiveField(0)
  final bool friendRequests;
  
  @HiveField(1)
  final bool activityLikes;
  
  @HiveField(2)
  final bool activityComments;
  
  @HiveField(3)
  final bool gameInvites;
  
  @HiveField(4)
  final bool venueRecommendations;
  
  @HiveField(5)
  final bool newFollowers;
  
  @HiveField(6)
  final bool groupActivity;
  
  @HiveField(7)
  final bool achievements;
  
  @HiveField(8)
  final bool systemUpdates;
  
  @HiveField(9)
  final bool pushNotifications;
  
  @HiveField(10)
  final bool emailNotifications;
  
  @HiveField(11)
  final String quietHoursStart; // "22:00"
  
  @HiveField(12)
  final String quietHoursEnd; // "08:00"

  const NotificationPreferences({
    this.friendRequests = true,
    this.activityLikes = true,
    this.activityComments = true,
    this.gameInvites = true,
    this.venueRecommendations = true,
    this.newFollowers = true,
    this.groupActivity = true,
    this.achievements = true,
    this.systemUpdates = true,
    this.pushNotifications = true,
    this.emailNotifications = false,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '08:00',
  });

  factory NotificationPreferences.defaultPreferences() {
    return const NotificationPreferences();
  }

  NotificationPreferences copyWith({
    bool? friendRequests,
    bool? activityLikes,
    bool? activityComments,
    bool? gameInvites,
    bool? venueRecommendations,
    bool? newFollowers,
    bool? groupActivity,
    bool? achievements,
    bool? systemUpdates,
    bool? pushNotifications,
    bool? emailNotifications,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) {
    return NotificationPreferences(
      friendRequests: friendRequests ?? this.friendRequests,
      activityLikes: activityLikes ?? this.activityLikes,
      activityComments: activityComments ?? this.activityComments,
      gameInvites: gameInvites ?? this.gameInvites,
      venueRecommendations: venueRecommendations ?? this.venueRecommendations,
      newFollowers: newFollowers ?? this.newFollowers,
      groupActivity: groupActivity ?? this.groupActivity,
      achievements: achievements ?? this.achievements,
      systemUpdates: systemUpdates ?? this.systemUpdates,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }

  bool shouldNotifyForType(NotificationType type) {
    switch (type) {
      case NotificationType.friendRequest:
        return friendRequests;
      case NotificationType.friendRequestAccepted:
        return friendRequests;
      case NotificationType.activityLike:
        return activityLikes;
      case NotificationType.activityComment:
        return activityComments;
      case NotificationType.gameInvite:
        return gameInvites;
      case NotificationType.venueRecommendation:
        return venueRecommendations;
      case NotificationType.newFollower:
        return newFollowers;
      case NotificationType.groupInvite:
        return groupActivity;
      case NotificationType.achievement:
        return achievements;
      case NotificationType.systemUpdate:
        return systemUpdates;
      case NotificationType.watchPartyInvite:
        return gameInvites; // Use gameInvites preference for watch party invites
      case NotificationType.matchReminder:
        return gameInvites; // Use gameInvites preference for match reminders
    }
  }

  bool get isInQuietHours {
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    // Simple time comparison - could be enhanced for cross-midnight ranges
    return currentTime.compareTo(quietHoursStart) >= 0 && 
           currentTime.compareTo(quietHoursEnd) <= 0;
  }

  @override
  List<Object?> get props => [
        friendRequests,
        activityLikes,
        activityComments,
        gameInvites,
        venueRecommendations,
        newFollowers,
        groupActivity,
        achievements,
        systemUpdates,
        pushNotifications,
        emailNotifications,
        quietHoursStart,
        quietHoursEnd,
      ];
} 