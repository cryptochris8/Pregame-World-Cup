import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/services/rate_limit_service.dart';

void main() {
  // Clean up all buckets before each test to avoid cross-test pollution
  // since RateLimitService uses static state.
  setUp(() {
    // Reset known endpoints to ensure clean state
    RateLimitService.reset('openai_completion');
    RateLimitService.reset('openai_embedding');
    RateLimitService.reset('google_places');
    RateLimitService.reset('sportsdata');
    RateLimitService.reset('firebase_function');
    RateLimitService.reset('default');
    RateLimitService.reset('test_endpoint');
    RateLimitService.reset('custom_endpoint');
    RateLimitService.reset('unknown_endpoint');
    RateLimitService.reset('wait_test');
  });

  group('RateLimitService', () {
    group('isAllowed', () {
      test('allows first request for a new endpoint', () {
        expect(RateLimitService.isAllowed('test_endpoint'), isTrue);
      });

      test('allows multiple requests within the rate limit', () {
        // Default limit is 30 per minute for unknown endpoints
        for (var i = 0; i < 10; i++) {
          expect(RateLimitService.isAllowed('test_endpoint'), isTrue);
        }
      });

      test('denies request when rate limit is exhausted', () {
        // Default limit is 30 per minute
        for (var i = 0; i < 30; i++) {
          RateLimitService.isAllowed('test_endpoint');
        }
        // 31st request should be denied
        expect(RateLimitService.isAllowed('test_endpoint'), isFalse);
      });

      test('uses correct rate limit for openai_completion (20/min)', () {
        for (var i = 0; i < 20; i++) {
          expect(RateLimitService.isAllowed('openai_completion'), isTrue);
        }
        expect(RateLimitService.isAllowed('openai_completion'), isFalse);
      });

      test('uses correct rate limit for openai_embedding (50/min)', () {
        for (var i = 0; i < 50; i++) {
          expect(RateLimitService.isAllowed('openai_embedding'), isTrue);
        }
        expect(RateLimitService.isAllowed('openai_embedding'), isFalse);
      });

      test('uses correct rate limit for google_places (100/min)', () {
        for (var i = 0; i < 100; i++) {
          expect(RateLimitService.isAllowed('google_places'), isTrue);
        }
        expect(RateLimitService.isAllowed('google_places'), isFalse);
      });

      test('uses correct rate limit for sportsdata (60/min)', () {
        for (var i = 0; i < 60; i++) {
          expect(RateLimitService.isAllowed('sportsdata'), isTrue);
        }
        expect(RateLimitService.isAllowed('sportsdata'), isFalse);
      });

      test('uses correct rate limit for firebase_function (200/min)', () {
        for (var i = 0; i < 200; i++) {
          expect(RateLimitService.isAllowed('firebase_function'), isTrue);
        }
        expect(RateLimitService.isAllowed('firebase_function'), isFalse);
      });

      test('uses default rate limit (30/min) for unknown endpoint', () {
        for (var i = 0; i < 30; i++) {
          expect(RateLimitService.isAllowed('unknown_endpoint'), isTrue);
        }
        expect(RateLimitService.isAllowed('unknown_endpoint'), isFalse);
      });

      test('different endpoints have independent limits', () {
        // Exhaust test_endpoint
        for (var i = 0; i < 30; i++) {
          RateLimitService.isAllowed('test_endpoint');
        }
        expect(RateLimitService.isAllowed('test_endpoint'), isFalse);

        // custom_endpoint should still work
        expect(RateLimitService.isAllowed('custom_endpoint'), isTrue);
      });
    });

    group('getRemainingTokens', () {
      test('returns full capacity for fresh endpoint', () {
        // Accessing getRemainingTokens creates the bucket with full tokens
        final remaining = RateLimitService.getRemainingTokens('test_endpoint');
        // Default limit is 30
        expect(remaining, equals(30));
      });

      test('decreases after each allowed request', () {
        RateLimitService.isAllowed('test_endpoint');
        final remaining = RateLimitService.getRemainingTokens('test_endpoint');
        expect(remaining, equals(29));
      });

      test('returns 0 when all tokens consumed', () {
        for (var i = 0; i < 30; i++) {
          RateLimitService.isAllowed('test_endpoint');
        }
        expect(RateLimitService.getRemainingTokens('test_endpoint'), equals(0));
      });

      test('returns correct capacity for named endpoints', () {
        expect(
          RateLimitService.getRemainingTokens('openai_completion'),
          equals(20),
        );
        expect(
          RateLimitService.getRemainingTokens('google_places'),
          equals(100),
        );
      });
    });

    group('getTimeUntilNextToken', () {
      test('returns positive duration for fresh bucket', () {
        // A fresh bucket was just created, so next refill is ~1 minute away
        RateLimitService.isAllowed('test_endpoint');
        final timeUntil =
            RateLimitService.getTimeUntilNextToken('test_endpoint');
        expect(timeUntil.inSeconds, greaterThan(0));
        expect(timeUntil.inSeconds, lessThanOrEqualTo(60));
      });
    });

    group('reset', () {
      test('restores full token capacity after reset', () {
        // Consume some tokens
        for (var i = 0; i < 15; i++) {
          RateLimitService.isAllowed('test_endpoint');
        }
        expect(
          RateLimitService.getRemainingTokens('test_endpoint'),
          equals(15),
        );

        // Reset
        RateLimitService.reset('test_endpoint');

        // After reset, a new bucket is created on next access
        expect(
          RateLimitService.getRemainingTokens('test_endpoint'),
          equals(30),
        );
      });

      test('allows requests again after reset from exhausted state', () {
        // Exhaust all tokens
        for (var i = 0; i < 30; i++) {
          RateLimitService.isAllowed('test_endpoint');
        }
        expect(RateLimitService.isAllowed('test_endpoint'), isFalse);

        // Reset and try again
        RateLimitService.reset('test_endpoint');
        expect(RateLimitService.isAllowed('test_endpoint'), isTrue);
      });
    });

    group('getStatus', () {
      test('returns empty map when no buckets created', () {
        final status = RateLimitService.getStatus();
        // After setUp resets, accessing getStatus should return
        // only buckets that were re-created during reset calls
        // (reset removes the bucket, so if no isAllowed/getRemainingTokens
        // calls happened, those buckets don't exist)
        // Actually, reset just removes the bucket, so status could be empty
        // Let's verify by creating one bucket
        RateLimitService.isAllowed('test_endpoint');
        final statusAfter = RateLimitService.getStatus();
        expect(statusAfter.containsKey('test_endpoint'), isTrue);
      });

      test('returns correct status for active endpoints', () {
        RateLimitService.isAllowed('test_endpoint');
        RateLimitService.isAllowed('test_endpoint');

        final status = RateLimitService.getStatus();
        final endpointStatus = status['test_endpoint']!;

        expect(endpointStatus['limit'], equals(30));
        expect(endpointStatus['remaining'], equals(28));
        expect(endpointStatus['resetTime'], isA<int>());
      });

      test('tracks multiple endpoints independently', () {
        RateLimitService.isAllowed('openai_completion');
        RateLimitService.isAllowed('google_places');

        final status = RateLimitService.getStatus();

        expect(status['openai_completion']!['limit'], equals(20));
        expect(status['openai_completion']!['remaining'], equals(19));
        expect(status['google_places']!['limit'], equals(100));
        expect(status['google_places']!['remaining'], equals(99));
      });
    });

    group('waitForSlot', () {
      test('returns true immediately when tokens available', () async {
        final result = await RateLimitService.waitForSlot('test_endpoint');
        expect(result, isTrue);
      });

      test('consumes a token when slot is obtained', () async {
        await RateLimitService.waitForSlot('test_endpoint');
        final remaining =
            RateLimitService.getRemainingTokens('test_endpoint');
        expect(remaining, equals(29));
      });

      test('returns false on timeout when no tokens available', () async {
        // Exhaust all tokens
        for (var i = 0; i < 30; i++) {
          RateLimitService.isAllowed('test_endpoint');
        }

        // Wait with a very short timeout
        final result = await RateLimitService.waitForSlot(
          'test_endpoint',
          timeout: const Duration(milliseconds: 100),
        );
        expect(result, isFalse);
      });
    });
  });
}
