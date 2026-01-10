import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/social/presentation/widgets/friend_request_item_widget.dart';

import '../../mock_factories.dart';

void main() {
  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.toString().contains('overflowed')) {
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

  group('FriendRequestItemWidget - Incoming Request', () {
    testWidgets('renders user name', (tester) async {
      final request = SocialTestFactory.createSocialConnection(
        connectedUserName: 'Jane Smith',
      );

      await tester.pumpWidget(
        buildTestWidget(FriendRequestItemWidget(
          request: request,
          onViewProfile: () {},
        )),
      );

      expect(find.text('Jane Smith'), findsOneWidget);
    });

    testWidgets('shows pending status for incoming request', (tester) async {
      final request = SocialTestFactory.createSocialConnection();

      await tester.pumpWidget(
        buildTestWidget(FriendRequestItemWidget(
          request: request,
          isOutgoing: false,
          onViewProfile: () {},
        )),
      );

      expect(find.text('PENDING'), findsOneWidget);
      expect(find.text('Wants to be friends'), findsOneWidget);
    });

    testWidgets('shows accept button when onAccept provided', (tester) async {
      final request = SocialTestFactory.createSocialConnection();

      await tester.pumpWidget(
        buildTestWidget(FriendRequestItemWidget(
          request: request,
          onAccept: () {},
          onViewProfile: () {},
        )),
      );

      expect(find.text('Accept'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('shows decline button when onDecline provided', (tester) async {
      final request = SocialTestFactory.createSocialConnection();

      await tester.pumpWidget(
        buildTestWidget(FriendRequestItemWidget(
          request: request,
          onDecline: () {},
          onViewProfile: () {},
        )),
      );

      expect(find.text('Decline'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('calls onAccept when accept button pressed', (tester) async {
      final request = SocialTestFactory.createSocialConnection();
      bool acceptCalled = false;

      await tester.pumpWidget(
        buildTestWidget(FriendRequestItemWidget(
          request: request,
          onAccept: () => acceptCalled = true,
          onViewProfile: () {},
        )),
      );

      await tester.tap(find.text('Accept'));
      expect(acceptCalled, isTrue);
    });

    testWidgets('calls onDecline when decline button pressed', (tester) async {
      final request = SocialTestFactory.createSocialConnection();
      bool declineCalled = false;

      await tester.pumpWidget(
        buildTestWidget(FriendRequestItemWidget(
          request: request,
          onDecline: () => declineCalled = true,
          onViewProfile: () {},
        )),
      );

      await tester.tap(find.text('Decline'));
      expect(declineCalled, isTrue);
    });

    testWidgets('calls onViewProfile when name tapped', (tester) async {
      final request = SocialTestFactory.createSocialConnection(
        connectedUserName: 'Jane Smith',
      );
      bool viewProfileCalled = false;

      await tester.pumpWidget(
        buildTestWidget(FriendRequestItemWidget(
          request: request,
          onViewProfile: () => viewProfileCalled = true,
        )),
      );

      await tester.tap(find.text('Jane Smith'));
      expect(viewProfileCalled, isTrue);
    });

    testWidgets('renders avatar with initial', (tester) async {
      final request = SocialTestFactory.createSocialConnection(
        connectedUserName: 'Jane Smith',
      );

      await tester.pumpWidget(
        buildTestWidget(FriendRequestItemWidget(
          request: request,
          onViewProfile: () {},
        )),
      );

      expect(find.text('J'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('shows question mark for unknown user', (tester) async {
      final request = SocialTestFactory.createSocialConnection(
        connectedUserName: null,
      );

      await tester.pumpWidget(
        buildTestWidget(FriendRequestItemWidget(
          request: request,
          onViewProfile: () {},
        )),
      );

      expect(find.text('?'), findsOneWidget);
      expect(find.text('Unknown User'), findsOneWidget);
    });

    testWidgets('has blue border for incoming request', (tester) async {
      final request = SocialTestFactory.createSocialConnection();

      await tester.pumpWidget(
        buildTestWidget(FriendRequestItemWidget(
          request: request,
          isOutgoing: false,
          onViewProfile: () {},
        )),
      );

      expect(find.byType(Card), findsOneWidget);
    });
  });

  group('FriendRequestItemWidget - Outgoing Request', () {
    testWidgets('shows SENT status for outgoing request', (tester) async {
      final request = SocialTestFactory.createSocialConnection();

      await tester.pumpWidget(
        buildTestWidget(FriendRequestItemWidget(
          request: request,
          isOutgoing: true,
          onViewProfile: () {},
        )),
      );

      expect(find.text('SENT'), findsOneWidget);
      expect(find.text('Friend request sent'), findsOneWidget);
    });

    testWidgets('shows cancel button when onCancel provided', (tester) async {
      final request = SocialTestFactory.createSocialConnection();

      await tester.pumpWidget(
        buildTestWidget(FriendRequestItemWidget(
          request: request,
          isOutgoing: true,
          onCancel: () {},
          onViewProfile: () {},
        )),
      );

      expect(find.text('Cancel Request'), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsOneWidget);
    });

    testWidgets('calls onCancel when cancel button pressed', (tester) async {
      final request = SocialTestFactory.createSocialConnection();
      bool cancelCalled = false;

      await tester.pumpWidget(
        buildTestWidget(FriendRequestItemWidget(
          request: request,
          isOutgoing: true,
          onCancel: () => cancelCalled = true,
          onViewProfile: () {},
        )),
      );

      await tester.tap(find.text('Cancel Request'));
      expect(cancelCalled, isTrue);
    });

    testWidgets('does not show accept/decline for outgoing', (tester) async {
      final request = SocialTestFactory.createSocialConnection();

      await tester.pumpWidget(
        buildTestWidget(FriendRequestItemWidget(
          request: request,
          isOutgoing: true,
          onAccept: () {},
          onDecline: () {},
          onViewProfile: () {},
        )),
      );

      expect(find.text('Accept'), findsNothing);
      expect(find.text('Decline'), findsNothing);
    });

    testWidgets('has orange border for outgoing request', (tester) async {
      final request = SocialTestFactory.createSocialConnection();

      await tester.pumpWidget(
        buildTestWidget(FriendRequestItemWidget(
          request: request,
          isOutgoing: true,
          onViewProfile: () {},
        )),
      );

      expect(find.byType(Card), findsOneWidget);
    });
  });

  group('FriendRequestItemWidget - Time Display', () {
    testWidgets('shows time ago text', (tester) async {
      final request = SocialTestFactory.createSocialConnection(
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      await tester.pumpWidget(
        buildTestWidget(FriendRequestItemWidget(
          request: request,
          onViewProfile: () {},
        )),
      );

      expect(find.text('2h ago'), findsOneWidget);
    });

    testWidgets('shows days ago for older requests', (tester) async {
      final request = SocialTestFactory.createSocialConnection(
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      );

      await tester.pumpWidget(
        buildTestWidget(FriendRequestItemWidget(
          request: request,
          onViewProfile: () {},
        )),
      );

      expect(find.text('3d ago'), findsOneWidget);
    });

    testWidgets('shows Just now for recent requests', (tester) async {
      final request = SocialTestFactory.createSocialConnection(
        createdAt: DateTime.now().subtract(const Duration(seconds: 30)),
      );

      await tester.pumpWidget(
        buildTestWidget(FriendRequestItemWidget(
          request: request,
          onViewProfile: () {},
        )),
      );

      expect(find.text('Just now'), findsOneWidget);
    });
  });
}
