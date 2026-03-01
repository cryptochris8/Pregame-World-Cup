import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/services/logging_service.dart';

void main() {
  // LoggingService is a static utility that delegates to dart:developer.log.
  // We cannot easily intercept dart:developer.log calls in unit tests, but we
  // CAN verify that the methods execute without throwing and accept the
  // expected parameters. This validates the public API surface and ensures
  // no runtime errors occur.

  group('LoggingService', () {
    group('info', () {
      test('executes without throwing with message only', () {
        expect(
          () => LoggingService.info('Test info message'),
          returnsNormally,
        );
      });

      test('executes without throwing with custom tag', () {
        expect(
          () => LoggingService.info('Test info', tag: 'CustomTag'),
          returnsNormally,
        );
      });

      test('accepts empty message', () {
        expect(
          () => LoggingService.info(''),
          returnsNormally,
        );
      });

      test('accepts long message', () {
        final longMessage = 'A' * 10000;
        expect(
          () => LoggingService.info(longMessage),
          returnsNormally,
        );
      });
    });

    group('warning', () {
      test('executes without throwing with message only', () {
        expect(
          () => LoggingService.warning('Test warning message'),
          returnsNormally,
        );
      });

      test('executes without throwing with custom tag', () {
        expect(
          () => LoggingService.warning('Test warning', tag: 'WarnTag'),
          returnsNormally,
        );
      });
    });

    group('error', () {
      test('executes without throwing with message only', () {
        expect(
          () => LoggingService.error('Test error message'),
          returnsNormally,
        );
      });

      test('executes without throwing with custom tag', () {
        expect(
          () => LoggingService.error('Test error', tag: 'ErrorTag'),
          returnsNormally,
        );
      });

      test('executes without throwing with error object', () {
        expect(
          () => LoggingService.error(
            'Test error',
            error: Exception('something went wrong'),
          ),
          returnsNormally,
        );
      });

      test('executes without throwing with stack trace', () {
        try {
          throw Exception('test');
        } catch (e, st) {
          expect(
            () => LoggingService.error(
              'Test error',
              error: e,
              stackTrace: st,
            ),
            returnsNormally,
          );
        }
      });

      test('executes without throwing with all parameters', () {
        try {
          throw Exception('full test');
        } catch (e, st) {
          expect(
            () => LoggingService.error(
              'Full error',
              tag: 'FullTag',
              error: e,
              stackTrace: st,
            ),
            returnsNormally,
          );
        }
      });
    });

    group('debug', () {
      test('executes without throwing with message only', () {
        expect(
          () => LoggingService.debug('Test debug message'),
          returnsNormally,
        );
      });

      test('executes without throwing with custom tag', () {
        expect(
          () => LoggingService.debug('Test debug', tag: 'DebugTag'),
          returnsNormally,
        );
      });
    });

    group('api', () {
      test('executes without throwing with message only', () {
        expect(
          () => LoggingService.api('GET /api/matches'),
          returnsNormally,
        );
      });

      test('executes without throwing with custom tag', () {
        expect(
          () => LoggingService.api('POST /api/predictions', tag: 'API'),
          returnsNormally,
        );
      });
    });

    group('navigation', () {
      test('executes without throwing with message only', () {
        expect(
          () => LoggingService.navigation('Navigated to HomeScreen'),
          returnsNormally,
        );
      });

      test('executes without throwing with custom tag', () {
        expect(
          () => LoggingService.navigation('Pop', tag: 'Nav'),
          returnsNormally,
        );
      });
    });

    group('social', () {
      test('executes without throwing with message only', () {
        expect(
          () => LoggingService.social('Friend request sent'),
          returnsNormally,
        );
      });

      test('executes without throwing with custom tag', () {
        expect(
          () => LoggingService.social('Like', tag: 'Social'),
          returnsNormally,
        );
      });
    });

    group('messaging', () {
      test('executes without throwing with message only', () {
        expect(
          () => LoggingService.messaging('Message sent to user123'),
          returnsNormally,
        );
      });

      test('executes without throwing with custom tag', () {
        expect(
          () => LoggingService.messaging('DM', tag: 'Chat'),
          returnsNormally,
        );
      });
    });

    group('venue', () {
      test('executes without throwing with message only', () {
        expect(
          () => LoggingService.venue('Venue loaded: MetLife Stadium'),
          returnsNormally,
        );
      });

      test('executes without throwing with custom tag', () {
        expect(
          () => LoggingService.venue('Search', tag: 'VenueSearch'),
          returnsNormally,
        );
      });
    });

    group('schedule', () {
      test('executes without throwing with message only', () {
        expect(
          () => LoggingService.schedule('Schedule refreshed'),
          returnsNormally,
        );
      });

      test('executes without throwing with custom tag', () {
        expect(
          () => LoggingService.schedule('Sync', tag: 'ScheduleSync'),
          returnsNormally,
        );
      });
    });

    group('edge cases', () {
      test('all methods accept null tag (uses default)', () {
        // All methods should use the default tag when none is provided
        expect(() => LoggingService.info('msg'), returnsNormally);
        expect(() => LoggingService.warning('msg'), returnsNormally);
        expect(() => LoggingService.error('msg'), returnsNormally);
        expect(() => LoggingService.debug('msg'), returnsNormally);
        expect(() => LoggingService.api('msg'), returnsNormally);
        expect(() => LoggingService.navigation('msg'), returnsNormally);
        expect(() => LoggingService.social('msg'), returnsNormally);
        expect(() => LoggingService.messaging('msg'), returnsNormally);
        expect(() => LoggingService.venue('msg'), returnsNormally);
        expect(() => LoggingService.schedule('msg'), returnsNormally);
      });

      test('messages with special characters do not throw', () {
        expect(
          () => LoggingService.info('Unicode: \u00e9\u00e0\u00fc\u00f1 emoji chars'),
          returnsNormally,
        );
        expect(
          () => LoggingService.info('Newlines:\nLine2\nLine3'),
          returnsNormally,
        );
        expect(
          () => LoggingService.info('Tabs:\t\tTabbed'),
          returnsNormally,
        );
      });

      test('error with non-Exception error object does not throw', () {
        expect(
          () => LoggingService.error('msg', error: 'string error'),
          returnsNormally,
        );
        expect(
          () => LoggingService.error('msg', error: 42),
          returnsNormally,
        );
        expect(
          () => LoggingService.error('msg', error: null),
          returnsNormally,
        );
      });
    });
  });
}
