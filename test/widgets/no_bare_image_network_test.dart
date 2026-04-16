import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Regression test to ensure no bare Image.network calls exist in lib/.
///
/// All network images should use CachedNetworkImage for disk/memory caching.
/// The only permitted exceptions are inside kIsWeb guards (player_photo.dart
/// and manager_photo.dart) where Image.network is used for web CORS handling.
void main() {
  test('lib/ contains no bare Image.network calls (except web-only guards)', () {
    final libDir = Directory('lib');
    expect(libDir.existsSync(), isTrue, reason: 'lib/ directory must exist');

    final dartFiles = libDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    final violations = <String>[];

    // Files that are allowed to contain Image.network inside kIsWeb guards
    final allowedFiles = {
      'player_photo.dart',
      'manager_photo.dart',
    };

    for (final file in dartFiles) {
      final fileName = file.uri.pathSegments.last;
      if (allowedFiles.contains(fileName)) continue;

      final content = file.readAsStringSync();
      if (content.contains('Image.network')) {
        violations.add(file.path);
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Found bare Image.network in these files (use CachedNetworkImage instead):\n'
          '${violations.join('\n')}',
    );
  });
}
