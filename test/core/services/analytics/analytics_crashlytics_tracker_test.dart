import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:pregame_world_cup/core/services/analytics/analytics_crashlytics_tracker.dart';

class MockFirebaseCrashlytics extends Mock implements FirebaseCrashlytics {}

void main() {
  late MockFirebaseCrashlytics mockCrashlytics;
  late AnalyticsCrashlyticsTracker tracker;

  setUp(() {
    mockCrashlytics = MockFirebaseCrashlytics();
    tracker = AnalyticsCrashlyticsTracker(mockCrashlytics);
  });

  group('AnalyticsCrashlyticsTracker', () {
    group('logFatalError', () {
      test('records fatal error with default reason when context is null', () async {
        final error = Exception('test error');
        final stackTrace = StackTrace.current;

        when(() => mockCrashlytics.recordError(
          any(),
          any(),
          reason: any(named: 'reason'),
          fatal: any(named: 'fatal'),
        )).thenAnswer((_) async {});

        await tracker.logFatalError(
          error: error,
          stackTrace: stackTrace,
        );

        verify(() => mockCrashlytics.recordError(
          error,
          stackTrace,
          reason: 'Fatal error',
          fatal: true,
        )).called(1);
      });

      test('records fatal error with provided context', () async {
        final error = Exception('crash');
        final stackTrace = StackTrace.current;

        when(() => mockCrashlytics.recordError(
          any(),
          any(),
          reason: any(named: 'reason'),
          fatal: any(named: 'fatal'),
        )).thenAnswer((_) async {});

        await tracker.logFatalError(
          error: error,
          stackTrace: stackTrace,
          context: 'UI rendering',
        );

        verify(() => mockCrashlytics.recordError(
          error,
          stackTrace,
          reason: 'UI rendering',
          fatal: true,
        )).called(1);
      });
    });

    group('setCrashlyticsKey', () {
      test('sets String key', () async {
        when(() => mockCrashlytics.setCustomKey(any(), any<String>()))
            .thenAnswer((_) async {});

        await tracker.setCrashlyticsKey('user_type', 'premium');

        verify(() => mockCrashlytics.setCustomKey('user_type', 'premium')).called(1);
      });

      test('sets int key', () async {
        when(() => mockCrashlytics.setCustomKey(any(), any<int>()))
            .thenAnswer((_) async {});

        await tracker.setCrashlyticsKey('login_count', 5);

        verify(() => mockCrashlytics.setCustomKey('login_count', 5)).called(1);
      });

      test('sets double key', () async {
        when(() => mockCrashlytics.setCustomKey(any(), any<double>()))
            .thenAnswer((_) async {});

        await tracker.setCrashlyticsKey('latitude', 40.7128);

        verify(() => mockCrashlytics.setCustomKey('latitude', 40.7128)).called(1);
      });

      test('sets bool key', () async {
        when(() => mockCrashlytics.setCustomKey(any(), any<bool>()))
            .thenAnswer((_) async {});

        await tracker.setCrashlyticsKey('is_premium', true);

        verify(() => mockCrashlytics.setCustomKey('is_premium', true)).called(1);
      });

      test('converts non-primitive types to String', () async {
        when(() => mockCrashlytics.setCustomKey(any(), any<String>()))
            .thenAnswer((_) async {});

        await tracker.setCrashlyticsKey('data', [1, 2, 3]);

        verify(() => mockCrashlytics.setCustomKey('data', '[1, 2, 3]')).called(1);
      });

      test('handles errors without throwing', () async {
        when(() => mockCrashlytics.setCustomKey(any(), any<String>()))
            .thenThrow(Exception('Crashlytics error'));

        // Should not throw
        await tracker.setCrashlyticsKey('key', 'value');
      });
    });

    group('logBreadcrumb', () {
      test('logs message to crashlytics', () async {
        when(() => mockCrashlytics.log(any()))
            .thenAnswer((_) async {});

        await tracker.logBreadcrumb('User tapped checkout');

        verify(() => mockCrashlytics.log('User tapped checkout')).called(1);
      });
    });
  });
}
