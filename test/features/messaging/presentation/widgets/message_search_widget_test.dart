import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/messaging/presentation/widgets/message_search_widget.dart';
import 'package:pregame_world_cup/features/messaging/domain/entities/message.dart';

void main() {
  group('MessageSearchWidget', () {
    test('is a StatefulWidget', () {
      final widget = MessageSearchWidget(
        chatId: 'chat123',
        onMessageSelected: (_) {},
      );
      expect(widget, isA<StatefulWidget>());
    });

    test('can be constructed with required parameters', () {
      final widget = MessageSearchWidget(
        chatId: 'chat123',
        onMessageSelected: (_) {},
      );
      expect(widget, isNotNull);
    });

    test('stores chatId', () {
      const testChatId = 'chat123';
      final widget = MessageSearchWidget(
        chatId: testChatId,
        onMessageSelected: (_) {},
      );
      expect(widget.chatId, equals(testChatId));
    });

    test('stores onMessageSelected callback', () {
      Message? selectedMessage;
      void testCallback(Message message) {
        selectedMessage = message;
      }

      final widget = MessageSearchWidget(
        chatId: 'chat123',
        onMessageSelected: testCallback,
      );

      expect(widget.onMessageSelected, equals(testCallback));

      final testMessage = Message.text(
        chatId: 'chat123',
        senderId: 'user1',
        senderName: 'Test User',
        content: 'Test message',
      );
      widget.onMessageSelected(testMessage);
      expect(selectedMessage, equals(testMessage));
      expect(selectedMessage?.chatId, equals('chat123'));
      expect(selectedMessage?.content, equals('Test message'));
    });

    test('can be constructed with different chat IDs', () {
      final widget1 = MessageSearchWidget(
        chatId: 'chat123',
        onMessageSelected: (_) {},
      );
      final widget2 = MessageSearchWidget(
        chatId: 'chat456',
        onMessageSelected: (_) {},
      );
      expect(widget1.chatId, equals('chat123'));
      expect(widget2.chatId, equals('chat456'));
      expect(widget1.chatId, isNot(equals(widget2.chatId)));
    });

    test('callback receives correct message data', () {
      Message? receivedMessage;
      final widget = MessageSearchWidget(
        chatId: 'testChat',
        onMessageSelected: (message) {
          receivedMessage = message;
        },
      );

      final testMessage = Message.text(
        chatId: 'testChat',
        senderId: 'sender1',
        senderName: 'John Doe',
        content: 'Hello world',
        senderImageUrl: 'https://example.com/avatar.jpg',
      );

      widget.onMessageSelected(testMessage);

      expect(receivedMessage, isNotNull);
      expect(receivedMessage?.senderId, equals('sender1'));
      expect(receivedMessage?.senderName, equals('John Doe'));
      expect(receivedMessage?.content, equals('Hello world'));
      expect(receivedMessage?.type, equals(MessageType.text));
    });

    test('handles multiple callback invocations', () {
      final selectedMessages = <Message>[];
      final widget = MessageSearchWidget(
        chatId: 'chat123',
        onMessageSelected: (message) {
          selectedMessages.add(message);
        },
      );

      final message1 = Message.text(
        chatId: 'chat123',
        senderId: 'user1',
        senderName: 'User 1',
        content: 'First message',
      );
      final message2 = Message.text(
        chatId: 'chat123',
        senderId: 'user2',
        senderName: 'User 2',
        content: 'Second message',
      );

      widget.onMessageSelected(message1);
      widget.onMessageSelected(message2);

      expect(selectedMessages.length, equals(2));
      expect(selectedMessages[0].content, equals('First message'));
      expect(selectedMessages[1].content, equals('Second message'));
    });
  });
}
