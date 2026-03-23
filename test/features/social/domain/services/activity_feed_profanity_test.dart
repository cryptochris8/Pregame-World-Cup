import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/moderation/domain/services/profanity_filter_service.dart';

void main() {
  late ProfanityFilterService filterService;

  setUp(() {
    filterService = ProfanityFilterService();
  });

  group('Activity Feed - Profanity Filter on Posts', () {
    test('activity with severe profanity is auto-rejected', () {
      // Severe profanity triggers shouldAutoReject
      final result = filterService.filterContent('heil hitler is my motto');
      expect(result.shouldAutoReject, isTrue);
      expect(result.containsProfanity, isTrue);
      expect(result.severityScore, 1.0);
    });

    test('activity with standard profanity triggers containsProfanity', () {
      final result = filterService.filterContent('this is fucking great');
      expect(result.containsProfanity, isTrue);
      expect(result.flaggedWords, contains('fucking'));
    });

    test('activity with accumulated profanity is auto-rejected', () {
      // Multiple standard profanity words accumulate severity >= 0.8
      final result = filterService.filterContent(
        'shit fuck damn crap dick',
      );
      expect(result.containsProfanity, isTrue);
      // Severity adds up: 5 words * 0.2 = 1.0 (capped)
      expect(result.severityScore, greaterThanOrEqualTo(0.8));
      expect(result.shouldAutoReject, isTrue);
    });

    test('activity without profanity is allowed', () {
      final result = filterService.filterContent(
        'Great match between USA and Brazil today!',
      );
      expect(result.containsProfanity, isFalse);
      expect(result.shouldAutoReject, isFalse);
      expect(result.severityScore, 0.0);
      expect(result.flaggedWords, isEmpty);
    });

    test('empty activity text is treated as clean', () {
      final result = filterService.filterContent('');
      expect(result.containsProfanity, isFalse);
      expect(result.shouldAutoReject, isFalse);
    });

    test('scam content is auto-rejected', () {
      final result = filterService.filterContent(
        'Congratulations you won a free iPhone! Click here to claim!',
      );
      expect(result.shouldAutoReject, isTrue);
      expect(result.containsProfanity, isTrue);
    });
  });

  group('Activity Feed - Profanity Filter on Comments', () {
    test('comment with severe profanity is auto-rejected', () {
      // Using the same filterContent method that commentOnActivity uses
      final result = filterService.filterContent('white power forever');
      expect(result.shouldAutoReject, isTrue);
      expect(result.containsProfanity, isTrue);
    });

    test('comment without profanity is allowed', () {
      final result = filterService.filterContent(
        'What an amazing goal by Messi!',
      );
      expect(result.containsProfanity, isFalse);
      expect(result.shouldAutoReject, isFalse);
      expect(result.severityScore, 0.0);
    });

    test('comment with racial slur is auto-rejected', () {
      final result = filterService.filterContent(
        'That player is a nigger',
      );
      expect(result.shouldAutoReject, isTrue);
      expect(result.severityScore, 1.0);
    });

    test('comment with Spanish profanity is flagged', () {
      final result = filterService.filterContent('eres un pendejo');
      expect(result.containsProfanity, isTrue);
      expect(result.flaggedWords, contains('pendejo'));
    });

    test('clean football comment passes filter', () {
      final result = filterService.filterContent(
        'I think Argentina will win 2-1 in the final',
      );
      expect(result.containsProfanity, isFalse);
      expect(result.shouldAutoReject, isFalse);
      expect(result.filteredText, 'I think Argentina will win 2-1 in the final');
    });
  });

  group('ProfanityFilterService - Convenience Methods', () {
    test('isClean returns true for clean text', () {
      expect(filterService.isClean('Go Team USA!'), isTrue);
    });

    test('isClean returns false for profane text', () {
      expect(filterService.isClean('what the fuck'), isFalse);
    });

    test('shouldReject returns true for severe content', () {
      expect(filterService.shouldReject('kill yourself now'), isTrue);
    });

    test('shouldReject returns false for clean content', () {
      expect(filterService.shouldReject('Great game today!'), isFalse);
    });

    test('getCensoredText censors profanity', () {
      final censored = filterService.getCensoredText('that is bullshit');
      expect(censored, isNot(contains('bullshit')));
      // First and last chars kept, middle replaced with *
      expect(censored, contains('b'));
    });
  });
}
