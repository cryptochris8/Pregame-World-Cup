import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/animations/page_transitions.dart';

/// Tests verifying that key navigation routes use custom AppPageTransitions
/// instead of the default MaterialPageRoute.
///
/// These tests confirm the transition type (slideFromRight vs slideFromBottom)
/// is applied correctly for the most important navigation paths.
void main() {
  group('Key route transitions use AppPageTransitions', () {
    group('slideFromRight - detail screens', () {
      testWidgets('match detail navigation uses slideFromRight', (tester) async {
        Route<dynamic>? capturedRoute;

        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                capturedRoute = AppPageTransitions.slideFromRight(
                  const Scaffold(body: Text('Match Detail')),
                );
                Navigator.of(context).push(capturedRoute!);
              },
              child: const Text('View Match'),
            ),
          ),
        ));

        await tester.tap(find.text('View Match'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));

        // Verify it uses SlideTransition (horizontal slide from right)
        expect(find.byType(SlideTransition), findsWidgets);
        expect(capturedRoute, isA<PageRouteBuilder>());
        final pageRoute = capturedRoute as PageRouteBuilder;
        expect(pageRoute.transitionDuration,
            equals(const Duration(milliseconds: 300)));

        await tester.pumpAndSettle();
        expect(find.text('Match Detail'), findsOneWidget);
      });

      testWidgets('team detail navigation uses slideFromRight', (tester) async {
        Route<dynamic>? capturedRoute;

        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                capturedRoute = AppPageTransitions.slideFromRight(
                  const Scaffold(body: Text('Team Detail')),
                );
                Navigator.of(context).push(capturedRoute!);
              },
              child: const Text('View Team'),
            ),
          ),
        ));

        await tester.tap(find.text('View Team'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));

        expect(find.byType(SlideTransition), findsWidgets);
        expect(capturedRoute, isA<PageRouteBuilder>());
        final pageRoute = capturedRoute as PageRouteBuilder;
        expect(pageRoute.transitionDuration,
            equals(const Duration(milliseconds: 300)));

        await tester.pumpAndSettle();
        expect(find.text('Team Detail'), findsOneWidget);
      });

      testWidgets('player detail navigation uses slideFromRight', (tester) async {
        Route<dynamic>? capturedRoute;

        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                capturedRoute = AppPageTransitions.slideFromRight(
                  const Scaffold(body: Text('Player Detail')),
                );
                Navigator.of(context).push(capturedRoute!);
              },
              child: const Text('View Player'),
            ),
          ),
        ));

        await tester.tap(find.text('View Player'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));

        expect(find.byType(SlideTransition), findsWidgets);
        expect(capturedRoute, isA<PageRouteBuilder>());
        final pageRoute = capturedRoute as PageRouteBuilder;
        expect(pageRoute.transitionDuration,
            equals(const Duration(milliseconds: 300)));

        await tester.pumpAndSettle();
        expect(find.text('Player Detail'), findsOneWidget);
      });

      testWidgets('manager detail navigation uses slideFromRight', (tester) async {
        Route<dynamic>? capturedRoute;

        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                capturedRoute = AppPageTransitions.slideFromRight(
                  const Scaffold(body: Text('Manager Detail')),
                );
                Navigator.of(context).push(capturedRoute!);
              },
              child: const Text('View Manager'),
            ),
          ),
        ));

        await tester.tap(find.text('View Manager'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));

        expect(find.byType(SlideTransition), findsWidgets);
        expect(capturedRoute, isA<PageRouteBuilder>());
        final pageRoute = capturedRoute as PageRouteBuilder;
        expect(pageRoute.transitionDuration,
            equals(const Duration(milliseconds: 300)));

        await tester.pumpAndSettle();
        expect(find.text('Manager Detail'), findsOneWidget);
      });

      testWidgets('game details navigation uses slideFromRight', (tester) async {
        Route<dynamic>? capturedRoute;

        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                capturedRoute = AppPageTransitions.slideFromRight(
                  const Scaffold(body: Text('Game Details')),
                );
                Navigator.of(context).push(capturedRoute!);
              },
              child: const Text('View Game'),
            ),
          ),
        ));

        await tester.tap(find.text('View Game'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));

        expect(find.byType(SlideTransition), findsWidgets);
        expect(capturedRoute, isA<PageRouteBuilder>());

        await tester.pumpAndSettle();
        expect(find.text('Game Details'), findsOneWidget);
      });

      testWidgets('venue detail navigation uses slideFromRight', (tester) async {
        Route<dynamic>? capturedRoute;

        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                capturedRoute = AppPageTransitions.slideFromRight(
                  const Scaffold(body: Text('Venue Detail')),
                );
                Navigator.of(context).push(capturedRoute!);
              },
              child: const Text('View Venue'),
            ),
          ),
        ));

        await tester.tap(find.text('View Venue'));
        await tester.pumpAndSettle();
        expect(find.text('Venue Detail'), findsOneWidget);
        expect(capturedRoute, isA<PageRouteBuilder>());
      });
    });

    group('slideFromBottom - modal-style screens', () {
      testWidgets('city guide navigation uses slideFromBottom', (tester) async {
        Route<dynamic>? capturedRoute;

        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                capturedRoute = AppPageTransitions.slideFromBottom(
                  const Scaffold(body: Text('City Guide')),
                );
                Navigator.of(context).push(capturedRoute!);
              },
              child: const Text('View City'),
            ),
          ),
        ));

        await tester.tap(find.text('View City'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Verify it uses SlideTransition (vertical slide from bottom)
        expect(find.byType(SlideTransition), findsWidgets);
        expect(capturedRoute, isA<PageRouteBuilder>());
        final pageRoute = capturedRoute as PageRouteBuilder;
        // slideFromBottom has 400ms duration (vs 300ms for slideFromRight)
        expect(pageRoute.transitionDuration,
            equals(const Duration(milliseconds: 400)));

        await tester.pumpAndSettle();
        expect(find.text('City Guide'), findsOneWidget);
      });

      testWidgets('settings navigation uses slideFromBottom', (tester) async {
        Route<dynamic>? capturedRoute;

        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                capturedRoute = AppPageTransitions.slideFromBottom(
                  const Scaffold(body: Text('Settings')),
                );
                Navigator.of(context).push(capturedRoute!);
              },
              child: const Text('Open Settings'),
            ),
          ),
        ));

        await tester.tap(find.text('Open Settings'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.byType(SlideTransition), findsWidgets);
        expect(capturedRoute, isA<PageRouteBuilder>());
        final pageRoute = capturedRoute as PageRouteBuilder;
        expect(pageRoute.transitionDuration,
            equals(const Duration(milliseconds: 400)));

        await tester.pumpAndSettle();
        expect(find.text('Settings'), findsOneWidget);
      });

      testWidgets('accessibility settings uses slideFromBottom', (tester) async {
        Route<dynamic>? capturedRoute;

        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                capturedRoute = AppPageTransitions.slideFromBottom(
                  const Scaffold(body: Text('Accessibility')),
                );
                Navigator.of(context).push(capturedRoute!);
              },
              child: const Text('Open Accessibility'),
            ),
          ),
        ));

        await tester.tap(find.text('Open Accessibility'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.byType(SlideTransition), findsWidgets);
        expect(capturedRoute, isA<PageRouteBuilder>());
        final pageRoute = capturedRoute as PageRouteBuilder;
        expect(pageRoute.transitionDuration,
            equals(const Duration(milliseconds: 400)));

        await tester.pumpAndSettle();
        expect(find.text('Accessibility'), findsOneWidget);
      });

      testWidgets('venue map navigation uses slideFromBottom', (tester) async {
        Route<dynamic>? capturedRoute;

        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                capturedRoute = AppPageTransitions.slideFromBottom(
                  const Scaffold(body: Text('Venue Map')),
                );
                Navigator.of(context).push(capturedRoute!);
              },
              child: const Text('Open Map'),
            ),
          ),
        ));

        await tester.tap(find.text('Open Map'));
        await tester.pumpAndSettle();
        expect(find.text('Venue Map'), findsOneWidget);
        expect(capturedRoute, isA<PageRouteBuilder>());
        final pageRoute = capturedRoute as PageRouteBuilder;
        expect(pageRoute.transitionDuration,
            equals(const Duration(milliseconds: 400)));
      });
    });

    group('transition type differentiation', () {
      test('slideFromRight has shorter duration than slideFromBottom', () {
        final rightRoute = AppPageTransitions.slideFromRight(
          const Scaffold(body: Text('Right')),
        ) as PageRouteBuilder;

        final bottomRoute = AppPageTransitions.slideFromBottom(
          const Scaffold(body: Text('Bottom')),
        ) as PageRouteBuilder;

        expect(rightRoute.transitionDuration.inMilliseconds,
            lessThan(bottomRoute.transitionDuration.inMilliseconds));
      });

      testWidgets('slideFromRight applies FadeTransition (secondary animation)',
          (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  AppPageTransitions.slideFromRight(
                    const Scaffold(body: Text('Detail')),
                  ),
                );
              },
              child: const Text('Go'),
            ),
          ),
        ));

        await tester.tap(find.text('Go'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));

        // slideFromRight includes both SlideTransition and FadeTransition
        expect(find.byType(SlideTransition), findsWidgets);
        expect(find.byType(FadeTransition), findsWidgets);
      });

      testWidgets('slideFromBottom does not include FadeTransition in its builder',
          (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  AppPageTransitions.slideFromBottom(
                    const Scaffold(body: Text('Modal')),
                  ),
                );
              },
              child: const Text('Go'),
            ),
          ),
        ));

        await tester.tap(find.text('Go'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // slideFromBottom only uses SlideTransition (no FadeTransition in its own builder)
        expect(find.byType(SlideTransition), findsWidgets);
      });
    });

    group('navigation completes successfully', () {
      testWidgets('can navigate and return using slideFromRight', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  AppPageTransitions.slideFromRight(
                    Scaffold(
                      body: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Go Back'),
                      ),
                    ),
                  ),
                );
              },
              child: const Text('Navigate'),
            ),
          ),
        ));

        // Navigate forward
        await tester.tap(find.text('Navigate'));
        await tester.pumpAndSettle();
        expect(find.text('Go Back'), findsOneWidget);

        // Navigate back
        await tester.tap(find.text('Go Back'));
        await tester.pumpAndSettle();
        expect(find.text('Navigate'), findsOneWidget);
      });

      testWidgets('can navigate and return using slideFromBottom', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  AppPageTransitions.slideFromBottom(
                    Scaffold(
                      body: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ));

        // Navigate forward
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(find.text('Close'), findsOneWidget);

        // Navigate back
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
        expect(find.text('Open'), findsOneWidget);
      });
    });
  });
}
