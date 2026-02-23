import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/chatbot/domain/entities/chat_intent.dart';
import 'package:pregame_world_cup/features/chatbot/domain/entities/chat_message.dart';
import 'package:pregame_world_cup/features/chatbot/domain/entities/chat_response.dart';
import 'package:pregame_world_cup/features/chatbot/domain/services/chatbot_service.dart';
import 'package:pregame_world_cup/features/chatbot/presentation/bloc/chatbot_cubit.dart';

// Mock ChatbotService — needs to be a real mock because cubit calls methods on it
class MockChatbotService extends Mock implements ChatbotService {}

void main() {
  late MockChatbotService mockService;
  late ChatbotCubit cubit;

  setUp(() {
    mockService = MockChatbotService();
    // Default stubs
    when(() => mockService.initialize()).thenAnswer((_) async {});
    when(() => mockService.clearHistory()).thenReturn(null);
    when(() => mockService.isInitialized).thenReturn(true);

    cubit = ChatbotCubit(chatbotService: mockService);
  });

  tearDown(() {
    cubit.close();
  });

  group('Initial state', () {
    test('starts with ChatbotInitial', () {
      expect(cubit.state, isA<ChatbotInitial>());
    });
  });

  group('initialize', () {
    test('emits ChatbotLoaded with welcome message', () async {
      await cubit.initialize();
      expect(cubit.state, isA<ChatbotLoaded>());

      final state = cubit.state as ChatbotLoaded;
      expect(state.messages, hasLength(1));
      expect(state.messages.first.type, ChatMessageType.bot);
      expect(state.messages.first.text, ChatbotService.welcomeMessage);
    });

    test('welcome message includes suggestion chips', () async {
      await cubit.initialize();
      final state = cubit.state as ChatbotLoaded;
      expect(state.currentSuggestions, isNotEmpty);
      expect(state.currentSuggestions, ChatbotService.welcomeSuggestions);
      expect(state.messages.first.suggestionChips, isNotEmpty);
    });

    test('triggers knowledge base preload', () async {
      await cubit.initialize();
      // Give async preload a moment to fire
      await Future.delayed(Duration.zero);
      verify(() => mockService.initialize()).called(1);
    });
  });

  group('sendMessage', () {
    test('ignores empty messages', () async {
      await cubit.initialize();
      await cubit.sendMessage('   ');
      final state = cubit.state as ChatbotLoaded;
      // Should still only have the welcome message
      expect(state.messages, hasLength(1));
    });

    test('adds user message immediately', () async {
      when(() => mockService.getResponse(any())).thenAnswer(
        (_) async => const ChatResponse(
          text: 'Bot reply',
          suggestionChips: ['Chip 1'],
          resolvedIntent: ChatIntent(type: ChatIntentType.greeting),
        ),
      );

      await cubit.initialize();

      // Start the send but don't await — check intermediate state
      final future = cubit.sendMessage('Hello');

      // We need to wait for the loading state to be emitted
      await Future.delayed(Duration.zero);

      // Now complete the future
      await future;

      final state = cubit.state as ChatbotLoaded;
      // Should have: bot reply, user message, welcome message (newest first)
      expect(state.messages, hasLength(3));
      expect(state.messages[2].type, ChatMessageType.bot); // welcome
      expect(state.messages[1].type, ChatMessageType.user); // "Hello"
      expect(state.messages[0].type, ChatMessageType.bot); // "Bot reply"
    });

    test('adds bot response with suggestion chips', () async {
      when(() => mockService.getResponse(any())).thenAnswer(
        (_) async => const ChatResponse(
          text: 'Here is the schedule',
          suggestionChips: ['USA squad', 'Group B'],
          resolvedIntent: ChatIntent(type: ChatIntentType.schedule),
        ),
      );

      await cubit.initialize();
      await cubit.sendMessage('USA schedule');

      final state = cubit.state as ChatbotLoaded;
      expect(state.messages.first.text, 'Here is the schedule');
      expect(state.messages.first.suggestionChips, ['USA squad', 'Group B']);
      expect(state.currentSuggestions, ['USA squad', 'Group B']);
    });

    test('handles errors gracefully', () async {
      when(() => mockService.getResponse(any())).thenThrow(Exception('Network error'));

      await cubit.initialize();
      await cubit.sendMessage('Hello');

      final state = cubit.state as ChatbotLoaded;
      // Should have error message as bot reply
      expect(state.messages.first.type, ChatMessageType.bot);
      expect(state.messages.first.text, contains('trouble'));
    });

    test('trims whitespace from messages', () async {
      when(() => mockService.getResponse('test')).thenAnswer(
        (_) async => const ChatResponse(
          text: 'Response',
          resolvedIntent: ChatIntent(type: ChatIntentType.unknown),
        ),
      );

      await cubit.initialize();
      await cubit.sendMessage('  test  ');

      verify(() => mockService.getResponse('test')).called(1);
    });
  });

  group('clearChat', () {
    test('resets to welcome message', () async {
      when(() => mockService.getResponse(any())).thenAnswer(
        (_) async => const ChatResponse(
          text: 'Reply',
          resolvedIntent: ChatIntent(type: ChatIntentType.greeting),
        ),
      );

      await cubit.initialize();
      await cubit.sendMessage('Hello');

      cubit.clearChat();

      final state = cubit.state as ChatbotLoaded;
      expect(state.messages, hasLength(1));
      expect(state.messages.first.text, ChatbotService.welcomeMessage);
      expect(state.currentSuggestions, ChatbotService.welcomeSuggestions);
    });

    test('clears service history', () async {
      await cubit.initialize();
      cubit.clearChat();

      verify(() => mockService.clearHistory()).called(1);
    });
  });

  group('State properties', () {
    test('ChatbotLoaded copyWith works', () {
      const state = ChatbotLoaded(
        messages: [],
        currentSuggestions: ['A'],
      );
      final copied = state.copyWith(currentSuggestions: ['B', 'C']);
      expect(copied.messages, isEmpty);
      expect(copied.currentSuggestions, ['B', 'C']);
    });

    test('ChatbotLoaded props include suggestions', () {
      const state1 = ChatbotLoaded(
        messages: [],
        currentSuggestions: ['A'],
      );
      const state2 = ChatbotLoaded(
        messages: [],
        currentSuggestions: ['B'],
      );
      expect(state1.props, isNot(equals(state2.props)));
    });

    test('ChatbotError preserves previous messages', () {
      final msg = ChatMessage(text: 'test', type: ChatMessageType.user);
      final state = ChatbotError(
        message: 'Error',
        previousMessages: [msg],
      );
      expect(state.previousMessages, hasLength(1));
    });
  });

  group('Multiple messages', () {
    test('builds conversation history in correct order', () async {
      var callCount = 0;
      when(() => mockService.getResponse(any())).thenAnswer((_) async {
        callCount++;
        return ChatResponse(
          text: 'Reply $callCount',
          resolvedIntent: const ChatIntent(type: ChatIntentType.unknown),
        );
      });

      await cubit.initialize();
      await cubit.sendMessage('First');
      await cubit.sendMessage('Second');

      final state = cubit.state as ChatbotLoaded;
      // Order (newest first): Reply 2, "Second", Reply 1, "First", Welcome
      expect(state.messages, hasLength(5));
      expect(state.messages[0].text, 'Reply 2');
      expect(state.messages[1].text, 'Second');
      expect(state.messages[2].text, 'Reply 1');
      expect(state.messages[3].text, 'First');
      expect(state.messages[4].text, ChatbotService.welcomeMessage);
    });
  });
}
