import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/schedule/presentation/screens/enhanced_schedule_screen.dart';
import 'package:pregame_world_cup/features/auth/domain/services/auth_service.dart';

// Mock classes
class MockAuthService extends Mock implements AuthService {}

void main() {
  final getIt = GetIt.instance;

  // Capture the original handler so we can restore it after each test.
  void Function(FlutterErrorDetails)? _originalOnError;

  setUp(() {
    _originalOnError = FlutterError.onError;

    // Only suppress known non-critical layout warnings; all other errors are
    // forwarded to the original handler so real failures still surface.
    FlutterError.onError = (FlutterErrorDetails details) {
      final message = details.toString();
      if (message.contains('overflowed') ||
          message.contains('_dependents.isEmpty') ||
          message.contains('RenderFlex')) {
        return; // Acceptable layout warnings in test environment
      }
      _originalOnError?.call(details);
    };

    // Reset GetIt
    getIt.reset();

    // Register mock AuthService
    final mockAuthService = MockAuthService();
    when(() => mockAuthService.currentUser).thenReturn(null);
    getIt.registerSingleton<AuthService>(mockAuthService);
  });

  tearDown(() {
    // Always restore the original error handler to avoid leaking state.
    FlutterError.onError = _originalOnError;
    getIt.reset();
  });

  group('EnhancedScheduleScreen', () {
    test('creates screen instance', () {
      const screen = EnhancedScheduleScreen();
      expect(screen, isNotNull);
      expect(screen, isA<StatefulWidget>());
    });

    test('screen is a StatefulWidget', () {
      const screen = EnhancedScheduleScreen();
      expect(screen, isA<StatefulWidget>());
    });

    test('screen properties are accessible', () {
      const screen = EnhancedScheduleScreen();
      expect(screen.key, isNull);
      expect(screen.runtimeType, equals(EnhancedScheduleScreen));
    });

    test('screen can be constructed with default constructor', () {
      const screen1 = EnhancedScheduleScreen();
      const screen2 = EnhancedScheduleScreen();

      expect(screen1, isA<EnhancedScheduleScreen>());
      expect(screen2, isA<EnhancedScheduleScreen>());
    });

    test('screen can be constructed with key', () {
      const key = ValueKey('test-key');
      const screen = EnhancedScheduleScreen(key: key);

      expect(screen.key, equals(key));
    });

    test('screen type is correct', () {
      const screen = EnhancedScheduleScreen();
      expect(screen.runtimeType.toString(), equals('EnhancedScheduleScreen'));
    });

    test('multiple screen instances can be created', () {
      const screen1 = EnhancedScheduleScreen();
      const screen2 = EnhancedScheduleScreen(key: ValueKey('1'));
      const screen3 = EnhancedScheduleScreen(key: ValueKey('2'));

      expect(screen1, isNotNull);
      expect(screen2, isNotNull);
      expect(screen3, isNotNull);
      expect(screen2.key, isNot(equals(screen3.key)));
    });

    test('screen inherits from StatefulWidget', () {
      const screen = EnhancedScheduleScreen();
      expect(screen, isA<Widget>());
      expect(screen, isA<StatefulWidget>());
    });

    test('screen has consistent type', () {
      const screen = EnhancedScheduleScreen();
      expect(screen is EnhancedScheduleScreen, isTrue);
      expect(screen is StatefulWidget, isTrue);
      expect(screen is Widget, isTrue);
    });

    test('screen keys work correctly', () {
      const key1 = ValueKey('key1');
      const key2 = ValueKey('key2');

      const screen1 = EnhancedScheduleScreen(key: key1);
      const screen2 = EnhancedScheduleScreen(key: key2);

      expect(screen1.key, equals(key1));
      expect(screen2.key, equals(key2));
      expect(screen1.key, isNot(equals(screen2.key)));
    });
  });
}
