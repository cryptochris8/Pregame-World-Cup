import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/admin/presentation/screens/admin_feature_flags_screen.dart';

void main() {
  group('AdminFeatureFlagsScreen', () {
    test('is a StatefulWidget', () {
      const screen = AdminFeatureFlagsScreen();
      expect(screen, isA<StatefulWidget>());
    });

    test('can be constructed', () {
      expect(() => const AdminFeatureFlagsScreen(), returnsNormally);
    });

    test('has correct runtimeType', () {
      const screen = AdminFeatureFlagsScreen();
      expect(screen.runtimeType, AdminFeatureFlagsScreen);
    });

    test('can create multiple instances', () {
      const screen1 = AdminFeatureFlagsScreen();
      const screen2 = AdminFeatureFlagsScreen();
      expect(screen1, isA<AdminFeatureFlagsScreen>());
      expect(screen2, isA<AdminFeatureFlagsScreen>());
      expect(identical(screen1, screen2), isFalse);
    });
  });
}
