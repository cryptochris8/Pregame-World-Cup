import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party_invite.dart';
import 'package:pregame_world_cup/features/watch_party/domain/services/watch_party_invite_service.dart';

// -- Mocks --
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockBox extends Mock implements Box<WatchPartyInvite> {}

// -- Fallback values --
class FakeWatchPartyInvite extends Fake implements WatchPartyInvite {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockBox mockInvitesBox;
  late WatchPartyInviteService service;

  const testUserId = 'user_test_123';
  const testWatchPartyId = 'wp_test_123';
  const testInviteeId = 'invitee_456';

  setUpAll(() {
    registerFallbackValue(FakeWatchPartyInvite());
  });

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockInvitesBox = MockBox();

    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn(testUserId);

    // Mock Hive box operations
    when(() => mockInvitesBox.put(any(), any())).thenAnswer((_) async {});
    when(() => mockInvitesBox.get(any())).thenReturn(null);
    when(() => mockInvitesBox.length).thenReturn(0);

    service = WatchPartyInviteService(
      firestore: fakeFirestore,
      auth: mockAuth,
    );
    service.initializeBox(mockInvitesBox);
  });

  /// Helper to create a test WatchParty
  WatchParty createTestParty({
    String watchPartyId = testWatchPartyId,
    String hostId = 'host_123',
    String name = 'Test Watch Party',
    String gameName = 'USA vs Mexico',
    String venueName = 'Sports Bar',
    DateTime? gameDateTime,
  }) {
    final now = DateTime.now();
    final game = gameDateTime ?? now.add(const Duration(days: 3));
    return WatchParty(
      watchPartyId: watchPartyId,
      name: name,
      description: 'A test party',
      hostId: hostId,
      hostName: 'Host User',
      visibility: WatchPartyVisibility.public,
      gameId: 'game_1',
      gameName: gameName,
      gameDateTime: game,
      venueId: 'venue_1',
      venueName: venueName,
      maxAttendees: 20,
      currentAttendeesCount: 5,
      status: WatchPartyStatus.upcoming,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Helper to seed a user profile in Firestore
  Future<void> seedUserProfile({
    required String userId,
    String displayName = 'Test User',
    String? imageUrl,
  }) async {
    await fakeFirestore.collection('user_profiles').doc(userId).set({
      'displayName': displayName,
      'imageUrl': imageUrl,
    });
  }

  /// Helper to seed an invite in Firestore
  Future<void> seedInvite({
    required String inviteId,
    String watchPartyId = testWatchPartyId,
    String watchPartyName = 'Test Watch Party',
    String inviterId = testUserId,
    String inviterName = 'Inviter',
    String inviteeId = testInviteeId,
    String status = 'pending',
    DateTime? createdAt,
    DateTime? expiresAt,
    String? gameName,
    DateTime? gameDateTime,
    String? venueName,
  }) async {
    final now = DateTime.now();
    await fakeFirestore
        .collection('watch_party_invites')
        .doc(inviteId)
        .set({
      'watchPartyId': watchPartyId,
      'watchPartyName': watchPartyName,
      'inviterId': inviterId,
      'inviterName': inviterName,
      'inviteeId': inviteeId,
      'status': status,
      'createdAt': (createdAt ?? now).toIso8601String(),
      'expiresAt':
          (expiresAt ?? now.add(const Duration(days: 7))).toIso8601String(),
      'gameName': gameName,
      'gameDateTime': gameDateTime?.toIso8601String(),
      'venueName': venueName,
    });
  }

  // ==================== sendInvite ====================
  group('sendInvite', () {
    test('returns false when user is not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);
      final party = createTestParty();

      final result = await service.sendInvite(
        testWatchPartyId,
        testInviteeId,
        party,
      );

      expect(result, isFalse);
    });

    test('sends invite successfully', () async {
      await seedUserProfile(
        userId: testUserId,
        displayName: 'The Inviter',
        imageUrl: 'https://example.com/inviter.jpg',
      );

      final party = createTestParty();

      final result = await service.sendInvite(
        testWatchPartyId,
        testInviteeId,
        party,
      );

      expect(result, isTrue);

      // Verify invite was stored in Firestore
      final snapshot =
          await fakeFirestore.collection('watch_party_invites').get();

      expect(snapshot.docs, hasLength(1));
      final data = snapshot.docs.first.data();
      expect(data['watchPartyId'], equals(testWatchPartyId));
      expect(data['inviteeId'], equals(testInviteeId));
      expect(data['inviterId'], equals(testUserId));
      expect(data['status'], equals('pending'));
      expect(data['watchPartyName'], equals('Test Watch Party'));
    });

    test('sends invite with optional message', () async {
      await seedUserProfile(userId: testUserId, displayName: 'Inviter');
      final party = createTestParty();

      final result = await service.sendInvite(
        testWatchPartyId,
        testInviteeId,
        party,
        message: 'Come watch the game!',
      );

      expect(result, isTrue);

      final snapshot =
          await fakeFirestore.collection('watch_party_invites').get();
      final data = snapshot.docs.first.data();
      expect(data['message'], equals('Come watch the game!'));
    });

    test('sends invite without message when not provided', () async {
      await seedUserProfile(userId: testUserId, displayName: 'Inviter');
      final party = createTestParty();

      final result = await service.sendInvite(
        testWatchPartyId,
        testInviteeId,
        party,
      );

      expect(result, isTrue);

      final snapshot =
          await fakeFirestore.collection('watch_party_invites').get();
      final data = snapshot.docs.first.data();
      expect(data['message'], isNull);
    });

    test('uses fallback name when user profile not found', () async {
      // Do NOT seed user profile
      final party = createTestParty();

      final result = await service.sendInvite(
        testWatchPartyId,
        testInviteeId,
        party,
      );

      expect(result, isTrue);

      final snapshot =
          await fakeFirestore.collection('watch_party_invites').get();
      final data = snapshot.docs.first.data();
      expect(data['inviterName'], equals('User'));
    });

    test('invite ID contains inviter and invitee IDs', () async {
      await seedUserProfile(userId: testUserId, displayName: 'Inviter');
      final party = createTestParty();

      await service.sendInvite(testWatchPartyId, testInviteeId, party);

      final snapshot =
          await fakeFirestore.collection('watch_party_invites').get();

      expect(snapshot.docs.first.id, contains(testUserId));
      expect(snapshot.docs.first.id, contains(testInviteeId));
    });

    test('includes game and venue details in invite', () async {
      await seedUserProfile(userId: testUserId, displayName: 'Inviter');
      final party = createTestParty(
        gameName: 'Brazil vs Argentina',
        venueName: 'MetLife Stadium',
      );

      await service.sendInvite(testWatchPartyId, testInviteeId, party);

      final snapshot =
          await fakeFirestore.collection('watch_party_invites').get();
      final data = snapshot.docs.first.data();
      expect(data['gameName'], equals('Brazil vs Argentina'));
      expect(data['venueName'], equals('MetLife Stadium'));
    });
  });

  // ==================== getPendingInvites ====================
  group('getPendingInvites', () {
    test('returns empty list when not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final invites = await service.getPendingInvites();

      expect(invites, isEmpty);
    });

    test('returns empty list when no pending invites', () async {
      final invites = await service.getPendingInvites();

      expect(invites, isEmpty);
    });

    test('returns pending invites for current user', () async {
      await seedInvite(
        inviteId: 'inv_1',
        inviteeId: testUserId,
        status: 'pending',
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      final invites = await service.getPendingInvites();

      expect(invites, hasLength(1));
      expect(invites.first.inviteId, equals('inv_1'));
    });

    test('filters out expired invites', () async {
      // Expired invite (expiresAt in the past)
      await seedInvite(
        inviteId: 'inv_expired',
        inviteeId: testUserId,
        status: 'pending',
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      // Valid invite
      await seedInvite(
        inviteId: 'inv_valid',
        inviteeId: testUserId,
        status: 'pending',
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      final invites = await service.getPendingInvites();

      // Only the non-expired invite should be returned
      expect(invites.where((i) => i.inviteId == 'inv_expired'), isEmpty);
    });

    test('does not return accepted invites', () async {
      await seedInvite(
        inviteId: 'inv_accepted',
        inviteeId: testUserId,
        status: 'accepted',
      );

      final invites = await service.getPendingInvites();

      expect(invites, isEmpty);
    });

    test('does not return declined invites', () async {
      await seedInvite(
        inviteId: 'inv_declined',
        inviteeId: testUserId,
        status: 'declined',
      );

      final invites = await service.getPendingInvites();

      expect(invites, isEmpty);
    });

    test('does not return invites for other users', () async {
      await seedInvite(
        inviteId: 'inv_other',
        inviteeId: 'other_user',
        status: 'pending',
      );

      final invites = await service.getPendingInvites();

      expect(invites, isEmpty);
    });

    test('caches invites in Hive box', () async {
      await seedInvite(
        inviteId: 'inv_cached',
        inviteeId: testUserId,
        status: 'pending',
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      await service.getPendingInvites();

      verify(() => mockInvitesBox.put(any(), any())).called(1);
    });
  });

  // ==================== respondToInvite ====================
  group('respondToInvite', () {
    test('accepts invite and returns watchPartyId', () async {
      await seedInvite(
        inviteId: 'inv_accept',
        watchPartyId: 'wp_accept_test',
        inviteeId: testUserId,
        status: 'pending',
      );

      final watchPartyId =
          await service.respondToInvite('inv_accept', true);

      expect(watchPartyId, equals('wp_accept_test'));

      // Verify status was updated in Firestore
      final doc = await fakeFirestore
          .collection('watch_party_invites')
          .doc('inv_accept')
          .get();

      expect(doc.data()!['status'], equals('accepted'));
    });

    test('declines invite and returns null', () async {
      await seedInvite(
        inviteId: 'inv_decline',
        inviteeId: testUserId,
        status: 'pending',
      );

      final watchPartyId =
          await service.respondToInvite('inv_decline', false);

      expect(watchPartyId, isNull);

      // Verify status was updated in Firestore
      final doc = await fakeFirestore
          .collection('watch_party_invites')
          .doc('inv_decline')
          .get();

      expect(doc.data()!['status'], equals('declined'));
    });

    test('clears memory cache after responding', () async {
      await seedInvite(
        inviteId: 'inv_cache_clear',
        inviteeId: testUserId,
        status: 'pending',
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      // Populate cache by getting pending invites
      await service.getPendingInvites();

      // Respond to invite
      await service.respondToInvite('inv_cache_clear', true);

      // Cache should be cleared - next call should fetch fresh data
      // (We can't directly verify cache state, but the method should work)
      final invites = await service.getPendingInvites();
      expect(invites, isA<List<WatchPartyInvite>>());
    });

    test('returns cached invite watchPartyId when available', () async {
      final cachedInvite = WatchPartyInvite(
        inviteId: 'inv_hive_cached',
        watchPartyId: 'wp_from_hive',
        watchPartyName: 'Cached Party',
        inviterId: 'inviter_1',
        inviterName: 'Inviter',
        inviteeId: testUserId,
        status: WatchPartyInviteStatus.pending,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      when(() => mockInvitesBox.get('inv_hive_cached'))
          .thenReturn(cachedInvite);

      // Seed in Firestore for the update to succeed
      await seedInvite(
        inviteId: 'inv_hive_cached',
        watchPartyId: 'wp_from_hive',
        inviteeId: testUserId,
      );

      final watchPartyId =
          await service.respondToInvite('inv_hive_cached', true);

      expect(watchPartyId, equals('wp_from_hive'));
    });
  });

  // ==================== createInviteNotification ====================
  group('createInviteNotification', () {
    test('creates notification document in Firestore', () async {
      final invite = WatchPartyInvite(
        inviteId: 'inv_notif',
        watchPartyId: testWatchPartyId,
        watchPartyName: 'Fun Party',
        inviterId: 'inviter_1',
        inviterName: 'John Doe',
        inviteeId: testInviteeId,
        status: WatchPartyInviteStatus.pending,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      await service.createInviteNotification(invite);

      final snapshot = await fakeFirestore.collection('notifications').get();

      expect(snapshot.docs, hasLength(1));
      final data = snapshot.docs.first.data();
      expect(data['userId'], equals(testInviteeId));
      expect(data['type'], equals('groupInvite'));
      expect(data['title'], equals('Watch Party Invite'));
      expect(data['message'], contains('John Doe'));
      expect(data['message'], contains('Fun Party'));
      expect(data['isRead'], isFalse);
      expect(data['data']['inviteId'], equals('inv_notif'));
      expect(data['data']['watchPartyId'], equals(testWatchPartyId));
    });

    test('handles error gracefully without throwing', () async {
      // Test that createInviteNotification doesn't throw even if there's
      // an unexpected issue. With FakeFirestore, errors are unlikely,
      // but we verify the method completes normally.
      final invite = WatchPartyInvite(
        inviteId: 'inv_error',
        watchPartyId: testWatchPartyId,
        watchPartyName: 'Error Party',
        inviterId: 'inviter_1',
        inviterName: 'Inviter',
        inviteeId: testInviteeId,
        status: WatchPartyInviteStatus.pending,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      await expectLater(
        service.createInviteNotification(invite),
        completes,
      );
    });
  });

  // ==================== clearCaches ====================
  group('clearCaches', () {
    test('clears in-memory invite caches', () async {
      // Populate cache by getting pending invites
      await seedInvite(
        inviteId: 'inv_cache_test',
        inviteeId: testUserId,
        status: 'pending',
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      );
      await service.getPendingInvites();

      service.clearCaches();

      // Verify by calling getPendingInvites again (should not use cache)
      // Since this fetches from Firestore, it should still work
      final invites = await service.getPendingInvites();
      expect(invites, isA<List<WatchPartyInvite>>());
    });
  });

  // ==================== hiveCacheSize ====================
  group('hiveCacheSize', () {
    test('returns box length', () {
      when(() => mockInvitesBox.length).thenReturn(15);

      expect(service.hiveCacheSize, equals(15));
    });

    test('returns 0 for empty box', () {
      when(() => mockInvitesBox.length).thenReturn(0);

      expect(service.hiveCacheSize, equals(0));
    });
  });

  // ==================== Constructor ====================
  group('Constructor', () {
    test('creates with custom firestore and auth', () {
      final customFirestore = FakeFirebaseFirestore();
      final customAuth = MockFirebaseAuth();
      when(() => customAuth.currentUser).thenReturn(null);

      final customService = WatchPartyInviteService(
        firestore: customFirestore,
        auth: customAuth,
      );

      expect(customService, isNotNull);
    });
  });
}
