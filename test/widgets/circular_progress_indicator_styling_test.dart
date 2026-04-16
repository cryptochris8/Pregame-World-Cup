import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// This test ensures that no bare CircularProgressIndicator() instances exist
/// in the lib/ directory. Every CircularProgressIndicator should have explicit
/// color styling via valueColor or color parameter.
void main() {
  test('no bare CircularProgressIndicator() without color styling in lib/', () {
    final libDir = Directory('lib');
    expect(libDir.existsSync(), isTrue, reason: 'lib/ directory must exist');

    final dartFiles = libDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    final barePattern = RegExp(r'CircularProgressIndicator\(\s*\)');
    final keyOnlyPattern =
        RegExp(r'CircularProgressIndicator\(\s*key\s*:.*?\)');

    final violations = <String>[];

    for (final file in dartFiles) {
      final content = file.readAsStringSync();
      final lines = content.split('\n');
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (barePattern.hasMatch(line) || keyOnlyPattern.hasMatch(line)) {
          // Verify it does not also contain color or valueColor
          if (!line.contains('valueColor') && !line.contains('color:')) {
            violations
                .add('${file.path}:${i + 1}: ${line.trim()}');
          }
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Found ${violations.length} bare CircularProgressIndicator() '
          'without color styling:\n${violations.join('\n')}',
    );
  });
}
