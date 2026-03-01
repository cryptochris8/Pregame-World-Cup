import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party_member.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party_message.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party_invite.dart';
import 'package:pregame_world_cup/features/watch_party/domain/services/watch_party_service.dart';
import 'package:pregame_world_cup/features/watch_party/domain/services/watch_party_payment_service.dart';
import 'package:pregame_world_cup/features/watch_party/presentation/bloc/watch_party_bloc.dart';

// -- Mocks --
class MockWatchPartyService extends Mock implements WatchPartyService {}

class MockWatchPartyPaymentService extends Mock
    implements WatchPartyPaymentService {}

void main() {
  setUpAll(() {
    registerFallbackValue(WatchPartyVisibility.public);
    registerFallbackValue(DateTime(2026, 1, 1));
  });

  late MockWatchPartyService mockService;
  late MockWatchPartyPaymentService mockPaymentService;
  late WatchPartyBloc bloc;

  // Test data
  final now = DateTime(2026, 6, 15, 18, 0);
  final futureDate = DateTime(2026, 7, 1, 20, 0);

  final testWatchParty = WatchParty(
    watchPartyId: 'wp_1',
    name: 'USA vs Mexico Watch Party',
    description: 'Come watch the big game!',
    hostId: 'host_user',
    hostName: 'Test Host',
    visibility: WatchPartyVisibility.public,
    gameId: 'game_1',
    gameName: 'USA vs Mexico',
    gameDateTime: futureDate,
    venueId: 'venue_1',
    venueName: 'Sports Bar Downtown',
    maxAttendees: 20,
    currentAttendeesCount: 5,
    status: WatchPartyStatus.upcoming,
    createdAt: now,
    updatedAt: now,
  );

  final testWatchParty2 = WatchParty(
    watchPartyId: 'wp_2',
    name: 'Brazil vs Germany Watch Party',
    description: 'Classic rivalry!',
    hostId: 'host_user_2',
    hostName: 'Another Host',
    visibility: WatchPartyVisibility.public,
    gameId: 'game_2',
    gameName: 'Brazil vs Germany',
    gameDateTime: futureDate.add(const Duration(days: 1)),
    venueId: 'venue_2',
    venueName: 'Pub Central',
    maxAttendees: 30,
    currentAttendeesCount: 10,
    status: WatchPartyStatus.upcoming,
    createdAt: now,
    updatedAt: now,
  );

  final testMember = WatchPartyMember(
    memberId: 'wp_1_user_1',
    watchPartyId: 'wp_1',
    userId: 'user_1',
    displayName: 'Test User',
    role: WatchPartyMemberRole.host,
    attendanceType: WatchPartyAttendanceType.inPerson,
    rsvpStatus: MemberRsvpStatus.going,
    joinedAt: now,
  );

  final testMember2 = WatchPartyMember(
    memberId: 'wp_1_user_2',
    watchPartyId: 'wp_1',
    userId: 'user_2',
    displayName: 'Second User',
    role: WatchPartyMemberRole.member,
    attendanceType: WatchPartyAttendanceType.inPerson,
    rsvpStatus: MemberRsvpStatus.going,
    joinedAt: now,
  );

  final testMessage = WatchPartyMessage(
    messageId: 'msg_1',
    watchPartyId: 'wp_1',
    senderId: 'user_1',
    senderName: 'Test User',
    senderRole: WatchPartyMemberRole.host,
    content: 'Hello everyone!',
    type: WatchPartyMessageType.text,
    createdAt: now,
  );

  final testInvite = WatchPartyInvite(
    inviteId: 'inv_1',
    watchPartyId: 'wp_1',
    watchPartyName: 'USA vs Mexico Watch Party',
    inviterId: 'user_1',
    inviterName: 'Test User',
    inviteeId: 'user_3',
    status: WatchPartyInviteStatus.pending,
    createdAt: now,
    expiresAt: futureDate,
  );

  setUp(() {
    mockService = MockWatchPartyService();
    mockPaymentService = MockWatchPartyPaymentService();
    bloc = WatchPartyBloc(
      watchPartyService: mockService,
      paymentService: mockPaymentService,
    );
  });

  tearDown(() {
    bloc.close();
  });

  // ==================== Initial State ====================

  group('WatchPartyBloc initial state', () {
    test('initial state is WatchPartyInitial', () {
      expect(bloc.state, isA<WatchPartyInitial>());
    });
  });

  // ==================== LoadPublicWatchPartiesEvent ====================

  group('LoadPublicWatchPartiesEvent', () {
    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [Loading, PublicWatchPartiesLoaded] on success',
      build: () {
        when(() => mockService.getPublicWatchParties(
              gameId: null,
              venueId: null,
              limit: 20,
            )).thenAnswer((_) async => [testWatchParty, testWatchParty2]);
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadPublicWatchPartiesEvent()),
      expect: () => [
        isA<WatchPartyLoading>(),
        isA<PublicWatchPartiesLoaded>()
            .having((s) => s.watchParties.length, 'watch parties count', 2)
            .having((s) => s.gameId, 'gameId', null)
            .having((s) => s.venueId, 'venueId', null),
      ],
    );

    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [Loading, PublicWatchPartiesLoaded] with filters',
      build: () {
        when(() => mockService.getPublicWatchParties(
              gameId: 'game_1',
              venueId: 'venue_1',
              limit: 10,
            )).thenAnswer((_) async => [testWatchParty]);
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadPublicWatchPartiesEvent(
        gameId: 'game_1',
        venueId: 'venue_1',
        limit: 10,
      )),
      expect: () => [
        isA<WatchPartyLoading>(),
        isA<PublicWatchPartiesLoaded>()
            .having((s) => s.watchParties.length, 'watch parties count', 1)
            .having((s) => s.gameId, 'gameId', 'game_1')
            .having((s) => s.venueId, 'venueId', 'venue_1'),
      ],
    );

    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [Loading, PublicWatchPartiesLoaded] with empty list',
      build: () {
        when(() => mockService.getPublicWatchParties(
              gameId: null,
              venueId: null,
              limit: 20,
            )).thenAnswer((_) async => []);
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadPublicWatchPartiesEvent()),
      expect: () => [
        isA<WatchPartyLoading>(),
        isA<PublicWatchPartiesLoaded>()
            .having((s) => s.watchParties.isEmpty, 'empty list', true),
      ],
    );

    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [Loading, Error] when service throws',
      build: () {
        when(() => mockService.getPublicWatchParties(
              gameId: null,
              venueId: null,
              limit: 20,
            )).thenThrow(Exception('Network error'));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadPublicWatchPartiesEvent()),
      expect: () => [
        isA<WatchPartyLoading>(),
        isA<WatchPartyError>(),
      ],
    );
  });

  // ==================== CreateWatchPartyEvent ====================

  group('CreateWatchPartyEvent', () {
    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [OperationInProgress, WatchPartyCreated] on success',
      build: () {
        when(() => mockService.createWatchParty(
              name: any(named: 'name'),
              description: any(named: 'description'),
              visibility: any(named: 'visibility'),
              gameId: any(named: 'gameId'),
              gameName: any(named: 'gameName'),
              gameDateTime: any(named: 'gameDateTime'),
              venueId: any(named: 'venueId'),
              venueName: any(named: 'venueName'),
              venueAddress: any(named: 'venueAddress'),
              venueLatitude: any(named: 'venueLatitude'),
              venueLongitude: any(named: 'venueLongitude'),
              maxAttendees: any(named: 'maxAttendees'),
              allowVirtualAttendance: any(named: 'allowVirtualAttendance'),
              virtualAttendanceFee: any(named: 'virtualAttendanceFee'),
              tags: any(named: 'tags'),
            )).thenAnswer((_) async => testWatchParty);
        return bloc;
      },
      act: (bloc) => bloc.add(CreateWatchPartyEvent(
        name: 'USA vs Mexico Watch Party',
        description: 'Come watch the big game!',
        visibility: WatchPartyVisibility.public,
        gameId: 'game_1',
        gameName: 'USA vs Mexico',
        gameDateTime: futureDate,
        venueId: 'venue_1',
        venueName: 'Sports Bar Downtown',
      )),
      expect: () => [
        isA<WatchPartyOperationInProgress>()
            .having((s) => s.operation, 'operation', 'creating'),
        isA<WatchPartyCreated>()
            .having((s) => s.watchParty.name, 'party name',
                'USA vs Mexico Watch Party'),
      ],
    );

    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [OperationInProgress, Error] when service returns null',
      build: () {
        when(() => mockService.createWatchParty(
              name: any(named: 'name'),
              description: any(named: 'description'),
              visibility: any(named: 'visibility'),
              gameId: any(named: 'gameId'),
              gameName: any(named: 'gameName'),
              gameDateTime: any(named: 'gameDateTime'),
              venueId: any(named: 'venueId'),
              venueName: any(named: 'venueName'),
              venueAddress: any(named: 'venueAddress'),
              venueLatitude: any(named: 'venueLatitude'),
              venueLongitude: any(named: 'venueLongitude'),
              maxAttendees: any(named: 'maxAttendees'),
              allowVirtualAttendance: any(named: 'allowVirtualAttendance'),
              virtualAttendanceFee: any(named: 'virtualAttendanceFee'),
              tags: any(named: 'tags'),
            )).thenAnswer((_) async => null);
        return bloc;
      },
      act: (bloc) => bloc.add(CreateWatchPartyEvent(
        name: 'Test Party',
        description: 'Desc',
        visibility: WatchPartyVisibility.public,
        gameId: 'game_1',
        gameName: 'USA vs Mexico',
        gameDateTime: futureDate,
        venueId: 'venue_1',
        venueName: 'Bar',
      )),
      expect: () => [
        isA<WatchPartyOperationInProgress>(),
        isA<WatchPartyError>()
            .having((s) => s.message, 'message',
                'Failed to create watch party'),
      ],
    );

    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [OperationInProgress, Error] when service throws',
      build: () {
        when(() => mockService.createWatchParty(
              name: any(named: 'name'),
              description: any(named: 'description'),
              visibility: any(named: 'visibility'),
              gameId: any(named: 'gameId'),
              gameName: any(named: 'gameName'),
              gameDateTime: any(named: 'gameDateTime'),
              venueId: any(named: 'venueId'),
              venueName: any(named: 'venueName'),
              venueAddress: any(named: 'venueAddress'),
              venueLatitude: any(named: 'venueLatitude'),
              venueLongitude: any(named: 'venueLongitude'),
              maxAttendees: any(named: 'maxAttendees'),
              allowVirtualAttendance: any(named: 'allowVirtualAttendance'),
              virtualAttendanceFee: any(named: 'virtualAttendanceFee'),
              tags: any(named: 'tags'),
            )).thenThrow(Exception('Firebase error'));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateWatchPartyEvent(
        name: 'Test Party',
        description: 'Desc',
        visibility: WatchPartyVisibility.public,
        gameId: 'game_1',
        gameName: 'USA vs Mexico',
        gameDateTime: futureDate,
        venueId: 'venue_1',
        venueName: 'Bar',
      )),
      expect: () => [
        isA<WatchPartyOperationInProgress>(),
        isA<WatchPartyError>(),
      ],
    );
  });

  // ==================== UpdateWatchPartyEvent ====================

  group('UpdateWatchPartyEvent', () {
    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [OperationInProgress, WatchPartyUpdated] on success',
      build: () {
        when(() => mockService.updateWatchParty(
              'wp_1',
              name: 'Updated Name',
              description: null,
              visibility: null,
              maxAttendees: null,
              allowVirtualAttendance: null,
              virtualAttendanceFee: null,
            )).thenAnswer((_) async => true);
        when(() => mockService.getWatchParty('wp_1'))
            .thenAnswer((_) async => testWatchParty.copyWith(name: 'Updated Name'));
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateWatchPartyEvent(
        watchPartyId: 'wp_1',
        name: 'Updated Name',
      )),
      expect: () => [
        isA<WatchPartyOperationInProgress>()
            .having((s) => s.operation, 'operation', 'updating'),
        isA<WatchPartyUpdated>()
            .having((s) => s.watchParty.name, 'updated name', 'Updated Name'),
      ],
    );

    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [OperationInProgress, Error] when update throws',
      build: () {
        when(() => mockService.updateWatchParty(
              'wp_1',
              name: 'Updated',
              description: null,
              visibility: null,
              maxAttendees: null,
              allowVirtualAttendance: null,
              virtualAttendanceFee: null,
            )).thenThrow(Exception('Permission denied'));
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateWatchPartyEvent(
        watchPartyId: 'wp_1',
        name: 'Updated',
      )),
      expect: () => [
        isA<WatchPartyOperationInProgress>(),
        isA<WatchPartyError>(),
      ],
    );
  });

  // ==================== CancelWatchPartyEvent ====================

  group('CancelWatchPartyEvent', () {
    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [OperationInProgress, WatchPartyCancelled] on success',
      build: () {
        when(() => mockService.cancelWatchParty('wp_1'))
            .thenAnswer((_) async => true);
        return bloc;
      },
      act: (bloc) => bloc.add(const CancelWatchPartyEvent('wp_1')),
      expect: () => [
        isA<WatchPartyOperationInProgress>()
            .having((s) => s.operation, 'operation', 'cancelling'),
        isA<WatchPartyCancelled>()
            .having((s) => s.watchPartyId, 'id', 'wp_1'),
      ],
    );

    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [OperationInProgress, Error] when cancel throws',
      build: () {
        when(() => mockService.cancelWatchParty('wp_1'))
            .thenThrow(Exception('Not authorized'));
        return bloc;
      },
      act: (bloc) => bloc.add(const CancelWatchPartyEvent('wp_1')),
      expect: () => [
        isA<WatchPartyOperationInProgress>(),
        isA<WatchPartyError>(),
      ],
    );
  });

  // ==================== JoinWatchPartyEvent ====================

  group('JoinWatchPartyEvent', () {
    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [OperationInProgress, WatchPartyJoined] on success (inPerson)',
      build: () {
        when(() => mockService.joinWatchParty(
              'wp_1',
              WatchPartyAttendanceType.inPerson,
            )).thenAnswer((_) async => true);
        return bloc;
      },
      act: (bloc) => bloc.add(const JoinWatchPartyEvent(
        watchPartyId: 'wp_1',
        attendanceType: WatchPartyAttendanceType.inPerson,
      )),
      expect: () => [
        isA<WatchPartyOperationInProgress>()
            .having((s) => s.operation, 'operation', 'joining'),
        isA<WatchPartyJoined>()
            .having((s) => s.watchPartyId, 'id', 'wp_1')
            .having((s) => s.attendanceType, 'type',
                WatchPartyAttendanceType.inPerson),
      ],
    );

    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [OperationInProgress, WatchPartyJoined] on success (virtual)',
      build: () {
        when(() => mockService.joinWatchParty(
              'wp_1',
              WatchPartyAttendanceType.virtual,
            )).thenAnswer((_) async => true);
        return bloc;
      },
      act: (bloc) => bloc.add(const JoinWatchPartyEvent(
        watchPartyId: 'wp_1',
        attendanceType: WatchPartyAttendanceType.virtual,
      )),
      expect: () => [
        isA<WatchPartyOperationInProgress>(),
        isA<WatchPartyJoined>()
            .having((s) => s.attendanceType, 'type',
                WatchPartyAttendanceType.virtual),
      ],
    );

    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [OperationInProgress, Error] when join throws',
      build: () {
        when(() => mockService.joinWatchParty(
              'wp_1',
              WatchPartyAttendanceType.inPerson,
            )).thenThrow(Exception('Party is full'));
        return bloc;
      },
      act: (bloc) => bloc.add(const JoinWatchPartyEvent(
        watchPartyId: 'wp_1',
        attendanceType: WatchPartyAttendanceType.inPerson,
      )),
      expect: () => [
        isA<WatchPartyOperationInProgress>(),
        isA<WatchPartyError>(),
      ],
    );
  });

  // ==================== LeaveWatchPartyEvent ====================

  group('LeaveWatchPartyEvent', () {
    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [OperationInProgress, WatchPartyLeft] on success',
      build: () {
        when(() => mockService.leaveWatchParty('wp_1'))
            .thenAnswer((_) async => true);
        return bloc;
      },
      act: (bloc) => bloc.add(const LeaveWatchPartyEvent('wp_1')),
      expect: () => [
        isA<WatchPartyOperationInProgress>()
            .having((s) => s.operation, 'operation', 'leaving'),
        isA<WatchPartyLeft>()
            .having((s) => s.watchPartyId, 'id', 'wp_1'),
      ],
    );

    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [OperationInProgress, Error] when leave throws',
      build: () {
        when(() => mockService.leaveWatchParty('wp_1'))
            .thenThrow(Exception('Cannot leave'));
        return bloc;
      },
      act: (bloc) => bloc.add(const LeaveWatchPartyEvent('wp_1')),
      expect: () => [
        isA<WatchPartyOperationInProgress>(),
        isA<WatchPartyError>(),
      ],
    );
  });

  // ==================== SendMessageEvent ====================

  group('SendMessageEvent', () {
    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [MessageSent] on success',
      build: () {
        when(() => mockService.sendMessage(
              'wp_1',
              'Hello everyone!',
              replyToMessageId: null,
            )).thenAnswer((_) async => testMessage);
        return bloc;
      },
      act: (bloc) => bloc.add(const SendMessageEvent(
        watchPartyId: 'wp_1',
        content: 'Hello everyone!',
      )),
      expect: () => [
        isA<MessageSent>()
            .having((s) => s.message.content, 'content', 'Hello everyone!'),
      ],
    );

    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [MessageSent] with reply on success',
      build: () {
        when(() => mockService.sendMessage(
              'wp_1',
              'Reply text',
              replyToMessageId: 'msg_original',
            )).thenAnswer((_) async => testMessage);
        return bloc;
      },
      act: (bloc) => bloc.add(const SendMessageEvent(
        watchPartyId: 'wp_1',
        content: 'Reply text',
        replyToMessageId: 'msg_original',
      )),
      expect: () => [
        isA<MessageSent>(),
      ],
    );

    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [Error] when send throws',
      build: () {
        when(() => mockService.sendMessage(
              'wp_1',
              'Hello!',
              replyToMessageId: null,
            )).thenThrow(Exception('User is muted'));
        return bloc;
      },
      act: (bloc) => bloc.add(const SendMessageEvent(
        watchPartyId: 'wp_1',
        content: 'Hello!',
      )),
      expect: () => [
        isA<WatchPartyError>(),
      ],
    );
  });

  // ==================== MessagesUpdatedEvent ====================

  group('MessagesUpdatedEvent', () {
    final detailState = WatchPartyDetailLoaded(
      watchParty: testWatchParty,
      members: [testMember, testMember2],
      messages: const [],
      currentUserMember: testMember,
      isHost: true,
      isCoHost: false,
      isMember: true,
    );

    blocTest<WatchPartyBloc, WatchPartyState>(
      'updates messages when current state is WatchPartyDetailLoaded',
      build: () => bloc,
      seed: () => detailState,
      act: (bloc) => bloc.add(MessagesUpdatedEvent([testMessage])),
      expect: () => [
        isA<WatchPartyDetailLoaded>()
            .having((s) => s.messages.length, 'message count', 1)
            .having(
                (s) => s.messages.first.content, 'content', 'Hello everyone!')
            .having((s) => s.watchParty, 'party preserved', testWatchParty)
            .having((s) => s.members.length, 'members preserved', 2)
            .having((s) => s.isHost, 'host preserved', true),
      ],
    );

    blocTest<WatchPartyBloc, WatchPartyState>(
      'does nothing when current state is not WatchPartyDetailLoaded',
      build: () => bloc,
      seed: () => WatchPartyInitial(),
      act: (bloc) => bloc.add(MessagesUpdatedEvent([testMessage])),
      expect: () => [],
    );
  });

  // ==================== SubscribeToMessagesEvent ====================

  group('SubscribeToMessagesEvent', () {
    blocTest<WatchPartyBloc, WatchPartyState>(
      'subscribes to messages stream',
      build: () {
        when(() => mockService.getMessagesStream('wp_1'))
            .thenAnswer((_) => const Stream<List<WatchPartyMessage>>.empty());
        return bloc;
      },
      act: (bloc) => bloc.add(const SubscribeToMessagesEvent('wp_1')),
      expect: () => [],
      verify: (_) {
        verify(() => mockService.getMessagesStream('wp_1')).called(1);
      },
    );

    blocTest<WatchPartyBloc, WatchPartyState>(
      'receives messages from stream and emits MessagesUpdated',
      build: () {
        final controller = StreamController<List<WatchPartyMessage>>();
        when(() => mockService.getMessagesStream('wp_1'))
            .thenAnswer((_) => controller.stream);

        // Emit messages after a small delay so subscription is set up
        Future.delayed(const Duration(milliseconds: 50), () {
          controller.add([testMessage]);
        });

        return bloc;
      },
      seed: () => WatchPartyDetailLoaded(
        watchParty: testWatchParty,
        members: [testMember],
        messages: const [],
        isHost: true,
        isMember: true,
      ),
      act: (bloc) => bloc.add(const SubscribeToMessagesEvent('wp_1')),
      wait: const Duration(milliseconds: 200),
      expect: () => [
        isA<WatchPartyDetailLoaded>()
            .having((s) => s.messages.length, 'message count', 1),
      ],
    );
  });

  // ==================== UnsubscribeFromMessagesEvent ====================

  group('UnsubscribeFromMessagesEvent', () {
    blocTest<WatchPartyBloc, WatchPartyState>(
      'unsubscribes from messages stream without emitting state',
      build: () => bloc,
      act: (bloc) =>
          bloc.add(const UnsubscribeFromMessagesEvent()),
      expect: () => [],
    );
  });

  // ==================== SendInviteEvent ====================

  group('SendInviteEvent', () {
    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [InviteSent] on success',
      build: () {
        when(() => mockService.sendInvite(
              'wp_1',
              'user_3',
              message: null,
            )).thenAnswer((_) async => true);
        return bloc;
      },
      act: (bloc) => bloc.add(const SendInviteEvent(
        watchPartyId: 'wp_1',
        inviteeId: 'user_3',
      )),
      expect: () => [
        isA<InviteSent>()
            .having((s) => s.inviteeId, 'inviteeId', 'user_3'),
      ],
    );

    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [InviteSent] with message on success',
      build: () {
        when(() => mockService.sendInvite(
              'wp_1',
              'user_3',
              message: 'Join us!',
            )).thenAnswer((_) async => true);
        return bloc;
      },
      act: (bloc) => bloc.add(const SendInviteEvent(
        watchPartyId: 'wp_1',
        inviteeId: 'user_3',
        message: 'Join us!',
      )),
      expect: () => [
        isA<InviteSent>(),
      ],
    );

    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [Error] when invite throws',
      build: () {
        when(() => mockService.sendInvite(
              'wp_1',
              'user_3',
              message: null,
            )).thenThrow(Exception('Already invited'));
        return bloc;
      },
      act: (bloc) => bloc.add(const SendInviteEvent(
        watchPartyId: 'wp_1',
        inviteeId: 'user_3',
      )),
      expect: () => [
        isA<WatchPartyError>(),
      ],
    );
  });

  // ==================== RespondToInviteEvent ====================

  group('RespondToInviteEvent', () {
    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [OperationInProgress, InviteResponded(accepted)] on accept',
      build: () {
        when(() => mockService.respondToInvite('inv_1', true))
            .thenAnswer((_) async => 'wp_1');
        return bloc;
      },
      act: (bloc) => bloc.add(const RespondToInviteEvent(
        inviteId: 'inv_1',
        accept: true,
      )),
      expect: () => [
        isA<WatchPartyOperationInProgress>()
            .having((s) => s.operation, 'operation', 'responding'),
        isA<InviteResponded>()
            .having((s) => s.inviteId, 'inviteId', 'inv_1')
            .having((s) => s.accepted, 'accepted', true)
            .having((s) => s.watchPartyId, 'watchPartyId', 'wp_1'),
      ],
    );

    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [OperationInProgress, InviteResponded(declined)] on decline',
      build: () {
        when(() => mockService.respondToInvite('inv_1', false))
            .thenAnswer((_) async => null);
        return bloc;
      },
      act: (bloc) => bloc.add(const RespondToInviteEvent(
        inviteId: 'inv_1',
        accept: false,
      )),
      expect: () => [
        isA<WatchPartyOperationInProgress>(),
        isA<InviteResponded>()
            .having((s) => s.accepted, 'accepted', false)
            .having((s) => s.watchPartyId, 'watchPartyId', null),
      ],
    );

    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [OperationInProgress, Error] when response throws',
      build: () {
        when(() => mockService.respondToInvite('inv_1', true))
            .thenThrow(Exception('Invite expired'));
        return bloc;
      },
      act: (bloc) => bloc.add(const RespondToInviteEvent(
        inviteId: 'inv_1',
        accept: true,
      )),
      expect: () => [
        isA<WatchPartyOperationInProgress>(),
        isA<WatchPartyError>(),
      ],
    );
  });

  // ==================== LoadPendingInvitesEvent ====================

  group('LoadPendingInvitesEvent', () {
    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [PendingInvitesLoaded] on success',
      build: () {
        when(() => mockService.getPendingInvites())
            .thenAnswer((_) async => [testInvite]);
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadPendingInvitesEvent()),
      expect: () => [
        isA<PendingInvitesLoaded>()
            .having((s) => s.invites.length, 'invite count', 1)
            .having(
                (s) => s.invites.first.inviteId, 'first invite id', 'inv_1'),
      ],
    );

    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [PendingInvitesLoaded] with empty list',
      build: () {
        when(() => mockService.getPendingInvites())
            .thenAnswer((_) async => []);
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadPendingInvitesEvent()),
      expect: () => [
        isA<PendingInvitesLoaded>()
            .having((s) => s.invites.isEmpty, 'empty', true),
      ],
    );

    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [Error] when loading invites throws',
      build: () {
        when(() => mockService.getPendingInvites())
            .thenThrow(Exception('Auth error'));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadPendingInvitesEvent()),
      expect: () => [
        isA<WatchPartyError>(),
      ],
    );
  });

  // ==================== ToggleMuteMemberEvent ====================

  group('ToggleMuteMemberEvent', () {
    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [MemberActionCompleted(muted)] when muting',
      build: () {
        when(() => mockService.muteMember('wp_1', 'user_2'))
            .thenAnswer((_) async => true);
        return bloc;
      },
      act: (bloc) => bloc.add(const ToggleMuteMemberEvent(
        watchPartyId: 'wp_1',
        memberId: 'user_2',
        mute: true,
      )),
      expect: () => [
        isA<MemberActionCompleted>()
            .having((s) => s.action, 'action', 'muted')
            .having((s) => s.memberId, 'memberId', 'user_2'),
      ],
    );

    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [MemberActionCompleted(unmuted)] when unmuting',
      build: () {
        when(() => mockService.unmuteMember('wp_1', 'user_2'))
            .thenAnswer((_) async => true);
        return bloc;
      },
      act: (bloc) => bloc.add(const ToggleMuteMemberEvent(
        watchPartyId: 'wp_1',
        memberId: 'user_2',
        mute: false,
      )),
      expect: () => [
        isA<MemberActionCompleted>()
            .having((s) => s.action, 'action', 'unmuted')
            .having((s) => s.memberId, 'memberId', 'user_2'),
      ],
    );

    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [Error] when mute throws',
      build: () {
        when(() => mockService.muteMember('wp_1', 'user_2'))
            .thenThrow(Exception('Not authorized'));
        return bloc;
      },
      act: (bloc) => bloc.add(const ToggleMuteMemberEvent(
        watchPartyId: 'wp_1',
        memberId: 'user_2',
        mute: true,
      )),
      expect: () => [
        isA<WatchPartyError>(),
      ],
    );
  });

  // ==================== RemoveMemberEvent ====================

  group('RemoveMemberEvent', () {
    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [MemberActionCompleted(removed)] on success',
      build: () {
        when(() => mockService.removeMember('wp_1', 'user_2'))
            .thenAnswer((_) async => true);
        return bloc;
      },
      act: (bloc) => bloc.add(const RemoveMemberEvent(
        watchPartyId: 'wp_1',
        memberId: 'user_2',
      )),
      expect: () => [
        isA<MemberActionCompleted>()
            .having((s) => s.action, 'action', 'removed')
            .having((s) => s.memberId, 'memberId', 'user_2'),
      ],
    );

    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [Error] when remove throws',
      build: () {
        when(() => mockService.removeMember('wp_1', 'user_2'))
            .thenThrow(Exception('Cannot remove host'));
        return bloc;
      },
      act: (bloc) => bloc.add(const RemoveMemberEvent(
        watchPartyId: 'wp_1',
        memberId: 'user_2',
      )),
      expect: () => [
        isA<WatchPartyError>(),
      ],
    );
  });

  // ==================== PromoteMemberEvent ====================

  group('PromoteMemberEvent', () {
    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [MemberActionCompleted(promoted)] on success',
      build: () {
        when(() => mockService.promoteMember('wp_1', 'user_2'))
            .thenAnswer((_) async => true);
        return bloc;
      },
      act: (bloc) => bloc.add(const PromoteMemberEvent(
        watchPartyId: 'wp_1',
        memberId: 'user_2',
      )),
      expect: () => [
        isA<MemberActionCompleted>()
            .having((s) => s.action, 'action', 'promoted')
            .having((s) => s.memberId, 'memberId', 'user_2'),
      ],
    );

    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [Error] when promote throws',
      build: () {
        when(() => mockService.promoteMember('wp_1', 'user_2'))
            .thenThrow(Exception('Not authorized'));
        return bloc;
      },
      act: (bloc) => bloc.add(const PromoteMemberEvent(
        watchPartyId: 'wp_1',
        memberId: 'user_2',
      )),
      expect: () => [
        isA<WatchPartyError>(),
      ],
    );
  });

  // ==================== DemoteMemberEvent ====================

  group('DemoteMemberEvent', () {
    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [MemberActionCompleted(demoted)] on success',
      build: () {
        when(() => mockService.demoteMember('wp_1', 'user_2'))
            .thenAnswer((_) async => true);
        return bloc;
      },
      act: (bloc) => bloc.add(const DemoteMemberEvent(
        watchPartyId: 'wp_1',
        memberId: 'user_2',
      )),
      expect: () => [
        isA<MemberActionCompleted>()
            .having((s) => s.action, 'action', 'demoted')
            .having((s) => s.memberId, 'memberId', 'user_2'),
      ],
    );

    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [Error] when demote throws',
      build: () {
        when(() => mockService.demoteMember('wp_1', 'user_2'))
            .thenThrow(Exception('Not authorized'));
        return bloc;
      },
      act: (bloc) => bloc.add(const DemoteMemberEvent(
        watchPartyId: 'wp_1',
        memberId: 'user_2',
      )),
      expect: () => [
        isA<WatchPartyError>(),
      ],
    );
  });

  // ==================== StartWatchPartyEvent ====================

  group('StartWatchPartyEvent', () {
    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [WatchPartyStatusChanged(live)] on success',
      build: () {
        when(() => mockService.startWatchParty('wp_1'))
            .thenAnswer((_) async => true);
        return bloc;
      },
      act: (bloc) => bloc.add(const StartWatchPartyEvent('wp_1')),
      expect: () => [
        isA<WatchPartyStatusChanged>()
            .having((s) => s.watchPartyId, 'id', 'wp_1')
            .having(
                (s) => s.newStatus, 'status', WatchPartyStatus.live),
      ],
    );

    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [Error] when start throws',
      build: () {
        when(() => mockService.startWatchParty('wp_1'))
            .thenThrow(Exception('Not host'));
        return bloc;
      },
      act: (bloc) => bloc.add(const StartWatchPartyEvent('wp_1')),
      expect: () => [
        isA<WatchPartyError>(),
      ],
    );
  });

  // ==================== EndWatchPartyEvent ====================

  group('EndWatchPartyEvent', () {
    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [WatchPartyStatusChanged(ended)] on success',
      build: () {
        when(() => mockService.endWatchParty('wp_1'))
            .thenAnswer((_) async => true);
        return bloc;
      },
      act: (bloc) => bloc.add(const EndWatchPartyEvent('wp_1')),
      expect: () => [
        isA<WatchPartyStatusChanged>()
            .having((s) => s.watchPartyId, 'id', 'wp_1')
            .having(
                (s) => s.newStatus, 'status', WatchPartyStatus.ended),
      ],
    );

    blocTest<WatchPartyBloc, WatchPartyState>(
      'emits [Error] when end throws',
      build: () {
        when(() => mockService.endWatchParty('wp_1'))
            .thenThrow(Exception('Not host'));
        return bloc;
      },
      act: (bloc) => bloc.add(const EndWatchPartyEvent('wp_1')),
      expect: () => [
        isA<WatchPartyError>(),
      ],
    );
  });

  // ==================== ClearErrorEvent ====================

  group('ClearErrorEvent', () {
    blocTest<WatchPartyBloc, WatchPartyState>(
      'resets state to WatchPartyInitial',
      build: () => bloc,
      seed: () => const WatchPartyError('Some error'),
      act: (bloc) => bloc.add(const ClearErrorEvent()),
      expect: () => [
        isA<WatchPartyInitial>(),
      ],
    );
  });

  // ==================== State tests ====================

  group('WatchPartyState properties', () {
    test('PublicWatchPartiesLoaded upcomingParties filters correctly', () {
      final liveParty = testWatchParty.copyWith(
        status: WatchPartyStatus.live,
      );
      final state = PublicWatchPartiesLoaded(
        watchParties: [testWatchParty, liveParty],
      );

      expect(state.upcomingParties.length, 1);
      expect(state.upcomingParties.first.watchPartyId, 'wp_1');
    });

    test('PublicWatchPartiesLoaded liveParties filters correctly', () {
      final liveParty = testWatchParty.copyWith(
        status: WatchPartyStatus.live,
      );
      final state = PublicWatchPartiesLoaded(
        watchParties: [testWatchParty, liveParty],
      );

      expect(state.liveParties.length, 1);
      expect(state.liveParties.first.status, WatchPartyStatus.live);
    });

    test('UserWatchPartiesLoaded allActiveParties excludes ended/cancelled',
        () {
      final endedParty = testWatchParty.copyWith(
        status: WatchPartyStatus.ended,
      );
      final cancelledParty = testWatchParty2.copyWith(
        status: WatchPartyStatus.cancelled,
      );
      final state = UserWatchPartiesLoaded(
        hostedParties: [testWatchParty, endedParty],
        attendingParties: [testWatchParty2, cancelledParty],
        pastParties: [],
      );

      expect(state.allActiveParties.length, 2);
    });

    test('WatchPartyDetailLoaded copyWithMessages preserves other fields', () {
      final original = WatchPartyDetailLoaded(
        watchParty: testWatchParty,
        members: [testMember, testMember2],
        messages: const [],
        currentUserMember: testMember,
        isHost: true,
        isCoHost: false,
        isMember: true,
      );

      final updated = original.copyWithMessages([testMessage]);

      expect(updated.messages.length, 1);
      expect(updated.watchParty, original.watchParty);
      expect(updated.members, original.members);
      expect(updated.currentUserMember, original.currentUserMember);
      expect(updated.isHost, true);
      expect(updated.isMember, true);
    });

    test('WatchPartyDetailLoaded copyWithMembers preserves other fields', () {
      final original = WatchPartyDetailLoaded(
        watchParty: testWatchParty,
        members: [testMember],
        messages: [testMessage],
        currentUserMember: testMember,
        isHost: true,
        isCoHost: false,
        isMember: true,
      );

      final updated = original.copyWithMembers([testMember, testMember2]);

      expect(updated.members.length, 2);
      expect(updated.messages, original.messages);
      expect(updated.watchParty, original.watchParty);
    });

    test('WatchPartyDetailLoaded canChat delegates to member', () {
      final mutedMember = testMember.copyWith(isMuted: true);
      final state = WatchPartyDetailLoaded(
        watchParty: testWatchParty,
        members: [mutedMember],
        currentUserMember: mutedMember,
        isHost: true,
        isMember: true,
      );

      expect(state.canChat, false);
    });

    test('WatchPartyDetailLoaded canManageMembers for host', () {
      final state = WatchPartyDetailLoaded(
        watchParty: testWatchParty,
        members: [testMember],
        isHost: true,
        isCoHost: false,
        isMember: true,
      );

      expect(state.canManageMembers, true);
    });

    test('WatchPartyDetailLoaded canManageMembers for co-host', () {
      final state = WatchPartyDetailLoaded(
        watchParty: testWatchParty,
        members: [testMember],
        isHost: false,
        isCoHost: true,
        isMember: true,
      );

      expect(state.canManageMembers, true);
    });

    test('WatchPartyDetailLoaded canManageMembers false for regular member',
        () {
      final state = WatchPartyDetailLoaded(
        watchParty: testWatchParty,
        members: [testMember2],
        isHost: false,
        isCoHost: false,
        isMember: true,
      );

      expect(state.canManageMembers, false);
    });

    test('WatchPartyDetailLoaded inPersonCount and virtualCount', () {
      final virtualMember = WatchPartyMember(
        memberId: 'wp_1_user_3',
        watchPartyId: 'wp_1',
        userId: 'user_3',
        displayName: 'Virtual User',
        role: WatchPartyMemberRole.member,
        attendanceType: WatchPartyAttendanceType.virtual,
        rsvpStatus: MemberRsvpStatus.going,
        joinedAt: now,
        hasPaid: true,
      );

      final state = WatchPartyDetailLoaded(
        watchParty: testWatchParty,
        members: [testMember, testMember2, virtualMember],
        isHost: true,
        isMember: true,
      );

      expect(state.inPersonCount, 2);
      expect(state.virtualCount, 1);
    });

    test('WatchPartyDetailLoaded goingMembers and maybeMembers', () {
      final maybeMember = testMember2.copyWith(
        rsvpStatus: MemberRsvpStatus.maybe,
      );

      final state = WatchPartyDetailLoaded(
        watchParty: testWatchParty,
        members: [testMember, maybeMember],
        isHost: true,
        isMember: true,
      );

      expect(state.goingMembers.length, 1);
      expect(state.maybeMembers.length, 1);
    });

    test('WatchPartyDetailLoaded canChat returns false when no member', () {
      final state = WatchPartyDetailLoaded(
        watchParty: testWatchParty,
        members: [testMember],
        currentUserMember: null,
        isHost: false,
        isMember: false,
      );

      expect(state.canChat, false);
    });

    test('PendingInvitesLoaded validInvites filters expired', () {
      final expiredInvite = WatchPartyInvite(
        inviteId: 'inv_2',
        watchPartyId: 'wp_1',
        watchPartyName: 'Party',
        inviterId: 'user_1',
        inviterName: 'User',
        inviteeId: 'user_3',
        status: WatchPartyInviteStatus.pending,
        createdAt: DateTime(2020, 1, 1),
        expiresAt: DateTime(2020, 1, 5), // Definitely in the past
      );

      final state = PendingInvitesLoaded([testInvite, expiredInvite]);

      // testInvite has expiresAt = futureDate (2026-07-01), so it's valid
      // expiredInvite has expiresAt = 2020-01-05, definitely expired
      expect(state.validInvites.length, 1);
      expect(state.validInvites.first.inviteId, 'inv_1');
    });
  });

  // ==================== Event equality ====================

  group('WatchPartyEvent equality', () {
    test('LoadPublicWatchPartiesEvent supports Equatable', () {
      const event1 = LoadPublicWatchPartiesEvent(gameId: 'g1');
      const event2 = LoadPublicWatchPartiesEvent(gameId: 'g1');
      const event3 = LoadPublicWatchPartiesEvent(gameId: 'g2');

      expect(event1, event2);
      expect(event1, isNot(event3));
    });

    test('CreateWatchPartyEvent supports Equatable', () {
      final event1 = CreateWatchPartyEvent(
        name: 'Party',
        description: 'Desc',
        visibility: WatchPartyVisibility.public,
        gameId: 'g1',
        gameName: 'Game 1',
        gameDateTime: futureDate,
        venueId: 'v1',
        venueName: 'Venue',
      );
      final event2 = CreateWatchPartyEvent(
        name: 'Party',
        description: 'Desc',
        visibility: WatchPartyVisibility.public,
        gameId: 'g1',
        gameName: 'Game 1',
        gameDateTime: futureDate,
        venueId: 'v1',
        venueName: 'Venue',
      );

      expect(event1, event2);
    });

    test('JoinWatchPartyEvent supports Equatable', () {
      const event1 = JoinWatchPartyEvent(
        watchPartyId: 'wp_1',
        attendanceType: WatchPartyAttendanceType.inPerson,
      );
      const event2 = JoinWatchPartyEvent(
        watchPartyId: 'wp_1',
        attendanceType: WatchPartyAttendanceType.virtual,
      );

      expect(event1, isNot(event2));
    });

    test('SendMessageEvent supports Equatable', () {
      const event1 = SendMessageEvent(
        watchPartyId: 'wp_1',
        content: 'Hello',
      );
      const event2 = SendMessageEvent(
        watchPartyId: 'wp_1',
        content: 'Hello',
      );

      expect(event1, event2);
    });

    test('ToggleMuteMemberEvent supports Equatable', () {
      const event1 = ToggleMuteMemberEvent(
        watchPartyId: 'wp_1',
        memberId: 'user_2',
        mute: true,
      );
      const event2 = ToggleMuteMemberEvent(
        watchPartyId: 'wp_1',
        memberId: 'user_2',
        mute: false,
      );

      expect(event1, isNot(event2));
    });
  });

  // ==================== State equality ====================

  group('WatchPartyState equality', () {
    test('WatchPartyError supports Equatable', () {
      const state1 = WatchPartyError('error', code: '404');
      const state2 = WatchPartyError('error', code: '404');
      const state3 = WatchPartyError('different error');

      expect(state1, state2);
      expect(state1, isNot(state3));
    });

    test('WatchPartyOperationInProgress supports Equatable', () {
      const state1 =
          WatchPartyOperationInProgress(operation: 'creating');
      const state2 =
          WatchPartyOperationInProgress(operation: 'creating');
      const state3 =
          WatchPartyOperationInProgress(operation: 'updating');

      expect(state1, state2);
      expect(state1, isNot(state3));
    });

    test('WatchPartyJoined supports Equatable', () {
      const state1 = WatchPartyJoined(
        watchPartyId: 'wp_1',
        attendanceType: WatchPartyAttendanceType.inPerson,
      );
      const state2 = WatchPartyJoined(
        watchPartyId: 'wp_1',
        attendanceType: WatchPartyAttendanceType.inPerson,
      );

      expect(state1, state2);
    });

    test('WatchPartyStatusChanged supports Equatable', () {
      const state1 = WatchPartyStatusChanged(
        watchPartyId: 'wp_1',
        newStatus: WatchPartyStatus.live,
      );
      const state2 = WatchPartyStatusChanged(
        watchPartyId: 'wp_1',
        newStatus: WatchPartyStatus.ended,
      );

      expect(state1, isNot(state2));
    });

    test('MemberActionCompleted supports Equatable', () {
      const state1 = MemberActionCompleted(
        action: 'muted',
        memberId: 'user_2',
      );
      const state2 = MemberActionCompleted(
        action: 'muted',
        memberId: 'user_2',
      );

      expect(state1, state2);
    });
  });

  // ==================== BLoC close / resource cleanup ====================

  group('Resource cleanup', () {
    test('close cancels message subscription', () async {
      when(() => mockService.getMessagesStream('wp_1'))
          .thenAnswer((_) => const Stream<List<WatchPartyMessage>>.empty());

      bloc.add(const SubscribeToMessagesEvent('wp_1'));
      await Future.delayed(const Duration(milliseconds: 50));

      // Should not throw on close
      await bloc.close();
    });

    test('close works even without active subscription', () async {
      // Just closing without subscribing should work fine
      await bloc.close();
    });
  });
}
