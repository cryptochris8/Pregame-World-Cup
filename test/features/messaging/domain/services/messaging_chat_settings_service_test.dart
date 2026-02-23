import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/messaging/domain/entities/chat.dart';
import 'package:pregame_world_cup/features/messaging/domain/services/messaging_chat_settings_service.dart';

// -- Mocks --
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MessagingChatSettingsService service;

  const testUserId = 'user_settings_test';
  const chatsKey = 'user_chats';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();

    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn(testUserId);

    service = MessagingChatSettingsService(
      firestore: fakeFirestore,
      auth: mockAuth,
      chatsKey: chatsKey,
    );
  });

  group('MessagingChatSettingsService', () {
    group('muteChat', () {
      test('returns false when user is not authenticated', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = await service.muteChat('chat_1');

        expect(result, isFalse);
      });

      test('mutes chat forever by default', () async {
        const chatId = 'chat_mute_forever';

        final result = await service.muteChat(chatId);

        expect(result, isTrue);

        // Verify Firestore data
        final doc = await fakeFirestore
            .collection('user_chat_settings')
            .doc('${testUserId}_$chatId')
            .get();

        expect(doc.exists, isTrue);
        final data = doc.data()!;
        expect(data['isMuted'], isTrue);
        expect(data['muteUntil'], equals('forever'));
        expect(data['userId'], equals(testUserId));
        expect(data['chatId'], equals(chatId));
      });

      test('mutes chat with duration', () async {
        const chatId = 'chat_mute_duration';

        final result = await service.muteChat(
          chatId,
          duration: const Duration(hours: 8),
        );

        expect(result, isTrue);

        final doc = await fakeFirestore
            .collection('user_chat_settings')
            .doc('${testUserId}_$chatId')
            .get();

        final data = doc.data()!;
        expect(data['isMuted'], isTrue);
        expect(data['muteUntil'], isNot(equals('forever')));

        // The muteUntil should be a valid ISO string in the future
        final muteUntil = DateTime.parse(data['muteUntil'] as String);
        expect(muteUntil.isAfter(DateTime.now()), isTrue);
      });
    });

    group('unmuteChat', () {
      test('returns false when user is not authenticated', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = await service.unmuteChat('chat_1');

        expect(result, isFalse);
      });

      test('unmutes a muted chat', () async {
        const chatId = 'chat_unmute_test';

        // First mute the chat
        await service.muteChat(chatId);

        // Then unmute it
        final result = await service.unmuteChat(chatId);

        expect(result, isTrue);

        final doc = await fakeFirestore
            .collection('user_chat_settings')
            .doc('${testUserId}_$chatId')
            .get();

        final data = doc.data()!;
        expect(data['isMuted'], isFalse);
        expect(data['muteUntil'], isNull);
      });
    });

    group('isChatMuted', () {
      test('returns false when user is not authenticated', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = await service.isChatMuted('chat_1');

        expect(result, isFalse);
      });

      test('returns false when no settings exist', () async {
        final result = await service.isChatMuted('chat_no_settings');

        expect(result, isFalse);
      });

      test('returns true for muted chat (forever)', () async {
        const chatId = 'chat_muted_forever_check';
        await service.muteChat(chatId);

        final result = await service.isChatMuted(chatId);

        expect(result, isTrue);
      });

      test('returns true for muted chat within duration', () async {
        const chatId = 'chat_muted_duration_check';
        await service.muteChat(
          chatId,
          duration: const Duration(hours: 24),
        );

        final result = await service.isChatMuted(chatId);

        expect(result, isTrue);
      });

      test('returns false for expired mute duration', () async {
        const chatId = 'chat_expired_mute';

        // Manually set an expired mute time
        final expiredTime =
            DateTime.now().subtract(const Duration(hours: 1)).toIso8601String();

        await fakeFirestore
            .collection('user_chat_settings')
            .doc('${testUserId}_$chatId')
            .set({
          'userId': testUserId,
          'chatId': chatId,
          'isMuted': true,
          'muteUntil': expiredTime,
        });

        final result = await service.isChatMuted(chatId);

        expect(result, isFalse);
      });

      test('returns false for unmuted chat', () async {
        const chatId = 'chat_not_muted';
        await service.muteChat(chatId);
        await service.unmuteChat(chatId);

        final result = await service.isChatMuted(chatId);

        expect(result, isFalse);
      });
    });

    group('archiveChat', () {
      test('returns false when user is not authenticated', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = await service.archiveChat('chat_1');

        expect(result, isFalse);
      });

      test('writes archive data to Firestore', () async {
        const chatId = 'chat_archive_test';

        // archiveChat writes to Firestore then calls CacheService.instance.remove()
        // which may fail in test environment (Hive not initialized).
        // We verify the Firestore write succeeded regardless.
        await service.archiveChat(chatId);

        final doc = await fakeFirestore
            .collection('user_chat_settings')
            .doc('${testUserId}_$chatId')
            .get();

        expect(doc.exists, isTrue);
        final data = doc.data()!;
        expect(data['isArchived'], isTrue);
        expect(data['archivedAt'], isNotNull);
        expect(data['userId'], equals(testUserId));
        expect(data['chatId'], equals(chatId));
      });
    });

    group('unarchiveChat', () {
      test('returns false when user is not authenticated', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = await service.unarchiveChat('chat_1');

        expect(result, isFalse);
      });

      test('writes unarchive data to Firestore', () async {
        const chatId = 'chat_unarchive_test';

        // First manually seed the archived state
        await fakeFirestore
            .collection('user_chat_settings')
            .doc('${testUserId}_$chatId')
            .set({
          'userId': testUserId,
          'chatId': chatId,
          'isArchived': true,
          'archivedAt': DateTime.now().toIso8601String(),
        });

        // unarchiveChat may return false due to CacheService in test env
        await service.unarchiveChat(chatId);

        final doc = await fakeFirestore
            .collection('user_chat_settings')
            .doc('${testUserId}_$chatId')
            .get();

        final data = doc.data()!;
        expect(data['isArchived'], isFalse);
      });
    });

    group('isChatArchived', () {
      test('returns false when user is not authenticated', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = await service.isChatArchived('chat_1');

        expect(result, isFalse);
      });

      test('returns false when no settings exist', () async {
        final result = await service.isChatArchived('chat_no_settings');

        expect(result, isFalse);
      });

      test('returns true for archived chat', () async {
        const chatId = 'chat_archived_check';
        await service.archiveChat(chatId);

        final result = await service.isChatArchived(chatId);

        expect(result, isTrue);
      });

      test('returns false for unarchived chat', () async {
        const chatId = 'chat_unarchived_check';
        await service.archiveChat(chatId);
        await service.unarchiveChat(chatId);

        final result = await service.isChatArchived(chatId);

        expect(result, isFalse);
      });
    });

    group('getChatSettings', () {
      test('returns default settings when user is not authenticated', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final settings = await service.getChatSettings('chat_1');

        expect(settings.isMuted, isFalse);
        expect(settings.isArchived, isFalse);
      });

      test('returns default settings when no settings exist', () async {
        final settings =
            await service.getChatSettings('chat_no_settings');

        expect(settings.isMuted, isFalse);
        expect(settings.isArchived, isFalse);
        expect(settings.muteUntil, isNull);
      });

      test('returns correct settings for muted and archived chat', () async {
        const chatId = 'chat_full_settings';
        await service.muteChat(chatId);
        await service.archiveChat(chatId);

        final settings = await service.getChatSettings(chatId);

        expect(settings.isMuted, isTrue);
        expect(settings.isArchived, isTrue);
        expect(settings.muteUntil, equals('forever'));
      });

      test('returns muted-forever correctly', () async {
        const chatId = 'chat_settings_forever';
        await service.muteChat(chatId);

        final settings = await service.getChatSettings(chatId);

        expect(settings.isMutedForever, isTrue);
        expect(settings.muteDuration, isNull);
      });
    });

    group('deleteChat', () {
      test('returns false when user is not authenticated', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = await service.deleteChat('chat_1');

        expect(result, isFalse);
      });

      test('writes delete data to Firestore', () async {
        const chatId = 'chat_delete_test';

        // deleteChat may return false due to CacheService in test env
        await service.deleteChat(chatId);

        final doc = await fakeFirestore
            .collection('user_chat_settings')
            .doc('${testUserId}_$chatId')
            .get();

        expect(doc.exists, isTrue);
        final data = doc.data()!;
        expect(data['isDeleted'], isTrue);
        expect(data['deletedAt'], isNotNull);
        expect(data['userId'], equals(testUserId));
        expect(data['chatId'], equals(chatId));
      });
    });

    group('clearChatHistory', () {
      test('returns false when user is not authenticated', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = await service.clearChatHistory(
          'chat_1',
          'chat_messages_',
        );

        expect(result, isFalse);
      });

      test('writes clearedAt timestamp to Firestore', () async {
        const chatId = 'chat_clear_test';

        // clearChatHistory may return false due to CacheService in test env
        await service.clearChatHistory(chatId, 'chat_messages_');

        final doc = await fakeFirestore
            .collection('user_chat_settings')
            .doc('${testUserId}_$chatId')
            .get();

        expect(doc.exists, isTrue);
        final data = doc.data()!;
        expect(data['clearedAt'], isNotNull);

        // Verify the clearedAt is a valid ISO timestamp
        final clearedAt = DateTime.parse(data['clearedAt'] as String);
        expect(clearedAt.isBefore(DateTime.now().add(const Duration(seconds: 1))),
            isTrue);
      });
    });

    group('getChatClearedAt', () {
      test('returns null when user is not authenticated', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = await service.getChatClearedAt('chat_1');

        expect(result, isNull);
      });

      test('returns null when no settings exist', () async {
        final result = await service.getChatClearedAt('chat_no_settings');

        expect(result, isNull);
      });

      test('returns correct DateTime after clearing', () async {
        const chatId = 'chat_cleared_at_test';

        final beforeClear = DateTime.now();
        await service.clearChatHistory(chatId, 'chat_messages_');
        final afterClear = DateTime.now();

        final clearedAt = await service.getChatClearedAt(chatId);

        expect(clearedAt, isNotNull);
        expect(clearedAt!.isAfter(beforeClear.subtract(const Duration(seconds: 1))),
            isTrue);
        expect(clearedAt.isBefore(afterClear.add(const Duration(seconds: 1))),
            isTrue);
      });
    });

    group('getChatBlockStatus', () {
      test('returns not blocked when user is not authenticated', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final chat = Chat(
          chatId: 'chat_block_check',
          type: ChatType.direct,
          participantIds: const [testUserId, 'user_other'],
          adminIds: const [],
          createdAt: DateTime.now(),
        );

        final status = await service.getChatBlockStatus(chat);

        expect(status.isBlocked, isFalse);
      });

      test('returns not blocked for group chats', () async {
        final chat = Chat(
          chatId: 'chat_group_block',
          type: ChatType.group,
          participantIds: const [testUserId, 'user_other', 'user_3'],
          adminIds: const [testUserId],
          createdAt: DateTime.now(),
        );

        final status = await service.getChatBlockStatus(chat);

        expect(status.isBlocked, isFalse);
      });

      test('returns not blocked for team chats', () async {
        final chat = Chat(
          chatId: 'chat_team_block',
          type: ChatType.team,
          participantIds: const [testUserId, 'user_other'],
          adminIds: const [testUserId],
          createdAt: DateTime.now(),
        );

        final status = await service.getChatBlockStatus(chat);

        expect(status.isBlocked, isFalse);
      });
    });
  });

  group('ChatSettings', () {
    test('isMutedForever returns true when muteUntil is forever', () {
      const settings = ChatSettings(
        isMuted: true,
        isArchived: false,
        muteUntil: 'forever',
      );

      expect(settings.isMutedForever, isTrue);
    });

    test('isMutedForever returns false when muteUntil is a date', () {
      final settings = ChatSettings(
        isMuted: true,
        isArchived: false,
        muteUntil: DateTime.now()
            .add(const Duration(hours: 1))
            .toIso8601String(),
      );

      expect(settings.isMutedForever, isFalse);
    });

    test('muteDuration returns null when muteUntil is null', () {
      const settings = ChatSettings(
        isMuted: false,
        isArchived: false,
      );

      expect(settings.muteDuration, isNull);
    });

    test('muteDuration returns null when muteUntil is forever', () {
      const settings = ChatSettings(
        isMuted: true,
        isArchived: false,
        muteUntil: 'forever',
      );

      expect(settings.muteDuration, isNull);
    });

    test('muteDuration returns remaining time for future mute', () {
      final futureTime =
          DateTime.now().add(const Duration(hours: 2)).toIso8601String();
      final settings = ChatSettings(
        isMuted: true,
        isArchived: false,
        muteUntil: futureTime,
      );

      final duration = settings.muteDuration;
      expect(duration, isNotNull);
      // Should be approximately 2 hours (allow some margin)
      expect(duration!.inMinutes, greaterThan(115));
      expect(duration.inMinutes, lessThanOrEqualTo(120));
    });

    test('muteDuration returns null for expired mute', () {
      final pastTime =
          DateTime.now().subtract(const Duration(hours: 1)).toIso8601String();
      final settings = ChatSettings(
        isMuted: true,
        isArchived: false,
        muteUntil: pastTime,
      );

      expect(settings.muteDuration, isNull);
    });
  });

  group('BlockStatus', () {
    test('default constructor sets isBlocked and defaults', () {
      const status = BlockStatus(isBlocked: false);

      expect(status.isBlocked, isFalse);
      expect(status.blockedByCurrentUser, isFalse);
      expect(status.message, isNull);
    });

    test('blocked by current user', () {
      const status = BlockStatus(
        isBlocked: true,
        blockedByCurrentUser: true,
        message: 'You blocked this user',
      );

      expect(status.isBlocked, isTrue);
      expect(status.blockedByCurrentUser, isTrue);
      expect(status.message, equals('You blocked this user'));
    });

    test('blocked by other user', () {
      const status = BlockStatus(
        isBlocked: true,
        blockedByCurrentUser: false,
        message: 'You cannot message this user',
      );

      expect(status.isBlocked, isTrue);
      expect(status.blockedByCurrentUser, isFalse);
      expect(status.message, equals('You cannot message this user'));
    });
  });

  group('ChatMemberInfo', () {
    test('creates with required fields', () {
      const info = ChatMemberInfo(
        userId: 'user_1',
        displayName: 'John Doe',
      );

      expect(info.userId, equals('user_1'));
      expect(info.displayName, equals('John Doe'));
      expect(info.imageUrl, isNull);
      expect(info.isAdmin, isFalse);
      expect(info.isCreator, isFalse);
    });

    test('creates with all fields', () {
      const info = ChatMemberInfo(
        userId: 'user_1',
        displayName: 'John Doe',
        imageUrl: 'https://example.com/avatar.jpg',
        isAdmin: true,
        isCreator: true,
      );

      expect(info.imageUrl, equals('https://example.com/avatar.jpg'));
      expect(info.isAdmin, isTrue);
      expect(info.isCreator, isTrue);
    });
  });
}
