import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/services/performance_monitor.dart';

void main() {
  // PerformanceMonitor uses static state, so we must reset between tests.
  setUp(() {
    PerformanceMonitor.reset();
  });

  group('PerformanceMonitor', () {
    group('reset', () {
      test('clears all statistics', () {
        PerformanceMonitor.recordCacheHit('key1');
        PerformanceMonitor.recordCacheMiss('key2');
        PerformanceMonitor.startApiCall('call1');
        PerformanceMonitor.endApiCall('call1');

        PerformanceMonitor.reset();
        final stats = PerformanceMonitor.getStats();

        expect(stats['cache_hits'], equals(0));
        expect(stats['cache_misses'], equals(0));
        expect(stats['api_calls'], equals(0));
        expect(stats['average_api_time_ms'], equals('0.0'));
        expect(stats['pending_calls'], equals(0));
      });

      test('executes without throwing', () {
        expect(() => PerformanceMonitor.reset(), returnsNormally);
      });

      test('can be called multiple times safely', () {
        PerformanceMonitor.reset();
        PerformanceMonitor.reset();
        PerformanceMonitor.reset();
        final stats = PerformanceMonitor.getStats();
        expect(stats['cache_hits'], equals(0));
      });
    });

    group('recordCacheHit', () {
      test('increments cache hit count', () {
        PerformanceMonitor.recordCacheHit('key1');
        final stats = PerformanceMonitor.getStats();
        expect(stats['cache_hits'], equals(1));
      });

      test('increments for each call', () {
        PerformanceMonitor.recordCacheHit('key1');
        PerformanceMonitor.recordCacheHit('key2');
        PerformanceMonitor.recordCacheHit('key3');
        final stats = PerformanceMonitor.getStats();
        expect(stats['cache_hits'], equals(3));
      });

      test('increments for same key called multiple times', () {
        PerformanceMonitor.recordCacheHit('key1');
        PerformanceMonitor.recordCacheHit('key1');
        final stats = PerformanceMonitor.getStats();
        expect(stats['cache_hits'], equals(2));
      });

      test('does not affect cache miss count', () {
        PerformanceMonitor.recordCacheHit('key1');
        final stats = PerformanceMonitor.getStats();
        expect(stats['cache_misses'], equals(0));
      });
    });

    group('recordCacheMiss', () {
      test('increments cache miss count', () {
        PerformanceMonitor.recordCacheMiss('key1');
        final stats = PerformanceMonitor.getStats();
        expect(stats['cache_misses'], equals(1));
      });

      test('increments for each call', () {
        PerformanceMonitor.recordCacheMiss('key1');
        PerformanceMonitor.recordCacheMiss('key2');
        PerformanceMonitor.recordCacheMiss('key3');
        final stats = PerformanceMonitor.getStats();
        expect(stats['cache_misses'], equals(3));
      });

      test('does not affect cache hit count', () {
        PerformanceMonitor.recordCacheMiss('key1');
        final stats = PerformanceMonitor.getStats();
        expect(stats['cache_hits'], equals(0));
      });
    });

    group('cache hit rate', () {
      test('is 100% when all hits and no misses', () {
        PerformanceMonitor.recordCacheHit('key1');
        PerformanceMonitor.recordCacheHit('key2');
        final stats = PerformanceMonitor.getStats();
        expect(stats['cache_hit_rate'], equals('100.0'));
      });

      test('is 0% when all misses and no hits', () {
        PerformanceMonitor.recordCacheMiss('key1');
        PerformanceMonitor.recordCacheMiss('key2');
        final stats = PerformanceMonitor.getStats();
        expect(stats['cache_hit_rate'], equals('0.0'));
      });

      test('is 50% when equal hits and misses', () {
        PerformanceMonitor.recordCacheHit('key1');
        PerformanceMonitor.recordCacheMiss('key2');
        final stats = PerformanceMonitor.getStats();
        expect(stats['cache_hit_rate'], equals('50.0'));
      });

      test('is 0.0 when no cache operations', () {
        final stats = PerformanceMonitor.getStats();
        expect(stats['cache_hit_rate'], equals('0.0'));
      });

      test('calculates correctly for 3 hits and 1 miss', () {
        PerformanceMonitor.recordCacheHit('a');
        PerformanceMonitor.recordCacheHit('b');
        PerformanceMonitor.recordCacheHit('c');
        PerformanceMonitor.recordCacheMiss('d');
        final stats = PerformanceMonitor.getStats();
        expect(stats['cache_hit_rate'], equals('75.0'));
      });
    });

    group('startApiCall and endApiCall', () {
      test('tracks a completed API call', () {
        PerformanceMonitor.startApiCall('fetchMatches');
        PerformanceMonitor.endApiCall('fetchMatches');

        final stats = PerformanceMonitor.getStats();
        expect(stats['api_calls'], equals(1));
        expect(stats['pending_calls'], equals(0));
      });

      test('tracks a pending API call', () {
        PerformanceMonitor.startApiCall('fetchMatches');
        final stats = PerformanceMonitor.getStats();
        expect(stats['pending_calls'], equals(1));
        expect(stats['api_calls'], equals(0));
      });

      test('removes pending call when ended', () {
        PerformanceMonitor.startApiCall('call1');
        expect(PerformanceMonitor.getStats()['pending_calls'], equals(1));

        PerformanceMonitor.endApiCall('call1');
        expect(PerformanceMonitor.getStats()['pending_calls'], equals(0));
      });

      test('tracks multiple concurrent API calls', () {
        PerformanceMonitor.startApiCall('call1');
        PerformanceMonitor.startApiCall('call2');
        PerformanceMonitor.startApiCall('call3');

        var stats = PerformanceMonitor.getStats();
        expect(stats['pending_calls'], equals(3));
        expect(stats['api_calls'], equals(0));

        PerformanceMonitor.endApiCall('call2');
        stats = PerformanceMonitor.getStats();
        expect(stats['pending_calls'], equals(2));
        expect(stats['api_calls'], equals(1));
      });

      test('endApiCall with unknown id does not increment api_calls', () {
        PerformanceMonitor.endApiCall('nonexistent');
        final stats = PerformanceMonitor.getStats();
        expect(stats['api_calls'], equals(0));
      });

      test('endApiCall with success=false still counts as completed', () {
        PerformanceMonitor.startApiCall('failedCall');
        PerformanceMonitor.endApiCall('failedCall', success: false);

        final stats = PerformanceMonitor.getStats();
        expect(stats['api_calls'], equals(1));
        expect(stats['pending_calls'], equals(0));
      });

      test('records non-negative API call time', () {
        PerformanceMonitor.startApiCall('timedCall');
        // endApiCall immediately; time should be very small but non-negative
        PerformanceMonitor.endApiCall('timedCall');

        final stats = PerformanceMonitor.getStats();
        final avgTime = double.parse(stats['average_api_time_ms'] as String);
        expect(avgTime, greaterThanOrEqualTo(0.0));
      });

      test('average API time is 0 with no completed calls', () {
        final stats = PerformanceMonitor.getStats();
        expect(stats['average_api_time_ms'], equals('0.0'));
      });

      test('calling endApiCall twice for same id only counts once', () {
        PerformanceMonitor.startApiCall('duplicateEnd');
        PerformanceMonitor.endApiCall('duplicateEnd');
        PerformanceMonitor.endApiCall('duplicateEnd');

        final stats = PerformanceMonitor.getStats();
        expect(stats['api_calls'], equals(1));
      });

      test('restarting same call id overwrites the pending entry', () {
        PerformanceMonitor.startApiCall('overwrite');
        PerformanceMonitor.startApiCall('overwrite');

        final stats = PerformanceMonitor.getStats();
        // Only one pending call since same key was overwritten
        expect(stats['pending_calls'], equals(1));
      });
    });

    group('getStats', () {
      test('returns correct keys', () {
        final stats = PerformanceMonitor.getStats();
        expect(stats.containsKey('cache_hits'), isTrue);
        expect(stats.containsKey('cache_misses'), isTrue);
        expect(stats.containsKey('cache_hit_rate'), isTrue);
        expect(stats.containsKey('api_calls'), isTrue);
        expect(stats.containsKey('average_api_time_ms'), isTrue);
        expect(stats.containsKey('pending_calls'), isTrue);
      });

      test('returns correct types', () {
        final stats = PerformanceMonitor.getStats();
        expect(stats['cache_hits'], isA<int>());
        expect(stats['cache_misses'], isA<int>());
        expect(stats['cache_hit_rate'], isA<String>());
        expect(stats['api_calls'], isA<int>());
        expect(stats['average_api_time_ms'], isA<String>());
        expect(stats['pending_calls'], isA<int>());
      });

      test('returns initial zero values', () {
        final stats = PerformanceMonitor.getStats();
        expect(stats['cache_hits'], equals(0));
        expect(stats['cache_misses'], equals(0));
        expect(stats['cache_hit_rate'], equals('0.0'));
        expect(stats['api_calls'], equals(0));
        expect(stats['average_api_time_ms'], equals('0.0'));
        expect(stats['pending_calls'], equals(0));
      });

      test('reflects accumulated operations', () {
        PerformanceMonitor.recordCacheHit('a');
        PerformanceMonitor.recordCacheHit('b');
        PerformanceMonitor.recordCacheMiss('c');
        PerformanceMonitor.startApiCall('call1');
        PerformanceMonitor.endApiCall('call1');
        PerformanceMonitor.startApiCall('call2');

        final stats = PerformanceMonitor.getStats();
        expect(stats['cache_hits'], equals(2));
        expect(stats['cache_misses'], equals(1));
        expect(stats['cache_hit_rate'], equals('66.7'));
        expect(stats['api_calls'], equals(1));
        expect(stats['pending_calls'], equals(1));
      });
    });

    group('printSummary', () {
      test('executes without throwing when no data', () {
        expect(() => PerformanceMonitor.printSummary(), returnsNormally);
      });

      test('executes without throwing with data', () {
        PerformanceMonitor.recordCacheHit('key');
        PerformanceMonitor.recordCacheMiss('key2');
        PerformanceMonitor.startApiCall('call1');
        PerformanceMonitor.endApiCall('call1');

        expect(() => PerformanceMonitor.printSummary(), returnsNormally);
      });

      test('does not modify statistics', () {
        PerformanceMonitor.recordCacheHit('key');
        PerformanceMonitor.recordCacheMiss('key2');

        final statsBefore = PerformanceMonitor.getStats();
        PerformanceMonitor.printSummary();
        final statsAfter = PerformanceMonitor.getStats();

        expect(statsAfter['cache_hits'], equals(statsBefore['cache_hits']));
        expect(
            statsAfter['cache_misses'], equals(statsBefore['cache_misses']));
        expect(statsAfter['api_calls'], equals(statsBefore['api_calls']));
      });
    });

    group('integration scenarios', () {
      test('simulates a typical session lifecycle', () {
        // Cache lookups
        PerformanceMonitor.recordCacheMiss('matches_list');
        PerformanceMonitor.recordCacheHit('team_Brazil');
        PerformanceMonitor.recordCacheHit('team_Argentina');
        PerformanceMonitor.recordCacheMiss('predictions');
        PerformanceMonitor.recordCacheHit('team_France');

        // API calls
        PerformanceMonitor.startApiCall('fetchMatches');
        PerformanceMonitor.endApiCall('fetchMatches');
        PerformanceMonitor.startApiCall('fetchPredictions');
        PerformanceMonitor.endApiCall('fetchPredictions');

        final stats = PerformanceMonitor.getStats();
        expect(stats['cache_hits'], equals(3));
        expect(stats['cache_misses'], equals(2));
        expect(stats['cache_hit_rate'], equals('60.0'));
        expect(stats['api_calls'], equals(2));
        expect(stats['pending_calls'], equals(0));
      });

      test('handles rapid successive operations', () {
        for (var i = 0; i < 100; i++) {
          PerformanceMonitor.recordCacheHit('key_$i');
        }
        for (var i = 0; i < 50; i++) {
          PerformanceMonitor.recordCacheMiss('miss_$i');
        }

        final stats = PerformanceMonitor.getStats();
        expect(stats['cache_hits'], equals(100));
        expect(stats['cache_misses'], equals(50));
        expect(stats['cache_hit_rate'], equals('66.7'));
      });

      test('reset mid-session clears everything', () {
        PerformanceMonitor.recordCacheHit('key');
        PerformanceMonitor.startApiCall('call1');

        PerformanceMonitor.reset();

        PerformanceMonitor.recordCacheMiss('new_key');
        final stats = PerformanceMonitor.getStats();
        expect(stats['cache_hits'], equals(0));
        expect(stats['cache_misses'], equals(1));
        expect(stats['pending_calls'], equals(0));
        expect(stats['api_calls'], equals(0));
      });
    });
  });
}
