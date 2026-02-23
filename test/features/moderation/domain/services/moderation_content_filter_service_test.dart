import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/moderation/domain/services/moderation_action_service.dart';
import 'package:pregame_world_cup/features/moderation/domain/services/moderation_content_filter_service.dart';
import 'package:pregame_world_cup/features/moderation/domain/services/profanity_filter_service.dart';

// -- Mocks --
class MockModerationActionService extends Mock
    implements ModerationActionService {}

void main() {
  late ProfanityFilterService profanityFilter;
  late MockModerationActionService mockActionService;
  late ModerationContentFilterService service;

  setUp(() {
    profanityFilter = ProfanityFilterService();
    mockActionService = MockModerationActionService();
    service = ModerationContentFilterService(
      profanityFilter: profanityFilter,
      actionService: mockActionService,
    );
  });

  group('ModerationContentFilterService', () {
    group('filterContent', () {
      test('returns clean result for appropriate text', () {
        final result = service.filterContent('Great game today!');

        expect(result.containsProfanity, isFalse);
        expect(result.filteredText, equals('Great game today!'));
        expect(result.shouldAutoReject, isFalse);
      });

      test('detects profanity in text', () {
        final result = service.filterContent('this is shit');

        expect(result.containsProfanity, isTrue);
        expect(result.flaggedWords, contains('shit'));
      });

      test('returns clean result for empty text', () {
        final result = service.filterContent('');

        expect(result.containsProfanity, isFalse);
        expect(result.filteredText, isEmpty);
      });
    });

    group('isContentAppropriate', () {
      test('returns true for clean text', () {
        expect(service.isContentAppropriate('Hello everyone'), isTrue);
      });

      test('returns false for profane text', () {
        expect(service.isContentAppropriate('what the fuck'), isFalse);
      });

      test('returns true for empty text', () {
        expect(service.isContentAppropriate(''), isTrue);
      });
    });

    group('getCensoredContent', () {
      test('returns original text for clean content', () {
        expect(
          service.getCensoredContent('Hello world'),
          equals('Hello world'),
        );
      });

      test('returns censored text for profane content', () {
        final censored = service.getCensoredContent('what the fuck');
        expect(censored, contains('f**k'));
      });
    });

    group('validateMessage', () {
      test('returns valid for clean message when user is not muted', () async {
        when(() => mockActionService.isCurrentUserMuted())
            .thenAnswer((_) async => false);

        final result = await service.validateMessage('Hello everyone!');

        expect(result.isValid, isTrue);
        expect(result.errorMessage, isNull);
        expect(result.filteredMessage, equals('Hello everyone!'));
        expect(result.wasFiltered, isFalse);
      });

      test('returns invalid when user is muted', () async {
        when(() => mockActionService.isCurrentUserMuted())
            .thenAnswer((_) async => true);

        final result = await service.validateMessage('Hello');

        expect(result.isValid, isFalse);
        expect(result.errorMessage,
            equals('You are currently muted and cannot send messages'));
        expect(result.filteredMessage, isNull);
      });

      test('checks mute status before profanity filtering', () async {
        when(() => mockActionService.isCurrentUserMuted())
            .thenAnswer((_) async => true);

        final result = await service.validateMessage('clean message');

        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('muted'));
        verify(() => mockActionService.isCurrentUserMuted()).called(1);
      });

      test('rejects message with auto-reject content', () async {
        when(() => mockActionService.isCurrentUserMuted())
            .thenAnswer((_) async => false);

        final result = await service.validateMessage(
          'congratulations you won free money click here now',
        );

        expect(result.isValid, isFalse);
        expect(result.errorMessage,
            equals('This message contains inappropriate content'));
        expect(result.filteredMessage, isNull);
      });

      test('filters mild profanity but keeps message valid', () async {
        when(() => mockActionService.isCurrentUserMuted())
            .thenAnswer((_) async => false);

        final result = await service.validateMessage('What the hell is this');

        expect(result.isValid, isTrue);
        expect(result.wasFiltered, isTrue);
        expect(result.filteredMessage, isNotNull);
        expect(result.filteredMessage, isNot(equals('What the hell is this')));
        expect(result.errorMessage, isNull);
      });

      test('passes through clean message without filtering', () async {
        when(() => mockActionService.isCurrentUserMuted())
            .thenAnswer((_) async => false);

        final result = await service.validateMessage('Go team! What a game!');

        expect(result.isValid, isTrue);
        expect(result.wasFiltered, isFalse);
        expect(result.filteredMessage, equals('Go team! What a game!'));
      });
    });

    group('validateWatchParty', () {
      test('returns valid for clean content when user is not suspended',
          () async {
        when(() => mockActionService.isCurrentUserSuspended())
            .thenAnswer((_) async => false);

        final result = await service.validateWatchParty(
          name: 'USA vs Mexico Watch Party',
          description: 'Join us to watch the big game!',
        );

        expect(result.isValid, isTrue);
        expect(result.wasFiltered, isFalse);
        expect(result.filteredName, equals('USA vs Mexico Watch Party'));
        expect(result.filteredDescription,
            equals('Join us to watch the big game!'));
        expect(result.errorMessage, isNull);
      });

      test('returns invalid when user is suspended', () async {
        when(() => mockActionService.isCurrentUserSuspended())
            .thenAnswer((_) async => true);

        final result = await service.validateWatchParty(
          name: 'My Party',
          description: 'A fun gathering',
        );

        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('suspended'));
      });

      test('checks suspension status before content filtering', () async {
        when(() => mockActionService.isCurrentUserSuspended())
            .thenAnswer((_) async => true);

        final result = await service.validateWatchParty(
          name: 'Any Party',
          description: 'Any description',
        );

        expect(result.isValid, isFalse);
        verify(() => mockActionService.isCurrentUserSuspended()).called(1);
      });

      test('rejects watch party with auto-reject content in name', () async {
        when(() => mockActionService.isCurrentUserSuspended())
            .thenAnswer((_) async => false);

        final result = await service.validateWatchParty(
          name: 'click here for free money',
          description: 'Normal description',
        );

        expect(result.isValid, isFalse);
        expect(result.errorMessage,
            equals('Watch party content contains inappropriate language'));
      });

      test('filters mild profanity in name and description', () async {
        when(() => mockActionService.isCurrentUserSuspended())
            .thenAnswer((_) async => false);

        final result = await service.validateWatchParty(
          name: 'Hell of a Game Party',
          description: 'This match is damn exciting',
        );

        expect(result.isValid, isTrue);
        expect(result.wasFiltered, isTrue);
        expect(result.filteredName, isNotNull);
        expect(result.filteredDescription, isNotNull);
      });

      test('splits filtered text into name and description', () async {
        when(() => mockActionService.isCurrentUserSuspended())
            .thenAnswer((_) async => false);

        final result = await service.validateWatchParty(
          name: 'This damn party',
          description: 'Come join the hell party',
        );

        expect(result.isValid, isTrue);
        expect(result.wasFiltered, isTrue);
        // filteredName and filteredDescription should be split on newline
        expect(result.filteredName, isNotNull);
        expect(result.filteredDescription, isNotNull);
      });

      test('passes through clean content without filtering', () async {
        when(() => mockActionService.isCurrentUserSuspended())
            .thenAnswer((_) async => false);

        final result = await service.validateWatchParty(
          name: 'Big Game Watch',
          description: 'Fun for the whole family',
        );

        expect(result.isValid, isTrue);
        expect(result.wasFiltered, isFalse);
        expect(result.filteredName, equals('Big Game Watch'));
        expect(result.filteredDescription,
            equals('Fun for the whole family'));
      });
    });
  });

  group('MessageValidationResult', () {
    test('creates valid result with defaults', () {
      const result = MessageValidationResult(
        isValid: true,
        filteredMessage: 'Hello',
      );

      expect(result.isValid, isTrue);
      expect(result.errorMessage, isNull);
      expect(result.filteredMessage, equals('Hello'));
      expect(result.wasFiltered, isFalse);
    });

    test('creates invalid result with error message', () {
      const result = MessageValidationResult(
        isValid: false,
        errorMessage: 'Content is inappropriate',
      );

      expect(result.isValid, isFalse);
      expect(result.errorMessage, equals('Content is inappropriate'));
      expect(result.filteredMessage, isNull);
      expect(result.wasFiltered, isFalse);
    });

    test('creates filtered valid result', () {
      const result = MessageValidationResult(
        isValid: true,
        filteredMessage: 'What the h**l',
        wasFiltered: true,
      );

      expect(result.isValid, isTrue);
      expect(result.wasFiltered, isTrue);
      expect(result.filteredMessage, equals('What the h**l'));
    });
  });

  group('WatchPartyValidationResult', () {
    test('creates valid result with defaults', () {
      const result = WatchPartyValidationResult(
        isValid: true,
        filteredName: 'Party Name',
        filteredDescription: 'Description',
      );

      expect(result.isValid, isTrue);
      expect(result.errorMessage, isNull);
      expect(result.filteredName, equals('Party Name'));
      expect(result.filteredDescription, equals('Description'));
      expect(result.wasFiltered, isFalse);
    });

    test('creates invalid result with error message', () {
      const result = WatchPartyValidationResult(
        isValid: false,
        errorMessage: 'Content is inappropriate',
      );

      expect(result.isValid, isFalse);
      expect(result.errorMessage, equals('Content is inappropriate'));
      expect(result.filteredName, isNull);
      expect(result.filteredDescription, isNull);
    });

    test('creates filtered valid result', () {
      const result = WatchPartyValidationResult(
        isValid: true,
        filteredName: 'Filtered Name',
        filteredDescription: 'Filtered Desc',
        wasFiltered: true,
      );

      expect(result.isValid, isTrue);
      expect(result.wasFiltered, isTrue);
    });
  });
}
