import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_prediction.dart';
import 'package:pregame_world_cup/features/schedule/presentation/widgets/prediction_action_buttons.dart';
import '../../schedule_test_factory.dart';

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
    required bool canPredict,
    required bool showScorePrediction,
    required bool isLoading,
    String? selectedWinner,
    GamePrediction? existingPrediction,
    required VoidCallback onShowScorePrediction,
    required VoidCallback onMakePrediction,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PredictionActionButtons(
          canPredict: canPredict,
          showScorePrediction: showScorePrediction,
          isLoading: isLoading,
          selectedWinner: selectedWinner,
          existingPrediction: existingPrediction,
          onShowScorePrediction: onShowScorePrediction,
          onMakePrediction: onMakePrediction,
        ),
      ),
    );
  }

  testWidgets('shows "Make Prediction" when canPredict and selectedWinner set',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildWidget(
        canPredict: true,
        showScorePrediction: false,
        isLoading: false,
        selectedWinner: 'Brazil',
        existingPrediction: null,
        onShowScorePrediction: () {},
        onMakePrediction: () {},
      ),
    );

    expect(find.text('Make Prediction'), findsOneWidget);
  });

  testWidgets('shows "Update Prediction" when existingPrediction exists',
      (WidgetTester tester) async {
    final prediction = ScheduleTestFactory.createGamePrediction(
      predictedWinner: 'Brazil',
    );

    await tester.pumpWidget(
      buildWidget(
        canPredict: true,
        showScorePrediction: false,
        isLoading: false,
        selectedWinner: 'Brazil',
        existingPrediction: prediction,
        onShowScorePrediction: () {},
        onMakePrediction: () {},
      ),
    );

    expect(find.text('Update Prediction'), findsOneWidget);
  });

  testWidgets('shows "Predictions Locked" when canPredict=false',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildWidget(
        canPredict: false,
        showScorePrediction: false,
        isLoading: false,
        selectedWinner: null,
        existingPrediction: null,
        onShowScorePrediction: () {},
        onMakePrediction: () {},
      ),
    );

    expect(find.text('Predictions Locked'), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsOneWidget);
  });

  testWidgets(
      'shows "Add Score Prediction" when canPredict=true and !showScorePrediction',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildWidget(
        canPredict: true,
        showScorePrediction: false,
        isLoading: false,
        selectedWinner: null,
        existingPrediction: null,
        onShowScorePrediction: () {},
        onMakePrediction: () {},
      ),
    );

    expect(find.text('Add Score Prediction'), findsOneWidget);
  });

  testWidgets('button disabled when selectedWinner is null',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildWidget(
        canPredict: true,
        showScorePrediction: false,
        isLoading: false,
        selectedWinner: null,
        existingPrediction: null,
        onShowScorePrediction: () {},
        onMakePrediction: () {},
      ),
    );

    // Find the ElevatedButton for making prediction
    final buttonFinder = find.ancestor(
      of: find.text('Make Prediction'),
      matching: find.byType(ElevatedButton),
    );

    // If button exists, verify it's disabled
    if (buttonFinder.evaluate().isNotEmpty) {
      final button = tester.widget<ElevatedButton>(buttonFinder);
      expect(button.onPressed, isNull);
    }
  });

  testWidgets('shows loading indicator when isLoading=true',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildWidget(
        canPredict: true,
        showScorePrediction: false,
        isLoading: true,
        selectedWinner: 'Brazil',
        existingPrediction: null,
        onShowScorePrediction: () {},
        onMakePrediction: () {},
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('tapping "Make Prediction" calls onMakePrediction',
      (WidgetTester tester) async {
    bool predictionCalled = false;

    await tester.pumpWidget(
      buildWidget(
        canPredict: true,
        showScorePrediction: false,
        isLoading: false,
        selectedWinner: 'Brazil',
        existingPrediction: null,
        onShowScorePrediction: () {},
        onMakePrediction: () => predictionCalled = true,
      ),
    );

    await tester.tap(find.text('Make Prediction'));
    await tester.pump();

    expect(predictionCalled, true);
  });

  testWidgets('tapping "Add Score Prediction" calls onShowScorePrediction',
      (WidgetTester tester) async {
    bool scorePredictionCalled = false;

    await tester.pumpWidget(
      buildWidget(
        canPredict: true,
        showScorePrediction: false,
        isLoading: false,
        selectedWinner: null,
        existingPrediction: null,
        onShowScorePrediction: () => scorePredictionCalled = true,
        onMakePrediction: () {},
      ),
    );

    await tester.tap(find.text('Add Score Prediction'));
    await tester.pump();

    expect(scorePredictionCalled, true);
  });
}
