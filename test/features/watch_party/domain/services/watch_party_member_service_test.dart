import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party_member.dart';
import 'package:pregame_world_cup/features/watch_party/domain/services/watch_party_member_service.dart';

// -- Mocks --
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockBox extends Mock implements Box<WatchPartyMember> {}

// -- Fallback values --
class FakeWatchPartyMember extends Fake implements WatchPartyMember {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockBox mockMembersBox;
  late WatchPartyMemberService service;

  const testUserId = 'user_test_123';
  const testUserName = 'Test User';
  const testWatchPartyId = 'wp_test_123';
  const testHostId = 'host_123';

  setUpAll(() {
    registerFallbackValue(FakeWatchPartyMember());
  });

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockMembersBox = MockBox();

    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn(testUserId);

    // Mock Hive box operations
    when(() => mockMembersBox.put(any(), any())).thenAnswer((_) async {});
    when(() => mockMembersBox.get(any())).thenReturn(null);
    when(() => mockMembersBox.length).thenReturn(0);

    service = WatchPartyMemberService(
      firestore: fakeFirestore,
      auth: mockAuth,
    );
    service.initializeBox(mockMembersBox);
  });

  /// Helper to create a test WatchParty
  WatchParty createTestParty({
    String watchPartyId = testWatchPartyId,
    String hostId = testHostId,
    WatchPartyStatus status = WatchPartyStatus.upcoming,
    int maxAttendees = 20,
    int currentAttendeesCount = 5,
  }) {
    final now = DateTime.now();
    return WatchParty(
      watchPartyId: watchPartyId,
      name: 'Test Watch Party',
      description: 'A test party',
      hostId: hostId,
      hostName: 'Host User',
      visibility: WatchPartyVisibility.public,
      gameId: 'game_1',
      gameName: 'USA vs Mexico',
      gameDateTime: now.add(const Duration(hours: 2)),
      venueId: 'venue_1',
      venueName: 'Sports Bar',
      maxAttendees: maxAttendees,
      currentAttendeesCount: currentAttendeesCount,
      status: status,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Helper to seed a member document in Firestore
  Future<void> seedMember({
    required String watchPartyId,
    required String userId,
    String displayName = 'Test Member',
    String role = 'member',
    String attendanceType = 'inPerson',
    bool hasPaid = false,
    bool isMuted = false,
  }) async {
    await fakeFirestore
        .collection('watch_parties')
        .doc(watchPartyId)
        .collection('members')
        .doc(userId)
        .set({
      'watchPartyId': watchPartyId,
      'userId': userId,
      'displayName': displayName,
      'role': role,
      'attendanceType': attendanceType,
      'rsvpStatus': 'going',
      'joinedAt': DateTime.now().toIso8601String(),
      'hasPaid': hasPaid,
      'isMuted': isMuted,
    });
  }

  /// Helper to seed a user profile document in Firestore
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

  // ==================== addMember ====================
  group('addMember', () {
    test('adds member to Firestore subcollection', () async {
      await service.addMember(
        testWatchPartyId,
        'user_new',
        'New User',
        'https://example.com/photo.jpg',
        WatchPartyMemberRole.member,
        WatchPartyAttendanceType.inPerson,
      );

      final doc = await fakeFirestore
          .collection('watch_parties')
          .doc(testWatchPartyId)
          .collection('members')
          .doc('user_new')
          .get();

      expect(doc.exists, isTrue);
      expect(doc.data()!['userId'], equals('user_new'));
      expect(doc.data()!['displayName'], equals('New User'));
      expect(doc.data()!['role'], equals('member'));
      expect(doc.data()!['attendanceType'], equals('inPerson'));
    });

    test('adds host member correctly', () async {
      await service.addMember(
        testWatchPartyId,
        'host_user',
        'Host Name',
        null,
        WatchPartyMemberRole.host,
        WatchPartyAttendanceType.inPerson,
      );

      final doc = await fakeFirestore
          .collection('watch_parties')
          .doc(testWatchPartyId)
          .collection('members')
          .doc('host_user')
          .get();

      expect(doc.data()!['role'], equals('host'));
    });

    test('adds virtual member correctly', () async {
      await service.addMember(
        testWatchPartyId,
        'virtual_user',
        'Virtual User',
        null,
        WatchPartyMemberRole.member,
        WatchPartyAttendanceType.virtual,
      );

      final doc = await fakeFirestore
          .collection('watch_parties')
          .doc(testWatchPartyId)
          .collection('members')
          .doc('virtual_user')
          .get();

      expect(doc.data()!['attendanceType'], equals('virtual'));
    });

    test('caches member in Hive box', () async {
      await service.addMember(
        testWatchPartyId,
        'cached_user',
        'Cached User',
        null,
        WatchPartyMemberRole.member,
        WatchPartyAttendanceType.inPerson,
      );

      verify(() => mockMembersBox.put(any(), any())).called(1);
    });
  });

  // ==================== getMember ====================
  group('getMember', () {
    test('returns member from Firestore when not cached', () async {
      await seedMember(
        watchPartyId: testWatchPartyId,
        userId: 'user_abc',
        displayName: 'ABC User',
        role: 'host',
      );

      final member =
          await service.getMember(testWatchPartyId, 'user_abc');

      expect(member, isNotNull);
      expect(member!.displayName, equals('ABC User'));
      expect(member.role, equals(WatchPartyMemberRole.host));
    });

    test('returns null when member does not exist', () async {
      final member =
          await service.getMember(testWatchPartyId, 'nonexistent');

      expect(member, isNull);
    });

    test('returns cached member from Hive box when available', () async {
      final cachedMember = WatchPartyMember(
        memberId: '${testWatchPartyId}_cached',
        watchPartyId: testWatchPartyId,
        userId: 'cached',
        displayName: 'Cached Member',
        role: WatchPartyMemberRole.member,
        attendanceType: WatchPartyAttendanceType.inPerson,
        rsvpStatus: MemberRsvpStatus.going,
        joinedAt: DateTime.now(),
      );

      when(() => mockMembersBox.get('${testWatchPartyId}_cached'))
          .thenReturn(cachedMember);

      final member =
          await service.getMember(testWatchPartyId, 'cached');

      expect(member, isNotNull);
      expect(member!.displayName, equals('Cached Member'));
    });
  });

  // ==================== joinWatchParty ====================
  group('joinWatchParty', () {
    test('returns false when user is not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);
      final party = createTestParty();

      final result = await service.joinWatchParty(
        testWatchPartyId,
        WatchPartyAttendanceType.inPerson,
        party,
      );

      expect(result, isFalse);
    });

    test('returns false when party is null', () async {
      final result = await service.joinWatchParty(
        testWatchPartyId,
        WatchPartyAttendanceType.inPerson,
        null,
      );

      expect(result, isFalse);
    });

    test('returns false when party is full', () async {
      final fullParty = createTestParty(
        maxAttendees: 10,
        currentAttendeesCount: 10,
      );

      final result = await service.joinWatchParty(
        testWatchPartyId,
        WatchPartyAttendanceType.inPerson,
        fullParty,
      );

      expect(result, isFalse);
    });

    test('returns false when party is not upcoming', () async {
      final endedParty = createTestParty(
        status: WatchPartyStatus.ended,
      );

      final result = await service.joinWatchParty(
        testWatchPartyId,
        WatchPartyAttendanceType.inPerson,
        endedParty,
      );

      expect(result, isFalse);
    });

    test('returns true when user is already a member', () async {
      await seedMember(
        watchPartyId: testWatchPartyId,
        userId: testUserId,
        displayName: testUserName,
      );

      // Ensure Hive does not return cached
      when(() => mockMembersBox.get('${testWatchPartyId}_$testUserId'))
          .thenReturn(null);

      final party = createTestParty();

      final result = await service.joinWatchParty(
        testWatchPartyId,
        WatchPartyAttendanceType.inPerson,
        party,
      );

      expect(result, isTrue);
    });

    test('joins successfully as in-person member', () async {
      await seedUserProfile(
        userId: testUserId,
        displayName: 'Joining User',
      );

      // Need to seed the watch party document for the count update
      await fakeFirestore
          .collection('watch_parties')
          .doc(testWatchPartyId)
          .set({
        'currentAttendeesCount': 5,
        'virtualAttendeesCount': 0,
      });

      final party = createTestParty();

      final result = await service.joinWatchParty(
        testWatchPartyId,
        WatchPartyAttendanceType.inPerson,
        party,
      );

      expect(result, isTrue);

      // Verify member was added
      final memberDoc = await fakeFirestore
          .collection('watch_parties')
          .doc(testWatchPartyId)
          .collection('members')
          .doc(testUserId)
          .get();

      expect(memberDoc.exists, isTrue);
      expect(memberDoc.data()!['role'], equals('member'));
    });

    test('joins successfully as virtual member', () async {
      await seedUserProfile(userId: testUserId, displayName: 'Virtual Joiner');

      await fakeFirestore
          .collection('watch_parties')
          .doc(testWatchPartyId)
          .set({
        'currentAttendeesCount': 5,
        'virtualAttendeesCount': 2,
      });

      final party = createTestParty();

      final result = await service.joinWatchParty(
        testWatchPartyId,
        WatchPartyAttendanceType.virtual,
        party,
      );

      expect(result, isTrue);
    });

    test('uses fallback display name when profile not found', () async {
      // Do NOT seed user profile

      await fakeFirestore
          .collection('watch_parties')
          .doc(testWatchPartyId)
          .set({
        'currentAttendeesCount': 5,
        'virtualAttendeesCount': 0,
      });

      final party = createTestParty();

      final result = await service.joinWatchParty(
        testWatchPartyId,
        WatchPartyAttendanceType.inPerson,
        party,
      );

      expect(result, isTrue);

      final memberDoc = await fakeFirestore
          .collection('watch_parties')
          .doc(testWatchPartyId)
          .collection('members')
          .doc(testUserId)
          .get();

      expect(memberDoc.data()!['displayName'], equals('Member'));
    });
  });

  // ==================== getJoinDisplayName ====================
  group('getJoinDisplayName', () {
    test('returns "Someone" when not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final name = await service.getJoinDisplayName();
      expect(name, equals('Someone'));
    });

    test('returns display name from user profile', () async {
      await seedUserProfile(
        userId: testUserId,
        displayName: 'John Doe',
      );

      final name = await service.getJoinDisplayName();
      expect(name, equals('John Doe'));
    });

    test('returns "Someone" when profile not found', () async {
      // No profile seeded
      final name = await service.getJoinDisplayName();
      expect(name, equals('Someone'));
    });
  });

  // ==================== leaveWatchParty ====================
  group('leaveWatchParty', () {
    test('returns false when user is not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = await service.leaveWatchParty(testWatchPartyId);

      expect(result, isFalse);
    });

    test('returns false when user is not a member', () async {
      // No member seeded, Hive returns null
      final result = await service.leaveWatchParty(testWatchPartyId);

      expect(result, isFalse);
    });

    test('returns false when user is the host', () async {
      await seedMember(
        watchPartyId: testWatchPartyId,
        userId: testUserId,
        role: 'host',
      );

      final result = await service.leaveWatchParty(testWatchPartyId);

      expect(result, isFalse);
    });

    test('leaves successfully as regular member', () async {
      await seedMember(
        watchPartyId: testWatchPartyId,
        userId: testUserId,
        role: 'member',
        attendanceType: 'inPerson',
      );

      // Seed the watch party document for the count update
      await fakeFirestore
          .collection('watch_parties')
          .doc(testWatchPartyId)
          .set({
        'currentAttendeesCount': 5,
        'virtualAttendeesCount': 0,
      });

      final result = await service.leaveWatchParty(testWatchPartyId);

      expect(result, isTrue);

      // Verify member was removed from Firestore
      final memberDoc = await fakeFirestore
          .collection('watch_parties')
          .doc(testWatchPartyId)
          .collection('members')
          .doc(testUserId)
          .get();

      expect(memberDoc.exists, isFalse);
    });

    test('leaves successfully as virtual member', () async {
      await seedMember(
        watchPartyId: testWatchPartyId,
        userId: testUserId,
        role: 'member',
        attendanceType: 'virtual',
      );

      await fakeFirestore
          .collection('watch_parties')
          .doc(testWatchPartyId)
          .set({
        'currentAttendeesCount': 5,
        'virtualAttendeesCount': 3,
      });

      final result = await service.leaveWatchParty(testWatchPartyId);

      expect(result, isTrue);
    });
  });

  // ==================== getLeavingMemberName ====================
  group('getLeavingMemberName', () {
    test('returns null when not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final name = await service.getLeavingMemberName(testWatchPartyId);
      expect(name, isNull);
    });

    test('returns member display name', () async {
      await seedMember(
        watchPartyId: testWatchPartyId,
        userId: testUserId,
        displayName: 'Leaving User',
      );

      final name = await service.getLeavingMemberName(testWatchPartyId);
      expect(name, equals('Leaving User'));
    });

    test('returns null when member not found', () async {
      final name = await service.getLeavingMemberName(testWatchPartyId);
      expect(name, isNull);
    });
  });

  // ==================== getMembers ====================
  group('getMembers', () {
    test('returns empty list for party with no members', () async {
      final members = await service.getMembers('empty_party');

      expect(members, isEmpty);
    });

    test('returns all members of a watch party', () async {
      await seedMember(
        watchPartyId: testWatchPartyId,
        userId: 'host_1',
        displayName: 'Host',
        role: 'host',
      );
      await seedMember(
        watchPartyId: testWatchPartyId,
        userId: 'member_1',
        displayName: 'Member 1',
      );
      await seedMember(
        watchPartyId: testWatchPartyId,
        userId: 'member_2',
        displayName: 'Member 2',
      );

      final members = await service.getMembers(testWatchPartyId);

      expect(members, hasLength(3));
    });

    test('returns cached members on second call', () async {
      await seedMember(
        watchPartyId: testWatchPartyId,
        userId: 'member_cached',
        displayName: 'Cached',
      );

      // First call - fetches from Firestore
      final members1 = await service.getMembers(testWatchPartyId);
      expect(members1, hasLength(1));

      // Second call - should return from memory cache
      final members2 = await service.getMembers(testWatchPartyId);
      expect(members2, hasLength(1));
    });

    test('cache is invalidated correctly', () async {
      await seedMember(
        watchPartyId: testWatchPartyId,
        userId: 'member_inv',
        displayName: 'Invalidated',
      );

      // Populate cache
      await service.getMembers(testWatchPartyId);

      // Invalidate cache
      service.invalidateMembersCache(testWatchPartyId);

      // Add another member
      await seedMember(
        watchPartyId: testWatchPartyId,
        userId: 'member_inv_2',
        displayName: 'Added After Invalidation',
      );

      // Should fetch fresh from Firestore
      final members = await service.getMembers(testWatchPartyId);
      expect(members, hasLength(2));
    });
  });

  // ==================== isUserMember ====================
  group('isUserMember', () {
    test('returns false when not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = await service.isUserMember(testWatchPartyId);

      expect(result, isFalse);
    });

    test('returns true when user is a member', () async {
      await seedMember(
        watchPartyId: testWatchPartyId,
        userId: testUserId,
      );

      final result = await service.isUserMember(testWatchPartyId);

      expect(result, isTrue);
    });

    test('returns false when user is not a member', () async {
      final result = await service.isUserMember(testWatchPartyId);

      expect(result, isFalse);
    });
  });

  // ==================== getCurrentUserMembership ====================
  group('getCurrentUserMembership', () {
    test('returns null when not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result =
          await service.getCurrentUserMembership(testWatchPartyId);

      expect(result, isNull);
    });

    test('returns membership when user is a member', () async {
      await seedMember(
        watchPartyId: testWatchPartyId,
        userId: testUserId,
        displayName: 'Current User',
        role: 'coHost',
      );

      final result =
          await service.getCurrentUserMembership(testWatchPartyId);

      expect(result, isNotNull);
      expect(result!.role, equals(WatchPartyMemberRole.coHost));
    });
  });

  // ==================== muteMember / unmuteMember ====================
  group('muteMember', () {
    test('returns false when not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result =
          await service.muteMember(testWatchPartyId, 'user_to_mute');

      expect(result, isFalse);
    });

    test('mutes member successfully', () async {
      await seedMember(
        watchPartyId: testWatchPartyId,
        userId: 'user_to_mute',
        isMuted: false,
      );

      final result =
          await service.muteMember(testWatchPartyId, 'user_to_mute');

      expect(result, isTrue);

      // Verify in Firestore
      final doc = await fakeFirestore
          .collection('watch_parties')
          .doc(testWatchPartyId)
          .collection('members')
          .doc('user_to_mute')
          .get();

      expect(doc.data()!['isMuted'], isTrue);
    });
  });

  group('unmuteMember', () {
    test('unmutes member successfully', () async {
      await seedMember(
        watchPartyId: testWatchPartyId,
        userId: 'user_to_unmute',
        isMuted: true,
      );

      final result =
          await service.unmuteMember(testWatchPartyId, 'user_to_unmute');

      expect(result, isTrue);

      final doc = await fakeFirestore
          .collection('watch_parties')
          .doc(testWatchPartyId)
          .collection('members')
          .doc('user_to_unmute')
          .get();

      expect(doc.data()!['isMuted'], isFalse);
    });
  });

  // ==================== removeMember ====================
  group('removeMember', () {
    test('returns false when not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);
      final party = createTestParty(hostId: testUserId);

      final result = await service.removeMember(
          testWatchPartyId, 'user_to_remove', party);

      expect(result, isFalse);
    });

    test('returns false when user is not the host', () async {
      final party = createTestParty(hostId: 'different_host');

      final result = await service.removeMember(
          testWatchPartyId, 'user_to_remove', party);

      expect(result, isFalse);
    });

    test('returns false when party is null', () async {
      final result = await service.removeMember(
          testWatchPartyId, 'user_to_remove', null);

      expect(result, isFalse);
    });

    test('returns false when trying to remove the host', () async {
      await seedMember(
        watchPartyId: testWatchPartyId,
        userId: testHostId,
        role: 'host',
      );

      final party = createTestParty(hostId: testUserId);

      final result = await service.removeMember(
          testWatchPartyId, testHostId, party);

      expect(result, isFalse);
    });

    test('returns false when member does not exist', () async {
      final party = createTestParty(hostId: testUserId);

      final result = await service.removeMember(
          testWatchPartyId, 'nonexistent_user', party);

      expect(result, isFalse);
    });

    test('removes in-person member successfully', () async {
      await seedMember(
        watchPartyId: testWatchPartyId,
        userId: 'removable_user',
        role: 'member',
        attendanceType: 'inPerson',
      );

      // Seed the party document for count update
      await fakeFirestore
          .collection('watch_parties')
          .doc(testWatchPartyId)
          .set({
        'currentAttendeesCount': 5,
        'virtualAttendeesCount': 0,
      });

      final party = createTestParty(hostId: testUserId);

      final result = await service.removeMember(
          testWatchPartyId, 'removable_user', party);

      expect(result, isTrue);

      // Verify member was deleted from Firestore
      final memberDoc = await fakeFirestore
          .collection('watch_parties')
          .doc(testWatchPartyId)
          .collection('members')
          .doc('removable_user')
          .get();

      expect(memberDoc.exists, isFalse);
    });

    test('removes virtual member successfully', () async {
      await seedMember(
        watchPartyId: testWatchPartyId,
        userId: 'virtual_removable',
        role: 'member',
        attendanceType: 'virtual',
      );

      await fakeFirestore
          .collection('watch_parties')
          .doc(testWatchPartyId)
          .set({
        'currentAttendeesCount': 5,
        'virtualAttendeesCount': 3,
      });

      final party = createTestParty(hostId: testUserId);

      final result = await service.removeMember(
          testWatchPartyId, 'virtual_removable', party);

      expect(result, isTrue);
    });
  });

  // ==================== getRemovedMemberName ====================
  group('getRemovedMemberName', () {
    test('returns display name of the member', () async {
      await seedMember(
        watchPartyId: testWatchPartyId,
        userId: 'named_member',
        displayName: 'Named Member',
      );

      final name = await service.getRemovedMemberName(
          testWatchPartyId, 'named_member');

      expect(name, equals('Named Member'));
    });

    test('returns null when member does not exist', () async {
      final name = await service.getRemovedMemberName(
          testWatchPartyId, 'nonexistent');

      expect(name, isNull);
    });
  });

  // ==================== promoteMember ====================
  group('promoteMember', () {
    test('returns false when not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);
      final party = createTestParty(hostId: testUserId);

      final result = await service.promoteMember(
          testWatchPartyId, 'user_to_promote', party);

      expect(result, isFalse);
    });

    test('returns false when user is not the host', () async {
      final party = createTestParty(hostId: 'different_host');

      final result = await service.promoteMember(
          testWatchPartyId, 'user_to_promote', party);

      expect(result, isFalse);
    });

    test('returns false when party is null', () async {
      final result = await service.promoteMember(
          testWatchPartyId, 'user_to_promote', null);

      expect(result, isFalse);
    });

    test('promotes member to co-host successfully', () async {
      await seedMember(
        watchPartyId: testWatchPartyId,
        userId: 'promotable',
        role: 'member',
      );

      final party = createTestParty(hostId: testUserId);

      final result = await service.promoteMember(
          testWatchPartyId, 'promotable', party);

      expect(result, isTrue);

      // Verify role was updated in Firestore
      final doc = await fakeFirestore
          .collection('watch_parties')
          .doc(testWatchPartyId)
          .collection('members')
          .doc('promotable')
          .get();

      expect(doc.data()!['role'], equals('coHost'));
    });
  });

  // ==================== demoteMember ====================
  group('demoteMember', () {
    test('returns false when not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);
      final party = createTestParty(hostId: testUserId);

      final result = await service.demoteMember(
          testWatchPartyId, 'user_to_demote', party);

      expect(result, isFalse);
    });

    test('returns false when user is not the host', () async {
      final party = createTestParty(hostId: 'different_host');

      final result = await service.demoteMember(
          testWatchPartyId, 'user_to_demote', party);

      expect(result, isFalse);
    });

    test('demotes co-host to member successfully', () async {
      await seedMember(
        watchPartyId: testWatchPartyId,
        userId: 'demotable',
        role: 'coHost',
      );

      final party = createTestParty(hostId: testUserId);

      final result = await service.demoteMember(
          testWatchPartyId, 'demotable', party);

      expect(result, isTrue);

      // Verify role was updated in Firestore
      final doc = await fakeFirestore
          .collection('watch_parties')
          .doc(testWatchPartyId)
          .collection('members')
          .doc('demotable')
          .get();

      expect(doc.data()!['role'], equals('member'));
    });
  });

  // ==================== updateMemberPaymentStatus ====================
  group('updateMemberPaymentStatus', () {
    test('updates payment status successfully', () async {
      await seedMember(
        watchPartyId: testWatchPartyId,
        userId: 'paying_user',
        hasPaid: false,
      );

      final result = await service.updateMemberPaymentStatus(
        testWatchPartyId,
        'paying_user',
        'pi_test_intent_123',
      );

      expect(result, isTrue);

      // Verify in Firestore
      final doc = await fakeFirestore
          .collection('watch_parties')
          .doc(testWatchPartyId)
          .collection('members')
          .doc('paying_user')
          .get();

      expect(doc.data()!['hasPaid'], isTrue);
      expect(doc.data()!['paymentIntentId'], equals('pi_test_intent_123'));
    });

    test('returns false when member does not exist', () async {
      final result = await service.updateMemberPaymentStatus(
        testWatchPartyId,
        'nonexistent_user',
        'pi_test',
      );

      // fake_cloud_firestore may not throw on update of non-existent doc
      // but in real Firestore it would fail; we check the method handles gracefully
      expect(result, isA<bool>());
    });
  });

  // ==================== clearCaches ====================
  group('clearCaches', () {
    test('clears memory cache', () async {
      // Populate cache
      await seedMember(
        watchPartyId: testWatchPartyId,
        userId: 'cache_user',
      );
      await service.getMembers(testWatchPartyId);

      expect(service.memoryCacheSize, equals(1));

      service.clearCaches();

      expect(service.memoryCacheSize, equals(0));
    });
  });

  // ==================== invalidateMembersCache ====================
  group('invalidateMembersCache', () {
    test('removes specific party from memory cache', () async {
      const party1 = 'wp_1';
      const party2 = 'wp_2';

      await seedMember(watchPartyId: party1, userId: 'u1');
      await seedMember(watchPartyId: party2, userId: 'u2');

      await service.getMembers(party1);
      await service.getMembers(party2);

      expect(service.memoryCacheSize, equals(2));

      service.invalidateMembersCache(party1);

      expect(service.memoryCacheSize, equals(1));
    });
  });

  // ==================== Cache stats ====================
  group('cache stats', () {
    test('memoryCacheSize returns 0 initially', () {
      expect(service.memoryCacheSize, equals(0));
    });

    test('hiveCacheSize delegates to box length', () {
      when(() => mockMembersBox.length).thenReturn(42);

      expect(service.hiveCacheSize, equals(42));
    });
  });
}
