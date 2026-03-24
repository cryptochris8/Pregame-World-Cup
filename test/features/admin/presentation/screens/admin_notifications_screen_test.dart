import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/admin/presentation/screens/admin_notifications_screen.dart';

void main() {
  group('AdminNotificationsScreen', () {
    test('is a StatefulWidget', () {
      const screen = AdminNotificationsScreen();
      expect(screen, isA<StatefulWidget>());
    });

    test('can be constructed', () {
      expect(() => const AdminNotificationsScreen(), returnsNormally);
    });

    test('has correct runtimeType', () {
      const screen = AdminNotificationsScreen();
      expect(screen.runtimeType, AdminNotificationsScreen);
    });

    test('can create multiple instances', () {
      const screen1 = AdminNotificationsScreen();
      const screen2 = AdminNotificationsScreen();
      expect(screen1, isA<AdminNotificationsScreen>());
      expect(screen2, isA<AdminNotificationsScreen>());
      expect(identical(screen1, screen2), isFalse);
    });
  });
}
