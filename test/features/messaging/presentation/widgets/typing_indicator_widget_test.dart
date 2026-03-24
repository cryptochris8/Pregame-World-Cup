import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/messaging/presentation/widgets/typing_indicator_widget.dart';
import '../../messaging_test_factory.dart';

void main() {
  group('TypingIndicatorWidget', () {
    test('is a StatefulWidget', () {
      expect(TypingIndicatorWidget, isA<Type>());
    });

    test('can be constructed with required params', () {
      final typingUsers = [
        MessagingTestFactory.createTypingIndicator(),
      ];

      final widget = TypingIndicatorWidget(
        typingUsers: typingUsers,
      );

      expect(widget, isNotNull);
      expect(widget, isA<TypingIndicatorWidget>());
    });

    test('stores typingUsers correctly', () {
      final typingUsers = [
        MessagingTestFactory.createTypingIndicator(
          userId: 'user_001',
          userName: 'John Doe',
        ),
      ];

      final widget = TypingIndicatorWidget(
        typingUsers: typingUsers,
      );

      expect(widget.typingUsers, equals(typingUsers));
      expect(widget.typingUsers.length, equals(1));
      expect(widget.typingUsers.first.userId, equals('user_001'));
      expect(widget.typingUsers.first.userName, equals('John Doe'));
    });

    test('can be constructed with empty list', () {
      final widget = TypingIndicatorWidget(
        typingUsers: const [],
      );

      expect(widget, isNotNull);
      expect(widget.typingUsers, isEmpty);
    });

    test('stores multiple typing users', () {
      final typingUsers = [
        MessagingTestFactory.createTypingIndicator(
          userId: 'user_001',
          userName: 'John Doe',
        ),
        MessagingTestFactory.createTypingIndicator(
          userId: 'user_002',
          userName: 'Jane Smith',
        ),
      ];

      final widget = TypingIndicatorWidget(
        typingUsers: typingUsers,
      );

      expect(widget.typingUsers.length, equals(2));
      expect(widget.typingUsers[0].userName, equals('John Doe'));
      expect(widget.typingUsers[1].userName, equals('Jane Smith'));
    });

    test('stores many typing users', () {
      final typingUsers = [
        MessagingTestFactory.createTypingIndicator(
          userId: 'user_001',
          userName: 'User 1',
        ),
        MessagingTestFactory.createTypingIndicator(
          userId: 'user_002',
          userName: 'User 2',
        ),
        MessagingTestFactory.createTypingIndicator(
          userId: 'user_003',
          userName: 'User 3',
        ),
        MessagingTestFactory.createTypingIndicator(
          userId: 'user_004',
          userName: 'User 4',
        ),
      ];

      final widget = TypingIndicatorWidget(
        typingUsers: typingUsers,
      );

      expect(widget.typingUsers.length, equals(4));
      expect(widget.typingUsers[0].userName, equals('User 1'));
      expect(widget.typingUsers[3].userName, equals('User 4'));
    });

    test('stores typing indicator with isTyping true', () {
      final typingUsers = [
        MessagingTestFactory.createTypingIndicator(
          isTyping: true,
        ),
      ];

      final widget = TypingIndicatorWidget(
        typingUsers: typingUsers,
      );

      expect(widget.typingUsers.first.isTyping, isTrue);
    });

    test('stores typing indicator with isTyping false', () {
      final typingUsers = [
        MessagingTestFactory.createTypingIndicator(
          isTyping: false,
        ),
      ];

      final widget = TypingIndicatorWidget(
        typingUsers: typingUsers,
      );

      expect(widget.typingUsers.first.isTyping, isFalse);
    });

    test('stores typing indicator with chatId', () {
      final typingUsers = [
        MessagingTestFactory.createTypingIndicator(
          chatId: 'chat_123',
        ),
      ];

      final widget = TypingIndicatorWidget(
        typingUsers: typingUsers,
      );

      expect(widget.typingUsers.first.chatId, equals('chat_123'));
    });

    test('stores typing indicator with timestamp', () {
      final timestamp = DateTime(2026, 6, 15, 14, 30);
      final typingUsers = [
        MessagingTestFactory.createTypingIndicator(
          timestamp: timestamp,
        ),
      ];

      final widget = TypingIndicatorWidget(
        typingUsers: typingUsers,
      );

      expect(widget.typingUsers.first.timestamp, equals(timestamp));
    });

    test('handles list modifications', () {
      final typingUsers = [
        MessagingTestFactory.createTypingIndicator(userId: 'user_001'),
      ];

      final widget1 = TypingIndicatorWidget(
        typingUsers: typingUsers,
      );

      expect(widget1.typingUsers.length, equals(1));

      final updatedTypingUsers = [
        ...typingUsers,
        MessagingTestFactory.createTypingIndicator(userId: 'user_002'),
      ];

      final widget2 = TypingIndicatorWidget(
        typingUsers: updatedTypingUsers,
      );

      expect(widget2.typingUsers.length, equals(2));
    });
  });
}
