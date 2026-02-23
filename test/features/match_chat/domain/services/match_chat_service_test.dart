import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/match_chat/domain/services/match_chat_service.dart';

/// Tests for SendMessageResult and RateLimitResult value classes
/// defined in the match_chat_service.dart file.
///
/// Note: MatchChatService itself requires Firebase (Firestore, Auth) and
/// ModerationService, which are singletons with Firebase dependencies.
/// The service uses a singleton pattern with internal Firebase calls,
/// making direct unit testing without fake_cloud_firestore impractical.
/// These tests focus on the result types and rate limiting logic that
/// can be tested without Firebase.
void main() {
  // ==================== SendMessageResult ====================
  group('SendMessageResult', () {
    test('success factory creates successful result', () {
      final result = SendMessageResult.success();

      expect(result.success, isTrue);
      expect(result.error, isNull);
      expect(result.waitSeconds, isNull);
      expect(result.maxLength, isNull);
    });

    test('notAuthenticated factory creates error result', () {
      final result = SendMessageResult.notAuthenticated();

      expect(result.success, isFalse);
      expect(result.error, equals('Not authenticated'));
      expect(result.waitSeconds, isNull);
      expect(result.maxLength, isNull);
    });

    test('rateLimited factory creates rate limited result with wait seconds', () {
      final result = SendMessageResult.rateLimited(5);

      expect(result.success, isFalse);
      expect(result.error, equals('Rate limited'));
      expect(result.waitSeconds, equals(5));
      expect(result.maxLength, isNull);
    });

    test('rateLimited with zero seconds', () {
      final result = SendMessageResult.rateLimited(0);

      expect(result.success, isFalse);
      expect(result.error, equals('Rate limited'));
      expect(result.waitSeconds, equals(0));
    });

    test('contentTooLong factory creates result with max length', () {
      final result = SendMessageResult.contentTooLong(500);

      expect(result.success, isFalse);
      expect(result.error, equals('Message too long'));
      expect(result.maxLength, equals(500));
      expect(result.waitSeconds, isNull);
    });

    test('blocked factory creates result with reason', () {
      final result = SendMessageResult.blocked('Profanity detected');

      expect(result.success, isFalse);
      expect(result.error, equals('Profanity detected'));
      expect(result.waitSeconds, isNull);
      expect(result.maxLength, isNull);
    });

    test('error factory creates result with error string', () {
      final result = SendMessageResult.error('Something went wrong');

      expect(result.success, isFalse);
      expect(result.error, equals('Something went wrong'));
      expect(result.waitSeconds, isNull);
      expect(result.maxLength, isNull);
    });

    test('error factory with empty string', () {
      final result = SendMessageResult.error('');

      expect(result.success, isFalse);
      expect(result.error, equals(''));
    });
  });

  // ==================== RateLimitResult ====================
  group('RateLimitResult', () {
    test('allowed result has waitSeconds defaulting to 0', () {
      final result = RateLimitResult(allowed: true);

      expect(result.allowed, isTrue);
      expect(result.waitSeconds, equals(0));
    });

    test('denied result includes wait seconds', () {
      final result = RateLimitResult(allowed: false, waitSeconds: 7);

      expect(result.allowed, isFalse);
      expect(result.waitSeconds, equals(7));
    });

    test('denied result defaults waitSeconds to 0', () {
      final result = RateLimitResult(allowed: false);

      expect(result.allowed, isFalse);
      expect(result.waitSeconds, equals(0));
    });

    test('allowed result with explicit waitSeconds', () {
      final result = RateLimitResult(allowed: true, waitSeconds: 0);

      expect(result.allowed, isTrue);
      expect(result.waitSeconds, equals(0));
    });
  });
}
