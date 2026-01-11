import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party_invite.dart';

void main() {
  group('WatchPartyInviteStatus', () {
    test('has expected values', () {
      expect(WatchPartyInviteStatus.values, hasLength(4));
      expect(WatchPartyInviteStatus.values, contains(WatchPartyInviteStatus.pending));
      expect(WatchPartyInviteStatus.values, contains(WatchPartyInviteStatus.accepted));
      expect(WatchPartyInviteStatus.values, contains(WatchPartyInviteStatus.declined));
      expect(WatchPartyInviteStatus.values, contains(WatchPartyInviteStatus.expired));
    });
  });

  group('WatchPartyInvite', () {
    final testCreatedAt = DateTime(2024, 10, 15, 12, 0, 0);
    final testExpiresAt = DateTime(2024, 10, 22, 12, 0, 0);
    final testGameDateTime = DateTime(2024, 10, 20, 18, 0, 0);

    WatchPartyInvite createTestInvite({
      String inviteId = 'inv_1',
      String watchPartyId = 'wp_123',
      String watchPartyName = 'Game Day Party',
      String inviterId = 'host_1',
      String inviterName = 'John Host',
      String? inviterImageUrl,
      String inviteeId = 'user_2',
      WatchPartyInviteStatus status = WatchPartyInviteStatus.pending,
      DateTime? createdAt,
      DateTime? expiresAt,
      String? message,
      String? gameName,
      DateTime? gameDateTime,
      String? venueName,
    }) {
      return WatchPartyInvite(
        inviteId: inviteId,
        watchPartyId: watchPartyId,
        watchPartyName: watchPartyName,
        inviterId: inviterId,
        inviterName: inviterName,
        inviterImageUrl: inviterImageUrl,
        inviteeId: inviteeId,
        status: status,
        createdAt: createdAt ?? testCreatedAt,
        expiresAt: expiresAt ?? testExpiresAt,
        message: message,
        gameName: gameName,
        gameDateTime: gameDateTime,
        venueName: venueName,
      );
    }

    group('Constructor', () {
      test('creates invite with required fields', () {
        final invite = createTestInvite();

        expect(invite.inviteId, equals('inv_1'));
        expect(invite.watchPartyId, equals('wp_123'));
        expect(invite.watchPartyName, equals('Game Day Party'));
        expect(invite.inviterId, equals('host_1'));
        expect(invite.inviterName, equals('John Host'));
        expect(invite.inviteeId, equals('user_2'));
        expect(invite.status, equals(WatchPartyInviteStatus.pending));
      });

      test('creates invite with optional fields', () {
        final invite = createTestInvite(
          inviterImageUrl: 'https://example.com/avatar.jpg',
          message: 'Join us for the big game!',
          gameName: 'USA vs Mexico',
          gameDateTime: testGameDateTime,
          venueName: 'Sports Bar Downtown',
        );

        expect(invite.inviterImageUrl, equals('https://example.com/avatar.jpg'));
        expect(invite.message, equals('Join us for the big game!'));
        expect(invite.gameName, equals('USA vs Mexico'));
        expect(invite.gameDateTime, equals(testGameDateTime));
        expect(invite.venueName, equals('Sports Bar Downtown'));
      });
    });

    group('Factory create', () {
      test('creates invite with generated ID', () {
        final invite = WatchPartyInvite.create(
          watchPartyId: 'wp_test',
          watchPartyName: 'Test Party',
          inviterId: 'inviter_1',
          inviterName: 'Inviter',
          inviteeId: 'invitee_1',
          expiresAt: testExpiresAt,
        );

        expect(invite.inviteId, contains('inv_'));
        expect(invite.inviteId, contains('inviter_1'));
        expect(invite.inviteId, contains('invitee_1'));
        expect(invite.status, equals(WatchPartyInviteStatus.pending));
      });

      test('creates invite with optional fields', () {
        final invite = WatchPartyInvite.create(
          watchPartyId: 'wp_test',
          watchPartyName: 'Test Party',
          inviterId: 'inviter_1',
          inviterName: 'Inviter',
          inviteeId: 'invitee_1',
          expiresAt: testExpiresAt,
          message: 'Come watch!',
          gameName: 'Big Game',
          gameDateTime: testGameDateTime,
          venueName: 'Bar',
        );

        expect(invite.message, equals('Come watch!'));
        expect(invite.gameName, equals('Big Game'));
        expect(invite.venueName, equals('Bar'));
      });
    });

    group('Status computed getters', () {
      test('isPending returns true for pending status', () {
        final pending = createTestInvite(status: WatchPartyInviteStatus.pending);
        final accepted = createTestInvite(status: WatchPartyInviteStatus.accepted);

        expect(pending.isPending, isTrue);
        expect(pending.isAccepted, isFalse);
        expect(accepted.isPending, isFalse);
        expect(accepted.isAccepted, isTrue);
      });

      test('isDeclined returns true for declined status', () {
        final declined = createTestInvite(status: WatchPartyInviteStatus.declined);
        expect(declined.isDeclined, isTrue);
      });

      test('isExpiredStatus returns true for expired status', () {
        final expired = createTestInvite(status: WatchPartyInviteStatus.expired);
        expect(expired.isExpiredStatus, isTrue);
      });

      test('statusDisplayName returns correct strings', () {
        expect(
          createTestInvite(status: WatchPartyInviteStatus.pending).statusDisplayName,
          equals('Pending'),
        );
        expect(
          createTestInvite(status: WatchPartyInviteStatus.accepted).statusDisplayName,
          equals('Accepted'),
        );
        expect(
          createTestInvite(status: WatchPartyInviteStatus.declined).statusDisplayName,
          equals('Declined'),
        );
        expect(
          createTestInvite(status: WatchPartyInviteStatus.expired).statusDisplayName,
          equals('Expired'),
        );
      });
    });

    group('isExpired', () {
      test('returns false for future expiry', () {
        final futureExpiry = DateTime.now().add(const Duration(days: 7));
        final invite = createTestInvite(expiresAt: futureExpiry);
        expect(invite.isExpired, isFalse);
      });

      test('returns true for past expiry', () {
        final pastExpiry = DateTime.now().subtract(const Duration(days: 1));
        final invite = createTestInvite(expiresAt: pastExpiry);
        expect(invite.isExpired, isTrue);
      });
    });

    group('isValid', () {
      test('returns true when pending and not expired', () {
        final futureExpiry = DateTime.now().add(const Duration(days: 7));
        final invite = createTestInvite(
          status: WatchPartyInviteStatus.pending,
          expiresAt: futureExpiry,
        );
        expect(invite.isValid, isTrue);
      });

      test('returns false when accepted', () {
        final futureExpiry = DateTime.now().add(const Duration(days: 7));
        final invite = createTestInvite(
          status: WatchPartyInviteStatus.accepted,
          expiresAt: futureExpiry,
        );
        expect(invite.isValid, isFalse);
      });

      test('returns false when expired', () {
        final pastExpiry = DateTime.now().subtract(const Duration(days: 1));
        final invite = createTestInvite(
          status: WatchPartyInviteStatus.pending,
          expiresAt: pastExpiry,
        );
        expect(invite.isValid, isFalse);
      });
    });

    group('canRespond', () {
      test('returns true when pending and not expired', () {
        final futureExpiry = DateTime.now().add(const Duration(days: 7));
        final invite = createTestInvite(
          status: WatchPartyInviteStatus.pending,
          expiresAt: futureExpiry,
        );
        expect(invite.canRespond, isTrue);
      });

      test('returns false when already accepted', () {
        final futureExpiry = DateTime.now().add(const Duration(days: 7));
        final invite = createTestInvite(
          status: WatchPartyInviteStatus.accepted,
          expiresAt: futureExpiry,
        );
        expect(invite.canRespond, isFalse);
      });
    });

    group('timeAgo', () {
      test('returns "Just now" for recent invites', () {
        final now = DateTime.now();
        final invite = createTestInvite(createdAt: now);
        expect(invite.timeAgo, equals('Just now'));
      });

      test('returns minutes format', () {
        final past = DateTime.now().subtract(const Duration(minutes: 30));
        final invite = createTestInvite(createdAt: past);
        expect(invite.timeAgo, contains('30m ago'));
      });

      test('returns hours format', () {
        final past = DateTime.now().subtract(const Duration(hours: 5));
        final invite = createTestInvite(createdAt: past);
        expect(invite.timeAgo, contains('5h ago'));
      });

      test('returns days format', () {
        final past = DateTime.now().subtract(const Duration(days: 3));
        final invite = createTestInvite(createdAt: past);
        expect(invite.timeAgo, contains('3d ago'));
      });
    });

    group('expiresIn', () {
      test('returns "Expired" for past expiry', () {
        final pastExpiry = DateTime.now().subtract(const Duration(hours: 1));
        final invite = createTestInvite(expiresAt: pastExpiry);
        expect(invite.expiresIn, equals('Expired'));
      });

      test('returns days format for future expiry', () {
        final futureExpiry = DateTime.now().add(const Duration(days: 5));
        final invite = createTestInvite(expiresAt: futureExpiry);
        expect(invite.expiresIn, contains('5d'));
      });

      test('returns hours format', () {
        final futureExpiry = DateTime.now().add(const Duration(hours: 12));
        final invite = createTestInvite(expiresAt: futureExpiry);
        expect(invite.expiresIn, contains('12h'));
      });

      test('returns minutes format', () {
        final futureExpiry = DateTime.now().add(const Duration(minutes: 45));
        final invite = createTestInvite(expiresAt: futureExpiry);
        expect(invite.expiresIn, contains('45m'));
      });

      test('returns "Expires soon" for imminent expiry', () {
        final futureExpiry = DateTime.now().add(const Duration(seconds: 30));
        final invite = createTestInvite(expiresAt: futureExpiry);
        expect(invite.expiresIn, equals('Expires soon'));
      });
    });

    group('Specialized methods', () {
      test('accept changes status to accepted', () {
        final pending = createTestInvite(status: WatchPartyInviteStatus.pending);
        final accepted = pending.accept();

        expect(accepted.status, equals(WatchPartyInviteStatus.accepted));
        expect(accepted.inviteId, equals(pending.inviteId));
      });

      test('decline changes status to declined', () {
        final pending = createTestInvite(status: WatchPartyInviteStatus.pending);
        final declined = pending.decline();

        expect(declined.status, equals(WatchPartyInviteStatus.declined));
      });

      test('markExpired changes status to expired', () {
        final pending = createTestInvite(status: WatchPartyInviteStatus.pending);
        final expired = pending.markExpired();

        expect(expired.status, equals(WatchPartyInviteStatus.expired));
      });
    });

    group('copyWith', () {
      test('copies with updated status', () {
        final original = createTestInvite();
        final updated = original.copyWith(
          status: WatchPartyInviteStatus.accepted,
        );

        expect(updated.status, equals(WatchPartyInviteStatus.accepted));
        expect(updated.inviteId, equals(original.inviteId));
        expect(updated.watchPartyName, equals(original.watchPartyName));
      });

      test('copies with updated message', () {
        final original = createTestInvite(message: 'Original');
        final updated = original.copyWith(message: 'Updated message');

        expect(updated.message, equals('Updated message'));
        expect(updated.status, equals(original.status));
      });

      test('preserves unchanged fields', () {
        final original = createTestInvite(
          gameName: 'Big Game',
          venueName: 'Sports Bar',
        );
        final updated = original.copyWith(status: WatchPartyInviteStatus.accepted);

        expect(updated.gameName, equals('Big Game'));
        expect(updated.venueName, equals('Sports Bar'));
        expect(updated.inviterId, equals(original.inviterId));
      });
    });

    group('JSON serialization', () {
      test('toJson serializes all fields', () {
        final invite = createTestInvite(
          inviterImageUrl: 'https://example.com/avatar.jpg',
          message: 'Join us!',
          gameName: 'USA vs Mexico',
          gameDateTime: testGameDateTime,
          venueName: 'Sports Bar',
        );
        final json = invite.toJson();

        expect(json['inviteId'], equals('inv_1'));
        expect(json['watchPartyId'], equals('wp_123'));
        expect(json['watchPartyName'], equals('Game Day Party'));
        expect(json['inviterId'], equals('host_1'));
        expect(json['inviterName'], equals('John Host'));
        expect(json['inviterImageUrl'], equals('https://example.com/avatar.jpg'));
        expect(json['inviteeId'], equals('user_2'));
        expect(json['status'], equals('pending'));
        expect(json['message'], equals('Join us!'));
        expect(json['gameName'], equals('USA vs Mexico'));
        expect(json['venueName'], equals('Sports Bar'));
      });

      test('fromJson deserializes correctly', () {
        final json = {
          'inviteId': 'inv_test',
          'watchPartyId': 'wp_test',
          'watchPartyName': 'Test Party',
          'inviterId': 'inviter_1',
          'inviterName': 'Inviter',
          'inviteeId': 'invitee_1',
          'status': 'accepted',
          'createdAt': '2024-10-15T12:00:00.000',
          'expiresAt': '2024-10-22T12:00:00.000',
          'message': 'Welcome!',
          'gameName': 'Test Game',
          'gameDateTime': '2024-10-20T18:00:00.000',
          'venueName': 'Test Venue',
        };

        final invite = WatchPartyInvite.fromJson(json);

        expect(invite.inviteId, equals('inv_test'));
        expect(invite.status, equals(WatchPartyInviteStatus.accepted));
        expect(invite.message, equals('Welcome!'));
        expect(invite.gameName, equals('Test Game'));
        expect(invite.gameDateTime, equals(testGameDateTime));
        expect(invite.venueName, equals('Test Venue'));
      });

      test('fromJson handles missing optional fields', () {
        final json = {
          'inviteId': 'inv_test',
          'watchPartyId': 'wp_test',
          'watchPartyName': 'Test Party',
          'inviterId': 'inviter_1',
          'inviterName': 'Inviter',
          'inviteeId': 'invitee_1',
          'status': 'pending',
          'createdAt': '2024-10-15T12:00:00.000',
          'expiresAt': '2024-10-22T12:00:00.000',
        };

        final invite = WatchPartyInvite.fromJson(json);

        expect(invite.message, isNull);
        expect(invite.gameName, isNull);
        expect(invite.gameDateTime, isNull);
        expect(invite.venueName, isNull);
        expect(invite.inviterImageUrl, isNull);
      });

      test('fromJson handles unknown status with default', () {
        final json = {
          'inviteId': 'inv_test',
          'watchPartyId': 'wp_test',
          'watchPartyName': 'Test Party',
          'inviterId': 'inviter_1',
          'inviterName': 'Inviter',
          'inviteeId': 'invitee_1',
          'status': 'unknownStatus',
          'createdAt': '2024-10-15T12:00:00.000',
          'expiresAt': '2024-10-22T12:00:00.000',
        };

        final invite = WatchPartyInvite.fromJson(json);
        expect(invite.status, equals(WatchPartyInviteStatus.pending));
      });

      test('roundtrip serialization preserves data', () {
        final original = createTestInvite(
          message: 'Join us!',
          gameName: 'Big Game',
          gameDateTime: testGameDateTime,
          venueName: 'Sports Bar',
        );
        final json = original.toJson();
        final restored = WatchPartyInvite.fromJson(json);

        expect(restored.inviteId, equals(original.inviteId));
        expect(restored.watchPartyId, equals(original.watchPartyId));
        expect(restored.status, equals(original.status));
        expect(restored.message, equals(original.message));
        expect(restored.gameName, equals(original.gameName));
        expect(restored.gameDateTime, equals(original.gameDateTime));
        expect(restored.venueName, equals(original.venueName));
      });
    });

    group('Firestore serialization', () {
      test('fromFirestore deserializes with string dates', () {
        final data = {
          'watchPartyId': 'wp_fs',
          'watchPartyName': 'Party',
          'inviterId': 'host',
          'inviterName': 'Host Name',
          'inviteeId': 'guest',
          'status': 'pending',
          'createdAt': '2024-10-15T12:00:00.000',
          'expiresAt': '2024-10-22T12:00:00.000',
        };

        final invite = WatchPartyInvite.fromFirestore(data, 'inv_fs_1');

        expect(invite.inviteId, equals('inv_fs_1'));
        expect(invite.watchPartyId, equals('wp_fs'));
        expect(invite.status, equals(WatchPartyInviteStatus.pending));
      });

      test('fromFirestore handles missing optional fields with defaults', () {
        final data = {
          'watchPartyId': 'wp_fs',
          'inviterId': 'host',
          'inviteeId': 'guest',
          'status': 'pending',
        };

        final invite = WatchPartyInvite.fromFirestore(data, 'inv_min');

        expect(invite.watchPartyName, equals('Watch Party'));
        expect(invite.inviterName, equals('User'));
        expect(invite.message, isNull);
      });
    });

    group('Equatable', () {
      test('two invites with same props are equal', () {
        final inv1 = createTestInvite();
        final inv2 = createTestInvite();

        expect(inv1, equals(inv2));
      });

      test('two invites with different props are not equal', () {
        final inv1 = createTestInvite(inviteId: 'inv_1');
        final inv2 = createTestInvite(inviteId: 'inv_2');

        expect(inv1, isNot(equals(inv2)));
      });

      test('props contains all fields', () {
        final invite = createTestInvite();
        expect(invite.props, hasLength(14));
      });
    });
  });
}
