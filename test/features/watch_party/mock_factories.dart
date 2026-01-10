import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party_member.dart';

/// Test data factories for watch party entities
class WatchPartyTestFactory {
  static WatchParty createWatchParty({
    String watchPartyId = 'wp_test_123',
    String name = 'USA vs Mexico Watch Party',
    String description = 'Join us for an exciting match!',
    String hostId = 'host_123',
    String hostName = 'John Doe',
    String? hostImageUrl,
    WatchPartyVisibility visibility = WatchPartyVisibility.public,
    String gameId = 'game_123',
    String gameName = 'USA vs Mexico',
    DateTime? gameDateTime,
    String venueId = 'venue_123',
    String venueName = 'Sports Bar Downtown',
    String? venueAddress = '123 Main St',
    int maxAttendees = 20,
    int currentAttendeesCount = 5,
    int virtualAttendeesCount = 0,
    bool allowVirtualAttendance = false,
    double virtualAttendanceFee = 0.0,
    WatchPartyStatus status = WatchPartyStatus.upcoming,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String> tags = const [],
  }) {
    final now = DateTime.now();
    return WatchParty(
      watchPartyId: watchPartyId,
      name: name,
      description: description,
      hostId: hostId,
      hostName: hostName,
      hostImageUrl: hostImageUrl,
      visibility: visibility,
      gameId: gameId,
      gameName: gameName,
      gameDateTime: gameDateTime ?? now.add(const Duration(hours: 2)),
      venueId: venueId,
      venueName: venueName,
      venueAddress: venueAddress,
      maxAttendees: maxAttendees,
      currentAttendeesCount: currentAttendeesCount,
      virtualAttendeesCount: virtualAttendeesCount,
      allowVirtualAttendance: allowVirtualAttendance,
      virtualAttendanceFee: virtualAttendanceFee,
      status: status,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      tags: tags,
    );
  }

  static WatchPartyMember createMember({
    String memberId = 'member_123',
    String watchPartyId = 'wp_test_123',
    String userId = 'user_123',
    String displayName = 'Test User',
    String? profileImageUrl,
    WatchPartyMemberRole role = WatchPartyMemberRole.member,
    WatchPartyAttendanceType attendanceType = WatchPartyAttendanceType.inPerson,
    MemberRsvpStatus rsvpStatus = MemberRsvpStatus.going,
    DateTime? joinedAt,
    bool hasPaid = false,
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
      joinedAt: joinedAt ?? DateTime.now(),
      hasPaid: hasPaid,
      isMuted: isMuted,
    );
  }

  static List<WatchPartyMember> createMemberList({int count = 5}) {
    return List.generate(count, (i) => createMember(
      memberId: 'member_$i',
      userId: 'user_$i',
      displayName: 'User ${i + 1}',
      role: i == 0 ? WatchPartyMemberRole.host : WatchPartyMemberRole.member,
    ));
  }
}
