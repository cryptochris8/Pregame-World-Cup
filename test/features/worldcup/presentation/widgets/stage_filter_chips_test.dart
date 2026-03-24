import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';

void main() {
  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      final exception = details.exception;
      final isOverflowError = exception is FlutterError &&
          !exception.diagnostics.any(
            (e) => e.value.toString().contains('A RenderFlex overflowed by'),
          );
      if (isOverflowError) {
      } else {
        FlutterError.presentError(details);
      }
    };
  });

  Widget buildWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('StageFilterChips', () {
    testWidgets('renders All Stages chip', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          StageFilterChips(
            selectedStage: null,
            onStageChanged: (_) {},
          ),
        ),
      );

      expect(find.text('All Stages'), findsOneWidget);
    });

    testWidgets('renders chips for each MatchStage', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          StageFilterChips(
            selectedStage: null,
            onStageChanged: (_) {},
          ),
        ),
      );

      // Verify all stage chips are rendered
      expect(find.text('Group Stage'), findsOneWidget);
      expect(find.text('Round of 32'), findsOneWidget);
      expect(find.text('Round of 16'), findsOneWidget);
      expect(find.text('Quarter-Finals'), findsOneWidget);
      expect(find.text('Semi-Finals'), findsOneWidget);
      expect(find.text('3rd Place'), findsOneWidget);
      expect(find.text('Final'), findsOneWidget);
    });

    testWidgets('All Stages chip is selected when selectedStage is null', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          StageFilterChips(
            selectedStage: null,
            onStageChanged: (_) {},
          ),
        ),
      );

      final allStagesChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('All Stages'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(allStagesChip.selected, isTrue);
    });

    testWidgets('Group Stage chip is selected when selectedStage is groupStage', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          StageFilterChips(
            selectedStage: MatchStage.groupStage,
            onStageChanged: (_) {},
          ),
        ),
      );

      final groupStageChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('Group Stage'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(groupStageChip.selected, isTrue);
    });

    testWidgets('Round of 16 chip is selected when selectedStage is roundOf16', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          StageFilterChips(
            selectedStage: MatchStage.roundOf16,
            onStageChanged: (_) {},
          ),
        ),
      );

      final roundOf16Chip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('Round of 16'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(roundOf16Chip.selected, isTrue);
    });

    testWidgets('Final chip is selected when selectedStage is final_', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          StageFilterChips(
            selectedStage: MatchStage.final_,
            onStageChanged: (_) {},
          ),
        ),
      );

      final finalChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('Final'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(finalChip.selected, isTrue);
    });

    testWidgets('tapping All Stages chip calls callback with null', (tester) async {
      MatchStage? capturedStage = MatchStage.groupStage; // Start with non-null

      await tester.pumpWidget(
        buildWidget(
          StageFilterChips(
            selectedStage: MatchStage.groupStage,
            onStageChanged: (stage) {
              capturedStage = stage;
            },
          ),
        ),
      );

      await tester.tap(find.text('All Stages'));
      await tester.pumpAndSettle();

      expect(capturedStage, isNull);
    });

    testWidgets('tapping Group Stage chip calls callback with groupStage', (tester) async {
      MatchStage? capturedStage;

      await tester.pumpWidget(
        buildWidget(
          StageFilterChips(
            selectedStage: null,
            onStageChanged: (stage) {
              capturedStage = stage;
            },
          ),
        ),
      );

      await tester.tap(find.text('Group Stage'));
      await tester.pumpAndSettle();

      expect(capturedStage, MatchStage.groupStage);
    });

    testWidgets('tapping Round of 32 chip calls callback with roundOf32', (tester) async {
      MatchStage? capturedStage;

      await tester.pumpWidget(
        buildWidget(
          StageFilterChips(
            selectedStage: null,
            onStageChanged: (stage) {
              capturedStage = stage;
            },
          ),
        ),
      );

      await tester.tap(find.text('Round of 32'));
      await tester.pumpAndSettle();

      expect(capturedStage, MatchStage.roundOf32);
    });

    testWidgets('tapping Round of 16 chip calls callback with roundOf16', (tester) async {
      MatchStage? capturedStage;

      await tester.pumpWidget(
        buildWidget(
          StageFilterChips(
            selectedStage: null,
            onStageChanged: (stage) {
              capturedStage = stage;
            },
          ),
        ),
      );

      await tester.tap(find.text('Round of 16'));
      await tester.pumpAndSettle();

      expect(capturedStage, MatchStage.roundOf16);
    });

    testWidgets('tapping Quarter-Finals chip calls callback with quarterFinal', (tester) async {
      MatchStage? capturedStage;

      await tester.pumpWidget(
        buildWidget(
          StageFilterChips(
            selectedStage: null,
            onStageChanged: (stage) {
              capturedStage = stage;
            },
          ),
        ),
      );

      await tester.dragUntilVisible(
        find.text('Quarter-Finals'),
        find.byType(SingleChildScrollView),
        const Offset(-100, 0),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Quarter-Finals'));
      await tester.pumpAndSettle();

      expect(capturedStage, MatchStage.quarterFinal);
    });

    testWidgets('tapping Semi-Finals chip calls callback with semiFinal', (tester) async {
      MatchStage? capturedStage;

      await tester.pumpWidget(
        buildWidget(
          StageFilterChips(
            selectedStage: null,
            onStageChanged: (stage) {
              capturedStage = stage;
            },
          ),
        ),
      );

      await tester.dragUntilVisible(
        find.text('Semi-Finals'),
        find.byType(SingleChildScrollView),
        const Offset(-100, 0),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Semi-Finals'));
      await tester.pumpAndSettle();

      expect(capturedStage, MatchStage.semiFinal);
    });

    testWidgets('tapping 3rd Place chip calls callback with thirdPlace', (tester) async {
      MatchStage? capturedStage;

      await tester.pumpWidget(
        buildWidget(
          StageFilterChips(
            selectedStage: null,
            onStageChanged: (stage) {
              capturedStage = stage;
            },
          ),
        ),
      );

      await tester.dragUntilVisible(
        find.text('3rd Place'),
        find.byType(SingleChildScrollView),
        const Offset(-100, 0),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('3rd Place'));
      await tester.pumpAndSettle();

      expect(capturedStage, MatchStage.thirdPlace);
    });

    testWidgets('tapping Final chip calls callback with final_', (tester) async {
      MatchStage? capturedStage;

      await tester.pumpWidget(
        buildWidget(
          StageFilterChips(
            selectedStage: null,
            onStageChanged: (stage) {
              capturedStage = stage;
            },
          ),
        ),
      );

      await tester.dragUntilVisible(
        find.text('Final'),
        find.byType(SingleChildScrollView),
        const Offset(-100, 0),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Final'));
      await tester.pumpAndSettle();

      expect(capturedStage, MatchStage.final_);
    });

    testWidgets('only selected chip is highlighted', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          StageFilterChips(
            selectedStage: MatchStage.quarterFinal,
            onStageChanged: (_) {},
          ),
        ),
      );

      // All Stages should not be selected
      final allStagesChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('All Stages'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(allStagesChip.selected, isFalse);

      // Group Stage should not be selected
      final groupStageChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('Group Stage'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(groupStageChip.selected, isFalse);

      // Quarter-Finals should be selected
      final quarterFinalChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('Quarter-Finals'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(quarterFinalChip.selected, isTrue);
    });

    testWidgets('renders in horizontal scrollable container', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          StageFilterChips(
            selectedStage: null,
            onStageChanged: (_) {},
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      final scrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(scrollView.scrollDirection, Axis.horizontal);
    });
  });
}
