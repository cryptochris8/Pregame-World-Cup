import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/admin/presentation/screens/admin_watch_parties_screen.dart';

void main() {
  group('AdminWatchPartiesScreen', () {
    test('is a StatefulWidget', () {
      const screen = AdminWatchPartiesScreen();
      expect(screen, isA<StatefulWidget>());
    });

    test('can be constructed', () {
      expect(() => const AdminWatchPartiesScreen(), returnsNormally);
    });

    test('has correct runtimeType', () {
      const screen = AdminWatchPartiesScreen();
      expect(screen.runtimeType, AdminWatchPartiesScreen);
    });

    test('can create multiple instances', () {
      const screen1 = AdminWatchPartiesScreen();
      const screen2 = AdminWatchPartiesScreen();
      expect(screen1, isA<AdminWatchPartiesScreen>());
      expect(screen2, isA<AdminWatchPartiesScreen>());
      expect(identical(screen1, screen2), isFalse);
    });
  });
}
