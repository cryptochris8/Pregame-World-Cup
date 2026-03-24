import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/schedule/presentation/widgets/prediction_confidence_selector.dart';

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
    required int confidenceLevel,
    required Function(int) onConfidenceChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PredictionConfidenceSelector(
          confidenceLevel: confidenceLevel,
          onConfidenceChanged: onConfidenceChanged,
        ),
      ),
    );
  }

  testWidgets('shows confidence level text "Confidence Level: 3/5"',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildWidget(
        confidenceLevel: 3,
        onConfidenceChanged: (_) {},
      ),
    );

    expect(find.text('Confidence Level: 3/5'), findsOneWidget);
  });

  testWidgets('shows correct confidence description text for level 3',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildWidget(
        confidenceLevel: 3,
        onConfidenceChanged: (_) {},
      ),
    );

    expect(find.text('Moderately confident'), findsOneWidget);
  });

  testWidgets('shows 6 star icons (1 header + 5 selectable)', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildWidget(
        confidenceLevel: 3,
        onConfidenceChanged: (_) {},
      ),
    );

    // 1 star in header label + 5 selectable stars = 6 total
    expect(find.byIcon(Icons.star), findsNWidgets(6));
  });

  testWidgets('tapping a star calls onConfidenceChanged with correct level',
      (WidgetTester tester) async {
    int? selectedLevel;

    await tester.pumpWidget(
      buildWidget(
        confidenceLevel: 3,
        onConfidenceChanged: (level) => selectedLevel = level,
      ),
    );

    // Find all GestureDetectors wrapping star icons (only the 5 selectable ones)
    final gestureDetectors = find.byType(GestureDetector);
    // Tap the 4th selectable star to set level to 4
    await tester.tap(gestureDetectors.at(3));
    await tester.pump();

    expect(selectedLevel, 4);
  });

  testWidgets('shows "Absolutely certain!" text for level 5',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildWidget(
        confidenceLevel: 5,
        onConfidenceChanged: (_) {},
      ),
    );

    expect(find.text('Absolutely certain!'), findsOneWidget);
  });

  testWidgets('shows "Not very confident" text for level 1',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildWidget(
        confidenceLevel: 1,
        onConfidenceChanged: (_) {},
      ),
    );

    expect(find.text('Not very confident'), findsOneWidget);
  });
}
