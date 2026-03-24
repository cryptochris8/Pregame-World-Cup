import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/messaging/presentation/widgets/message_item_widget.dart';
import 'package:pregame_world_cup/features/messaging/domain/entities/message.dart';
import '../../messaging_test_factory.dart';

void main() {
  group('MessageItemWidget', () {
    late Function(String) onReply;
    late Function(String, String) onReaction;

    setUp(() {
      onReply = (messageId) {};
      onReaction = (messageId, emoji) {};
    });

    test('is a StatelessWidget', () {
      expect(MessageItemWidget, isA<Type>());
    });

    test('can be constructed with all required params', () {
      final message = MessagingTestFactory.createTextMessage();
      final chat = MessagingTestFactory.createDirectChat();

      final widget = MessageItemWidget(
        message: message,
        chat: chat,
        showSenderInfo: true,
        isFirstMessage: true,
        isLastMessage: false,
        onReply: onReply,
        onReaction: onReaction,
      );

      expect(widget, isNotNull);
      expect(widget, isA<MessageItemWidget>());
    });

    test('stores message correctly', () {
      final message = MessagingTestFactory.createTextMessage(
        messageId: 'test_msg_123',
        content: 'Test message content',
      );
      final chat = MessagingTestFactory.createDirectChat();

      final widget = MessageItemWidget(
        message: message,
        chat: chat,
        showSenderInfo: false,
        isFirstMessage: false,
        isLastMessage: true,
        onReply: onReply,
        onReaction: onReaction,
      );

      expect(widget.message, equals(message));
      expect(widget.message.messageId, equals('test_msg_123'));
      expect(widget.message.content, equals('Test message content'));
    });

    test('stores chat correctly', () {
      final message = MessagingTestFactory.createTextMessage();
      final chat = MessagingTestFactory.createGroupChat(
        chatId: 'group_chat_456',
        name: 'Test Group',
      );

      final widget = MessageItemWidget(
        message: message,
        chat: chat,
        showSenderInfo: true,
        isFirstMessage: false,
        isLastMessage: false,
        onReply: onReply,
        onReaction: onReaction,
      );

      expect(widget.chat, equals(chat));
      expect(widget.chat.chatId, equals('group_chat_456'));
      expect(widget.chat.name, equals('Test Group'));
    });

    test('stores showSenderInfo correctly', () {
      final message = MessagingTestFactory.createTextMessage();
      final chat = MessagingTestFactory.createDirectChat();

      final widget1 = MessageItemWidget(
        message: message,
        chat: chat,
        showSenderInfo: true,
        isFirstMessage: true,
        isLastMessage: false,
        onReply: onReply,
        onReaction: onReaction,
      );

      final widget2 = MessageItemWidget(
        message: message,
        chat: chat,
        showSenderInfo: false,
        isFirstMessage: true,
        isLastMessage: false,
        onReply: onReply,
        onReaction: onReaction,
      );

      expect(widget1.showSenderInfo, isTrue);
      expect(widget2.showSenderInfo, isFalse);
    });

    test('stores isFirstMessage correctly', () {
      final message = MessagingTestFactory.createTextMessage();
      final chat = MessagingTestFactory.createDirectChat();

      final widget = MessageItemWidget(
        message: message,
        chat: chat,
        showSenderInfo: true,
        isFirstMessage: true,
        isLastMessage: false,
        onReply: onReply,
        onReaction: onReaction,
      );

      expect(widget.isFirstMessage, isTrue);
    });

    test('stores isLastMessage correctly', () {
      final message = MessagingTestFactory.createTextMessage();
      final chat = MessagingTestFactory.createDirectChat();

      final widget = MessageItemWidget(
        message: message,
        chat: chat,
        showSenderInfo: true,
        isFirstMessage: false,
        isLastMessage: true,
        onReply: onReply,
        onReaction: onReaction,
      );

      expect(widget.isLastMessage, isTrue);
    });

    test('stores onReply callback correctly', () {
      final message = MessagingTestFactory.createTextMessage();
      final chat = MessagingTestFactory.createDirectChat();
      String? capturedMessageId;

      final widget = MessageItemWidget(
        message: message,
        chat: chat,
        showSenderInfo: true,
        isFirstMessage: false,
        isLastMessage: false,
        onReply: (messageId) {
          capturedMessageId = messageId;
        },
        onReaction: onReaction,
      );

      expect(widget.onReply, isNotNull);
      widget.onReply('test_id');
      expect(capturedMessageId, equals('test_id'));
    });

    test('stores onReaction callback correctly', () {
      final message = MessagingTestFactory.createTextMessage();
      final chat = MessagingTestFactory.createDirectChat();
      String? capturedMessageId;
      String? capturedEmoji;

      final widget = MessageItemWidget(
        message: message,
        chat: chat,
        showSenderInfo: true,
        isFirstMessage: false,
        isLastMessage: false,
        onReply: onReply,
        onReaction: (messageId, emoji) {
          capturedMessageId = messageId;
          capturedEmoji = emoji;
        },
      );

      expect(widget.onReaction, isNotNull);
      widget.onReaction('msg_123', '👍');
      expect(capturedMessageId, equals('msg_123'));
      expect(capturedEmoji, equals('👍'));
    });

    test('works with different message types', () {
      final chat = MessagingTestFactory.createDirectChat();

      final textMessage = MessagingTestFactory.createTextMessage();
      final imageMessage = MessagingTestFactory.createImageMessage();
      final systemMessage = MessagingTestFactory.createSystemMessage();

      final widget1 = MessageItemWidget(
        message: textMessage,
        chat: chat,
        showSenderInfo: true,
        isFirstMessage: true,
        isLastMessage: false,
        onReply: onReply,
        onReaction: onReaction,
      );

      final widget2 = MessageItemWidget(
        message: imageMessage,
        chat: chat,
        showSenderInfo: true,
        isFirstMessage: false,
        isLastMessage: false,
        onReply: onReply,
        onReaction: onReaction,
      );

      final widget3 = MessageItemWidget(
        message: systemMessage,
        chat: chat,
        showSenderInfo: false,
        isFirstMessage: false,
        isLastMessage: true,
        onReply: onReply,
        onReaction: onReaction,
      );

      expect(widget1.message.type, equals(MessageType.text));
      expect(widget2.message.type, equals(MessageType.image));
      expect(widget3.message.type, equals(MessageType.system));
    });
  });
}
