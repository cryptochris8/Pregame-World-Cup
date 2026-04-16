import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/messaging/domain/entities/chat.dart';
import 'package:pregame_world_cup/features/messaging/domain/entities/message.dart';
import 'package:pregame_world_cup/features/messaging/domain/services/messaging_serialization.dart';

void main() {
  // =========================================================================
  // ChatJson extension
  // =========================================================================
  group('ChatJson extension', () {
    group('toJson', () {
      test('serializes all Chat fields', () {
        final now = DateTime(2026, 3, 1, 12, 0, 0);
        final chat = Chat(
          chatId: 'chat_1',
          type: ChatType.group,
          name: 'Test Group',
          description: 'A group chat',
          imageUrl: 'https://example.com/group.jpg',
          participantIds: const ['user_1', 'user_2', 'user_3'],
          adminIds: const ['user_1'],
          createdAt: now,
          updatedAt: now,
          lastMessageId: 'msg_last',
          lastMessageContent: 'Last message',
          lastMessageTime: now,
          lastMessageSenderId: 'user_2',
          unreadCounts: const {'user_1': 3, 'user_3': 1},
          settings: const {'theme': 'dark'},
          isActive: true,
          createdBy: 'user_1',
        );

        final json = ChatJson(chat).toJson();

        expect(json['chatId'], equals('chat_1'));
        expect(json['type'], equals('group'));
        expect(json['name'], equals('Test Group'));
        expect(json['description'], equals('A group chat'));
        expect(json['imageUrl'], equals('https://example.com/group.jpg'));
        expect(json['participantIds'], equals(['user_1', 'user_2', 'user_3']));
        expect(json['adminIds'], equals(['user_1']));
        expect(json['createdAt'], equals('2026-03-01T12:00:00.000'));
        expect(json['updatedAt'], equals('2026-03-01T12:00:00.000'));
        expect(json['lastMessageId'], equals('msg_last'));
        expect(json['lastMessageContent'], equals('Last message'));
        expect(json['lastMessageTime'], equals('2026-03-01T12:00:00.000'));
        expect(json['lastMessageSenderId'], equals('user_2'));
        expect(json['unreadCounts'], equals({'user_1': 3, 'user_3': 1}));
        expect(json['settings'], equals({'theme': 'dark'}));
        expect(json['isActive'], isTrue);
        expect(json['createdBy'], equals('user_1'));
      });

      test('serializes null optional fields', () {
        final chat = Chat(
          chatId: 'chat_2',
          type: ChatType.direct,
          participantIds: const ['user_1', 'user_2'],
          adminIds: const [],
          createdAt: DateTime(2026, 1, 1),
        );

        final json = ChatJson(chat).toJson();

        expect(json['name'], isNull);
        expect(json['description'], isNull);
        expect(json['imageUrl'], isNull);
        expect(json['updatedAt'], isNull);
        expect(json['lastMessageId'], isNull);
        expect(json['lastMessageContent'], isNull);
        expect(json['lastMessageTime'], isNull);
        expect(json['lastMessageSenderId'], isNull);
        expect(json['createdBy'], isNull);
      });
    });

    group('fromJson', () {
      test('deserializes all Chat fields from JSON', () {
        final json = <String, dynamic>{
          'chatId': 'chat_deser',
          'type': 'team',
          'name': 'USA Fans',
          'description': 'Team chat',
          'imageUrl': 'https://example.com/usa.jpg',
          'participantIds': ['user_a', 'user_b'],
          'adminIds': ['user_a'],
          'createdAt': '2026-06-01T10:00:00.000',
          'updatedAt': '2026-06-01T11:00:00.000',
          'lastMessageId': 'msg_10',
          'lastMessageContent': 'Go USA!',
          'lastMessageTime': '2026-06-01T11:30:00.000',
          'lastMessageSenderId': 'user_b',
          'unreadCounts': {'user_a': 2},
          'settings': {'notifications': true},
          'isActive': true,
          'createdBy': 'user_a',
        };

        final chat = ChatJson.fromJson(json);

        expect(chat.chatId, equals('chat_deser'));
        expect(chat.type, equals(ChatType.team));
        expect(chat.name, equals('USA Fans'));
        expect(chat.description, equals('Team chat'));
        expect(chat.participantIds, equals(['user_a', 'user_b']));
        expect(chat.adminIds, equals(['user_a']));
        expect(chat.createdAt, equals(DateTime(2026, 6, 1, 10, 0)));
        expect(chat.updatedAt, equals(DateTime(2026, 6, 1, 11, 0)));
        expect(chat.isActive, isTrue);
        expect(chat.createdBy, equals('user_a'));
      });

      test('handles missing optional fields with defaults', () {
        final json = <String, dynamic>{
          'chatId': 'chat_minimal',
          'type': 'direct',
          'createdAt': '2026-01-01T00:00:00.000',
        };

        final chat = ChatJson.fromJson(json);

        expect(chat.chatId, equals('chat_minimal'));
        expect(chat.participantIds, isEmpty);
        expect(chat.adminIds, isEmpty);
        expect(chat.unreadCounts, isEmpty);
        expect(chat.settings, isEmpty);
        expect(chat.isActive, isTrue);
      });

      test('handles null updatedAt and lastMessageTime', () {
        final json = <String, dynamic>{
          'chatId': 'chat_nulls',
          'type': 'group',
          'createdAt': '2026-01-01T00:00:00.000',
          'updatedAt': null,
          'lastMessageTime': null,
        };

        final chat = ChatJson.fromJson(json);

        expect(chat.updatedAt, isNull);
        expect(chat.lastMessageTime, isNull);
      });
    });

    group('roundtrip', () {
      test('toJson then fromJson preserves direct chat', () {
        final original = Chat(
          chatId: 'dm_user1_user2',
          type: ChatType.direct,
          participantIds: const ['user1', 'user2'],
          adminIds: const [],
          createdAt: DateTime(2026, 3, 15, 8, 30),
          isActive: true,
        );

        final json = ChatJson(original).toJson();
        final restored = ChatJson.fromJson(json);

        expect(restored.chatId, equals(original.chatId));
        expect(restored.type, equals(original.type));
        expect(restored.participantIds, equals(original.participantIds));
        expect(restored.isActive, equals(original.isActive));
      });

      test('toJson then fromJson preserves group chat with all fields', () {
        final now = DateTime(2026, 6, 15, 14, 0);
        final original = Chat(
          chatId: 'group_123',
          type: ChatType.group,
          name: 'Full Group',
          description: 'Full fields test',
          imageUrl: 'https://example.com/full.jpg',
          participantIds: const ['a', 'b', 'c'],
          adminIds: const ['a'],
          createdAt: now,
          updatedAt: now,
          lastMessageId: 'msg_99',
          lastMessageContent: 'Hello all',
          lastMessageTime: now,
          lastMessageSenderId: 'b',
          unreadCounts: const {'a': 0, 'c': 5},
          settings: const {'pinned': true},
          isActive: true,
          createdBy: 'a',
        );

        final json = ChatJson(original).toJson();
        final restored = ChatJson.fromJson(json);

        expect(restored.chatId, equals(original.chatId));
        expect(restored.name, equals(original.name));
        expect(restored.description, equals(original.description));
        expect(restored.unreadCounts, equals(original.unreadCounts));
        expect(restored.settings, equals(original.settings));
        expect(restored.createdBy, equals(original.createdBy));
      });
    });
  });

  // =========================================================================
  // MessageJson extension
  // =========================================================================
  group('MessageJson extension', () {
    group('toJson', () {
      test('serializes all Message fields', () {
        final now = DateTime(2026, 3, 1, 12, 0, 0);
        final message = Message(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Test User',
          senderImageUrl: 'https://example.com/avatar.jpg',
          content: 'Hello world',
          type: MessageType.text,
          createdAt: now,
          updatedAt: now,
          status: MessageStatus.delivered,
          replyToMessageId: 'msg_0',
          reactions: [
            MessageReaction(userId: 'user_2', emoji: '👍', createdAt: now),
          ],
          metadata: const {'key': 'value'},
          isDeleted: false,
          readBy: const ['user_2'],
        );

        final json = MessageJson(message).toJson();

        expect(json['messageId'], equals('msg_1'));
        expect(json['chatId'], equals('chat_1'));
        expect(json['senderId'], equals('user_1'));
        expect(json['senderName'], equals('Test User'));
        expect(json['senderImageUrl'], equals('https://example.com/avatar.jpg'));
        expect(json['content'], equals('Hello world'));
        expect(json['type'], equals('text'));
        expect(json['createdAt'], equals('2026-03-01T12:00:00.000'));
        expect(json['updatedAt'], equals('2026-03-01T12:00:00.000'));
        expect(json['status'], equals('delivered'));
        expect(json['replyToMessageId'], equals('msg_0'));
        expect(json['reactions'], isList);
        expect((json['reactions'] as List).length, equals(1));
        expect(json['metadata'], equals({'key': 'value'}));
        expect(json['isDeleted'], isFalse);
        expect(json['readBy'], equals(['user_2']));
      });

      test('serializes system message correctly', () {
        final message = Message.system(
          chatId: 'chat_sys',
          content: 'User joined',
        );

        final json = MessageJson(message).toJson();

        expect(json['senderId'], equals('system'));
        expect(json['senderName'], equals('System'));
        expect(json['type'], equals('system'));
        expect(json['status'], equals('delivered'));
      });

      test('serializes voice message with metadata', () {
        final message = Message.voice(
          chatId: 'chat_voice',
          senderId: 'user_1',
          senderName: 'User One',
          audioUrl: 'https://example.com/audio.m4a',
          durationSeconds: 15,
          waveformData: const [0.1, 0.5, 0.8],
        );

        final json = MessageJson(message).toJson();

        expect(json['type'], equals('voice'));
        expect(json['metadata']['audioUrl'], equals('https://example.com/audio.m4a'));
        expect(json['metadata']['durationSeconds'], equals(15));
        expect(json['metadata']['waveformData'], equals([0.1, 0.5, 0.8]));
      });

      test('handles null optional fields', () {
        final message = Message(
          messageId: 'msg_null',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'User',
          content: 'Test',
          type: MessageType.text,
          createdAt: DateTime(2026, 1, 1),
          status: MessageStatus.sent,
        );

        final json = MessageJson(message).toJson();

        expect(json['senderImageUrl'], isNull);
        expect(json['updatedAt'], isNull);
        expect(json['replyToMessageId'], isNull);
      });
    });

    group('fromJson', () {
      test('deserializes all Message fields', () {
        final json = <String, dynamic>{
          'messageId': 'msg_deser',
          'chatId': 'chat_1',
          'senderId': 'user_1',
          'senderName': 'Test User',
          'senderImageUrl': 'https://example.com/img.jpg',
          'content': 'Deserialized',
          'type': 'image',
          'createdAt': '2026-06-01T10:00:00.000',
          'updatedAt': '2026-06-01T10:05:00.000',
          'status': 'read',
          'replyToMessageId': 'msg_prev',
          'reactions': [
            {
              'userId': 'user_2',
              'emoji': '❤️',
              'createdAt': '2026-06-01T10:01:00.000',
            }
          ],
          'metadata': {'imageUrl': 'https://example.com/photo.jpg'},
          'isDeleted': true,
          'readBy': ['user_2', 'user_3'],
        };

        final message = MessageJson.fromJson(json);

        expect(message.messageId, equals('msg_deser'));
        expect(message.chatId, equals('chat_1'));
        expect(message.type, equals(MessageType.image));
        expect(message.status, equals(MessageStatus.read));
        expect(message.replyToMessageId, equals('msg_prev'));
        expect(message.reactions.length, equals(1));
        expect(message.reactions.first.emoji, equals('❤️'));
        expect(message.isDeleted, isTrue);
        expect(message.readBy, equals(['user_2', 'user_3']));
      });

      test('handles missing optional fields with defaults', () {
        final json = <String, dynamic>{
          'messageId': 'msg_min',
          'chatId': 'chat_1',
          'senderId': 'user_1',
          'senderName': 'User',
          'content': 'Minimal',
          'type': 'text',
          'createdAt': '2026-01-01T00:00:00.000',
          'status': 'sent',
        };

        final message = MessageJson.fromJson(json);

        expect(message.senderImageUrl, isNull);
        expect(message.updatedAt, isNull);
        expect(message.replyToMessageId, isNull);
        expect(message.reactions, isEmpty);
        expect(message.metadata, isEmpty);
        expect(message.isDeleted, isFalse);
        expect(message.readBy, isEmpty);
      });

      test('handles empty reactions list', () {
        final json = <String, dynamic>{
          'messageId': 'msg_empty_react',
          'chatId': 'chat_1',
          'senderId': 'user_1',
          'senderName': 'User',
          'content': 'No reactions',
          'type': 'text',
          'createdAt': '2026-01-01T00:00:00.000',
          'status': 'sent',
          'reactions': <dynamic>[],
        };

        final message = MessageJson.fromJson(json);

        expect(message.reactions, isEmpty);
      });
    });

    group('roundtrip', () {
      test('toJson then fromJson preserves text message', () {
        final original = Message.text(
          chatId: 'chat_rt',
          senderId: 'user_1',
          senderName: 'User One',
          content: 'Roundtrip test',
          replyToMessageId: 'msg_original',
        );

        final json = MessageJson(original).toJson();
        final restored = MessageJson.fromJson(json);

        expect(restored.messageId, equals(original.messageId));
        expect(restored.chatId, equals(original.chatId));
        expect(restored.senderId, equals(original.senderId));
        expect(restored.content, equals(original.content));
        expect(restored.type, equals(original.type));
        expect(restored.replyToMessageId, equals(original.replyToMessageId));
      });

      test('toJson then fromJson preserves message with reactions', () {
        final now = DateTime(2026, 6, 1, 12, 0, 0);
        final original = Message(
          messageId: 'msg_react_rt',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'User',
          content: 'Reactions test',
          type: MessageType.text,
          createdAt: now,
          status: MessageStatus.sent,
          reactions: [
            MessageReaction(userId: 'u2', emoji: '👍', createdAt: now),
            MessageReaction(userId: 'u3', emoji: '❤️', createdAt: now),
          ],
        );

        final json = MessageJson(original).toJson();
        final restored = MessageJson.fromJson(json);

        expect(restored.reactions.length, equals(2));
        expect(restored.reactions[0].emoji, equals('👍'));
        expect(restored.reactions[1].emoji, equals('❤️'));
      });
    });
  });

  // =========================================================================
  // MessageReactionJson extension
  // =========================================================================
  group('MessageReactionJson extension', () {
    group('toJson', () {
      test('serializes all MessageReaction fields', () {
        final now = DateTime(2026, 3, 1, 12, 0, 0);
        final reaction = MessageReaction(
          userId: 'user_1',
          emoji: '🎉',
          createdAt: now,
        );

        final json = MessageReactionJson(reaction).toJson();

        expect(json['userId'], equals('user_1'));
        expect(json['emoji'], equals('🎉'));
        expect(json['createdAt'], equals('2026-03-01T12:00:00.000'));
      });
    });

    group('fromJson', () {
      test('deserializes MessageReaction from JSON', () {
        final json = <String, dynamic>{
          'userId': 'user_2',
          'emoji': '🔥',
          'createdAt': '2026-06-11T15:00:00.000',
        };

        final reaction = MessageReactionJson.fromJson(json);

        expect(reaction.userId, equals('user_2'));
        expect(reaction.emoji, equals('🔥'));
        expect(reaction.createdAt, equals(DateTime(2026, 6, 11, 15, 0)));
      });
    });

    group('roundtrip', () {
      test('toJson then fromJson preserves reaction', () {
        final now = DateTime(2026, 7, 4, 20, 0, 0);
        final original = MessageReaction(
          userId: 'user_react',
          emoji: '⚽',
          createdAt: now,
        );

        final json = MessageReactionJson(original).toJson();
        final restored = MessageReactionJson.fromJson(json);

        expect(restored.userId, equals(original.userId));
        expect(restored.emoji, equals(original.emoji));
        expect(restored.createdAt, equals(original.createdAt));
      });
    });
  });

  // =========================================================================
  // Cross-extension integration
  // =========================================================================
  group('Cross-extension integration', () {
    test('MessageJson reaction serialization uses MessageReactionJson', () {
      final now = DateTime(2026, 6, 1, 12, 0, 0);
      final message = Message(
        messageId: 'msg_cross',
        chatId: 'chat_1',
        senderId: 'user_1',
        senderName: 'User',
        content: 'Cross test',
        type: MessageType.text,
        createdAt: now,
        status: MessageStatus.sent,
        reactions: [
          MessageReaction(userId: 'u2', emoji: '👍', createdAt: now),
        ],
      );

      final json = MessageJson(message).toJson();
      final reactionJson = (json['reactions'] as List).first as Map<String, dynamic>;

      expect(reactionJson['userId'], equals('u2'));
      expect(reactionJson['emoji'], equals('👍'));
      expect(reactionJson['createdAt'], equals('2026-06-01T12:00:00.000'));
    });

    test('ChatJson handles all ChatType values', () {
      for (final chatType in ChatType.values) {
        final chat = Chat(
          chatId: 'chat_${chatType.name}',
          type: chatType,
          participantIds: const ['user_1'],
          adminIds: const [],
          createdAt: DateTime(2026, 1, 1),
        );

        final json = ChatJson(chat).toJson();
        final restored = ChatJson.fromJson(json);

        expect(restored.type, equals(chatType));
      }
    });

    test('MessageJson handles all MessageType values', () {
      for (final msgType in MessageType.values) {
        final message = Message(
          messageId: 'msg_${msgType.name}',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'User',
          content: 'Test',
          type: msgType,
          createdAt: DateTime(2026, 1, 1),
          status: MessageStatus.sent,
        );

        final json = MessageJson(message).toJson();
        final restored = MessageJson.fromJson(json);

        expect(restored.type, equals(msgType));
      }
    });

    test('MessageJson handles all MessageStatus values', () {
      for (final status in MessageStatus.values) {
        final message = Message(
          messageId: 'msg_${status.name}',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'User',
          content: 'Test',
          type: MessageType.text,
          createdAt: DateTime(2026, 1, 1),
          status: status,
        );

        final json = MessageJson(message).toJson();
        final restored = MessageJson.fromJson(json);

        expect(restored.status, equals(status));
      }
    });
  });

  // =========================================================================
  // firstWhere orElse fallback tests
  // =========================================================================
  group('Unknown enum value fallbacks', () {
    test('ChatJson.fromJson defaults to ChatType.direct for unknown type', () {
      final json = <String, dynamic>{
        'chatId': 'chat_unknown_type',
        'type': 'nonexistent_type',
        'createdAt': '2026-01-01T00:00:00.000',
      };

      final chat = ChatJson.fromJson(json);

      expect(chat.type, equals(ChatType.direct));
    });

    test('MessageJson.fromJson defaults to MessageType.text for unknown type', () {
      final json = <String, dynamic>{
        'messageId': 'msg_unknown_type',
        'chatId': 'chat_1',
        'senderId': 'user_1',
        'senderName': 'User',
        'content': 'Test',
        'type': 'nonexistent_type',
        'createdAt': '2026-01-01T00:00:00.000',
        'status': 'sent',
      };

      final message = MessageJson.fromJson(json);

      expect(message.type, equals(MessageType.text));
    });

    test('MessageJson.fromJson defaults to MessageStatus.sent for unknown status', () {
      final json = <String, dynamic>{
        'messageId': 'msg_unknown_status',
        'chatId': 'chat_1',
        'senderId': 'user_1',
        'senderName': 'User',
        'content': 'Test',
        'type': 'text',
        'createdAt': '2026-01-01T00:00:00.000',
        'status': 'nonexistent_status',
      };

      final message = MessageJson.fromJson(json);

      expect(message.status, equals(MessageStatus.sent));
    });

    test('ChatJson.fromJson defaults to ChatType.direct for null type', () {
      final json = <String, dynamic>{
        'chatId': 'chat_null_type',
        'type': null,
        'createdAt': '2026-01-01T00:00:00.000',
      };

      final chat = ChatJson.fromJson(json);

      expect(chat.type, equals(ChatType.direct));
    });

    test('MessageJson.fromJson defaults to MessageType.text for null type', () {
      final json = <String, dynamic>{
        'messageId': 'msg_null_type',
        'chatId': 'chat_1',
        'senderId': 'user_1',
        'senderName': 'User',
        'content': 'Test',
        'type': null,
        'createdAt': '2026-01-01T00:00:00.000',
        'status': 'sent',
      };

      final message = MessageJson.fromJson(json);

      expect(message.type, equals(MessageType.text));
    });

    test('MessageJson.fromJson defaults to MessageStatus.sent for null status', () {
      final json = <String, dynamic>{
        'messageId': 'msg_null_status',
        'chatId': 'chat_1',
        'senderId': 'user_1',
        'senderName': 'User',
        'content': 'Test',
        'type': 'text',
        'createdAt': '2026-01-01T00:00:00.000',
        'status': null,
      };

      final message = MessageJson.fromJson(json);

      expect(message.status, equals(MessageStatus.sent));
    });
  });

  // =========================================================================
  // DateTime null guard tests
  // =========================================================================
  group('DateTime null guard fallbacks', () {
    test('ChatJson.fromJson uses DateTime.now() for null createdAt', () {
      final before = DateTime.now();
      final json = <String, dynamic>{
        'chatId': 'chat_null_date',
        'type': 'direct',
        'createdAt': null,
      };

      final chat = ChatJson.fromJson(json);
      final after = DateTime.now();

      expect(chat.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(chat.createdAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });

    test('MessageJson.fromJson uses DateTime.now() for null createdAt', () {
      final before = DateTime.now();
      final json = <String, dynamic>{
        'messageId': 'msg_null_date',
        'chatId': 'chat_1',
        'senderId': 'user_1',
        'senderName': 'User',
        'content': 'Test',
        'type': 'text',
        'createdAt': null,
        'status': 'sent',
      };

      final message = MessageJson.fromJson(json);
      final after = DateTime.now();

      expect(message.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(message.createdAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });
  });
}
