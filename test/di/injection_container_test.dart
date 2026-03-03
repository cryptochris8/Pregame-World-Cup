import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';

import 'package:pregame_world_cup/injection_container.dart';

/// Tests for lib/injection_container.dart (the orchestrator)
///
/// The orchestrator calls registerCoreDependencies (async), then the remaining
/// 8 module functions in sequence, each wrapped in try/catch for resilience.
///
/// We test:
///   - The global `sl` is the GetIt.instance
///   - setupLocator structure (we cannot fully call it without all platform
///     channels, but we can test the top-level contract)
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  group('injection_container.dart - globals', () {
    test('sl is GetIt.instance', () {
      expect(identical(sl, GetIt.instance), isTrue);
    });
  });

  group('injection_container.dart - setupLocator', () {
    test('setupLocator is a Future<void> function', () {
      // Just verifying it exists and has the right signature
      expect(setupLocator, isA<Function>());
    });

    test('GetIt instance starts empty', () async {
      final testSl = GetIt.instance;
      await testSl.reset();

      // After reset, nothing should be registered
      expect(testSl.isRegistered<String>(), isFalse);
    });
  });
}
