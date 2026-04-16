import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Test that verifies all Hive type IDs are unique across the entire codebase.
///
/// Duplicate type IDs cause data corruption because Hive uses the type ID to
/// determine which adapter to use for serialization/deserialization. If two
/// different classes share the same type ID, Hive will attempt to deserialize
/// data with the wrong adapter, leading to runtime errors or silent corruption.
void main() {
  test('All @HiveType typeId values must be unique across the codebase', () {
    final libDir = Directory('lib');
    expect(libDir.existsSync(), isTrue,
        reason: 'lib directory must exist');

    // Collect all Dart files in lib/
    final dartFiles = libDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'))
        .toList();

    // RegExp to match @HiveType(typeId: <number>)
    final hiveTypePattern = RegExp(r'@HiveType\(typeId:\s*(\d+)\)');

    // Map from typeId -> list of (file, line) where it appears
    final typeIdLocations = <int, List<String>>{};

    for (final file in dartFiles) {
      final content = file.readAsStringSync();
      final lines = content.split('\n');

      for (var i = 0; i < lines.length; i++) {
        final match = hiveTypePattern.firstMatch(lines[i]);
        if (match != null) {
          final typeId = int.parse(match.group(1)!);
          final relativePath = file.path.replaceAll('\\', '/');
          final location = '$relativePath:${i + 1}';
          typeIdLocations.putIfAbsent(typeId, () => []).add(location);
        }
      }
    }

    // Check for duplicates
    final duplicates = <int, List<String>>{};
    for (final entry in typeIdLocations.entries) {
      if (entry.value.length > 1) {
        duplicates[entry.key] = entry.value;
      }
    }

    if (duplicates.isNotEmpty) {
      final buffer = StringBuffer('Duplicate Hive type IDs found:\n');
      for (final entry in duplicates.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key))) {
        buffer.writeln('  typeId ${entry.key}:');
        for (final location in entry.value) {
          buffer.writeln('    - $location');
        }
      }
      fail(buffer.toString());
    }

    // Verify we actually found type IDs (sanity check)
    expect(typeIdLocations.isNotEmpty, isTrue,
        reason: 'Should have found at least one @HiveType annotation');
    expect(typeIdLocations.length, greaterThanOrEqualTo(20),
        reason: 'Expected at least 20 unique Hive type IDs in the codebase');
  });

  test('Core messaging entity type IDs 17-24 belong to message.dart and chat.dart', () {
    // The core messaging entities (message.dart, chat.dart) own IDs 17-24.
    // Auxiliary messaging entities (file_attachment, video_message) use 50+ range.
    final messageFile =
        File('lib/features/messaging/domain/entities/message.dart');
    final chatFile =
        File('lib/features/messaging/domain/entities/chat.dart');

    final hiveTypePattern = RegExp(r'@HiveType\(typeId:\s*(\d+)\)');

    if (messageFile.existsSync()) {
      final content = messageFile.readAsStringSync();
      for (final match in hiveTypePattern.allMatches(content)) {
        final typeId = int.parse(match.group(1)!);
        expect(typeId, inInclusiveRange(17, 24),
            reason: 'message.dart type ID $typeId should be in range 17-24');
      }
    }

    if (chatFile.existsSync()) {
      final content = chatFile.readAsStringSync();
      for (final match in hiveTypePattern.allMatches(content)) {
        final typeId = int.parse(match.group(1)!);
        expect(typeId, inInclusiveRange(17, 24),
            reason: 'chat.dart type ID $typeId should be in range 17-24');
      }
    }
  });

  test('Social/core entities use IDs 50+ to avoid conflicts', () {
    // notification.dart and game_intelligence.dart should use 50+ IDs
    // for the types that were previously conflicting
    final notificationFile =
        File('lib/features/social/domain/entities/notification.dart');
    final gameIntelFile = File('lib/core/entities/game_intelligence.dart');

    final hiveTypePattern = RegExp(r'@HiveType\(typeId:\s*(\d+)\)');

    if (notificationFile.existsSync()) {
      final content = notificationFile.readAsStringSync();
      final matches = hiveTypePattern.allMatches(content);
      for (final match in matches) {
        final typeId = int.parse(match.group(1)!);
        // ID 16 is fine (SocialNotification itself, not conflicting)
        if (typeId == 16) continue;
        expect(typeId, greaterThanOrEqualTo(50),
            reason:
                'notification.dart enum/class type IDs should be 50+ (found $typeId)');
      }
    }

    if (gameIntelFile.existsSync()) {
      final content = gameIntelFile.readAsStringSync();
      final matches = hiveTypePattern.allMatches(content);
      for (final match in matches) {
        final typeId = int.parse(match.group(1)!);
        expect(typeId, greaterThanOrEqualTo(50),
            reason:
                'game_intelligence.dart type IDs should be 50+ (found $typeId)');
      }
    }
  });
}
