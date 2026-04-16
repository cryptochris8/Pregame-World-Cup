import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Regression test to ensure deprecated `withOpacity` is not used in
/// social profile widget files. Use `withValues(alpha: ...)` instead.
void main() {
  const widgetDir = 'lib/features/social/presentation/widgets';
  const targetFiles = [
    '$widgetDir/profile_feature_cards.dart',
    '$widgetDir/profile_account_actions.dart',
    '$widgetDir/profile_stats_row.dart',
    '$widgetDir/profile_header_card.dart',
  ];

  for (final filePath in targetFiles) {
    test('$filePath does not use deprecated withOpacity', () {
      final file = File(filePath);
      expect(file.existsSync(), isTrue, reason: '$filePath should exist');

      final content = file.readAsStringSync();
      final matches = RegExp(r'\.withOpacity\(').allMatches(content);

      expect(
        matches.length,
        0,
        reason:
            '$filePath still contains ${matches.length} call(s) to '
            'withOpacity. Use .withValues(alpha: ...) instead.',
      );
    });
  }
}
