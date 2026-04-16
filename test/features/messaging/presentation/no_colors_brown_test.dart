import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('messaging feature has no Colors.brown references', () {
    final messagingDir = Directory('lib/features/messaging');
    expect(messagingDir.existsSync(), isTrue,
        reason: 'messaging directory should exist');

    final dartFiles = messagingDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    final violations = <String>[];

    for (final file in dartFiles) {
      final content = file.readAsStringSync();
      final lines = content.split('\n');
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].contains('Colors.brown')) {
          violations.add('${file.path}:${i + 1}: ${lines[i].trim()}');
        }
      }
    }

    expect(violations, isEmpty,
        reason:
            'All Colors.brown references should be replaced with AppTheme colors.\n'
            'Found ${violations.length} violation(s):\n${violations.join('\n')}');
  });
}
