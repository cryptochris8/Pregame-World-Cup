import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party_member.dart';

void main() {
  group('WatchPartyMemberRole', () {
    test('has expected values', () {
      expect(WatchPartyMemberRole.values, hasLength(3));
      expect(WatchPartyMemberRole.values, contains(WatchPartyMemberRole.host));
      expect(WatchPartyMemberRole.values, contains(WatchPartyMemberRole.coHost));
      expect(WatchPartyMemberRole.values, contains(WatchPartyMemberRole.member));
    });
  });

  group('WatchPartyAttendanceType', () {
    test('has expected values', () {
      expect(WatchPartyAttendanceType.values, hasLength(2));
      expect(WatchPartyAttendanceType.values, contains(WatchPartyAttendanceType.inPerson));
      expect(WatchPartyAttendanceType.values, contains(WatchPartyAttendanceType.virtual));
    });
  });

  group('MemberRsvpStatus', () {
    test('has expected values', () {
      expect(MemberRsvpStatus.values, hasLength(3));
      expect(MemberRsvpStatus.values, contains(MemberRsvpStatus.going));
      expect(MemberRsvpStatus.values, contains(MemberRsvpStatus.maybe));
      expect(MemberRsvpStatus.values, contains(MemberRsvpStatus.notGoing));
    });
  });

  group('WatchPartyMember', () {
    final now = DateTime(2024, 10, 15, 12, 0, 0);

    WatchPartyMember createTestMember({
      String memberId = 'member_1',
      String watchPartyId = 'wp_123',
      String userId = 'user_1',
      String displayName = 'John Doe',
      String? profileImageUrl,
      WatchPartyMemberRole role = WatchPartyMemberRole.member,
      WatchPartyAttendanceType attendanceType = WatchPartyAttendanceType.inPerson,
      MemberRsvpStatus rsvpStatus = MemberRsvpStatus.going,
      DateTime? joinedAt,
      String? paymentIntentId,
      bool hasPaid = false,
      DateTime? checkedInAt,
      bool isMuted = false,
    }) {
      return WatchPartyMember(
        memberId: memberId,
        watchPartyId: watchPartyId,
        userId: userId,
        displayName: displayName,
        profileImageUrl: profileImageUrl,
        role: role,
        attendanceType: attendanceType,
        rsvpStatus: rsvpStatus,
        joinedAt: joinedAt ?? now,
        paymentIntentId: paymentIntentId,
        hasPaid: hasPaid,
        checkedInAt: checkedInAt,
        isMuted: isMuted,
      );
    }

    group('Constructor', () {
      test('creates member with required fields', () {
        final member = createTestMember();

        expect(member.memberId, equals('member_1'));
        expect(member.watchPartyId, equals('wp_123'));
        expect(member.userId, equals('user_1'));
        expect(member.displayName, equals('John Doe'));
        expect(member.role, equals(WatchPartyMemberRole.member));
        expect(member.attendanceType, equals(WatchPartyAttendanceType.inPerson));
        expect(member.rsvpStatus, equals(MemberRsvpStatus.going));
      });

      test('creates member with optional fields', () {
        final member = createTestMember(
          profileImageUrl: 'https://example.com/avatar.jpg',
          paymentIntentId: 'pi_123',
          hasPaid: true,
          checkedInAt: now,
          isMuted: true,
        );

        expect(member.profileImageUrl, equals('https://example.com/avatar.jpg'));
        expect(member.paymentIntentId, equals('pi_123'));
        expect(member.hasPaid, isTrue);
        expect(member.checkedInAt, equals(now));
        expect(member.isMuted, isTrue);
      });
    });

    group('Role computed getters', () {
      test('isHost returns true for host role', () {
        final host = createTestMember(role: WatchPartyMemberRole.host);
        final coHost = createTestMember(role: WatchPartyMemberRole.coHost);
        final member = createTestMember(role: WatchPartyMemberRole.member);

        expect(host.isHost, isTrue);
        expect(host.isCoHost, isFalse);
        expect(host.isMember, isFalse);
        expect(coHost.isCoHost, isTrue);
        expect(member.isMember, isTrue);
      });

      test('canManageMembers returns true for host and coHost', () {
        final host = createTestMember(role: WatchPartyMemberRole.host);
        final coHost = createTestMember(role: WatchPartyMemberRole.coHost);
        final member = createTestMember(role: WatchPartyMemberRole.member);

        expect(host.canManageMembers, isTrue);
        expect(coHost.canManageMembers, isTrue);
        expect(member.canManageMembers, isFalse);
      });

      test('roleDisplayName returns correct strings', () {
        final host = createTestMember(role: WatchPartyMemberRole.host);
        final coHost = createTestMember(role: WatchPartyMemberRole.coHost);
        final member = createTestMember(role: WatchPartyMemberRole.member);

        expect(host.roleDisplayName, equals('Host'));
        expect(coHost.roleDisplayName, equals('Co-Host'));
        expect(member.roleDisplayName, equals('Member'));
      });
    });

    group('Attendance computed getters', () {
      test('isVirtual and isInPerson work correctly', () {
        final virtual = createTestMember(
          attendanceType: WatchPartyAttendanceType.virtual,
        );
        final inPerson = createTestMember(
          attendanceType: WatchPartyAttendanceType.inPerson,
        );

        expect(virtual.isVirtual, isTrue);
        expect(virtual.isInPerson, isFalse);
        expect(inPerson.isVirtual, isFalse);
        expect(inPerson.isInPerson, isTrue);
      });

      test('attendanceTypeDisplayName returns correct strings', () {
        final virtual = createTestMember(
          attendanceType: WatchPartyAttendanceType.virtual,
        );
        final inPerson = createTestMember(
          attendanceType: WatchPartyAttendanceType.inPerson,
        );

        expect(virtual.attendanceTypeDisplayName, equals('Virtual'));
        expect(inPerson.attendanceTypeDisplayName, equals('In Person'));
      });
    });

    group('RSVP computed getters', () {
      test('isGoing, isMaybe, isNotGoing work correctly', () {
        final going = createTestMember(rsvpStatus: MemberRsvpStatus.going);
        final maybe = createTestMember(rsvpStatus: MemberRsvpStatus.maybe);
        final notGoing = createTestMember(rsvpStatus: MemberRsvpStatus.notGoing);

        expect(going.isGoing, isTrue);
        expect(going.isMaybe, isFalse);
        expect(maybe.isMaybe, isTrue);
        expect(notGoing.isNotGoing, isTrue);
      });
    });

    group('canChat', () {
      test('returns false when muted', () {
        final muted = createTestMember(isMuted: true);
        expect(muted.canChat, isFalse);
      });

      test('returns false for virtual unpaid member', () {
        final virtualUnpaid = createTestMember(
          attendanceType: WatchPartyAttendanceType.virtual,
          hasPaid: false,
        );
        expect(virtualUnpaid.canChat, isFalse);
      });

      test('returns true for virtual paid member', () {
        final virtualPaid = createTestMember(
          attendanceType: WatchPartyAttendanceType.virtual,
          hasPaid: true,
        );
        expect(virtualPaid.canChat, isTrue);
      });

      test('returns true for in-person member', () {
        final inPerson = createTestMember(
          attendanceType: WatchPartyAttendanceType.inPerson,
        );
        expect(inPerson.canChat, isTrue);
      });
    });

    group('hasCheckedIn', () {
      test('returns true when checkedInAt is set', () {
        final checkedIn = createTestMember(checkedInAt: now);
        final notCheckedIn = createTestMember(checkedInAt: null);

        expect(checkedIn.hasCheckedIn, isTrue);
        expect(notCheckedIn.hasCheckedIn, isFalse);
      });
    });

    group('Specialized methods', () {
      test('checkIn sets checkedInAt', () {
        final member = createTestMember(checkedInAt: null);
        final checkedIn = member.checkIn();

        expect(checkedIn.hasCheckedIn, isTrue);
        expect(checkedIn.checkedInAt, isNotNull);
      });

      test('mute sets isMuted to true', () {
        final member = createTestMember(isMuted: false);
        final muted = member.mute();

        expect(muted.isMuted, isTrue);
      });

      test('unmute sets isMuted to false', () {
        final member = createTestMember(isMuted: true);
        final unmuted = member.unmute();

        expect(unmuted.isMuted, isFalse);
      });

      test('markAsPaid updates payment status', () {
        final member = createTestMember(hasPaid: false);
        final paid = member.markAsPaid('pi_test_123');

        expect(paid.hasPaid, isTrue);
        expect(paid.paymentIntentId, equals('pi_test_123'));
      });

      test('promoteToCoHost changes role', () {
        final member = createTestMember(role: WatchPartyMemberRole.member);
        final promoted = member.promoteToCoHost();

        expect(promoted.role, equals(WatchPartyMemberRole.coHost));
      });

      test('demoteToMember changes role', () {
        final coHost = createTestMember(role: WatchPartyMemberRole.coHost);
        final demoted = coHost.demoteToMember();

        expect(demoted.role, equals(WatchPartyMemberRole.member));
      });
    });

    group('copyWith', () {
      test('copies with updated fields', () {
        final original = createTestMember();
        final updated = original.copyWith(
          displayName: 'Jane Doe',
          role: WatchPartyMemberRole.coHost,
          hasPaid: true,
        );

        expect(updated.displayName, equals('Jane Doe'));
        expect(updated.role, equals(WatchPartyMemberRole.coHost));
        expect(updated.hasPaid, isTrue);
        expect(updated.memberId, equals(original.memberId));
      });

      test('preserves unchanged fields', () {
        final original = createTestMember(
          profileImageUrl: 'https://example.com/img.jpg',
          paymentIntentId: 'pi_123',
        );
        final updated = original.copyWith(displayName: 'New Name');

        expect(updated.profileImageUrl, equals('https://example.com/img.jpg'));
        expect(updated.paymentIntentId, equals('pi_123'));
      });
    });

    group('Factory create', () {
      test('creates member with generated ID', () {
        final member = WatchPartyMember.create(
          watchPartyId: 'wp_test',
          userId: 'user_test',
          displayName: 'Test User',
          role: WatchPartyMemberRole.member,
          attendanceType: WatchPartyAttendanceType.inPerson,
        );

        expect(member.memberId, equals('wp_test_user_test'));
        expect(member.rsvpStatus, equals(MemberRsvpStatus.going));
      });

      test('sets hasPaid true for in-person attendance', () {
        final inPerson = WatchPartyMember.create(
          watchPartyId: 'wp_test',
          userId: 'user_test',
          displayName: 'Test User',
          role: WatchPartyMemberRole.member,
          attendanceType: WatchPartyAttendanceType.inPerson,
        );

        expect(inPerson.hasPaid, isTrue);
      });

      test('sets hasPaid false for virtual attendance', () {
        final virtual = WatchPartyMember.create(
          watchPartyId: 'wp_test',
          userId: 'user_test',
          displayName: 'Test User',
          role: WatchPartyMemberRole.member,
          attendanceType: WatchPartyAttendanceType.virtual,
        );

        expect(virtual.hasPaid, isFalse);
      });
    });

    group('JSON serialization', () {
      test('toJson serializes all fields', () {
        final member = createTestMember(
          profileImageUrl: 'https://example.com/img.jpg',
          paymentIntentId: 'pi_123',
          hasPaid: true,
        );
        final json = member.toJson();

        expect(json['memberId'], equals('member_1'));
        expect(json['watchPartyId'], equals('wp_123'));
        expect(json['userId'], equals('user_1'));
        expect(json['displayName'], equals('John Doe'));
        expect(json['role'], equals('member'));
        expect(json['attendanceType'], equals('inPerson'));
        expect(json['rsvpStatus'], equals('going'));
        expect(json['hasPaid'], isTrue);
      });

      test('fromJson deserializes correctly', () {
        final json = {
          'memberId': 'member_test',
          'watchPartyId': 'wp_test',
          'userId': 'user_test',
          'displayName': 'Test User',
          'role': 'coHost',
          'attendanceType': 'virtual',
          'rsvpStatus': 'maybe',
          'joinedAt': '2024-10-15T12:00:00.000',
          'hasPaid': true,
          'isMuted': true,
        };

        final member = WatchPartyMember.fromJson(json);

        expect(member.memberId, equals('member_test'));
        expect(member.role, equals(WatchPartyMemberRole.coHost));
        expect(member.attendanceType, equals(WatchPartyAttendanceType.virtual));
        expect(member.rsvpStatus, equals(MemberRsvpStatus.maybe));
        expect(member.hasPaid, isTrue);
        expect(member.isMuted, isTrue);
      });

      test('roundtrip serialization preserves data', () {
        final original = createTestMember(
          role: WatchPartyMemberRole.coHost,
          attendanceType: WatchPartyAttendanceType.virtual,
          hasPaid: true,
          isMuted: true,
        );
        final json = original.toJson();
        final restored = WatchPartyMember.fromJson(json);

        expect(restored.memberId, equals(original.memberId));
        expect(restored.role, equals(original.role));
        expect(restored.attendanceType, equals(original.attendanceType));
        expect(restored.hasPaid, equals(original.hasPaid));
        expect(restored.isMuted, equals(original.isMuted));
      });
    });

    group('Equatable', () {
      test('two members with same props are equal', () {
        final member1 = createTestMember();
        final member2 = createTestMember();

        expect(member1, equals(member2));
      });

      test('two members with different props are not equal', () {
        final member1 = createTestMember(memberId: 'member_1');
        final member2 = createTestMember(memberId: 'member_2');

        expect(member1, isNot(equals(member2)));
      });
    });
  });
}
