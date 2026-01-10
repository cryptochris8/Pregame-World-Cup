import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/social/presentation/widgets/friend_item_widget.dart';

import '../../mock_factories.dart';

void main() {
  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.toString().contains('overflowed') ||
          details.toString().contains('HTTP')) {
        return;
      }
      FlutterError.presentError(details);
    };
  });

  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: 400,
            child: child,
          ),
        ),
      ),
    );
  }

  group('FriendItemWidget', () {
    testWidgets('renders friend display name', (tester) async {
      final friend = SocialTestFactory.createUserProfile(
        displayName: 'John Doe',
      );

      await tester.pumpWidget(
        buildTestWidget(FriendItemWidget(
          friend: friend,
          onTap: () {},
          onMessage: () {},
          onRemove: () {},
          onBlock: () {},
        )),
      );

      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('renders friend bio when present', (tester) async {
      final friend = SocialTestFactory.createUserProfile(
        bio: 'Soccer fan from NYC',
      );

      await tester.pumpWidget(
        buildTestWidget(FriendItemWidget(
          friend: friend,
          onTap: () {},
          onMessage: () {},
          onRemove: () {},
          onBlock: () {},
        )),
      );

      expect(find.text('Soccer fan from NYC'), findsOneWidget);
    });

    testWidgets('renders location when present', (tester) async {
      final friend = SocialTestFactory.createUserProfile(
        homeLocation: 'New York, NY',
      );

      await tester.pumpWidget(
        buildTestWidget(FriendItemWidget(
          friend: friend,
          onTap: () {},
          onMessage: () {},
          onRemove: () {},
          onBlock: () {},
        )),
      );

      expect(find.text('New York, NY'), findsOneWidget);
    });

    testWidgets('renders avatar with initial', (tester) async {
      final friend = SocialTestFactory.createUserProfile(
        displayName: 'Alice Smith',
        profileImageUrl: null,
      );

      await tester.pumpWidget(
        buildTestWidget(FriendItemWidget(
          friend: friend,
          onTap: () {},
          onMessage: () {},
          onRemove: () {},
          onBlock: () {},
        )),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('shows message button', (tester) async {
      final friend = SocialTestFactory.createUserProfile();

      await tester.pumpWidget(
        buildTestWidget(FriendItemWidget(
          friend: friend,
          onTap: () {},
          onMessage: () {},
          onRemove: () {},
          onBlock: () {},
        )),
      );

      expect(find.byIcon(Icons.message), findsOneWidget);
    });

    testWidgets('shows more options menu', (tester) async {
      final friend = SocialTestFactory.createUserProfile();

      await tester.pumpWidget(
        buildTestWidget(FriendItemWidget(
          friend: friend,
          onTap: () {},
          onMessage: () {},
          onRemove: () {},
          onBlock: () {},
        )),
      );

      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('calls onTap when card tapped', (tester) async {
      final friend = SocialTestFactory.createUserProfile();
      bool tapped = false;

      await tester.pumpWidget(
        buildTestWidget(FriendItemWidget(
          friend: friend,
          onTap: () => tapped = true,
          onMessage: () {},
          onRemove: () {},
          onBlock: () {},
        )),
      );

      await tester.tap(find.byType(FriendItemWidget));
      expect(tapped, isTrue);
    });

    testWidgets('calls onMessage when message button pressed', (tester) async {
      final friend = SocialTestFactory.createUserProfile();
      bool messageCalled = false;

      await tester.pumpWidget(
        buildTestWidget(FriendItemWidget(
          friend: friend,
          onTap: () {},
          onMessage: () => messageCalled = true,
          onRemove: () {},
          onBlock: () {},
        )),
      );

      await tester.tap(find.byIcon(Icons.message));
      expect(messageCalled, isTrue);
    });

    testWidgets('shows favorite teams as chips', (tester) async {
      final friend = SocialTestFactory.createUserProfile(
        favoriteTeams: ['USA', 'Manchester United'],
      );

      await tester.pumpWidget(
        buildTestWidget(FriendItemWidget(
          friend: friend,
          onTap: () {},
          onMessage: () {},
          onRemove: () {},
          onBlock: () {},
        )),
      );

      expect(find.text('USA'), findsOneWidget);
      expect(find.text('Manchester United'), findsOneWidget);
    });

    testWidgets('limits displayed teams to 3', (tester) async {
      final friend = SocialTestFactory.createUserProfile(
        favoriteTeams: ['USA', 'Brazil', 'Germany', 'France', 'Spain'],
      );

      await tester.pumpWidget(
        buildTestWidget(FriendItemWidget(
          friend: friend,
          onTap: () {},
          onMessage: () {},
          onRemove: () {},
          onBlock: () {},
        )),
      );

      expect(find.text('USA'), findsOneWidget);
      expect(find.text('Brazil'), findsOneWidget);
      expect(find.text('Germany'), findsOneWidget);
      expect(find.text('France'), findsNothing);
      expect(find.text('Spain'), findsNothing);
    });

    testWidgets('opens popup menu when more button pressed', (tester) async {
      final friend = SocialTestFactory.createUserProfile();

      await tester.pumpWidget(
        buildTestWidget(FriendItemWidget(
          friend: friend,
          onTap: () {},
          onMessage: () {},
          onRemove: () {},
          onBlock: () {},
        )),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Remove Friend'), findsOneWidget);
      expect(find.text('Block User'), findsOneWidget);
    });

    testWidgets('calls onRemove when remove selected from menu', (tester) async {
      final friend = SocialTestFactory.createUserProfile();
      bool removeCalled = false;

      await tester.pumpWidget(
        buildTestWidget(FriendItemWidget(
          friend: friend,
          onTap: () {},
          onMessage: () {},
          onRemove: () => removeCalled = true,
          onBlock: () {},
        )),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove Friend'));

      expect(removeCalled, isTrue);
    });

    testWidgets('calls onBlock when block selected from menu', (tester) async {
      final friend = SocialTestFactory.createUserProfile();
      bool blockCalled = false;

      await tester.pumpWidget(
        buildTestWidget(FriendItemWidget(
          friend: friend,
          onTap: () {},
          onMessage: () {},
          onRemove: () {},
          onBlock: () => blockCalled = true,
        )),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Block User'));

      expect(blockCalled, isTrue);
    });

    testWidgets('shows online status when enabled', (tester) async {
      final friend = SocialTestFactory.createUserProfile(
        isOnline: true,
        privacySettings: SocialTestFactory.createPrivacySettings(
          showOnlineStatus: true,
        ),
      );

      await tester.pumpWidget(
        buildTestWidget(FriendItemWidget(
          friend: friend,
          onTap: () {},
          onMessage: () {},
          onRemove: () {},
          onBlock: () {},
        )),
      );

      expect(find.text('Online'), findsOneWidget);
    });

    testWidgets('shows last seen when offline', (tester) async {
      final friend = SocialTestFactory.createUserProfile(
        isOnline: false,
        lastSeenAt: DateTime.now().subtract(const Duration(hours: 2)),
        privacySettings: SocialTestFactory.createPrivacySettings(
          showOnlineStatus: true,
        ),
      );

      await tester.pumpWidget(
        buildTestWidget(FriendItemWidget(
          friend: friend,
          onTap: () {},
          onMessage: () {},
          onRemove: () {},
          onBlock: () {},
        )),
      );

      expect(find.text('2h ago'), findsOneWidget);
    });

    testWidgets('hides online status when privacy disabled', (tester) async {
      final friend = SocialTestFactory.createUserProfile(
        isOnline: true,
        privacySettings: SocialTestFactory.createPrivacySettings(
          showOnlineStatus: false,
        ),
      );

      await tester.pumpWidget(
        buildTestWidget(FriendItemWidget(
          friend: friend,
          onTap: () {},
          onMessage: () {},
          onRemove: () {},
          onBlock: () {},
        )),
      );

      expect(find.text('Online'), findsNothing);
    });

    testWidgets('shows question mark for empty display name', (tester) async {
      final friend = SocialTestFactory.createUserProfile(
        displayName: '',
        profileImageUrl: null,
      );

      await tester.pumpWidget(
        buildTestWidget(FriendItemWidget(
          friend: friend,
          onTap: () {},
          onMessage: () {},
          onRemove: () {},
          onBlock: () {},
        )),
      );

      expect(find.text('?'), findsOneWidget);
    });
  });
}
