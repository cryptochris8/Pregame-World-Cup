import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/widgets/widgets.dart';

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

  group('TeamFlag', () {
    testWidgets('renders with team code when no flag URL', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TeamFlag(
              teamCode: 'USA',
              size: 40,
            ),
          ),
        ),
      );

      // Placeholder shows first 2 characters of team code
      expect(find.text('US'), findsOneWidget);
    });

    testWidgets('renders with custom size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TeamFlag(
              teamCode: 'BRA',
              size: 60,
            ),
          ),
        ),
      );

      expect(find.byType(TeamFlag), findsOneWidget);
    });

    testWidgets('renders for null team code', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TeamFlag(
              teamCode: null,
              size: 40,
            ),
          ),
        ),
      );

      expect(find.byType(TeamFlag), findsOneWidget);
    });
  });

  group('TeamVsRow', () {
    testWidgets('renders both team flags', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: TeamVsRow(
                homeTeamCode: 'USA',
                homeTeamName: 'United States',
                awayTeamCode: 'MEX',
                awayTeamName: 'Mexico',
              ),
            ),
          ),
        ),
      );

      expect(find.text('United States'), findsOneWidget);
      expect(find.text('Mexico'), findsOneWidget);
    });

    testWidgets('renders score when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: TeamVsRow(
                homeTeamCode: 'USA',
                homeTeamName: 'United States',
                awayTeamCode: 'MEX',
                awayTeamName: 'Mexico',
                homeScore: 2,
                awayScore: 1,
              ),
            ),
          ),
        ),
      );

      expect(find.text('2 - 1'), findsOneWidget);
    });

    testWidgets('renders TeamVsRow widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: TeamVsRow(
                homeTeamCode: 'USA',
                homeTeamName: 'United States',
                awayTeamCode: 'MEX',
                awayTeamName: 'Mexico',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TeamVsRow), findsOneWidget);
    });
  });
}
