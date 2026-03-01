import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/messaging/domain/entities/typing_indicator.dart';

void main() {
  group('TypingIndicator', () {
    final testTimestamp = DateTime(2026, 6, 14, 18, 30, 0);

    TypingIndicator createIndicator({
      String chatId = 'chat_1',
      String userId = 'user_1',
      String userName = 'John',
      DateTime? timestamp,
      bool isTyping = true,
    }) {
      return TypingIndicator(
        chatId: chatId,
        userId: userId,
        userName: userName,
        timestamp: timestamp ?? testTimestamp,
        isTyping: isTyping,
      );
    }

    group('Constructor', () {
      test('creates indicator with all required fields', () {
        final indicator = createIndicator();

        expect(indicator.chatId, equals('chat_1'));
        expect(indicator.userId, equals('user_1'));
        expect(indicator.userName, equals('John'));
        expect(indicator.timestamp, equals(testTimestamp));
        expect(indicator.isTyping, isTrue);
      });

      test('creates indicator with isTyping false', () {
        final indicator = createIndicator(isTyping: false);
        expect(indicator.isTyping, isFalse);
      });
    });

    group('isExpired', () {
      test('returns true when timestamp is older than 3 seconds', () {
        final oldTimestamp = DateTime.now().subtract(const Duration(seconds: 5));
        final indicator = createIndicator(timestamp: oldTimestamp);

        expect(indicator.isExpired, isTrue);
      });

      test('returns false when timestamp is within 3 seconds', () {
        final recentTimestamp = DateTime.now().subtract(const Duration(seconds: 1));
        final indicator = createIndicator(timestamp: recentTimestamp);

        expect(indicator.isExpired, isFalse);
      });

      test('returns false when timestamp is now', () {
        final indicator = createIndicator(timestamp: DateTime.now());

        expect(indicator.isExpired, isFalse);
      });

      test('returns true when timestamp is exactly 4 seconds ago', () {
        final timestamp = DateTime.now().subtract(const Duration(seconds: 4));
        final indicator = createIndicator(timestamp: timestamp);

        expect(indicator.isExpired, isTrue);
      });

      test('returns true for very old timestamps', () {
        final oldTimestamp = DateTime(2020, 1, 1);
        final indicator = createIndicator(timestamp: oldTimestamp);

        expect(indicator.isExpired, isTrue);
      });
    });

    group('copyWith', () {
      test('updates chatId', () {
        final original = createIndicator();
        final updated = original.copyWith(chatId: 'chat_2');

        expect(updated.chatId, equals('chat_2'));
        expect(updated.userId, equals(original.userId));
        expect(updated.userName, equals(original.userName));
      });

      test('updates userId', () {
        final original = createIndicator();
        final updated = original.copyWith(userId: 'user_2');

        expect(updated.userId, equals('user_2'));
        expect(updated.chatId, equals(original.chatId));
      });

      test('updates userName', () {
        final original = createIndicator();
        final updated = original.copyWith(userName: 'Jane');

        expect(updated.userName, equals('Jane'));
      });

      test('updates timestamp', () {
        final original = createIndicator();
        final newTime = DateTime(2026, 7, 1);
        final updated = original.copyWith(timestamp: newTime);

        expect(updated.timestamp, equals(newTime));
      });

      test('updates isTyping', () {
        final original = createIndicator(isTyping: true);
        final updated = original.copyWith(isTyping: false);

        expect(updated.isTyping, isFalse);
        expect(updated.chatId, equals(original.chatId));
      });

      test('preserves all fields when no updates given', () {
        final original = createIndicator();
        final copy = original.copyWith();

        expect(copy.chatId, equals(original.chatId));
        expect(copy.userId, equals(original.userId));
        expect(copy.userName, equals(original.userName));
        expect(copy.timestamp, equals(original.timestamp));
        expect(copy.isTyping, equals(original.isTyping));
      });

      test('updates multiple fields at once', () {
        final original = createIndicator();
        final updated = original.copyWith(
          chatId: 'chat_new',
          userId: 'user_new',
          isTyping: false,
        );

        expect(updated.chatId, equals('chat_new'));
        expect(updated.userId, equals('user_new'));
        expect(updated.isTyping, isFalse);
        expect(updated.userName, equals(original.userName));
      });
    });

    group('JSON serialization', () {
      group('toJson', () {
        test('serializes all fields', () {
          final indicator = createIndicator();
          final json = indicator.toJson();

          expect(json['chatId'], equals('chat_1'));
          expect(json['userId'], equals('user_1'));
          expect(json['userName'], equals('John'));
          expect(json['timestamp'], equals(testTimestamp.toIso8601String()));
          expect(json['isTyping'], isTrue);
        });

        test('serializes isTyping false', () {
          final indicator = createIndicator(isTyping: false);
          final json = indicator.toJson();

          expect(json['isTyping'], isFalse);
        });
      });

      group('fromJson', () {
        test('deserializes all fields', () {
          final json = {
            'chatId': 'chat_test',
            'userId': 'user_test',
            'userName': 'Test User',
            'timestamp': '2026-06-14T18:30:00.000',
            'isTyping': true,
          };

          final indicator = TypingIndicator.fromJson(json);

          expect(indicator.chatId, equals('chat_test'));
          expect(indicator.userId, equals('user_test'));
          expect(indicator.userName, equals('Test User'));
          expect(indicator.timestamp.year, equals(2026));
          expect(indicator.timestamp.month, equals(6));
          expect(indicator.isTyping, isTrue);
        });

        test('deserializes isTyping false', () {
          final json = {
            'chatId': 'chat_1',
            'userId': 'user_1',
            'userName': 'User',
            'timestamp': '2026-06-14T18:30:00.000',
            'isTyping': false,
          };

          final indicator = TypingIndicator.fromJson(json);
          expect(indicator.isTyping, isFalse);
        });
      });

      group('roundtrip', () {
        test('toJson/fromJson preserves all data', () {
          final original = createIndicator(
            chatId: 'chat_roundtrip',
            userId: 'user_roundtrip',
            userName: 'Roundtrip User',
            isTyping: true,
          );

          final json = original.toJson();
          final restored = TypingIndicator.fromJson(json);

          expect(restored.chatId, equals(original.chatId));
          expect(restored.userId, equals(original.userId));
          expect(restored.userName, equals(original.userName));
          expect(restored.isTyping, equals(original.isTyping));
        });

        test('preserves isTyping false through roundtrip', () {
          final original = createIndicator(isTyping: false);

          final json = original.toJson();
          final restored = TypingIndicator.fromJson(json);

          expect(restored.isTyping, isFalse);
        });
      });
    });

    group('Equatable', () {
      test('equal indicators are equal', () {
        final i1 = createIndicator();
        final i2 = createIndicator();

        expect(i1, equals(i2));
      });

      test('different chatId makes not equal', () {
        final i1 = createIndicator(chatId: 'chat_1');
        final i2 = createIndicator(chatId: 'chat_2');

        expect(i1, isNot(equals(i2)));
      });

      test('different userId makes not equal', () {
        final i1 = createIndicator(userId: 'user_1');
        final i2 = createIndicator(userId: 'user_2');

        expect(i1, isNot(equals(i2)));
      });

      test('different isTyping makes not equal', () {
        final i1 = createIndicator(isTyping: true);
        final i2 = createIndicator(isTyping: false);

        expect(i1, isNot(equals(i2)));
      });

      test('different timestamp makes not equal', () {
        final i1 = createIndicator(timestamp: DateTime(2026, 6, 14));
        final i2 = createIndicator(timestamp: DateTime(2026, 6, 15));

        expect(i1, isNot(equals(i2)));
      });
    });
  });
}
