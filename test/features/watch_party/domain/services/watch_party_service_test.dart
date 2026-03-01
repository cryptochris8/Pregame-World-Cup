import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party_member.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party_message.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party_invite.dart';

/// Tests for WatchPartyService.
///
/// Note: WatchPartyService itself uses hardcoded Firebase singletons
/// (FirebaseFirestore.instance, FirebaseAuth.instance) and internal
/// singleton sub-services. This makes direct Firestore unit testing
/// impractical without DI refactoring.
///
/// The sub-services (WatchPartyChatService, WatchPartyMemberService,
/// WatchPartyInviteService) all accept injectable Firestore/Auth
/// parameters and are thoroughly tested in their own test files.
///
/// This test file focuses on:
/// 1. Entity data model validation (watch party creation, serialization)
/// 2. Business logic embedded in entities (canJoin, isFull, etc.)
/// 3. WatchParty.create factory logic
/// 4. Firestore serialization roundtrips
/// 5. Data model contracts the service depends on
void main() {
  // ==================== WatchParty.create ====================
  group('WatchParty.create factory', () {
    test('generates unique watch party ID with prefix and host ID', () {
      final party = WatchParty.create(
        hostId: 'host_abc',
        hostName: 'Test Host',
        name: 'My Party',
        description: 'A fun party',
        visibility: WatchPartyVisibility.public,
        gameId: 'game_1',
        gameName: 'USA vs Mexico',
        gameDateTime: DateTime(2026, 6, 15, 18, 0),
        venueId: 'venue_1',
        venueName: 'Sports Bar',
      );

      expect(party.watchPartyId, startsWith('wp_'));
      expect(party.watchPartyId, contains('host_abc'));
    });

    test('sets status to upcoming', () {
      final party = WatchParty.create(
        hostId: 'host_1',
        hostName: 'Host',
        name: 'Party',
        description: 'Desc',
        visibility: WatchPartyVisibility.public,
        gameId: 'g1',
        gameName: 'Game',
        gameDateTime: DateTime.now().add(const Duration(days: 1)),
        venueId: 'v1',
        venueName: 'Venue',
      );

      expect(party.status, equals(WatchPartyStatus.upcoming));
      expect(party.isUpcoming, isTrue);
    });

    test('sets initial attendees count to 1 (host)', () {
      final party = WatchParty.create(
        hostId: 'host_1',
        hostName: 'Host',
        name: 'Party',
        description: 'Desc',
        visibility: WatchPartyVisibility.public,
        gameId: 'g1',
        gameName: 'Game',
        gameDateTime: DateTime.now().add(const Duration(days: 1)),
        venueId: 'v1',
        venueName: 'Venue',
      );

      expect(party.currentAttendeesCount, equals(1));
      expect(party.virtualAttendeesCount, equals(0));
    });

    test('applies default values for optional parameters', () {
      final party = WatchParty.create(
        hostId: 'host_1',
        hostName: 'Host',
        name: 'Party',
        description: 'Desc',
        visibility: WatchPartyVisibility.public,
        gameId: 'g1',
        gameName: 'Game',
        gameDateTime: DateTime.now().add(const Duration(days: 1)),
        venueId: 'v1',
        venueName: 'Venue',
      );

      expect(party.maxAttendees, equals(20));
      expect(party.allowVirtualAttendance, isFalse);
      expect(party.virtualAttendanceFee, equals(0.0));
      expect(party.tags, isEmpty);
      expect(party.settings, isEmpty);
      expect(party.imageUrl, isNull);
      expect(party.hostImageUrl, isNull);
      expect(party.venueAddress, isNull);
    });

    test('accepts custom optional parameters', () {
      final party = WatchParty.create(
        hostId: 'host_1',
        hostName: 'Host',
        hostImageUrl: 'https://example.com/host.jpg',
        name: 'Premium Party',
        description: 'A premium experience',
        visibility: WatchPartyVisibility.private,
        gameId: 'g1',
        gameName: 'Final',
        gameDateTime: DateTime(2026, 7, 19, 15, 0),
        venueId: 'v1',
        venueName: 'MetLife Stadium',
        venueAddress: 'East Rutherford, NJ',
        venueLatitude: 40.8135,
        venueLongitude: -74.0745,
        maxAttendees: 50,
        allowVirtualAttendance: true,
        virtualAttendanceFee: 9.99,
        imageUrl: 'https://example.com/party.jpg',
        tags: ['final', 'premium'],
      );

      expect(party.hostImageUrl, equals('https://example.com/host.jpg'));
      expect(party.visibility, equals(WatchPartyVisibility.private));
      expect(party.maxAttendees, equals(50));
      expect(party.allowVirtualAttendance, isTrue);
      expect(party.virtualAttendanceFee, equals(9.99));
      expect(party.tags, equals(['final', 'premium']));
      expect(party.venueAddress, equals('East Rutherford, NJ'));
      expect(party.venueLatitude, equals(40.8135));
      expect(party.venueLongitude, equals(-74.0745));
    });

    test('two parties created sequentially have different IDs', () async {
      final party1 = WatchParty.create(
        hostId: 'host_1',
        hostName: 'Host',
        name: 'Party 1',
        description: 'Desc',
        visibility: WatchPartyVisibility.public,
        gameId: 'g1',
        gameName: 'Game',
        gameDateTime: DateTime.now().add(const Duration(days: 1)),
        venueId: 'v1',
        venueName: 'Venue',
      );

      // Ensure different milliseconds
      await Future.delayed(const Duration(milliseconds: 2));

      final party2 = WatchParty.create(
        hostId: 'host_1',
        hostName: 'Host',
        name: 'Party 2',
        description: 'Desc',
        visibility: WatchPartyVisibility.public,
        gameId: 'g1',
        gameName: 'Game',
        gameDateTime: DateTime.now().add(const Duration(days: 1)),
        venueId: 'v1',
        venueName: 'Venue',
      );

      expect(party1.watchPartyId, isNot(equals(party2.watchPartyId)));
    });
  });

  // ==================== Firestore roundtrip ====================
  group('Firestore serialization roundtrip', () {
    test('toFirestore and fromFirestore preserve all fields', () {
      final now = DateTime(2026, 3, 1, 12, 0, 0);
      final original = WatchParty(
        watchPartyId: 'wp_roundtrip',
        name: 'Roundtrip Party',
        description: 'Testing roundtrip',
        hostId: 'host_rt',
        hostName: 'RT Host',
        hostImageUrl: 'https://example.com/rt.jpg',
        visibility: WatchPartyVisibility.private,
        gameId: 'game_rt',
        gameName: 'Brazil vs Germany',
        gameDateTime: DateTime(2026, 6, 20, 20, 0),
        venueId: 'venue_rt',
        venueName: 'Maracana',
        venueAddress: 'Rio de Janeiro',
        venueLatitude: -22.9121,
        venueLongitude: -43.2302,
        maxAttendees: 30,
        currentAttendeesCount: 12,
        virtualAttendeesCount: 5,
        allowVirtualAttendance: true,
        virtualAttendanceFee: 4.99,
        status: WatchPartyStatus.live,
        createdAt: now,
        updatedAt: now,
        imageUrl: 'https://example.com/party.jpg',
        tags: ['soccer', 'worldcup'],
        settings: {'theme': 'dark'},
      );

      final firestoreData = original.toFirestore();
      final restored =
          WatchParty.fromFirestore(firestoreData, original.watchPartyId);

      expect(restored.watchPartyId, equals(original.watchPartyId));
      expect(restored.name, equals(original.name));
      expect(restored.description, equals(original.description));
      expect(restored.hostId, equals(original.hostId));
      expect(restored.hostName, equals(original.hostName));
      expect(restored.hostImageUrl, equals(original.hostImageUrl));
      expect(restored.visibility, equals(original.visibility));
      expect(restored.gameId, equals(original.gameId));
      expect(restored.gameName, equals(original.gameName));
      expect(restored.venueId, equals(original.venueId));
      expect(restored.venueName, equals(original.venueName));
      expect(restored.venueAddress, equals(original.venueAddress));
      expect(restored.venueLatitude, equals(original.venueLatitude));
      expect(restored.venueLongitude, equals(original.venueLongitude));
      expect(restored.maxAttendees, equals(original.maxAttendees));
      expect(restored.currentAttendeesCount,
          equals(original.currentAttendeesCount));
      expect(restored.virtualAttendeesCount,
          equals(original.virtualAttendeesCount));
      expect(restored.allowVirtualAttendance,
          equals(original.allowVirtualAttendance));
      expect(restored.virtualAttendanceFee,
          equals(original.virtualAttendanceFee));
      expect(restored.status, equals(original.status));
      expect(restored.imageUrl, equals(original.imageUrl));
      expect(restored.tags, equals(original.tags));
      expect(restored.settings, equals(original.settings));
    });

    test('fromFirestore handles missing optional fields', () {
      final data = {
        'name': 'Minimal Party',
        'hostId': 'host_min',
        'gameId': 'game_min',
        'venueId': 'venue_min',
      };

      final party = WatchParty.fromFirestore(data, 'wp_minimal');

      expect(party.watchPartyId, equals('wp_minimal'));
      expect(party.name, equals('Minimal Party'));
      expect(party.hostName, equals('Host'));
      expect(party.gameName, equals('Game'));
      expect(party.venueName, equals('Venue'));
      expect(party.description, isEmpty);
      expect(party.maxAttendees, equals(20));
      expect(party.currentAttendeesCount, equals(1));
      expect(party.virtualAttendeesCount, equals(0));
      expect(party.allowVirtualAttendance, isFalse);
      expect(party.virtualAttendanceFee, equals(0.0));
      expect(party.status, equals(WatchPartyStatus.upcoming));
      expect(party.tags, isEmpty);
      expect(party.settings, isEmpty);
    });
  });

  // ==================== WatchPartyMember data contracts ====================
  group('WatchPartyMember.create factory', () {
    test('generates member ID from watchPartyId and userId', () {
      final member = WatchPartyMember.create(
        watchPartyId: 'wp_test',
        userId: 'user_1',
        displayName: 'User One',
        role: WatchPartyMemberRole.member,
        attendanceType: WatchPartyAttendanceType.inPerson,
      );

      expect(member.memberId, equals('wp_test_user_1'));
    });

    test('in-person member is marked as paid by default', () {
      final member = WatchPartyMember.create(
        watchPartyId: 'wp_test',
        userId: 'user_1',
        displayName: 'User',
        role: WatchPartyMemberRole.member,
        attendanceType: WatchPartyAttendanceType.inPerson,
      );

      expect(member.hasPaid, isTrue);
    });

    test('virtual member is NOT marked as paid by default', () {
      final member = WatchPartyMember.create(
        watchPartyId: 'wp_test',
        userId: 'user_1',
        displayName: 'User',
        role: WatchPartyMemberRole.member,
        attendanceType: WatchPartyAttendanceType.virtual,
      );

      expect(member.hasPaid, isFalse);
    });

    test('canChat is true for non-muted in-person member', () {
      final member = WatchPartyMember.create(
        watchPartyId: 'wp_test',
        userId: 'user_1',
        displayName: 'User',
        role: WatchPartyMemberRole.member,
        attendanceType: WatchPartyAttendanceType.inPerson,
      );

      expect(member.canChat, isTrue);
    });

    test('canChat is false for muted member', () {
      final member = WatchPartyMember(
        memberId: 'test',
        watchPartyId: 'wp_test',
        userId: 'user_1',
        displayName: 'User',
        role: WatchPartyMemberRole.member,
        attendanceType: WatchPartyAttendanceType.inPerson,
        rsvpStatus: MemberRsvpStatus.going,
        joinedAt: DateTime.now(),
        isMuted: true,
      );

      expect(member.canChat, isFalse);
    });

    test('canChat is false for unpaid virtual member', () {
      final member = WatchPartyMember(
        memberId: 'test',
        watchPartyId: 'wp_test',
        userId: 'user_1',
        displayName: 'User',
        role: WatchPartyMemberRole.member,
        attendanceType: WatchPartyAttendanceType.virtual,
        rsvpStatus: MemberRsvpStatus.going,
        joinedAt: DateTime.now(),
        hasPaid: false,
      );

      expect(member.canChat, isFalse);
    });

    test('canChat is true for paid virtual member', () {
      final member = WatchPartyMember(
        memberId: 'test',
        watchPartyId: 'wp_test',
        userId: 'user_1',
        displayName: 'User',
        role: WatchPartyMemberRole.member,
        attendanceType: WatchPartyAttendanceType.virtual,
        rsvpStatus: MemberRsvpStatus.going,
        joinedAt: DateTime.now(),
        hasPaid: true,
      );

      expect(member.canChat, isTrue);
    });
  });

  // ==================== WatchPartyMember Firestore roundtrip ====================
  group('WatchPartyMember Firestore roundtrip', () {
    test('toFirestore and fromFirestore preserve all fields', () {
      final now = DateTime(2026, 3, 1, 10, 0, 0);
      final original = WatchPartyMember(
        memberId: 'wp_1_user_1',
        watchPartyId: 'wp_1',
        userId: 'user_1',
        displayName: 'Test Member',
        profileImageUrl: 'https://example.com/member.jpg',
        role: WatchPartyMemberRole.coHost,
        attendanceType: WatchPartyAttendanceType.virtual,
        rsvpStatus: MemberRsvpStatus.maybe,
        joinedAt: now,
        paymentIntentId: 'pi_test',
        hasPaid: true,
        checkedInAt: now.add(const Duration(hours: 1)),
        isMuted: false,
      );

      final data = original.toFirestore();
      final restored =
          WatchPartyMember.fromFirestore(data, original.memberId);

      expect(restored.userId, equals(original.userId));
      expect(restored.displayName, equals(original.displayName));
      expect(restored.role, equals(original.role));
      expect(restored.attendanceType, equals(original.attendanceType));
      expect(restored.rsvpStatus, equals(original.rsvpStatus));
      expect(restored.hasPaid, equals(original.hasPaid));
      expect(restored.paymentIntentId, equals(original.paymentIntentId));
      expect(restored.isMuted, equals(original.isMuted));
    });
  });

  // ==================== WatchPartyMessage data contracts ====================
  group('WatchPartyMessage factories', () {
    test('text factory creates text message with correct fields', () {
      final msg = WatchPartyMessage.text(
        watchPartyId: 'wp_1',
        senderId: 'user_1',
        senderName: 'User One',
        senderRole: WatchPartyMemberRole.member,
        content: 'Hello!',
      );

      expect(msg.messageId, startsWith('msg_'));
      expect(msg.type, equals(WatchPartyMessageType.text));
      expect(msg.isText, isTrue);
      expect(msg.content, equals('Hello!'));
      expect(msg.senderId, equals('user_1'));
      expect(msg.isDeleted, isFalse);
    });

    test('text factory includes reply reference', () {
      final msg = WatchPartyMessage.text(
        watchPartyId: 'wp_1',
        senderId: 'user_1',
        senderName: 'User',
        senderRole: WatchPartyMemberRole.member,
        content: 'Reply!',
        replyToMessageId: 'msg_original',
      );

      expect(msg.isReply, isTrue);
      expect(msg.replyToMessageId, equals('msg_original'));
    });

    test('system factory creates system message', () {
      final msg = WatchPartyMessage.system(
        watchPartyId: 'wp_1',
        content: 'User joined',
      );

      expect(msg.messageId, startsWith('sys_'));
      expect(msg.type, equals(WatchPartyMessageType.system));
      expect(msg.isSystem, isTrue);
      expect(msg.senderId, equals('system'));
      expect(msg.senderName, equals('System'));
    });

    test('image factory creates image message', () {
      final msg = WatchPartyMessage.image(
        watchPartyId: 'wp_1',
        senderId: 'user_1',
        senderName: 'User',
        senderRole: WatchPartyMemberRole.member,
        imageUrl: 'https://example.com/img.jpg',
        caption: 'Check this out!',
      );

      expect(msg.type, equals(WatchPartyMessageType.image));
      expect(msg.isImage, isTrue);
      expect(msg.imageUrl, equals('https://example.com/img.jpg'));
      expect(msg.content, equals('Check this out!'));
    });

    test('gif factory creates gif message', () {
      final msg = WatchPartyMessage.gif(
        watchPartyId: 'wp_1',
        senderId: 'user_1',
        senderName: 'User',
        senderRole: WatchPartyMemberRole.member,
        gifUrl: 'https://giphy.com/test.gif',
      );

      expect(msg.type, equals(WatchPartyMessageType.gif));
      expect(msg.isGif, isTrue);
      expect(msg.gifUrl, equals('https://giphy.com/test.gif'));
    });
  });

  // ==================== WatchPartyMessage Firestore roundtrip ====================
  group('WatchPartyMessage Firestore roundtrip', () {
    test('toFirestore and fromFirestore preserve all fields', () {
      final msg = WatchPartyMessage.text(
        watchPartyId: 'wp_1',
        senderId: 'user_1',
        senderName: 'User',
        senderImageUrl: 'https://example.com/user.jpg',
        senderRole: WatchPartyMemberRole.host,
        content: 'Hello World',
        replyToMessageId: 'msg_prev',
      );

      final data = msg.toFirestore();
      final restored = WatchPartyMessage.fromFirestore(data, msg.messageId);

      expect(restored.messageId, equals(msg.messageId));
      expect(restored.watchPartyId, equals(msg.watchPartyId));
      expect(restored.senderId, equals(msg.senderId));
      expect(restored.senderName, equals(msg.senderName));
      expect(restored.senderRole, equals(msg.senderRole));
      expect(restored.content, equals(msg.content));
      expect(restored.type, equals(msg.type));
      expect(restored.isDeleted, equals(msg.isDeleted));
      expect(restored.replyToMessageId, equals(msg.replyToMessageId));
    });
  });

  // ==================== WatchPartyInvite data contracts ====================
  group('WatchPartyInvite.create factory', () {
    test('generates invite ID with inviter and invitee', () {
      final invite = WatchPartyInvite.create(
        watchPartyId: 'wp_1',
        watchPartyName: 'Party',
        inviterId: 'inviter_1',
        inviterName: 'Inviter',
        inviteeId: 'invitee_1',
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      expect(invite.inviteId, startsWith('inv_'));
      expect(invite.inviteId, contains('inviter_1'));
      expect(invite.inviteId, contains('invitee_1'));
    });

    test('sets status to pending', () {
      final invite = WatchPartyInvite.create(
        watchPartyId: 'wp_1',
        watchPartyName: 'Party',
        inviterId: 'inviter_1',
        inviterName: 'Inviter',
        inviteeId: 'invitee_1',
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      expect(invite.status, equals(WatchPartyInviteStatus.pending));
      expect(invite.isPending, isTrue);
    });

    test('isValid returns true for pending non-expired invite', () {
      final invite = WatchPartyInvite.create(
        watchPartyId: 'wp_1',
        watchPartyName: 'Party',
        inviterId: 'inviter_1',
        inviterName: 'Inviter',
        inviteeId: 'invitee_1',
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      expect(invite.isValid, isTrue);
      expect(invite.canRespond, isTrue);
    });

    test('isExpired returns true for past expiration', () {
      final invite = WatchPartyInvite(
        inviteId: 'inv_expired',
        watchPartyId: 'wp_1',
        watchPartyName: 'Party',
        inviterId: 'inviter_1',
        inviterName: 'Inviter',
        inviteeId: 'invitee_1',
        status: WatchPartyInviteStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      expect(invite.isExpired, isTrue);
      expect(invite.isValid, isFalse);
      expect(invite.canRespond, isFalse);
    });

    test('includes optional game and venue details', () {
      final invite = WatchPartyInvite.create(
        watchPartyId: 'wp_1',
        watchPartyName: 'Party',
        inviterId: 'inviter_1',
        inviterName: 'Inviter',
        inviteeId: 'invitee_1',
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        message: 'Come watch!',
        gameName: 'USA vs Mexico',
        gameDateTime: DateTime(2026, 6, 15, 18, 0),
        venueName: 'Sports Bar',
      );

      expect(invite.message, equals('Come watch!'));
      expect(invite.gameName, equals('USA vs Mexico'));
      expect(invite.venueName, equals('Sports Bar'));
    });
  });

  // ==================== WatchPartyInvite Firestore roundtrip ====================
  group('WatchPartyInvite Firestore roundtrip', () {
    test('toFirestore and fromFirestore preserve all fields', () {
      final invite = WatchPartyInvite.create(
        watchPartyId: 'wp_1',
        watchPartyName: 'Test Party',
        inviterId: 'inviter_1',
        inviterName: 'Inviter User',
        inviterImageUrl: 'https://example.com/inviter.jpg',
        inviteeId: 'invitee_1',
        expiresAt: DateTime(2026, 6, 15, 18, 0),
        message: 'Join us!',
        gameName: 'Brazil vs Argentina',
        gameDateTime: DateTime(2026, 6, 20, 20, 0),
        venueName: 'Stadium',
      );

      final data = invite.toFirestore();
      final restored =
          WatchPartyInvite.fromFirestore(data, invite.inviteId);

      expect(restored.inviteId, equals(invite.inviteId));
      expect(restored.watchPartyId, equals(invite.watchPartyId));
      expect(restored.watchPartyName, equals(invite.watchPartyName));
      expect(restored.inviterId, equals(invite.inviterId));
      expect(restored.inviterName, equals(invite.inviterName));
      expect(restored.inviterImageUrl, equals(invite.inviterImageUrl));
      expect(restored.inviteeId, equals(invite.inviteeId));
      expect(restored.status, equals(invite.status));
      expect(restored.message, equals(invite.message));
      expect(restored.gameName, equals(invite.gameName));
      expect(restored.venueName, equals(invite.venueName));
    });
  });

  // ==================== Business logic validation ====================
  group('Watch party business logic', () {
    test('canJoin is true only when upcoming and has spots', () {
      final party = WatchParty(
        watchPartyId: 'wp_1',
        name: 'Party',
        description: 'Desc',
        hostId: 'host',
        hostName: 'Host',
        visibility: WatchPartyVisibility.public,
        gameId: 'g1',
        gameName: 'Game',
        gameDateTime: DateTime.now().add(const Duration(hours: 2)),
        venueId: 'v1',
        venueName: 'Venue',
        maxAttendees: 20,
        currentAttendeesCount: 10,
        status: WatchPartyStatus.upcoming,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(party.canJoin, isTrue);
    });

    test('canJoin is false when party is full', () {
      final party = WatchParty(
        watchPartyId: 'wp_1',
        name: 'Party',
        description: 'Desc',
        hostId: 'host',
        hostName: 'Host',
        visibility: WatchPartyVisibility.public,
        gameId: 'g1',
        gameName: 'Game',
        gameDateTime: DateTime.now().add(const Duration(hours: 2)),
        venueId: 'v1',
        venueName: 'Venue',
        maxAttendees: 10,
        currentAttendeesCount: 10,
        status: WatchPartyStatus.upcoming,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(party.canJoin, isFalse);
      expect(party.isFull, isTrue);
    });

    test('canJoin is false when party is live', () {
      final party = WatchParty(
        watchPartyId: 'wp_1',
        name: 'Party',
        description: 'Desc',
        hostId: 'host',
        hostName: 'Host',
        visibility: WatchPartyVisibility.public,
        gameId: 'g1',
        gameName: 'Game',
        gameDateTime: DateTime.now().add(const Duration(hours: 2)),
        venueId: 'v1',
        venueName: 'Venue',
        maxAttendees: 20,
        currentAttendeesCount: 10,
        status: WatchPartyStatus.live,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(party.canJoin, isFalse);
    });

    test('canJoin is false when party is cancelled', () {
      final party = WatchParty(
        watchPartyId: 'wp_1',
        name: 'Party',
        description: 'Desc',
        hostId: 'host',
        hostName: 'Host',
        visibility: WatchPartyVisibility.public,
        gameId: 'g1',
        gameName: 'Game',
        gameDateTime: DateTime.now().add(const Duration(hours: 2)),
        venueId: 'v1',
        venueName: 'Venue',
        maxAttendees: 20,
        currentAttendeesCount: 10,
        status: WatchPartyStatus.cancelled,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(party.canJoin, isFalse);
      expect(party.isCancelled, isTrue);
    });

    test('totalAttendees sums in-person and virtual', () {
      final party = WatchParty(
        watchPartyId: 'wp_1',
        name: 'Party',
        description: 'Desc',
        hostId: 'host',
        hostName: 'Host',
        visibility: WatchPartyVisibility.public,
        gameId: 'g1',
        gameName: 'Game',
        gameDateTime: DateTime.now().add(const Duration(hours: 2)),
        venueId: 'v1',
        venueName: 'Venue',
        maxAttendees: 20,
        currentAttendeesCount: 8,
        virtualAttendeesCount: 12,
        status: WatchPartyStatus.upcoming,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(party.totalAttendees, equals(20));
    });

    test('copyWith updates status correctly', () {
      final party = WatchParty(
        watchPartyId: 'wp_1',
        name: 'Party',
        description: 'Desc',
        hostId: 'host',
        hostName: 'Host',
        visibility: WatchPartyVisibility.public,
        gameId: 'g1',
        gameName: 'Game',
        gameDateTime: DateTime.now().add(const Duration(hours: 2)),
        venueId: 'v1',
        venueName: 'Venue',
        maxAttendees: 20,
        status: WatchPartyStatus.upcoming,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final cancelled = party.copyWith(status: WatchPartyStatus.cancelled);

      expect(cancelled.isCancelled, isTrue);
      expect(cancelled.watchPartyId, equals(party.watchPartyId));
      expect(cancelled.hostId, equals(party.hostId));
    });
  });

  // ==================== Member role hierarchy ====================
  group('Member role hierarchy', () {
    test('host can manage members', () {
      final host = WatchPartyMember(
        memberId: 'test',
        watchPartyId: 'wp_1',
        userId: 'u1',
        displayName: 'Host',
        role: WatchPartyMemberRole.host,
        attendanceType: WatchPartyAttendanceType.inPerson,
        rsvpStatus: MemberRsvpStatus.going,
        joinedAt: DateTime.now(),
      );

      expect(host.isHost, isTrue);
      expect(host.canManageMembers, isTrue);
    });

    test('co-host can manage members', () {
      final coHost = WatchPartyMember(
        memberId: 'test',
        watchPartyId: 'wp_1',
        userId: 'u1',
        displayName: 'Co-Host',
        role: WatchPartyMemberRole.coHost,
        attendanceType: WatchPartyAttendanceType.inPerson,
        rsvpStatus: MemberRsvpStatus.going,
        joinedAt: DateTime.now(),
      );

      expect(coHost.isCoHost, isTrue);
      expect(coHost.canManageMembers, isTrue);
    });

    test('regular member cannot manage members', () {
      final member = WatchPartyMember(
        memberId: 'test',
        watchPartyId: 'wp_1',
        userId: 'u1',
        displayName: 'Member',
        role: WatchPartyMemberRole.member,
        attendanceType: WatchPartyAttendanceType.inPerson,
        rsvpStatus: MemberRsvpStatus.going,
        joinedAt: DateTime.now(),
      );

      expect(member.isMember, isTrue);
      expect(member.canManageMembers, isFalse);
    });
  });

  // ==================== Invite status transitions ====================
  group('Invite status transitions', () {
    test('accept transitions from pending to accepted', () {
      final invite = WatchPartyInvite(
        inviteId: 'inv_1',
        watchPartyId: 'wp_1',
        watchPartyName: 'Party',
        inviterId: 'inviter',
        inviterName: 'Inviter',
        inviteeId: 'invitee',
        status: WatchPartyInviteStatus.pending,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      final accepted = invite.accept();

      expect(accepted.isAccepted, isTrue);
      expect(accepted.inviteId, equals(invite.inviteId));
    });

    test('decline transitions from pending to declined', () {
      final invite = WatchPartyInvite(
        inviteId: 'inv_1',
        watchPartyId: 'wp_1',
        watchPartyName: 'Party',
        inviterId: 'inviter',
        inviterName: 'Inviter',
        inviteeId: 'invitee',
        status: WatchPartyInviteStatus.pending,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      final declined = invite.decline();

      expect(declined.isDeclined, isTrue);
    });

    test('markExpired transitions to expired', () {
      final invite = WatchPartyInvite(
        inviteId: 'inv_1',
        watchPartyId: 'wp_1',
        watchPartyName: 'Party',
        inviterId: 'inviter',
        inviterName: 'Inviter',
        inviteeId: 'invitee',
        status: WatchPartyInviteStatus.pending,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      final expired = invite.markExpired();

      expect(expired.isExpiredStatus, isTrue);
    });
  });
}
