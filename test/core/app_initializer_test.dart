import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/app_initializer.dart';

void main() {
  group('AppInitializer', () {
    test('debugLog function exists', () {
      // debugLog should be callable without errors in test environment
      // In debug mode it logs, in release it's a no-op
      expect(debugLog, isA<Function>());
    });

    test('debugLog can be called with a string', () {
      // Should not throw in test environment
      debugLog('test message');
    });

    test('initializeApp function exists', () {
      expect(initializeApp, isA<Function>());
    });

    test('firebaseMessagingBackgroundHandler function exists', () {
      expect(firebaseMessagingBackgroundHandler, isA<Function>());
    });
  });
}
