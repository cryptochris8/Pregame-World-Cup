import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party_message.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party_member.dart';

void main() {
  group('WatchPartyMessageType', () {
    test('has expected values', () {
      expect(WatchPartyMessageType.values, hasLength(5));
      expect(WatchPartyMessageType.values, contains(WatchPartyMessageType.text));
      expect(WatchPartyMessageType.values, contains(WatchPartyMessageType.image));
      expect(WatchPartyMessageType.values, contains(WatchPartyMessageType.gif));
      expect(WatchPartyMessageType.values, contains(WatchPartyMessageType.system));
      expect(WatchPartyMessageType.values, contains(WatchPartyMessageType.poll));
    });
  });

  group('MessageReaction', () {
    final testTime = DateTime(2024, 10, 15, 12, 0, 0);

    group('Constructor', () {
      test('creates reaction with required fields', () {
        final reaction = MessageReaction(
          emoji: '👍',
          userId: 'user_1',
          userName: 'John Doe',
          createdAt: testTime,
        );

        expect(reaction.emoji, equals('👍'));
        expect(reaction.userId, equals('user_1'));
        expect(reaction.userName, equals('John Doe'));
        expect(reaction.createdAt, equals(testTime));
      });
    });

    group('JSON serialization', () {
      test('toJson serializes correctly', () {
        final reaction = MessageReaction(
          emoji: '❤️',
          userId: 'user_1',
          userName: 'Jane Doe',
          createdAt: testTime,
        );
        final json = reaction.toJson();

        expect(json['emoji'], equals('❤️'));
        expect(json['userId'], equals('user_1'));
        expect(json['userName'], equals('Jane Doe'));
        expect(json['createdAt'], equals('2024-10-15T12:00:00.000'));
      });

      test('fromJson deserializes correctly', () {
        final json = {
          'emoji': '🎉',
          'userId': 'user_2',
          'userName': 'Bob',
          'createdAt': '2024-10-15T14:30:00.000',
        };

        final reaction = MessageReaction.fromJson(json);

        expect(reaction.emoji, equals('🎉'));
        expect(reaction.userId, equals('user_2'));
        expect(reaction.userName, equals('Bob'));
        expect(reaction.createdAt, equals(DateTime(2024, 10, 15, 14, 30, 0)));
      });

      test('fromJson handles missing userName', () {
        final json = {
          'emoji': '👍',
          'userId': 'user_1',
          'createdAt': '2024-10-15T12:00:00.000',
        };

        final reaction = MessageReaction.fromJson(json);
        expect(reaction.userName, equals(''));
      });

      test('roundtrip serialization preserves data', () {
        final original = MessageReaction(
          emoji: '⚽',
          userId: 'user_3',
          userName: 'Soccer Fan',
          createdAt: testTime,
        );
        final json = original.toJson();
        final restored = MessageReaction.fromJson(json);

        expect(restored.emoji, equals(original.emoji));
        expect(restored.userId, equals(original.userId));
        expect(restored.userName, equals(original.userName));
        expect(restored.createdAt, equals(original.createdAt));
      });
    });

    group('Equatable', () {
      test('two reactions with same props are equal', () {
        final r1 = MessageReaction(
          emoji: '👍',
          userId: 'user_1',
          userName: 'John',
          createdAt: testTime,
        );
        final r2 = MessageReaction(
          emoji: '👍',
          userId: 'user_1',
          userName: 'John',
          createdAt: testTime,
        );

        expect(r1, equals(r2));
      });

      test('two reactions with different props are not equal', () {
        final r1 = MessageReaction(
          emoji: '👍',
          userId: 'user_1',
          userName: 'John',
          createdAt: testTime,
        );
        final r2 = MessageReaction(
          emoji: '❤️',
          userId: 'user_1',
          userName: 'John',
          createdAt: testTime,
        );

        expect(r1, isNot(equals(r2)));
      });
    });
  });

  group('WatchPartyMessage', () {
    final testTime = DateTime(2024, 10, 15, 12, 0, 0);

    WatchPartyMessage createTestMessage({
      String messageId = 'msg_1',
      String watchPartyId = 'wp_123',
      String senderId = 'user_1',
      String senderName = 'John Doe',
      String? senderImageUrl,
      WatchPartyMemberRole senderRole = WatchPartyMemberRole.member,
      String content = 'Hello everyone!',
      WatchPartyMessageType type = WatchPartyMessageType.text,
      DateTime? createdAt,
      bool isDeleted = false,
      List<MessageReaction> reactions = const [],
      String? replyToMessageId,
      Map<String, dynamic> metadata = const {},
    }) {
      return WatchPartyMessage(
        messageId: messageId,
        watchPartyId: watchPartyId,
        senderId: senderId,
        senderName: senderName,
        senderImageUrl: senderImageUrl,
        senderRole: senderRole,
        content: content,
        type: type,
        createdAt: createdAt ?? testTime,
        isDeleted: isDeleted,
        reactions: reactions,
        replyToMessageId: replyToMessageId,
        metadata: metadata,
      );
    }

    group('Constructor', () {
      test('creates message with required fields', () {
        final message = createTestMessage();

        expect(message.messageId, equals('msg_1'));
        expect(message.watchPartyId, equals('wp_123'));
        expect(message.senderId, equals('user_1'));
        expect(message.senderName, equals('John Doe'));
        expect(message.content, equals('Hello everyone!'));
        expect(message.type, equals(WatchPartyMessageType.text));
        expect(message.isDeleted, isFalse);
        expect(message.reactions, isEmpty);
      });

      test('creates message with optional fields', () {
        final message = createTestMessage(
          senderImageUrl: 'https://example.com/avatar.jpg',
          replyToMessageId: 'msg_0',
          metadata: {'key': 'value'},
        );

        expect(message.senderImageUrl, equals('https://example.com/avatar.jpg'));
        expect(message.replyToMessageId, equals('msg_0'));
        expect(message.metadata, equals({'key': 'value'}));
      });
    });

    group('Factory constructors', () {
      test('text creates text message', () {
        final message = WatchPartyMessage.text(
          watchPartyId: 'wp_1',
          senderId: 'user_1',
          senderName: 'John',
          senderRole: WatchPartyMemberRole.member,
          content: 'Hello!',
        );

        expect(message.type, equals(WatchPartyMessageType.text));
        expect(message.messageId, contains('msg_'));
        expect(message.content, equals('Hello!'));
      });

      test('text creates message with reply', () {
        final message = WatchPartyMessage.text(
          watchPartyId: 'wp_1',
          senderId: 'user_1',
          senderName: 'John',
          senderRole: WatchPartyMemberRole.member,
          content: 'Reply',
          replyToMessageId: 'msg_original',
        );

        expect(message.replyToMessageId, equals('msg_original'));
        expect(message.isReply, isTrue);
      });

      test('system creates system message', () {
        final message = WatchPartyMessage.system(
          watchPartyId: 'wp_1',
          content: 'John joined the party',
        );

        expect(message.type, equals(WatchPartyMessageType.system));
        expect(message.senderId, equals('system'));
        expect(message.senderName, equals('System'));
        expect(message.messageId, contains('sys_'));
      });

      test('image creates image message', () {
        final message = WatchPartyMessage.image(
          watchPartyId: 'wp_1',
          senderId: 'user_1',
          senderName: 'John',
          senderRole: WatchPartyMemberRole.member,
          imageUrl: 'https://example.com/image.jpg',
          caption: 'Check this out!',
        );

        expect(message.type, equals(WatchPartyMessageType.image));
        expect(message.messageId, contains('img_'));
        expect(message.content, equals('Check this out!'));
        expect(message.metadata['imageUrl'], equals('https://example.com/image.jpg'));
        expect(message.imageUrl, equals('https://example.com/image.jpg'));
      });

      test('gif creates gif message', () {
        final message = WatchPartyMessage.gif(
          watchPartyId: 'wp_1',
          senderId: 'user_1',
          senderName: 'John',
          senderRole: WatchPartyMemberRole.member,
          gifUrl: 'https://example.com/reaction.gif',
        );

        expect(message.type, equals(WatchPartyMessageType.gif));
        expect(message.messageId, contains('gif_'));
        expect(message.metadata['gifUrl'], equals('https://example.com/reaction.gif'));
        expect(message.gifUrl, equals('https://example.com/reaction.gif'));
      });
    });

    group('Computed getters', () {
      test('type getters work correctly', () {
        final text = createTestMessage(type: WatchPartyMessageType.text);
        final image = createTestMessage(type: WatchPartyMessageType.image);
        final gif = createTestMessage(type: WatchPartyMessageType.gif);
        final system = createTestMessage(type: WatchPartyMessageType.system);
        final poll = createTestMessage(type: WatchPartyMessageType.poll);

        expect(text.isText, isTrue);
        expect(text.isImage, isFalse);
        expect(image.isImage, isTrue);
        expect(gif.isGif, isTrue);
        expect(system.isSystem, isTrue);
        expect(poll.isPoll, isTrue);
      });

      test('isReply works correctly', () {
        final reply = createTestMessage(replyToMessageId: 'msg_0');
        final notReply = createTestMessage(replyToMessageId: null);

        expect(reply.isReply, isTrue);
        expect(notReply.isReply, isFalse);
      });

      test('hasReactions works correctly', () {
        final withReactions = createTestMessage(
          reactions: [
            MessageReaction(
              emoji: '👍',
              userId: 'user_1',
              userName: 'John',
              createdAt: testTime,
            ),
          ],
        );
        final noReactions = createTestMessage(reactions: []);

        expect(withReactions.hasReactions, isTrue);
        expect(noReactions.hasReactions, isFalse);
      });

      test('isFromHost and isFromCoHost work correctly', () {
        final hostMsg = createTestMessage(senderRole: WatchPartyMemberRole.host);
        final coHostMsg = createTestMessage(senderRole: WatchPartyMemberRole.coHost);
        final memberMsg = createTestMessage(senderRole: WatchPartyMemberRole.member);

        expect(hostMsg.isFromHost, isTrue);
        expect(hostMsg.isFromCoHost, isFalse);
        expect(coHostMsg.isFromCoHost, isTrue);
        expect(memberMsg.isFromHost, isFalse);
        expect(memberMsg.isFromCoHost, isFalse);
      });

      test('imageUrl and gifUrl return metadata values', () {
        final imageMsg = createTestMessage(
          metadata: {'imageUrl': 'https://example.com/img.jpg'},
        );
        final gifMsg = createTestMessage(
          metadata: {'gifUrl': 'https://example.com/anim.gif'},
        );

        expect(imageMsg.imageUrl, equals('https://example.com/img.jpg'));
        expect(gifMsg.gifUrl, equals('https://example.com/anim.gif'));
      });
    });

    group('timeAgo', () {
      test('returns "Just now" for recent messages', () {
        final now = DateTime.now();
        final message = createTestMessage(createdAt: now);
        expect(message.timeAgo, equals('Just now'));
      });

      test('returns minutes format', () {
        final past = DateTime.now().subtract(const Duration(minutes: 5));
        final message = createTestMessage(createdAt: past);
        expect(message.timeAgo, contains('5m ago'));
      });

      test('returns hours format', () {
        final past = DateTime.now().subtract(const Duration(hours: 3));
        final message = createTestMessage(createdAt: past);
        expect(message.timeAgo, contains('3h ago'));
      });

      test('returns days format', () {
        final past = DateTime.now().subtract(const Duration(days: 2));
        final message = createTestMessage(createdAt: past);
        expect(message.timeAgo, contains('2d ago'));
      });
    });

    group('formattedTime', () {
      test('formats AM time correctly', () {
        final message = createTestMessage(
          createdAt: DateTime(2024, 10, 15, 9, 5, 0),
        );
        expect(message.formattedTime, equals('9:05 AM'));
      });

      test('formats PM time correctly', () {
        final message = createTestMessage(
          createdAt: DateTime(2024, 10, 15, 14, 30, 0),
        );
        expect(message.formattedTime, equals('2:30 PM'));
      });

      test('formats noon correctly', () {
        final message = createTestMessage(
          createdAt: DateTime(2024, 10, 15, 12, 0, 0),
        );
        expect(message.formattedTime, equals('12:00 PM'));
      });

      test('formats midnight correctly', () {
        final message = createTestMessage(
          createdAt: DateTime(2024, 10, 15, 0, 15, 0),
        );
        expect(message.formattedTime, equals('12:15 AM'));
      });
    });

    group('Reaction methods', () {
      test('getReactionCount returns correct count', () {
        final message = createTestMessage(
          reactions: [
            MessageReaction(emoji: '👍', userId: 'u1', userName: 'A', createdAt: testTime),
            MessageReaction(emoji: '👍', userId: 'u2', userName: 'B', createdAt: testTime),
            MessageReaction(emoji: '❤️', userId: 'u3', userName: 'C', createdAt: testTime),
          ],
        );

        expect(message.getReactionCount('👍'), equals(2));
        expect(message.getReactionCount('❤️'), equals(1));
        expect(message.getReactionCount('😂'), equals(0));
      });

      test('hasUserReacted returns correct value', () {
        final message = createTestMessage(
          reactions: [
            MessageReaction(emoji: '👍', userId: 'user_1', userName: 'A', createdAt: testTime),
          ],
        );

        expect(message.hasUserReacted('user_1', '👍'), isTrue);
        expect(message.hasUserReacted('user_1', '❤️'), isFalse);
        expect(message.hasUserReacted('user_2', '👍'), isFalse);
      });

      test('uniqueReactionEmojis returns unique list', () {
        final message = createTestMessage(
          reactions: [
            MessageReaction(emoji: '👍', userId: 'u1', userName: 'A', createdAt: testTime),
            MessageReaction(emoji: '👍', userId: 'u2', userName: 'B', createdAt: testTime),
            MessageReaction(emoji: '❤️', userId: 'u3', userName: 'C', createdAt: testTime),
          ],
        );

        final uniqueEmojis = message.uniqueReactionEmojis;
        expect(uniqueEmojis, hasLength(2));
        expect(uniqueEmojis, contains('👍'));
        expect(uniqueEmojis, contains('❤️'));
      });
    });

    group('Specialized methods', () {
      test('delete marks message as deleted', () {
        final original = createTestMessage(content: 'Original message');
        final deleted = original.delete();

        expect(deleted.isDeleted, isTrue);
        expect(deleted.content, equals('This message was deleted'));
      });

      test('addReaction adds new reaction', () {
        final original = createTestMessage(reactions: []);
        final reaction = MessageReaction(
          emoji: '👍',
          userId: 'user_1',
          userName: 'John',
          createdAt: testTime,
        );
        final updated = original.addReaction(reaction);

        expect(updated.reactions, hasLength(1));
        expect(updated.reactions.first.emoji, equals('👍'));
      });

      test('removeReaction removes specific reaction', () {
        final original = createTestMessage(
          reactions: [
            MessageReaction(emoji: '👍', userId: 'user_1', userName: 'A', createdAt: testTime),
            MessageReaction(emoji: '❤️', userId: 'user_2', userName: 'B', createdAt: testTime),
          ],
        );
        final updated = original.removeReaction('user_1', '👍');

        expect(updated.reactions, hasLength(1));
        expect(updated.reactions.first.emoji, equals('❤️'));
      });
    });

    group('copyWith', () {
      test('copies with updated fields', () {
        final original = createTestMessage();
        final updated = original.copyWith(
          content: 'Updated content',
          isDeleted: true,
        );

        expect(updated.content, equals('Updated content'));
        expect(updated.isDeleted, isTrue);
        expect(updated.messageId, equals(original.messageId));
      });
    });

    group('JSON serialization', () {
      test('toJson serializes all fields', () {
        final message = createTestMessage(
          senderImageUrl: 'https://example.com/avatar.jpg',
          reactions: [
            MessageReaction(emoji: '👍', userId: 'u1', userName: 'A', createdAt: testTime),
          ],
          replyToMessageId: 'msg_0',
          metadata: {'key': 'value'},
        );
        final json = message.toJson();

        expect(json['messageId'], equals('msg_1'));
        expect(json['watchPartyId'], equals('wp_123'));
        expect(json['senderId'], equals('user_1'));
        expect(json['senderName'], equals('John Doe'));
        expect(json['senderRole'], equals('member'));
        expect(json['type'], equals('text'));
        expect(json['reactions'], hasLength(1));
        expect(json['metadata'], equals({'key': 'value'}));
      });

      test('fromJson deserializes correctly', () {
        final json = {
          'messageId': 'msg_test',
          'watchPartyId': 'wp_test',
          'senderId': 'sender_1',
          'senderName': 'Test User',
          'senderRole': 'host',
          'content': 'Test content',
          'type': 'text',
          'createdAt': '2024-10-15T12:00:00.000',
          'isDeleted': false,
          'reactions': [],
          'metadata': {},
        };

        final message = WatchPartyMessage.fromJson(json);

        expect(message.messageId, equals('msg_test'));
        expect(message.senderName, equals('Test User'));
        expect(message.senderRole, equals(WatchPartyMemberRole.host));
        expect(message.type, equals(WatchPartyMessageType.text));
      });

      test('fromJson handles unknown role with default', () {
        final json = {
          'messageId': 'msg_test',
          'watchPartyId': 'wp_test',
          'senderId': 'sender_1',
          'senderName': 'Test User',
          'senderRole': 'unknownRole',
          'content': 'Test',
          'type': 'text',
          'createdAt': '2024-10-15T12:00:00.000',
        };

        final message = WatchPartyMessage.fromJson(json);
        expect(message.senderRole, equals(WatchPartyMemberRole.member));
      });

      test('fromJson handles unknown type with default', () {
        final json = {
          'messageId': 'msg_test',
          'watchPartyId': 'wp_test',
          'senderId': 'sender_1',
          'senderName': 'Test User',
          'senderRole': 'member',
          'content': 'Test',
          'type': 'unknownType',
          'createdAt': '2024-10-15T12:00:00.000',
        };

        final message = WatchPartyMessage.fromJson(json);
        expect(message.type, equals(WatchPartyMessageType.text));
      });

      test('roundtrip serialization preserves data', () {
        final original = createTestMessage(
          senderImageUrl: 'https://example.com/img.jpg',
          reactions: [
            MessageReaction(emoji: '👍', userId: 'u1', userName: 'A', createdAt: testTime),
          ],
          metadata: {'key': 'value'},
        );
        final json = original.toJson();
        final restored = WatchPartyMessage.fromJson(json);

        expect(restored.messageId, equals(original.messageId));
        expect(restored.content, equals(original.content));
        expect(restored.senderRole, equals(original.senderRole));
        expect(restored.reactions, hasLength(1));
      });
    });

    group('Firestore serialization', () {
      test('fromFirestore deserializes with string dates', () {
        final data = {
          'watchPartyId': 'wp_1',
          'senderId': 'sender_1',
          'senderName': 'User',
          'senderRole': 'member',
          'content': 'Hello',
          'type': 'text',
          'createdAt': '2024-10-15T12:00:00.000',
          'isDeleted': false,
          'reactions': [],
          'metadata': {},
        };

        final message = WatchPartyMessage.fromFirestore(data, 'msg_fs_1');

        expect(message.messageId, equals('msg_fs_1'));
        expect(message.watchPartyId, equals('wp_1'));
        expect(message.content, equals('Hello'));
      });

      test('fromFirestore handles missing fields with defaults', () {
        final data = <String, dynamic>{};

        final message = WatchPartyMessage.fromFirestore(data, 'msg_min');

        expect(message.messageId, equals('msg_min'));
        expect(message.watchPartyId, equals(''));
        expect(message.senderId, equals(''));
        expect(message.senderName, equals('User'));
        expect(message.content, equals(''));
        expect(message.type, equals(WatchPartyMessageType.text));
      });
    });

    group('Equatable', () {
      test('two messages with same props are equal', () {
        final m1 = createTestMessage();
        final m2 = createTestMessage();

        expect(m1, equals(m2));
      });

      test('two messages with different props are not equal', () {
        final m1 = createTestMessage(messageId: 'msg_1');
        final m2 = createTestMessage(messageId: 'msg_2');

        expect(m1, isNot(equals(m2)));
      });
    });
  });
}
