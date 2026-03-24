import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/messaging/presentation/widgets/message_input_widget.dart';

void main() {
  group('MessageInputWidget', () {
    late VoidCallback onMessageSent;
    late VoidCallback onCancelReply;

    setUp(() {
      onMessageSent = () {};
      onCancelReply = () {};
    });

    test('is a StatefulWidget', () {
      expect(MessageInputWidget, isA<Type>());
    });

    test('can be constructed with required params', () {
      final widget = MessageInputWidget(
        chatId: 'chat_123',
        onMessageSent: onMessageSent,
      );

      expect(widget, isNotNull);
      expect(widget, isA<MessageInputWidget>());
    });

    test('stores chatId correctly', () {
      final widget = MessageInputWidget(
        chatId: 'chat_test_456',
        onMessageSent: onMessageSent,
      );

      expect(widget.chatId, equals('chat_test_456'));
    });

    test('stores onMessageSent callback correctly', () {
      var wasCalled = false;

      final widget = MessageInputWidget(
        chatId: 'chat_123',
        onMessageSent: () {
          wasCalled = true;
        },
      );

      expect(widget.onMessageSent, isNotNull);
      widget.onMessageSent();
      expect(wasCalled, isTrue);
    });

    test('replyToMessageId is null by default', () {
      final widget = MessageInputWidget(
        chatId: 'chat_123',
        onMessageSent: onMessageSent,
      );

      expect(widget.replyToMessageId, isNull);
    });

    test('stores replyToMessageId when provided', () {
      final widget = MessageInputWidget(
        chatId: 'chat_123',
        replyToMessageId: 'msg_789',
        onMessageSent: onMessageSent,
      );

      expect(widget.replyToMessageId, equals('msg_789'));
    });

    test('onCancelReply is null by default', () {
      final widget = MessageInputWidget(
        chatId: 'chat_123',
        onMessageSent: onMessageSent,
      );

      expect(widget.onCancelReply, isNull);
    });

    test('stores onCancelReply when provided', () {
      var wasCalled = false;

      final widget = MessageInputWidget(
        chatId: 'chat_123',
        onMessageSent: onMessageSent,
        onCancelReply: () {
          wasCalled = true;
        },
      );

      expect(widget.onCancelReply, isNotNull);
      widget.onCancelReply!();
      expect(wasCalled, isTrue);
    });

    test('can be constructed with all params', () {
      var messageSent = false;
      var replyCancelled = false;

      final widget = MessageInputWidget(
        chatId: 'chat_full_test',
        replyToMessageId: 'msg_reply_123',
        onMessageSent: () {
          messageSent = true;
        },
        onCancelReply: () {
          replyCancelled = true;
        },
      );

      expect(widget, isNotNull);
      expect(widget.chatId, equals('chat_full_test'));
      expect(widget.replyToMessageId, equals('msg_reply_123'));

      widget.onMessageSent();
      expect(messageSent, isTrue);

      widget.onCancelReply!();
      expect(replyCancelled, isTrue);
    });

    test('handles different chatId values', () {
      final widget1 = MessageInputWidget(
        chatId: 'direct_chat_001',
        onMessageSent: onMessageSent,
      );

      final widget2 = MessageInputWidget(
        chatId: 'group_chat_002',
        onMessageSent: onMessageSent,
      );

      final widget3 = MessageInputWidget(
        chatId: 'team_chat_003',
        onMessageSent: onMessageSent,
      );

      expect(widget1.chatId, equals('direct_chat_001'));
      expect(widget2.chatId, equals('group_chat_002'));
      expect(widget3.chatId, equals('team_chat_003'));
    });

    test('handles reply to different messages', () {
      final widget1 = MessageInputWidget(
        chatId: 'chat_123',
        replyToMessageId: 'msg_001',
        onMessageSent: onMessageSent,
      );

      final widget2 = MessageInputWidget(
        chatId: 'chat_123',
        replyToMessageId: 'msg_002',
        onMessageSent: onMessageSent,
      );

      expect(widget1.replyToMessageId, equals('msg_001'));
      expect(widget2.replyToMessageId, equals('msg_002'));
    });

    test('can create widget without reply', () {
      final widget = MessageInputWidget(
        chatId: 'chat_123',
        onMessageSent: onMessageSent,
        onCancelReply: onCancelReply,
      );

      expect(widget.replyToMessageId, isNull);
      expect(widget.onCancelReply, isNotNull);
    });

    test('callbacks are independent', () {
      var messageSentCount = 0;
      var replyCancelledCount = 0;

      final widget = MessageInputWidget(
        chatId: 'chat_123',
        onMessageSent: () {
          messageSentCount++;
        },
        onCancelReply: () {
          replyCancelledCount++;
        },
      );

      widget.onMessageSent();
      expect(messageSentCount, equals(1));
      expect(replyCancelledCount, equals(0));

      widget.onCancelReply!();
      expect(messageSentCount, equals(1));
      expect(replyCancelledCount, equals(1));

      widget.onMessageSent();
      expect(messageSentCount, equals(2));
      expect(replyCancelledCount, equals(1));
    });

    test('stores empty chatId', () {
      final widget = MessageInputWidget(
        chatId: '',
        onMessageSent: onMessageSent,
      );

      expect(widget.chatId, equals(''));
    });

    test('handles multiple widget instances', () {
      final widget1 = MessageInputWidget(
        chatId: 'chat_001',
        onMessageSent: () {},
      );

      final widget2 = MessageInputWidget(
        chatId: 'chat_002',
        replyToMessageId: 'msg_002',
        onMessageSent: () {},
        onCancelReply: () {},
      );

      expect(widget1.chatId, equals('chat_001'));
      expect(widget1.replyToMessageId, isNull);
      expect(widget1.onCancelReply, isNull);

      expect(widget2.chatId, equals('chat_002'));
      expect(widget2.replyToMessageId, equals('msg_002'));
      expect(widget2.onCancelReply, isNotNull);
    });
  });
}
