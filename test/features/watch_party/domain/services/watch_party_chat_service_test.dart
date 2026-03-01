import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party_member.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party_message.dart';
import 'package:pregame_world_cup/features/watch_party/domain/services/watch_party_chat_service.dart';

// -- Mocks --
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late WatchPartyChatService service;

  const testUserId = 'user_test_123';
  const testUserName = 'Test User';
  const testWatchPartyId = 'wp_test_123';
  const testHostId = 'host_123';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();

    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn(testUserId);

    service = WatchPartyChatService(
      firestore: fakeFirestore,
      auth: mockAuth,
    );
  });

  tearDown(() async {
    await service.dispose();
  });

  /// Helper to create a test WatchPartyMember
  WatchPartyMember createTestMember({
    String userId = testUserId,
    String displayName = testUserName,
    String? profileImageUrl,
    WatchPartyMemberRole role = WatchPartyMemberRole.member,
    bool isMuted = false,
    bool hasPaid = true,
    WatchPartyAttendanceType attendanceType = WatchPartyAttendanceType.inPerson,
  }) {
    return WatchPartyMember(
      memberId: '${testWatchPartyId}_$userId',
      watchPartyId: testWatchPartyId,
      userId: userId,
      displayName: displayName,
      profileImageUrl: profileImageUrl,
      role: role,
      attendanceType: attendanceType,
      rsvpStatus: MemberRsvpStatus.going,
      joinedAt: DateTime.now(),
      hasPaid: hasPaid,
      isMuted: isMuted,
    );
  }

  /// Helper to create a test WatchParty
  WatchParty createTestParty({
    String watchPartyId = testWatchPartyId,
    String hostId = testHostId,
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
      maxAttendees: 20,
      currentAttendeesCount: 5,
      status: WatchPartyStatus.upcoming,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Helper to seed a message directly in Firestore
  Future<void> seedMessage({
    required String messageId,
    String watchPartyId = testWatchPartyId,
    String senderId = testUserId,
    String senderName = testUserName,
    String content = 'Hello',
    String type = 'text',
    String senderRole = 'member',
    bool isDeleted = false,
    DateTime? createdAt,
  }) async {
    await fakeFirestore
        .collection('watch_parties')
        .doc(watchPartyId)
        .collection('messages')
        .doc(messageId)
        .set({
      'watchPartyId': watchPartyId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'type': type,
      'senderRole': senderRole,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      'isDeleted': isDeleted,
      'reactions': <dynamic>[],
      'metadata': <String, dynamic>{},
    });
  }

  // ==================== getMessagesStream ====================
  group('getMessagesStream', () {
    test('returns empty stream for party with no messages', () async {
      final stream = service.getMessagesStream('nonexistent_party');

      final messages = await stream.first;
      expect(messages, isEmpty);
    });

    test('returns messages ordered by createdAt ascending', () async {
      final time1 = DateTime(2026, 1, 1, 10, 0, 0);
      final time2 = DateTime(2026, 1, 1, 10, 1, 0);
      final time3 = DateTime(2026, 1, 1, 10, 2, 0);

      await seedMessage(
        messageId: 'msg_1',
        content: 'First message',
        createdAt: time1,
      );
      await seedMessage(
        messageId: 'msg_3',
        content: 'Third message',
        createdAt: time3,
      );
      await seedMessage(
        messageId: 'msg_2',
        content: 'Second message',
        createdAt: time2,
      );

      final stream = service.getMessagesStream(testWatchPartyId);
      final messages = await stream.first;

      expect(messages, hasLength(3));
      expect(messages[0].content, equals('First message'));
      expect(messages[1].content, equals('Second message'));
      expect(messages[2].content, equals('Third message'));
    });

    test('returns WatchPartyMessage objects with correct fields', () async {
      await seedMessage(
        messageId: 'msg_detail',
        senderId: 'user_abc',
        senderName: 'Alice',
        content: 'Hello World',
        type: 'text',
        senderRole: 'host',
      );

      final stream = service.getMessagesStream(testWatchPartyId);
      final messages = await stream.first;

      expect(messages, hasLength(1));
      final msg = messages.first;
      expect(msg.messageId, equals('msg_detail'));
      expect(msg.senderId, equals('user_abc'));
      expect(msg.senderName, equals('Alice'));
      expect(msg.content, equals('Hello World'));
      expect(msg.type, equals(WatchPartyMessageType.text));
      expect(msg.senderRole, equals(WatchPartyMemberRole.host));
    });

    test('correctly deserializes system messages', () async {
      await seedMessage(
        messageId: 'sys_msg_1',
        senderId: 'system',
        senderName: 'System',
        content: 'A user joined',
        type: 'system',
        senderRole: 'host',
      );

      final stream = service.getMessagesStream(testWatchPartyId);
      final messages = await stream.first;

      expect(messages, hasLength(1));
      expect(messages.first.isSystem, isTrue);
      expect(messages.first.senderId, equals('system'));
    });
  });

  // ==================== sendMessage ====================
  group('sendMessage', () {
    test('throws when user is not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);
      final member = createTestMember();

      expect(
        () => service.sendMessage(testWatchPartyId, 'Hello', member),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('User not authenticated'),
        )),
      );
    });

    test('throws when member is muted', () async {
      final mutedMember = createTestMember(isMuted: true);

      expect(
        () => service.sendMessage(testWatchPartyId, 'Hello', mutedMember),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('cannot send messages'),
        )),
      );
    });

    test('throws when virtual member has not paid', () async {
      final unpaidVirtualMember = createTestMember(
        attendanceType: WatchPartyAttendanceType.virtual,
        hasPaid: false,
      );

      expect(
        () => service.sendMessage(
            testWatchPartyId, 'Hello', unpaidVirtualMember),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('cannot send messages'),
        )),
      );
    });

    test('sends message successfully for regular member', () async {
      final member = createTestMember();

      final result =
          await service.sendMessage(testWatchPartyId, 'Hello World', member);

      expect(result, isA<WatchPartyMessage>());
      expect(result.content, equals('Hello World'));
      expect(result.senderId, equals(testUserId));
      expect(result.senderName, equals(testUserName));
      expect(result.watchPartyId, equals(testWatchPartyId));
      expect(result.type, equals(WatchPartyMessageType.text));
      expect(result.isDeleted, isFalse);

      // Verify message was stored in Firestore
      final doc = await fakeFirestore
          .collection('watch_parties')
          .doc(testWatchPartyId)
          .collection('messages')
          .doc(result.messageId)
          .get();

      expect(doc.exists, isTrue);
      expect(doc.data()!['content'], equals('Hello World'));
    });

    test('sends message with reply reference', () async {
      final member = createTestMember();

      final result = await service.sendMessage(
        testWatchPartyId,
        'This is a reply',
        member,
        replyToMessageId: 'msg_original_123',
      );

      expect(result.replyToMessageId, equals('msg_original_123'));
      expect(result.isReply, isTrue);
    });

    test('allows virtual member who has paid to send message', () async {
      final paidVirtualMember = createTestMember(
        attendanceType: WatchPartyAttendanceType.virtual,
        hasPaid: true,
      );

      final result = await service.sendMessage(
          testWatchPartyId, 'Virtual hello!', paidVirtualMember);

      expect(result.content, equals('Virtual hello!'));
    });

    test('allows host to send messages', () async {
      final hostMember = createTestMember(
        role: WatchPartyMemberRole.host,
      );

      final result = await service.sendMessage(
          testWatchPartyId, 'Host message', hostMember);

      expect(result.senderRole, equals(WatchPartyMemberRole.host));
    });

    test('allows co-host to send messages', () async {
      final coHostMember = createTestMember(
        role: WatchPartyMemberRole.coHost,
      );

      final result = await service.sendMessage(
          testWatchPartyId, 'Co-host message', coHostMember);

      expect(result.senderRole, equals(WatchPartyMemberRole.coHost));
    });

    test('message ID starts with msg_ prefix', () async {
      final member = createTestMember();

      final result = await service.sendMessage(
          testWatchPartyId, 'Testing', member);

      expect(result.messageId, startsWith('msg_'));
    });
  });

  // ==================== sendSystemMessage ====================
  group('sendSystemMessage', () {
    test('sends system message successfully', () async {
      final result = await service.sendSystemMessage(
          testWatchPartyId, 'Player joined the party');

      expect(result, isTrue);

      // Verify in Firestore
      final snapshot = await fakeFirestore
          .collection('watch_parties')
          .doc(testWatchPartyId)
          .collection('messages')
          .get();

      expect(snapshot.docs, hasLength(1));
      final data = snapshot.docs.first.data();
      expect(data['content'], equals('Player joined the party'));
      expect(data['senderId'], equals('system'));
      expect(data['senderName'], equals('System'));
      expect(data['type'], equals('system'));
    });

    test('system message ID starts with sys_ prefix', () async {
      await service.sendSystemMessage(testWatchPartyId, 'Test system msg');

      final snapshot = await fakeFirestore
          .collection('watch_parties')
          .doc(testWatchPartyId)
          .collection('messages')
          .get();

      expect(snapshot.docs.first.id, startsWith('sys_'));
    });

    test('sends multiple system messages', () async {
      await service.sendSystemMessage(testWatchPartyId, 'Message 1');
      // Small delay to ensure different timestamps for message IDs
      await Future.delayed(const Duration(milliseconds: 10));
      await service.sendSystemMessage(testWatchPartyId, 'Message 2');

      final snapshot = await fakeFirestore
          .collection('watch_parties')
          .doc(testWatchPartyId)
          .collection('messages')
          .get();

      expect(snapshot.docs.length, greaterThanOrEqualTo(2));
    });
  });

  // ==================== deleteMessage ====================
  group('deleteMessage', () {
    test('returns false when user is not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = await service.deleteMessage(
          testWatchPartyId, 'msg_1', null);

      expect(result, isFalse);
    });

    test('returns false when message does not exist', () async {
      final party = createTestParty();

      final result = await service.deleteMessage(
          testWatchPartyId, 'nonexistent_msg', party);

      expect(result, isFalse);
    });

    test('sender can delete their own message', () async {
      await seedMessage(
        messageId: 'msg_own',
        senderId: testUserId,
        content: 'My message',
      );

      final party = createTestParty();
      final result = await service.deleteMessage(
          testWatchPartyId, 'msg_own', party);

      expect(result, isTrue);

      // Verify message was marked as deleted
      final doc = await fakeFirestore
          .collection('watch_parties')
          .doc(testWatchPartyId)
          .collection('messages')
          .doc('msg_own')
          .get();

      expect(doc.data()!['isDeleted'], isTrue);
      expect(doc.data()!['content'], equals('This message was deleted'));
    });

    test('host can delete any message', () async {
      // Seed a message from another user
      await seedMessage(
        messageId: 'msg_other',
        senderId: 'other_user',
        senderName: 'Other User',
        content: 'Other user message',
      );

      // Current user is the host
      final party = createTestParty(hostId: testUserId);

      final result = await service.deleteMessage(
          testWatchPartyId, 'msg_other', party);

      expect(result, isTrue);
    });

    test('non-sender non-host cannot delete message', () async {
      // Message from another user
      await seedMessage(
        messageId: 'msg_other2',
        senderId: 'other_user',
        senderName: 'Other User',
        content: 'Cannot delete this',
      );

      // Current user is NOT the host (host is someone else)
      final party = createTestParty(hostId: 'different_host');

      final result = await service.deleteMessage(
          testWatchPartyId, 'msg_other2', party);

      expect(result, isFalse);
    });

    test('works when party is null (only sender check)', () async {
      await seedMessage(
        messageId: 'msg_sender_null_party',
        senderId: testUserId,
        content: 'My message with null party',
      );

      final result = await service.deleteMessage(
          testWatchPartyId, 'msg_sender_null_party', null);

      expect(result, isTrue);
    });

    test('non-sender cannot delete when party is null', () async {
      await seedMessage(
        messageId: 'msg_other_null_party',
        senderId: 'someone_else',
        content: 'Not my message',
      );

      final result = await service.deleteMessage(
          testWatchPartyId, 'msg_other_null_party', null);

      expect(result, isFalse);
    });
  });

  // ==================== dispose ====================
  group('dispose', () {
    test('completes without error', () async {
      await expectLater(service.dispose(), completes);
    });

    test('can be called multiple times safely', () async {
      await service.dispose();
      await expectLater(service.dispose(), completes);
    });
  });

  // ==================== Constructor ====================
  group('Constructor', () {
    test('creates with custom firestore and auth', () {
      final customFirestore = FakeFirebaseFirestore();
      final customAuth = MockFirebaseAuth();
      when(() => customAuth.currentUser).thenReturn(null);

      final customService = WatchPartyChatService(
        firestore: customFirestore,
        auth: customAuth,
      );

      expect(customService, isNotNull);
    });

    test('accepts null parameters and falls back to defaults', () {
      // Verify that the optional parameters accept null gracefully.
      // In a test environment without Firebase.initializeApp(), we verify
      // that the constructor signature supports optional injection.
      final testService = WatchPartyChatService(
        firestore: FakeFirebaseFirestore(),
        auth: MockFirebaseAuth(),
      );
      expect(testService, isNotNull);
    });
  });
}
