import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/messaging/domain/entities/chat.dart';
import 'package:pregame_world_cup/features/messaging/domain/entities/message.dart';

void main() {
  group('Chat', () {
    group('Constructor', () {
      test('creates chat with required fields', () {
        final now = DateTime.now();
        final chat = Chat(
          chatId: 'chat_1',
          type: ChatType.direct,
          participantIds: const ['user_1', 'user_2'],
          adminIds: const [],
          createdAt: now,
        );

        expect(chat.chatId, equals('chat_1'));
        expect(chat.type, equals(ChatType.direct));
        expect(chat.participantIds, hasLength(2));
        expect(chat.adminIds, isEmpty);
        expect(chat.isActive, isTrue);
        expect(chat.unreadCounts, isEmpty);
      });

      test('creates chat with optional fields', () {
        final now = DateTime.now();
        final chat = Chat(
          chatId: 'chat_1',
          type: ChatType.group,
          participantIds: const ['user_1', 'user_2', 'user_3'],
          adminIds: const ['user_1'],
          name: 'Test Group',
          description: 'A test group chat',
          imageUrl: 'https://example.com/group.jpg',
          createdAt: now,
          lastMessageContent: 'Last message',
          lastMessageTime: now,
          unreadCounts: const {'user_2': 5},
          settings: const {'muted': true},
          createdBy: 'user_1',
        );

        expect(chat.name, equals('Test Group'));
        expect(chat.description, equals('A test group chat'));
        expect(chat.imageUrl, equals('https://example.com/group.jpg'));
        expect(chat.lastMessageContent, equals('Last message'));
        expect(chat.unreadCounts['user_2'], equals(5));
        expect(chat.settings['muted'], isTrue);
        expect(chat.createdBy, equals('user_1'));
      });
    });

    group('Factory constructors', () {
      test('Chat.direct creates direct message chat', () {
        final chat = Chat.direct(
          participantUserId: 'user_2',
          currentUserId: 'user_1',
        );

        expect(chat.chatId, startsWith('direct_'));
        expect(chat.type, equals(ChatType.direct));
        expect(chat.participantIds, hasLength(2));
        expect(chat.participantIds, contains('user_1'));
        expect(chat.participantIds, contains('user_2'));
        expect(chat.adminIds, isEmpty);
        expect(chat.isActive, isTrue);
        expect(chat.isDirectMessage, isTrue);
      });

      test('Chat.direct creates consistent chat ID regardless of user order', () {
        final chat1 = Chat.direct(
          participantUserId: 'user_2',
          currentUserId: 'user_1',
        );

        final chat2 = Chat.direct(
          participantUserId: 'user_1',
          currentUserId: 'user_2',
        );

        expect(chat1.chatId, equals(chat2.chatId));
      });

      test('Chat.group creates group chat', () {
        final chat = Chat.group(
          name: 'Game Day Crew',
          creatorId: 'user_1',
          participantIds: const ['user_2', 'user_3'],
          description: 'Friends for game day',
          imageUrl: 'https://example.com/group.jpg',
        );

        expect(chat.chatId, startsWith('group_'));
        expect(chat.type, equals(ChatType.group));
        expect(chat.name, equals('Game Day Crew'));
        expect(chat.description, equals('Friends for game day'));
        expect(chat.participantIds, hasLength(3));
        expect(chat.participantIds, contains('user_1'));
        expect(chat.adminIds, equals(['user_1']));
        expect(chat.createdBy, equals('user_1'));
        expect(chat.isGroupChat, isTrue);
      });

      test('Chat.group does not duplicate creator in participants', () {
        final chat = Chat.group(
          name: 'Test Group',
          creatorId: 'user_1',
          participantIds: const ['user_1', 'user_2', 'user_3'],
        );

        expect(chat.participantIds.where((id) => id == 'user_1').length, equals(1));
      });

      test('Chat.team creates team chat', () {
        final chat = Chat.team(
          teamName: 'Georgia Bulldogs Fan Group',
          creatorId: 'user_1',
          memberIds: const ['user_2', 'user_3', 'user_4'],
          description: 'Go Dawgs!',
        );

        expect(chat.chatId, startsWith('team_'));
        expect(chat.type, equals(ChatType.team));
        expect(chat.name, equals('Georgia Bulldogs Fan Group'));
        expect(chat.participantIds, hasLength(4));
        expect(chat.adminIds, equals(['user_1']));
        expect(chat.isTeamChat, isTrue);
      });
    });

    group('copyWith', () {
      test('copies chat with new name', () {
        final chat = Chat.group(
          name: 'Old Name',
          creatorId: 'user_1',
          participantIds: const ['user_2'],
        );

        final updated = chat.copyWith(name: 'New Name');

        expect(updated.name, equals('New Name'));
        expect(updated.chatId, equals(chat.chatId));
        expect(updated.type, equals(chat.type));
      });

      test('copies chat with multiple changes', () {
        final now = DateTime.now();
        final chat = Chat.group(
          name: 'Test Group',
          creatorId: 'user_1',
          participantIds: const ['user_2'],
        );

        final updated = chat.copyWith(
          name: 'Updated Group',
          description: 'New description',
          lastMessageContent: 'Hello!',
          lastMessageTime: now,
          isActive: false,
        );

        expect(updated.name, equals('Updated Group'));
        expect(updated.description, equals('New description'));
        expect(updated.lastMessageContent, equals('Hello!'));
        expect(updated.lastMessageTime, equals(now));
        expect(updated.isActive, isFalse);
      });
    });

    group('Message operations', () {
      test('updateLastMessage updates chat with message info', () {
        final chat = Chat.group(
          name: 'Test Group',
          creatorId: 'user_1',
          participantIds: const ['user_2'],
        );

        final message = Message.text(
          chatId: chat.chatId,
          senderId: 'user_1',
          senderName: 'Test User',
          content: 'Hello everyone!',
        );

        final updated = chat.updateLastMessage(message);

        expect(updated.lastMessageId, equals(message.messageId));
        expect(updated.lastMessageContent, equals('Hello everyone!'));
        expect(updated.lastMessageSenderId, equals('user_1'));
        expect(updated.updatedAt, isNotNull);
      });

      test('updateLastMessage shows photo emoji for image messages', () {
        final chat = Chat.group(
          name: 'Test Group',
          creatorId: 'user_1',
          participantIds: const ['user_2'],
        );

        final message = Message.image(
          chatId: chat.chatId,
          senderId: 'user_1',
          senderName: 'Test User',
          imageUrl: 'https://example.com/image.jpg',
        );

        final updated = chat.updateLastMessage(message);

        expect(updated.lastMessageContent, contains('Photo'));
      });
    });

    group('Unread counts', () {
      test('incrementUnreadCount increases count for user', () {
        final chat = Chat.group(
          name: 'Test Group',
          creatorId: 'user_1',
          participantIds: const ['user_2'],
        );

        final updated = chat.incrementUnreadCount('user_2');

        expect(updated.getUnreadCount('user_2'), equals(1));
      });

      test('incrementUnreadCount does not increment for sender', () {
        final now = DateTime.now();
        final chat = Chat(
          chatId: 'chat_1',
          type: ChatType.group,
          participantIds: const ['user_1', 'user_2'],
          adminIds: const ['user_1'],
          createdAt: now,
          lastMessageSenderId: 'user_1',
        );

        final updated = chat.incrementUnreadCount('user_1');

        expect(updated.getUnreadCount('user_1'), equals(0));
      });

      test('markAsRead removes user from unread counts', () {
        final now = DateTime.now();
        final chat = Chat(
          chatId: 'chat_1',
          type: ChatType.group,
          participantIds: const ['user_1', 'user_2'],
          adminIds: const ['user_1'],
          createdAt: now,
          unreadCounts: const {'user_2': 5},
        );

        final updated = chat.markAsRead('user_2');

        expect(updated.getUnreadCount('user_2'), equals(0));
        expect(updated.unreadCounts.containsKey('user_2'), isFalse);
      });

      test('hasUnreadMessages returns true when counts exist', () {
        final now = DateTime.now();
        final chat = Chat(
          chatId: 'chat_1',
          type: ChatType.group,
          participantIds: const ['user_1', 'user_2'],
          adminIds: const [],
          createdAt: now,
          unreadCounts: const {'user_2': 3},
        );

        expect(chat.hasUnreadMessages, isTrue);
      });
    });

    group('Participant management', () {
      test('addParticipant adds new user', () {
        final chat = Chat.group(
          name: 'Test Group',
          creatorId: 'user_1',
          participantIds: const ['user_2'],
        );

        final updated = chat.addParticipant('user_3');

        expect(updated.participantIds, hasLength(3));
        expect(updated.participantIds, contains('user_3'));
        expect(updated.updatedAt, isNotNull);
      });

      test('addParticipant does not duplicate existing user', () {
        final chat = Chat.group(
          name: 'Test Group',
          creatorId: 'user_1',
          participantIds: const ['user_2'],
        );

        final updated = chat.addParticipant('user_2');

        expect(updated.participantIds.where((id) => id == 'user_2').length, equals(1));
      });

      test('removeParticipant removes user from participants and admins', () {
        final now = DateTime.now();
        final chat = Chat(
          chatId: 'chat_1',
          type: ChatType.group,
          participantIds: const ['user_1', 'user_2', 'user_3'],
          adminIds: const ['user_1', 'user_2'],
          createdAt: now,
        );

        final updated = chat.removeParticipant('user_2');

        expect(updated.participantIds, hasLength(2));
        expect(updated.participantIds, isNot(contains('user_2')));
        expect(updated.adminIds, isNot(contains('user_2')));
      });

      test('isParticipant returns true for participants', () {
        final chat = Chat.group(
          name: 'Test Group',
          creatorId: 'user_1',
          participantIds: const ['user_2'],
        );

        expect(chat.isParticipant('user_1'), isTrue);
        expect(chat.isParticipant('user_2'), isTrue);
        expect(chat.isParticipant('user_3'), isFalse);
      });
    });

    group('Admin management', () {
      test('addAdmin promotes participant to admin', () {
        final chat = Chat.group(
          name: 'Test Group',
          creatorId: 'user_1',
          participantIds: const ['user_2', 'user_3'],
        );

        final updated = chat.addAdmin('user_2');

        expect(updated.adminIds, hasLength(2));
        expect(updated.adminIds, contains('user_2'));
      });

      test('addAdmin does not add non-participant as admin', () {
        final chat = Chat.group(
          name: 'Test Group',
          creatorId: 'user_1',
          participantIds: const ['user_2'],
        );

        final updated = chat.addAdmin('user_3');

        expect(updated.adminIds, hasLength(1));
        expect(updated.adminIds, isNot(contains('user_3')));
      });

      test('addAdmin does not duplicate existing admin', () {
        final chat = Chat.group(
          name: 'Test Group',
          creatorId: 'user_1',
          participantIds: const ['user_2'],
        );

        final updated = chat.addAdmin('user_1');

        expect(updated.adminIds.where((id) => id == 'user_1').length, equals(1));
      });

      test('removeAdmin demotes admin to regular participant', () {
        final now = DateTime.now();
        final chat = Chat(
          chatId: 'chat_1',
          type: ChatType.group,
          participantIds: const ['user_1', 'user_2'],
          adminIds: const ['user_1', 'user_2'],
          createdAt: now,
        );

        final updated = chat.removeAdmin('user_2');

        expect(updated.adminIds, hasLength(1));
        expect(updated.adminIds, isNot(contains('user_2')));
        expect(updated.participantIds, contains('user_2'));
      });

      test('isAdmin returns true for admins', () {
        final chat = Chat.group(
          name: 'Test Group',
          creatorId: 'user_1',
          participantIds: const ['user_2'],
        );

        expect(chat.isAdmin('user_1'), isTrue);
        expect(chat.isAdmin('user_2'), isFalse);
      });
    });

    group('Helper getters', () {
      test('isDirectMessage returns true for direct chats', () {
        final chat = Chat.direct(
          participantUserId: 'user_2',
          currentUserId: 'user_1',
        );

        expect(chat.isDirectMessage, isTrue);
        expect(chat.isGroupChat, isFalse);
        expect(chat.isTeamChat, isFalse);
      });

      test('isGroupChat returns true for group chats', () {
        final chat = Chat.group(
          name: 'Test',
          creatorId: 'user_1',
          participantIds: const ['user_2'],
        );

        expect(chat.isGroupChat, isTrue);
        expect(chat.isDirectMessage, isFalse);
      });

      test('isTeamChat returns true for team chats', () {
        final chat = Chat.team(
          teamName: 'Georgia Fans',
          creatorId: 'user_1',
          memberIds: const ['user_2'],
        );

        expect(chat.isTeamChat, isTrue);
        expect(chat.isGroupChat, isFalse);
      });

      test('lastMessage getter returns lastMessageContent', () {
        final now = DateTime.now();
        final chat = Chat(
          chatId: 'chat_1',
          type: ChatType.direct,
          participantIds: const ['user_1', 'user_2'],
          adminIds: const [],
          createdAt: now,
          lastMessageContent: 'Hello!',
        );

        expect(chat.lastMessage, equals('Hello!'));
      });

      test('lastMessagePreview truncates long messages', () {
        final now = DateTime.now();
        const longMessage = 'This is a very long message that exceeds fifty characters and should be truncated';
        final chat = Chat(
          chatId: 'chat_1',
          type: ChatType.direct,
          participantIds: const ['user_1', 'user_2'],
          adminIds: const [],
          createdAt: now,
          lastMessageContent: longMessage,
        );

        expect(chat.lastMessagePreview.length, lessThanOrEqualTo(53)); // 50 + "..."
        expect(chat.lastMessagePreview, endsWith('...'));
      });

      test('lastMessagePreview returns placeholder for no messages', () {
        final chat = Chat.group(
          name: 'Test',
          creatorId: 'user_1',
          participantIds: const ['user_2'],
        );

        expect(chat.lastMessagePreview, equals('No messages yet'));
      });
    });

    group('timeAgo', () {
      test('returns empty string when no last message time', () {
        final chat = Chat.group(
          name: 'Test',
          creatorId: 'user_1',
          participantIds: const ['user_2'],
        );

        expect(chat.timeAgo, isEmpty);
      });

      test('returns "now" for recent messages', () {
        final now = DateTime.now();
        final chat = Chat(
          chatId: 'chat_1',
          type: ChatType.direct,
          participantIds: const ['user_1', 'user_2'],
          adminIds: const [],
          createdAt: now,
          lastMessageTime: now,
        );

        expect(chat.timeAgo, equals('now'));
      });

      test('returns minutes for messages within an hour', () {
        final now = DateTime.now();
        final chat = Chat(
          chatId: 'chat_1',
          type: ChatType.direct,
          participantIds: const ['user_1', 'user_2'],
          adminIds: const [],
          createdAt: now,
          lastMessageTime: now.subtract(const Duration(minutes: 15)),
        );

        expect(chat.timeAgo, equals('15m'));
      });

      test('returns hours for messages within a day', () {
        final now = DateTime.now();
        final chat = Chat(
          chatId: 'chat_1',
          type: ChatType.direct,
          participantIds: const ['user_1', 'user_2'],
          adminIds: const [],
          createdAt: now,
          lastMessageTime: now.subtract(const Duration(hours: 3)),
        );

        expect(chat.timeAgo, equals('3h'));
      });

      test('returns days for messages within a week', () {
        final now = DateTime.now();
        final chat = Chat(
          chatId: 'chat_1',
          type: ChatType.direct,
          participantIds: const ['user_1', 'user_2'],
          adminIds: const [],
          createdAt: now,
          lastMessageTime: now.subtract(const Duration(days: 5)),
        );

        expect(chat.timeAgo, equals('5d'));
      });

      test('returns date format for older messages', () {
        final now = DateTime.now();
        final oldDate = now.subtract(const Duration(days: 10));
        final chat = Chat(
          chatId: 'chat_1',
          type: ChatType.direct,
          participantIds: const ['user_1', 'user_2'],
          adminIds: const [],
          createdAt: now,
          lastMessageTime: oldDate,
        );

        expect(chat.timeAgo, contains('/'));
      });
    });

    group('JSON serialization', () {
      test('toJson serializes chat correctly', () {
        final now = DateTime(2024, 1, 15, 12, 0, 0);
        final chat = Chat(
          chatId: 'chat_1',
          type: ChatType.group,
          participantIds: const ['user_1', 'user_2'],
          adminIds: const ['user_1'],
          name: 'Test Group',
          description: 'A test group',
          createdAt: now,
          lastMessageContent: 'Hello!',
          unreadCounts: const {'user_2': 3},
          isActive: true,
          createdBy: 'user_1',
        );

        final json = chat.toJson();

        expect(json['chatId'], equals('chat_1'));
        expect(json['type'], equals('group'));
        expect(json['participantIds'], equals(['user_1', 'user_2']));
        expect(json['adminIds'], equals(['user_1']));
        expect(json['name'], equals('Test Group'));
        expect(json['createdAt'], equals('2024-01-15T12:00:00.000'));
        expect(json['lastMessage'], equals('Hello!'));
        expect(json['unreadCounts']['user_2'], equals(3));
        expect(json['isActive'], isTrue);
      });

      test('fromJson deserializes chat correctly', () {
        final json = <String, dynamic>{
          'chatId': 'chat_1',
          'type': 'group',
          'participantIds': <dynamic>['user_1', 'user_2'],
          'adminIds': <dynamic>['user_1'],
          'name': 'Test Group',
          'description': 'A test group',
          'createdAt': '2024-01-15T12:00:00.000',
          'lastMessage': 'Hello!',
          'unreadCounts': <String, dynamic>{'user_2': 3},
          'isActive': true,
          'createdBy': 'user_1',
        };

        final chat = Chat.fromJson(json);

        expect(chat.chatId, equals('chat_1'));
        expect(chat.type, equals(ChatType.group));
        expect(chat.participantIds, hasLength(2));
        expect(chat.adminIds, equals(['user_1']));
        expect(chat.name, equals('Test Group'));
        expect(chat.lastMessageContent, equals('Hello!'));
        expect(chat.getUnreadCount('user_2'), equals(3));
      });

      test('roundtrip serialization preserves data', () {
        final now = DateTime(2024, 1, 15, 12, 0, 0);
        final original = Chat(
          chatId: 'chat_1',
          type: ChatType.team,
          participantIds: const ['user_1', 'user_2', 'user_3'],
          adminIds: const ['user_1'],
          name: 'Team Chat',
          description: 'Go team!',
          createdAt: now,
          lastMessageContent: 'Score!',
          lastMessageTime: now,
          unreadCounts: const {'user_2': 1, 'user_3': 2},
          isActive: true,
          createdBy: 'user_1',
        );

        final json = original.toJson();
        final restored = Chat.fromJson(json);

        expect(restored.chatId, equals(original.chatId));
        expect(restored.type, equals(original.type));
        expect(restored.participantIds.length, equals(original.participantIds.length));
        expect(restored.name, equals(original.name));
      });
    });

    group('Equatable', () {
      test('two chats with same props are equal', () {
        final now = DateTime(2024, 1, 15, 12, 0, 0);
        final chat1 = Chat(
          chatId: 'chat_1',
          type: ChatType.direct,
          participantIds: const ['user_1', 'user_2'],
          adminIds: const [],
          createdAt: now,
        );

        final chat2 = Chat(
          chatId: 'chat_1',
          type: ChatType.direct,
          participantIds: const ['user_1', 'user_2'],
          adminIds: const [],
          createdAt: now,
        );

        expect(chat1, equals(chat2));
      });

      test('two chats with different ids are not equal', () {
        final now = DateTime.now();
        final chat1 = Chat(
          chatId: 'chat_1',
          type: ChatType.direct,
          participantIds: const ['user_1', 'user_2'],
          adminIds: const [],
          createdAt: now,
        );

        final chat2 = Chat(
          chatId: 'chat_2',
          type: ChatType.direct,
          participantIds: const ['user_1', 'user_2'],
          adminIds: const [],
          createdAt: now,
        );

        expect(chat1, isNot(equals(chat2)));
      });
    });
  });

  group('ChatType', () {
    test('contains all expected types', () {
      expect(ChatType.values, contains(ChatType.direct));
      expect(ChatType.values, contains(ChatType.group));
      expect(ChatType.values, contains(ChatType.team));
      expect(ChatType.values, contains(ChatType.event));
    });
  });

  group('ChatMember', () {
    test('creates chat member with required fields', () {
      final now = DateTime.now();
      final member = ChatMember(
        userId: 'user_1',
        displayName: 'Test User',
        role: ChatMemberRole.member,
        joinedAt: now,
      );

      expect(member.userId, equals('user_1'));
      expect(member.displayName, equals('Test User'));
      expect(member.role, equals(ChatMemberRole.member));
      expect(member.joinedAt, equals(now));
      expect(member.isOnline, isFalse);
    });

    test('creates chat member with optional fields', () {
      final now = DateTime.now();
      final member = ChatMember(
        userId: 'user_1',
        displayName: 'Test User',
        imageUrl: 'https://example.com/avatar.jpg',
        role: ChatMemberRole.admin,
        joinedAt: now,
        lastSeenAt: now,
        isOnline: true,
      );

      expect(member.imageUrl, equals('https://example.com/avatar.jpg'));
      expect(member.role, equals(ChatMemberRole.admin));
      expect(member.lastSeenAt, equals(now));
      expect(member.isOnline, isTrue);
    });

    test('copyWith updates specified fields', () {
      final now = DateTime.now();
      final member = ChatMember(
        userId: 'user_1',
        displayName: 'Test User',
        role: ChatMemberRole.member,
        joinedAt: now,
      );

      final updated = member.copyWith(
        displayName: 'Updated Name',
        role: ChatMemberRole.admin,
        isOnline: true,
      );

      expect(updated.userId, equals('user_1'));
      expect(updated.displayName, equals('Updated Name'));
      expect(updated.role, equals(ChatMemberRole.admin));
      expect(updated.isOnline, isTrue);
      expect(updated.joinedAt, equals(now));
    });

    test('two members with same props are equal', () {
      final now = DateTime(2024, 1, 15, 12, 0, 0);
      final member1 = ChatMember(
        userId: 'user_1',
        displayName: 'Test User',
        role: ChatMemberRole.member,
        joinedAt: now,
      );

      final member2 = ChatMember(
        userId: 'user_1',
        displayName: 'Test User',
        role: ChatMemberRole.member,
        joinedAt: now,
      );

      expect(member1, equals(member2));
    });
  });

  group('ChatMemberRole', () {
    test('contains all expected roles', () {
      expect(ChatMemberRole.values, contains(ChatMemberRole.member));
      expect(ChatMemberRole.values, contains(ChatMemberRole.admin));
      expect(ChatMemberRole.values, contains(ChatMemberRole.owner));
    });
  });
}
