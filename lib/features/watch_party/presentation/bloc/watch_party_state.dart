part of 'watch_party_bloc.dart';

abstract class WatchPartyState extends Equatable {
  const WatchPartyState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class WatchPartyInitial extends WatchPartyState {}

/// Loading state
class WatchPartyLoading extends WatchPartyState {}

/// Public watch parties loaded for discovery
class PublicWatchPartiesLoaded extends WatchPartyState {
  final List<WatchParty> watchParties;
  final String? gameId;
  final String? venueId;

  const PublicWatchPartiesLoaded({
    required this.watchParties,
    this.gameId,
    this.venueId,
  });

  @override
  List<Object?> get props => [watchParties, gameId, venueId];

  /// Filter to upcoming parties only
  List<WatchParty> get upcomingParties =>
      watchParties.where((p) => p.isUpcoming).toList();

  /// Filter to live parties only
  List<WatchParty> get liveParties =>
      watchParties.where((p) => p.isLive).toList();
}

/// User's watch parties loaded (hosted + attending)
class UserWatchPartiesLoaded extends WatchPartyState {
  final List<WatchParty> hostedParties;
  final List<WatchParty> attendingParties;
  final List<WatchParty> pastParties;

  const UserWatchPartiesLoaded({
    required this.hostedParties,
    required this.attendingParties,
    required this.pastParties,
  });

  @override
  List<Object?> get props => [hostedParties, attendingParties, pastParties];

  /// All active parties (hosted + attending)
  List<WatchParty> get allActiveParties => [
        ...hostedParties.where((p) => !p.hasEnded && !p.isCancelled),
        ...attendingParties.where((p) => !p.hasEnded && !p.isCancelled),
      ];
}

/// Watch party detail loaded with members and messages
class WatchPartyDetailLoaded extends WatchPartyState {
  final WatchParty watchParty;
  final List<WatchPartyMember> members;
  final List<WatchPartyMessage> messages;
  final WatchPartyMember? currentUserMember;
  final bool isHost;
  final bool isCoHost;
  final bool isMember;

  const WatchPartyDetailLoaded({
    required this.watchParty,
    required this.members,
    this.messages = const [],
    this.currentUserMember,
    this.isHost = false,
    this.isCoHost = false,
    this.isMember = false,
  });

  @override
  List<Object?> get props => [
        watchParty,
        members,
        messages,
        currentUserMember,
        isHost,
        isCoHost,
        isMember,
      ];

  /// Create a copy with updated messages
  WatchPartyDetailLoaded copyWithMessages(List<WatchPartyMessage> newMessages) {
    return WatchPartyDetailLoaded(
      watchParty: watchParty,
      members: members,
      messages: newMessages,
      currentUserMember: currentUserMember,
      isHost: isHost,
      isCoHost: isCoHost,
      isMember: isMember,
    );
  }

  /// Create a copy with updated members
  WatchPartyDetailLoaded copyWithMembers(List<WatchPartyMember> newMembers) {
    return WatchPartyDetailLoaded(
      watchParty: watchParty,
      members: newMembers,
      messages: messages,
      currentUserMember: currentUserMember,
      isHost: isHost,
      isCoHost: isCoHost,
      isMember: isMember,
    );
  }

  /// Check if current user can send messages
  bool get canChat => currentUserMember?.canChat ?? false;

  /// Check if current user can manage members
  bool get canManageMembers => isHost || isCoHost;

  /// Get in-person attendees count
  int get inPersonCount =>
      members.where((m) => m.isInPerson && m.isGoing).length;

  /// Get virtual attendees count
  int get virtualCount =>
      members.where((m) => m.isVirtual && m.isGoing).length;

  /// Get going members only
  List<WatchPartyMember> get goingMembers =>
      members.where((m) => m.isGoing).toList();

  /// Get maybe members
  List<WatchPartyMember> get maybeMembers =>
      members.where((m) => m.isMaybe).toList();
}

/// Watch party created successfully
class WatchPartyCreated extends WatchPartyState {
  final WatchParty watchParty;

  const WatchPartyCreated(this.watchParty);

  @override
  List<Object?> get props => [watchParty];
}

/// Watch party updated successfully
class WatchPartyUpdated extends WatchPartyState {
  final WatchParty watchParty;

  const WatchPartyUpdated(this.watchParty);

  @override
  List<Object?> get props => [watchParty];
}

/// Joined watch party successfully
class WatchPartyJoined extends WatchPartyState {
  final String watchPartyId;
  final WatchPartyAttendanceType attendanceType;

  const WatchPartyJoined({
    required this.watchPartyId,
    required this.attendanceType,
  });

  @override
  List<Object?> get props => [watchPartyId, attendanceType];
}

/// Left watch party successfully
class WatchPartyLeft extends WatchPartyState {
  final String watchPartyId;

  const WatchPartyLeft(this.watchPartyId);

  @override
  List<Object?> get props => [watchPartyId];
}

/// Watch party cancelled successfully
class WatchPartyCancelled extends WatchPartyState {
  final String watchPartyId;

  const WatchPartyCancelled(this.watchPartyId);

  @override
  List<Object?> get props => [watchPartyId];
}

/// Message sent successfully
class MessageSent extends WatchPartyState {
  final WatchPartyMessage message;

  const MessageSent(this.message);

  @override
  List<Object?> get props => [message];
}

/// Invite sent successfully
class InviteSent extends WatchPartyState {
  final String inviteeId;

  const InviteSent(this.inviteeId);

  @override
  List<Object?> get props => [inviteeId];
}

/// Invite response processed
class InviteResponded extends WatchPartyState {
  final String inviteId;
  final bool accepted;
  final String? watchPartyId;

  const InviteResponded({
    required this.inviteId,
    required this.accepted,
    this.watchPartyId,
  });

  @override
  List<Object?> get props => [inviteId, accepted, watchPartyId];
}

/// Pending invites loaded
class PendingInvitesLoaded extends WatchPartyState {
  final List<WatchPartyInvite> invites;

  const PendingInvitesLoaded(this.invites);

  @override
  List<Object?> get props => [invites];

  /// Get valid (non-expired) invites only
  List<WatchPartyInvite> get validInvites =>
      invites.where((i) => i.isValid).toList();
}

/// Virtual attendance purchased successfully
class VirtualAttendancePurchased extends WatchPartyState {
  final String watchPartyId;

  const VirtualAttendancePurchased(this.watchPartyId);

  @override
  List<Object?> get props => [watchPartyId];
}

/// Member action completed (mute, remove, promote, demote)
class MemberActionCompleted extends WatchPartyState {
  final String action;
  final String memberId;

  const MemberActionCompleted({
    required this.action,
    required this.memberId,
  });

  @override
  List<Object?> get props => [action, memberId];
}

/// Watch party status changed (started, ended)
class WatchPartyStatusChanged extends WatchPartyState {
  final String watchPartyId;
  final WatchPartyStatus newStatus;

  const WatchPartyStatusChanged({
    required this.watchPartyId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [watchPartyId, newStatus];
}

/// Error state
class WatchPartyError extends WatchPartyState {
  final String message;
  final String? code;

  const WatchPartyError(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Operation in progress (for showing loading indicators on specific actions)
class WatchPartyOperationInProgress extends WatchPartyState {
  final String operation;
  final WatchPartyState? previousState;

  const WatchPartyOperationInProgress({
    required this.operation,
    this.previousState,
  });

  @override
  List<Object?> get props => [operation, previousState];
}
