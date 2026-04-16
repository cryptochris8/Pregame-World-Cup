import 'dart:io';

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

    test('no fire-and-forget async functions (void _init* async)', () {
      // All async initialization helpers must return Future<void>, not void.
      // Returning void from an async function silently swallows errors after
      // the first await.
      final file = File('lib/app_initializer.dart');
      final contents = file.readAsStringSync();

      // Match patterns like "void _init...() async" which are fire-and-forget bugs
      final fireAndForgetPattern = RegExp(r'void\s+_init\w+\s*\([^)]*\)\s+async');
      final matches = fireAndForgetPattern.allMatches(contents).toList();

      expect(
        matches,
        isEmpty,
        reason:
            'Found ${matches.length} fire-and-forget async function(s) in '
            'app_initializer.dart. All async helpers should return '
            'Future<void>, not void. Matches: '
            '${matches.map((m) => m.group(0)).toList()}',
      );
    });
  });
}
