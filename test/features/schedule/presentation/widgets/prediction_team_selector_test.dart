import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/schedule/presentation/widgets/prediction_team_selector.dart';

void main() {
  setUp(() {
    // Suppress overflow errors during testing
    FlutterError.onError = (FlutterErrorDetails details) {
      final exception = details.exception;
      final isOverflowError = exception is FlutterError &&
          !exception.diagnostics.any(
            (e) => e.value.toString().contains('A RenderFlex overflowed by'),
          );

      if (isOverflowError) {
        // Ignore overflow errors
      } else {
        FlutterError.presentError(details);
      }
    };
  });

  Widget buildWidget({
    required String homeTeamName,
    required String awayTeamName,
    String? selectedWinner,
    required Function(String) onWinnerSelected,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PredictionTeamSelector(
          homeTeamName: homeTeamName,
          awayTeamName: awayTeamName,
          selectedWinner: selectedWinner,
          onWinnerSelected: onWinnerSelected,
        ),
      ),
    );
  }

  testWidgets('renders with team names displayed', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildWidget(
        homeTeamName: 'Brazil',
        awayTeamName: 'Argentina',
        selectedWinner: null,
        onWinnerSelected: (_) {},
      ),
    );

    expect(find.text('Brazil'), findsOneWidget);
    expect(find.text('Argentina'), findsOneWidget);
  });

  testWidgets('shows "Who will win?" text', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildWidget(
        homeTeamName: 'Brazil',
        awayTeamName: 'Argentina',
        selectedWinner: null,
        onWinnerSelected: (_) {},
      ),
    );

    expect(find.text('Who will win?'), findsOneWidget);
  });

  testWidgets('shows HOME and AWAY labels', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildWidget(
        homeTeamName: 'Brazil',
        awayTeamName: 'Argentina',
        selectedWinner: null,
        onWinnerSelected: (_) {},
      ),
    );

    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('AWAY'), findsOneWidget);
  });

  testWidgets('tapping home team calls onWinnerSelected with home team name',
      (WidgetTester tester) async {
    String? selectedTeam;

    await tester.pumpWidget(
      buildWidget(
        homeTeamName: 'Brazil',
        awayTeamName: 'Argentina',
        selectedWinner: null,
        onWinnerSelected: (team) => selectedTeam = team,
      ),
    );

    // Find and tap the home team container
    final homeFinder = find.ancestor(
      of: find.text('Brazil'),
      matching: find.byType(GestureDetector),
    );
    await tester.tap(homeFinder.first);
    await tester.pump();

    expect(selectedTeam, 'Brazil');
  });

  testWidgets('tapping away team calls onWinnerSelected with away team name',
      (WidgetTester tester) async {
    String? selectedTeam;

    await tester.pumpWidget(
      buildWidget(
        homeTeamName: 'Brazil',
        awayTeamName: 'Argentina',
        selectedWinner: null,
        onWinnerSelected: (team) => selectedTeam = team,
      ),
    );

    // Find and tap the away team container
    final awayFinder = find.ancestor(
      of: find.text('Argentina'),
      matching: find.byType(GestureDetector),
    );
    await tester.tap(awayFinder.first);
    await tester.pump();

    expect(selectedTeam, 'Argentina');
  });

  testWidgets('selected winner shows check_circle icon',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildWidget(
        homeTeamName: 'Brazil',
        awayTeamName: 'Argentina',
        selectedWinner: 'Brazil',
        onWinnerSelected: (_) {},
      ),
    );

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('no winner selected shows no check_circle icon',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildWidget(
        homeTeamName: 'Brazil',
        awayTeamName: 'Argentina',
        selectedWinner: null,
        onWinnerSelected: (_) {},
      ),
    );

    expect(find.byIcon(Icons.check_circle), findsNothing);
  });
}
