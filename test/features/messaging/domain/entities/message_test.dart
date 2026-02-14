import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/messaging/domain/entities/message.dart';

void main() {
  group('Message', () {
    group('Constructor', () {
      test('creates message with required fields', () {
        final now = DateTime.now();
        final message = Message(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Test User',
          content: 'Hello world',
          type: MessageType.text,
          createdAt: now,
          status: MessageStatus.sent,
        );

        expect(message.messageId, equals('msg_1'));
        expect(message.chatId, equals('chat_1'));
        expect(message.senderId, equals('user_1'));
        expect(message.senderName, equals('Test User'));
        expect(message.content, equals('Hello world'));
        expect(message.type, equals(MessageType.text));
        expect(message.status, equals(MessageStatus.sent));
        expect(message.reactions, isEmpty);
        expect(message.metadata, isEmpty);
        expect(message.isDeleted, isFalse);
        expect(message.readBy, isEmpty);
      });

      test('creates message with optional fields', () {
        final now = DateTime.now();
        final reactions = [
          MessageReaction(userId: 'user_2', emoji: '👍', createdAt: now),
        ];

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
          status: MessageStatus.read,
          replyToMessageId: 'msg_0',
          reactions: reactions,
          metadata: const {'key': 'value'},
          isDeleted: true,
          readBy: const ['user_2'],
        );

        expect(message.senderImageUrl, equals('https://example.com/avatar.jpg'));
        expect(message.updatedAt, equals(now));
        expect(message.replyToMessageId, equals('msg_0'));
        expect(message.reactions.length, equals(1));
        expect(message.metadata['key'], equals('value'));
        expect(message.isDeleted, isTrue);
        expect(message.readBy, contains('user_2'));
      });
    });

    group('Factory constructors', () {
      test('Message.text creates text message', () {
        final message = Message.text(
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Test User',
          content: 'Hello world',
        );

        expect(message.messageId, startsWith('chat_1_'));
        expect(message.type, equals(MessageType.text));
        expect(message.status, equals(MessageStatus.sent));
        expect(message.content, equals('Hello world'));
      });

      test('Message.text with reply creates text message with reply', () {
        final message = Message.text(
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Test User',
          content: 'Reply text',
          replyToMessageId: 'msg_original',
        );

        expect(message.replyToMessageId, equals('msg_original'));
        expect(message.isReply, isTrue);
      });

      test('Message.image creates image message', () {
        final message = Message.image(
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Test User',
          imageUrl: 'https://example.com/image.jpg',
          caption: 'A beautiful photo',
        );

        expect(message.type, equals(MessageType.image));
        expect(message.content, equals('A beautiful photo'));
        expect(message.metadata['imageUrl'], equals('https://example.com/image.jpg'));
      });

      test('Message.image without caption has empty content', () {
        final message = Message.image(
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Test User',
          imageUrl: 'https://example.com/image.jpg',
        );

        expect(message.content, isEmpty);
      });

      test('Message.system creates system message', () {
        final message = Message.system(
          chatId: 'chat_1',
          content: 'User joined the chat',
        );

        expect(message.senderId, equals('system'));
        expect(message.senderName, equals('System'));
        expect(message.type, equals(MessageType.system));
        expect(message.status, equals(MessageStatus.delivered));
        expect(message.isSystemMessage, isTrue);
      });

      test('Message.voice creates voice message', () {
        final message = Message.voice(
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Test User',
          audioUrl: 'https://example.com/audio.mp3',
          durationSeconds: 30,
          waveformData: const [0.1, 0.5, 0.8, 0.3],
        );

        expect(message.type, equals(MessageType.voice));
        expect(message.content, equals('Voice message 30s'));
        expect(message.metadata['audioUrl'], equals('https://example.com/audio.mp3'));
        expect(message.metadata['durationSeconds'], equals(30));
        expect(message.metadata['waveformData'], equals([0.1, 0.5, 0.8, 0.3]));
      });

      test('Message.video creates video message', () {
        final message = Message.video(
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Test User',
          videoUrl: 'https://example.com/video.mp4',
          thumbnailUrl: 'https://example.com/thumb.jpg',
          durationSeconds: 120,
          width: 1920,
          height: 1080,
          fileSizeBytes: 5000000,
          caption: 'Check this out!',
        );

        expect(message.type, equals(MessageType.video));
        expect(message.content, equals('Check this out!'));
        expect(message.metadata['videoUrl'], equals('https://example.com/video.mp4'));
        expect(message.metadata['thumbnailUrl'], equals('https://example.com/thumb.jpg'));
        expect(message.metadata['durationSeconds'], equals(120));
        expect(message.metadata['width'], equals(1920));
        expect(message.metadata['height'], equals(1080));
        expect(message.metadata['fileSizeBytes'], equals(5000000));
      });

      test('Message.file creates file message', () {
        final message = Message.file(
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Test User',
          fileName: 'document.pdf',
          fileUrl: 'https://example.com/document.pdf',
          fileType: 'pdf',
          fileSizeBytes: 1024000,
          mimeType: 'application/pdf',
        );

        expect(message.type, equals(MessageType.file));
        expect(message.content, equals('File: document.pdf'));
        expect(message.metadata['fileName'], equals('document.pdf'));
        expect(message.metadata['fileUrl'], equals('https://example.com/document.pdf'));
        expect(message.metadata['fileType'], equals('pdf'));
        expect(message.metadata['fileSizeBytes'], equals(1024000));
        expect(message.metadata['mimeType'], equals('application/pdf'));
      });
    });

    group('copyWith', () {
      test('copies message with new status', () {
        final message = Message.text(
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Test User',
          content: 'Hello',
        );

        final updated = message.copyWith(status: MessageStatus.delivered);

        expect(updated.status, equals(MessageStatus.delivered));
        expect(updated.content, equals('Hello'));
        expect(updated.messageId, equals(message.messageId));
      });

      test('copies message with multiple changes', () {
        final now = DateTime.now();
        final message = Message.text(
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Test User',
          content: 'Hello',
        );

        final reactions = [
          MessageReaction(userId: 'user_2', emoji: '❤️', createdAt: now),
        ];

        final updated = message.copyWith(
          status: MessageStatus.read,
          updatedAt: now,
          reactions: reactions,
          isDeleted: true,
          readBy: ['user_2', 'user_3'],
        );

        expect(updated.status, equals(MessageStatus.read));
        expect(updated.updatedAt, equals(now));
        expect(updated.reactions.length, equals(1));
        expect(updated.isDeleted, isTrue);
        expect(updated.readBy.length, equals(2));
      });
    });

    group('markAsRead', () {
      test('marks message as read and adds user to readBy', () {
        final message = Message.text(
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Test User',
          content: 'Hello',
        );

        final read = message.markAsRead('user_2');

        expect(read.status, equals(MessageStatus.read));
        expect(read.readBy, contains('user_2'));
      });

      test('does not duplicate user in readBy', () {
        final message = Message(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Test User',
          content: 'Hello',
          type: MessageType.text,
          createdAt: DateTime.now(),
          status: MessageStatus.sent,
          readBy: const ['user_2'],
        );

        final read = message.markAsRead('user_2');

        expect(read.readBy.where((id) => id == 'user_2').length, equals(1));
      });
    });

    group('Reactions', () {
      test('addReaction adds reaction to message', () {
        final message = Message.text(
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Test User',
          content: 'Hello',
        );

        final withReaction = message.addReaction('user_2', '👍');

        expect(withReaction.reactions.length, equals(1));
        expect(withReaction.reactions.first.userId, equals('user_2'));
        expect(withReaction.reactions.first.emoji, equals('👍'));
        expect(withReaction.hasReactions, isTrue);
      });

      test('addReaction replaces existing reaction from same user', () {
        final now = DateTime.now();
        final message = Message(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Test User',
          content: 'Hello',
          type: MessageType.text,
          createdAt: now,
          status: MessageStatus.sent,
          reactions: [
            MessageReaction(userId: 'user_2', emoji: '👍', createdAt: now),
          ],
        );

        final updated = message.addReaction('user_2', '❤️');

        expect(updated.reactions.length, equals(1));
        expect(updated.reactions.first.emoji, equals('❤️'));
      });

      test('removeReaction removes reaction from user', () {
        final now = DateTime.now();
        final message = Message(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Test User',
          content: 'Hello',
          type: MessageType.text,
          createdAt: now,
          status: MessageStatus.sent,
          reactions: [
            MessageReaction(userId: 'user_2', emoji: '👍', createdAt: now),
            MessageReaction(userId: 'user_3', emoji: '❤️', createdAt: now),
          ],
        );

        final updated = message.removeReaction('user_2');

        expect(updated.reactions.length, equals(1));
        expect(updated.reactions.first.userId, equals('user_3'));
      });
    });

    group('Helper getters', () {
      test('isRead returns true when status is read', () {
        final message = Message(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Test User',
          content: 'Hello',
          type: MessageType.text,
          createdAt: DateTime.now(),
          status: MessageStatus.read,
        );

        expect(message.isRead, isTrue);
        expect(message.isDelivered, isFalse);
        expect(message.isSent, isFalse);
      });

      test('isDelivered returns true when status is delivered', () {
        final message = Message(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Test User',
          content: 'Hello',
          type: MessageType.text,
          createdAt: DateTime.now(),
          status: MessageStatus.delivered,
        );

        expect(message.isDelivered, isTrue);
      });

      test('isSent returns true when status is sent', () {
        final message = Message.text(
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Test User',
          content: 'Hello',
        );

        expect(message.isSent, isTrue);
      });

      test('isReply returns true when replyToMessageId is set', () {
        final message = Message.text(
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Test User',
          content: 'Hello',
          replyToMessageId: 'msg_original',
        );

        expect(message.isReply, isTrue);
      });

      test('hasReactions returns true when reactions exist', () {
        final now = DateTime.now();
        final message = Message(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Test User',
          content: 'Hello',
          type: MessageType.text,
          createdAt: now,
          status: MessageStatus.sent,
          reactions: [
            MessageReaction(userId: 'user_2', emoji: '👍', createdAt: now),
          ],
        );

        expect(message.hasReactions, isTrue);
      });
    });

    group('timeAgo', () {
      test('returns "now" for recent messages', () {
        final message = Message(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Test User',
          content: 'Hello',
          type: MessageType.text,
          createdAt: DateTime.now(),
          status: MessageStatus.sent,
        );

        expect(message.timeAgo, equals('now'));
      });

      test('returns minutes for messages within an hour', () {
        final message = Message(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Test User',
          content: 'Hello',
          type: MessageType.text,
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          status: MessageStatus.sent,
        );

        expect(message.timeAgo, equals('30m'));
      });

      test('returns hours for messages within a day', () {
        final message = Message(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Test User',
          content: 'Hello',
          type: MessageType.text,
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          status: MessageStatus.sent,
        );

        expect(message.timeAgo, equals('5h'));
      });

      test('returns days for older messages', () {
        final message = Message(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Test User',
          content: 'Hello',
          type: MessageType.text,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          status: MessageStatus.sent,
        );

        expect(message.timeAgo, equals('3d'));
      });
    });

    group('JSON serialization', () {
      test('toJson serializes message correctly', () {
        final now = DateTime(2024, 1, 15, 12, 0, 0);
        final message = Message(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Test User',
          senderImageUrl: 'https://example.com/avatar.jpg',
          content: 'Hello world',
          type: MessageType.text,
          createdAt: now,
          status: MessageStatus.sent,
          metadata: const {'key': 'value'},
          readBy: const ['user_2'],
        );

        final json = message.toJson();

        expect(json['messageId'], equals('msg_1'));
        expect(json['chatId'], equals('chat_1'));
        expect(json['senderId'], equals('user_1'));
        expect(json['senderName'], equals('Test User'));
        expect(json['senderImageUrl'], equals('https://example.com/avatar.jpg'));
        expect(json['content'], equals('Hello world'));
        expect(json['type'], equals('text'));
        expect(json['createdAt'], equals('2024-01-15T12:00:00.000'));
        expect(json['status'], equals('sent'));
        expect(json['metadata']['key'], equals('value'));
        expect(json['readBy'], equals(['user_2']));
      });

      test('fromJson deserializes message correctly', () {
        final json = <String, dynamic>{
          'messageId': 'msg_1',
          'chatId': 'chat_1',
          'senderId': 'user_1',
          'senderName': 'Test User',
          'senderImageUrl': 'https://example.com/avatar.jpg',
          'content': 'Hello world',
          'type': 'text',
          'createdAt': '2024-01-15T12:00:00.000',
          'status': 'sent',
          'metadata': <String, dynamic>{'key': 'value'},
          'readBy': <dynamic>['user_2'],
          'reactions': <dynamic>[],
        };

        final message = Message.fromJson(json);

        expect(message.messageId, equals('msg_1'));
        expect(message.chatId, equals('chat_1'));
        expect(message.senderId, equals('user_1'));
        expect(message.senderName, equals('Test User'));
        expect(message.content, equals('Hello world'));
        expect(message.type, equals(MessageType.text));
        expect(message.status, equals(MessageStatus.sent));
      });

      test('roundtrip serialization preserves data', () {
        final now = DateTime(2024, 1, 15, 12, 0, 0);
        final original = Message(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Test User',
          content: 'Hello world',
          type: MessageType.image,
          createdAt: now,
          status: MessageStatus.delivered,
          metadata: const {'imageUrl': 'https://example.com/image.jpg'},
          reactions: [
            MessageReaction(userId: 'user_2', emoji: '👍', createdAt: now),
          ],
        );

        final json = original.toJson();
        final restored = Message.fromJson(json);

        expect(restored.messageId, equals(original.messageId));
        expect(restored.type, equals(original.type));
        expect(restored.status, equals(original.status));
        expect(restored.reactions.length, equals(1));
      });
    });

    group('Equatable', () {
      test('two messages with same props are equal', () {
        final now = DateTime(2024, 1, 15, 12, 0, 0);
        final message1 = Message(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Test User',
          content: 'Hello',
          type: MessageType.text,
          createdAt: now,
          status: MessageStatus.sent,
        );

        final message2 = Message(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Test User',
          content: 'Hello',
          type: MessageType.text,
          createdAt: now,
          status: MessageStatus.sent,
        );

        expect(message1, equals(message2));
      });

      test('two messages with different props are not equal', () {
        final now = DateTime.now();
        final message1 = Message(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Test User',
          content: 'Hello',
          type: MessageType.text,
          createdAt: now,
          status: MessageStatus.sent,
        );

        final message2 = Message(
          messageId: 'msg_2',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Test User',
          content: 'Hello',
          type: MessageType.text,
          createdAt: now,
          status: MessageStatus.sent,
        );

        expect(message1, isNot(equals(message2)));
      });
    });
  });

  group('MessageType', () {
    test('contains all expected types', () {
      expect(MessageType.values, contains(MessageType.text));
      expect(MessageType.values, contains(MessageType.image));
      expect(MessageType.values, contains(MessageType.location));
      expect(MessageType.values, contains(MessageType.system));
      expect(MessageType.values, contains(MessageType.gameInvite));
      expect(MessageType.values, contains(MessageType.venueShare));
      expect(MessageType.values, contains(MessageType.voice));
      expect(MessageType.values, contains(MessageType.video));
      expect(MessageType.values, contains(MessageType.file));
    });
  });

  group('MessageStatus', () {
    test('contains all expected statuses', () {
      expect(MessageStatus.values, contains(MessageStatus.sending));
      expect(MessageStatus.values, contains(MessageStatus.sent));
      expect(MessageStatus.values, contains(MessageStatus.delivered));
      expect(MessageStatus.values, contains(MessageStatus.read));
      expect(MessageStatus.values, contains(MessageStatus.failed));
    });
  });

  group('MessageReaction', () {
    test('creates reaction with required fields', () {
      final now = DateTime.now();
      final reaction = MessageReaction(
        userId: 'user_1',
        emoji: '👍',
        createdAt: now,
      );

      expect(reaction.userId, equals('user_1'));
      expect(reaction.emoji, equals('👍'));
      expect(reaction.createdAt, equals(now));
    });

    test('toJson serializes correctly', () {
      final now = DateTime(2024, 1, 15, 12, 0, 0);
      final reaction = MessageReaction(
        userId: 'user_1',
        emoji: '❤️',
        createdAt: now,
      );

      final json = reaction.toJson();

      expect(json['userId'], equals('user_1'));
      expect(json['emoji'], equals('❤️'));
      expect(json['createdAt'], equals('2024-01-15T12:00:00.000'));
    });

    test('fromJson deserializes correctly', () {
      final json = <String, dynamic>{
        'userId': 'user_1',
        'emoji': '🎉',
        'createdAt': '2024-01-15T12:00:00.000',
      };

      final reaction = MessageReaction.fromJson(json);

      expect(reaction.userId, equals('user_1'));
      expect(reaction.emoji, equals('🎉'));
      expect(reaction.createdAt, equals(DateTime(2024, 1, 15, 12, 0, 0)));
    });

    test('two reactions with same props are equal', () {
      final now = DateTime(2024, 1, 15, 12, 0, 0);
      final reaction1 = MessageReaction(
        userId: 'user_1',
        emoji: '👍',
        createdAt: now,
      );

      final reaction2 = MessageReaction(
        userId: 'user_1',
        emoji: '👍',
        createdAt: now,
      );

      expect(reaction1, equals(reaction2));
    });
  });
}
