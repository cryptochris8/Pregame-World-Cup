import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/match_chat/match_chat.dart';

// ==================== MOCKS ====================

class MockMatchChatService extends Mock implements MatchChatService {}

// ==================== TEST DATA HELPERS ====================

class MatchChatTestData {
  static final DateTime testMatchDateTime = DateTime(2026, 6, 15, 18, 0);
  static final DateTime testCreatedAt = DateTime(2026, 6, 15, 17, 0);

  static MatchChat createChat({
    String chatId = 'chat_1',
    String matchId = 'match_1',
    String matchName = 'USA vs Mexico',
    String homeTeam = 'USA',
    String awayTeam = 'MEX',
    DateTime? matchDateTime,
    int participantCount = 42,
    int messageCount = 100,
    bool isActive = true,
    DateTime? createdAt,
    MatchChatSettings settings = const MatchChatSettings(),
  }) {
    return MatchChat(
      chatId: chatId,
      matchId: matchId,
      matchName: matchName,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      matchDateTime: matchDateTime ?? testMatchDateTime,
      participantCount: participantCount,
      messageCount: messageCount,
      isActive: isActive,
      createdAt: createdAt ?? testCreatedAt,
      settings: settings,
    );
  }

  static MatchChatMessage createMessage({
    String messageId = 'msg_1',
    String chatId = 'chat_1',
    String senderId = 'user_1',
    String senderName = 'Test User',
    String content = 'Hello World Cup!',
    MatchChatMessageType type = MatchChatMessageType.text,
    DateTime? sentAt,
    bool isDeleted = false,
    Map<String, List<String>> reactions = const {},
  }) {
    return MatchChatMessage(
      messageId: messageId,
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      type: type,
      sentAt: sentAt ?? DateTime(2026, 6, 15, 18, 30),
      isDeleted: isDeleted,
      reactions: reactions,
    );
  }

  static List<MatchChatMessage> createMessageList({int count = 5}) {
    return List.generate(
      count,
      (i) => createMessage(
        messageId: 'msg_$i',
        senderId: 'user_${i % 3}',
        senderName: 'User ${i % 3}',
        content: 'Message $i',
        sentAt: DateTime(2026, 6, 15, 18, 30 + i),
      ),
    );
  }
}

// ==================== TESTS ====================

void main() {
  late MockMatchChatService mockChatService;
  late MatchChatCubit cubit;

  setUp(() {
    mockChatService = MockMatchChatService();
    cubit = MatchChatCubit(chatService: mockChatService);
  });

  tearDown(() {
    cubit.close();
  });

  group('MatchChatCubit', () {
    final testChat = MatchChatTestData.createChat();
    final testMessages = MatchChatTestData.createMessageList();

    // ----------------------------------------------------------
    // 1. Initial state
    // ----------------------------------------------------------
    test('initial state is MatchChatInitial', () {
      expect(cubit.state, isA<MatchChatInitial>());
    });

    // ----------------------------------------------------------
    // 2. initializeChat emits Loading then Loaded
    // ----------------------------------------------------------
    blocTest<MatchChatCubit, MatchChatState>(
      'initializeChat emits Loading then Loaded',
      build: () {
        when(() => mockChatService.getOrCreateMatchChat(
              matchId: any(named: 'matchId'),
              matchName: any(named: 'matchName'),
              homeTeam: any(named: 'homeTeam'),
              awayTeam: any(named: 'awayTeam'),
              matchDateTime: any(named: 'matchDateTime'),
            )).thenAnswer((_) async => testChat);
        when(() => mockChatService.isUserInChat(any()))
            .thenAnswer((_) async => false);
        when(() => mockChatService.getMessagesStream(any()))
            .thenAnswer((_) => const Stream.empty());
        when(() => mockChatService.getParticipantCountStream(any()))
            .thenAnswer((_) => const Stream.empty());
        return cubit;
      },
      act: (cubit) => cubit.initializeChat(
        matchId: 'match_1',
        matchName: 'USA vs Mexico',
        homeTeam: 'USA',
        awayTeam: 'MEX',
        matchDateTime: MatchChatTestData.testMatchDateTime,
      ),
      expect: () => [
        isA<MatchChatLoading>(),
        isA<MatchChatLoaded>()
            .having((s) => s.chat, 'chat', testChat)
            .having((s) => s.isJoined, 'isJoined', false),
      ],
      verify: (_) {
        verify(() => mockChatService.getOrCreateMatchChat(
              matchId: 'match_1',
              matchName: 'USA vs Mexico',
              homeTeam: 'USA',
              awayTeam: 'MEX',
              matchDateTime: MatchChatTestData.testMatchDateTime,
            )).called(1);
        verify(() => mockChatService.isUserInChat('chat_1')).called(1);
        verify(() => mockChatService.getMessagesStream('chat_1')).called(1);
        verify(() => mockChatService.getParticipantCountStream('chat_1'))
            .called(1);
      },
    );

    // ----------------------------------------------------------
    // 3. initializeChat emits Error when service returns null
    // ----------------------------------------------------------
    blocTest<MatchChatCubit, MatchChatState>(
      'initializeChat emits Error when service returns null',
      build: () {
        when(() => mockChatService.getOrCreateMatchChat(
              matchId: any(named: 'matchId'),
              matchName: any(named: 'matchName'),
              homeTeam: any(named: 'homeTeam'),
              awayTeam: any(named: 'awayTeam'),
              matchDateTime: any(named: 'matchDateTime'),
            )).thenAnswer((_) async => null);
        return cubit;
      },
      act: (cubit) => cubit.initializeChat(
        matchId: 'match_1',
        matchName: 'USA vs Mexico',
        homeTeam: 'USA',
        awayTeam: 'MEX',
        matchDateTime: MatchChatTestData.testMatchDateTime,
      ),
      expect: () => [
        isA<MatchChatLoading>(),
        isA<MatchChatError>()
            .having((s) => s.message, 'message', 'Failed to initialize chat'),
      ],
    );

    // ----------------------------------------------------------
    // 4. initializeChat handles exceptions
    // ----------------------------------------------------------
    blocTest<MatchChatCubit, MatchChatState>(
      'initializeChat handles exceptions',
      build: () {
        when(() => mockChatService.getOrCreateMatchChat(
              matchId: any(named: 'matchId'),
              matchName: any(named: 'matchName'),
              homeTeam: any(named: 'homeTeam'),
              awayTeam: any(named: 'awayTeam'),
              matchDateTime: any(named: 'matchDateTime'),
            )).thenThrow(Exception('Network error'));
        return cubit;
      },
      act: (cubit) => cubit.initializeChat(
        matchId: 'match_1',
        matchName: 'USA vs Mexico',
        homeTeam: 'USA',
        awayTeam: 'MEX',
        matchDateTime: MatchChatTestData.testMatchDateTime,
      ),
      expect: () => [
        isA<MatchChatLoading>(),
        isA<MatchChatError>()
            .having((s) => s.message, 'message', contains('Network error')),
      ],
    );

    // ----------------------------------------------------------
    // 5. loadChat emits Loading then Loaded with existing chat
    // ----------------------------------------------------------
    blocTest<MatchChatCubit, MatchChatState>(
      'loadChat emits Loading then Loaded with existing chat',
      build: () {
        when(() => mockChatService.getMatchChat(any()))
            .thenAnswer((_) async => testChat);
        when(() => mockChatService.isUserInChat(any()))
            .thenAnswer((_) async => true);
        when(() => mockChatService.getMessagesStream(any()))
            .thenAnswer((_) => const Stream.empty());
        when(() => mockChatService.getParticipantCountStream(any()))
            .thenAnswer((_) => const Stream.empty());
        return cubit;
      },
      act: (cubit) => cubit.loadChat('chat_1'),
      expect: () => [
        isA<MatchChatLoading>(),
        isA<MatchChatLoaded>()
            .having((s) => s.chat, 'chat', testChat)
            .having((s) => s.isJoined, 'isJoined', true),
      ],
      verify: (_) {
        verify(() => mockChatService.getMatchChat('chat_1')).called(1);
        verify(() => mockChatService.isUserInChat('chat_1')).called(1);
      },
    );

    // ----------------------------------------------------------
    // 6. loadChat emits Error when chat not found
    // ----------------------------------------------------------
    blocTest<MatchChatCubit, MatchChatState>(
      'loadChat emits Error when chat not found',
      build: () {
        when(() => mockChatService.getMatchChat(any()))
            .thenAnswer((_) async => null);
        return cubit;
      },
      act: (cubit) => cubit.loadChat('nonexistent'),
      expect: () => [
        isA<MatchChatLoading>(),
        isA<MatchChatError>()
            .having((s) => s.message, 'message', 'Chat not found'),
      ],
    );

    // ----------------------------------------------------------
    // 7. joinChat transitions to Joined state
    // ----------------------------------------------------------
    blocTest<MatchChatCubit, MatchChatState>(
      'joinChat transitions to Joined state',
      build: () {
        when(() => mockChatService.joinMatchChat(any()))
            .thenAnswer((_) async => true);
        return cubit;
      },
      seed: () => MatchChatLoaded(chat: testChat, isJoined: false),
      act: (cubit) => cubit.joinChat(),
      expect: () => [
        isA<MatchChatJoining>(),
        isA<MatchChatLoaded>()
            .having((s) => s.isJoined, 'isJoined', true)
            .having((s) => s.chat, 'chat', testChat),
      ],
      verify: (_) {
        verify(() => mockChatService.joinMatchChat('chat_1')).called(1);
      },
    );

    // ----------------------------------------------------------
    // 8. joinChat handles failure
    // ----------------------------------------------------------
    blocTest<MatchChatCubit, MatchChatState>(
      'joinChat handles failure',
      build: () {
        when(() => mockChatService.joinMatchChat(any()))
            .thenAnswer((_) async => false);
        return cubit;
      },
      seed: () => MatchChatLoaded(chat: testChat, isJoined: false),
      act: (cubit) => cubit.joinChat(),
      expect: () => [
        isA<MatchChatJoining>(),
        isA<MatchChatLoaded>()
            .having((s) => s.isJoined, 'isJoined', false)
            .having(
                (s) => s.sendError, 'sendError', 'Failed to join chat'),
      ],
    );

    // ----------------------------------------------------------
    // 9. joinChat does nothing if not in Loaded state
    // ----------------------------------------------------------
    blocTest<MatchChatCubit, MatchChatState>(
      'joinChat does nothing if not in Loaded state',
      build: () => cubit,
      // Default initial state is MatchChatInitial
      act: (cubit) => cubit.joinChat(),
      expect: () => <MatchChatState>[],
    );

    // ----------------------------------------------------------
    // 10. leaveChat sets isJoined to false
    // ----------------------------------------------------------
    blocTest<MatchChatCubit, MatchChatState>(
      'leaveChat sets isJoined to false',
      build: () {
        when(() => mockChatService.leaveMatchChat(any()))
            .thenAnswer((_) async => true);
        return cubit;
      },
      seed: () => MatchChatLoaded(chat: testChat, isJoined: true),
      act: (cubit) => cubit.leaveChat(),
      expect: () => [
        isA<MatchChatLoaded>()
            .having((s) => s.isJoined, 'isJoined', false),
      ],
      verify: (_) {
        verify(() => mockChatService.leaveMatchChat('chat_1')).called(1);
      },
    );

    // ----------------------------------------------------------
    // 11. sendMessage succeeds with no error
    // ----------------------------------------------------------
    blocTest<MatchChatCubit, MatchChatState>(
      'sendMessage succeeds with no error',
      build: () {
        when(() => mockChatService.sendMessage(
              chatId: any(named: 'chatId'),
              content: any(named: 'content'),
            )).thenAnswer((_) async => SendMessageResult.success());
        return cubit;
      },
      // Seed with a prior sendError so clearing it produces a new state emission
      seed: () => MatchChatLoaded(
        chat: testChat,
        isJoined: true,
        sendError: 'previous error',
      ),
      act: (cubit) => cubit.sendMessage('Go USA!'),
      expect: () => [
        isA<MatchChatLoaded>()
            .having((s) => s.sendError, 'sendError', isNull),
      ],
      verify: (_) {
        verify(() => mockChatService.sendMessage(
              chatId: 'chat_1',
              content: 'Go USA!',
            )).called(1);
      },
    );

    // ----------------------------------------------------------
    // 12. sendMessage does nothing if not joined
    // ----------------------------------------------------------
    blocTest<MatchChatCubit, MatchChatState>(
      'sendMessage does nothing if not joined',
      build: () => cubit,
      seed: () => MatchChatLoaded(chat: testChat, isJoined: false),
      act: (cubit) => cubit.sendMessage('Hello!'),
      expect: () => <MatchChatState>[],
    );

    // ----------------------------------------------------------
    // 13. sendMessage does nothing if content is empty
    // ----------------------------------------------------------
    blocTest<MatchChatCubit, MatchChatState>(
      'sendMessage does nothing if content is empty',
      build: () => cubit,
      seed: () => MatchChatLoaded(chat: testChat, isJoined: true),
      act: (cubit) => cubit.sendMessage(''),
      expect: () => <MatchChatState>[],
    );

    blocTest<MatchChatCubit, MatchChatState>(
      'sendMessage does nothing if content is whitespace only',
      build: () => cubit,
      seed: () => MatchChatLoaded(chat: testChat, isJoined: true),
      act: (cubit) => cubit.sendMessage('   '),
      expect: () => <MatchChatState>[],
    );

    // ----------------------------------------------------------
    // 14. sendMessage handles rate limiting (sets rateLimitSeconds)
    // ----------------------------------------------------------
    blocTest<MatchChatCubit, MatchChatState>(
      'sendMessage handles rate limiting',
      build: () {
        when(() => mockChatService.sendMessage(
              chatId: any(named: 'chatId'),
              content: any(named: 'content'),
            )).thenAnswer(
                (_) async => SendMessageResult.rateLimited(5));
        return cubit;
      },
      seed: () => MatchChatLoaded(chat: testChat, isJoined: true),
      act: (cubit) => cubit.sendMessage('Too fast!'),
      expect: () => [
        isA<MatchChatLoaded>()
            .having((s) => s.rateLimitSeconds, 'rateLimitSeconds', 5)
            .having((s) => s.sendError, 'sendError', 'Please wait 5 seconds'),
      ],
    );

    // ----------------------------------------------------------
    // 15. sendMessage handles other errors
    // ----------------------------------------------------------
    blocTest<MatchChatCubit, MatchChatState>(
      'sendMessage handles other errors',
      build: () {
        when(() => mockChatService.sendMessage(
              chatId: any(named: 'chatId'),
              content: any(named: 'content'),
            )).thenAnswer(
                (_) async => SendMessageResult.error('Something went wrong'));
        return cubit;
      },
      seed: () => MatchChatLoaded(chat: testChat, isJoined: true),
      act: (cubit) => cubit.sendMessage('Oops'),
      expect: () => [
        isA<MatchChatLoaded>()
            .having(
                (s) => s.sendError, 'sendError', 'Something went wrong')
            .having((s) => s.rateLimitSeconds, 'rateLimitSeconds', 0),
      ],
    );

    blocTest<MatchChatCubit, MatchChatState>(
      'sendMessage handles blocked content',
      build: () {
        when(() => mockChatService.sendMessage(
              chatId: any(named: 'chatId'),
              content: any(named: 'content'),
            )).thenAnswer(
                (_) async => SendMessageResult.blocked('Content violation'));
        return cubit;
      },
      seed: () => MatchChatLoaded(chat: testChat, isJoined: true),
      act: (cubit) => cubit.sendMessage('bad content'),
      expect: () => [
        isA<MatchChatLoaded>()
            .having(
                (s) => s.sendError, 'sendError', 'Content violation'),
      ],
    );

    blocTest<MatchChatCubit, MatchChatState>(
      'sendMessage does nothing if not in Loaded state',
      build: () => cubit,
      // Default initial state is MatchChatInitial
      act: (cubit) => cubit.sendMessage('Hello'),
      expect: () => <MatchChatState>[],
    );

    // ----------------------------------------------------------
    // 16. sendQuickReaction calls service
    // ----------------------------------------------------------
    blocTest<MatchChatCubit, MatchChatState>(
      'sendQuickReaction calls service when joined',
      build: () {
        when(() => mockChatService.sendQuickReaction(any(), any()))
            .thenAnswer((_) async => true);
        return cubit;
      },
      seed: () => MatchChatLoaded(chat: testChat, isJoined: true),
      act: (cubit) => cubit.sendQuickReaction('goal emoji'),
      verify: (_) {
        verify(() => mockChatService.sendQuickReaction('chat_1', 'goal emoji'))
            .called(1);
      },
    );

    blocTest<MatchChatCubit, MatchChatState>(
      'sendQuickReaction does nothing if not joined',
      build: () => cubit,
      seed: () => MatchChatLoaded(chat: testChat, isJoined: false),
      act: (cubit) => cubit.sendQuickReaction('emoji'),
      verify: (_) {
        verifyNever(() => mockChatService.sendQuickReaction(any(), any()));
      },
    );

    blocTest<MatchChatCubit, MatchChatState>(
      'sendQuickReaction does nothing if not in Loaded state',
      build: () => cubit,
      act: (cubit) => cubit.sendQuickReaction('emoji'),
      verify: (_) {
        verifyNever(() => mockChatService.sendQuickReaction(any(), any()));
      },
    );

    // ----------------------------------------------------------
    // 17. toggleReaction calls service
    // ----------------------------------------------------------
    blocTest<MatchChatCubit, MatchChatState>(
      'toggleReaction calls service when in Loaded state',
      build: () {
        when(() => mockChatService.toggleMessageReaction(any(), any(), any()))
            .thenAnswer((_) async => true);
        return cubit;
      },
      seed: () => MatchChatLoaded(chat: testChat),
      act: (cubit) => cubit.toggleReaction('msg_1', 'thumbsup'),
      verify: (_) {
        verify(() => mockChatService.toggleMessageReaction(
              'chat_1',
              'msg_1',
              'thumbsup',
            )).called(1);
      },
    );

    blocTest<MatchChatCubit, MatchChatState>(
      'toggleReaction does nothing if not in Loaded state',
      build: () => cubit,
      act: (cubit) => cubit.toggleReaction('msg_1', 'thumbsup'),
      verify: (_) {
        verifyNever(
            () => mockChatService.toggleMessageReaction(any(), any(), any()));
      },
    );

    // ----------------------------------------------------------
    // 18. deleteMessage calls service
    // ----------------------------------------------------------
    blocTest<MatchChatCubit, MatchChatState>(
      'deleteMessage calls service when in Loaded state',
      build: () {
        when(() => mockChatService.deleteMessage(any(), any()))
            .thenAnswer((_) async => true);
        return cubit;
      },
      seed: () => MatchChatLoaded(chat: testChat),
      act: (cubit) => cubit.deleteMessage('msg_1'),
      verify: (_) {
        verify(() => mockChatService.deleteMessage('chat_1', 'msg_1'))
            .called(1);
      },
    );

    blocTest<MatchChatCubit, MatchChatState>(
      'deleteMessage does nothing if not in Loaded state',
      build: () => cubit,
      act: (cubit) => cubit.deleteMessage('msg_1'),
      verify: (_) {
        verifyNever(() => mockChatService.deleteMessage(any(), any()));
      },
    );

    // ----------------------------------------------------------
    // 19. clearError clears sendError
    // ----------------------------------------------------------
    blocTest<MatchChatCubit, MatchChatState>(
      'clearError clears sendError',
      build: () => cubit,
      seed: () => MatchChatLoaded(
        chat: testChat,
        sendError: 'Some error',
      ),
      act: (cubit) => cubit.clearError(),
      expect: () => [
        isA<MatchChatLoaded>()
            .having((s) => s.sendError, 'sendError', isNull),
      ],
    );

    blocTest<MatchChatCubit, MatchChatState>(
      'clearError does nothing if not in Loaded state',
      build: () => cubit,
      act: (cubit) => cubit.clearError(),
      expect: () => <MatchChatState>[],
    );

    // ----------------------------------------------------------
    // 20. Messages stream updates messages in Loaded state
    // ----------------------------------------------------------
    blocTest<MatchChatCubit, MatchChatState>(
      'messages stream updates messages in Loaded state',
      build: () {
        final messagesController =
            StreamController<List<MatchChatMessage>>.broadcast();

        when(() => mockChatService.getOrCreateMatchChat(
              matchId: any(named: 'matchId'),
              matchName: any(named: 'matchName'),
              homeTeam: any(named: 'homeTeam'),
              awayTeam: any(named: 'awayTeam'),
              matchDateTime: any(named: 'matchDateTime'),
            )).thenAnswer((_) async => testChat);
        when(() => mockChatService.isUserInChat(any()))
            .thenAnswer((_) async => false);
        when(() => mockChatService.getMessagesStream(any()))
            .thenAnswer((_) => messagesController.stream);
        when(() => mockChatService.getParticipantCountStream(any()))
            .thenAnswer((_) => const Stream.empty());

        // Schedule adding messages after initializeChat completes
        return MatchChatCubit(chatService: mockChatService);
      },
      act: (cubit) async {
        await cubit.initializeChat(
          matchId: 'match_1',
          matchName: 'USA vs Mexico',
          homeTeam: 'USA',
          awayTeam: 'MEX',
          matchDateTime: MatchChatTestData.testMatchDateTime,
        );
        // The messages stream is wired up inside initializeChat.
        // We need to get the controller that was returned by getMessagesStream
        // Since we can't easily access it, let's use a different approach:
        // We use a StreamController in the build closure and add to it here.
      },
      expect: () => [
        isA<MatchChatLoading>(),
        isA<MatchChatLoaded>()
            .having((s) => s.messages, 'messages', isEmpty),
      ],
    );

    test('messages stream updates messages after initialization', () async {
      final messagesController =
          StreamController<List<MatchChatMessage>>.broadcast();

      when(() => mockChatService.getOrCreateMatchChat(
            matchId: any(named: 'matchId'),
            matchName: any(named: 'matchName'),
            homeTeam: any(named: 'homeTeam'),
            awayTeam: any(named: 'awayTeam'),
            matchDateTime: any(named: 'matchDateTime'),
          )).thenAnswer((_) async => testChat);
      when(() => mockChatService.isUserInChat(any()))
          .thenAnswer((_) async => false);
      when(() => mockChatService.getMessagesStream(any()))
          .thenAnswer((_) => messagesController.stream);
      when(() => mockChatService.getParticipantCountStream(any()))
          .thenAnswer((_) => const Stream.empty());

      await cubit.initializeChat(
        matchId: 'match_1',
        matchName: 'USA vs Mexico',
        homeTeam: 'USA',
        awayTeam: 'MEX',
        matchDateTime: MatchChatTestData.testMatchDateTime,
      );

      // Cubit should be in Loaded state now
      expect(cubit.state, isA<MatchChatLoaded>());
      expect((cubit.state as MatchChatLoaded).messages, isEmpty);

      // Push messages through the stream
      messagesController.add(testMessages);

      // Wait for the stream event to propagate
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<MatchChatLoaded>());
      final loadedState = cubit.state as MatchChatLoaded;
      expect(loadedState.messages, testMessages);
      expect(loadedState.messages.length, 5);

      await messagesController.close();
    });

    test('messages stream updates with new messages over time', () async {
      final messagesController =
          StreamController<List<MatchChatMessage>>.broadcast();

      when(() => mockChatService.getOrCreateMatchChat(
            matchId: any(named: 'matchId'),
            matchName: any(named: 'matchName'),
            homeTeam: any(named: 'homeTeam'),
            awayTeam: any(named: 'awayTeam'),
            matchDateTime: any(named: 'matchDateTime'),
          )).thenAnswer((_) async => testChat);
      when(() => mockChatService.isUserInChat(any()))
          .thenAnswer((_) async => false);
      when(() => mockChatService.getMessagesStream(any()))
          .thenAnswer((_) => messagesController.stream);
      when(() => mockChatService.getParticipantCountStream(any()))
          .thenAnswer((_) => const Stream.empty());

      await cubit.initializeChat(
        matchId: 'match_1',
        matchName: 'USA vs Mexico',
        homeTeam: 'USA',
        awayTeam: 'MEX',
        matchDateTime: MatchChatTestData.testMatchDateTime,
      );

      // First batch of messages
      final firstBatch = [MatchChatTestData.createMessage(messageId: 'msg_a')];
      messagesController.add(firstBatch);
      await Future<void>.delayed(Duration.zero);

      expect((cubit.state as MatchChatLoaded).messages.length, 1);

      // Second batch with additional messages
      final secondBatch = [
        MatchChatTestData.createMessage(messageId: 'msg_a'),
        MatchChatTestData.createMessage(messageId: 'msg_b'),
        MatchChatTestData.createMessage(messageId: 'msg_c'),
      ];
      messagesController.add(secondBatch);
      await Future<void>.delayed(Duration.zero);

      expect((cubit.state as MatchChatLoaded).messages.length, 3);

      await messagesController.close();
    });

    // ----------------------------------------------------------
    // 21. Participant count stream updates count in Loaded state
    // ----------------------------------------------------------
    test('participant count stream updates count in Loaded state', () async {
      final participantCountController = StreamController<int>.broadcast();

      when(() => mockChatService.getOrCreateMatchChat(
            matchId: any(named: 'matchId'),
            matchName: any(named: 'matchName'),
            homeTeam: any(named: 'homeTeam'),
            awayTeam: any(named: 'awayTeam'),
            matchDateTime: any(named: 'matchDateTime'),
          )).thenAnswer((_) async => testChat);
      when(() => mockChatService.isUserInChat(any()))
          .thenAnswer((_) async => false);
      when(() => mockChatService.getMessagesStream(any()))
          .thenAnswer((_) => const Stream.empty());
      when(() => mockChatService.getParticipantCountStream(any()))
          .thenAnswer((_) => participantCountController.stream);

      await cubit.initializeChat(
        matchId: 'match_1',
        matchName: 'USA vs Mexico',
        homeTeam: 'USA',
        awayTeam: 'MEX',
        matchDateTime: MatchChatTestData.testMatchDateTime,
      );

      expect(cubit.state, isA<MatchChatLoaded>());
      expect((cubit.state as MatchChatLoaded).participantCount, 0);

      // Push a participant count update
      participantCountController.add(150);
      await Future<void>.delayed(Duration.zero);

      expect((cubit.state as MatchChatLoaded).participantCount, 150);

      // Push another update
      participantCountController.add(155);
      await Future<void>.delayed(Duration.zero);

      expect((cubit.state as MatchChatLoaded).participantCount, 155);

      await participantCountController.close();
    });

    // ----------------------------------------------------------
    // Additional edge case tests
    // ----------------------------------------------------------

    blocTest<MatchChatCubit, MatchChatState>(
      'leaveChat does nothing if not in Loaded state',
      build: () => cubit,
      act: (cubit) => cubit.leaveChat(),
      expect: () => <MatchChatState>[],
    );

    blocTest<MatchChatCubit, MatchChatState>(
      'sendMessage trims content before sending',
      build: () {
        when(() => mockChatService.sendMessage(
              chatId: any(named: 'chatId'),
              content: any(named: 'content'),
            )).thenAnswer((_) async => SendMessageResult.success());
        return cubit;
      },
      seed: () => MatchChatLoaded(chat: testChat, isJoined: true),
      act: (cubit) => cubit.sendMessage('  Hello!  '),
      verify: (_) {
        verify(() => mockChatService.sendMessage(
              chatId: 'chat_1',
              content: 'Hello!',
            )).called(1);
      },
    );

    blocTest<MatchChatCubit, MatchChatState>(
      'loadChat handles exceptions',
      build: () {
        when(() => mockChatService.getMatchChat(any()))
            .thenThrow(Exception('Firebase error'));
        return cubit;
      },
      act: (cubit) => cubit.loadChat('chat_1'),
      expect: () => [
        isA<MatchChatLoading>(),
        isA<MatchChatError>()
            .having((s) => s.message, 'message', contains('Firebase error')),
      ],
    );

    blocTest<MatchChatCubit, MatchChatState>(
      'initializeChat shows isJoined true when user is already in chat',
      build: () {
        when(() => mockChatService.getOrCreateMatchChat(
              matchId: any(named: 'matchId'),
              matchName: any(named: 'matchName'),
              homeTeam: any(named: 'homeTeam'),
              awayTeam: any(named: 'awayTeam'),
              matchDateTime: any(named: 'matchDateTime'),
            )).thenAnswer((_) async => testChat);
        when(() => mockChatService.isUserInChat(any()))
            .thenAnswer((_) async => true);
        when(() => mockChatService.getMessagesStream(any()))
            .thenAnswer((_) => const Stream.empty());
        when(() => mockChatService.getParticipantCountStream(any()))
            .thenAnswer((_) => const Stream.empty());
        return cubit;
      },
      act: (cubit) => cubit.initializeChat(
        matchId: 'match_1',
        matchName: 'USA vs Mexico',
        homeTeam: 'USA',
        awayTeam: 'MEX',
        matchDateTime: MatchChatTestData.testMatchDateTime,
      ),
      expect: () => [
        isA<MatchChatLoading>(),
        isA<MatchChatLoaded>()
            .having((s) => s.isJoined, 'isJoined', true),
      ],
    );

    blocTest<MatchChatCubit, MatchChatState>(
      'sendMessage handles not authenticated result',
      build: () {
        when(() => mockChatService.sendMessage(
              chatId: any(named: 'chatId'),
              content: any(named: 'content'),
            )).thenAnswer(
                (_) async => SendMessageResult.notAuthenticated());
        return cubit;
      },
      seed: () => MatchChatLoaded(chat: testChat, isJoined: true),
      act: (cubit) => cubit.sendMessage('Hello'),
      expect: () => [
        isA<MatchChatLoaded>()
            .having(
                (s) => s.sendError, 'sendError', 'Not authenticated'),
      ],
    );

    blocTest<MatchChatCubit, MatchChatState>(
      'sendMessage handles content too long result',
      build: () {
        when(() => mockChatService.sendMessage(
              chatId: any(named: 'chatId'),
              content: any(named: 'content'),
            )).thenAnswer(
                (_) async => SendMessageResult.contentTooLong(500));
        return cubit;
      },
      seed: () => MatchChatLoaded(chat: testChat, isJoined: true),
      act: (cubit) => cubit.sendMessage('Very long message'),
      expect: () => [
        isA<MatchChatLoaded>()
            .having(
                (s) => s.sendError, 'sendError', 'Message too long'),
      ],
    );
  });
}
