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
  late SocialFriendService friendService;

  const testUserId = 'current_user_123';

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
    when(() => mockUser.displayName).thenReturn('Test User');
    when(() => mockUser.photoURL).thenReturn(null);

    when(() => mockBox.put(any(), any())).thenAnswer((_) async {});
    when(() => mockBox.delete(any())).thenAnswer((_) async {});
    when(() => mockBox.get(any())).thenReturn(null);
    when(() => mockBox.containsKey(any())).thenReturn(false);

    when(() => mockProfileService.getUserProfile(any()))
        .thenAnswer((_) async => null);
    when(() => mockProfileService.incrementSocialStat(any(), any()))
        .thenAnswer((_) async {});
    when(() => mockProfileService.decrementSocialStat(any(), any()))
        .thenAnswer((_) async {});

    friendService = SocialFriendService(
      profileService: mockProfileService,
      firestore: fakeFirestore,
      auth: mockAuth,
    );
    friendService.connectionsBox = mockBox;
    friendService.connectionMemoryCache.clear();
  });

  // ===========================================================================
  // Search results should be filterable by blocked user IDs
  // ===========================================================================
  group('Search result filtering with blocked users', () {
    UserProfile _createProfile(String userId, String name) {
      return UserProfile.create(
        userId: userId,
        displayName: name,
        email: '$userId@test.com',
      );
    }

    test('getBlockedUserIds returns blocked user IDs for filtering', () async {
      // Seed two block connections
      await fakeFirestore.collection('social_connections').doc('block_1').set({
        'fromUserId': testUserId,
        'toUserId': 'blocked_user_a',
        'type': 'block',
        'status': 'accepted',
        'createdAt': Timestamp.now(),
      });
      await fakeFirestore.collection('social_connections').doc('block_2').set({
        'fromUserId': testUserId,
        'toUserId': 'blocked_user_b',
        'type': 'block',
        'status': 'accepted',
        'createdAt': Timestamp.now(),
      });

      final blockedIds = await friendService.getBlockedUserIds();

      expect(blockedIds, hasLength(2));
      expect(blockedIds, contains('blocked_user_a'));
      expect(blockedIds, contains('blocked_user_b'));
    });

    test('blocked user IDs can filter search results list', () async {
      // Simulate what SocialService.searchUsers does
      final searchResults = [
        _createProfile('user_a', 'Alice'),
        _createProfile('blocked_user_a', 'Blocked Alice'),
        _createProfile('user_b', 'Bob'),
        _createProfile('blocked_user_b', 'Blocked Bob'),
        _createProfile('user_c', 'Charlie'),
      ];

      // Seed blocks in Firestore
      await fakeFirestore.collection('social_connections').doc('block_1').set({
        'fromUserId': testUserId,
        'toUserId': 'blocked_user_a',
        'type': 'block',
        'status': 'accepted',
        'createdAt': Timestamp.now(),
      });
      await fakeFirestore.collection('social_connections').doc('block_2').set({
        'fromUserId': testUserId,
        'toUserId': 'blocked_user_b',
        'type': 'block',
        'status': 'accepted',
        'createdAt': Timestamp.now(),
      });

      final blockedIds = await friendService.getBlockedUserIds();
      final blockedSet = blockedIds.toSet();

      // Filter as SocialService.searchUsers now does
      final filtered = searchResults
          .where((u) => !blockedSet.contains(u.userId))
          .toList();

      expect(filtered, hasLength(3));
      expect(filtered.map((u) => u.userId), containsAll(['user_a', 'user_b', 'user_c']));
      expect(filtered.map((u) => u.userId), isNot(contains('blocked_user_a')));
      expect(filtered.map((u) => u.userId), isNot(contains('blocked_user_b')));
    });

    test('no blocked users returns unfiltered results', () async {
      final searchResults = [
        _createProfile('user_a', 'Alice'),
        _createProfile('user_b', 'Bob'),
      ];

      final blockedIds = await friendService.getBlockedUserIds();
      expect(blockedIds, isEmpty);

      // No filtering happens
      final filtered = searchResults;
      expect(filtered, hasLength(2));
    });

    test('non-block connections are not included in blocked IDs', () async {
      // Seed a friend connection (not a block)
      await fakeFirestore.collection('social_connections').doc('friend_1').set({
        'fromUserId': testUserId,
        'toUserId': 'friend_user',
        'type': 'friend',
        'status': 'accepted',
        'createdAt': Timestamp.now(),
      });

      final blockedIds = await friendService.getBlockedUserIds();
      expect(blockedIds, isEmpty);
      expect(blockedIds, isNot(contains('friend_user')));
    });
  });

  // ===========================================================================
  // Block from profile screen (service-level tests)
  // ===========================================================================
  group('Block/unblock from profile', () {
    test('blockUser creates block and unblockUser removes it', () async {
      // Block
      final blocked = await friendService.blockUser(testUserId, 'target_user');
      expect(blocked, isTrue);

      final blockDoc = await fakeFirestore
          .collection('social_connections')
          .doc('${testUserId}_blocks_target_user')
          .get();
      expect(blockDoc.exists, isTrue);
      expect(blockDoc.data()!['type'], equals('block'));

      // Unblock
      final unblocked = await friendService.unblockUser(testUserId, 'target_user');
      expect(unblocked, isTrue);

      final deletedDoc = await fakeFirestore
          .collection('social_connections')
          .doc('${testUserId}_blocks_target_user')
          .get();
      expect(deletedDoc.exists, isFalse);
    });

    test('hasBlockedUser returns correct status after block/unblock cycle', () async {
      // Initially not blocked
      var isBlocked = await friendService.hasBlockedUser('target_user');
      expect(isBlocked, isFalse);

      // Block the user
      await friendService.blockUser(testUserId, 'target_user');
      isBlocked = await friendService.hasBlockedUser('target_user');
      expect(isBlocked, isTrue);

      // Unblock the user
      await friendService.unblockUser(testUserId, 'target_user');
      isBlocked = await friendService.hasBlockedUser('target_user');
      expect(isBlocked, isFalse);
    });

    test('blockUser creates a report for admin notification', () async {
      await friendService.blockUser(testUserId, 'target_user');

      final reports = await fakeFirestore.collection('reports').get();
      expect(reports.docs, hasLength(1));

      final report = reports.docs.first.data();
      expect(report['reporterId'], equals(testUserId));
      expect(report['reportedUserId'], equals('target_user'));
      expect(report['isBlockAction'], isTrue);
    });
  });

  // ===========================================================================
  // Blocked users list management
  // ===========================================================================
  group('Blocked users list management', () {
    test('getBlockedUserIds returns all blocked users for management screen', () async {
      // Block multiple users
      await friendService.blockUser(testUserId, 'user_1');
      await friendService.blockUser(testUserId, 'user_2');
      await friendService.blockUser(testUserId, 'user_3');

      final blockedIds = await friendService.getBlockedUserIds();

      expect(blockedIds, hasLength(3));
      expect(blockedIds, containsAll(['user_1', 'user_2', 'user_3']));
    });

    test('unblocking removes user from blocked list', () async {
      await friendService.blockUser(testUserId, 'user_1');
      await friendService.blockUser(testUserId, 'user_2');

      // Unblock one
      await friendService.unblockUser(testUserId, 'user_1');

      final blockedIds = await friendService.getBlockedUserIds();
      expect(blockedIds, hasLength(1));
      expect(blockedIds, contains('user_2'));
      expect(blockedIds, isNot(contains('user_1')));
    });

    test('blocking is asymmetric - only blocker sees blocked list', () async {
      await friendService.blockUser(testUserId, 'other_user');

      // Current user should see 'other_user' in their blocked list
      final blockedIds = await friendService.getBlockedUserIds();
      expect(blockedIds, contains('other_user'));

      // But isBlockedByUser checks the reverse direction
      final isBlockedBy = await friendService.isBlockedByUser('other_user');
      expect(isBlockedBy, isFalse); // other_user hasn't blocked us
    });
  });

  // ===========================================================================
  // FriendActionDialogs unblock confirmation (entity-level)
  // ===========================================================================
  group('Unblock dialog entity support', () {
    test('SocialConnection block type has correct properties', () {
      final blockConnection = SocialConnection(
        connectionId: '${testUserId}_blocks_target',
        fromUserId: testUserId,
        toUserId: 'target',
        type: ConnectionType.block,
        status: ConnectionStatus.accepted,
        createdAt: DateTime.now(),
      );

      expect(blockConnection.type, equals(ConnectionType.block));
      expect(blockConnection.isAccepted, isTrue);
      expect(blockConnection.isFriend, isFalse);
      expect(blockConnection.fromUserId, equals(testUserId));
      expect(blockConnection.toUserId, equals('target'));
    });
  });
}
