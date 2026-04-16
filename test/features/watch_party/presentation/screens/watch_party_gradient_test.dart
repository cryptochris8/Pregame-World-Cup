import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Test that all watch party screens use gradient backgrounds.
///
/// This ensures visual consistency across the app by verifying that every
/// watch party screen wraps its body in AppTheme.mainGradientDecoration.
void main() {
  group('Watch party screens gradient backgrounds', () {
    final screenFiles = [
      'lib/features/watch_party/presentation/screens/watch_parties_discovery_screen.dart',
      'lib/features/watch_party/presentation/screens/my_watch_parties_screen.dart',
      'lib/features/watch_party/presentation/screens/watch_party_detail_screen.dart',
      'lib/features/watch_party/presentation/screens/invite_friends_screen.dart',
      'lib/features/watch_party/presentation/screens/game_selector_screen.dart',
      'lib/features/watch_party/presentation/screens/create_watch_party_screen.dart',
      'lib/features/watch_party/presentation/screens/edit_watch_party_screen.dart',
      'lib/features/watch_party/presentation/screens/venue_selector_screen.dart',
    ];

    for (final filePath in screenFiles) {
      final fileName = filePath.split('/').last;

      test('$fileName uses mainGradientDecoration', () {
        final file = File(filePath);
        expect(file.existsSync(), isTrue,
            reason: '$filePath should exist');

        final content = file.readAsStringSync();
        expect(content.contains('mainGradientDecoration'), isTrue,
            reason: '$fileName should use AppTheme.mainGradientDecoration '
                'for gradient background');
      });
    }
  });

  group('Watch party AlertDialogs use dark theme backgroundColor', () {
    test('watch_party_detail_screen AlertDialogs have backgroundColor', () {
      final file = File(
          'lib/features/watch_party/presentation/screens/watch_party_detail_screen.dart');
      final content = file.readAsStringSync();

      // Count AlertDialog occurrences
      final alertDialogCount = 'AlertDialog('.allMatches(content).length;
      final bgColorCount =
          'backgroundColor: AppTheme.backgroundCard'.allMatches(content).length;

      expect(bgColorCount, equals(alertDialogCount),
          reason:
              'All AlertDialogs in watch_party_detail_screen should have backgroundColor set');
    });

    test('edit_watch_party_screen AlertDialogs have backgroundColor', () {
      final file = File(
          'lib/features/watch_party/presentation/screens/edit_watch_party_screen.dart');
      final content = file.readAsStringSync();

      final alertDialogCount = 'AlertDialog('.allMatches(content).length;
      final bgColorCount =
          'backgroundColor: AppTheme.backgroundCard'.allMatches(content).length;

      expect(bgColorCount, equals(alertDialogCount),
          reason:
              'All AlertDialogs in edit_watch_party_screen should have backgroundColor set');
    });

    test('friend_action_dialogs AlertDialogs have backgroundColor', () {
      final file = File(
          'lib/features/social/presentation/widgets/friend_action_dialogs.dart');
      final content = file.readAsStringSync();

      final alertDialogCount = 'AlertDialog('.allMatches(content).length;
      final bgColorCount =
          'backgroundColor: AppTheme.backgroundCard'.allMatches(content).length;

      expect(bgColorCount, equals(alertDialogCount),
          reason:
              'All AlertDialogs in friend_action_dialogs should have backgroundColor set');
    });
  });
}
