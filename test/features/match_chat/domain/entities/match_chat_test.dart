import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/match_chat/domain/entities/match_chat.dart';

void main() {
  // ==================== MatchChat ====================
  group('MatchChat', () {
    final testMatchDateTime = DateTime(2026, 6, 15, 18, 0);
    final testCreatedAt = DateTime(2026, 6, 15, 17, 0);
    final testClosedAt = DateTime(2026, 6, 15, 20, 0);

    group('Constructor', () {
      test('creates instance with required fields and defaults', () {
        final chat = MatchChat(
          chatId: 'chat_1',
          matchId: 'match_1',
          matchName: 'USA vs Mexico',
          homeTeam: 'USA',
          awayTeam: 'MEX',
          matchDateTime: testMatchDateTime,
          createdAt: testCreatedAt,
        );

        expect(chat.chatId, equals('chat_1'));
        expect(chat.matchId, equals('match_1'));
        expect(chat.matchName, equals('USA vs Mexico'));
        expect(chat.homeTeam, equals('USA'));
        expect(chat.awayTeam, equals('MEX'));
        expect(chat.matchDateTime, equals(testMatchDateTime));
        expect(chat.participantCount, equals(0));
        expect(chat.messageCount, equals(0));
        expect(chat.isActive, isTrue);
        expect(chat.createdAt, equals(testCreatedAt));
        expect(chat.closedAt, isNull);
        expect(chat.settings, equals(const MatchChatSettings()));
      });

      test('creates instance with all fields specified', () {
        const settings = MatchChatSettings(
          slowModeEnabled: true,
          slowModeSeconds: 10,
        );
        final chat = MatchChat(
          chatId: 'chat_2',
          matchId: 'match_2',
          matchName: 'Brazil vs Germany',
          homeTeam: 'BRA',
          awayTeam: 'GER',
          matchDateTime: testMatchDateTime,
          participantCount: 500,
          messageCount: 2000,
          isActive: false,
          createdAt: testCreatedAt,
          closedAt: testClosedAt,
          settings: settings,
        );

        expect(chat.participantCount, equals(500));
        expect(chat.messageCount, equals(2000));
        expect(chat.isActive, isFalse);
        expect(chat.closedAt, equals(testClosedAt));
        expect(chat.settings.slowModeEnabled, isTrue);
        expect(chat.settings.slowModeSeconds, equals(10));
      });
    });

    group('fromFirestore', () {
      test('parses complete Firestore data', () {
        final data = {
          'matchId': 'match_1',
          'matchName': 'USA vs Mexico',
          'homeTeam': 'USA',
          'awayTeam': 'MEX',
          'matchDateTime': Timestamp.fromDate(testMatchDateTime),
          'participantCount': 42,
          'messageCount': 100,
          'isActive': true,
          'createdAt': Timestamp.fromDate(testCreatedAt),
          'closedAt': Timestamp.fromDate(testClosedAt),
          'settings': {
            'slowModeEnabled': true,
            'slowModeSeconds': 10,
            'subscribersOnly': false,
            'moderatorsOnly': false,
            'maxMessageLength': 250,
          },
        };

        final chat = MatchChat.fromFirestore(data, 'doc_123');

        expect(chat.chatId, equals('doc_123'));
        expect(chat.matchId, equals('match_1'));
        expect(chat.matchName, equals('USA vs Mexico'));
        expect(chat.homeTeam, equals('USA'));
        expect(chat.awayTeam, equals('MEX'));
        expect(chat.matchDateTime, equals(testMatchDateTime));
        expect(chat.participantCount, equals(42));
        expect(chat.messageCount, equals(100));
        expect(chat.isActive, isTrue);
        expect(chat.createdAt, equals(testCreatedAt));
        expect(chat.closedAt, equals(testClosedAt));
        expect(chat.settings.slowModeEnabled, isTrue);
        expect(chat.settings.slowModeSeconds, equals(10));
        expect(chat.settings.maxMessageLength, equals(250));
      });

      test('handles missing optional fields with defaults', () {
        final data = <String, dynamic>{
          'matchId': 'match_2',
        };

        final chat = MatchChat.fromFirestore(data, 'doc_456');

        expect(chat.chatId, equals('doc_456'));
        expect(chat.matchId, equals('match_2'));
        expect(chat.matchName, equals(''));
        expect(chat.homeTeam, equals(''));
        expect(chat.awayTeam, equals(''));
        expect(chat.participantCount, equals(0));
        expect(chat.messageCount, equals(0));
        expect(chat.isActive, isTrue);
        expect(chat.closedAt, isNull);
        expect(chat.settings, equals(const MatchChatSettings()));
      });

      test('handles null matchDateTime by defaulting to now', () {
        final data = <String, dynamic>{
          'matchId': 'match_3',
          'matchDateTime': null,
        };

        final beforeTest = DateTime.now();
        final chat = MatchChat.fromFirestore(data, 'doc_789');
        final afterTest = DateTime.now();

        expect(chat.matchDateTime.isAfter(beforeTest.subtract(const Duration(seconds: 1))), isTrue);
        expect(chat.matchDateTime.isBefore(afterTest.add(const Duration(seconds: 1))), isTrue);
      });

      test('handles null createdAt by defaulting to now', () {
        final data = <String, dynamic>{
          'matchId': 'match_4',
          'createdAt': null,
        };

        final beforeTest = DateTime.now();
        final chat = MatchChat.fromFirestore(data, 'doc_abc');
        final afterTest = DateTime.now();

        expect(chat.createdAt.isAfter(beforeTest.subtract(const Duration(seconds: 1))), isTrue);
        expect(chat.createdAt.isBefore(afterTest.add(const Duration(seconds: 1))), isTrue);
      });

      test('handles null closedAt', () {
        final data = <String, dynamic>{
          'matchId': 'match_5',
          'closedAt': null,
        };

        final chat = MatchChat.fromFirestore(data, 'doc_def');
        expect(chat.closedAt, isNull);
      });

      test('handles null settings by using defaults', () {
        final data = <String, dynamic>{
          'matchId': 'match_6',
          'settings': null,
        };

        final chat = MatchChat.fromFirestore(data, 'doc_ghi');
        expect(chat.settings.slowModeEnabled, isFalse);
        expect(chat.settings.slowModeSeconds, equals(5));
        expect(chat.settings.maxMessageLength, equals(500));
      });
    });

    group('toFirestore', () {
      test('serializes all fields correctly', () {
        final chat = MatchChat(
          chatId: 'chat_1',
          matchId: 'match_1',
          matchName: 'USA vs Mexico',
          homeTeam: 'USA',
          awayTeam: 'MEX',
          matchDateTime: testMatchDateTime,
          participantCount: 42,
          messageCount: 100,
          isActive: true,
          createdAt: testCreatedAt,
          closedAt: testClosedAt,
          settings: const MatchChatSettings(
            slowModeEnabled: true,
            slowModeSeconds: 10,
          ),
        );

        final data = chat.toFirestore();

        expect(data['matchId'], equals('match_1'));
        expect(data['matchName'], equals('USA vs Mexico'));
        expect(data['homeTeam'], equals('USA'));
        expect(data['awayTeam'], equals('MEX'));
        expect(data['matchDateTime'], equals(Timestamp.fromDate(testMatchDateTime)));
        expect(data['participantCount'], equals(42));
        expect(data['messageCount'], equals(100));
        expect(data['isActive'], isTrue);
        expect(data['createdAt'], equals(Timestamp.fromDate(testCreatedAt)));
        expect(data['closedAt'], equals(Timestamp.fromDate(testClosedAt)));
        expect(data['settings'], isA<Map<String, dynamic>>());
        expect(data['settings']['slowModeEnabled'], isTrue);
        expect(data['settings']['slowModeSeconds'], equals(10));
      });

      test('serializes null closedAt as null', () {
        final chat = MatchChat(
          chatId: 'chat_1',
          matchId: 'match_1',
          matchName: 'Test',
          homeTeam: 'A',
          awayTeam: 'B',
          matchDateTime: testMatchDateTime,
          createdAt: testCreatedAt,
        );

        final data = chat.toFirestore();
        expect(data['closedAt'], isNull);
      });

      test('does not include chatId in Firestore output', () {
        final chat = MatchChat(
          chatId: 'chat_1',
          matchId: 'match_1',
          matchName: 'Test',
          homeTeam: 'A',
          awayTeam: 'B',
          matchDateTime: testMatchDateTime,
          createdAt: testCreatedAt,
        );

        final data = chat.toFirestore();
        expect(data.containsKey('chatId'), isFalse);
      });
    });

    group('copyWith', () {
      test('creates copy with updated participantCount', () {
        final original = MatchChat(
          chatId: 'chat_1',
          matchId: 'match_1',
          matchName: 'USA vs Mexico',
          homeTeam: 'USA',
          awayTeam: 'MEX',
          matchDateTime: testMatchDateTime,
          participantCount: 42,
          createdAt: testCreatedAt,
        );

        final copy = original.copyWith(participantCount: 100);

        expect(copy.participantCount, equals(100));
        expect(copy.chatId, equals('chat_1'));
        expect(copy.matchId, equals('match_1'));
        expect(copy.matchName, equals('USA vs Mexico'));
        expect(copy.homeTeam, equals('USA'));
        expect(copy.awayTeam, equals('MEX'));
      });

      test('creates copy with updated messageCount', () {
        final original = MatchChat(
          chatId: 'chat_1',
          matchId: 'match_1',
          matchName: 'Test',
          homeTeam: 'A',
          awayTeam: 'B',
          matchDateTime: testMatchDateTime,
          messageCount: 10,
          createdAt: testCreatedAt,
        );

        final copy = original.copyWith(messageCount: 50);
        expect(copy.messageCount, equals(50));
        expect(copy.matchId, equals('match_1'));
      });

      test('creates copy with updated isActive and closedAt', () {
        final original = MatchChat(
          chatId: 'chat_1',
          matchId: 'match_1',
          matchName: 'Test',
          homeTeam: 'A',
          awayTeam: 'B',
          matchDateTime: testMatchDateTime,
          isActive: true,
          createdAt: testCreatedAt,
        );

        final copy = original.copyWith(
          isActive: false,
          closedAt: testClosedAt,
        );

        expect(copy.isActive, isFalse);
        expect(copy.closedAt, equals(testClosedAt));
      });

      test('creates copy with updated settings', () {
        final original = MatchChat(
          chatId: 'chat_1',
          matchId: 'match_1',
          matchName: 'Test',
          homeTeam: 'A',
          awayTeam: 'B',
          matchDateTime: testMatchDateTime,
          createdAt: testCreatedAt,
        );

        final copy = original.copyWith(
          settings: const MatchChatSettings(
            slowModeEnabled: true,
            slowModeSeconds: 15,
          ),
        );

        expect(copy.settings.slowModeEnabled, isTrue);
        expect(copy.settings.slowModeSeconds, equals(15));
      });

      test('preserves all fields when no arguments provided', () {
        final original = MatchChat(
          chatId: 'chat_1',
          matchId: 'match_1',
          matchName: 'USA vs Mexico',
          homeTeam: 'USA',
          awayTeam: 'MEX',
          matchDateTime: testMatchDateTime,
          participantCount: 42,
          messageCount: 100,
          isActive: true,
          createdAt: testCreatedAt,
          closedAt: testClosedAt,
          settings: const MatchChatSettings(slowModeEnabled: true),
        );

        final copy = original.copyWith();

        expect(copy.chatId, equals(original.chatId));
        expect(copy.matchId, equals(original.matchId));
        expect(copy.matchName, equals(original.matchName));
        expect(copy.homeTeam, equals(original.homeTeam));
        expect(copy.awayTeam, equals(original.awayTeam));
        expect(copy.matchDateTime, equals(original.matchDateTime));
        expect(copy.participantCount, equals(original.participantCount));
        expect(copy.messageCount, equals(original.messageCount));
        expect(copy.isActive, equals(original.isActive));
        expect(copy.createdAt, equals(original.createdAt));
        expect(copy.closedAt, equals(original.closedAt));
        expect(copy.settings, equals(original.settings));
      });
    });

    group('Equatable', () {
      test('chats with same chatId, matchId, isActive are equal', () {
        final chat1 = MatchChat(
          chatId: 'chat_1',
          matchId: 'match_1',
          matchName: 'USA vs Mexico',
          homeTeam: 'USA',
          awayTeam: 'MEX',
          matchDateTime: testMatchDateTime,
          participantCount: 10,
          isActive: true,
          createdAt: testCreatedAt,
        );
        final chat2 = MatchChat(
          chatId: 'chat_1',
          matchId: 'match_1',
          matchName: 'Different Name',
          homeTeam: 'X',
          awayTeam: 'Y',
          matchDateTime: DateTime(2027, 1, 1),
          participantCount: 99,
          isActive: true,
          createdAt: DateTime(2027, 1, 1),
        );

        expect(chat1, equals(chat2));
      });

      test('chats with different chatId are not equal', () {
        final chat1 = MatchChat(
          chatId: 'chat_1',
          matchId: 'match_1',
          matchName: 'Test',
          homeTeam: 'A',
          awayTeam: 'B',
          matchDateTime: testMatchDateTime,
          isActive: true,
          createdAt: testCreatedAt,
        );
        final chat2 = MatchChat(
          chatId: 'chat_2',
          matchId: 'match_1',
          matchName: 'Test',
          homeTeam: 'A',
          awayTeam: 'B',
          matchDateTime: testMatchDateTime,
          isActive: true,
          createdAt: testCreatedAt,
        );

        expect(chat1, isNot(equals(chat2)));
      });

      test('chats with different isActive are not equal', () {
        final chat1 = MatchChat(
          chatId: 'chat_1',
          matchId: 'match_1',
          matchName: 'Test',
          homeTeam: 'A',
          awayTeam: 'B',
          matchDateTime: testMatchDateTime,
          isActive: true,
          createdAt: testCreatedAt,
        );
        final chat2 = MatchChat(
          chatId: 'chat_1',
          matchId: 'match_1',
          matchName: 'Test',
          homeTeam: 'A',
          awayTeam: 'B',
          matchDateTime: testMatchDateTime,
          isActive: false,
          createdAt: testCreatedAt,
        );

        expect(chat1, isNot(equals(chat2)));
      });
    });

    group('Roundtrip (fromFirestore -> toFirestore)', () {
      test('preserves data through roundtrip', () {
        final originalData = {
          'matchId': 'match_1',
          'matchName': 'USA vs Mexico',
          'homeTeam': 'USA',
          'awayTeam': 'MEX',
          'matchDateTime': Timestamp.fromDate(testMatchDateTime),
          'participantCount': 42,
          'messageCount': 100,
          'isActive': true,
          'createdAt': Timestamp.fromDate(testCreatedAt),
          'closedAt': null,
          'settings': {
            'slowModeEnabled': false,
            'slowModeSeconds': 5,
            'subscribersOnly': false,
            'moderatorsOnly': false,
            'maxMessageLength': 500,
          },
        };

        final chat = MatchChat.fromFirestore(originalData, 'doc_1');
        final outputData = chat.toFirestore();

        expect(outputData['matchId'], equals(originalData['matchId']));
        expect(outputData['matchName'], equals(originalData['matchName']));
        expect(outputData['homeTeam'], equals(originalData['homeTeam']));
        expect(outputData['awayTeam'], equals(originalData['awayTeam']));
        expect(outputData['matchDateTime'], equals(originalData['matchDateTime']));
        expect(outputData['participantCount'], equals(originalData['participantCount']));
        expect(outputData['messageCount'], equals(originalData['messageCount']));
        expect(outputData['isActive'], equals(originalData['isActive']));
      });
    });
  });

  // ==================== MatchChatSettings ====================
  group('MatchChatSettings', () {
    group('Constructor and defaults', () {
      test('creates instance with default values', () {
        const settings = MatchChatSettings();

        expect(settings.slowModeEnabled, isFalse);
        expect(settings.slowModeSeconds, equals(5));
        expect(settings.subscribersOnly, isFalse);
        expect(settings.moderatorsOnly, isFalse);
        expect(settings.maxMessageLength, equals(500));
      });

      test('creates instance with custom values', () {
        const settings = MatchChatSettings(
          slowModeEnabled: true,
          slowModeSeconds: 30,
          subscribersOnly: true,
          moderatorsOnly: true,
          maxMessageLength: 200,
        );

        expect(settings.slowModeEnabled, isTrue);
        expect(settings.slowModeSeconds, equals(30));
        expect(settings.subscribersOnly, isTrue);
        expect(settings.moderatorsOnly, isTrue);
        expect(settings.maxMessageLength, equals(200));
      });
    });

    group('fromJson', () {
      test('parses complete JSON', () {
        final json = {
          'slowModeEnabled': true,
          'slowModeSeconds': 10,
          'subscribersOnly': true,
          'moderatorsOnly': false,
          'maxMessageLength': 250,
        };

        final settings = MatchChatSettings.fromJson(json);

        expect(settings.slowModeEnabled, isTrue);
        expect(settings.slowModeSeconds, equals(10));
        expect(settings.subscribersOnly, isTrue);
        expect(settings.moderatorsOnly, isFalse);
        expect(settings.maxMessageLength, equals(250));
      });

      test('handles missing fields with defaults', () {
        final json = <String, dynamic>{};

        final settings = MatchChatSettings.fromJson(json);

        expect(settings.slowModeEnabled, isFalse);
        expect(settings.slowModeSeconds, equals(5));
        expect(settings.subscribersOnly, isFalse);
        expect(settings.moderatorsOnly, isFalse);
        expect(settings.maxMessageLength, equals(500));
      });

      test('handles partial JSON data', () {
        final json = {
          'slowModeEnabled': true,
        };

        final settings = MatchChatSettings.fromJson(json);

        expect(settings.slowModeEnabled, isTrue);
        expect(settings.slowModeSeconds, equals(5));
        expect(settings.subscribersOnly, isFalse);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        const settings = MatchChatSettings(
          slowModeEnabled: true,
          slowModeSeconds: 15,
          subscribersOnly: false,
          moderatorsOnly: true,
          maxMessageLength: 300,
        );

        final json = settings.toJson();

        expect(json['slowModeEnabled'], isTrue);
        expect(json['slowModeSeconds'], equals(15));
        expect(json['subscribersOnly'], isFalse);
        expect(json['moderatorsOnly'], isTrue);
        expect(json['maxMessageLength'], equals(300));
      });

      test('roundtrip preserves data', () {
        const original = MatchChatSettings(
          slowModeEnabled: true,
          slowModeSeconds: 20,
          subscribersOnly: true,
          moderatorsOnly: false,
          maxMessageLength: 1000,
        );

        final json = original.toJson();
        final restored = MatchChatSettings.fromJson(json);

        expect(restored.slowModeEnabled, equals(original.slowModeEnabled));
        expect(restored.slowModeSeconds, equals(original.slowModeSeconds));
        expect(restored.subscribersOnly, equals(original.subscribersOnly));
        expect(restored.moderatorsOnly, equals(original.moderatorsOnly));
        expect(restored.maxMessageLength, equals(original.maxMessageLength));
      });
    });

    group('Equatable', () {
      test('settings with same props are equal', () {
        const settings1 = MatchChatSettings(
          slowModeEnabled: true,
          slowModeSeconds: 10,
          subscribersOnly: false,
        );
        const settings2 = MatchChatSettings(
          slowModeEnabled: true,
          slowModeSeconds: 10,
          subscribersOnly: false,
        );

        expect(settings1, equals(settings2));
      });

      test('settings with different slowModeEnabled are not equal', () {
        const settings1 = MatchChatSettings(slowModeEnabled: true);
        const settings2 = MatchChatSettings(slowModeEnabled: false);

        expect(settings1, isNot(equals(settings2)));
      });

      test('settings with different slowModeSeconds are not equal', () {
        const settings1 = MatchChatSettings(slowModeSeconds: 5);
        const settings2 = MatchChatSettings(slowModeSeconds: 10);

        expect(settings1, isNot(equals(settings2)));
      });
    });
  });

  // ==================== MatchChatMessage ====================
  group('MatchChatMessage', () {
    final testSentAt = DateTime(2026, 6, 15, 18, 30);

    group('Constructor', () {
      test('creates instance with required fields and defaults', () {
        final message = MatchChatMessage(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'John',
          content: 'Hello!',
          sentAt: testSentAt,
        );

        expect(message.messageId, equals('msg_1'));
        expect(message.chatId, equals('chat_1'));
        expect(message.senderId, equals('user_1'));
        expect(message.senderName, equals('John'));
        expect(message.senderImageUrl, isNull);
        expect(message.senderTeamFlair, isNull);
        expect(message.content, equals('Hello!'));
        expect(message.type, equals(MatchChatMessageType.text));
        expect(message.sentAt, equals(testSentAt));
        expect(message.isDeleted, isFalse);
        expect(message.deletedBy, isNull);
        expect(message.reactions, isEmpty);
        expect(message.eventData, isNull);
      });

      test('creates instance with all fields', () {
        const eventData = MatchEventData(
          eventType: MatchEventType.goal,
          team: 'USA',
          playerName: 'Pulisic',
          minute: 45,
        );

        final message = MatchChatMessage(
          messageId: 'msg_2',
          chatId: 'chat_1',
          senderId: 'user_2',
          senderName: 'Jane',
          senderImageUrl: 'https://example.com/avatar.jpg',
          senderTeamFlair: 'USA',
          content: 'GOAL!',
          type: MatchChatMessageType.goalReaction,
          sentAt: testSentAt,
          isDeleted: false,
          deletedBy: null,
          reactions: const {
            'thumbsup': ['user_3', 'user_4'],
            'fire': ['user_5'],
          },
          eventData: eventData,
        );

        expect(message.senderImageUrl, equals('https://example.com/avatar.jpg'));
        expect(message.senderTeamFlair, equals('USA'));
        expect(message.type, equals(MatchChatMessageType.goalReaction));
        expect(message.reactions.length, equals(2));
        expect(message.reactions['thumbsup'], contains('user_3'));
        expect(message.eventData, isNotNull);
        expect(message.eventData!.eventType, equals(MatchEventType.goal));
      });
    });

    group('fromFirestore', () {
      test('parses complete Firestore data', () {
        final data = {
          'chatId': 'chat_1',
          'senderId': 'user_1',
          'senderName': 'John',
          'senderImageUrl': 'https://example.com/avatar.jpg',
          'senderTeamFlair': 'BRA',
          'content': 'Great match!',
          'type': 'text',
          'sentAt': Timestamp.fromDate(testSentAt),
          'isDeleted': false,
          'deletedBy': null,
          'reactions': {
            'thumbsup': ['user_2', 'user_3'],
            'heart': ['user_4'],
          },
          'eventData': null,
        };

        final message = MatchChatMessage.fromFirestore(data, 'msg_123');

        expect(message.messageId, equals('msg_123'));
        expect(message.chatId, equals('chat_1'));
        expect(message.senderId, equals('user_1'));
        expect(message.senderName, equals('John'));
        expect(message.senderImageUrl, equals('https://example.com/avatar.jpg'));
        expect(message.senderTeamFlair, equals('BRA'));
        expect(message.content, equals('Great match!'));
        expect(message.type, equals(MatchChatMessageType.text));
        expect(message.sentAt, equals(testSentAt));
        expect(message.isDeleted, isFalse);
        expect(message.deletedBy, isNull);
        expect(message.reactions['thumbsup']!.length, equals(2));
        expect(message.reactions['heart']!.length, equals(1));
      });

      test('parses different message types', () {
        for (final msgType in MatchChatMessageType.values) {
          final data = {
            'chatId': 'chat_1',
            'senderId': 'user_1',
            'content': 'test',
            'type': msgType.name,
            'sentAt': Timestamp.fromDate(testSentAt),
          };

          final message = MatchChatMessage.fromFirestore(data, 'msg_${msgType.name}');
          expect(message.type, equals(msgType));
        }
      });

      test('defaults to text type for unknown type string', () {
        final data = {
          'chatId': 'chat_1',
          'senderId': 'user_1',
          'content': 'test',
          'type': 'unknown_type',
          'sentAt': Timestamp.fromDate(testSentAt),
        };

        final message = MatchChatMessage.fromFirestore(data, 'msg_unknown');
        expect(message.type, equals(MatchChatMessageType.text));
      });

      test('handles missing optional fields', () {
        final data = <String, dynamic>{
          'chatId': 'chat_1',
          'senderId': 'user_1',
        };

        final message = MatchChatMessage.fromFirestore(data, 'msg_minimal');

        expect(message.senderName, equals('Unknown'));
        expect(message.senderImageUrl, isNull);
        expect(message.senderTeamFlair, isNull);
        expect(message.content, equals(''));
        expect(message.isDeleted, isFalse);
        expect(message.deletedBy, isNull);
        expect(message.reactions, isEmpty);
        expect(message.eventData, isNull);
      });

      test('handles null sentAt by defaulting to now', () {
        final data = <String, dynamic>{
          'chatId': 'chat_1',
          'senderId': 'user_1',
          'sentAt': null,
        };

        final beforeTest = DateTime.now();
        final message = MatchChatMessage.fromFirestore(data, 'msg_no_time');
        final afterTest = DateTime.now();

        expect(message.sentAt.isAfter(beforeTest.subtract(const Duration(seconds: 1))), isTrue);
        expect(message.sentAt.isBefore(afterTest.add(const Duration(seconds: 1))), isTrue);
      });

      test('handles null reactions', () {
        final data = <String, dynamic>{
          'chatId': 'chat_1',
          'senderId': 'user_1',
          'reactions': null,
        };

        final message = MatchChatMessage.fromFirestore(data, 'msg_no_reactions');
        expect(message.reactions, isEmpty);
      });

      test('parses eventData when present', () {
        final data = {
          'chatId': 'chat_1',
          'senderId': 'user_1',
          'content': 'GOAL!',
          'type': 'goalReaction',
          'sentAt': Timestamp.fromDate(testSentAt),
          'eventData': {
            'eventType': 'goal',
            'team': 'USA',
            'playerName': 'Pulisic',
            'minute': 45,
            'description': 'Great strike from outside the box',
          },
        };

        final message = MatchChatMessage.fromFirestore(data, 'msg_goal');
        expect(message.eventData, isNotNull);
        expect(message.eventData!.eventType, equals(MatchEventType.goal));
        expect(message.eventData!.team, equals('USA'));
        expect(message.eventData!.playerName, equals('Pulisic'));
        expect(message.eventData!.minute, equals(45));
        expect(message.eventData!.description, equals('Great strike from outside the box'));
      });
    });

    group('toFirestore', () {
      test('serializes all fields correctly', () {
        final message = MatchChatMessage(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'John',
          senderImageUrl: 'https://example.com/avatar.jpg',
          senderTeamFlair: 'USA',
          content: 'Hello!',
          type: MatchChatMessageType.text,
          sentAt: testSentAt,
          isDeleted: false,
          deletedBy: null,
          reactions: const {
            'thumbsup': ['user_2'],
          },
          eventData: null,
        );

        final data = message.toFirestore();

        expect(data['chatId'], equals('chat_1'));
        expect(data['senderId'], equals('user_1'));
        expect(data['senderName'], equals('John'));
        expect(data['senderImageUrl'], equals('https://example.com/avatar.jpg'));
        expect(data['senderTeamFlair'], equals('USA'));
        expect(data['content'], equals('Hello!'));
        expect(data['type'], equals('text'));
        expect(data['sentAt'], equals(Timestamp.fromDate(testSentAt)));
        expect(data['isDeleted'], isFalse);
        expect(data['deletedBy'], isNull);
        expect(data['reactions'], isA<Map>());
        expect(data['eventData'], isNull);
      });

      test('serializes eventData when present', () {
        final message = MatchChatMessage(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'John',
          content: 'GOAL!',
          type: MatchChatMessageType.goalReaction,
          sentAt: testSentAt,
          eventData: const MatchEventData(
            eventType: MatchEventType.goal,
            team: 'BRA',
            playerName: 'Neymar',
            minute: 78,
          ),
        );

        final data = message.toFirestore();
        expect(data['eventData'], isNotNull);
        expect(data['eventData']['eventType'], equals('goal'));
        expect(data['eventData']['team'], equals('BRA'));
        expect(data['eventData']['playerName'], equals('Neymar'));
        expect(data['eventData']['minute'], equals(78));
      });

      test('does not include messageId in Firestore output', () {
        final message = MatchChatMessage(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'John',
          content: 'Hello!',
          sentAt: testSentAt,
        );

        final data = message.toFirestore();
        expect(data.containsKey('messageId'), isFalse);
      });
    });

    group('copyWith', () {
      test('creates copy with updated isDeleted and deletedBy', () {
        final original = MatchChatMessage(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'John',
          content: 'Hello!',
          sentAt: testSentAt,
        );

        final deleted = original.copyWith(
          isDeleted: true,
          deletedBy: 'moderator_1',
        );

        expect(deleted.isDeleted, isTrue);
        expect(deleted.deletedBy, equals('moderator_1'));
        expect(deleted.messageId, equals('msg_1'));
        expect(deleted.chatId, equals('chat_1'));
        expect(deleted.senderId, equals('user_1'));
        expect(deleted.content, equals('Hello!'));
      });

      test('creates copy with updated reactions', () {
        final original = MatchChatMessage(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'John',
          content: 'Hello!',
          sentAt: testSentAt,
          reactions: const {
            'thumbsup': ['user_2'],
          },
        );

        final updated = original.copyWith(
          reactions: const {
            'thumbsup': ['user_2', 'user_3'],
            'heart': ['user_4'],
          },
        );

        expect(updated.reactions.length, equals(2));
        expect(updated.reactions['thumbsup']!.length, equals(2));
        expect(updated.reactions['heart']!.length, equals(1));
      });

      test('preserves all fields when no arguments provided', () {
        final original = MatchChatMessage(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'John',
          senderImageUrl: 'https://example.com/avatar.jpg',
          senderTeamFlair: 'USA',
          content: 'Hello!',
          type: MatchChatMessageType.goalReaction,
          sentAt: testSentAt,
          isDeleted: false,
          reactions: const {'fire': ['user_2']},
          eventData: const MatchEventData(
            eventType: MatchEventType.goal,
            team: 'USA',
          ),
        );

        final copy = original.copyWith();

        expect(copy.messageId, equals(original.messageId));
        expect(copy.chatId, equals(original.chatId));
        expect(copy.senderId, equals(original.senderId));
        expect(copy.senderName, equals(original.senderName));
        expect(copy.senderImageUrl, equals(original.senderImageUrl));
        expect(copy.senderTeamFlair, equals(original.senderTeamFlair));
        expect(copy.content, equals(original.content));
        expect(copy.type, equals(original.type));
        expect(copy.sentAt, equals(original.sentAt));
        expect(copy.isDeleted, equals(original.isDeleted));
        expect(copy.reactions, equals(original.reactions));
        expect(copy.eventData, equals(original.eventData));
      });
    });

    group('totalReactions', () {
      test('returns 0 for empty reactions', () {
        final message = MatchChatMessage(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'John',
          content: 'Hello!',
          sentAt: testSentAt,
        );

        expect(message.totalReactions, equals(0));
      });

      test('correctly sums reactions across all emojis', () {
        final message = MatchChatMessage(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'John',
          content: 'Hello!',
          sentAt: testSentAt,
          reactions: const {
            'thumbsup': ['user_2', 'user_3'],
            'heart': ['user_4'],
            'fire': ['user_5', 'user_6', 'user_7'],
          },
        );

        expect(message.totalReactions, equals(6));
      });

      test('returns correct count with single reaction type', () {
        final message = MatchChatMessage(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'John',
          content: 'Hello!',
          sentAt: testSentAt,
          reactions: const {
            'thumbsup': ['user_2'],
          },
        );

        expect(message.totalReactions, equals(1));
      });
    });

    group('Equatable', () {
      test('messages with same key props are equal', () {
        final msg1 = MatchChatMessage(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'John',
          content: 'Hello!',
          sentAt: testSentAt,
          isDeleted: false,
        );
        final msg2 = MatchChatMessage(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'Different Name',
          content: 'Different Content',
          sentAt: testSentAt,
          isDeleted: false,
        );

        expect(msg1, equals(msg2));
      });

      test('messages with different messageId are not equal', () {
        final msg1 = MatchChatMessage(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'John',
          content: 'Hello!',
          sentAt: testSentAt,
        );
        final msg2 = MatchChatMessage(
          messageId: 'msg_2',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'John',
          content: 'Hello!',
          sentAt: testSentAt,
        );

        expect(msg1, isNot(equals(msg2)));
      });

      test('messages with different isDeleted are not equal', () {
        final msg1 = MatchChatMessage(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'John',
          content: 'Hello!',
          sentAt: testSentAt,
          isDeleted: false,
        );
        final msg2 = MatchChatMessage(
          messageId: 'msg_1',
          chatId: 'chat_1',
          senderId: 'user_1',
          senderName: 'John',
          content: 'Hello!',
          sentAt: testSentAt,
          isDeleted: true,
        );

        expect(msg1, isNot(equals(msg2)));
      });
    });
  });

  // ==================== MatchEventData ====================
  group('MatchEventData', () {
    group('Constructor', () {
      test('creates instance with required field and defaults', () {
        const event = MatchEventData(
          eventType: MatchEventType.goal,
        );

        expect(event.eventType, equals(MatchEventType.goal));
        expect(event.team, isNull);
        expect(event.playerName, isNull);
        expect(event.minute, isNull);
        expect(event.description, isNull);
      });

      test('creates instance with all fields', () {
        const event = MatchEventData(
          eventType: MatchEventType.redCard,
          team: 'ARG',
          playerName: 'Messi',
          minute: 89,
          description: 'Second yellow card',
        );

        expect(event.eventType, equals(MatchEventType.redCard));
        expect(event.team, equals('ARG'));
        expect(event.playerName, equals('Messi'));
        expect(event.minute, equals(89));
        expect(event.description, equals('Second yellow card'));
      });
    });

    group('fromJson', () {
      test('parses complete JSON', () {
        final json = {
          'eventType': 'goal',
          'team': 'USA',
          'playerName': 'Pulisic',
          'minute': 45,
          'description': 'Penalty kick',
        };

        final event = MatchEventData.fromJson(json);

        expect(event.eventType, equals(MatchEventType.goal));
        expect(event.team, equals('USA'));
        expect(event.playerName, equals('Pulisic'));
        expect(event.minute, equals(45));
        expect(event.description, equals('Penalty kick'));
      });

      test('defaults to other for unknown event type', () {
        final json = {
          'eventType': 'unknown_event',
        };

        final event = MatchEventData.fromJson(json);
        expect(event.eventType, equals(MatchEventType.other));
      });

      test('parses all known event types', () {
        for (final eventType in MatchEventType.values) {
          final json = {'eventType': eventType.name};
          final event = MatchEventData.fromJson(json);
          expect(event.eventType, equals(eventType));
        }
      });

      test('handles missing optional fields', () {
        final json = {
          'eventType': 'halftime',
        };

        final event = MatchEventData.fromJson(json);
        expect(event.team, isNull);
        expect(event.playerName, isNull);
        expect(event.minute, isNull);
        expect(event.description, isNull);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        const event = MatchEventData(
          eventType: MatchEventType.penalty,
          team: 'FRA',
          playerName: 'Mbappe',
          minute: 90,
          description: 'Late penalty',
        );

        final json = event.toJson();

        expect(json['eventType'], equals('penalty'));
        expect(json['team'], equals('FRA'));
        expect(json['playerName'], equals('Mbappe'));
        expect(json['minute'], equals(90));
        expect(json['description'], equals('Late penalty'));
      });

      test('serializes null fields as null', () {
        const event = MatchEventData(
          eventType: MatchEventType.kickoff,
        );

        final json = event.toJson();
        expect(json['team'], isNull);
        expect(json['playerName'], isNull);
        expect(json['minute'], isNull);
        expect(json['description'], isNull);
      });

      test('roundtrip preserves data', () {
        const original = MatchEventData(
          eventType: MatchEventType.substitution,
          team: 'ENG',
          playerName: 'Kane',
          minute: 70,
          description: 'Replaced by Foden',
        );

        final json = original.toJson();
        final restored = MatchEventData.fromJson(json);

        expect(restored.eventType, equals(original.eventType));
        expect(restored.team, equals(original.team));
        expect(restored.playerName, equals(original.playerName));
        expect(restored.minute, equals(original.minute));
        expect(restored.description, equals(original.description));
      });
    });

    group('Equatable', () {
      test('events with same eventType, team, minute are equal', () {
        const event1 = MatchEventData(
          eventType: MatchEventType.goal,
          team: 'USA',
          minute: 45,
          playerName: 'Pulisic',
          description: 'Header',
        );
        const event2 = MatchEventData(
          eventType: MatchEventType.goal,
          team: 'USA',
          minute: 45,
          playerName: 'Different',
          description: 'Different',
        );

        expect(event1, equals(event2));
      });

      test('events with different eventType are not equal', () {
        const event1 = MatchEventData(
          eventType: MatchEventType.goal,
          team: 'USA',
          minute: 45,
        );
        const event2 = MatchEventData(
          eventType: MatchEventType.ownGoal,
          team: 'USA',
          minute: 45,
        );

        expect(event1, isNot(equals(event2)));
      });
    });
  });

  // ==================== MatchChatMessageType ====================
  group('MatchChatMessageType', () {
    test('has expected values', () {
      expect(MatchChatMessageType.values, hasLength(5));
      expect(MatchChatMessageType.values, contains(MatchChatMessageType.text));
      expect(MatchChatMessageType.values, contains(MatchChatMessageType.goalReaction));
      expect(MatchChatMessageType.values, contains(MatchChatMessageType.eventReaction));
      expect(MatchChatMessageType.values, contains(MatchChatMessageType.system));
      expect(MatchChatMessageType.values, contains(MatchChatMessageType.moderator));
    });
  });

  // ==================== MatchEventType ====================
  group('MatchEventType', () {
    test('has expected values', () {
      expect(MatchEventType.values, hasLength(13));
      expect(MatchEventType.values, contains(MatchEventType.goal));
      expect(MatchEventType.values, contains(MatchEventType.ownGoal));
      expect(MatchEventType.values, contains(MatchEventType.penalty));
      expect(MatchEventType.values, contains(MatchEventType.penaltyMissed));
      expect(MatchEventType.values, contains(MatchEventType.yellowCard));
      expect(MatchEventType.values, contains(MatchEventType.redCard));
      expect(MatchEventType.values, contains(MatchEventType.substitution));
      expect(MatchEventType.values, contains(MatchEventType.kickoff));
      expect(MatchEventType.values, contains(MatchEventType.halftime));
      expect(MatchEventType.values, contains(MatchEventType.fulltime));
      expect(MatchEventType.values, contains(MatchEventType.varReview));
      expect(MatchEventType.values, contains(MatchEventType.injury));
      expect(MatchEventType.values, contains(MatchEventType.other));
    });
  });

  // ==================== MatchEventTypeExtension ====================
  group('MatchEventTypeExtension', () {
    group('emoji', () {
      test('all event types have non-empty emojis', () {
        for (final eventType in MatchEventType.values) {
          expect(eventType.emoji, isNotEmpty, reason: '${eventType.name} should have an emoji');
        }
      });

      test('specific emojis are correct', () {
        expect(MatchEventType.goal.emoji, contains('⚽'));
        expect(MatchEventType.yellowCard.emoji, contains('🟨'));
        expect(MatchEventType.redCard.emoji, contains('🟥'));
      });
    });

    group('displayName', () {
      test('all event types have non-empty display names', () {
        for (final eventType in MatchEventType.values) {
          expect(eventType.displayName, isNotEmpty, reason: '${eventType.name} should have a displayName');
        }
      });

      test('specific display names are correct', () {
        expect(MatchEventType.goal.displayName, equals('Goal!'));
        expect(MatchEventType.ownGoal.displayName, equals('Own Goal'));
        expect(MatchEventType.penalty.displayName, equals('Penalty Scored'));
        expect(MatchEventType.penaltyMissed.displayName, equals('Penalty Missed'));
        expect(MatchEventType.yellowCard.displayName, equals('Yellow Card'));
        expect(MatchEventType.redCard.displayName, equals('Red Card'));
        expect(MatchEventType.substitution.displayName, equals('Substitution'));
        expect(MatchEventType.kickoff.displayName, equals('Kick Off'));
        expect(MatchEventType.halftime.displayName, equals('Half Time'));
        expect(MatchEventType.fulltime.displayName, equals('Full Time'));
        expect(MatchEventType.varReview.displayName, equals('VAR Review'));
        expect(MatchEventType.injury.displayName, equals('Injury'));
        expect(MatchEventType.other.displayName, equals('Event'));
      });
    });
  });

  // ==================== MatchChatReactions ====================
  group('MatchChatReactions', () {
    test('quickReactions has 8 emojis', () {
      expect(MatchChatReactions.quickReactions, hasLength(8));
    });

    test('reactionLabels has entries for all quickReactions', () {
      for (final emoji in MatchChatReactions.quickReactions) {
        expect(MatchChatReactions.reactionLabels.containsKey(emoji), isTrue,
            reason: 'Emoji $emoji should have a label');
      }
    });

    test('reactionLabels values are non-empty strings', () {
      for (final label in MatchChatReactions.reactionLabels.values) {
        expect(label, isNotEmpty);
      }
    });

    test('quickReactions count matches reactionLabels count', () {
      expect(
        MatchChatReactions.quickReactions.length,
        equals(MatchChatReactions.reactionLabels.length),
      );
    });
  });
}
