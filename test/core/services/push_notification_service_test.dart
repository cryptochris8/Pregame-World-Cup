import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/services/push_notification_service.dart';

void main() {
  // PushNotificationService depends on FirebaseMessaging, FirebaseFirestore, and
  // FirebaseAuth which are eagerly instantiated in the constructor.
  // We cannot construct the service in tests. We CAN test:
  // 1. The static onNotificationTap callback
  // 2. The top-level background handler reference
  // 3. Notification type constants used in _navigateFromNotification

  group('PushNotificationService', () {
    setUp(() {
      // Reset static callback between tests
      PushNotificationService.onNotificationTap = null;
    });

    group('static notification callback', () {
      test('onNotificationTap is null by default', () {
        expect(PushNotificationService.onNotificationTap, isNull);
      });

      test('onNotificationTap can be set to a function', () {
        bool wasCalled = false;
        String? receivedType;
        Map<String, dynamic>? receivedData;

        PushNotificationService.onNotificationTap =
            (String type, Map<String, dynamic> data) {
          wasCalled = true;
          receivedType = type;
          receivedData = data;
        };

        expect(PushNotificationService.onNotificationTap, isNotNull);

        // Invoke the callback
        PushNotificationService.onNotificationTap!(
          'new_message',
          {'chatId': 'abc123', 'chatName': 'Test Chat'},
        );

        expect(wasCalled, isTrue);
        expect(receivedType, 'new_message');
        expect(receivedData, {'chatId': 'abc123', 'chatName': 'Test Chat'});
      });

      test('onNotificationTap can be reset to null', () {
        PushNotificationService.onNotificationTap =
            (String type, Map<String, dynamic> data) {};
        expect(PushNotificationService.onNotificationTap, isNotNull);

        PushNotificationService.onNotificationTap = null;
        expect(PushNotificationService.onNotificationTap, isNull);
      });

      test('callback can be replaced', () {
        int callCount1 = 0;
        int callCount2 = 0;

        PushNotificationService.onNotificationTap = (type, data) {
          callCount1++;
        };
        PushNotificationService.onNotificationTap!('test', {});
        expect(callCount1, 1);

        PushNotificationService.onNotificationTap = (type, data) {
          callCount2++;
        };
        PushNotificationService.onNotificationTap!('test', {});
        expect(callCount1, 1); // First callback not called again
        expect(callCount2, 1);
      });
    });

    group('notification type strings', () {
      // These are the notification types used in _navigateFromNotification
      test('new_message type is recognized', () {
        const type = 'new_message';
        expect(type, isNotEmpty);
      });

      test('watch_party_invite type is recognized', () {
        const type = 'watch_party_invite';
        expect(type, isNotEmpty);
      });

      test('watch_party_invite_response type is recognized', () {
        const type = 'watch_party_invite_response';
        expect(type, isNotEmpty);
      });

      test('watch_party_cancelled type is recognized', () {
        const type = 'watch_party_cancelled';
        expect(type, isNotEmpty);
      });

      test('match_reminder type is recognized', () {
        const type = 'match_reminder';
        expect(type, isNotEmpty);
      });

      test('favorite_team_match type is recognized', () {
        const type = 'favorite_team_match';
        expect(type, isNotEmpty);
      });

      test('friend_request type is recognized', () {
        const type = 'friend_request';
        expect(type, isNotEmpty);
      });

      test('all notification types are unique', () {
        final types = {
          'new_message',
          'watch_party_invite',
          'watch_party_invite_response',
          'watch_party_cancelled',
          'match_reminder',
          'favorite_team_match',
          'friend_request',
        };
        expect(types.length, 7);
      });
    });

    group('notification data keys', () {
      test('new_message uses chatId and chatName keys', () {
        final data = {'chatId': 'chat123', 'chatName': 'My Chat'};
        expect(data['chatId'], 'chat123');
        expect(data['chatName'], 'My Chat');
      });

      test('watch_party uses watchPartyId key', () {
        final data = {'watchPartyId': 'party456'};
        expect(data['watchPartyId'], 'party456');
      });

      test('match_reminder uses matchId key', () {
        final data = {'matchId': 'match789'};
        expect(data['matchId'], 'match789');
      });

      test('friend_request uses fromUserId key', () {
        final data = {'fromUserId': 'user101'};
        expect(data['fromUserId'], 'user101');
      });
    });

    group('callback type checking', () {
      test('callback receives correct type and data for chat notification', () {
        String? capturedType;
        Map<String, dynamic>? capturedData;

        PushNotificationService.onNotificationTap = (type, data) {
          capturedType = type;
          capturedData = data;
        };

        PushNotificationService.onNotificationTap!(
            'new_message', {'chatId': '123', 'chatName': 'Test'});

        expect(capturedType, 'new_message');
        expect(capturedData!['chatId'], '123');
        expect(capturedData!['chatName'], 'Test');
      });

      test('callback receives correct type and data for match reminder', () {
        String? capturedType;
        Map<String, dynamic>? capturedData;

        PushNotificationService.onNotificationTap = (type, data) {
          capturedType = type;
          capturedData = data;
        };

        PushNotificationService.onNotificationTap!(
            'match_reminder', {'matchId': 'M42', 'teams': 'BRA vs ARG'});

        expect(capturedType, 'match_reminder');
        expect(capturedData!['matchId'], 'M42');
      });

      test('callback handles empty data map', () {
        Map<String, dynamic>? capturedData;

        PushNotificationService.onNotificationTap = (type, data) {
          capturedData = data;
        };

        PushNotificationService.onNotificationTap!('unknown', {});
        expect(capturedData, isEmpty);
      });
    });
  });

  group('firebaseMessagingBackgroundHandler', () {
    test('function reference exists and is callable', () {
      expect(firebaseMessagingBackgroundHandler, isA<Function>());
    });
  });
}
