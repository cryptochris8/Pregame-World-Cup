import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Prevents large files from being added to the assets/logos/ directory.
/// Any file over 500 KB in that directory will cause this test to fail,
/// guarding against unnecessary app bundle bloat.
void main() {
  test('assets/logos/ should not contain files larger than 500 KB', () {
    final logosDir = Directory('assets/logos');
    expect(logosDir.existsSync(), isTrue,
        reason: 'assets/logos/ directory should exist');

    final maxBytes = 500 * 1024; // 500 KB

    final oversizedFiles = <String>[];
    for (final entity in logosDir.listSync()) {
      if (entity is File) {
        final sizeBytes = entity.lengthSync();
        if (sizeBytes > maxBytes) {
          final sizeKB = (sizeBytes / 1024).toStringAsFixed(1);
          oversizedFiles.add('${entity.path} (${sizeKB} KB)');
        }
      }
    }

    expect(oversizedFiles, isEmpty,
        reason:
            'Found files over 500 KB in assets/logos/ — these bloat the app '
            'bundle. Compress or remove them:\n${oversizedFiles.join('\n')}');
  });
}
