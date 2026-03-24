import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party_member.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party_message.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party_invite.dart';
import 'package:pregame_world_cup/features/watch_party/presentation/bloc/watch_party_bloc.dart';

import '../../mock_factories.dart';

void main() {
  group('WatchPartyState', () {
    test('WatchPartyState is abstract and Equatable', () {
      final state = WatchPartyInitial();
      expect(state, isA<WatchPartyState>());
      expect(state.props, isEmpty);
    });
  });

  group('WatchPartyInitial', () {
    test('creates initial state', () {
      final state = WatchPartyInitial();
      expect(state, isA<WatchPartyState>());
      expect(state.props, isEmpty);
    });

    test('two initial states are equal', () {
      final state1 = WatchPartyInitial();
      final state2 = WatchPartyInitial();
      expect(state1, equals(state2));
    });
  });

  group('WatchPartyLoading', () {
    test('creates loading state', () {
      final state = WatchPartyLoading();
      expect(state, isA<WatchPartyState>());
      expect(state.props, isEmpty);
    });

    test('two loading states are equal', () {
      final state1 = WatchPartyLoading();
      final state2 = WatchPartyLoading();
      expect(state1, equals(state2));
    });
  });

  group('PublicWatchPartiesLoaded', () {
    final watchParty1 = WatchPartyTestFactory.createWatchParty(
      watchPartyId: 'wp1',
      name: 'USA vs Mexico',
      status: WatchPartyStatus.upcoming,
    );
    final watchParty2 = WatchPartyTestFactory.createWatchParty(
      watchPartyId: 'wp2',
      name: 'Brazil vs Argentina',
      status: WatchPartyStatus.live,
    );

    test('creates loaded state with watch parties', () {
      final state = PublicWatchPartiesLoaded(
        watchParties: [watchParty1, watchParty2],
      );

      expect(state.watchParties, hasLength(2));
      expect(state.gameId, isNull);
      expect(state.venueId, isNull);
    });

    test('creates loaded state with filters', () {
      final state = PublicWatchPartiesLoaded(
        watchParties: [watchParty1],
        gameId: 'game_123',
        venueId: 'venue_456',
      );

      expect(state.watchParties, hasLength(1));
      expect(state.gameId, equals('game_123'));
      expect(state.venueId, equals('venue_456'));
    });

    test('upcomingParties filters correctly', () {
      final upcoming = WatchPartyTestFactory.createWatchParty(
        watchPartyId: 'wp_upcoming',
        status: WatchPartyStatus.upcoming,
        gameDateTime: DateTime.now().add(const Duration(hours: 2)),
      );
      final live = WatchPartyTestFactory.createWatchParty(
        watchPartyId: 'wp_live',
        status: WatchPartyStatus.live,
      );
      final ended = WatchPartyTestFactory.createWatchParty(
        watchPartyId: 'wp_ended',
        status: WatchPartyStatus.ended,
      );

      final state = PublicWatchPartiesLoaded(
        watchParties: [upcoming, live, ended],
      );

      expect(state.upcomingParties, hasLength(1));
      expect(state.upcomingParties.first.watchPartyId, equals('wp_upcoming'));
    });

    test('liveParties filters correctly', () {
      final upcoming = WatchPartyTestFactory.createWatchParty(
        watchPartyId: 'wp_upcoming',
        status: WatchPartyStatus.upcoming,
      );
      final live = WatchPartyTestFactory.createWatchParty(
        watchPartyId: 'wp_live',
        status: WatchPartyStatus.live,
      );

      final state = PublicWatchPartiesLoaded(
        watchParties: [upcoming, live],
      );

      expect(state.liveParties, hasLength(1));
      expect(state.liveParties.first.watchPartyId, equals('wp_live'));
    });

    test('props contains expected fields', () {
      final state = PublicWatchPartiesLoaded(
        watchParties: [watchParty1],
        gameId: 'game_123',
        venueId: 'venue_456',
      );

      expect(state.props, hasLength(3));
      expect(state.props, contains(state.watchParties));
      expect(state.props, contains(state.gameId));
      expect(state.props, contains(state.venueId));
    });

    test('two states with same props are equal', () {
      final state1 = PublicWatchPartiesLoaded(
        watchParties: [watchParty1],
        gameId: 'game_123',
      );
      final state2 = PublicWatchPartiesLoaded(
        watchParties: [watchParty1],
        gameId: 'game_123',
      );

      expect(state1, equals(state2));
    });
  });

  group('UserWatchPartiesLoaded', () {
    final hostedParty = WatchPartyTestFactory.createWatchParty(
      watchPartyId: 'hosted_1',
      name: 'My Watch Party',
    );
    final attendingParty = WatchPartyTestFactory.createWatchParty(
      watchPartyId: 'attending_1',
      name: 'Friend\'s Party',
    );
    final pastParty = WatchPartyTestFactory.createWatchParty(
      watchPartyId: 'past_1',
      status: WatchPartyStatus.ended,
    );

    test('creates user watch parties state', () {
      final state = UserWatchPartiesLoaded(
        hostedParties: [hostedParty],
        attendingParties: [attendingParty],
        pastParties: [pastParty],
      );

      expect(state.hostedParties, hasLength(1));
      expect(state.attendingParties, hasLength(1));
      expect(state.pastParties, hasLength(1));
    });

    test('allActiveParties filters out ended and cancelled parties', () {
      final activeHosted = WatchPartyTestFactory.createWatchParty(
        watchPartyId: 'active_hosted',
        status: WatchPartyStatus.upcoming,
      );
      final endedHosted = WatchPartyTestFactory.createWatchParty(
        watchPartyId: 'ended_hosted',
        status: WatchPartyStatus.ended,
      );
      final cancelledAttending = WatchPartyTestFactory.createWatchParty(
        watchPartyId: 'cancelled_attending',
        status: WatchPartyStatus.cancelled,
      );
      final activeAttending = WatchPartyTestFactory.createWatchParty(
        watchPartyId: 'active_attending',
        status: WatchPartyStatus.live,
      );

      final state = UserWatchPartiesLoaded(
        hostedParties: [activeHosted, endedHosted],
        attendingParties: [activeAttending, cancelledAttending],
        pastParties: [],
      );

      expect(state.allActiveParties, hasLength(2));
      expect(
        state.allActiveParties.map((p) => p.watchPartyId),
        containsAll(['active_hosted', 'active_attending']),
      );
    });

    test('props contains expected fields', () {
      final state = UserWatchPartiesLoaded(
        hostedParties: [hostedParty],
        attendingParties: [attendingParty],
        pastParties: [pastParty],
      );

      expect(state.props, hasLength(3));
      expect(state.props, contains(state.hostedParties));
      expect(state.props, contains(state.attendingParties));
      expect(state.props, contains(state.pastParties));
    });
  });

  group('WatchPartyDetailLoaded', () {
    final watchParty = WatchPartyTestFactory.createWatchParty(
      watchPartyId: 'wp_detail',
      allowVirtualAttendance: true,
      virtualAttendanceFee: 5.99,
    );
    final host = WatchPartyTestFactory.createMember(
      memberId: 'host_1',
      userId: 'user_host',
      role: WatchPartyMemberRole.host,
      attendanceType: WatchPartyAttendanceType.inPerson,
      rsvpStatus: MemberRsvpStatus.going,
    );
    final coHost = WatchPartyTestFactory.createMember(
      memberId: 'cohost_1',
      userId: 'user_cohost',
      role: WatchPartyMemberRole.coHost,
      attendanceType: WatchPartyAttendanceType.inPerson,
      rsvpStatus: MemberRsvpStatus.going,
    );
    final virtualPaidMember = WatchPartyTestFactory.createMember(
      memberId: 'virtual_1',
      userId: 'user_virtual',
      role: WatchPartyMemberRole.member,
      attendanceType: WatchPartyAttendanceType.virtual,
      rsvpStatus: MemberRsvpStatus.going,
      hasPaid: true,
    );
    final maybeMember = WatchPartyTestFactory.createMember(
      memberId: 'maybe_1',
      userId: 'user_maybe',
      rsvpStatus: MemberRsvpStatus.maybe,
    );

    test('creates detail state with all data', () {
      final state = WatchPartyDetailLoaded(
        watchParty: watchParty,
        members: [host, coHost, virtualPaidMember],
        messages: const [],
        currentUserMember: host,
        isHost: true,
        isCoHost: false,
        isMember: false,
      );

      expect(state.watchParty.watchPartyId, equals('wp_detail'));
      expect(state.members, hasLength(3));
      expect(state.messages, isEmpty);
      expect(state.isHost, isTrue);
      expect(state.isCoHost, isFalse);
    });

    test('copyWithMessages creates new state with updated messages', () {
      final original = WatchPartyDetailLoaded(
        watchParty: watchParty,
        members: [host],
        messages: const [],
        isHost: true,
      );

      final message = WatchPartyMessage.text(
        watchPartyId: 'wp_detail',
        senderId: 'user_host',
        senderName: 'Host',
        senderRole: WatchPartyMemberRole.host,
        content: 'Hello!',
      );

      final updated = original.copyWithMessages([message]);

      expect(updated.messages, hasLength(1));
      expect(updated.watchParty, equals(original.watchParty));
      expect(updated.members, equals(original.members));
      expect(updated.isHost, equals(original.isHost));
    });

    test('copyWithMembers creates new state with updated members', () {
      final original = WatchPartyDetailLoaded(
        watchParty: watchParty,
        members: [host],
        messages: const [],
        isHost: true,
      );

      final updated = original.copyWithMembers([host, coHost]);

      expect(updated.members, hasLength(2));
      expect(updated.watchParty, equals(original.watchParty));
      expect(updated.messages, equals(original.messages));
    });

    test('canChat returns true for members who can chat', () {
      final hostState = WatchPartyDetailLoaded(
        watchParty: watchParty,
        members: [host],
        currentUserMember: host,
        isHost: true,
      );

      expect(hostState.canChat, isTrue);

      final virtualPaidState = WatchPartyDetailLoaded(
        watchParty: watchParty,
        members: [virtualPaidMember],
        currentUserMember: virtualPaidMember,
      );

      expect(virtualPaidState.canChat, isTrue);
    });

    test('canChat returns false for virtual unpaid members', () {
      final virtualUnpaid = WatchPartyTestFactory.createMember(
        attendanceType: WatchPartyAttendanceType.virtual,
        hasPaid: false,
      );

      final state = WatchPartyDetailLoaded(
        watchParty: watchParty,
        members: [virtualUnpaid],
        currentUserMember: virtualUnpaid,
      );

      expect(state.canChat, isFalse);
    });

    test('canManageMembers returns true for host and coHost', () {
      final hostState = WatchPartyDetailLoaded(
        watchParty: watchParty,
        members: [host],
        isHost: true,
      );
      expect(hostState.canManageMembers, isTrue);

      final coHostState = WatchPartyDetailLoaded(
        watchParty: watchParty,
        members: [coHost],
        isCoHost: true,
      );
      expect(coHostState.canManageMembers, isTrue);

      final memberState = WatchPartyDetailLoaded(
        watchParty: watchParty,
        members: [virtualPaidMember],
      );
      expect(memberState.canManageMembers, isFalse);
    });

    test('inPersonCount counts correctly', () {
      final state = WatchPartyDetailLoaded(
        watchParty: watchParty,
        members: [host, coHost, virtualPaidMember],
      );

      expect(state.inPersonCount, equals(2));
    });

    test('virtualCount counts correctly', () {
      final state = WatchPartyDetailLoaded(
        watchParty: watchParty,
        members: [host, coHost, virtualPaidMember],
      );

      expect(state.virtualCount, equals(1));
    });

    test('goingMembers filters correctly', () {
      final state = WatchPartyDetailLoaded(
        watchParty: watchParty,
        members: [host, virtualPaidMember, maybeMember],
      );

      expect(state.goingMembers, hasLength(2));
      expect(
        state.goingMembers.map((m) => m.memberId),
        containsAll(['host_1', 'virtual_1']),
      );
    });

    test('maybeMembers filters correctly', () {
      final state = WatchPartyDetailLoaded(
        watchParty: watchParty,
        members: [host, maybeMember],
      );

      expect(state.maybeMembers, hasLength(1));
      expect(state.maybeMembers.first.memberId, equals('maybe_1'));
    });

    test('props contains all fields', () {
      final state = WatchPartyDetailLoaded(
        watchParty: watchParty,
        members: [host],
        currentUserMember: host,
        isHost: true,
        isCoHost: false,
        isMember: false,
      );

      expect(state.props, hasLength(7));
    });
  });

  group('WatchPartyCreated', () {
    test('creates success state with watch party', () {
      final now = DateTime.now();
      final watchParty = WatchParty(
        watchPartyId: 'wp_new',
        name: 'New Party',
        description: 'Test',
        hostId: 'host_1',
        hostName: 'Host',
        visibility: WatchPartyVisibility.public,
        gameId: 'game_1',
        gameName: 'Game',
        gameDateTime: now.add(const Duration(hours: 2)),
        venueId: 'venue_1',
        venueName: 'Venue',
        maxAttendees: 20,
        currentAttendeesCount: 1,
        virtualAttendeesCount: 0,
        allowVirtualAttendance: false,
        virtualAttendanceFee: 0,
        status: WatchPartyStatus.upcoming,
        createdAt: now,
        updatedAt: now,
      );
      final state = WatchPartyCreated(watchParty);

      expect(state.watchParty.watchPartyId, equals('wp_new'));
      expect(state.props, hasLength(1));
    });
  });

  group('WatchPartyUpdated', () {
    test('creates updated state', () {
      final watchParty = WatchPartyTestFactory.createWatchParty();
      final state = WatchPartyUpdated(watchParty);

      expect(state.watchParty, equals(watchParty));
      expect(state.props, contains(watchParty));
    });
  });

  group('WatchPartyJoined', () {
    test('creates joined state', () {
      const state = WatchPartyJoined(
        watchPartyId: 'wp_123',
        attendanceType: WatchPartyAttendanceType.inPerson,
      );

      expect(state.watchPartyId, equals('wp_123'));
      expect(state.attendanceType, equals(WatchPartyAttendanceType.inPerson));
      expect(state.props, hasLength(2));
    });

    test('two states with same props are equal', () {
      const state1 = WatchPartyJoined(
        watchPartyId: 'wp_123',
        attendanceType: WatchPartyAttendanceType.virtual,
      );
      const state2 = WatchPartyJoined(
        watchPartyId: 'wp_123',
        attendanceType: WatchPartyAttendanceType.virtual,
      );

      expect(state1, equals(state2));
    });
  });

  group('WatchPartyLeft', () {
    test('creates left state', () {
      const state = WatchPartyLeft('wp_123');

      expect(state.watchPartyId, equals('wp_123'));
      expect(state.props, contains('wp_123'));
    });
  });

  group('WatchPartyCancelled', () {
    test('creates cancelled state', () {
      const state = WatchPartyCancelled('wp_123');

      expect(state.watchPartyId, equals('wp_123'));
      expect(state.props, contains('wp_123'));
    });
  });

  group('MessageSent', () {
    test('creates message sent state', () {
      final message = WatchPartyMessage.text(
        watchPartyId: 'wp_123',
        senderId: 'user_1',
        senderName: 'User',
        senderRole: WatchPartyMemberRole.member,
        content: 'Hello!',
      );
      final state = MessageSent(message);

      expect(state.message, equals(message));
      expect(state.props, contains(message));
    });
  });

  group('InviteSent', () {
    test('creates invite sent state', () {
      const state = InviteSent('invitee_123');

      expect(state.inviteeId, equals('invitee_123'));
      expect(state.props, contains('invitee_123'));
    });
  });

  group('InviteResponded', () {
    test('creates accepted invite state', () {
      const state = InviteResponded(
        inviteId: 'invite_123',
        accepted: true,
        watchPartyId: 'wp_123',
      );

      expect(state.inviteId, equals('invite_123'));
      expect(state.accepted, isTrue);
      expect(state.watchPartyId, equals('wp_123'));
      expect(state.props, hasLength(3));
    });

    test('creates declined invite state', () {
      const state = InviteResponded(
        inviteId: 'invite_123',
        accepted: false,
      );

      expect(state.accepted, isFalse);
      expect(state.watchPartyId, isNull);
    });
  });

  group('PendingInvitesLoaded', () {
    test('creates loaded state with invites', () {
      final invite = WatchPartyInvite.create(
        watchPartyId: 'wp_123',
        watchPartyName: 'Party Name',
        inviterId: 'inviter_1',
        inviterName: 'Inviter',
        inviteeId: 'invitee_1',
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      final state = PendingInvitesLoaded([invite]);

      expect(state.invites, hasLength(1));
      expect(state.props, contains(state.invites));
    });

    test('validInvites filters correctly', () {
      final validInvite = WatchPartyInvite.create(
        watchPartyId: 'wp_valid',
        watchPartyName: 'Valid Party',
        inviterId: 'inviter_1',
        inviterName: 'Inviter',
        inviteeId: 'invitee_1',
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      final expiredInvite = WatchPartyInvite(
        inviteId: 'invite_expired',
        watchPartyId: 'wp_expired',
        watchPartyName: 'Expired Party',
        inviterId: 'inviter_1',
        inviterName: 'Inviter',
        inviteeId: 'invitee_1',
        status: WatchPartyInviteStatus.expired,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        expiresAt: DateTime.now().subtract(const Duration(days: 3)),
      );

      final state = PendingInvitesLoaded([validInvite, expiredInvite]);

      expect(state.invites, hasLength(2));
      expect(state.validInvites, hasLength(1));
      expect(state.validInvites.first.inviteId, equals(validInvite.inviteId));
    });
  });

  group('VirtualAttendancePurchased', () {
    test('creates purchased state', () {
      const state = VirtualAttendancePurchased('wp_123');

      expect(state.watchPartyId, equals('wp_123'));
      expect(state.props, contains('wp_123'));
    });
  });

  group('MemberActionCompleted', () {
    test('creates action completed state', () {
      const state = MemberActionCompleted(
        action: 'mute',
        memberId: 'member_123',
      );

      expect(state.action, equals('mute'));
      expect(state.memberId, equals('member_123'));
      expect(state.props, hasLength(2));
    });

    test('supports different actions', () {
      const muteState = MemberActionCompleted(action: 'mute', memberId: 'm1');
      const removeState = MemberActionCompleted(action: 'remove', memberId: 'm2');
      const promoteState = MemberActionCompleted(action: 'promote', memberId: 'm3');
      const demoteState = MemberActionCompleted(action: 'demote', memberId: 'm4');

      expect(muteState.action, equals('mute'));
      expect(removeState.action, equals('remove'));
      expect(promoteState.action, equals('promote'));
      expect(demoteState.action, equals('demote'));
    });
  });

  group('WatchPartyStatusChanged', () {
    test('creates status changed state', () {
      const state = WatchPartyStatusChanged(
        watchPartyId: 'wp_123',
        newStatus: WatchPartyStatus.live,
      );

      expect(state.watchPartyId, equals('wp_123'));
      expect(state.newStatus, equals(WatchPartyStatus.live));
      expect(state.props, hasLength(2));
    });

    test('supports all status types', () {
      const upcoming = WatchPartyStatusChanged(
        watchPartyId: 'wp_1',
        newStatus: WatchPartyStatus.upcoming,
      );
      const live = WatchPartyStatusChanged(
        watchPartyId: 'wp_2',
        newStatus: WatchPartyStatus.live,
      );
      const ended = WatchPartyStatusChanged(
        watchPartyId: 'wp_3',
        newStatus: WatchPartyStatus.ended,
      );
      const cancelled = WatchPartyStatusChanged(
        watchPartyId: 'wp_4',
        newStatus: WatchPartyStatus.cancelled,
      );

      expect(upcoming.newStatus, equals(WatchPartyStatus.upcoming));
      expect(live.newStatus, equals(WatchPartyStatus.live));
      expect(ended.newStatus, equals(WatchPartyStatus.ended));
      expect(cancelled.newStatus, equals(WatchPartyStatus.cancelled));
    });
  });

  group('WatchPartyError', () {
    test('creates error state with message', () {
      const state = WatchPartyError('An error occurred');

      expect(state.message, equals('An error occurred'));
      expect(state.code, isNull);
      expect(state.props, hasLength(2));
    });

    test('creates error state with code', () {
      const state = WatchPartyError('Permission denied', code: 'PERMISSION_DENIED');

      expect(state.message, equals('Permission denied'));
      expect(state.code, equals('PERMISSION_DENIED'));
    });

    test('two errors with same message and code are equal', () {
      const state1 = WatchPartyError('Error', code: 'CODE');
      const state2 = WatchPartyError('Error', code: 'CODE');

      expect(state1, equals(state2));
    });
  });

  group('WatchPartyOperationInProgress', () {
    test('creates operation state', () {
      const state = WatchPartyOperationInProgress(
        operation: 'joining',
      );

      expect(state.operation, equals('joining'));
      expect(state.previousState, isNull);
      expect(state.props, hasLength(2));
    });

    test('creates operation state with previous state', () {
      final previous = WatchPartyInitial();
      final state = WatchPartyOperationInProgress(
        operation: 'loading',
        previousState: previous,
      );

      expect(state.operation, equals('loading'));
      expect(state.previousState, equals(previous));
    });

    test('supports different operations', () {
      const joining = WatchPartyOperationInProgress(operation: 'joining');
      const leaving = WatchPartyOperationInProgress(operation: 'leaving');
      const creating = WatchPartyOperationInProgress(operation: 'creating');
      const updating = WatchPartyOperationInProgress(operation: 'updating');

      expect(joining.operation, equals('joining'));
      expect(leaving.operation, equals('leaving'));
      expect(creating.operation, equals('creating'));
      expect(updating.operation, equals('updating'));
    });
  });
}
