part of 'watch_party_bloc.dart';

abstract class WatchPartyEvent extends Equatable {
  const WatchPartyEvent();

  @override
  List<Object?> get props => [];
}

/// Load public watch parties for discovery
class LoadPublicWatchPartiesEvent extends WatchPartyEvent {
  final String? gameId;
  final String? venueId;
  final int limit;

  const LoadPublicWatchPartiesEvent({
    this.gameId,
    this.venueId,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [gameId, venueId, limit];
}

/// Load user's watch parties (hosted + joined)
class LoadUserWatchPartiesEvent extends WatchPartyEvent {
  const LoadUserWatchPartiesEvent();
}

/// Load watch party detail with members and messages
class LoadWatchPartyDetailEvent extends WatchPartyEvent {
  final String watchPartyId;

  const LoadWatchPartyDetailEvent(this.watchPartyId);

  @override
  List<Object?> get props => [watchPartyId];
}

/// Create a new watch party
class CreateWatchPartyEvent extends WatchPartyEvent {
  final String name;
  final String description;
  final WatchPartyVisibility visibility;
  final String gameId;
  final String gameName;
  final DateTime gameDateTime;
  final String venueId;
  final String venueName;
  final String? venueAddress;
  final double? venueLatitude;
  final double? venueLongitude;
  final int maxAttendees;
  final bool allowVirtualAttendance;
  final double virtualAttendanceFee;
  final List<String> tags;

  const CreateWatchPartyEvent({
    required this.name,
    required this.description,
    required this.visibility,
    required this.gameId,
    required this.gameName,
    required this.gameDateTime,
    required this.venueId,
    required this.venueName,
    this.venueAddress,
    this.venueLatitude,
    this.venueLongitude,
    this.maxAttendees = 20,
    this.allowVirtualAttendance = false,
    this.virtualAttendanceFee = 0.0,
    this.tags = const [],
  });

  @override
  List<Object?> get props => [
        name,
        description,
        visibility,
        gameId,
        gameName,
        gameDateTime,
        venueId,
        venueName,
        venueAddress,
        venueLatitude,
        venueLongitude,
        maxAttendees,
        allowVirtualAttendance,
        virtualAttendanceFee,
        tags,
      ];
}

/// Update an existing watch party
class UpdateWatchPartyEvent extends WatchPartyEvent {
  final String watchPartyId;
  final String? name;
  final String? description;
  final WatchPartyVisibility? visibility;
  final int? maxAttendees;
  final bool? allowVirtualAttendance;
  final double? virtualAttendanceFee;
  final String? venueId;
  final String? venueName;
  final String? venueAddress;
  final double? venueLatitude;
  final double? venueLongitude;

  const UpdateWatchPartyEvent({
    required this.watchPartyId,
    this.name,
    this.description,
    this.visibility,
    this.maxAttendees,
    this.allowVirtualAttendance,
    this.virtualAttendanceFee,
    this.venueId,
    this.venueName,
    this.venueAddress,
    this.venueLatitude,
    this.venueLongitude,
  });

  @override
  List<Object?> get props => [
        watchPartyId,
        name,
        description,
        visibility,
        maxAttendees,
        allowVirtualAttendance,
        virtualAttendanceFee,
        venueId,
        venueName,
        venueAddress,
        venueLatitude,
        venueLongitude,
      ];
}

/// Join a watch party
class JoinWatchPartyEvent extends WatchPartyEvent {
  final String watchPartyId;
  final WatchPartyAttendanceType attendanceType;

  const JoinWatchPartyEvent({
    required this.watchPartyId,
    required this.attendanceType,
  });

  @override
  List<Object?> get props => [watchPartyId, attendanceType];
}

/// Leave a watch party
class LeaveWatchPartyEvent extends WatchPartyEvent {
  final String watchPartyId;

  const LeaveWatchPartyEvent(this.watchPartyId);

  @override
  List<Object?> get props => [watchPartyId];
}

/// Cancel a watch party (host only)
class CancelWatchPartyEvent extends WatchPartyEvent {
  final String watchPartyId;

  const CancelWatchPartyEvent(this.watchPartyId);

  @override
  List<Object?> get props => [watchPartyId];
}

/// Send a chat message
class SendMessageEvent extends WatchPartyEvent {
  final String watchPartyId;
  final String content;
  final String? replyToMessageId;

  const SendMessageEvent({
    required this.watchPartyId,
    required this.content,
    this.replyToMessageId,
  });

  @override
  List<Object?> get props => [watchPartyId, content, replyToMessageId];
}

/// Internal event when messages stream updates
class MessagesUpdatedEvent extends WatchPartyEvent {
  final List<WatchPartyMessage> messages;

  const MessagesUpdatedEvent(this.messages);

  @override
  List<Object?> get props => [messages];
}

/// Send invite to a user
class SendInviteEvent extends WatchPartyEvent {
  final String watchPartyId;
  final String inviteeId;
  final String? message;

  const SendInviteEvent({
    required this.watchPartyId,
    required this.inviteeId,
    this.message,
  });

  @override
  List<Object?> get props => [watchPartyId, inviteeId, message];
}

/// Respond to an invite (accept/decline)
class RespondToInviteEvent extends WatchPartyEvent {
  final String inviteId;
  final bool accept;

  const RespondToInviteEvent({
    required this.inviteId,
    required this.accept,
  });

  @override
  List<Object?> get props => [inviteId, accept];
}

/// Load pending invites for current user
class LoadPendingInvitesEvent extends WatchPartyEvent {
  const LoadPendingInvitesEvent();
}

/// Purchase virtual attendance
class PurchaseVirtualAttendanceEvent extends WatchPartyEvent {
  final String watchPartyId;
  final BuildContext context;

  const PurchaseVirtualAttendanceEvent({
    required this.watchPartyId,
    required this.context,
  });

  @override
  List<Object?> get props => [watchPartyId];
}

/// Mute/unmute a member (host/co-host only)
class ToggleMuteMemberEvent extends WatchPartyEvent {
  final String watchPartyId;
  final String memberId;
  final bool mute;

  const ToggleMuteMemberEvent({
    required this.watchPartyId,
    required this.memberId,
    required this.mute,
  });

  @override
  List<Object?> get props => [watchPartyId, memberId, mute];
}

/// Remove a member (host/co-host only)
class RemoveMemberEvent extends WatchPartyEvent {
  final String watchPartyId;
  final String memberId;

  const RemoveMemberEvent({
    required this.watchPartyId,
    required this.memberId,
  });

  @override
  List<Object?> get props => [watchPartyId, memberId];
}

/// Promote member to co-host
class PromoteMemberEvent extends WatchPartyEvent {
  final String watchPartyId;
  final String memberId;

  const PromoteMemberEvent({
    required this.watchPartyId,
    required this.memberId,
  });

  @override
  List<Object?> get props => [watchPartyId, memberId];
}

/// Demote co-host to member
class DemoteMemberEvent extends WatchPartyEvent {
  final String watchPartyId;
  final String memberId;

  const DemoteMemberEvent({
    required this.watchPartyId,
    required this.memberId,
  });

  @override
  List<Object?> get props => [watchPartyId, memberId];
}

/// Start the watch party (host only)
class StartWatchPartyEvent extends WatchPartyEvent {
  final String watchPartyId;

  const StartWatchPartyEvent(this.watchPartyId);

  @override
  List<Object?> get props => [watchPartyId];
}

/// End the watch party (host only)
class EndWatchPartyEvent extends WatchPartyEvent {
  final String watchPartyId;

  const EndWatchPartyEvent(this.watchPartyId);

  @override
  List<Object?> get props => [watchPartyId];
}

/// Subscribe to messages stream for a watch party
class SubscribeToMessagesEvent extends WatchPartyEvent {
  final String watchPartyId;

  const SubscribeToMessagesEvent(this.watchPartyId);

  @override
  List<Object?> get props => [watchPartyId];
}

/// Unsubscribe from messages stream
class UnsubscribeFromMessagesEvent extends WatchPartyEvent {
  const UnsubscribeFromMessagesEvent();
}

/// Clear any error state
class ClearErrorEvent extends WatchPartyEvent {
  const ClearErrorEvent();
}
