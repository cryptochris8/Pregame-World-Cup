import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/widgets/penalty_kick_promo_card.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/pages/penalty_kick_game_page.dart';

void main() {
  Widget buildSubject({
    String? homeTeamName,
    String? awayTeamName,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PenaltyKickPromoCard(
          homeTeamName: homeTeamName,
          awayTeamName: awayTeamName,
        ),
      ),
    );
  }

  group('PenaltyKickPromoCard', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.byType(PenaltyKickPromoCard), findsOneWidget);
    });

    testWidgets('displays Pregame Challenge title', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Pregame Challenge'), findsOneWidget);
    });

    testWidgets('displays teaser text', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(
        find.text('Test your penalty kick skills before the match!'),
        findsOneWidget,
      );
    });

    testWidgets('displays Play button text', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Play'), findsOneWidget);
    });

    testWidgets('displays soccer icon', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.byIcon(Icons.sports_soccer), findsOneWidget);
    });

    testWidgets('navigates to PenaltyKickGamePage on tap', (tester) async {
      await tester.pumpWidget(buildSubject(
        homeTeamName: 'Mexico',
        awayTeamName: 'USA',
      ));

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      expect(find.byType(PenaltyKickGamePage), findsOneWidget);
    });

    testWidgets('passes team names to game page', (tester) async {
      await tester.pumpWidget(buildSubject(
        homeTeamName: 'Brazil',
        awayTeamName: 'Argentina',
      ));

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      // Verify the game page shows match context
      expect(find.text('Brazil vs Argentina'), findsOneWidget);
    });

    testWidgets('navigates without team names', (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      expect(find.byType(PenaltyKickGamePage), findsOneWidget);
    });

    testWidgets('has gradient background', (tester) async {
      await tester.pumpWidget(buildSubject());

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PenaltyKickPromoCard),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isNotNull);
      expect(decoration.gradient, isA<LinearGradient>());
    });

    testWidgets('has rounded border radius', (tester) async {
      await tester.pumpWidget(buildSubject());

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PenaltyKickPromoCard),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, equals(BorderRadius.circular(16)));
    });

    testWidgets('has box shadow', (tester) async {
      await tester.pumpWidget(buildSubject());

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PenaltyKickPromoCard),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, equals(1));
    });

    testWidgets('icon container has correct size', (tester) async {
      await tester.pumpWidget(buildSubject());

      final iconContainer = tester.widget<Container>(
        find.ancestor(
          of: find.byIcon(Icons.sports_soccer),
          matching: find.byType(Container),
        ).first,
      );

      expect(iconContainer.constraints?.maxWidth, equals(52));
      expect(iconContainer.constraints?.maxHeight, equals(52));
    });
  });
}
