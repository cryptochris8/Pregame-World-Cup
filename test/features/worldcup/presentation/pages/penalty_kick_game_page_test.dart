import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/pages/penalty_kick_game_page.dart';

void main() {
  Widget buildSubject({
    String? homeTeamName,
    String? awayTeamName,
  }) {
    return MaterialApp(
      home: PenaltyKickGamePage(
        homeTeamName: homeTeamName,
        awayTeamName: awayTeamName,
      ),
    );
  }

  group('PenaltyKickGamePage', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.byType(PenaltyKickGamePage), findsOneWidget);
    });

    testWidgets('displays page title', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Penalty Kick Challenge'), findsOneWidget);
    });

    testWidgets('displays game title', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Pregame Challenge'), findsOneWidget);
    });

    testWidgets('displays game description', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(
        find.text('Test your skills before the match! Can you beat the goalkeeper?'),
        findsOneWidget,
      );
    });

    testWidgets('displays Play Now button', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Play Now'), findsOneWidget);
    });

    testWidgets('displays soccer ball icon', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.byIcon(Icons.sports_soccer), findsOneWidget);
    });

    testWidgets('displays How to Play section', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('How to Play'), findsOneWidget);
    });

    testWidgets('displays how-to-play steps', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Aim by dragging on the screen'), findsOneWidget);
      expect(find.text('Swipe to kick the ball'), findsOneWidget);
      expect(find.text('Score as many goals as you can!'), findsOneWidget);
    });

    testWidgets('shows match context when team names are provided', (tester) async {
      await tester.pumpWidget(buildSubject(
        homeTeamName: 'Brazil',
        awayTeamName: 'Germany',
      ));
      expect(find.text('Brazil vs Germany'), findsOneWidget);
    });

    testWidgets('does not show match context when team names are null', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.byIcon(Icons.sports), findsNothing);
    });

    testWidgets('shows match context with sports icon', (tester) async {
      await tester.pumpWidget(buildSubject(
        homeTeamName: 'Argentina',
        awayTeamName: 'France',
      ));
      expect(find.byIcon(Icons.sports), findsOneWidget);
    });

    testWidgets('back button pops navigation', (tester) async {
      // Wrap in a navigator to test pop behavior
      bool didPop = false;
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PenaltyKickGamePage(),
                ),
              );
            },
            child: const Text('Go'),
          ),
        ),
      ));

      // Navigate to the game page
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.byType(PenaltyKickGamePage), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should be back on the original page
      expect(find.byType(PenaltyKickGamePage), findsNothing);
      expect(find.text('Go'), findsOneWidget);
    });

    testWidgets('has gradient background decoration', (tester) async {
      await tester.pumpWidget(buildSubject());

      // Find the outer Container with gradient decoration
      final containers = tester.widgetList<Container>(find.byType(Container));
      final hasGradient = containers.any((c) {
        if (c.decoration is BoxDecoration) {
          return (c.decoration as BoxDecoration).gradient != null;
        }
        return false;
      });
      expect(hasGradient, isTrue);
    });

    testWidgets('displays play arrow icon in button', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    });

    test('gameUrl is a valid URL', () {
      final uri = Uri.tryParse(PenaltyKickGamePage.gameUrl);
      expect(uri, isNotNull);
      expect(uri!.scheme, equals('https'));
    });
  });
}
