import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/messaging/domain/entities/chat.dart';
import 'package:pregame_world_cup/features/messaging/domain/services/messaging_group_management_service.dart';

// -- Mocks --
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MessagingGroupManagementService service;

  const testUserId = 'user_admin_123';
  const testUserName = 'Admin User';
  const chatsKey = 'user_chats';

  // Track system messages sent
  final sentSystemMessages = <Map<String, dynamic>>[];

  Chat chatFromFirestore(DocumentSnapshot doc) {
    final data = Map<String, dynamic>.from(doc.data() as Map);
    return Chat.fromJson({...data, 'chatId': doc.id});
  }

  Future<bool> mockSendSystemMessage({
    required String chatId,
    required String content,
    Map<String, dynamic>? metadata,
  }) async {
    sentSystemMessages.add({
      'chatId': chatId,
      'content': content,
      'metadata': metadata,
    });
    return true;
  }

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    sentSystemMessages.clear();

    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn(testUserId);
    when(() => mockUser.displayName).thenReturn(testUserName);

    service = MessagingGroupManagementService(
      firestore: fakeFirestore,
      auth: mockAuth,
      sendSystemMessage: mockSendSystemMessage,
      chatFromFirestore: chatFromFirestore,
      chatsKey: chatsKey,
    );
  });

  /// Helper to seed a group chat in Firestore.
  Future<void> seedGroupChat({
    required String chatId,
    List<String>? participantIds,
    List<String>? adminIds,
    String? createdBy,
  }) async {
    await fakeFirestore.collection('chats').doc(chatId).set({
      'chatId': chatId,
      'type': 'group',
      'participantIds': participantIds ?? [testUserId, 'user_2', 'user_3'],
      'adminIds': adminIds ?? [testUserId],
      'createdAt': DateTime.now().toIso8601String(),
      'isActive': true,
      'unreadCounts': <String, dynamic>{},
      'settings': <String, dynamic>{},
      'createdBy': createdBy ?? testUserId,
    });
  }

  /// Helper to seed a user document in Firestore.
  Future<void> seedUser({
    required String userId,
    String displayName = 'Test User',
    String? profileImageUrl,
  }) async {
    await fakeFirestore.collection('users').doc(userId).set({
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
    });
  }

  group('MessagingGroupManagementService', () {
    group('addMemberToChat', () {
      test('returns false when user is not authenticated', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = await service.addMemberToChat(
          'chat_1',
          'new_user',
          'New User',
        );

        expect(result, isFalse);
      });

      test('returns false when chat does not exist', () async {
        final result = await service.addMemberToChat(
          'nonexistent_chat',
          'new_user',
          'New User',
        );

        expect(result, isFalse);
      });

      test('returns false when current user is not admin', () async {
        await seedGroupChat(
          chatId: 'chat_no_admin',
          adminIds: ['other_admin'],
        );

        final result = await service.addMemberToChat(
          'chat_no_admin',
          'new_user',
          'New User',
        );

        expect(result, isFalse);
      });

      test('returns false when user is already a participant', () async {
        await seedGroupChat(chatId: 'chat_already_member');

        final result = await service.addMemberToChat(
          'chat_already_member',
          'user_2',
          'User 2',
        );

        expect(result, isFalse);
      });

      test('successfully adds a new member', () async {
        const chatId = 'chat_add_member';
        await seedGroupChat(chatId: chatId);

        // addMemberToChat writes to Firestore then calls CacheService.instance.remove()
        // which may fail in test environment (Hive not initialized).
        // We verify the Firestore write succeeded regardless.
        await service.addMemberToChat(
          chatId,
          'new_user_id',
          'New User Name',
        );

        // Verify Firestore was updated
        final chatDoc =
            await fakeFirestore.collection('chats').doc(chatId).get();
        final data = chatDoc.data()!;
        final participants = List<String>.from(data['participantIds']);
        final unreadCounts =
            Map<String, int>.from(data['unreadCounts'] ?? {});

        expect(participants, contains('new_user_id'));
        expect(unreadCounts['new_user_id'], equals(0));

        // Verify system message was sent
        expect(sentSystemMessages, isNotEmpty);
        expect(
          sentSystemMessages.last['content'],
          contains('added New User Name'),
        );
      });
    });

    group('removeMemberFromChat', () {
      test('returns false when user is not authenticated', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = await service.removeMemberFromChat(
          'chat_1',
          'user_2',
        );

        expect(result, isFalse);
      });

      test('returns false when chat does not exist', () async {
        final result = await service.removeMemberFromChat(
          'nonexistent_chat',
          'user_2',
        );

        expect(result, isFalse);
      });

      test('returns false when current user is not admin', () async {
        await seedGroupChat(
          chatId: 'chat_remove_no_admin',
          adminIds: ['other_admin'],
        );

        final result = await service.removeMemberFromChat(
          'chat_remove_no_admin',
          'user_2',
        );

        expect(result, isFalse);
      });

      test('returns false when trying to remove the chat creator', () async {
        await seedGroupChat(
          chatId: 'chat_remove_creator',
          createdBy: 'user_2',
        );

        final result = await service.removeMemberFromChat(
          'chat_remove_creator',
          'user_2',
        );

        expect(result, isFalse);
      });

      test('successfully removes a member', () async {
        const chatId = 'chat_remove_member';
        await seedGroupChat(
          chatId: chatId,
          participantIds: [testUserId, 'user_2', 'user_3'],
          adminIds: [testUserId, 'user_2'],
        );
        await seedUser(userId: 'user_3', displayName: 'User Three');

        // removeMemberFromChat writes to Firestore then calls CacheService.instance.remove()
        // which may fail in test environment. We verify the Firestore write succeeded.
        await service.removeMemberFromChat(chatId, 'user_3');

        // Verify Firestore was updated
        final chatDoc =
            await fakeFirestore.collection('chats').doc(chatId).get();
        final data = chatDoc.data()!;
        final participants = List<String>.from(data['participantIds']);

        expect(participants, isNot(contains('user_3')));

        // Verify system message was sent
        expect(sentSystemMessages, isNotEmpty);
        expect(
          sentSystemMessages.last['content'],
          contains('removed User Three'),
        );
      });

      test('removes member from both participants and admins', () async {
        const chatId = 'chat_remove_admin_member';
        await seedGroupChat(
          chatId: chatId,
          participantIds: [testUserId, 'user_2', 'user_3'],
          adminIds: [testUserId, 'user_3'],
        );
        await seedUser(userId: 'user_3', displayName: 'Admin User 3');

        // CacheService may fail in test env, but Firestore writes succeed
        await service.removeMemberFromChat(chatId, 'user_3');

        final chatDoc =
            await fakeFirestore.collection('chats').doc(chatId).get();
        final data = chatDoc.data()!;
        final admins = List<String>.from(data['adminIds']);
        final participants = List<String>.from(data['participantIds']);

        expect(participants, isNot(contains('user_3')));
        expect(admins, isNot(contains('user_3')));
      });
    });

    group('leaveChat', () {
      test('returns false when user is not authenticated', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = await service.leaveChat('chat_1');

        expect(result, isFalse);
      });

      test('returns false when chat does not exist', () async {
        final result = await service.leaveChat('nonexistent_chat');

        expect(result, isFalse);
      });

      test('returns false for direct chats', () async {
        const chatId = 'chat_direct_leave';
        await fakeFirestore.collection('chats').doc(chatId).set({
          'chatId': chatId,
          'type': 'direct',
          'participantIds': [testUserId, 'user_2'],
          'adminIds': <String>[],
          'createdAt': DateTime.now().toIso8601String(),
          'isActive': true,
          'unreadCounts': <String, dynamic>{},
          'settings': <String, dynamic>{},
        });

        final result = await service.leaveChat(chatId);

        expect(result, isFalse);
      });

      test('returns false when only admin with other members', () async {
        const chatId = 'chat_only_admin';
        await seedGroupChat(
          chatId: chatId,
          participantIds: [testUserId, 'user_2', 'user_3'],
          adminIds: [testUserId],
        );

        final result = await service.leaveChat(chatId);

        expect(result, isFalse);
      });

      test('successfully leaves a group chat', () async {
        const chatId = 'chat_leave_success';
        await seedGroupChat(
          chatId: chatId,
          participantIds: [testUserId, 'user_2', 'user_3'],
          adminIds: [testUserId, 'user_2'],
        );

        // CacheService may fail in test env, but Firestore writes succeed
        await service.leaveChat(chatId);

        // Verify user was removed
        final chatDoc =
            await fakeFirestore.collection('chats').doc(chatId).get();
        final data = chatDoc.data()!;
        final participants = List<String>.from(data['participantIds']);
        final admins = List<String>.from(data['adminIds']);

        expect(participants, isNot(contains(testUserId)));
        expect(admins, isNot(contains(testUserId)));

        // Verify system message
        expect(sentSystemMessages, isNotEmpty);
        expect(
          sentSystemMessages.last['content'],
          contains('left the group'),
        );
      });

      test('deactivates chat when last member leaves', () async {
        const chatId = 'chat_last_member';
        await seedGroupChat(
          chatId: chatId,
          participantIds: [testUserId],
          adminIds: [testUserId],
        );

        // CacheService may fail in test env, but Firestore writes succeed
        await service.leaveChat(chatId);

        final chatDoc =
            await fakeFirestore.collection('chats').doc(chatId).get();
        final data = chatDoc.data()!;

        expect(data['isActive'], isFalse);
      });

      test('allows non-admin to leave', () async {
        const chatId = 'chat_non_admin_leave';
        await seedGroupChat(
          chatId: chatId,
          participantIds: [testUserId, 'user_2', 'user_3'],
          adminIds: ['user_2'],
        );

        // CacheService may fail in test env, but Firestore writes succeed
        await service.leaveChat(chatId);

        // Verify user was removed from participants
        final chatDoc =
            await fakeFirestore.collection('chats').doc(chatId).get();
        final data = chatDoc.data()!;
        final participants = List<String>.from(data['participantIds']);

        expect(participants, isNot(contains(testUserId)));
      });
    });

    group('promoteToAdmin', () {
      test('returns false when user is not authenticated', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = await service.promoteToAdmin('chat_1', 'user_2');

        expect(result, isFalse);
      });

      test('returns false when chat does not exist', () async {
        final result =
            await service.promoteToAdmin('nonexistent_chat', 'user_2');

        expect(result, isFalse);
      });

      test('returns false when current user is not admin', () async {
        await seedGroupChat(
          chatId: 'chat_promote_no_admin',
          adminIds: ['other_admin'],
        );

        final result = await service.promoteToAdmin(
          'chat_promote_no_admin',
          'user_2',
        );

        expect(result, isFalse);
      });

      test('returns false when target is not a participant', () async {
        await seedGroupChat(
          chatId: 'chat_promote_non_participant',
          participantIds: [testUserId, 'user_2'],
        );

        final result = await service.promoteToAdmin(
          'chat_promote_non_participant',
          'user_not_in_chat',
        );

        expect(result, isFalse);
      });

      test('returns false when target is already admin', () async {
        await seedGroupChat(
          chatId: 'chat_promote_already_admin',
          participantIds: [testUserId, 'user_2'],
          adminIds: [testUserId, 'user_2'],
        );

        final result = await service.promoteToAdmin(
          'chat_promote_already_admin',
          'user_2',
        );

        expect(result, isFalse);
      });

      test('successfully promotes a member to admin', () async {
        const chatId = 'chat_promote_success';
        await seedGroupChat(
          chatId: chatId,
          participantIds: [testUserId, 'user_2', 'user_3'],
          adminIds: [testUserId],
        );
        await seedUser(userId: 'user_2', displayName: 'Promoted User');

        // CacheService may fail in test env, but Firestore writes succeed
        await service.promoteToAdmin(chatId, 'user_2');

        // Verify admin list was updated
        final chatDoc =
            await fakeFirestore.collection('chats').doc(chatId).get();
        final data = chatDoc.data()!;
        final admins = List<String>.from(data['adminIds']);

        expect(admins, contains('user_2'));

        // Verify system message
        expect(sentSystemMessages, isNotEmpty);
        expect(
          sentSystemMessages.last['content'],
          contains('made Promoted User an admin'),
        );
      });
    });

    group('demoteFromAdmin', () {
      test('returns false when user is not authenticated', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = await service.demoteFromAdmin('chat_1', 'user_2');

        expect(result, isFalse);
      });

      test('returns false when chat does not exist', () async {
        final result =
            await service.demoteFromAdmin('nonexistent_chat', 'user_2');

        expect(result, isFalse);
      });

      test('returns false when current user is not the creator', () async {
        await seedGroupChat(
          chatId: 'chat_demote_not_creator',
          adminIds: [testUserId, 'user_2'],
          createdBy: 'someone_else',
        );

        final result = await service.demoteFromAdmin(
          'chat_demote_not_creator',
          'user_2',
        );

        expect(result, isFalse);
      });

      test('returns false when trying to demote the creator', () async {
        await seedGroupChat(
          chatId: 'chat_demote_creator',
          adminIds: [testUserId, 'user_2'],
          createdBy: testUserId,
        );

        // Try to demote self (the creator)
        final result = await service.demoteFromAdmin(
          'chat_demote_creator',
          testUserId,
        );

        expect(result, isFalse);
      });

      test('returns false when target is not an admin', () async {
        await seedGroupChat(
          chatId: 'chat_demote_not_admin',
          participantIds: [testUserId, 'user_2', 'user_3'],
          adminIds: [testUserId],
          createdBy: testUserId,
        );

        final result = await service.demoteFromAdmin(
          'chat_demote_not_admin',
          'user_2',
        );

        expect(result, isFalse);
      });

      test('successfully demotes an admin', () async {
        const chatId = 'chat_demote_success';
        await seedGroupChat(
          chatId: chatId,
          participantIds: [testUserId, 'user_2', 'user_3'],
          adminIds: [testUserId, 'user_2'],
          createdBy: testUserId,
        );
        await seedUser(userId: 'user_2', displayName: 'Demoted User');

        // CacheService may fail in test env, but Firestore writes succeed
        await service.demoteFromAdmin(chatId, 'user_2');

        // Verify admin list was updated
        final chatDoc =
            await fakeFirestore.collection('chats').doc(chatId).get();
        final data = chatDoc.data()!;
        final admins = List<String>.from(data['adminIds']);

        expect(admins, isNot(contains('user_2')));
        expect(admins, contains(testUserId)); // Creator should remain

        // Verify system message
        expect(sentSystemMessages, isNotEmpty);
        expect(
          sentSystemMessages.last['content'],
          contains('removed Demoted User as admin'),
        );
      });
    });

    group('getChatMembers', () {
      test('returns empty list when chat does not exist', () async {
        final members = await service.getChatMembers('nonexistent_chat');

        expect(members, isEmpty);
      });

      test('returns member info for all participants', () async {
        const chatId = 'chat_members_test';
        await seedGroupChat(
          chatId: chatId,
          participantIds: [testUserId, 'user_2', 'user_3'],
          adminIds: [testUserId],
          createdBy: testUserId,
        );

        await seedUser(
          userId: testUserId,
          displayName: 'Creator Admin',
          profileImageUrl: 'https://example.com/creator.jpg',
        );
        await seedUser(userId: 'user_2', displayName: 'Regular Member');
        await seedUser(
          userId: 'user_3',
          displayName: 'Another Member',
          profileImageUrl: 'https://example.com/member3.jpg',
        );

        final members = await service.getChatMembers(chatId);

        expect(members.length, equals(3));

        // Creator should be first
        expect(members.first.userId, equals(testUserId));
        expect(members.first.isCreator, isTrue);
        expect(members.first.isAdmin, isTrue);
        expect(members.first.displayName, equals('Creator Admin'));
        expect(members.first.imageUrl, equals('https://example.com/creator.jpg'));
      });

      test('sorts members: creator, admins, then regular members', () async {
        const chatId = 'chat_members_sorted';
        await seedGroupChat(
          chatId: chatId,
          participantIds: [testUserId, 'user_2', 'user_3', 'user_4'],
          adminIds: [testUserId, 'user_3'],
          createdBy: testUserId,
        );

        await seedUser(userId: testUserId, displayName: 'Creator');
        await seedUser(userId: 'user_2', displayName: 'Zebra Member');
        await seedUser(userId: 'user_3', displayName: 'Admin Member');
        await seedUser(userId: 'user_4', displayName: 'Alpha Member');

        final members = await service.getChatMembers(chatId);

        expect(members.length, equals(4));
        // First: creator
        expect(members[0].isCreator, isTrue);
        // Second: admin (non-creator)
        expect(members[1].isAdmin, isTrue);
        expect(members[1].isCreator, isFalse);
        // Last two: regular members, sorted alphabetically
        expect(members[2].isAdmin, isFalse);
        expect(members[3].isAdmin, isFalse);
        expect(
          members[2].displayName.compareTo(members[3].displayName),
          lessThanOrEqualTo(0),
        );
      });

      test('skips participants without user documents', () async {
        const chatId = 'chat_members_missing_users';
        await seedGroupChat(
          chatId: chatId,
          participantIds: [testUserId, 'user_no_doc'],
          adminIds: [testUserId],
          createdBy: testUserId,
        );

        await seedUser(userId: testUserId, displayName: 'Existing User');
        // user_no_doc has no user document

        final members = await service.getChatMembers(chatId);

        // Only the user with a document should be returned
        expect(members.length, equals(1));
        expect(members.first.userId, equals(testUserId));
      });
    });
  });
}
