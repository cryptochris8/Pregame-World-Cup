import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Counts the number of hardcoded `Text('...')` or `Text("...")` calls
/// in a Dart source file that are NOT using l10n (i.e., have a string
/// literal as the first argument).
int countHardcodedTextStrings(String source) {
  // Match Text( followed by a string literal (single or double quoted),
  // but not a variable reference. We look for Text('...' or Text("...
  // We also match const Text('...' and const Text("...
  final pattern = RegExp(r'''(?:const\s+)?Text\(\s*(['"])(?!\$)''');
  return pattern.allMatches(source).length;
}

void main() {
  group('Hardcoded Text string reduction', () {
    test('friends_empty_states.dart should have zero hardcoded Text strings',
        () {
      final file = File(
        'lib/features/social/presentation/widgets/friends_empty_states.dart',
      );
      expect(file.existsSync(), isTrue,
          reason: 'friends_empty_states.dart should exist');

      final source = file.readAsStringSync();
      final count = countHardcodedTextStrings(source);

      // After localization, there should be 0 hardcoded text strings.
      // All visible strings now use AppLocalizations.
      expect(count, 0,
          reason:
              'friends_empty_states.dart should have no hardcoded Text strings');
    });

    test(
        'match_chat_message_item.dart should have zero hardcoded Text strings for actions',
        () {
      final file = File(
        'lib/features/match_chat/presentation/widgets/match_chat_message_item.dart',
      );
      expect(file.existsSync(), isTrue,
          reason: 'match_chat_message_item.dart should exist');

      final source = file.readAsStringSync();
      final count = countHardcodedTextStrings(source);

      // The only remaining hardcoded Text might be the '?' fallback in avatar.
      // Action labels (Add Reaction, Delete Message, Report Message,
      // Block User, Cancel, Block) should all be localized now.
      expect(count, lessThanOrEqualTo(1),
          reason:
              'match_chat_message_item.dart should have at most 1 hardcoded Text string (avatar fallback)');
    });

    test('chat_screen.dart should have zero hardcoded Copa strings', () {
      final file = File(
        'lib/features/chatbot/presentation/screens/chat_screen.dart',
      );
      expect(file.existsSync(), isTrue,
          reason: 'chat_screen.dart should exist');

      final source = file.readAsStringSync();

      // Verify no hardcoded 'Copa' text remains in Text() calls
      final copaPattern = RegExp(r'''Text\(\s*['"]Copa['"]''');
      final copaMatches = copaPattern.allMatches(source).length;

      expect(copaMatches, 0,
          reason: 'chat_screen.dart should have no hardcoded Copa Text calls');
    });

    test(
        'friends_empty_states.dart uses AppLocalizations import', () {
      final file = File(
        'lib/features/social/presentation/widgets/friends_empty_states.dart',
      );
      final source = file.readAsStringSync();

      expect(source.contains('app_localizations.dart'), isTrue,
          reason: 'Should import AppLocalizations');
      expect(source.contains('AppLocalizations.of(context)'), isTrue,
          reason: 'Should use AppLocalizations.of(context)');
    });

    test(
        'match_chat_message_item.dart uses AppLocalizations import', () {
      final file = File(
        'lib/features/match_chat/presentation/widgets/match_chat_message_item.dart',
      );
      final source = file.readAsStringSync();

      expect(source.contains('app_localizations.dart'), isTrue,
          reason: 'Should import AppLocalizations');
      expect(source.contains('AppLocalizations.of(context)'), isTrue,
          reason: 'Should use AppLocalizations.of(context)');
    });
  });
}
