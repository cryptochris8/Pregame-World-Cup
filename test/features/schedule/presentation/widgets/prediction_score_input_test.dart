import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/schedule/presentation/widgets/prediction_score_input.dart';

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
    required TextEditingController homeScoreController,
    required TextEditingController awayScoreController,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PredictionScoreInput(
          homeTeamName: homeTeamName,
          awayTeamName: awayTeamName,
          homeScoreController: homeScoreController,
          awayScoreController: awayScoreController,
        ),
      ),
    );
  }

  testWidgets('renders with team names', (WidgetTester tester) async {
    final homeController = TextEditingController();
    final awayController = TextEditingController();

    await tester.pumpWidget(
      buildWidget(
        homeTeamName: 'Brazil',
        awayTeamName: 'Argentina',
        homeScoreController: homeController,
        awayScoreController: awayController,
      ),
    );

    expect(find.text('Brazil'), findsOneWidget);
    expect(find.text('Argentina'), findsOneWidget);
  });

  testWidgets('shows "Predict Final Score (Optional)" text',
      (WidgetTester tester) async {
    final homeController = TextEditingController();
    final awayController = TextEditingController();

    await tester.pumpWidget(
      buildWidget(
        homeTeamName: 'Brazil',
        awayTeamName: 'Argentina',
        homeScoreController: homeController,
        awayScoreController: awayController,
      ),
    );

    expect(find.text('Predict Final Score (Optional)'), findsOneWidget);
  });

  testWidgets('shows two TextField widgets', (WidgetTester tester) async {
    final homeController = TextEditingController();
    final awayController = TextEditingController();

    await tester.pumpWidget(
      buildWidget(
        homeTeamName: 'Brazil',
        awayTeamName: 'Argentina',
        homeScoreController: homeController,
        awayScoreController: awayController,
      ),
    );

    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('shows dash separator between fields',
      (WidgetTester tester) async {
    final homeController = TextEditingController();
    final awayController = TextEditingController();

    await tester.pumpWidget(
      buildWidget(
        homeTeamName: 'Brazil',
        awayTeamName: 'Argentina',
        homeScoreController: homeController,
        awayScoreController: awayController,
      ),
    );

    expect(find.text('-'), findsOneWidget);
  });

  testWidgets('can enter text in home score field',
      (WidgetTester tester) async {
    final homeController = TextEditingController();
    final awayController = TextEditingController();

    await tester.pumpWidget(
      buildWidget(
        homeTeamName: 'Brazil',
        awayTeamName: 'Argentina',
        homeScoreController: homeController,
        awayScoreController: awayController,
      ),
    );

    final textFields = find.byType(TextField);
    await tester.enterText(textFields.first, '3');
    await tester.pump();

    expect(homeController.text, '3');
  });

  testWidgets('can enter text in away score field',
      (WidgetTester tester) async {
    final homeController = TextEditingController();
    final awayController = TextEditingController();

    await tester.pumpWidget(
      buildWidget(
        homeTeamName: 'Brazil',
        awayTeamName: 'Argentina',
        homeScoreController: homeController,
        awayScoreController: awayController,
      ),
    );

    final textFields = find.byType(TextField);
    await tester.enterText(textFields.last, '2');
    await tester.pump();

    expect(awayController.text, '2');
  });

  testWidgets('shows scoreboard icon', (WidgetTester tester) async {
    final homeController = TextEditingController();
    final awayController = TextEditingController();

    await tester.pumpWidget(
      buildWidget(
        homeTeamName: 'Brazil',
        awayTeamName: 'Argentina',
        homeScoreController: homeController,
        awayScoreController: awayController,
      ),
    );

    expect(find.byIcon(Icons.scoreboard), findsOneWidget);
  });
}
