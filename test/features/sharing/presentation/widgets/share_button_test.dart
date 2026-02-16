import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/sharing/domain/entities/shareable_content.dart';
import 'package:pregame_world_cup/features/sharing/presentation/widgets/share_button.dart';

void main() {
  ShareableInvite createTestContent() {
    return const ShareableInvite(
      inviterName: 'Chris',
      referralCode: 'ABC123',
      deepLink: 'https://pregameworldcup.com/invite',
    );
  }

  Widget wrapWithMaterialApp(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('ShareButton', () {
    group('default constructor', () {
      testWidgets('renders share icon button by default', (tester) async {
        await tester.pumpWidget(wrapWithMaterialApp(
          ShareButton(content: createTestContent()),
        ));

        expect(find.byIcon(Icons.share), findsOneWidget);
        // No label text rendered when showLabel is false
        expect(find.text('Share'), findsNothing);
      });

      testWidgets('renders label when showLabel is true', (tester) async {
        await tester.pumpWidget(wrapWithMaterialApp(
          ShareButton(content: createTestContent(), showLabel: true),
        ));

        expect(find.text('Share'), findsOneWidget);
        expect(find.byIcon(Icons.share), findsOneWidget);
      });

      testWidgets('renders compact icon button when compact is true', (tester) async {
        await tester.pumpWidget(wrapWithMaterialApp(
          ShareButton(content: createTestContent(), compact: true),
        ));

        expect(find.byIcon(Icons.share), findsOneWidget);
      });

      testWidgets('renders custom child when provided', (tester) async {
        await tester.pumpWidget(wrapWithMaterialApp(
          ShareButton(
            content: createTestContent(),
            child: const Text('Custom Share'),
          ),
        ));

        expect(find.text('Custom Share'), findsOneWidget);
      });

      testWidgets('has correct widget type for icon button', (tester) async {
        await tester.pumpWidget(wrapWithMaterialApp(
          ShareButton(content: createTestContent()),
        ));

        // Default (no showLabel, no compact) renders an IconButton
        expect(find.byType(IconButton), findsOneWidget);
      });
    });

    group('prediction factory', () {
      testWidgets('creates share button for prediction', (tester) async {
        await tester.pumpWidget(wrapWithMaterialApp(
          ShareButton.prediction(
            matchId: 'match-1',
            homeTeam: 'USA',
            awayTeam: 'Mexico',
            predictedHomeScore: 2,
            predictedAwayScore: 1,
            predictedWinner: 'USA',
            confidence: 75,
            userName: 'Chris',
          ),
        ));

        expect(find.byIcon(Icons.share), findsOneWidget);
      });

      testWidgets('prediction button with showLabel renders text', (tester) async {
        await tester.pumpWidget(wrapWithMaterialApp(
          ShareButton.prediction(
            matchId: 'match-1',
            homeTeam: 'USA',
            awayTeam: 'Mexico',
            predictedHomeScore: 2,
            predictedAwayScore: 1,
            showLabel: true,
          ),
        ));

        expect(find.text('Share'), findsOneWidget);
      });
    });

    group('matchResult factory', () {
      testWidgets('creates share button for match result', (tester) async {
        await tester.pumpWidget(wrapWithMaterialApp(
          ShareButton.matchResult(
            matchId: 'match-1',
            homeTeam: 'USA',
            awayTeam: 'Mexico',
            homeScore: 2,
            awayScore: 1,
            stage: 'Group A',
          ),
        ));

        expect(find.byIcon(Icons.share), findsOneWidget);
      });

      testWidgets('creates live match result button', (tester) async {
        await tester.pumpWidget(wrapWithMaterialApp(
          ShareButton.matchResult(
            matchId: 'match-1',
            homeTeam: 'USA',
            awayTeam: 'Mexico',
            homeScore: 1,
            awayScore: 0,
            isLive: true,
            matchMinute: '65',
          ),
        ));

        expect(find.byIcon(Icons.share), findsOneWidget);
      });
    });

    group('watchParty factory', () {
      testWidgets('creates share button for watch party', (tester) async {
        await tester.pumpWidget(wrapWithMaterialApp(
          ShareButton.watchParty(
            partyId: 'party-1',
            partyName: 'Big Game Watch',
            matchName: 'USA vs England',
            partyTime: DateTime(2026, 6, 20, 19, 0),
            venueName: 'Sports Bar',
            venueAddress: '123 Main St',
            currentAttendees: 15,
            maxAttendees: 50,
            hostName: 'Chris',
          ),
        ));

        expect(find.byIcon(Icons.share), findsOneWidget);
      });
    });

    group('invite factory', () {
      testWidgets('creates share button for invite with label by default', (tester) async {
        await tester.pumpWidget(wrapWithMaterialApp(
          ShareButton.invite(
            userId: 'user-1',
            userName: 'Chris',
            referralCode: 'ABC123',
          ),
        ));

        // invite factory defaults to showLabel: true
        expect(find.text('Share'), findsOneWidget);
        expect(find.byIcon(Icons.share), findsOneWidget);
      });

      testWidgets('creates invite button without label', (tester) async {
        await tester.pumpWidget(wrapWithMaterialApp(
          ShareButton.invite(
            userId: 'user-1',
            userName: 'Chris',
            showLabel: false,
          ),
        ));

        expect(find.byIcon(Icons.share), findsOneWidget);
        expect(find.text('Share'), findsNothing);
      });
    });
  });

  group('InlineShareButton', () {
    testWidgets('renders share icon with default size', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(
        InlineShareButton(content: createTestContent()),
      ));

      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('renders with custom icon color', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(
        InlineShareButton(
          content: createTestContent(),
          iconColor: Colors.red,
        ),
      ));

      final icon = tester.widget<IconButton>(find.byType(IconButton));
      expect(icon.color, Colors.red);
    });

    testWidgets('renders with custom icon size', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(
        InlineShareButton(
          content: createTestContent(),
          iconSize: 32,
        ),
      ));

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.size, 32);
    });

    testWidgets('has share tooltip', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(
        InlineShareButton(content: createTestContent()),
      ));

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.tooltip, 'Share');
    });
  });
}
