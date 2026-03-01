import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/services/offline_service.dart';

void main() {
  group('ConnectivityState', () {
    test('has 3 states', () {
      expect(ConnectivityState.values.length, equals(3));
    });

    test('has online state', () {
      expect(ConnectivityState.online, isNotNull);
      expect(ConnectivityState.online.name, equals('online'));
    });

    test('has offline state', () {
      expect(ConnectivityState.offline, isNotNull);
      expect(ConnectivityState.offline.name, equals('offline'));
    });

    test('has syncing state', () {
      expect(ConnectivityState.syncing, isNotNull);
      expect(ConnectivityState.syncing.name, equals('syncing'));
    });
  });

  group('QueuedAction', () {
    final testDateTime = DateTime(2026, 6, 11, 14, 0, 0);

    group('constructor', () {
      test('creates with required fields', () {
        final action = QueuedAction(
          id: 'test-1',
          type: 'create_prediction',
          data: {'matchId': 'M001', 'score': '2-1'},
          createdAt: testDateTime,
        );

        expect(action.id, equals('test-1'));
        expect(action.type, equals('create_prediction'));
        expect(action.data, equals({'matchId': 'M001', 'score': '2-1'}));
        expect(action.createdAt, equals(testDateTime));
        expect(action.retryCount, equals(0));
      });

      test('creates with custom retry count', () {
        final action = QueuedAction(
          id: 'test-2',
          type: 'send_chat_message',
          data: {'message': 'hello'},
          createdAt: testDateTime,
          retryCount: 3,
        );

        expect(action.retryCount, equals(3));
      });

      test('default retry count is 0', () {
        final action = QueuedAction(
          id: 'test-3',
          type: 'join_watch_party',
          data: {},
          createdAt: testDateTime,
        );

        expect(action.retryCount, equals(0));
      });
    });

    group('copyWith', () {
      test('updates retry count', () {
        final action = QueuedAction(
          id: 'test-1',
          type: 'create_prediction',
          data: {'matchId': 'M001'},
          createdAt: testDateTime,
          retryCount: 0,
        );

        final updated = action.copyWith(retryCount: 2);
        expect(updated.retryCount, equals(2));
        // Other fields are preserved
        expect(updated.id, equals('test-1'));
        expect(updated.type, equals('create_prediction'));
        expect(updated.data, equals({'matchId': 'M001'}));
        expect(updated.createdAt, equals(testDateTime));
      });

      test('preserves retry count when not specified', () {
        final action = QueuedAction(
          id: 'test-1',
          type: 'create_prediction',
          data: {},
          createdAt: testDateTime,
          retryCount: 5,
        );

        final updated = action.copyWith();
        expect(updated.retryCount, equals(5));
      });
    });

    group('toMap', () {
      test('serializes all fields', () {
        final action = QueuedAction(
          id: 'test-1',
          type: 'create_prediction',
          data: {'matchId': 'M001', 'score': '2-1'},
          createdAt: testDateTime,
          retryCount: 1,
        );

        final map = action.toMap();
        expect(map['id'], equals('test-1'));
        expect(map['type'], equals('create_prediction'));
        expect(map['data'], equals({'matchId': 'M001', 'score': '2-1'}));
        expect(map['createdAt'], equals(testDateTime.toIso8601String()));
        expect(map['retryCount'], equals(1));
      });

      test('contains all expected keys', () {
        final action = QueuedAction(
          id: 'test-1',
          type: 'test',
          data: {},
          createdAt: testDateTime,
        );

        final map = action.toMap();
        expect(map.keys.length, equals(5));
        expect(map.containsKey('id'), isTrue);
        expect(map.containsKey('type'), isTrue);
        expect(map.containsKey('data'), isTrue);
        expect(map.containsKey('createdAt'), isTrue);
        expect(map.containsKey('retryCount'), isTrue);
      });

      test('serializes empty data map', () {
        final action = QueuedAction(
          id: 'test-1',
          type: 'test',
          data: {},
          createdAt: testDateTime,
        );

        final map = action.toMap();
        expect(map['data'], equals({}));
      });

      test('serializes nested data map', () {
        final action = QueuedAction(
          id: 'test-1',
          type: 'update_profile',
          data: {
            'user': {
              'name': 'Test User',
              'preferences': {'theme': 'dark'},
            },
            'tags': ['soccer', 'worldcup'],
          },
          createdAt: testDateTime,
        );

        final map = action.toMap();
        expect((map['data'] as Map)['user'], isA<Map>());
        expect(
          (map['data'] as Map)['tags'],
          equals(['soccer', 'worldcup']),
        );
      });
    });

    group('fromMap', () {
      test('deserializes from complete map', () {
        final map = {
          'id': 'test-1',
          'type': 'create_prediction',
          'data': {'matchId': 'M001', 'score': '2-1'},
          'createdAt': testDateTime.toIso8601String(),
          'retryCount': 2,
        };

        final action = QueuedAction.fromMap(map);
        expect(action.id, equals('test-1'));
        expect(action.type, equals('create_prediction'));
        expect(action.data, equals({'matchId': 'M001', 'score': '2-1'}));
        expect(action.createdAt, equals(testDateTime));
        expect(action.retryCount, equals(2));
      });

      test('defaults retryCount to 0 when missing', () {
        final map = {
          'id': 'test-1',
          'type': 'test',
          'data': <String, dynamic>{},
          'createdAt': testDateTime.toIso8601String(),
        };

        final action = QueuedAction.fromMap(map);
        expect(action.retryCount, equals(0));
      });

      test('defaults retryCount to 0 when null', () {
        final map = {
          'id': 'test-1',
          'type': 'test',
          'data': <String, dynamic>{},
          'createdAt': testDateTime.toIso8601String(),
          'retryCount': null,
        };

        final action = QueuedAction.fromMap(map);
        expect(action.retryCount, equals(0));
      });
    });

    group('roundtrip serialization', () {
      test('toMap/fromMap are symmetric', () {
        final original = QueuedAction(
          id: 'roundtrip-1',
          type: 'send_chat_message',
          data: {'message': 'hello world', 'chatId': 'chat-123'},
          createdAt: testDateTime,
          retryCount: 1,
        );

        final roundtripped = QueuedAction.fromMap(original.toMap());
        expect(roundtripped.id, equals(original.id));
        expect(roundtripped.type, equals(original.type));
        expect(roundtripped.data, equals(original.data));
        expect(roundtripped.createdAt, equals(original.createdAt));
        expect(roundtripped.retryCount, equals(original.retryCount));
      });

      test('survives JSON encode/decode cycle', () {
        final original = QueuedAction(
          id: 'json-1',
          type: 'create_prediction',
          data: {'matchId': 'M001', 'homeScore': 2, 'awayScore': 1},
          createdAt: testDateTime,
          retryCount: 0,
        );

        final jsonStr = json.encode(original.toMap());
        final decoded = json.decode(jsonStr) as Map<String, dynamic>;
        final restored = QueuedAction.fromMap(decoded);

        expect(restored.id, equals(original.id));
        expect(restored.type, equals(original.type));
        expect(restored.data['matchId'], equals(original.data['matchId']));
        expect(restored.createdAt, equals(original.createdAt));
        expect(restored.retryCount, equals(original.retryCount));
      });

      test('list of actions survives JSON roundtrip', () {
        final actions = [
          QueuedAction(
            id: 'list-1',
            type: 'create_prediction',
            data: {'matchId': 'M001'},
            createdAt: testDateTime,
          ),
          QueuedAction(
            id: 'list-2',
            type: 'send_chat_message',
            data: {'message': 'test'},
            createdAt: testDateTime.add(const Duration(minutes: 5)),
            retryCount: 1,
          ),
        ];

        final jsonStr = json.encode(actions.map((a) => a.toMap()).toList());
        final List<dynamic> decoded = json.decode(jsonStr);
        final restored = decoded
            .map((e) => QueuedAction.fromMap(e as Map<String, dynamic>))
            .toList();

        expect(restored.length, equals(2));
        expect(restored[0].id, equals('list-1'));
        expect(restored[0].type, equals('create_prediction'));
        expect(restored[1].id, equals('list-2'));
        expect(restored[1].type, equals('send_chat_message'));
        expect(restored[1].retryCount, equals(1));
      });
    });
  });

  group('SyncStatus', () {
    group('constructor defaults', () {
      test('has correct default values', () {
        const status = SyncStatus();
        expect(status.isSyncing, isFalse);
        expect(status.pendingActions, equals(0));
        expect(status.completedActions, equals(0));
        expect(status.failedActions, equals(0));
        expect(status.lastSyncTime, isNull);
        expect(status.currentAction, isNull);
        expect(status.errorMessage, isNull);
      });
    });

    group('constructor with values', () {
      test('accepts all custom values', () {
        final now = DateTime.now();
        final status = SyncStatus(
          isSyncing: true,
          pendingActions: 5,
          completedActions: 3,
          failedActions: 1,
          lastSyncTime: now,
          currentAction: 'create_prediction',
          errorMessage: 'Network error',
        );

        expect(status.isSyncing, isTrue);
        expect(status.pendingActions, equals(5));
        expect(status.completedActions, equals(3));
        expect(status.failedActions, equals(1));
        expect(status.lastSyncTime, equals(now));
        expect(status.currentAction, equals('create_prediction'));
        expect(status.errorMessage, equals('Network error'));
      });
    });

    group('progress', () {
      test('returns 1.0 when no actions', () {
        const status = SyncStatus();
        expect(status.progress, equals(1.0));
      });

      test('returns 0.0 when all pending', () {
        const status = SyncStatus(
          pendingActions: 5,
          completedActions: 0,
          failedActions: 0,
        );
        expect(status.progress, equals(0.0));
      });

      test('returns 1.0 when all completed', () {
        const status = SyncStatus(
          pendingActions: 0,
          completedActions: 5,
          failedActions: 0,
        );
        expect(status.progress, equals(1.0));
      });

      test('returns correct progress for mixed state', () {
        const status = SyncStatus(
          pendingActions: 2,
          completedActions: 6,
          failedActions: 2,
        );
        // total = 2 + 6 + 2 = 10
        // done = 6 + 2 = 8
        // progress = 8/10 = 0.8
        expect(status.progress, equals(0.8));
      });

      test('counts failed actions as done for progress', () {
        const status = SyncStatus(
          pendingActions: 0,
          completedActions: 0,
          failedActions: 3,
        );
        // All actions finished (even if failed)
        expect(status.progress, equals(1.0));
      });

      test('returns 0.5 for half completed', () {
        const status = SyncStatus(
          pendingActions: 5,
          completedActions: 5,
          failedActions: 0,
        );
        expect(status.progress, equals(0.5));
      });
    });

    group('hasErrors', () {
      test('returns false when no failed actions', () {
        const status = SyncStatus(failedActions: 0);
        expect(status.hasErrors, isFalse);
      });

      test('returns true when there are failed actions', () {
        const status = SyncStatus(failedActions: 1);
        expect(status.hasErrors, isTrue);
      });

      test('returns true for multiple failed actions', () {
        const status = SyncStatus(failedActions: 10);
        expect(status.hasErrors, isTrue);
      });
    });

    group('copyWith', () {
      test('updates single field', () {
        const original = SyncStatus();
        final updated = original.copyWith(isSyncing: true);
        expect(updated.isSyncing, isTrue);
        expect(updated.pendingActions, equals(0));
        expect(updated.completedActions, equals(0));
      });

      test('preserves unchanged fields', () {
        final now = DateTime.now();
        final original = SyncStatus(
          isSyncing: true,
          pendingActions: 5,
          completedActions: 3,
          failedActions: 1,
          lastSyncTime: now,
          currentAction: 'test',
          errorMessage: 'error',
        );

        final updated = original.copyWith(completedActions: 4);
        expect(updated.isSyncing, isTrue);
        expect(updated.pendingActions, equals(5));
        expect(updated.completedActions, equals(4));
        expect(updated.failedActions, equals(1));
        expect(updated.lastSyncTime, equals(now));
        expect(updated.currentAction, equals('test'));
        expect(updated.errorMessage, equals('error'));
      });

      test('can update all fields', () {
        const original = SyncStatus();
        final now = DateTime.now();

        final updated = original.copyWith(
          isSyncing: true,
          pendingActions: 10,
          completedActions: 5,
          failedActions: 2,
          lastSyncTime: now,
          currentAction: 'update_profile',
          errorMessage: 'timeout',
        );

        expect(updated.isSyncing, isTrue);
        expect(updated.pendingActions, equals(10));
        expect(updated.completedActions, equals(5));
        expect(updated.failedActions, equals(2));
        expect(updated.lastSyncTime, equals(now));
        expect(updated.currentAction, equals('update_profile'));
        expect(updated.errorMessage, equals('timeout'));
      });

      test('returns equivalent object when no fields provided', () {
        const original = SyncStatus(
          isSyncing: true,
          pendingActions: 3,
        );
        final copied = original.copyWith();
        expect(copied.isSyncing, equals(original.isSyncing));
        expect(copied.pendingActions, equals(original.pendingActions));
      });
    });
  });

  group('OfflineActionTypes', () {
    test('has createPrediction constant', () {
      expect(OfflineActionTypes.createPrediction, equals('create_prediction'));
    });

    test('has updatePrediction constant', () {
      expect(OfflineActionTypes.updatePrediction, equals('update_prediction'));
    });

    test('has joinWatchParty constant', () {
      expect(OfflineActionTypes.joinWatchParty, equals('join_watch_party'));
    });

    test('has leaveWatchParty constant', () {
      expect(OfflineActionTypes.leaveWatchParty, equals('leave_watch_party'));
    });

    test('has sendChatMessage constant', () {
      expect(OfflineActionTypes.sendChatMessage, equals('send_chat_message'));
    });

    test('has addFavorite constant', () {
      expect(OfflineActionTypes.addFavorite, equals('add_favorite'));
    });

    test('has removeFavorite constant', () {
      expect(OfflineActionTypes.removeFavorite, equals('remove_favorite'));
    });

    test('has updateProfile constant', () {
      expect(OfflineActionTypes.updateProfile, equals('update_profile'));
    });

    test('all action types are unique', () {
      final types = [
        OfflineActionTypes.createPrediction,
        OfflineActionTypes.updatePrediction,
        OfflineActionTypes.joinWatchParty,
        OfflineActionTypes.leaveWatchParty,
        OfflineActionTypes.sendChatMessage,
        OfflineActionTypes.addFavorite,
        OfflineActionTypes.removeFavorite,
        OfflineActionTypes.updateProfile,
      ];
      expect(types.toSet().length, equals(types.length));
    });

    test('action types are snake_case strings', () {
      final types = [
        OfflineActionTypes.createPrediction,
        OfflineActionTypes.updatePrediction,
        OfflineActionTypes.joinWatchParty,
        OfflineActionTypes.leaveWatchParty,
        OfflineActionTypes.sendChatMessage,
        OfflineActionTypes.addFavorite,
        OfflineActionTypes.removeFavorite,
        OfflineActionTypes.updateProfile,
      ];
      final snakeCaseRegex = RegExp(r'^[a-z]+(_[a-z]+)*$');
      for (final type in types) {
        expect(snakeCaseRegex.hasMatch(type), isTrue,
            reason: '$type should be snake_case');
      }
    });
  });

  group('QueuedAction edge cases', () {
    test('handles empty string fields', () {
      final action = QueuedAction(
        id: '',
        type: '',
        data: {},
        createdAt: DateTime(2026, 1, 1),
      );

      final map = action.toMap();
      final restored = QueuedAction.fromMap(map);
      expect(restored.id, equals(''));
      expect(restored.type, equals(''));
    });

    test('handles large data maps', () {
      final data = <String, dynamic>{};
      for (int i = 0; i < 100; i++) {
        data['key_$i'] = 'value_$i';
      }

      final action = QueuedAction(
        id: 'large-data',
        type: 'test',
        data: data,
        createdAt: DateTime(2026, 6, 11),
      );

      final map = action.toMap();
      final restored = QueuedAction.fromMap(map);
      expect(restored.data.length, equals(100));
      expect(restored.data['key_50'], equals('value_50'));
    });

    test('handles high retry count', () {
      final action = QueuedAction(
        id: 'high-retry',
        type: 'test',
        data: {},
        createdAt: DateTime(2026, 6, 11),
        retryCount: 999,
      );

      final roundtripped = QueuedAction.fromMap(action.toMap());
      expect(roundtripped.retryCount, equals(999));
    });

    test('handles special characters in data', () {
      final action = QueuedAction(
        id: 'special-chars',
        type: 'send_chat_message',
        data: {
          'message': 'Hello! "World" \'Cup\' 2026 <goal> & more',
          'emoji': '\u26BD\uD83C\uDFC6',
        },
        createdAt: DateTime(2026, 6, 11),
      );

      final jsonStr = json.encode(action.toMap());
      final decoded = json.decode(jsonStr) as Map<String, dynamic>;
      final restored = QueuedAction.fromMap(decoded);

      expect(restored.data['message'],
          equals('Hello! "World" \'Cup\' 2026 <goal> & more'));
    });

    test('handles UTC and local dates', () {
      final utcDate = DateTime.utc(2026, 6, 11, 14, 0, 0);
      final action = QueuedAction(
        id: 'utc-test',
        type: 'test',
        data: {},
        createdAt: utcDate,
      );

      final map = action.toMap();
      expect(map['createdAt'], contains('2026-06-11'));
    });
  });

  group('SyncStatus edge cases', () {
    test('progress handles large numbers', () {
      const status = SyncStatus(
        pendingActions: 0,
        completedActions: 1000000,
        failedActions: 0,
      );
      expect(status.progress, equals(1.0));
    });

    test('progress handles all zeros', () {
      const status = SyncStatus(
        pendingActions: 0,
        completedActions: 0,
        failedActions: 0,
      );
      expect(status.progress, equals(1.0));
    });

    test('progress is between 0 and 1', () {
      final testCases = [
        const SyncStatus(pendingActions: 10),
        const SyncStatus(completedActions: 5, pendingActions: 5),
        const SyncStatus(failedActions: 3, pendingActions: 7),
        const SyncStatus(
            completedActions: 3, failedActions: 2, pendingActions: 5),
      ];

      for (final status in testCases) {
        expect(status.progress, greaterThanOrEqualTo(0.0));
        expect(status.progress, lessThanOrEqualTo(1.0));
      }
    });
  });
}
