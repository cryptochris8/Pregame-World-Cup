import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/match_chat/domain/entities/match_chat.dart';

void main() {
  group('MatchChatMessage', () {
    final testSentAt = DateTime(2026, 6, 14, 18, 30, 0);

    MatchChatMessage createMessage({
      String messageId = 'msg_1',
      String chatId = 'chat_1',
      String senderId = 'user_1',
      String senderName = 'John',
      String? senderImageUrl,
      String? senderTeamFlair,
      String content = 'Great goal!',
      MatchChatMessageType type = MatchChatMessageType.text,
      DateTime? sentAt,
      bool isDeleted = false,
      String? deletedBy,
      Map<String, List<String>> reactions = const {},
      MatchEventData? eventData,
    }) {
      return MatchChatMessage(
        messageId: messageId,
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        senderImageUrl: senderImageUrl,
        senderTeamFlair: senderTeamFlair,
        content: content,
        type: type,
        sentAt: sentAt ?? testSentAt,
        isDeleted: isDeleted,
        deletedBy: deletedBy,
        reactions: reactions,
        eventData: eventData,
      );
    }

    group('Constructor', () {
      test('creates message with required fields', () {
        final msg = createMessage();

        expect(msg.messageId, equals('msg_1'));
        expect(msg.chatId, equals('chat_1'));
        expect(msg.senderId, equals('user_1'));
        expect(msg.senderName, equals('John'));
        expect(msg.content, equals('Great goal!'));
        expect(msg.type, equals(MatchChatMessageType.text));
        expect(msg.isDeleted, isFalse);
        expect(msg.reactions, isEmpty);
        expect(msg.eventData, isNull);
      });

      test('creates message with all optional fields', () {
        final eventData = const MatchEventData(
          eventType: MatchEventType.goal,
          team: 'USA',
          playerName: 'Pulisic',
          minute: 23,
        );

        final msg = createMessage(
          senderImageUrl: 'https://example.com/avatar.jpg',
          senderTeamFlair: 'USA',
          type: MatchChatMessageType.goalReaction,
          isDeleted: true,
          deletedBy: 'mod_1',
          reactions: {
            'fire': ['user_2', 'user_3'],
            'goal': ['user_4'],
          },
          eventData: eventData,
        );

        expect(msg.senderImageUrl, equals('https://example.com/avatar.jpg'));
        expect(msg.senderTeamFlair, equals('USA'));
        expect(msg.type, equals(MatchChatMessageType.goalReaction));
        expect(msg.isDeleted, isTrue);
        expect(msg.deletedBy, equals('mod_1'));
        expect(msg.reactions, hasLength(2));
        expect(msg.eventData, isNotNull);
        expect(msg.eventData!.playerName, equals('Pulisic'));
      });
    });

    group('totalReactions', () {
      test('returns 0 when no reactions', () {
        final msg = createMessage();
        expect(msg.totalReactions, equals(0));
      });

      test('counts all reactions across emojis', () {
        final msg = createMessage(
          reactions: {
            'fire': ['user_1', 'user_2', 'user_3'],
            'goal': ['user_4', 'user_5'],
            'clap': ['user_6'],
          },
        );
        expect(msg.totalReactions, equals(6));
      });

      test('counts single reaction', () {
        final msg = createMessage(
          reactions: {
            'fire': ['user_1'],
          },
        );
        expect(msg.totalReactions, equals(1));
      });
    });

    group('copyWith', () {
      test('updates isDeleted', () {
        final original = createMessage();
        final updated = original.copyWith(isDeleted: true, deletedBy: 'mod_1');

        expect(updated.isDeleted, isTrue);
        expect(updated.deletedBy, equals('mod_1'));
        expect(updated.messageId, equals(original.messageId));
        expect(updated.content, equals(original.content));
      });

      test('updates reactions', () {
        final original = createMessage();
        final updated = original.copyWith(
          reactions: {
            'fire': ['user_1'],
          },
        );

        expect(updated.reactions, hasLength(1));
        expect(updated.reactions['fire'], equals(['user_1']));
      });

      test('preserves unchanged fields', () {
        final original = createMessage(
          senderTeamFlair: 'BRA',
          type: MatchChatMessageType.eventReaction,
        );
        final updated = original.copyWith(isDeleted: true);

        expect(updated.senderTeamFlair, equals('BRA'));
        expect(updated.type, equals(MatchChatMessageType.eventReaction));
        expect(updated.sentAt, equals(original.sentAt));
      });
    });

    group('toFirestore', () {
      test('serializes all fields', () {
        final eventData = const MatchEventData(
          eventType: MatchEventType.goal,
          team: 'BRA',
          playerName: 'Neymar',
          minute: 45,
        );

        final msg = createMessage(
          senderImageUrl: 'https://example.com/avatar.jpg',
          senderTeamFlair: 'BRA',
          type: MatchChatMessageType.goalReaction,
          reactions: {
            'fire': ['user_1'],
          },
          eventData: eventData,
        );

        final data = msg.toFirestore();

        expect(data['chatId'], equals('chat_1'));
        expect(data['senderId'], equals('user_1'));
        expect(data['senderName'], equals('John'));
        expect(data['senderImageUrl'], equals('https://example.com/avatar.jpg'));
        expect(data['senderTeamFlair'], equals('BRA'));
        expect(data['content'], equals('Great goal!'));
        expect(data['type'], equals('goalReaction'));
        expect(data['isDeleted'], isFalse);
        expect(data['reactions'], equals({'fire': ['user_1']}));
        expect(data['eventData'], isNotNull);
        expect(data['eventData']['playerName'], equals('Neymar'));
      });

      test('serializes null optional fields', () {
        final msg = createMessage();
        final data = msg.toFirestore();

        expect(data['senderImageUrl'], isNull);
        expect(data['senderTeamFlair'], isNull);
        expect(data['deletedBy'], isNull);
        expect(data['eventData'], isNull);
      });
    });

    group('Equatable', () {
      test('equal messages are equal', () {
        final m1 = createMessage();
        final m2 = createMessage();
        expect(m1, equals(m2));
      });

      test('different messageId makes not equal', () {
        final m1 = createMessage(messageId: 'msg_1');
        final m2 = createMessage(messageId: 'msg_2');
        expect(m1, isNot(equals(m2)));
      });
    });
  });

  group('MatchEventData', () {
    group('Constructor', () {
      test('creates event data with all fields', () {
        const event = MatchEventData(
          eventType: MatchEventType.goal,
          team: 'ARG',
          playerName: 'Messi',
          minute: 72,
          description: 'Brilliant left-foot strike',
        );

        expect(event.eventType, equals(MatchEventType.goal));
        expect(event.team, equals('ARG'));
        expect(event.playerName, equals('Messi'));
        expect(event.minute, equals(72));
        expect(event.description, equals('Brilliant left-foot strike'));
      });

      test('creates event data with required fields only', () {
        const event = MatchEventData(eventType: MatchEventType.kickoff);

        expect(event.team, isNull);
        expect(event.playerName, isNull);
        expect(event.minute, isNull);
        expect(event.description, isNull);
      });
    });

    group('fromJson', () {
      test('deserializes all fields', () {
        final json = {
          'eventType': 'goal',
          'team': 'USA',
          'playerName': 'Pulisic',
          'minute': 55,
          'description': 'Header from corner',
        };

        final event = MatchEventData.fromJson(json);

        expect(event.eventType, equals(MatchEventType.goal));
        expect(event.team, equals('USA'));
        expect(event.playerName, equals('Pulisic'));
        expect(event.minute, equals(55));
        expect(event.description, equals('Header from corner'));
      });

      test('handles unknown event type with fallback', () {
        final json = {
          'eventType': 'unknown_type',
        };

        final event = MatchEventData.fromJson(json);
        expect(event.eventType, equals(MatchEventType.other));
      });

      test('handles missing optional fields', () {
        final json = {'eventType': 'yellowCard'};

        final event = MatchEventData.fromJson(json);
        expect(event.eventType, equals(MatchEventType.yellowCard));
        expect(event.team, isNull);
        expect(event.playerName, isNull);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        const event = MatchEventData(
          eventType: MatchEventType.penalty,
          team: 'BRA',
          playerName: 'Neymar',
          minute: 88,
          description: 'Converted penalty',
        );

        final json = event.toJson();

        expect(json['eventType'], equals('penalty'));
        expect(json['team'], equals('BRA'));
        expect(json['playerName'], equals('Neymar'));
        expect(json['minute'], equals(88));
        expect(json['description'], equals('Converted penalty'));
      });
    });

    group('roundtrip serialization', () {
      test('toJson/fromJson preserves data', () {
        const original = MatchEventData(
          eventType: MatchEventType.redCard,
          team: 'GER',
          playerName: 'Mueller',
          minute: 67,
          description: 'Violent conduct',
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
      test('equal events are equal', () {
        const e1 = MatchEventData(
          eventType: MatchEventType.goal,
          team: 'USA',
          minute: 45,
        );
        const e2 = MatchEventData(
          eventType: MatchEventType.goal,
          team: 'USA',
          minute: 45,
        );
        expect(e1, equals(e2));
      });

      test('different events are not equal', () {
        const e1 = MatchEventData(
          eventType: MatchEventType.goal,
          team: 'USA',
          minute: 45,
        );
        const e2 = MatchEventData(
          eventType: MatchEventType.yellowCard,
          team: 'USA',
          minute: 45,
        );
        expect(e1, isNot(equals(e2)));
      });
    });
  });

  group('MatchEventTypeExtension', () {
    group('emoji', () {
      test('returns correct emoji for each event type', () {
        expect(MatchEventType.goal.emoji, isNotEmpty);
        expect(MatchEventType.ownGoal.emoji, isNotEmpty);
        expect(MatchEventType.penalty.emoji, isNotEmpty);
        expect(MatchEventType.penaltyMissed.emoji, isNotEmpty);
        expect(MatchEventType.yellowCard.emoji, isNotEmpty);
        expect(MatchEventType.redCard.emoji, isNotEmpty);
        expect(MatchEventType.substitution.emoji, isNotEmpty);
        expect(MatchEventType.kickoff.emoji, isNotEmpty);
        expect(MatchEventType.halftime.emoji, isNotEmpty);
        expect(MatchEventType.fulltime.emoji, isNotEmpty);
        expect(MatchEventType.varReview.emoji, isNotEmpty);
        expect(MatchEventType.injury.emoji, isNotEmpty);
        expect(MatchEventType.other.emoji, isNotEmpty);
      });

      test('all event types have unique emojis', () {
        final emojis = MatchEventType.values.map((e) => e.emoji).toSet();
        expect(emojis.length, equals(MatchEventType.values.length));
      });
    });

    group('displayName', () {
      test('returns correct display names', () {
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

  group('MatchChatReactions', () {
    test('quickReactions has 8 emojis', () {
      expect(MatchChatReactions.quickReactions, hasLength(8));
    });

    test('reactionLabels matches quickReactions', () {
      for (final emoji in MatchChatReactions.quickReactions) {
        expect(MatchChatReactions.reactionLabels.containsKey(emoji), isTrue,
            reason: 'Missing label for emoji: $emoji');
      }
    });

    test('reactionLabels have non-empty values', () {
      for (final entry in MatchChatReactions.reactionLabels.entries) {
        expect(entry.value, isNotEmpty, reason: 'Empty label for ${entry.key}');
      }
    });
  });

  group('MatchChatSettings', () {
    group('Constructor', () {
      test('creates settings with defaults', () {
        const settings = MatchChatSettings();

        expect(settings.slowModeEnabled, isFalse);
        expect(settings.slowModeSeconds, equals(5));
        expect(settings.subscribersOnly, isFalse);
        expect(settings.moderatorsOnly, isFalse);
        expect(settings.maxMessageLength, equals(500));
      });

      test('creates settings with custom values', () {
        const settings = MatchChatSettings(
          slowModeEnabled: true,
          slowModeSeconds: 10,
          subscribersOnly: true,
          moderatorsOnly: false,
          maxMessageLength: 250,
        );

        expect(settings.slowModeEnabled, isTrue);
        expect(settings.slowModeSeconds, equals(10));
        expect(settings.subscribersOnly, isTrue);
        expect(settings.maxMessageLength, equals(250));
      });
    });

    group('fromJson', () {
      test('deserializes all fields', () {
        final json = {
          'slowModeEnabled': true,
          'slowModeSeconds': 15,
          'subscribersOnly': true,
          'moderatorsOnly': true,
          'maxMessageLength': 200,
        };

        final settings = MatchChatSettings.fromJson(json);

        expect(settings.slowModeEnabled, isTrue);
        expect(settings.slowModeSeconds, equals(15));
        expect(settings.subscribersOnly, isTrue);
        expect(settings.moderatorsOnly, isTrue);
        expect(settings.maxMessageLength, equals(200));
      });

      test('handles missing fields with defaults', () {
        final settings = MatchChatSettings.fromJson({});

        expect(settings.slowModeEnabled, isFalse);
        expect(settings.slowModeSeconds, equals(5));
        expect(settings.subscribersOnly, isFalse);
        expect(settings.moderatorsOnly, isFalse);
        expect(settings.maxMessageLength, equals(500));
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        const settings = MatchChatSettings(
          slowModeEnabled: true,
          slowModeSeconds: 20,
          subscribersOnly: true,
          moderatorsOnly: false,
          maxMessageLength: 1000,
        );

        final json = settings.toJson();

        expect(json['slowModeEnabled'], isTrue);
        expect(json['slowModeSeconds'], equals(20));
        expect(json['subscribersOnly'], isTrue);
        expect(json['moderatorsOnly'], isFalse);
        expect(json['maxMessageLength'], equals(1000));
      });
    });

    group('roundtrip serialization', () {
      test('toJson/fromJson preserves data', () {
        const original = MatchChatSettings(
          slowModeEnabled: true,
          slowModeSeconds: 30,
          subscribersOnly: true,
          moderatorsOnly: true,
          maxMessageLength: 300,
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
  });
}
