import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/moderation/domain/services/profanity_filter_service.dart';

void main() {
  late ProfanityFilterService service;

  setUp(() {
    // ProfanityFilterService is a singleton; we just get the instance.
    service = ProfanityFilterService();
  });

  group('ContentFilterResult', () {
    test('clean factory creates appropriate result', () {
      final result = ContentFilterResult.clean('Hello world');

      expect(result.containsProfanity, isFalse);
      expect(result.filteredText, equals('Hello world'));
      expect(result.flaggedWords, isEmpty);
      expect(result.severityScore, equals(0.0));
      expect(result.shouldAutoReject, isFalse);
    });

    test('clean factory preserves original text', () {
      const text = 'Some clean text with no issues';
      final result = ContentFilterResult.clean(text);
      expect(result.filteredText, equals(text));
    });
  });

  group('ProfanityFilterService', () {
    group('filterContent', () {
      test('returns clean result for empty text', () {
        final result = service.filterContent('');

        expect(result.containsProfanity, isFalse);
        expect(result.filteredText, isEmpty);
        expect(result.flaggedWords, isEmpty);
        expect(result.severityScore, equals(0.0));
        expect(result.shouldAutoReject, isFalse);
      });

      test('returns clean result for appropriate text', () {
        final result = service.filterContent('Great game today! Go USA!');

        expect(result.containsProfanity, isFalse);
        expect(result.filteredText, equals('Great game today! Go USA!'));
        expect(result.flaggedWords, isEmpty);
        expect(result.shouldAutoReject, isFalse);
      });

      test('detects English profanity', () {
        final result = service.filterContent('this is shit');

        expect(result.containsProfanity, isTrue);
        expect(result.flaggedWords, contains('shit'));
        expect(result.severityScore, greaterThan(0));
      });

      test('detects multiple profanity words', () {
        final result = service.filterContent('what the fuck, this is shit');

        expect(result.containsProfanity, isTrue);
        expect(result.flaggedWords, contains('fuck'));
        expect(result.flaggedWords, contains('shit'));
        expect(result.severityScore, greaterThan(0.2));
      });

      test('detects Spanish profanity', () {
        final testCases = {
          'eres un pendejo': 'pendejo',
          'que mierda': 'mierda',
          'pinche referee': 'pinche',
        };

        for (final entry in testCases.entries) {
          final result = service.filterContent(entry.key);
          expect(result.containsProfanity, isTrue,
              reason: 'Failed to detect Spanish profanity in: ${entry.key}');
          expect(result.flaggedWords, contains(entry.value),
              reason: 'Missing flagged word ${entry.value} for: ${entry.key}');
        }
      });

      test('detects Portuguese profanity', () {
        final testCases = {
          'isso eh uma merda': 'merda',
          'porra que gol': 'porra',
        };

        for (final entry in testCases.entries) {
          final result = service.filterContent(entry.key);
          expect(result.containsProfanity, isTrue,
              reason: 'Failed to detect Portuguese profanity in: ${entry.key}');
          expect(result.flaggedWords, contains(entry.value));
        }
      });

      test('censors short words with all asterisks', () {
        // "ass" is 3 chars, so first+last kept, middle replaced
        final result = service.filterContent('you are an ass');
        expect(result.filteredText, contains('a*s'));
      });

      test('censors longer words keeping first and last char', () {
        final result = service.filterContent('this is fucking great');
        // "fucking" -> f*****g
        expect(result.filteredText, contains('f*****g'));
      });

      test('censoring is case-insensitive', () {
        final result = service.filterContent('What the FUCK');
        expect(result.containsProfanity, isTrue);
        expect(result.flaggedWords, contains('fuck'));
      });

      test('uses word boundaries for matching', () {
        // "class" contains "ass" but should not be flagged
        // because word-boundary regex is used
        final result = service.filterContent('I went to class today');
        expect(result.flaggedWords, isNot(contains('ass')));
      });

      test('does not flag partial word matches', () {
        // "assassin" starts with "ass" but "ass" should not match
        // since "assassin" has word boundaries around the full word
        final result = service.filterContent('The assassin was caught');
        // "ass" as a standalone word boundary wouldn't match inside "assassin"
        // because \\bass\\b won't match "ass" inside "assassin"
        expect(result.flaggedWords, isNot(contains('ass')));
      });

      test('detects scam indicators', () {
        final scamPhrases = [
          'click here for free money',
          'congratulations you won the lottery',
          'send money to this account',
          'crypto giveaway happening now',
          'nigerian prince needs your help',
        ];

        for (final phrase in scamPhrases) {
          final result = service.filterContent(phrase);
          expect(result.shouldAutoReject, isTrue,
              reason: 'Failed to auto-reject scam phrase: $phrase');
        }
      });

      test('flags multiple violent contextual words', () {
        // 3+ contextual words should trigger flagging
        final result = service.filterContent(
          'I will kill and murder and bomb everyone',
        );
        expect(result.flaggedWords, contains('multiple_violent_terms'));
        expect(result.severityScore, greaterThan(0));
      });

      test('does not flag fewer than 3 contextual words', () {
        final result = service.filterContent('He might kill it in the game');
        expect(result.flaggedWords, isNot(contains('multiple_violent_terms')));
      });

      test('detects excessive caps as shouting', () {
        final result = service.filterContent(
          'THIS IS ALL CAPS AND VERY LOUD TEXT HERE',
        );
        // Severity should include the 0.1 excessive caps penalty
        expect(result.severityScore, greaterThan(0));
      });

      test('does not flag caps on short text (under 10 chars)', () {
        final result = service.filterContent('GO USA!');
        // Short text should not trigger caps detection
        expect(result.severityScore, equals(0.0));
      });

      test('detects repeated characters as spam', () {
        final result = service.filterContent('goooooool!!!!');
        expect(result.severityScore, greaterThan(0));
      });

      test('does not flag normal text with few repeated chars', () {
        final result = service.filterContent('goool!');
        // 3 or fewer repeated chars should not trigger
        expect(result.severityScore, equals(0.0));
      });

      test('severity score is clamped to 1.0', () {
        // Stack many violations to potentially exceed 1.0
        final result = service.filterContent(
          'fuck shit damn crap piss hell bastard bitch cock pussy cunt click here for free money congratulations you won',
        );
        expect(result.severityScore, lessThanOrEqualTo(1.0));
      });

      test('auto-rejects when severity score reaches 0.8 or above', () {
        // Many profane words will push severity above 0.8
        final result = service.filterContent(
          'fuck shit damn crap piss hell bastard',
        );
        // 7 words * 0.2 = 1.4, clamped to 1.0 >= 0.8
        expect(result.shouldAutoReject, isTrue);
      });
    });

    group('isClean', () {
      test('returns true for clean text', () {
        expect(service.isClean('Go team!'), isTrue);
        expect(service.isClean('What a great match'), isTrue);
        expect(service.isClean(''), isTrue);
      });

      test('returns false for profane text', () {
        expect(service.isClean('this is shit'), isFalse);
        expect(service.isClean('what the fuck'), isFalse);
      });
    });

    group('getCensoredText', () {
      test('returns original text for clean content', () {
        expect(service.getCensoredText('Hello world'), equals('Hello world'));
      });

      test('returns censored text for profane content', () {
        final censored = service.getCensoredText('what the fuck');
        expect(censored, isNot(equals('what the fuck')));
        expect(censored, contains('f**k'));
      });

      test('censors multiple words in same text', () {
        final censored = service.getCensoredText('shit and fuck');
        expect(censored, isNot(contains('shit')));
        expect(censored, isNot(contains('fuck')));
      });
    });

    group('shouldReject', () {
      test('returns false for clean text', () {
        expect(service.shouldReject('Great game'), isFalse);
      });

      test('returns true for scam content', () {
        expect(
          service.shouldReject('click here for free money now'),
          isTrue,
        );
      });

      test('returns true for heavily profane content', () {
        expect(
          service.shouldReject(
            'fuck shit damn crap piss hell bastard',
          ),
          isTrue,
        );
      });
    });

    group('validateUsername', () {
      test('returns clean result for normal username', () {
        final result = service.validateUsername('SoccerFan2026');

        expect(result.containsProfanity, isFalse);
        expect(result.shouldAutoReject, isFalse);
      });

      test('rejects username containing profanity as standalone word', () {
        // Word boundary matching: "fuck" as a standalone word
        // Underscores count as word characters in regex, so we use a space
        final result = service.validateUsername('fuck fan');

        expect(result.containsProfanity, isTrue);
      });

      test('rejects username impersonating admin', () {
        final result = service.validateUsername('admin_official');

        expect(result.containsProfanity, isTrue);
        expect(result.shouldAutoReject, isTrue);
        expect(result.flaggedWords.any((w) => w.contains('impersonation')),
            isTrue);
      });

      test('rejects username impersonating moderator', () {
        final result = service.validateUsername('moderator_john');

        expect(result.shouldAutoReject, isTrue);
        expect(
          result.flaggedWords.any((w) => w.contains('impersonation:moderator')),
          isTrue,
        );
      });

      test('rejects username impersonating staff', () {
        final result = service.validateUsername('pregame_staff');

        expect(result.shouldAutoReject, isTrue);
      });

      test('rejects username containing fifa', () {
        final result = service.validateUsername('fifa_official_account');

        expect(result.shouldAutoReject, isTrue);
        expect(
          result.flaggedWords.any((w) => w.contains('impersonation')),
          isTrue,
        );
      });

      test('rejects username containing support', () {
        final result = service.validateUsername('support_team');

        expect(result.shouldAutoReject, isTrue);
      });

      test('accepts username that does not impersonate', () {
        // Note: 'WorldCup_Lover' would be rejected because it contains
        // 'worldcup' which matches the impersonation list
        final validNames = [
          'GoalMaster99',
          'BrazilFan',
          'messiIsGoat',
          'soccer_queen',
          'Cup2026Fan',
        ];

        for (final name in validNames) {
          final result = service.validateUsername(name);
          expect(result.shouldAutoReject, isFalse,
              reason: 'Unexpectedly rejected username: $name');
        }
      });

      test('impersonation check is case insensitive', () {
        final result = service.validateUsername('ADMIN_USER');

        expect(result.shouldAutoReject, isTrue);
      });

      test('impersonation severity score is 0.7', () {
        final result = service.validateUsername('official_account');

        expect(result.severityScore, equals(0.7));
      });
    });

    group('validateWatchPartyContent', () {
      test('returns clean result for appropriate content', () {
        final result = service.validateWatchPartyContent(
          name: 'USA vs Mexico Watch Party',
          description: 'Join us to cheer for the home team!',
        );

        expect(result.containsProfanity, isFalse);
        expect(result.shouldAutoReject, isFalse);
        expect(result.filteredText,
            contains('USA vs Mexico Watch Party'));
      });

      test('detects profanity in name', () {
        final result = service.validateWatchPartyContent(
          name: 'Shit Show Party',
          description: 'Come watch the game',
        );

        expect(result.containsProfanity, isTrue);
        expect(result.flaggedWords, contains('shit'));
      });

      test('detects profanity in description', () {
        final result = service.validateWatchPartyContent(
          name: 'Big Game Party',
          description: 'This is going to be fucking awesome',
        );

        expect(result.containsProfanity, isTrue);
        expect(result.flaggedWords, contains('fucking'));
      });

      test('combines flagged words from name and description', () {
        final result = service.validateWatchPartyContent(
          name: 'Shit Game Party',
          description: 'Come get fucking wasted',
        );

        expect(result.flaggedWords, contains('shit'));
        expect(result.flaggedWords, contains('fucking'));
      });

      test('filtered text contains name and description separated by newline', () {
        final result = service.validateWatchPartyContent(
          name: 'Game Night',
          description: 'Fun times ahead',
        );

        expect(result.filteredText, equals('Game Night\nFun times ahead'));
      });

      test('auto-rejects when name contains severe content', () {
        final result = service.validateWatchPartyContent(
          name: 'click here for free money',
          description: 'Normal description',
        );

        expect(result.shouldAutoReject, isTrue);
      });

      test('auto-rejects when description contains severe content', () {
        final result = service.validateWatchPartyContent(
          name: 'Normal Party Name',
          description: 'Send money to win, wire transfer needed',
        );

        expect(result.shouldAutoReject, isTrue);
      });

      test('name violations weighted higher in severity score', () {
        // A violation in name should produce a higher combined score
        // than the same violation in description
        final nameResult = service.validateWatchPartyContent(
          name: 'shit party',
          description: 'clean description',
        );

        final descResult = service.validateWatchPartyContent(
          name: 'clean party',
          description: 'shit description',
        );

        // Name score is weighted 1.5x, so nameResult severity > descResult severity
        expect(nameResult.severityScore,
            greaterThan(descResult.severityScore));
      });

      test('severity score is clamped to 1.0', () {
        final result = service.validateWatchPartyContent(
          name: 'fuck shit damn crap piss hell bastard',
          description: 'fuck shit damn crap piss hell bastard',
        );

        expect(result.severityScore, lessThanOrEqualTo(1.0));
      });
    });
  });
}
