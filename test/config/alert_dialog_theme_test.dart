import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Lint-style test that ensures every AlertDialog in lib/features/
/// sets backgroundColor so dialogs render correctly in dark theme.
void main() {
  test('All AlertDialogs in lib/features/ must set backgroundColor', () {
    final featuresDir = Directory('lib/features');
    expect(featuresDir.existsSync(), isTrue,
        reason: 'lib/features/ directory must exist');

    final violations = <String>[];

    for (final file in featuresDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        // Match lines that contain AlertDialog( — either `AlertDialog(` alone
        // or `=> AlertDialog(` etc.
        if (line.contains('AlertDialog(') && !line.contains('//')) {
          // Check if backgroundColor is set on this line or the next line
          final hasOnSameLine = line.contains('backgroundColor');
          final hasOnNextLine =
              (i + 1 < lines.length) && lines[i + 1].contains('backgroundColor');
          if (!hasOnSameLine && !hasOnNextLine) {
            final relativePath =
                file.path.replaceAll('\\', '/');
            violations.add('$relativePath:${i + 1}');
          }
        }
      }
    }

    expect(violations, isEmpty,
        reason:
            'Found AlertDialog(s) without backgroundColor on the same or next line.\n'
            'Each AlertDialog must set backgroundColor: AppTheme.backgroundCard.\n'
            'Violations:\n${violations.join('\n')}');
  });

  test('No AlertDialog in lib/features/ uses hardcoded Color(0xFF1E293B) for backgroundColor', () {
    final featuresDir = Directory('lib/features');
    expect(featuresDir.existsSync(), isTrue);

    final violations = <String>[];

    for (final file in featuresDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final content = file.readAsStringSync();
      // Look for AlertDialog backgroundColor using hardcoded hex
      final pattern = RegExp(r'AlertDialog\([^)]*backgroundColor:\s*(?:const\s+)?Color\(0xFF1E293B\)', dotAll: true);
      if (pattern.hasMatch(content)) {
        final relativePath = file.path.replaceAll('\\', '/');
        violations.add(relativePath);
      }
    }

    expect(violations, isEmpty,
        reason:
            'Found AlertDialog(s) using hardcoded Color(0xFF1E293B) instead of AppTheme.backgroundCard.\n'
            'Violations:\n${violations.join('\n')}');
  });
}
