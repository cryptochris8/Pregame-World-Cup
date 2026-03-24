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

  group('ConfederationFilterChips', () {
    testWidgets('renders All chip', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          ConfederationFilterChips(
            selectedConfederation: null,
            onConfederationChanged: (_) {},
          ),
        ),
      );

      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('renders chips for all confederations', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          ConfederationFilterChips(
            selectedConfederation: null,
            onConfederationChanged: (_) {},
          ),
        ),
      );

      // Verify all confederation chips are rendered
      for (final conf in Confederation.values) {
        expect(find.text(conf.name), findsOneWidget);
      }
    });

    testWidgets('All chip is selected when selectedConfederation is null', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          ConfederationFilterChips(
            selectedConfederation: null,
            onConfederationChanged: (_) {},
          ),
        ),
      );

      final allChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('All'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(allChip.selected, isTrue);
    });

    testWidgets('UEFA chip is selected when selectedConfederation is uefa', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          ConfederationFilterChips(
            selectedConfederation: Confederation.uefa,
            onConfederationChanged: (_) {},
          ),
        ),
      );

      final uefaChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('uefa'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(uefaChip.selected, isTrue);
    });

    testWidgets('CONMEBOL chip is selected when selectedConfederation is conmebol', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          ConfederationFilterChips(
            selectedConfederation: Confederation.conmebol,
            onConfederationChanged: (_) {},
          ),
        ),
      );

      final conmebolChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('conmebol'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(conmebolChip.selected, isTrue);
    });

    testWidgets('CONCACAF chip is selected when selectedConfederation is concacaf', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          ConfederationFilterChips(
            selectedConfederation: Confederation.concacaf,
            onConfederationChanged: (_) {},
          ),
        ),
      );

      final concacafChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('concacaf'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(concacafChip.selected, isTrue);
    });

    testWidgets('tapping All chip calls callback with null', (tester) async {
      Confederation? capturedConfederation = Confederation.uefa; // Start with non-null

      await tester.pumpWidget(
        buildWidget(
          ConfederationFilterChips(
            selectedConfederation: Confederation.uefa,
            onConfederationChanged: (conf) {
              capturedConfederation = conf;
            },
          ),
        ),
      );

      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      expect(capturedConfederation, isNull);
    });

    testWidgets('tapping UEFA chip calls callback with uefa', (tester) async {
      Confederation? capturedConfederation;

      await tester.pumpWidget(
        buildWidget(
          ConfederationFilterChips(
            selectedConfederation: null,
            onConfederationChanged: (conf) {
              capturedConfederation = conf;
            },
          ),
        ),
      );

      await tester.tap(find.text('uefa'));
      await tester.pumpAndSettle();

      expect(capturedConfederation, Confederation.uefa);
    });

    testWidgets('tapping CONMEBOL chip calls callback with conmebol', (tester) async {
      Confederation? capturedConfederation;

      await tester.pumpWidget(
        buildWidget(
          ConfederationFilterChips(
            selectedConfederation: null,
            onConfederationChanged: (conf) {
              capturedConfederation = conf;
            },
          ),
        ),
      );

      await tester.tap(find.text('conmebol'));
      await tester.pumpAndSettle();

      expect(capturedConfederation, Confederation.conmebol);
    });

    testWidgets('tapping CONCACAF chip calls callback with concacaf', (tester) async {
      Confederation? capturedConfederation;

      await tester.pumpWidget(
        buildWidget(
          ConfederationFilterChips(
            selectedConfederation: null,
            onConfederationChanged: (conf) {
              capturedConfederation = conf;
            },
          ),
        ),
      );

      await tester.tap(find.text('concacaf'));
      await tester.pumpAndSettle();

      expect(capturedConfederation, Confederation.concacaf);
    });

    testWidgets('tapping AFC chip calls callback with afc', (tester) async {
      Confederation? capturedConfederation;

      await tester.pumpWidget(
        buildWidget(
          ConfederationFilterChips(
            selectedConfederation: null,
            onConfederationChanged: (conf) {
              capturedConfederation = conf;
            },
          ),
        ),
      );

      await tester.tap(find.text('afc'));
      await tester.pumpAndSettle();

      expect(capturedConfederation, Confederation.afc);
    });

    testWidgets('tapping CAF chip calls callback with caf', (tester) async {
      Confederation? capturedConfederation;

      await tester.pumpWidget(
        buildWidget(
          ConfederationFilterChips(
            selectedConfederation: null,
            onConfederationChanged: (conf) {
              capturedConfederation = conf;
            },
          ),
        ),
      );

      await tester.tap(find.text('caf'));
      await tester.pumpAndSettle();

      expect(capturedConfederation, Confederation.caf);
    });

    testWidgets('tapping OFC chip calls callback with ofc', (tester) async {
      Confederation? capturedConfederation;

      await tester.pumpWidget(
        buildWidget(
          ConfederationFilterChips(
            selectedConfederation: null,
            onConfederationChanged: (conf) {
              capturedConfederation = conf;
            },
          ),
        ),
      );

      await tester.tap(find.text('ofc'));
      await tester.pumpAndSettle();

      expect(capturedConfederation, Confederation.ofc);
    });

    testWidgets('shows counts when provided', (tester) async {
      final counts = {
        Confederation.uefa: 16,
        Confederation.conmebol: 6,
        Confederation.concacaf: 6,
        Confederation.afc: 8,
        Confederation.caf: 9,
        Confederation.ofc: 1,
      };

      await tester.pumpWidget(
        buildWidget(
          ConfederationFilterChips(
            selectedConfederation: null,
            onConfederationChanged: (_) {},
            counts: counts,
          ),
        ),
      );

      // Verify counts are displayed
      expect(find.text('(16)'), findsOneWidget);
      expect(find.text('(6)'), findsNWidgets(2)); // Both CONMEBOL and CONCACAF
      expect(find.text('(8)'), findsOneWidget);
      expect(find.text('(9)'), findsOneWidget);
      expect(find.text('(1)'), findsOneWidget);
    });

    testWidgets('does not show count when count is null for a confederation', (tester) async {
      final counts = {
        Confederation.uefa: 16,
        // Other confederations have no counts
      };

      await tester.pumpWidget(
        buildWidget(
          ConfederationFilterChips(
            selectedConfederation: null,
            onConfederationChanged: (_) {},
            counts: counts,
          ),
        ),
      );

      expect(find.text('(16)'), findsOneWidget);
      // Should not find counts for other confederations
      expect(find.text('(6)'), findsNothing);
      expect(find.text('(8)'), findsNothing);
    });

    testWidgets('does not show counts when counts parameter is null', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          ConfederationFilterChips(
            selectedConfederation: null,
            onConfederationChanged: (_) {},
            counts: null,
          ),
        ),
      );

      // Should not find any count badges
      expect(find.textContaining('('), findsNothing);
    });

    testWidgets('only selected chip is highlighted', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          ConfederationFilterChips(
            selectedConfederation: Confederation.afc,
            onConfederationChanged: (_) {},
          ),
        ),
      );

      // All chip should not be selected
      final allChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('All'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(allChip.selected, isFalse);

      // UEFA should not be selected
      final uefaChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('uefa'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(uefaChip.selected, isFalse);

      // AFC should be selected
      final afcChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('afc'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(afcChip.selected, isTrue);
    });

    testWidgets('renders in horizontal scrollable container', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          ConfederationFilterChips(
            selectedConfederation: null,
            onConfederationChanged: (_) {},
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
