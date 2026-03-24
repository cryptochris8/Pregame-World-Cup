import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/chatbot/presentation/screens/chat_screen.dart';

void main() {
  group('ChatScreen', () {
    test('is StatelessWidget', () {
      const screen = ChatScreen();
      expect(screen, isA<ChatScreen>());
    });

    test('construction', () {
      const screen = ChatScreen();
      expect(screen, isNotNull);
    });

    test('construction with isBottomSheet parameter', () {
      const screen = ChatScreen(isBottomSheet: true);
      expect(screen.isBottomSheet, isTrue);
    });

    test('construction with default isBottomSheet parameter', () {
      const screen = ChatScreen();
      expect(screen.isBottomSheet, isFalse);
    });

    test('runtimeType', () {
      const screen = ChatScreen();
      expect(screen.runtimeType, equals(ChatScreen));
    });
  });
}
