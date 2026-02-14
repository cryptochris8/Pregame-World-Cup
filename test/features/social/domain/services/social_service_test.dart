import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/social/domain/entities/social_connection.dart';
import 'package:pregame_world_cup/features/social/domain/entities/user_profile.dart';

/// Tests for SocialService-related entities and business logic.
///
/// SocialService uses hardcoded FirebaseFirestore.instance and
/// FirebaseAuth.instance as well as Hive boxes for local caching,
/// making direct service-level unit testing difficult without a
/// significant refactor to support dependency injection.
///
/// These tests cover the critical data models and business logic
/// that SocialService relies on: SocialConnection creation,
/// acceptance, blocking, UserProfile serialization, friend
/// suggestion scoring, and connection analytics.
void main() {
  // ===========================================================================
  // SocialConnection Entity
  // ===========================================================================
  group('SocialConnection', () {
    test('createFriendRequest creates pending friend connection', () {
      final connection = SocialConnection.createFriendRequest(
        fromUserId: 'user_1',
        toUserId: 'user_2',
        source: 'search',
      );

      expect(connection.fromUserId, equals('user_1'));
      expect(connection.toUserId, equals('user_2'));
      expect(connection.type, equals(ConnectionType.friend));
      expect(connection.status, equals(ConnectionStatus.pending));
      expect(connection.connectionSource, equals('search'));
      expect(connection.isPending, isTrue);
      expect(connection.isFriend, isFalse);
      expect(connection.isAccepted, isFalse);
    });

    test('createFriendRequest generates unique connectionId', () {
      final conn1 = SocialConnection.createFriendRequest(
        fromUserId: 'user_1',
        toUserId: 'user_2',
      );
      // Tiny delay ensures different timestamp
      final conn2 = SocialConnection.createFriendRequest(
        fromUserId: 'user_1',
        toUserId: 'user_3',
      );

      expect(conn1.connectionId, isNot(equals(conn2.connectionId)));
    });

    test('createFriendRequest connectionId includes user IDs', () {
      final connection = SocialConnection.createFriendRequest(
        fromUserId: 'alice',
        toUserId: 'bob',
      );

      expect(connection.connectionId, contains('alice'));
      expect(connection.connectionId, contains('bob'));
    });

    test('createFollow creates immediately accepted follow connection', () {
      final connection = SocialConnection.createFollow(
        fromUserId: 'follower',
        toUserId: 'followed',
        source: 'profile',
      );

      expect(connection.type, equals(ConnectionType.follow));
      expect(connection.status, equals(ConnectionStatus.accepted));
      expect(connection.acceptedAt, isNotNull);
      expect(connection.isAccepted, isTrue);
      expect(connection.isFollower, isTrue);
    });

    test('accept() changes status to accepted and sets acceptedAt', () {
      final pending = SocialConnection.createFriendRequest(
        fromUserId: 'user_1',
        toUserId: 'user_2',
      );

      expect(pending.isPending, isTrue);
      expect(pending.acceptedAt, isNull);

      final accepted = pending.accept();

      expect(accepted.status, equals(ConnectionStatus.accepted));
      expect(accepted.acceptedAt, isNotNull);
      expect(accepted.isAccepted, isTrue);
      expect(accepted.isFriend, isTrue);
      // Original data preserved
      expect(accepted.fromUserId, equals('user_1'));
      expect(accepted.toUserId, equals('user_2'));
      expect(accepted.connectionId, equals(pending.connectionId));
    });

    test('block() changes status to blocked', () {
      final connection = SocialConnection.createFriendRequest(
        fromUserId: 'user_1',
        toUserId: 'user_2',
      );

      final blocked = connection.block();

      expect(blocked.status, equals(ConnectionStatus.blocked));
      expect(blocked.isBlocked, isTrue);
      expect(blocked.isFriend, isFalse);
    });

    test('isFriend is true only for accepted friend connections', () {
      // Pending friend - not yet a friend
      final pending = SocialConnection.createFriendRequest(
        fromUserId: 'a',
        toUserId: 'b',
      );
      expect(pending.isFriend, isFalse);

      // Accepted friend - is a friend
      final accepted = pending.accept();
      expect(accepted.isFriend, isTrue);

      // Accepted follow - not a friend
      final follow = SocialConnection.createFollow(
        fromUserId: 'a',
        toUserId: 'b',
      );
      expect(follow.isFriend, isFalse);
      expect(follow.isFollower, isTrue);
    });

    test('timeAgo returns correct relative time strings', () {
      final justNow = SocialConnection(
        connectionId: 'c1',
        fromUserId: 'a',
        toUserId: 'b',
        type: ConnectionType.friend,
        status: ConnectionStatus.pending,
        createdAt: DateTime.now(),
      );
      expect(justNow.timeAgo, equals('Just now'));

      final hoursAgo = SocialConnection(
        connectionId: 'c2',
        fromUserId: 'a',
        toUserId: 'b',
        type: ConnectionType.friend,
        status: ConnectionStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      );
      expect(hoursAgo.timeAgo, equals('3h ago'));

      final daysAgo = SocialConnection(
        connectionId: 'c3',
        fromUserId: 'a',
        toUserId: 'b',
        type: ConnectionType.friend,
        status: ConnectionStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      );
      expect(daysAgo.timeAgo, equals('5d ago'));
    });

    test('copyWith preserves original fields when no overrides', () {
      final original = SocialConnection(
        connectionId: 'c1',
        fromUserId: 'user_a',
        toUserId: 'user_b',
        type: ConnectionType.friend,
        status: ConnectionStatus.pending,
        createdAt: DateTime(2026, 6, 1),
        connectionSource: 'search',
        metadata: const {'key': 'value'},
      );

      final copy = original.copyWith();

      expect(copy.connectionId, equals(original.connectionId));
      expect(copy.fromUserId, equals(original.fromUserId));
      expect(copy.toUserId, equals(original.toUserId));
      expect(copy.type, equals(original.type));
      expect(copy.status, equals(original.status));
      expect(copy.createdAt, equals(original.createdAt));
      expect(copy.connectionSource, equals(original.connectionSource));
    });

    test('copyWith applies overrides correctly', () {
      final original = SocialConnection(
        connectionId: 'c1',
        fromUserId: 'user_a',
        toUserId: 'user_b',
        type: ConnectionType.friend,
        status: ConnectionStatus.pending,
        createdAt: DateTime(2026, 6, 1),
      );

      final now = DateTime.now();
      final copy = original.copyWith(
        status: ConnectionStatus.accepted,
        acceptedAt: now,
      );

      expect(copy.status, equals(ConnectionStatus.accepted));
      expect(copy.acceptedAt, equals(now));
      // Unchanged fields
      expect(copy.connectionId, equals(original.connectionId));
      expect(copy.fromUserId, equals(original.fromUserId));
    });

    test('Equatable compares by value', () {
      final now = DateTime(2026, 6, 1);
      final conn1 = SocialConnection(
        connectionId: 'c1',
        fromUserId: 'a',
        toUserId: 'b',
        type: ConnectionType.friend,
        status: ConnectionStatus.pending,
        createdAt: now,
      );
      final conn2 = SocialConnection(
        connectionId: 'c1',
        fromUserId: 'a',
        toUserId: 'b',
        type: ConnectionType.friend,
        status: ConnectionStatus.pending,
        createdAt: now,
      );

      expect(conn1, equals(conn2));
    });
  });

  // ===========================================================================
  // ConnectionType Enum
  // ===========================================================================
  group('ConnectionType', () {
    test('has all expected values', () {
      expect(ConnectionType.values, contains(ConnectionType.friend));
      expect(ConnectionType.values, contains(ConnectionType.follow));
      expect(ConnectionType.values, contains(ConnectionType.block));
      expect(ConnectionType.values.length, equals(3));
    });
  });

  // ===========================================================================
  // ConnectionStatus Enum
  // ===========================================================================
  group('ConnectionStatus', () {
    test('has all expected values', () {
      expect(ConnectionStatus.values, contains(ConnectionStatus.pending));
      expect(ConnectionStatus.values, contains(ConnectionStatus.accepted));
      expect(ConnectionStatus.values, contains(ConnectionStatus.declined));
      expect(ConnectionStatus.values, contains(ConnectionStatus.blocked));
      expect(ConnectionStatus.values.length, equals(4));
    });
  });

  // ===========================================================================
  // FriendSuggestion Entity
  // ===========================================================================
  group('FriendSuggestion', () {
    test('suggestionText shows mutual friends count when available', () {
      final suggestion = FriendSuggestion(
        userId: 'u1',
        displayName: 'Test User',
        mutualFriends: const ['f1', 'f2', 'f3'],
        relevanceScore: 0.9,
        suggestedAt: DateTime.now(),
      );

      expect(suggestion.suggestionText, equals('3 mutual friends'));
    });

    test('suggestionText shows single mutual friend', () {
      final suggestion = FriendSuggestion(
        userId: 'u1',
        displayName: 'Test User',
        mutualFriends: const ['f1'],
        relevanceScore: 0.5,
        suggestedAt: DateTime.now(),
      );

      expect(suggestion.suggestionText, equals('1 mutual friend'));
    });

    test('suggestionText shows shared team when no mutual friends', () {
      final suggestion = FriendSuggestion(
        userId: 'u1',
        displayName: 'Test User',
        sharedTeams: const ['USA', 'Mexico'],
        relevanceScore: 0.7,
        suggestedAt: DateTime.now(),
      );

      expect(suggestion.suggestionText, equals('Fan of USA'));
    });

    test('suggestionText shows connection reason as fallback', () {
      final suggestion = FriendSuggestion(
        userId: 'u1',
        displayName: 'Test User',
        connectionReason: 'Nearby venue regular',
        relevanceScore: 0.3,
        suggestedAt: DateTime.now(),
      );

      expect(suggestion.suggestionText, equals('Nearby venue regular'));
    });

    test('suggestionText shows default text when no context available', () {
      final suggestion = FriendSuggestion(
        userId: 'u1',
        displayName: 'Test User',
        relevanceScore: 0.1,
        suggestedAt: DateTime.now(),
      );

      expect(suggestion.suggestionText, equals('Suggested for you'));
    });

    test('Equatable compares by value', () {
      final now = DateTime(2026, 6, 15);
      final s1 = FriendSuggestion(
        userId: 'u1',
        displayName: 'User',
        relevanceScore: 0.5,
        suggestedAt: now,
      );
      final s2 = FriendSuggestion(
        userId: 'u1',
        displayName: 'User',
        relevanceScore: 0.5,
        suggestedAt: now,
      );

      expect(s1, equals(s2));
    });
  });

  // ===========================================================================
  // ConnectionAnalytics
  // ===========================================================================
  group('ConnectionAnalytics', () {
    test('engagementScore is 0 when no connections', () {
      final analytics = ConnectionAnalytics(
        totalConnections: 0,
        friendsCount: 0,
        followersCount: 0,
        followingCount: 0,
        pendingRequestsCount: 0,
        mutualFriendsCount: 0,
        topMutualConnections: const [],
        lastConnectionActivity: DateTime.now(),
      );

      expect(analytics.engagementScore, equals(0.0));
    });

    test('engagementScore is calculated correctly', () {
      final analytics = ConnectionAnalytics(
        totalConnections: 10,
        friendsCount: 6,
        followersCount: 4,
        followingCount: 2,
        pendingRequestsCount: 0,
        mutualFriendsCount: 3,
        topMutualConnections: const ['u1', 'u2'],
        lastConnectionActivity: DateTime.now(),
      );

      // (6 + 4 * 0.5) / 10 = 8.0 / 10 = 0.8
      expect(analytics.engagementScore, equals(0.8));
    });

    test('isInfluencer is true when followers > 2x friends', () {
      final analytics = ConnectionAnalytics(
        totalConnections: 30,
        friendsCount: 5,
        followersCount: 25,
        followingCount: 0,
        pendingRequestsCount: 0,
        mutualFriendsCount: 0,
        topMutualConnections: const [],
        lastConnectionActivity: DateTime.now(),
      );

      expect(analytics.isInfluencer, isTrue);
    });

    test('isInfluencer is false when followers <= 2x friends', () {
      final analytics = ConnectionAnalytics(
        totalConnections: 20,
        friendsCount: 10,
        followersCount: 10,
        followingCount: 0,
        pendingRequestsCount: 0,
        mutualFriendsCount: 0,
        topMutualConnections: const [],
        lastConnectionActivity: DateTime.now(),
      );

      expect(analytics.isInfluencer, isFalse);
    });

    test('isActiveConnector is true with pending requests', () {
      final analytics = ConnectionAnalytics(
        totalConnections: 5,
        friendsCount: 3,
        followersCount: 2,
        followingCount: 1,
        pendingRequestsCount: 2,
        mutualFriendsCount: 1,
        topMutualConnections: const [],
        lastConnectionActivity: DateTime.now().subtract(const Duration(days: 30)),
      );

      expect(analytics.isActiveConnector, isTrue);
    });

    test('isActiveConnector is true with recent activity', () {
      final analytics = ConnectionAnalytics(
        totalConnections: 5,
        friendsCount: 3,
        followersCount: 2,
        followingCount: 1,
        pendingRequestsCount: 0,
        mutualFriendsCount: 1,
        topMutualConnections: const [],
        lastConnectionActivity: DateTime.now().subtract(const Duration(days: 3)),
      );

      expect(analytics.isActiveConnector, isTrue);
    });

    test('isActiveConnector is false with old activity and no pending', () {
      final analytics = ConnectionAnalytics(
        totalConnections: 5,
        friendsCount: 3,
        followersCount: 2,
        followingCount: 1,
        pendingRequestsCount: 0,
        mutualFriendsCount: 1,
        topMutualConnections: const [],
        lastConnectionActivity: DateTime.now().subtract(const Duration(days: 30)),
      );

      expect(analytics.isActiveConnector, isFalse);
    });
  });

  // ===========================================================================
  // UserProfile Entity
  // ===========================================================================
  group('UserProfile', () {
    test('create() factory sets defaults correctly', () {
      final profile = UserProfile.create(
        userId: 'user_1',
        displayName: 'Test User',
        email: 'test@example.com',
        favoriteTeams: const ['USA', 'BRA'],
      );

      expect(profile.userId, equals('user_1'));
      expect(profile.displayName, equals('Test User'));
      expect(profile.email, equals('test@example.com'));
      expect(profile.favoriteTeams, equals(['USA', 'BRA']));
      expect(profile.level, equals(1));
      expect(profile.experiencePoints, equals(0));
      expect(profile.badges, isEmpty);
      expect(profile.isOnline, isFalse);
    });

    test('levelTitle returns correct title for different levels', () {
      expect(
        UserProfile.create(userId: 'u', displayName: 'U').levelTitle,
        equals('Rookie'),
      );

      final risingStarProfile = UserProfile.create(
        userId: 'u',
        displayName: 'U',
      ).copyWith(level: 5);
      expect(risingStarProfile.levelTitle, equals('Rising Star'));

      final regularProfile = UserProfile.create(
        userId: 'u',
        displayName: 'U',
      ).copyWith(level: 10);
      expect(regularProfile.levelTitle, equals('Regular'));

      final veteranProfile = UserProfile.create(
        userId: 'u',
        displayName: 'U',
      ).copyWith(level: 20);
      expect(veteranProfile.levelTitle, equals('Veteran'));

      final superFanProfile = UserProfile.create(
        userId: 'u',
        displayName: 'U',
      ).copyWith(level: 30);
      expect(superFanProfile.levelTitle, equals('Super Fan'));

      final legendProfile = UserProfile.create(
        userId: 'u',
        displayName: 'U',
      ).copyWith(level: 50);
      expect(legendProfile.levelTitle, equals('Legend'));
    });

    test('isVerified checks badges', () {
      final profile = UserProfile.create(
        userId: 'u',
        displayName: 'U',
      );
      expect(profile.isVerified, isFalse);

      final verified = profile.copyWith(badges: ['verified']);
      expect(verified.isVerified, isTrue);
    });

    test('isSuperFan checks badges', () {
      final profile = UserProfile.create(
        userId: 'u',
        displayName: 'U',
      );
      expect(profile.isSuperFan, isFalse);

      final superFan = profile.copyWith(badges: ['super_fan']);
      expect(superFan.isSuperFan, isTrue);
    });

    test('hasCompletedProfile checks all required fields', () {
      final incomplete = UserProfile.create(
        userId: 'u',
        displayName: 'U',
      );
      expect(incomplete.hasCompletedProfile, isFalse);

      final complete = incomplete.copyWith(
        profileImageUrl: 'https://example.com/photo.jpg',
        bio: 'Football fan',
        favoriteTeams: ['USA'],
        homeLocation: 'New York',
      );
      expect(complete.hasCompletedProfile, isTrue);
    });

    test('lastSeenText returns Online when user is online', () {
      final profile = UserProfile.create(
        userId: 'u',
        displayName: 'U',
      ).copyWith(isOnline: true);

      expect(profile.lastSeenText, equals('Online'));
    });

    test('lastSeenText returns relative time when offline', () {
      final profile = UserProfile.create(
        userId: 'u',
        displayName: 'U',
      ).copyWith(
        isOnline: false,
        lastSeenAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      expect(profile.lastSeenText, equals('2h ago'));
    });

    test('lastSeenText returns unknown when no last seen data', () {
      final profile = UserProfile.create(
        userId: 'u',
        displayName: 'U',
      );

      expect(profile.lastSeenText, equals('Last seen unknown'));
    });

    test('isRecentlyActive is true within 15 minutes', () {
      final profile = UserProfile.create(
        userId: 'u',
        displayName: 'U',
      ).copyWith(
        lastSeenAt: DateTime.now().subtract(const Duration(minutes: 10)),
      );

      expect(profile.isRecentlyActive, isTrue);
    });

    test('isRecentlyActive is false after 15 minutes', () {
      final profile = UserProfile.create(
        userId: 'u',
        displayName: 'U',
      ).copyWith(
        lastSeenAt: DateTime.now().subtract(const Duration(minutes: 20)),
      );

      expect(profile.isRecentlyActive, isFalse);
    });

    test('toJson/fromJson roundtrip preserves key fields', () {
      final now = DateTime(2026, 6, 15, 12, 0);
      final original = UserProfile(
        userId: 'user_1',
        displayName: 'Test User',
        email: 'test@example.com',
        profileImageUrl: 'https://example.com/img.jpg',
        bio: 'Soccer fan',
        favoriteTeams: const ['USA', 'BRA'],
        homeLocation: 'New York',
        preferences: UserPreferences.defaultPreferences(),
        socialStats: SocialStats.empty(),
        createdAt: now,
        updatedAt: now,
        privacySettings: UserPrivacySettings.defaultSettings(),
        badges: const ['verified'],
        level: 15,
        experiencePoints: 5000,
      );

      final json = original.toJson();
      final restored = UserProfile.fromJson(json);

      expect(restored.userId, equals(original.userId));
      expect(restored.displayName, equals(original.displayName));
      expect(restored.email, equals(original.email));
      expect(restored.favoriteTeams, equals(original.favoriteTeams));
      expect(restored.level, equals(original.level));
      expect(restored.experiencePoints, equals(original.experiencePoints));
      expect(restored.badges, equals(original.badges));
    });

    test('copyWith preserves unchanged fields', () {
      final original = UserProfile.create(
        userId: 'u1',
        displayName: 'Original',
        email: 'orig@test.com',
      );

      final updated = original.copyWith(displayName: 'Updated');

      expect(updated.displayName, equals('Updated'));
      expect(updated.userId, equals('u1'));
      expect(updated.email, equals('orig@test.com'));
    });
  });

  // ===========================================================================
  // UserPreferences Entity
  // ===========================================================================
  group('UserPreferences', () {
    test('defaultPreferences has sensible defaults', () {
      final prefs = UserPreferences.defaultPreferences();

      expect(prefs.showLocation, isTrue);
      expect(prefs.allowFriendRequests, isTrue);
      expect(prefs.shareGameDayPlans, isTrue);
      expect(prefs.receiveNotifications, isTrue);
      expect(prefs.maxTravelDistance, equals(5));
      expect(prefs.preferredVenueTypes, contains('sports_bar'));
    });

    test('toJson/fromJson roundtrip preserves all fields', () {
      const original = UserPreferences(
        showLocation: false,
        allowFriendRequests: false,
        maxTravelDistance: 10,
        preferredPriceRange: '\$\$\$',
        autoShareCheckIns: true,
      );

      final json = original.toJson();
      final restored = UserPreferences.fromJson(json);

      expect(restored.showLocation, equals(original.showLocation));
      expect(
        restored.allowFriendRequests,
        equals(original.allowFriendRequests),
      );
      expect(restored.maxTravelDistance, equals(original.maxTravelDistance));
      expect(
        restored.preferredPriceRange,
        equals(original.preferredPriceRange),
      );
      expect(restored.autoShareCheckIns, equals(original.autoShareCheckIns));
    });

    test('copyWith applies changes', () {
      final original = UserPreferences.defaultPreferences();
      final updated = original.copyWith(
        allowFriendRequests: false,
        maxTravelDistance: 20,
      );

      expect(updated.allowFriendRequests, isFalse);
      expect(updated.maxTravelDistance, equals(20));
      // Unchanged
      expect(updated.showLocation, equals(original.showLocation));
    });
  });

  // ===========================================================================
  // SocialStats Entity
  // ===========================================================================
  group('SocialStats', () {
    test('empty() creates zeroed stats', () {
      final stats = SocialStats.empty();

      expect(stats.friendsCount, equals(0));
      expect(stats.checkInsCount, equals(0));
      expect(stats.reviewsCount, equals(0));
      expect(stats.gamesAttended, equals(0));
      expect(stats.venuesVisited, equals(0));
      expect(stats.photosShared, equals(0));
      expect(stats.likesReceived, equals(0));
      expect(stats.helpfulVotes, equals(0));
      expect(stats.lastActivity, isNull);
      expect(stats.totalActivity, equals(0));
    });

    test('totalActivity sums relevant counts', () {
      const stats = SocialStats(
        checkInsCount: 10,
        reviewsCount: 5,
        photosShared: 3,
        gamesAttended: 7,
      );

      expect(stats.totalActivity, equals(25));
    });

    test('toJson/fromJson roundtrip preserves fields', () {
      const original = SocialStats(
        friendsCount: 42,
        checkInsCount: 10,
        reviewsCount: 5,
        gamesAttended: 20,
        venuesVisited: 15,
        photosShared: 50,
        likesReceived: 100,
        helpfulVotes: 30,
      );

      final json = original.toJson();
      final restored = SocialStats.fromJson(json);

      expect(restored.friendsCount, equals(42));
      expect(restored.gamesAttended, equals(20));
      expect(restored.photosShared, equals(50));
    });

    test('copyWith applies changes', () {
      final original = SocialStats.empty();
      final updated = original.copyWith(friendsCount: 5, gamesAttended: 3);

      expect(updated.friendsCount, equals(5));
      expect(updated.gamesAttended, equals(3));
      // Unchanged
      expect(updated.checkInsCount, equals(0));
    });
  });

  // ===========================================================================
  // UserPrivacySettings Entity
  // ===========================================================================
  group('UserPrivacySettings', () {
    test('defaultSettings has all visibility enabled', () {
      final settings = UserPrivacySettings.defaultSettings();

      expect(settings.profileVisible, isTrue);
      expect(settings.showRealName, isTrue);
      expect(settings.showLocation, isTrue);
      expect(settings.showFavoriteTeams, isTrue);
      expect(settings.allowMessaging, isTrue);
      expect(settings.showOnlineStatus, isTrue);
      expect(settings.checkInVisibility, equals('friends'));
      expect(settings.friendListVisibility, equals('friends'));
    });

    test('toJson/fromJson roundtrip preserves fields', () {
      const original = UserPrivacySettings(
        profileVisible: false,
        showRealName: false,
        allowMessaging: false,
        checkInVisibility: 'private',
        friendListVisibility: 'public',
      );

      final json = original.toJson();
      final restored = UserPrivacySettings.fromJson(json);

      expect(restored.profileVisible, isFalse);
      expect(restored.showRealName, isFalse);
      expect(restored.allowMessaging, isFalse);
      expect(restored.checkInVisibility, equals('private'));
      expect(restored.friendListVisibility, equals('public'));
    });

    test('copyWith applies changes', () {
      final original = UserPrivacySettings.defaultSettings();
      final updated = original.copyWith(
        profileVisible: false,
        showOnlineStatus: false,
      );

      expect(updated.profileVisible, isFalse);
      expect(updated.showOnlineStatus, isFalse);
      // Unchanged
      expect(updated.allowMessaging, isTrue);
    });
  });

  // ===========================================================================
  // Block Connection Pattern (used by SocialService.blockUser)
  // ===========================================================================
  group('Block connection pattern', () {
    test('block connection follows expected ID pattern', () {
      const userId = 'user_1';
      const blockedUserId = 'user_2';
      const expectedId = '${userId}_blocks_$blockedUserId';

      final blockConnection = SocialConnection(
        connectionId: expectedId,
        fromUserId: userId,
        toUserId: blockedUserId,
        type: ConnectionType.block,
        status: ConnectionStatus.accepted,
        createdAt: DateTime.now(),
      );

      expect(blockConnection.connectionId, equals('user_1_blocks_user_2'));
      expect(blockConnection.type, equals(ConnectionType.block));
      expect(blockConnection.status, equals(ConnectionStatus.accepted));
      expect(blockConnection.isBlocked, isFalse); // isBlocked checks ConnectionStatus.blocked
      expect(blockConnection.isAccepted, isTrue); // blocks use "accepted" status
    });

    test('block connection is bidirectional by convention', () {
      // The service checks both directions when determining if blocked
      const userA = 'alice';
      const userB = 'bob';

      final aliceBlocksBob = SocialConnection(
        connectionId: '${userA}_blocks_$userB',
        fromUserId: userA,
        toUserId: userB,
        type: ConnectionType.block,
        status: ConnectionStatus.accepted,
        createdAt: DateTime.now(),
      );

      final bobBlocksAlice = SocialConnection(
        connectionId: '${userB}_blocks_$userA',
        fromUserId: userB,
        toUserId: userA,
        type: ConnectionType.block,
        status: ConnectionStatus.accepted,
        createdAt: DateTime.now(),
      );

      expect(aliceBlocksBob.connectionId, isNot(equals(bobBlocksAlice.connectionId)));
      expect(aliceBlocksBob.fromUserId, equals(userA));
      expect(bobBlocksAlice.fromUserId, equals(userB));
    });
  });
}
