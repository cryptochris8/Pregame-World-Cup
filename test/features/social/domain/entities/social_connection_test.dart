import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/social/domain/entities/social_connection.dart';

void main() {
  group('SocialConnection', () {
    group('Constructor', () {
      test('creates connection with required fields', () {
        final now = DateTime.now();
        final connection = SocialConnection(
          connectionId: 'conn_1',
          fromUserId: 'user_1',
          toUserId: 'user_2',
          type: ConnectionType.friend,
          status: ConnectionStatus.pending,
          createdAt: now,
        );

        expect(connection.connectionId, equals('conn_1'));
        expect(connection.fromUserId, equals('user_1'));
        expect(connection.toUserId, equals('user_2'));
        expect(connection.type, equals(ConnectionType.friend));
        expect(connection.status, equals(ConnectionStatus.pending));
        expect(connection.createdAt, equals(now));
        expect(connection.metadata, isEmpty);
      });

      test('creates connection with optional fields', () {
        final now = DateTime.now();
        final connection = SocialConnection(
          connectionId: 'conn_1',
          fromUserId: 'user_1',
          toUserId: 'user_2',
          type: ConnectionType.friend,
          status: ConnectionStatus.accepted,
          createdAt: now,
          acceptedAt: now,
          connectionSource: 'mutual_friend',
          metadata: const {'connectedUserName': 'John Doe'},
        );

        expect(connection.acceptedAt, equals(now));
        expect(connection.connectionSource, equals('mutual_friend'));
        expect(connection.metadata['connectedUserName'], equals('John Doe'));
      });
    });

    group('Factory constructors', () {
      test('createFriendRequest creates pending friend request', () {
        final connection = SocialConnection.createFriendRequest(
          fromUserId: 'user_1',
          toUserId: 'user_2',
          source: 'search',
        );

        expect(connection.connectionId, contains('user_1_user_2'));
        expect(connection.type, equals(ConnectionType.friend));
        expect(connection.status, equals(ConnectionStatus.pending));
        expect(connection.connectionSource, equals('search'));
        expect(connection.acceptedAt, isNull);
      });

      test('createFollow creates immediately accepted follow', () {
        final connection = SocialConnection.createFollow(
          fromUserId: 'user_1',
          toUserId: 'user_2',
          source: 'profile',
        );

        expect(connection.connectionId, contains('user_1_user_2'));
        expect(connection.type, equals(ConnectionType.follow));
        expect(connection.status, equals(ConnectionStatus.accepted));
        expect(connection.acceptedAt, isNotNull);
        expect(connection.connectionSource, equals('profile'));
      });
    });

    group('copyWith', () {
      test('copies connection with new status', () {
        final now = DateTime.now();
        final connection = SocialConnection(
          connectionId: 'conn_1',
          fromUserId: 'user_1',
          toUserId: 'user_2',
          type: ConnectionType.friend,
          status: ConnectionStatus.pending,
          createdAt: now,
        );

        final updated = connection.copyWith(status: ConnectionStatus.accepted);

        expect(updated.status, equals(ConnectionStatus.accepted));
        expect(updated.connectionId, equals(connection.connectionId));
        expect(updated.type, equals(connection.type));
      });

      test('copies connection with multiple changes', () {
        final now = DateTime.now();
        final connection = SocialConnection(
          connectionId: 'conn_1',
          fromUserId: 'user_1',
          toUserId: 'user_2',
          type: ConnectionType.friend,
          status: ConnectionStatus.pending,
          createdAt: now,
        );

        final updated = connection.copyWith(
          status: ConnectionStatus.accepted,
          acceptedAt: now,
          metadata: {'note': 'accepted via notification'},
        );

        expect(updated.status, equals(ConnectionStatus.accepted));
        expect(updated.acceptedAt, equals(now));
        expect(updated.metadata['note'], equals('accepted via notification'));
      });
    });

    group('accept', () {
      test('changes status to accepted and sets acceptedAt', () {
        final connection = SocialConnection.createFriendRequest(
          fromUserId: 'user_1',
          toUserId: 'user_2',
        );

        final accepted = connection.accept();

        expect(accepted.status, equals(ConnectionStatus.accepted));
        expect(accepted.acceptedAt, isNotNull);
        expect(accepted.isAccepted, isTrue);
      });
    });

    group('block', () {
      test('changes status to blocked', () {
        final connection = SocialConnection.createFriendRequest(
          fromUserId: 'user_1',
          toUserId: 'user_2',
        );

        final blocked = connection.block();

        expect(blocked.status, equals(ConnectionStatus.blocked));
        expect(blocked.isBlocked, isTrue);
      });
    });

    group('Helper getters', () {
      test('isPending returns true for pending status', () {
        final connection = SocialConnection.createFriendRequest(
          fromUserId: 'user_1',
          toUserId: 'user_2',
        );

        expect(connection.isPending, isTrue);
        expect(connection.isAccepted, isFalse);
        expect(connection.isBlocked, isFalse);
      });

      test('isAccepted returns true for accepted status', () {
        final connection = SocialConnection.createFollow(
          fromUserId: 'user_1',
          toUserId: 'user_2',
        );

        expect(connection.isAccepted, isTrue);
        expect(connection.isPending, isFalse);
      });

      test('isFriend returns true for accepted friend connections', () {
        final accepted = SocialConnection.createFriendRequest(
          fromUserId: 'user_1',
          toUserId: 'user_2',
        ).accept();

        expect(accepted.isFriend, isTrue);
        expect(accepted.isFollower, isFalse);
      });

      test('isFollower returns true for accepted follow connections', () {
        final follow = SocialConnection.createFollow(
          fromUserId: 'user_1',
          toUserId: 'user_2',
        );

        expect(follow.isFollower, isTrue);
        expect(follow.isFriend, isFalse);
      });

      test('isFriend returns false for pending friend requests', () {
        final pending = SocialConnection.createFriendRequest(
          fromUserId: 'user_1',
          toUserId: 'user_2',
        );

        expect(pending.isFriend, isFalse);
      });

      test('connectedUserName returns name from metadata', () {
        final now = DateTime.now();
        final connection = SocialConnection(
          connectionId: 'conn_1',
          fromUserId: 'user_1',
          toUserId: 'user_2',
          type: ConnectionType.friend,
          status: ConnectionStatus.accepted,
          createdAt: now,
          metadata: const {'connectedUserName': 'Jane Smith'},
        );

        expect(connection.connectedUserName, equals('Jane Smith'));
      });

      test('connectedUserName returns null when not in metadata', () {
        final connection = SocialConnection.createFriendRequest(
          fromUserId: 'user_1',
          toUserId: 'user_2',
        );

        expect(connection.connectedUserName, isNull);
      });
    });

    group('timeAgo', () {
      test('returns "Just now" for recent connections', () {
        final connection = SocialConnection.createFriendRequest(
          fromUserId: 'user_1',
          toUserId: 'user_2',
        );

        expect(connection.timeAgo, equals('Just now'));
      });

      test('returns minutes ago for connections within an hour', () {
        final now = DateTime.now();
        final connection = SocialConnection(
          connectionId: 'conn_1',
          fromUserId: 'user_1',
          toUserId: 'user_2',
          type: ConnectionType.friend,
          status: ConnectionStatus.pending,
          createdAt: now.subtract(const Duration(minutes: 30)),
        );

        expect(connection.timeAgo, equals('30m ago'));
      });

      test('returns hours ago for connections within a day', () {
        final now = DateTime.now();
        final connection = SocialConnection(
          connectionId: 'conn_1',
          fromUserId: 'user_1',
          toUserId: 'user_2',
          type: ConnectionType.friend,
          status: ConnectionStatus.pending,
          createdAt: now.subtract(const Duration(hours: 5)),
        );

        expect(connection.timeAgo, equals('5h ago'));
      });

      test('returns days ago for older connections', () {
        final now = DateTime.now();
        final connection = SocialConnection(
          connectionId: 'conn_1',
          fromUserId: 'user_1',
          toUserId: 'user_2',
          type: ConnectionType.friend,
          status: ConnectionStatus.pending,
          createdAt: now.subtract(const Duration(days: 3)),
        );

        expect(connection.timeAgo, equals('3d ago'));
      });
    });

    group('Equatable', () {
      test('two connections with same props are equal', () {
        final now = DateTime(2024, 1, 15, 12, 0, 0);
        final conn1 = SocialConnection(
          connectionId: 'conn_1',
          fromUserId: 'user_1',
          toUserId: 'user_2',
          type: ConnectionType.friend,
          status: ConnectionStatus.pending,
          createdAt: now,
        );

        final conn2 = SocialConnection(
          connectionId: 'conn_1',
          fromUserId: 'user_1',
          toUserId: 'user_2',
          type: ConnectionType.friend,
          status: ConnectionStatus.pending,
          createdAt: now,
        );

        expect(conn1, equals(conn2));
      });

      test('two connections with different props are not equal', () {
        final now = DateTime.now();
        final conn1 = SocialConnection(
          connectionId: 'conn_1',
          fromUserId: 'user_1',
          toUserId: 'user_2',
          type: ConnectionType.friend,
          status: ConnectionStatus.pending,
          createdAt: now,
        );

        final conn2 = SocialConnection(
          connectionId: 'conn_2',
          fromUserId: 'user_1',
          toUserId: 'user_2',
          type: ConnectionType.friend,
          status: ConnectionStatus.pending,
          createdAt: now,
        );

        expect(conn1, isNot(equals(conn2)));
      });
    });
  });

  group('ConnectionType', () {
    test('contains all expected types', () {
      expect(ConnectionType.values, contains(ConnectionType.friend));
      expect(ConnectionType.values, contains(ConnectionType.follow));
      expect(ConnectionType.values, contains(ConnectionType.block));
    });
  });

  group('ConnectionStatus', () {
    test('contains all expected statuses', () {
      expect(ConnectionStatus.values, contains(ConnectionStatus.pending));
      expect(ConnectionStatus.values, contains(ConnectionStatus.accepted));
      expect(ConnectionStatus.values, contains(ConnectionStatus.declined));
      expect(ConnectionStatus.values, contains(ConnectionStatus.blocked));
    });
  });

  group('FriendSuggestion', () {
    test('creates suggestion with required fields', () {
      final now = DateTime.now();
      final suggestion = FriendSuggestion(
        userId: 'user_1',
        displayName: 'John Doe',
        relevanceScore: 0.85,
        suggestedAt: now,
      );

      expect(suggestion.userId, equals('user_1'));
      expect(suggestion.displayName, equals('John Doe'));
      expect(suggestion.relevanceScore, equals(0.85));
      expect(suggestion.mutualFriends, isEmpty);
      expect(suggestion.sharedTeams, isEmpty);
    });

    test('creates suggestion with optional fields', () {
      final now = DateTime.now();
      final suggestion = FriendSuggestion(
        userId: 'user_1',
        displayName: 'John Doe',
        profileImageUrl: 'https://example.com/avatar.jpg',
        mutualFriends: const ['user_2', 'user_3'],
        sharedTeams: const ['Georgia'],
        connectionReason: 'You both like Georgia',
        relevanceScore: 0.95,
        suggestedAt: now,
      );

      expect(suggestion.profileImageUrl, equals('https://example.com/avatar.jpg'));
      expect(suggestion.mutualFriends, hasLength(2));
      expect(suggestion.sharedTeams, contains('Georgia'));
      expect(suggestion.connectionReason, equals('You both like Georgia'));
    });

    group('suggestionText', () {
      test('returns mutual friends count when available', () {
        final suggestion = FriendSuggestion(
          userId: 'user_1',
          displayName: 'John Doe',
          mutualFriends: const ['user_2', 'user_3', 'user_4'],
          relevanceScore: 0.8,
          suggestedAt: DateTime.now(),
        );

        expect(suggestion.suggestionText, equals('3 mutual friends'));
      });

      test('returns singular for one mutual friend', () {
        final suggestion = FriendSuggestion(
          userId: 'user_1',
          displayName: 'John Doe',
          mutualFriends: const ['user_2'],
          relevanceScore: 0.8,
          suggestedAt: DateTime.now(),
        );

        expect(suggestion.suggestionText, equals('1 mutual friend'));
      });

      test('returns shared team when no mutual friends', () {
        final suggestion = FriendSuggestion(
          userId: 'user_1',
          displayName: 'John Doe',
          sharedTeams: const ['Alabama', 'Georgia'],
          relevanceScore: 0.7,
          suggestedAt: DateTime.now(),
        );

        expect(suggestion.suggestionText, equals('Fan of Alabama'));
      });

      test('returns connection reason when no mutual friends or teams', () {
        final suggestion = FriendSuggestion(
          userId: 'user_1',
          displayName: 'John Doe',
          connectionReason: 'Nearby user',
          relevanceScore: 0.5,
          suggestedAt: DateTime.now(),
        );

        expect(suggestion.suggestionText, equals('Nearby user'));
      });

      test('returns default when no connection data', () {
        final suggestion = FriendSuggestion(
          userId: 'user_1',
          displayName: 'John Doe',
          relevanceScore: 0.3,
          suggestedAt: DateTime.now(),
        );

        expect(suggestion.suggestionText, equals('Suggested for you'));
      });
    });

    group('Equatable', () {
      test('two suggestions with same props are equal', () {
        final now = DateTime(2024, 1, 15, 12, 0, 0);
        final sugg1 = FriendSuggestion(
          userId: 'user_1',
          displayName: 'John Doe',
          relevanceScore: 0.8,
          suggestedAt: now,
        );

        final sugg2 = FriendSuggestion(
          userId: 'user_1',
          displayName: 'John Doe',
          relevanceScore: 0.8,
          suggestedAt: now,
        );

        expect(sugg1, equals(sugg2));
      });
    });
  });

  group('ConnectionAnalytics', () {
    test('creates analytics with required fields', () {
      final now = DateTime.now();
      final analytics = ConnectionAnalytics(
        totalConnections: 100,
        friendsCount: 50,
        followersCount: 30,
        followingCount: 20,
        pendingRequestsCount: 5,
        mutualFriendsCount: 15,
        topMutualConnections: ['user_1', 'user_2'],
        lastConnectionActivity: now,
      );

      expect(analytics.totalConnections, equals(100));
      expect(analytics.friendsCount, equals(50));
      expect(analytics.followersCount, equals(30));
      expect(analytics.followingCount, equals(20));
      expect(analytics.pendingRequestsCount, equals(5));
    });

    group('engagementScore', () {
      test('returns 0 when no connections', () {
        final analytics = ConnectionAnalytics(
          totalConnections: 0,
          friendsCount: 0,
          followersCount: 0,
          followingCount: 0,
          pendingRequestsCount: 0,
          mutualFriendsCount: 0,
          topMutualConnections: [],
          lastConnectionActivity: DateTime.now(),
        );

        expect(analytics.engagementScore, equals(0.0));
      });

      test('calculates engagement score correctly', () {
        final analytics = ConnectionAnalytics(
          totalConnections: 100,
          friendsCount: 50,
          followersCount: 30,
          followingCount: 20,
          pendingRequestsCount: 0,
          mutualFriendsCount: 10,
          topMutualConnections: [],
          lastConnectionActivity: DateTime.now(),
        );

        // (50 + (30 * 0.5)) / 100 = 65 / 100 = 0.65
        expect(analytics.engagementScore, equals(0.65));
      });
    });

    group('isInfluencer', () {
      test('returns true when followers exceed twice friends count', () {
        final analytics = ConnectionAnalytics(
          totalConnections: 150,
          friendsCount: 20,
          followersCount: 100,
          followingCount: 30,
          pendingRequestsCount: 0,
          mutualFriendsCount: 5,
          topMutualConnections: [],
          lastConnectionActivity: DateTime.now(),
        );

        expect(analytics.isInfluencer, isTrue);
      });

      test('returns false when followers do not exceed twice friends', () {
        final analytics = ConnectionAnalytics(
          totalConnections: 100,
          friendsCount: 50,
          followersCount: 30,
          followingCount: 20,
          pendingRequestsCount: 0,
          mutualFriendsCount: 10,
          topMutualConnections: [],
          lastConnectionActivity: DateTime.now(),
        );

        expect(analytics.isInfluencer, isFalse);
      });
    });

    group('isActiveConnector', () {
      test('returns true when pending requests exist', () {
        final analytics = ConnectionAnalytics(
          totalConnections: 50,
          friendsCount: 25,
          followersCount: 15,
          followingCount: 10,
          pendingRequestsCount: 3,
          mutualFriendsCount: 5,
          topMutualConnections: [],
          lastConnectionActivity: DateTime.now().subtract(const Duration(days: 30)),
        );

        expect(analytics.isActiveConnector, isTrue);
      });

      test('returns true when recent activity within 7 days', () {
        final analytics = ConnectionAnalytics(
          totalConnections: 50,
          friendsCount: 25,
          followersCount: 15,
          followingCount: 10,
          pendingRequestsCount: 0,
          mutualFriendsCount: 5,
          topMutualConnections: [],
          lastConnectionActivity: DateTime.now().subtract(const Duration(days: 3)),
        );

        expect(analytics.isActiveConnector, isTrue);
      });

      test('returns false when no pending and no recent activity', () {
        final analytics = ConnectionAnalytics(
          totalConnections: 50,
          friendsCount: 25,
          followersCount: 15,
          followingCount: 10,
          pendingRequestsCount: 0,
          mutualFriendsCount: 5,
          topMutualConnections: [],
          lastConnectionActivity: DateTime.now().subtract(const Duration(days: 30)),
        );

        expect(analytics.isActiveConnector, isFalse);
      });
    });
  });
}
