import 'dart:io';
import 'package:test/test.dart';

/// Test that ensures no hardcoded hex colors remain in venue and social feature files.
/// All colors should reference AppTheme constants instead of inline Color(0xFF...) values.
void main() {
  // Legacy off-brand hex colors that must not appear in production code.
  // These were replaced with AppTheme references.
  final offBrandPatterns = [
    RegExp(r'Color\(0xFFFF6B35\)'), // legacy orange
    RegExp(r'Color\(0xFF8B4513\)'), // saddlebrown
    RegExp(r'Color\(0xFF2D1810\)'), // dark brown
    RegExp(r'Color\(0xFF355E3B\)'), // dark green
  ];

  final directories = [
    'lib/features/venues',
    'lib/features/social',
    'lib/features/venue_portal',
    'lib/features/recommendations',
  ];

  for (final dir in directories) {
    test('No hardcoded off-brand colors in $dir', () {
      final directory = Directory(dir);
      if (!directory.existsSync()) {
        // Skip if directory does not exist in test environment
        return;
      }

      final violations = <String>[];

      for (final entity in directory.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        // Skip test files
        if (entity.path.contains('_test.dart')) continue;

        final content = entity.readAsStringSync();
        for (final pattern in offBrandPatterns) {
          final matches = pattern.allMatches(content);
          for (final match in matches) {
            violations.add(
              '${entity.path}: found ${match.group(0)}',
            );
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Found hardcoded off-brand colors. Use AppTheme constants instead:\n'
            '${violations.join('\n')}',
      );
    });
  }
}
