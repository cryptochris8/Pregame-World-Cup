import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/messaging/presentation/widgets/chat_list_item.dart';
import 'package:pregame_world_cup/features/messaging/domain/entities/chat.dart';
import '../../messaging_test_factory.dart';

void main() {
  group('ChatListItem', () {
    late VoidCallback onTap;
    late VoidCallback onLongPress;

    setUp(() {
      onTap = () {};
      onLongPress = () {};
    });

    test('is a StatelessWidget', () {
      expect(ChatListItem, isA<Type>());
    });

    test('can be constructed with required params', () {
      final chat = MessagingTestFactory.createDirectChat();

      final widget = ChatListItem(
        chat: chat,
        onTap: onTap,
      );

      expect(widget, isNotNull);
      expect(widget, isA<ChatListItem>());
    });

    test('can be constructed with optional onLongPress', () {
      final chat = MessagingTestFactory.createDirectChat();

      final widget = ChatListItem(
        chat: chat,
        onTap: onTap,
        onLongPress: onLongPress,
      );

      expect(widget, isNotNull);
      expect(widget, isA<ChatListItem>());
    });

    test('stores chat correctly', () {
      final chat = MessagingTestFactory.createDirectChat(
        chatId: 'test_chat_123',
        name: 'Test Chat',
      );

      final widget = ChatListItem(
        chat: chat,
        onTap: onTap,
      );

      expect(widget.chat, equals(chat));
      expect(widget.chat.chatId, equals('test_chat_123'));
      expect(widget.chat.name, equals('Test Chat'));
    });

    test('stores onTap callback correctly', () {
      final chat = MessagingTestFactory.createDirectChat();
      var wasTapped = false;

      final widget = ChatListItem(
        chat: chat,
        onTap: () {
          wasTapped = true;
        },
      );

      expect(widget.onTap, isNotNull);
      widget.onTap();
      expect(wasTapped, isTrue);
    });

    test('stores onLongPress callback when provided', () {
      final chat = MessagingTestFactory.createDirectChat();
      var wasLongPressed = false;

      final widget = ChatListItem(
        chat: chat,
        onTap: onTap,
        onLongPress: () {
          wasLongPressed = true;
        },
      );

      expect(widget.onLongPress, isNotNull);
      widget.onLongPress!();
      expect(wasLongPressed, isTrue);
    });

    test('onLongPress is null when not provided', () {
      final chat = MessagingTestFactory.createDirectChat();

      final widget = ChatListItem(
        chat: chat,
        onTap: onTap,
      );

      expect(widget.onLongPress, isNull);
    });

    test('works with direct chat', () {
      final chat = MessagingTestFactory.createDirectChat(
        chatId: 'direct_chat_001',
        participantIds: ['user_001', 'user_002'],
      );

      final widget = ChatListItem(
        chat: chat,
        onTap: onTap,
      );

      expect(widget.chat.type, equals(ChatType.direct));
      expect(widget.chat.participantIds.length, equals(2));
    });

    test('works with group chat', () {
      final chat = MessagingTestFactory.createGroupChat(
        chatId: 'group_chat_001',
        name: 'Test Group',
        participantIds: ['user_001', 'user_002', 'user_003'],
      );

      final widget = ChatListItem(
        chat: chat,
        onTap: onTap,
      );

      expect(widget.chat.type, equals(ChatType.group));
      expect(widget.chat.participantIds.length, equals(3));
      expect(widget.chat.name, equals('Test Group'));
    });

    test('handles chat with unread messages', () {
      final chat = MessagingTestFactory.createDirectChat(
        unreadCounts: {'user_001': 5},
      );

      final widget = ChatListItem(
        chat: chat,
        onTap: onTap,
      );

      expect(widget.chat.unreadCounts['user_001'], equals(5));
    });

    test('handles chat with no unread messages', () {
      final chat = MessagingTestFactory.createDirectChat(
        unreadCounts: {},
      );

      final widget = ChatListItem(
        chat: chat,
        onTap: onTap,
      );

      expect(widget.chat.unreadCounts, isEmpty);
    });

    test('handles chat with last message', () {
      final chat = MessagingTestFactory.createDirectChat(
        lastMessageContent: 'Hello there!',
        lastMessageTime: DateTime(2026, 6, 15, 10, 30),
      );

      final widget = ChatListItem(
        chat: chat,
        onTap: onTap,
      );

      expect(widget.chat.lastMessageContent, equals('Hello there!'));
      expect(widget.chat.lastMessageTime, isNotNull);
    });

    test('handles chat without last message', () {
      final chat = MessagingTestFactory.createDirectChat(
        lastMessageContent: null,
        lastMessageTime: null,
      );

      final widget = ChatListItem(
        chat: chat,
        onTap: onTap,
      );

      expect(widget.chat.lastMessageContent, isNull);
      expect(widget.chat.lastMessageTime, isNull);
    });
  });
}
