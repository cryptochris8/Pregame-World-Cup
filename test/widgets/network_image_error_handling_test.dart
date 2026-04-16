import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Regression test to ensure all CachedNetworkImage and Image.network calls
/// include error handling (errorWidget or errorBuilder respectively).
///
/// Broken Firebase Storage URLs should never show a raw error widget.
/// Every network image must gracefully degrade to a placeholder.
void main() {
  test('All CachedNetworkImage calls must include errorWidget', () {
    final libDir = Directory('lib');
    expect(libDir.existsSync(), isTrue, reason: 'lib/ directory must exist');

    final dartFiles = libDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    final violations = <String>[];

    for (final file in dartFiles) {
      final content = file.readAsStringSync();

      // Find each CachedNetworkImage( and check its constructor block
      final pattern = RegExp(r'CachedNetworkImage\(');
      for (final match in pattern.allMatches(content)) {
        final start = match.start;
        // Walk forward counting parens to find the end of the constructor
        var depth = 1;
        var i = start + match.group(0)!.length;
        while (i < content.length && depth > 0) {
          if (content[i] == '(') depth++;
          if (content[i] == ')') depth--;
          i++;
        }
        final block = content.substring(start, i);
        if (!block.contains('errorWidget')) {
          final lineNum = content.substring(0, start).split('\n').length;
          violations.add('${file.path}:$lineNum');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'CachedNetworkImage calls missing errorWidget '
          '(broken URLs will show raw error):\n'
          '${violations.join('\n')}',
    );
  });

  test('All Image.network calls must include errorBuilder', () {
    final libDir = Directory('lib');
    expect(libDir.existsSync(), isTrue, reason: 'lib/ directory must exist');

    final dartFiles = libDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    final violations = <String>[];

    for (final file in dartFiles) {
      final content = file.readAsStringSync();

      final pattern = RegExp(r'Image\.network\(');
      for (final match in pattern.allMatches(content)) {
        final start = match.start;
        var depth = 1;
        var i = start + match.group(0)!.length;
        while (i < content.length && depth > 0) {
          if (content[i] == '(') depth++;
          if (content[i] == ')') depth--;
          i++;
        }
        final block = content.substring(start, i);
        if (!block.contains('errorBuilder')) {
          final lineNum = content.substring(0, start).split('\n').length;
          violations.add('${file.path}:$lineNum');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Image.network calls missing errorBuilder '
          '(broken URLs will show raw error):\n'
          '${violations.join('\n')}',
    );
  });
}
