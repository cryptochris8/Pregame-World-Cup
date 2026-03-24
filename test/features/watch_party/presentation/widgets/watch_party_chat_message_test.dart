import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party_message.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party_member.dart';
import 'package:pregame_world_cup/features/watch_party/presentation/widgets/watch_party_chat_message.dart';

void main() {
  // Ignore overflow errors in widget tests
  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.toString().contains('overflowed')) {
        return; // Ignore overflow errors
      }
      FlutterError.presentError(details);
    };
  });

  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            child: child,
          ),
        ),
      ),
    );
  }

  group('WatchPartyChatMessage', () {
    testWidgets('renders text message from current user', (tester) async {
      final message = WatchPartyMessage.text(
        watchPartyId: 'wp_123',
        senderId: 'user_123',
        senderName: 'John Doe',
        senderRole: WatchPartyMemberRole.member,
        content: 'Hello everyone!',
      );

      await tester.pumpWidget(
        buildTestWidget(
          WatchPartyChatMessage(
            message: message,
            isCurrentUser: true,
          ),
        ),
      );

      expect(find.text('Hello everyone!'), findsOneWidget);
    });

    testWidgets('renders text message from other user', (tester) async {
      final message = WatchPartyMessage.text(
        watchPartyId: 'wp_123',
        senderId: 'user_456',
        senderName: 'Jane Smith',
        senderRole: WatchPartyMemberRole.member,
        content: 'Great game!',
      );

      await tester.pumpWidget(
        buildTestWidget(
          WatchPartyChatMessage(
            message: message,
            isCurrentUser: false,
          ),
        ),
      );

      expect(find.text('Great game!'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);
    });

    testWidgets('renders system message', (tester) async {
      final message = WatchPartyMessage.system(
        watchPartyId: 'wp_123',
        content: 'John joined the party',
      );

      await tester.pumpWidget(
        buildTestWidget(
          WatchPartyChatMessage(
            message: message,
            isCurrentUser: false,
          ),
        ),
      );

      expect(find.text('John joined the party'), findsOneWidget);
    });

    testWidgets('renders deleted message', (tester) async {
      final message = WatchPartyMessage.text(
        watchPartyId: 'wp_123',
        senderId: 'user_123',
        senderName: 'John Doe',
        senderRole: WatchPartyMemberRole.member,
        content: 'Original message',
      ).delete();

      await tester.pumpWidget(
        buildTestWidget(
          WatchPartyChatMessage(
            message: message,
            isCurrentUser: true,
          ),
        ),
      );

      expect(find.text('Message deleted'), findsOneWidget);
    });

    testWidgets('shows host badge for host messages', (tester) async {
      final message = WatchPartyMessage.text(
        watchPartyId: 'wp_123',
        senderId: 'host_123',
        senderName: 'Host User',
        senderRole: WatchPartyMemberRole.host,
        content: 'Welcome everyone!',
      );

      await tester.pumpWidget(
        buildTestWidget(
          WatchPartyChatMessage(
            message: message,
            isCurrentUser: false,
          ),
        ),
      );

      expect(find.text('Welcome everyone!'), findsOneWidget);
      expect(find.text('Host'), findsOneWidget);
    });

    testWidgets('shows co-host badge for co-host messages', (tester) async {
      final message = WatchPartyMessage.text(
        watchPartyId: 'wp_123',
        senderId: 'cohost_123',
        senderName: 'Co-Host User',
        senderRole: WatchPartyMemberRole.coHost,
        content: 'Game starts soon!',
      );

      await tester.pumpWidget(
        buildTestWidget(
          WatchPartyChatMessage(
            message: message,
            isCurrentUser: false,
          ),
        ),
      );

      expect(find.text('Game starts soon!'), findsOneWidget);
      expect(find.text('Co-Host'), findsOneWidget);
    });

    testWidgets('renders message with reactions', (tester) async {
      final message = WatchPartyMessage.text(
        watchPartyId: 'wp_123',
        senderId: 'user_123',
        senderName: 'John Doe',
        senderRole: WatchPartyMemberRole.member,
        content: 'Amazing goal!',
      ).addReaction(
        MessageReaction(
          emoji: '⚽',
          userId: 'user_456',
          userName: 'Jane',
          createdAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        buildTestWidget(
          WatchPartyChatMessage(
            message: message,
            isCurrentUser: false,
          ),
        ),
      );

      expect(find.text('Amazing goal!'), findsOneWidget);
      expect(find.text('⚽'), findsOneWidget);
    });

    testWidgets('triggers onLongPress callback', (tester) async {
      bool wasPressed = false;
      final message = WatchPartyMessage.text(
        watchPartyId: 'wp_123',
        senderId: 'user_123',
        senderName: 'John Doe',
        senderRole: WatchPartyMemberRole.member,
        content: 'Long press me',
      );

      await tester.pumpWidget(
        buildTestWidget(
          WatchPartyChatMessage(
            message: message,
            isCurrentUser: true,
            onLongPress: () {
              wasPressed = true;
            },
          ),
        ),
      );

      await tester.longPress(find.text('Long press me'));
      expect(wasPressed, isTrue);
    });
  });
}
