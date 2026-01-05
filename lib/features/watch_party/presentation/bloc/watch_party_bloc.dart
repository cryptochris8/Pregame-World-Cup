import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/watch_party.dart';
import '../../domain/entities/watch_party_member.dart';
import '../../domain/entities/watch_party_message.dart';
import '../../domain/entities/watch_party_invite.dart';
import '../../domain/services/watch_party_service.dart';
import '../../domain/services/watch_party_payment_service.dart';
import '../../../../core/services/logging_service.dart';

part 'watch_party_event.dart';
part 'watch_party_state.dart';

/// BLoC for managing watch party state
class WatchPartyBloc extends Bloc<WatchPartyEvent, WatchPartyState> {
  final WatchPartyService watchPartyService;
  final WatchPartyPaymentService paymentService;
  static const String _logTag = 'WatchPartyBloc';

  // Message stream subscription
  StreamSubscription<List<WatchPartyMessage>>? _messagesSubscription;
  String? _currentWatchPartyId;

  WatchPartyBloc({
    required this.watchPartyService,
    required this.paymentService,
  }) : super(WatchPartyInitial()) {
    // Discovery & Loading
    on<LoadPublicWatchPartiesEvent>(_onLoadPublicWatchParties);
    on<LoadUserWatchPartiesEvent>(_onLoadUserWatchParties);
    on<LoadWatchPartyDetailEvent>(_onLoadWatchPartyDetail);

    // CRUD Operations
    on<CreateWatchPartyEvent>(_onCreateWatchParty);
    on<UpdateWatchPartyEvent>(_onUpdateWatchParty);
    on<CancelWatchPartyEvent>(_onCancelWatchParty);

    // Membership
    on<JoinWatchPartyEvent>(_onJoinWatchParty);
    on<LeaveWatchPartyEvent>(_onLeaveWatchParty);

    // Messaging
    on<SendMessageEvent>(_onSendMessage);
    on<MessagesUpdatedEvent>(_onMessagesUpdated);
    on<SubscribeToMessagesEvent>(_onSubscribeToMessages);
    on<UnsubscribeFromMessagesEvent>(_onUnsubscribeFromMessages);

    // Invites
    on<SendInviteEvent>(_onSendInvite);
    on<RespondToInviteEvent>(_onRespondToInvite);
    on<LoadPendingInvitesEvent>(_onLoadPendingInvites);

    // Payments
    on<PurchaseVirtualAttendanceEvent>(_onPurchaseVirtualAttendance);

    // Member Management
    on<ToggleMuteMemberEvent>(_onToggleMuteMember);
    on<RemoveMemberEvent>(_onRemoveMember);
    on<PromoteMemberEvent>(_onPromoteMember);
    on<DemoteMemberEvent>(_onDemoteMember);

    // Status Changes
    on<StartWatchPartyEvent>(_onStartWatchParty);
    on<EndWatchPartyEvent>(_onEndWatchParty);

    // Utility
    on<ClearErrorEvent>(_onClearError);
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }

  // ==================== Discovery & Loading ====================

  Future<void> _onLoadPublicWatchParties(
    LoadPublicWatchPartiesEvent event,
    Emitter<WatchPartyState> emit,
  ) async {
    emit(WatchPartyLoading());
    try {
      final watchParties = await watchPartyService.getPublicWatchParties(
        gameId: event.gameId,
        venueId: event.venueId,
        limit: event.limit,
      );

      emit(PublicWatchPartiesLoaded(
        watchParties: watchParties,
        gameId: event.gameId,
        venueId: event.venueId,
      ));
      LoggingService.info('Loaded ${watchParties.length} public watch parties', tag: _logTag);
    } catch (e) {
      LoggingService.error('Failed to load public watch parties: $e', tag: _logTag);
      emit(WatchPartyError('Failed to load watch parties: $e'));
    }
  }

  Future<void> _onLoadUserWatchParties(
    LoadUserWatchPartiesEvent event,
    Emitter<WatchPartyState> emit,
  ) async {
    emit(WatchPartyLoading());
    try {
      final allParties = await watchPartyService.getUserWatchParties();
      final userId = FirebaseAuth.instance.currentUser?.uid;

      final now = DateTime.now();
      final hostedParties = <WatchParty>[];
      final attendingParties = <WatchParty>[];
      final pastParties = <WatchParty>[];

      for (final party in allParties) {
        final isHost = party.hostId == userId;
        final isPast = party.hasEnded ||
            party.isCancelled ||
            party.gameDateTime.isBefore(now.subtract(const Duration(hours: 4)));

        if (isPast) {
          pastParties.add(party);
        } else if (isHost) {
          hostedParties.add(party);
        } else {
          attendingParties.add(party);
        }
      }

      emit(UserWatchPartiesLoaded(
        hostedParties: hostedParties,
        attendingParties: attendingParties,
        pastParties: pastParties,
      ));
      LoggingService.info(
          'Loaded user watch parties: ${hostedParties.length} hosted, ${attendingParties.length} attending', tag: _logTag);
    } catch (e) {
      LoggingService.error('Failed to load user watch parties: $e', tag: _logTag);
      emit(WatchPartyError('Failed to load your watch parties: $e'));
    }
  }

  Future<void> _onLoadWatchPartyDetail(
    LoadWatchPartyDetailEvent event,
    Emitter<WatchPartyState> emit,
  ) async {
    emit(WatchPartyLoading());
    try {
      final watchParty = await watchPartyService.getWatchParty(event.watchPartyId);
      if (watchParty == null) {
        emit(const WatchPartyError('Watch party not found'));
        return;
      }

      final members = await watchPartyService.getMembers(event.watchPartyId);
      final userId = FirebaseAuth.instance.currentUser?.uid;

      WatchPartyMember? currentUserMember;
      bool isHost = false;
      bool isCoHost = false;
      bool isMember = false;

      if (userId != null) {
        for (final member in members) {
          if (member.userId == userId) {
            currentUserMember = member;
            isHost = member.isHost;
            isCoHost = member.isCoHost;
            isMember = true;
            break;
          }
        }
        // Also check if user is the host even if not in members list
        if (watchParty.hostId == userId) {
          isHost = true;
          isMember = true;
        }
      }

      emit(WatchPartyDetailLoaded(
        watchParty: watchParty,
        members: members,
        currentUserMember: currentUserMember,
        isHost: isHost,
        isCoHost: isCoHost,
        isMember: isMember,
      ));
      LoggingService.info('Loaded watch party detail: ${watchParty.name}', tag: _logTag);
    } catch (e) {
      LoggingService.error('Failed to load watch party detail: $e', tag: _logTag);
      emit(WatchPartyError('Failed to load watch party: $e'));
    }
  }

  // ==================== CRUD Operations ====================

  Future<void> _onCreateWatchParty(
    CreateWatchPartyEvent event,
    Emitter<WatchPartyState> emit,
  ) async {
    emit(const WatchPartyOperationInProgress(operation: 'creating'));
    try {
      final watchParty = await watchPartyService.createWatchParty(
        name: event.name,
        description: event.description,
        visibility: event.visibility,
        gameId: event.gameId,
        gameName: event.gameName,
        gameDateTime: event.gameDateTime,
        venueId: event.venueId,
        venueName: event.venueName,
        venueAddress: event.venueAddress,
        venueLatitude: event.venueLatitude,
        venueLongitude: event.venueLongitude,
        maxAttendees: event.maxAttendees,
        allowVirtualAttendance: event.allowVirtualAttendance,
        virtualAttendanceFee: event.virtualAttendanceFee,
        tags: event.tags,
      );

      if (watchParty == null) {
        emit(const WatchPartyError('Failed to create watch party'));
        return;
      }
      emit(WatchPartyCreated(watchParty));
      LoggingService.info('Created watch party: ${watchParty.name}', tag: _logTag);
    } catch (e) {
      LoggingService.error('Failed to create watch party: $e', tag: _logTag);
      emit(WatchPartyError('Failed to create watch party: $e'));
    }
  }

  Future<void> _onUpdateWatchParty(
    UpdateWatchPartyEvent event,
    Emitter<WatchPartyState> emit,
  ) async {
    final previousState = state;
    emit(WatchPartyOperationInProgress(
      operation: 'updating',
      previousState: previousState,
    ));
    try {
      await watchPartyService.updateWatchParty(
        event.watchPartyId,
        name: event.name,
        description: event.description,
        visibility: event.visibility,
        maxAttendees: event.maxAttendees,
        allowVirtualAttendance: event.allowVirtualAttendance,
        virtualAttendanceFee: event.virtualAttendanceFee,
      );

      final updatedParty = await watchPartyService.getWatchParty(event.watchPartyId);
      if (updatedParty != null) {
        emit(WatchPartyUpdated(updatedParty));
        LoggingService.info('Updated watch party: ${updatedParty.name}', tag: _logTag);
      }
    } catch (e) {
      LoggingService.error('Failed to update watch party: $e', tag: _logTag);
      emit(WatchPartyError('Failed to update watch party: $e'));
    }
  }

  Future<void> _onCancelWatchParty(
    CancelWatchPartyEvent event,
    Emitter<WatchPartyState> emit,
  ) async {
    emit(const WatchPartyOperationInProgress(operation: 'cancelling'));
    try {
      await watchPartyService.cancelWatchParty(event.watchPartyId);
      emit(WatchPartyCancelled(event.watchPartyId));
      LoggingService.info('Cancelled watch party: ${event.watchPartyId}', tag: _logTag);
    } catch (e) {
      LoggingService.error('Failed to cancel watch party: $e', tag: _logTag);
      emit(WatchPartyError('Failed to cancel watch party: $e'));
    }
  }

  // ==================== Membership ====================

  Future<void> _onJoinWatchParty(
    JoinWatchPartyEvent event,
    Emitter<WatchPartyState> emit,
  ) async {
    emit(const WatchPartyOperationInProgress(operation: 'joining'));
    try {
      await watchPartyService.joinWatchParty(
        event.watchPartyId,
        event.attendanceType,
      );
      emit(WatchPartyJoined(
        watchPartyId: event.watchPartyId,
        attendanceType: event.attendanceType,
      ));
      LoggingService.info('Joined watch party: ${event.watchPartyId}', tag: _logTag);
    } catch (e) {
      LoggingService.error('Failed to join watch party: $e', tag: _logTag);
      emit(WatchPartyError('Failed to join watch party: $e'));
    }
  }

  Future<void> _onLeaveWatchParty(
    LeaveWatchPartyEvent event,
    Emitter<WatchPartyState> emit,
  ) async {
    emit(const WatchPartyOperationInProgress(operation: 'leaving'));
    try {
      await watchPartyService.leaveWatchParty(event.watchPartyId);
      emit(WatchPartyLeft(event.watchPartyId));
      LoggingService.info('Left watch party: ${event.watchPartyId}', tag: _logTag);
    } catch (e) {
      LoggingService.error('Failed to leave watch party: $e', tag: _logTag);
      emit(WatchPartyError('Failed to leave watch party: $e'));
    }
  }

  // ==================== Messaging ====================

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<WatchPartyState> emit,
  ) async {
    try {
      final message = await watchPartyService.sendMessage(
        event.watchPartyId,
        event.content,
        replyToMessageId: event.replyToMessageId,
      );
      emit(MessageSent(message));
    } catch (e) {
      LoggingService.error('Failed to send message: $e', tag: _logTag);
      emit(WatchPartyError('Failed to send message: $e'));
    }
  }

  void _onMessagesUpdated(
    MessagesUpdatedEvent event,
    Emitter<WatchPartyState> emit,
  ) {
    final currentState = state;
    if (currentState is WatchPartyDetailLoaded) {
      emit(currentState.copyWithMessages(event.messages));
    }
  }

  Future<void> _onSubscribeToMessages(
    SubscribeToMessagesEvent event,
    Emitter<WatchPartyState> emit,
  ) async {
    // Cancel existing subscription if any
    await _messagesSubscription?.cancel();
    _currentWatchPartyId = event.watchPartyId;

    _messagesSubscription = watchPartyService
        .getMessagesStream(event.watchPartyId)
        .listen((messages) {
      if (_currentWatchPartyId == event.watchPartyId) {
        add(MessagesUpdatedEvent(messages));
      }
    });
    LoggingService.info('Subscribed to messages for: ${event.watchPartyId}', tag: _logTag);
  }

  Future<void> _onUnsubscribeFromMessages(
    UnsubscribeFromMessagesEvent event,
    Emitter<WatchPartyState> emit,
  ) async {
    await _messagesSubscription?.cancel();
    _messagesSubscription = null;
    _currentWatchPartyId = null;
    LoggingService.info('Unsubscribed from messages', tag: _logTag);
  }

  // ==================== Invites ====================

  Future<void> _onSendInvite(
    SendInviteEvent event,
    Emitter<WatchPartyState> emit,
  ) async {
    try {
      await watchPartyService.sendInvite(
        event.watchPartyId,
        event.inviteeId,
        message: event.message,
      );
      emit(InviteSent(event.inviteeId));
      LoggingService.info('Sent invite to: ${event.inviteeId}', tag: _logTag);
    } catch (e) {
      LoggingService.error('Failed to send invite: $e', tag: _logTag);
      emit(WatchPartyError('Failed to send invite: $e'));
    }
  }

  Future<void> _onRespondToInvite(
    RespondToInviteEvent event,
    Emitter<WatchPartyState> emit,
  ) async {
    emit(const WatchPartyOperationInProgress(operation: 'responding'));
    try {
      final watchPartyId = await watchPartyService.respondToInvite(
        event.inviteId,
        event.accept,
      );
      emit(InviteResponded(
        inviteId: event.inviteId,
        accepted: event.accept,
        watchPartyId: event.accept ? watchPartyId : null,
      ));
      LoggingService.info('Responded to invite: ${event.accept ? "accepted" : "declined"}', tag: _logTag);
    } catch (e) {
      LoggingService.error('Failed to respond to invite: $e', tag: _logTag);
      emit(WatchPartyError('Failed to respond to invite: $e'));
    }
  }

  Future<void> _onLoadPendingInvites(
    LoadPendingInvitesEvent event,
    Emitter<WatchPartyState> emit,
  ) async {
    try {
      final invites = await watchPartyService.getPendingInvites();
      emit(PendingInvitesLoaded(invites));
      LoggingService.info('Loaded ${invites.length} pending invites', tag: _logTag);
    } catch (e) {
      LoggingService.error('Failed to load pending invites: $e', tag: _logTag);
      emit(WatchPartyError('Failed to load invites: $e'));
    }
  }

  // ==================== Payments ====================

  Future<void> _onPurchaseVirtualAttendance(
    PurchaseVirtualAttendanceEvent event,
    Emitter<WatchPartyState> emit,
  ) async {
    emit(const WatchPartyOperationInProgress(operation: 'purchasing'));
    try {
      final success = await paymentService.purchaseVirtualAttendance(
        watchPartyId: event.watchPartyId,
        context: event.context,
      );
      if (success) {
        emit(VirtualAttendancePurchased(event.watchPartyId));
        LoggingService.info('Purchased virtual attendance for: ${event.watchPartyId}', tag: _logTag);
      } else {
        emit(const WatchPartyError('Payment was cancelled or failed'));
      }
    } catch (e) {
      LoggingService.error('Failed to purchase virtual attendance: $e', tag: _logTag);
      emit(WatchPartyError('Failed to purchase: $e'));
    }
  }

  // ==================== Member Management ====================

  Future<void> _onToggleMuteMember(
    ToggleMuteMemberEvent event,
    Emitter<WatchPartyState> emit,
  ) async {
    try {
      if (event.mute) {
        await watchPartyService.muteMember(event.watchPartyId, event.memberId);
      } else {
        await watchPartyService.unmuteMember(event.watchPartyId, event.memberId);
      }
      emit(MemberActionCompleted(
        action: event.mute ? 'muted' : 'unmuted',
        memberId: event.memberId,
      ));
    } catch (e) {
      LoggingService.error('Failed to toggle mute member: $e', tag: _logTag);
      emit(WatchPartyError('Failed to ${event.mute ? "mute" : "unmute"} member: $e'));
    }
  }

  Future<void> _onRemoveMember(
    RemoveMemberEvent event,
    Emitter<WatchPartyState> emit,
  ) async {
    try {
      await watchPartyService.removeMember(event.watchPartyId, event.memberId);
      emit(MemberActionCompleted(
        action: 'removed',
        memberId: event.memberId,
      ));
      LoggingService.info('Removed member: ${event.memberId}', tag: _logTag);
    } catch (e) {
      LoggingService.error('Failed to remove member: $e', tag: _logTag);
      emit(WatchPartyError('Failed to remove member: $e'));
    }
  }

  Future<void> _onPromoteMember(
    PromoteMemberEvent event,
    Emitter<WatchPartyState> emit,
  ) async {
    try {
      await watchPartyService.promoteMember(event.watchPartyId, event.memberId);
      emit(MemberActionCompleted(
        action: 'promoted',
        memberId: event.memberId,
      ));
      LoggingService.info('Promoted member: ${event.memberId}', tag: _logTag);
    } catch (e) {
      LoggingService.error('Failed to promote member: $e', tag: _logTag);
      emit(WatchPartyError('Failed to promote member: $e'));
    }
  }

  Future<void> _onDemoteMember(
    DemoteMemberEvent event,
    Emitter<WatchPartyState> emit,
  ) async {
    try {
      await watchPartyService.demoteMember(event.watchPartyId, event.memberId);
      emit(MemberActionCompleted(
        action: 'demoted',
        memberId: event.memberId,
      ));
      LoggingService.info('Demoted member: ${event.memberId}', tag: _logTag);
    } catch (e) {
      LoggingService.error('Failed to demote member: $e', tag: _logTag);
      emit(WatchPartyError('Failed to demote member: $e'));
    }
  }

  // ==================== Status Changes ====================

  Future<void> _onStartWatchParty(
    StartWatchPartyEvent event,
    Emitter<WatchPartyState> emit,
  ) async {
    try {
      await watchPartyService.startWatchParty(event.watchPartyId);
      emit(WatchPartyStatusChanged(
        watchPartyId: event.watchPartyId,
        newStatus: WatchPartyStatus.live,
      ));
      LoggingService.info('Started watch party: ${event.watchPartyId}', tag: _logTag);
    } catch (e) {
      LoggingService.error('Failed to start watch party: $e', tag: _logTag);
      emit(WatchPartyError('Failed to start watch party: $e'));
    }
  }

  Future<void> _onEndWatchParty(
    EndWatchPartyEvent event,
    Emitter<WatchPartyState> emit,
  ) async {
    try {
      await watchPartyService.endWatchParty(event.watchPartyId);
      emit(WatchPartyStatusChanged(
        watchPartyId: event.watchPartyId,
        newStatus: WatchPartyStatus.ended,
      ));
      LoggingService.info('Ended watch party: ${event.watchPartyId}', tag: _logTag);
    } catch (e) {
      LoggingService.error('Failed to end watch party: $e', tag: _logTag);
      emit(WatchPartyError('Failed to end watch party: $e'));
    }
  }

  // ==================== Utility ====================

  void _onClearError(
    ClearErrorEvent event,
    Emitter<WatchPartyState> emit,
  ) {
    emit(WatchPartyInitial());
  }
}
