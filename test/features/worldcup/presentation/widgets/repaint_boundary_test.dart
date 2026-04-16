import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/widgets/widgets.dart';

void main() {
  group('RepaintBoundary optimizations', () {
    testWidgets('LiveIndicator is wrapped with RepaintBoundary', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LiveIndicator(),
          ),
        ),
      );

      // LiveIndicator's build method should return a RepaintBoundary
      final liveIndicatorElement = tester.element(find.byType(LiveIndicator));
      final repaintBoundaryFinder = find.descendant(
        of: find.byElementPredicate((e) => e == liveIndicatorElement),
        matching: find.byType(RepaintBoundary),
      );
      expect(repaintBoundaryFinder, findsOneWidget);
    });

    testWidgets('LiveBadge is wrapped with RepaintBoundary', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LiveBadge(),
          ),
        ),
      );

      // LiveBadge should contain at least one RepaintBoundary (its own + LiveIndicator's)
      final liveBadgeFinder = find.byType(LiveBadge);
      final repaintBoundaryFinder = find.descendant(
        of: liveBadgeFinder,
        matching: find.byType(RepaintBoundary),
      );
      // LiveBadge has its own RepaintBoundary, and the inner LiveIndicator also has one
      expect(repaintBoundaryFinder, findsAtLeastNWidgets(2));
    });

    testWidgets('LiveIndicator with label has RepaintBoundary', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LiveIndicator(label: 'LIVE NOW'),
          ),
        ),
      );

      final liveIndicatorElement = tester.element(find.byType(LiveIndicator));
      final repaintBoundaryFinder = find.descendant(
        of: find.byElementPredicate((e) => e == liveIndicatorElement),
        matching: find.byType(RepaintBoundary),
      );
      expect(repaintBoundaryFinder, findsOneWidget);
    });
  });
}
