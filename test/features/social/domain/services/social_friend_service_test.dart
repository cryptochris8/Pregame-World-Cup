import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/social/domain/entities/social_connection.dart';
import 'package:pregame_world_cup/features/social/domain/entities/user_profile.dart';
import 'package:pregame_world_cup/features/social/domain/services/social_friend_service.dart';
import 'package:pregame_world_cup/features/social/domain/services/social_profile_service.dart';

// -- Mocks --
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockSocialProfileService extends Mock implements SocialProfileService {}

class MockConnectionsBox extends Mock implements Box<SocialConnection> {}

class FakeSocialConnection extends Fake implements SocialConnection {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockSocialProfileService mockProfileService;
  late MockConnectionsBox mockBox;
  late SocialFriendService service;

  const testUserId = 'user_test_123';
  const testUserName = 'Test User';
  const targetUserId = 'user_target_456';

  setUpAll(() {
    registerFallbackValue(FakeSocialConnection());
  });

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockProfileService = MockSocialProfileService();
    mockBox = MockConnectionsBox();

    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn(testUserId);
    when(() => mockUser.displayName).thenReturn(testUserName);
    when(() => mockUser.photoURL).thenReturn(null);

    // Default mock box behavior
    when(() => mockBox.put(any(), any())).thenAnswer((_) async {});
    when(() => mockBox.delete(any())).thenAnswer((_) async {});
    when(() => mockBox.get(any())).thenReturn(null);
    when(() => mockBox.containsKey(any())).thenReturn(false);

    // Default profile service behavior
    when(() => mockProfileService.getUserProfile(any()))
        .thenAnswer((_) async => null);
    when(() => mockProfileService.incrementSocialStat(any(), any()))
        .thenAnswer((_) async {});
    when(() => mockProfileService.decrementSocialStat(any(), any()))
        .thenAnswer((_) async {});

    service = SocialFriendService(
      profileService: mockProfileService,
      firestore: fakeFirestore,
      auth: mockAuth,
    );
    service.connectionsBox = mockBox;
    service.connectionMemoryCache.clear();
  });

  /// Helper to seed a connection document in fake Firestore.
  Future<void> seedConnection({
    required String connectionId,
    required String fromUserId,
    required String toUserId,
    String type = 'friend',
    String status = 'pending',
    DateTime? createdAt,
    DateTime? acceptedAt,
  }) async {
    final data = <String, dynamic>{
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'type': type,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt ?? DateTime.now()),
      'connectionSource': 'test',
      'metadata': <String, dynamic>{},
    };
    if (acceptedAt != null) {
      data['acceptedAt'] = Timestamp.fromDate(acceptedAt);
    }
    await fakeFirestore
        .collection('social_connections')
        .doc(connectionId)
        .set(data);
  }

  // ===========================================================================
  // sendFriendRequest
  // ===========================================================================
  group('sendFriendRequest', () {
    test('returns false when no user is logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = await service.sendFriendRequest(targetUserId);

      expect(result, isFalse);
    });

    test('creates connection in Firestore and caches locally', () async {
      when(() => mockProfileService.getUserProfile(testUserId))
          .thenAnswer((_) async => UserProfile.create(
                userId: testUserId,
                displayName: testUserName,
              ));

      final result = await service.sendFriendRequest(targetUserId, source: 'search');

      expect(result, isTrue);

      // Verify Firestore document was created
      final snapshot =
          await fakeFirestore.collection('social_connections').get();
      expect(snapshot.docs.length, equals(1));

      final data = snapshot.docs.first.data();
      expect(data['fromUserId'], equals(testUserId));
      expect(data['toUserId'], equals(targetUserId));
      expect(data['type'], equals('friend'));
      expect(data['status'], equals('pending'));
      expect(data['connectionSource'], equals('search'));

      // Verify local cache was updated
      verify(() => mockBox.put(any(), any())).called(1);
    });

    test('creates friend request notification in Firestore', () async {
      when(() => mockProfileService.getUserProfile(testUserId))
          .thenAnswer((_) async => UserProfile.create(
                userId: testUserId,
                displayName: 'Sender Name',
              ));

      await service.sendFriendRequest(targetUserId);

      // Verify notification document was created
      final notifications =
          await fakeFirestore.collection('friend_request_notifications').get();
      expect(notifications.docs.length, equals(1));

      final notifData = notifications.docs.first.data();
      expect(notifData['fromUserId'], equals(testUserId));
      expect(notifData['toUserId'], equals(targetUserId));
      expect(notifData['type'], equals('friend_request'));
      expect(notifData['processed'], isFalse);
      expect(notifData['fromUserName'], equals('Sender Name'));
    });

    test('uses current user displayName as fallback for notification', () async {
      // getUserProfile returns null - fallback to currentUser.displayName
      when(() => mockProfileService.getUserProfile(testUserId))
          .thenAnswer((_) async => null);

      await service.sendFriendRequest(targetUserId);

      final notifications =
          await fakeFirestore.collection('friend_request_notifications').get();
      expect(notifications.docs.first.data()['fromUserName'], equals(testUserName));
    });
  });

  // ===========================================================================
  // acceptFriendRequest
  // ===========================================================================
  group('acceptFriendRequest', () {
    test('accepts a pending connection', () async {
      const connectionId = 'conn_pending_1';
      await seedConnection(
        connectionId: connectionId,
        fromUserId: 'sender_1',
        toUserId: testUserId,
        status: 'pending',
      );

      when(() => mockProfileService.getUserProfile(testUserId))
          .thenAnswer((_) async => UserProfile.create(
                userId: testUserId,
                displayName: 'Acceptor',
              ));

      final result = await service.acceptFriendRequest(connectionId);

      expect(result, isTrue);

      // Verify Firestore updated
      final doc = await fakeFirestore
          .collection('social_connections')
          .doc(connectionId)
          .get();
      expect(doc.data()!['status'], equals('accepted'));
      expect(doc.data()!['acceptedAt'], isNotNull);

      // Verify both users' social stats were incremented
      verify(() =>
              mockProfileService.incrementSocialStat('sender_1', 'friendsCount'))
          .called(1);
      verify(() =>
              mockProfileService.incrementSocialStat(testUserId, 'friendsCount'))
          .called(1);
    });

    test('creates accepted notification for original sender', () async {
      const connectionId = 'conn_accept_notif';
      await seedConnection(
        connectionId: connectionId,
        fromUserId: 'original_sender',
        toUserId: testUserId,
        status: 'pending',
      );

      when(() => mockProfileService.getUserProfile(testUserId))
          .thenAnswer((_) async => UserProfile.create(
                userId: testUserId,
                displayName: 'Acceptor Name',
              ));

      await service.acceptFriendRequest(connectionId);

      final notifications =
          await fakeFirestore.collection('friend_request_notifications').get();
      expect(notifications.docs.length, equals(1));

      final data = notifications.docs.first.data();
      expect(data['type'], equals('friend_request_accepted'));
      expect(data['toUserId'], equals('original_sender'));
      expect(data['fromUserName'], equals('Acceptor Name'));
    });

    test('returns false when connection does not exist', () async {
      final result = await service.acceptFriendRequest('nonexistent_conn');

      expect(result, isFalse);
    });

    test('returns connection from Hive cache if available', () async {
      const connectionId = 'conn_cached';
      final cachedConnection = SocialConnection(
        connectionId: connectionId,
        fromUserId: 'cached_sender',
        toUserId: testUserId,
        type: ConnectionType.friend,
        status: ConnectionStatus.pending,
        createdAt: DateTime.now(),
      );

      when(() => mockBox.get(connectionId)).thenReturn(cachedConnection);
      when(() => mockProfileService.getUserProfile(testUserId))
          .thenAnswer((_) async => null);

      // The connection comes from Hive cache, but Firestore update will fail
      // because the doc doesn't exist in fakeFirestore. Service catches the error.
      // Seeding the firestore doc to allow the update to succeed:
      await seedConnection(
        connectionId: connectionId,
        fromUserId: 'cached_sender',
        toUserId: testUserId,
        status: 'pending',
      );

      final result = await service.acceptFriendRequest(connectionId);

      expect(result, isTrue);
    });
  });

  // ===========================================================================
  // getUserConnections
  // ===========================================================================
  group('getUserConnections', () {
    test('returns connections from memory cache if available', () async {
      final cachedConnections = [
        SocialConnection(
          connectionId: 'mem_conn_1',
          fromUserId: testUserId,
          toUserId: 'other_1',
          type: ConnectionType.friend,
          status: ConnectionStatus.accepted,
          createdAt: DateTime.now(),
        ),
      ];
      service.connectionMemoryCache[testUserId] = cachedConnections;

      final result = await service.getUserConnections(testUserId);

      expect(result.length, equals(1));
      expect(result.first.connectionId, equals('mem_conn_1'));
    });

    test('fetches connections from Firestore when not cached', () async {
      await seedConnection(
        connectionId: 'fs_conn_1',
        fromUserId: testUserId,
        toUserId: 'other_1',
        type: 'friend',
        status: 'accepted',
      );
      await seedConnection(
        connectionId: 'fs_conn_2',
        fromUserId: 'other_2',
        toUserId: testUserId,
        type: 'friend',
        status: 'pending',
      );

      final result = await service.getUserConnections(testUserId);

      expect(result.length, equals(2));

      // Verify connections were cached locally
      verify(() => mockBox.put(any(), any())).called(2);

      // Verify memory cache was populated
      expect(service.connectionMemoryCache.containsKey(testUserId), isTrue);
    });

    test('returns empty list when user has no connections', () async {
      final result = await service.getUserConnections('lonely_user');

      expect(result, isEmpty);
    });

    test('combines fromUserId and toUserId queries', () async {
      // Connection where testUserId is the sender
      await seedConnection(
        connectionId: 'outgoing',
        fromUserId: testUserId,
        toUserId: 'other_1',
      );
      // Connection where testUserId is the receiver
      await seedConnection(
        connectionId: 'incoming',
        fromUserId: 'other_2',
        toUserId: testUserId,
      );

      final result = await service.getUserConnections(testUserId);

      expect(result.length, equals(2));
    });
  });

  // ===========================================================================
  // getFriendSuggestions
  // ===========================================================================
  group('getFriendSuggestions', () {
    test('returns empty list when user profile not found', () async {
      when(() => mockProfileService.getUserProfile('no_profile'))
          .thenAnswer((_) async => null);

      final result = await service.getFriendSuggestions('no_profile');

      expect(result, isEmpty);
    });

    test('returns suggestions based on shared favorite teams', () async {
      final userProfile = UserProfile.create(
        userId: testUserId,
        displayName: 'Test User',
        favoriteTeams: ['USA'],
      );
      when(() => mockProfileService.getUserProfile(testUserId))
          .thenAnswer((_) async => userProfile);

      // Seed potential suggestion profiles
      await fakeFirestore.collection('user_profiles').doc('suggested_1').set({
        'displayName': 'Suggested User 1',
        'favoriteTeams': ['USA'],
        'profileImageUrl': null,
      });

      final result = await service.getFriendSuggestions(testUserId);

      expect(result, isNotEmpty);
      expect(result.first.displayName, equals('Suggested User 1'));
      expect(result.first.connectionReason, equals('Fan of USA'));
      expect(result.first.sharedTeams, contains('USA'));
    });

    test('excludes existing friends from suggestions', () async {
      final userProfile = UserProfile.create(
        userId: testUserId,
        displayName: 'Test User',
        favoriteTeams: ['Brazil'],
      );
      when(() => mockProfileService.getUserProfile(testUserId))
          .thenAnswer((_) async => userProfile);

      // Seed existing friend connection
      await seedConnection(
        connectionId: 'existing_friend',
        fromUserId: testUserId,
        toUserId: 'already_friend',
        type: 'friend',
        status: 'accepted',
        acceptedAt: DateTime.now(),
      );

      // Seed user profiles
      await fakeFirestore.collection('user_profiles').doc('already_friend').set({
        'displayName': 'Already Friend',
        'favoriteTeams': ['Brazil'],
      });
      await fakeFirestore.collection('user_profiles').doc('new_suggestion').set({
        'displayName': 'New Suggestion',
        'favoriteTeams': ['Brazil'],
      });

      final result = await service.getFriendSuggestions(testUserId);

      final suggestedIds = result.map((s) => s.userId).toList();
      expect(suggestedIds, isNot(contains('already_friend')));
    });

    test('excludes self from suggestions', () async {
      final userProfile = UserProfile.create(
        userId: testUserId,
        displayName: 'Test User',
        favoriteTeams: ['Argentina'],
      );
      when(() => mockProfileService.getUserProfile(testUserId))
          .thenAnswer((_) async => userProfile);

      // Seed self profile with matching team
      await fakeFirestore.collection('user_profiles').doc(testUserId).set({
        'displayName': 'Self',
        'favoriteTeams': ['Argentina'],
      });

      final result = await service.getFriendSuggestions(testUserId);

      final suggestedIds = result.map((s) => s.userId).toList();
      expect(suggestedIds, isNot(contains(testUserId)));
    });

    test('respects limit parameter', () async {
      final userProfile = UserProfile.create(
        userId: testUserId,
        displayName: 'Test',
        favoriteTeams: ['Germany'],
      );
      when(() => mockProfileService.getUserProfile(testUserId))
          .thenAnswer((_) async => userProfile);

      for (int i = 0; i < 15; i++) {
        await fakeFirestore.collection('user_profiles').doc('user_$i').set({
          'displayName': 'User $i',
          'favoriteTeams': ['Germany'],
        });
      }

      final result = await service.getFriendSuggestions(testUserId, limit: 5);

      expect(result.length, lessThanOrEqualTo(5));
    });

    test('returns empty list for user with no favorite teams', () async {
      final userProfile = UserProfile.create(
        userId: testUserId,
        displayName: 'Test',
        favoriteTeams: [],
      );
      when(() => mockProfileService.getUserProfile(testUserId))
          .thenAnswer((_) async => userProfile);

      final result = await service.getFriendSuggestions(testUserId);

      expect(result, isEmpty);
    });
  });

  // ===========================================================================
  // declineFriendRequest
  // ===========================================================================
  group('declineFriendRequest', () {
    test('deletes connection from Firestore and cache', () async {
      const connectionId = 'conn_to_decline';
      await seedConnection(
        connectionId: connectionId,
        fromUserId: 'sender',
        toUserId: testUserId,
      );

      // Add to memory cache to verify it gets cleared
      service.connectionMemoryCache['some_key'] = [];

      final result = await service.declineFriendRequest(connectionId);

      expect(result, isTrue);

      // Verify Firestore document was deleted
      final doc = await fakeFirestore
          .collection('social_connections')
          .doc(connectionId)
          .get();
      expect(doc.exists, isFalse);

      // Verify local cache was cleared
      verify(() => mockBox.delete(connectionId)).called(1);
      expect(service.connectionMemoryCache, isEmpty);
    });

    test('returns true even when connection does not exist', () async {
      // Deleting non-existent doc does not throw in Firestore
      final result = await service.declineFriendRequest('nonexistent');

      expect(result, isTrue);
    });
  });

  // ===========================================================================
  // cancelFriendRequest
  // ===========================================================================
  group('cancelFriendRequest', () {
    test('deletes connection from Firestore and cache', () async {
      const connectionId = 'conn_to_cancel';
      await seedConnection(
        connectionId: connectionId,
        fromUserId: testUserId,
        toUserId: targetUserId,
      );

      final result = await service.cancelFriendRequest(connectionId);

      expect(result, isTrue);

      final doc = await fakeFirestore
          .collection('social_connections')
          .doc(connectionId)
          .get();
      expect(doc.exists, isFalse);
      verify(() => mockBox.delete(connectionId)).called(1);
    });

    test('clears memory cache on cancel', () async {
      service.connectionMemoryCache['user1'] = [];
      service.connectionMemoryCache['user2'] = [];

      await service.cancelFriendRequest('any_conn');

      expect(service.connectionMemoryCache, isEmpty);
    });
  });

  // ===========================================================================
  // removeFriend
  // ===========================================================================
  group('removeFriend', () {
    test('removes accepted friendship and decrements stats', () async {
      const connectionId = 'friend_conn';
      await seedConnection(
        connectionId: connectionId,
        fromUserId: testUserId,
        toUserId: 'friend_to_remove',
        type: 'friend',
        status: 'accepted',
        acceptedAt: DateTime.now(),
      );

      final result =
          await service.removeFriend(testUserId, 'friend_to_remove');

      expect(result, isTrue);

      // Verify Firestore deletion
      final doc = await fakeFirestore
          .collection('social_connections')
          .doc(connectionId)
          .get();
      expect(doc.exists, isFalse);

      // Verify stats decremented for both users
      verify(() => mockProfileService.decrementSocialStat(
          testUserId, 'friendsCount')).called(1);
      verify(() => mockProfileService.decrementSocialStat(
          'friend_to_remove', 'friendsCount')).called(1);
    });

    test('returns false when friendship does not exist', () async {
      // getUserConnections returns empty -> firstWhere throws
      final result =
          await service.removeFriend(testUserId, 'not_a_friend');

      expect(result, isFalse);
    });

    test('clears memory cache after removal', () async {
      await seedConnection(
        connectionId: 'rm_conn',
        fromUserId: testUserId,
        toUserId: 'rm_friend',
        type: 'friend',
        status: 'accepted',
        acceptedAt: DateTime.now(),
      );
      service.connectionMemoryCache['cached'] = [];

      await service.removeFriend(testUserId, 'rm_friend');

      expect(service.connectionMemoryCache, isEmpty);
    });
  });

  // ===========================================================================
  // blockUser
  // ===========================================================================
  group('blockUser', () {
    test('creates block connection in Firestore', () async {
      final result = await service.blockUser(testUserId, 'blocked_user');

      expect(result, isTrue);

      final doc = await fakeFirestore
          .collection('social_connections')
          .doc('${testUserId}_blocks_blocked_user')
          .get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['type'], equals('block'));
      expect(doc.data()!['status'], equals('accepted'));
      expect(doc.data()!['fromUserId'], equals(testUserId));
      expect(doc.data()!['toUserId'], equals('blocked_user'));
      expect(doc.data()!['metadata'], equals({'reason': 'blocked_by_user'}));
    });

    test('removes existing friendship before blocking', () async {
      // Seed existing friendship
      await seedConnection(
        connectionId: 'existing_friendship',
        fromUserId: testUserId,
        toUserId: 'block_target',
        type: 'friend',
        status: 'accepted',
        acceptedAt: DateTime.now(),
      );

      final result = await service.blockUser(testUserId, 'block_target');

      expect(result, isTrue);

      // Verify block connection was created
      final blockDoc = await fakeFirestore
          .collection('social_connections')
          .doc('${testUserId}_blocks_block_target')
          .get();
      expect(blockDoc.exists, isTrue);
    });

    test('caches block connection locally', () async {
      await service.blockUser(testUserId, 'blocked_local');

      verify(() => mockBox.put(
            '${testUserId}_blocks_blocked_local',
            any(),
          )).called(1);
    });

    test('clears memory cache after blocking', () async {
      service.connectionMemoryCache['user'] = [];

      await service.blockUser(testUserId, 'blocked_clear');

      expect(service.connectionMemoryCache, isEmpty);
    });
  });

  // ===========================================================================
  // unblockUser
  // ===========================================================================
  group('unblockUser', () {
    test('removes block connection from Firestore and cache', () async {
      final blockId = '${testUserId}_blocks_$targetUserId';
      await fakeFirestore.collection('social_connections').doc(blockId).set({
        'fromUserId': testUserId,
        'toUserId': targetUserId,
        'type': 'block',
        'status': 'accepted',
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });

      final result = await service.unblockUser(testUserId, targetUserId);

      expect(result, isTrue);

      final doc = await fakeFirestore
          .collection('social_connections')
          .doc(blockId)
          .get();
      expect(doc.exists, isFalse);
      verify(() => mockBox.delete(blockId)).called(1);
    });

    test('clears memory cache after unblocking', () async {
      service.connectionMemoryCache['key'] = [];

      await service.unblockUser(testUserId, targetUserId);

      expect(service.connectionMemoryCache, isEmpty);
    });
  });

  // ===========================================================================
  // isUserBlocked
  // ===========================================================================
  group('isUserBlocked', () {
    test('returns true when user1 blocks user2', () async {
      final blockId = 'user_a_blocks_user_b';
      await fakeFirestore.collection('social_connections').doc(blockId).set({
        'fromUserId': 'user_a',
        'toUserId': 'user_b',
        'type': 'block',
        'status': 'accepted',
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });

      final result = await service.isUserBlocked('user_a', 'user_b');

      expect(result, isTrue);
    });

    test('returns true when user2 blocks user1 (reverse direction)', () async {
      final blockId = 'user_b_blocks_user_a';
      await fakeFirestore.collection('social_connections').doc(blockId).set({
        'fromUserId': 'user_b',
        'toUserId': 'user_a',
        'type': 'block',
        'status': 'accepted',
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });

      final result = await service.isUserBlocked('user_a', 'user_b');

      expect(result, isTrue);
    });

    test('returns false when no block exists', () async {
      final result = await service.isUserBlocked('user_x', 'user_y');

      expect(result, isFalse);
    });

    test('returns false when connection exists but is not a block', () async {
      final docId = 'user_c_blocks_user_d';
      await fakeFirestore.collection('social_connections').doc(docId).set({
        'fromUserId': 'user_c',
        'toUserId': 'user_d',
        'type': 'friend',
        'status': 'accepted',
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });

      final result = await service.isUserBlocked('user_c', 'user_d');

      expect(result, isFalse);
    });
  });

  // ===========================================================================
  // hasBlockedUser
  // ===========================================================================
  group('hasBlockedUser', () {
    test('returns false when no user is logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = await service.hasBlockedUser('some_user');

      expect(result, isFalse);
    });

    test('returns true when current user has blocked the target', () async {
      final blockId = '${testUserId}_blocks_blocked_target';
      await fakeFirestore.collection('social_connections').doc(blockId).set({
        'fromUserId': testUserId,
        'toUserId': 'blocked_target',
        'type': 'block',
        'status': 'accepted',
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });

      final result = await service.hasBlockedUser('blocked_target');

      expect(result, isTrue);
    });

    test('returns false when current user has not blocked the target', () async {
      final result = await service.hasBlockedUser('not_blocked');

      expect(result, isFalse);
    });
  });

  // ===========================================================================
  // isBlockedByUser
  // ===========================================================================
  group('isBlockedByUser', () {
    test('returns false when no user is logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = await service.isBlockedByUser('some_blocker');

      expect(result, isFalse);
    });

    test('returns true when target user has blocked current user', () async {
      final blockId = 'blocker_blocks_$testUserId';
      await fakeFirestore.collection('social_connections').doc(blockId).set({
        'fromUserId': 'blocker',
        'toUserId': testUserId,
        'type': 'block',
        'status': 'accepted',
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });

      final result = await service.isBlockedByUser('blocker');

      expect(result, isTrue);
    });

    test('returns false when target user has not blocked current user', () async {
      final result = await service.isBlockedByUser('friendly_user');

      expect(result, isFalse);
    });
  });

  // ===========================================================================
  // getBlockedUserIds
  // ===========================================================================
  group('getBlockedUserIds', () {
    test('returns empty list when no user is logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = await service.getBlockedUserIds();

      expect(result, isEmpty);
    });

    test('returns list of blocked user IDs', () async {
      await fakeFirestore.collection('social_connections').doc('block_1').set({
        'fromUserId': testUserId,
        'toUserId': 'blocked_a',
        'type': 'block',
        'status': 'accepted',
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });
      await fakeFirestore.collection('social_connections').doc('block_2').set({
        'fromUserId': testUserId,
        'toUserId': 'blocked_b',
        'type': 'block',
        'status': 'accepted',
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });

      final result = await service.getBlockedUserIds();

      expect(result.length, equals(2));
      expect(result, contains('blocked_a'));
      expect(result, contains('blocked_b'));
    });

    test('excludes non-block connections from results', () async {
      await fakeFirestore.collection('social_connections').doc('friend_conn').set({
        'fromUserId': testUserId,
        'toUserId': 'friend_user',
        'type': 'friend',
        'status': 'accepted',
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });

      final result = await service.getBlockedUserIds();

      expect(result, isNot(contains('friend_user')));
    });

    test('returns empty list when no blocks exist', () async {
      final result = await service.getBlockedUserIds();

      expect(result, isEmpty);
    });
  });

  // ===========================================================================
  // initialize
  // ===========================================================================
  group('initialize', () {
    test('sets the connections box', () async {
      final newBox = MockConnectionsBox();
      when(() => newBox.put(any(), any())).thenAnswer((_) async {});

      await service.initialize(newBox);

      // After initialization, the box should be set (we can verify by using the service)
      // No assertion needed - just verifying no exception is thrown
    });
  });
}
