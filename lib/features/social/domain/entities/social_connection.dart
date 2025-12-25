import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'social_connection.g.dart';

@HiveType(typeId: 8)
class SocialConnection extends Equatable {
  @HiveField(0)
  final String connectionId;
  
  @HiveField(1)
  final String fromUserId;
  
  @HiveField(2)
  final String toUserId;
  
  @HiveField(3)
  final ConnectionType type;
  
  @HiveField(4)
  final ConnectionStatus status;
  
  @HiveField(5)
  final DateTime createdAt;
  
  @HiveField(6)
  final DateTime? acceptedAt;
  
  @HiveField(7)
  final String? connectionSource; // how they connected
  
  @HiveField(8)
  final Map<String, dynamic> metadata;

  const SocialConnection({
    required this.connectionId,
    required this.fromUserId,
    required this.toUserId,
    required this.type,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.connectionSource,
    this.metadata = const {},
  });

  factory SocialConnection.createFriendRequest({
    required String fromUserId,
    required String toUserId,
    String? source,
  }) {
    return SocialConnection(
      connectionId: '${fromUserId}_${toUserId}_${DateTime.now().millisecondsSinceEpoch}',
      fromUserId: fromUserId,
      toUserId: toUserId,
      type: ConnectionType.friend,
      status: ConnectionStatus.pending,
      createdAt: DateTime.now(),
      connectionSource: source,
    );
  }

  factory SocialConnection.createFollow({
    required String fromUserId,
    required String toUserId,
    String? source,
  }) {
    return SocialConnection(
      connectionId: '${fromUserId}_${toUserId}_${DateTime.now().millisecondsSinceEpoch}',
      fromUserId: fromUserId,
      toUserId: toUserId,
      type: ConnectionType.follow,
      status: ConnectionStatus.accepted, // follows are immediate
      createdAt: DateTime.now(),
      acceptedAt: DateTime.now(),
      connectionSource: source,
    );
  }

  SocialConnection copyWith({
    ConnectionStatus? status,
    DateTime? acceptedAt,
    Map<String, dynamic>? metadata,
  }) {
    return SocialConnection(
      connectionId: connectionId,
      fromUserId: fromUserId,
      toUserId: toUserId,
      type: type,
      status: status ?? this.status,
      createdAt: createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      connectionSource: connectionSource,
      metadata: metadata ?? this.metadata,
    );
  }

  SocialConnection accept() {
    return copyWith(
      status: ConnectionStatus.accepted,
      acceptedAt: DateTime.now(),
    );
  }

  SocialConnection block() {
    return copyWith(status: ConnectionStatus.blocked);
  }

  // Helper getters
  bool get isPending => status == ConnectionStatus.pending;
  bool get isAccepted => status == ConnectionStatus.accepted;
  bool get isBlocked => status == ConnectionStatus.blocked;
  bool get isFriend => type == ConnectionType.friend && isAccepted;
  bool get isFollower => type == ConnectionType.follow && isAccepted;

  // Helper getter for connected user name (placeholder until we have user names cached)
  String? get connectedUserName => metadata['connectedUserName'];
  
  // Helper getter for time ago
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

  @override
  List<Object?> get props => [
        connectionId,
        fromUserId,
        toUserId,
        type,
        status,
        createdAt,
        acceptedAt,
        connectionSource,
        metadata,
      ];
}

@HiveType(typeId: 9)
enum ConnectionType {
  @HiveField(0)
  friend,
  
  @HiveField(1)
  follow,
  
  @HiveField(2)
  block,
}

@HiveType(typeId: 10)
enum ConnectionStatus {
  @HiveField(0)
  pending,
  
  @HiveField(1)
  accepted,
  
  @HiveField(2)
  declined,
  
  @HiveField(3)
  blocked,
}

// Friend recommendation based on mutual connections, shared teams, etc.
@HiveType(typeId: 11)
class FriendSuggestion extends Equatable {
  @HiveField(0)
  final String userId;
  
  @HiveField(1)
  final String displayName;
  
  @HiveField(2)
  final String? profileImageUrl;
  
  @HiveField(3)
  final List<String> mutualFriends;
  
  @HiveField(4)
  final List<String> sharedTeams;
  
  @HiveField(5)
  final String? connectionReason;
  
  @HiveField(6)
  final double relevanceScore;
  
  @HiveField(7)
  final DateTime suggestedAt;

  const FriendSuggestion({
    required this.userId,
    required this.displayName,
    this.profileImageUrl,
    this.mutualFriends = const [],
    this.sharedTeams = const [],
    this.connectionReason,
    required this.relevanceScore,
    required this.suggestedAt,
  });

  String get suggestionText {
    if (mutualFriends.isNotEmpty) {
      final count = mutualFriends.length;
      return '$count mutual friend${count > 1 ? 's' : ''}';
    }
    if (sharedTeams.isNotEmpty) {
      return 'Fan of ${sharedTeams.first}';
    }
    return connectionReason ?? 'Suggested for you';
  }

  @override
  List<Object?> get props => [
        userId,
        displayName,
        profileImageUrl,
        mutualFriends,
        sharedTeams,
        connectionReason,
        relevanceScore,
        suggestedAt,
      ];
}

// Enhanced connection analytics
class ConnectionAnalytics {
  final int totalConnections;
  final int friendsCount;
  final int followersCount;
  final int followingCount;
  final int pendingRequestsCount;
  final int mutualFriendsCount;
  final List<String> topMutualConnections;
  final DateTime lastConnectionActivity;

  const ConnectionAnalytics({
    required this.totalConnections,
    required this.friendsCount,
    required this.followersCount,
    required this.followingCount,
    required this.pendingRequestsCount,
    required this.mutualFriendsCount,
    required this.topMutualConnections,
    required this.lastConnectionActivity,
  });

  double get engagementScore {
    if (totalConnections == 0) return 0.0;
    return (friendsCount + (followersCount * 0.5)) / totalConnections;
  }

  bool get isInfluencer => followersCount > friendsCount * 2;
  bool get isActiveConnector => pendingRequestsCount > 0 || 
      DateTime.now().difference(lastConnectionActivity).inDays < 7;
} 