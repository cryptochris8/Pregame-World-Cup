import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/watch_party/presentation/widgets/watch_party_chat_input.dart';

void main() {
  group('WatchPartyChatInput construction and type tests', () {
    test('can be constructed with required parameters', () {
      final widget = WatchPartyChatInput(
        onSend: (message) {},
      );

      expect(widget, isNotNull);
      expect(widget, isA<WatchPartyChatInput>());
    });

    test('can be constructed with all parameters', () {
      final widget = WatchPartyChatInput(
        onSend: (message) {},
        enabled: true,
        replyingTo: 'Original message',
        onCancelReply: () {},
        disabledMessage: 'Chat is disabled',
      );

      expect(widget, isNotNull);
      expect(widget.enabled, isTrue);
      expect(widget.replyingTo, equals('Original message'));
      expect(widget.onCancelReply, isNotNull);
      expect(widget.disabledMessage, equals('Chat is disabled'));
    });

    test('default enabled value is true', () {
      final widget = WatchPartyChatInput(
        onSend: (message) {},
      );

      expect(widget.enabled, isTrue);
    });

    test('onSend callback is set correctly', () {
      String? sentMessage;
      final widget = WatchPartyChatInput(
        onSend: (message) {
          sentMessage = message;
        },
      );

      widget.onSend('Test message');
      expect(sentMessage, equals('Test message'));
    });

    test('can be constructed with disabled state', () {
      final widget = WatchPartyChatInput(
        onSend: (message) {},
        enabled: false,
        disabledMessage: 'You cannot send messages',
      );

      expect(widget.enabled, isFalse);
      expect(widget.disabledMessage, equals('You cannot send messages'));
    });

    test('onCancelReply callback works correctly', () {
      bool replyCancelled = false;
      final widget = WatchPartyChatInput(
        onSend: (message) {},
        replyingTo: 'Some message',
        onCancelReply: () {
          replyCancelled = true;
        },
      );

      widget.onCancelReply?.call();
      expect(replyCancelled, isTrue);
    });

    test('is a StatefulWidget', () {
      final widget = WatchPartyChatInput(
        onSend: (message) {},
      );

      expect(widget, isA<StatefulWidget>());
    });

    test('multiple instances are independent', () {
      final widget1 = WatchPartyChatInput(
        onSend: (message) {},
        enabled: true,
      );

      final widget2 = WatchPartyChatInput(
        onSend: (message) {},
        enabled: false,
      );

      expect(widget1.enabled, isTrue);
      expect(widget2.enabled, isFalse);
    });
  });

  group('QuickReactionBar construction and type tests', () {
    test('can be constructed with required parameters', () {
      final widget = QuickReactionBar(
        onReact: (emoji) {},
      );

      expect(widget, isNotNull);
      expect(widget, isA<QuickReactionBar>());
    });

    test('default reactions are provided', () {
      final widget = QuickReactionBar(
        onReact: (emoji) {},
      );

      expect(widget.reactions, equals(['👍', '❤️', '😂', '😮', '😢', '👏']));
    });

    test('can be constructed with custom reactions', () {
      final customReactions = ['⚽', '🏆', '🔥'];
      final widget = QuickReactionBar(
        onReact: (emoji) {},
        reactions: customReactions,
      );

      expect(widget.reactions, equals(customReactions));
    });

    test('onReact callback works correctly', () {
      String? reactedEmoji;
      final widget = QuickReactionBar(
        onReact: (emoji) {
          reactedEmoji = emoji;
        },
      );

      widget.onReact('⚽');
      expect(reactedEmoji, equals('⚽'));
    });

    test('is a StatelessWidget', () {
      final widget = QuickReactionBar(
        onReact: (emoji) {},
      );

      expect(widget, isA<StatelessWidget>());
    });
  });
}
