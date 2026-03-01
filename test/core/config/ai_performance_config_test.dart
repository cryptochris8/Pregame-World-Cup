import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/config/ai_performance_config.dart';

void main() {
  group('AIPerformanceConfig', () {
    group('timeout constants', () {
      test('overallAnalysisTimeout is 6 seconds', () {
        expect(AIPerformanceConfig.overallAnalysisTimeout,
            const Duration(seconds: 6));
      });

      test('memoryPressureTimeout is 3 seconds', () {
        expect(AIPerformanceConfig.memoryPressureTimeout,
            const Duration(seconds: 3));
      });

      test('parallelExecutionTimeout is 4 seconds', () {
        expect(AIPerformanceConfig.parallelExecutionTimeout,
            const Duration(seconds: 4));
      });

      test('predictionTimeout is 2 seconds', () {
        expect(AIPerformanceConfig.predictionTimeout,
            const Duration(seconds: 2));
      });

      test('summaryTimeout is 1 second', () {
        expect(AIPerformanceConfig.summaryTimeout,
            const Duration(seconds: 1));
      });

      test('playerDataTimeout is 1 second', () {
        expect(AIPerformanceConfig.playerDataTimeout,
            const Duration(seconds: 1));
      });
    });

    group('API timeout constants', () {
      test('openAITimeout is 5 seconds', () {
        expect(
            AIPerformanceConfig.openAITimeout, const Duration(seconds: 5));
      });

      test('claudeTimeout is 5 seconds', () {
        expect(
            AIPerformanceConfig.claudeTimeout, const Duration(seconds: 5));
      });

      test('sportsDataTimeout is 3 seconds', () {
        expect(AIPerformanceConfig.sportsDataTimeout,
            const Duration(seconds: 3));
      });
    });

    group('cache settings', () {
      test('cacheExpiry is 30 minutes', () {
        expect(AIPerformanceConfig.cacheExpiry,
            const Duration(minutes: 30));
      });

      test('maxCacheSize is 100', () {
        expect(AIPerformanceConfig.maxCacheSize, 100);
      });
    });

    group('memory optimization flags', () {
      test('enableParallelExecution is true', () {
        expect(AIPerformanceConfig.enableParallelExecution, isTrue);
      });

      test('enableAggressiveCaching is true', () {
        expect(AIPerformanceConfig.enableAggressiveCaching, isTrue);
      });

      test('enableFastFallbacks is true', () {
        expect(AIPerformanceConfig.enableFastFallbacks, isTrue);
      });
    });

    group('performance thresholds', () {
      test('memoryPressureThresholdMB is 512', () {
        expect(AIPerformanceConfig.memoryPressureThresholdMB, 512);
      });

      test('lowPerformanceDeviceThreshold is 1024', () {
        expect(AIPerformanceConfig.lowPerformanceDeviceThreshold, 1024);
      });
    });

    group('getAdaptiveTimeout', () {
      test('returns base timeout under normal conditions', () {
        final result = AIPerformanceConfig.getAdaptiveTimeout(
          baseTimeout: const Duration(seconds: 10),
        );
        expect(result, const Duration(seconds: 10));
      });

      test('returns 50% of base timeout under memory pressure', () {
        final result = AIPerformanceConfig.getAdaptiveTimeout(
          baseTimeout: const Duration(seconds: 10),
          isMemoryPressure: true,
        );
        expect(result, const Duration(seconds: 5));
      });

      test('returns 70% of base timeout on low performance device', () {
        final result = AIPerformanceConfig.getAdaptiveTimeout(
          baseTimeout: const Duration(seconds: 10),
          isLowPerformanceDevice: true,
        );
        expect(result, const Duration(seconds: 7));
      });

      test('memory pressure takes priority over low performance', () {
        final result = AIPerformanceConfig.getAdaptiveTimeout(
          baseTimeout: const Duration(seconds: 10),
          isMemoryPressure: true,
          isLowPerformanceDevice: true,
        );
        // Memory pressure (50%) takes precedence over low perf (70%)
        expect(result, const Duration(seconds: 5));
      });

      test('handles small base timeout', () {
        final result = AIPerformanceConfig.getAdaptiveTimeout(
          baseTimeout: const Duration(milliseconds: 100),
          isMemoryPressure: true,
        );
        expect(result, const Duration(milliseconds: 50));
      });

      test('handles zero base timeout', () {
        final result = AIPerformanceConfig.getAdaptiveTimeout(
          baseTimeout: Duration.zero,
          isMemoryPressure: true,
        );
        expect(result, Duration.zero);
      });

      test('works with predictionTimeout', () {
        final result = AIPerformanceConfig.getAdaptiveTimeout(
          baseTimeout: AIPerformanceConfig.predictionTimeout,
        );
        expect(result, AIPerformanceConfig.predictionTimeout);
      });

      test('memory pressure halves predictionTimeout', () {
        final result = AIPerformanceConfig.getAdaptiveTimeout(
          baseTimeout: AIPerformanceConfig.predictionTimeout,
          isMemoryPressure: true,
        );
        expect(result, const Duration(seconds: 1));
      });

      test('low performance reduces summaryTimeout', () {
        final result = AIPerformanceConfig.getAdaptiveTimeout(
          baseTimeout: AIPerformanceConfig.summaryTimeout,
          isLowPerformanceDevice: true,
        );
        // 1000ms * 0.7 = 700ms
        expect(result, const Duration(milliseconds: 700));
      });

      test('works with overallAnalysisTimeout', () {
        final result = AIPerformanceConfig.getAdaptiveTimeout(
          baseTimeout: AIPerformanceConfig.overallAnalysisTimeout,
          isMemoryPressure: true,
        );
        // 6000ms * 0.5 = 3000ms
        expect(result, const Duration(seconds: 3));
      });
    });

    group('isMemoryPressure', () {
      test('returns false (default implementation)', () {
        expect(AIPerformanceConfig.isMemoryPressure(), isFalse);
      });
    });

    group('isLowPerformanceDevice', () {
      test('returns false (default implementation)', () {
        expect(AIPerformanceConfig.isLowPerformanceDevice(), isFalse);
      });
    });

    group('timeout ordering', () {
      test('individual service timeouts are shorter than overall', () {
        expect(
          AIPerformanceConfig.predictionTimeout.inMilliseconds,
          lessThan(
              AIPerformanceConfig.overallAnalysisTimeout.inMilliseconds),
        );
        expect(
          AIPerformanceConfig.summaryTimeout.inMilliseconds,
          lessThan(
              AIPerformanceConfig.overallAnalysisTimeout.inMilliseconds),
        );
        expect(
          AIPerformanceConfig.playerDataTimeout.inMilliseconds,
          lessThan(
              AIPerformanceConfig.overallAnalysisTimeout.inMilliseconds),
        );
      });

      test('memory pressure timeout is less than overall', () {
        expect(
          AIPerformanceConfig.memoryPressureTimeout.inMilliseconds,
          lessThan(
              AIPerformanceConfig.overallAnalysisTimeout.inMilliseconds),
        );
      });

      test('parallel execution timeout is less than overall', () {
        expect(
          AIPerformanceConfig.parallelExecutionTimeout.inMilliseconds,
          lessThanOrEqualTo(
              AIPerformanceConfig.overallAnalysisTimeout.inMilliseconds),
        );
      });

      test('API timeouts are reasonable', () {
        expect(
          AIPerformanceConfig.openAITimeout.inSeconds,
          greaterThan(0),
        );
        expect(
          AIPerformanceConfig.claudeTimeout.inSeconds,
          greaterThan(0),
        );
        expect(
          AIPerformanceConfig.sportsDataTimeout.inSeconds,
          greaterThan(0),
        );
      });
    });

    group('all timeout values are positive', () {
      test('overallAnalysisTimeout is positive', () {
        expect(AIPerformanceConfig.overallAnalysisTimeout.inMilliseconds,
            greaterThan(0));
      });

      test('memoryPressureTimeout is positive', () {
        expect(AIPerformanceConfig.memoryPressureTimeout.inMilliseconds,
            greaterThan(0));
      });

      test('parallelExecutionTimeout is positive', () {
        expect(
            AIPerformanceConfig.parallelExecutionTimeout.inMilliseconds,
            greaterThan(0));
      });

      test('predictionTimeout is positive', () {
        expect(AIPerformanceConfig.predictionTimeout.inMilliseconds,
            greaterThan(0));
      });

      test('summaryTimeout is positive', () {
        expect(AIPerformanceConfig.summaryTimeout.inMilliseconds,
            greaterThan(0));
      });

      test('playerDataTimeout is positive', () {
        expect(AIPerformanceConfig.playerDataTimeout.inMilliseconds,
            greaterThan(0));
      });

      test('openAITimeout is positive', () {
        expect(AIPerformanceConfig.openAITimeout.inMilliseconds,
            greaterThan(0));
      });

      test('claudeTimeout is positive', () {
        expect(AIPerformanceConfig.claudeTimeout.inMilliseconds,
            greaterThan(0));
      });

      test('sportsDataTimeout is positive', () {
        expect(AIPerformanceConfig.sportsDataTimeout.inMilliseconds,
            greaterThan(0));
      });

      test('cacheExpiry is positive', () {
        expect(AIPerformanceConfig.cacheExpiry.inMilliseconds,
            greaterThan(0));
      });

      test('maxCacheSize is positive', () {
        expect(AIPerformanceConfig.maxCacheSize, greaterThan(0));
      });

      test('memoryPressureThresholdMB is positive', () {
        expect(AIPerformanceConfig.memoryPressureThresholdMB,
            greaterThan(0));
      });

      test('lowPerformanceDeviceThreshold is positive', () {
        expect(AIPerformanceConfig.lowPerformanceDeviceThreshold,
            greaterThan(0));
      });
    });
  });
}
