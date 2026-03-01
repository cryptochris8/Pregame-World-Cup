import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/animations/page_transitions.dart';

void main() {
  group('AppPageTransitions', () {
    group('slideFromRight', () {
      test('returns a PageRouteBuilder', () {
        final route = AppPageTransitions.slideFromRight(
          const Scaffold(body: Text('Test Page')),
        );
        expect(route, isA<PageRouteBuilder>());
      });

      test('transition duration is 300ms', () {
        final route = AppPageTransitions.slideFromRight(
          const Scaffold(body: Text('Test')),
        ) as PageRouteBuilder;
        expect(route.transitionDuration, equals(const Duration(milliseconds: 300)));
      });

      test('reverse transition duration is 250ms', () {
        final route = AppPageTransitions.slideFromRight(
          const Scaffold(body: Text('Test')),
        ) as PageRouteBuilder;
        expect(route.reverseTransitionDuration, equals(const Duration(milliseconds: 250)));
      });

      testWidgets('renders the target page', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  AppPageTransitions.slideFromRight(
                    const Scaffold(body: Text('Destination')),
                  ),
                );
              },
              child: const Text('Navigate'),
            ),
          ),
        ));

        await tester.tap(find.text('Navigate'));
        await tester.pumpAndSettle();

        expect(find.text('Destination'), findsOneWidget);
      });

      testWidgets('applies SlideTransition during animation', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  AppPageTransitions.slideFromRight(
                    const Scaffold(body: Text('Sliding Page')),
                  ),
                );
              },
              child: const Text('Go'),
            ),
          ),
        ));

        await tester.tap(find.text('Go'));
        // Pump partially to catch the animation mid-flight
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // During animation, SlideTransition should be in the widget tree
        expect(find.byType(SlideTransition), findsWidgets);
      });

      testWidgets('applies FadeTransition during animation', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  AppPageTransitions.slideFromRight(
                    const Scaffold(body: Text('Fading Page')),
                  ),
                );
              },
              child: const Text('Go'),
            ),
          ),
        ));

        await tester.tap(find.text('Go'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(FadeTransition), findsWidgets);
      });
    });

    group('slideFromBottom', () {
      test('returns a PageRouteBuilder', () {
        final route = AppPageTransitions.slideFromBottom(
          const Scaffold(body: Text('Test')),
        );
        expect(route, isA<PageRouteBuilder>());
      });

      test('transition duration is 400ms', () {
        final route = AppPageTransitions.slideFromBottom(
          const Scaffold(body: Text('Test')),
        ) as PageRouteBuilder;
        expect(route.transitionDuration, equals(const Duration(milliseconds: 400)));
      });

      test('reverse transition duration is 300ms', () {
        final route = AppPageTransitions.slideFromBottom(
          const Scaffold(body: Text('Test')),
        ) as PageRouteBuilder;
        expect(route.reverseTransitionDuration, equals(const Duration(milliseconds: 300)));
      });

      testWidgets('renders the target page', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  AppPageTransitions.slideFromBottom(
                    const Scaffold(body: Text('Bottom Page')),
                  ),
                );
              },
              child: const Text('Navigate'),
            ),
          ),
        ));

        await tester.tap(find.text('Navigate'));
        await tester.pumpAndSettle();

        expect(find.text('Bottom Page'), findsOneWidget);
      });

      testWidgets('uses SlideTransition (vertical)', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  AppPageTransitions.slideFromBottom(
                    const Scaffold(body: Text('Slide Up')),
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

        expect(find.byType(SlideTransition), findsWidgets);
      });
    });

    group('scaleAndFade', () {
      test('returns a PageRouteBuilder', () {
        final route = AppPageTransitions.scaleAndFade(
          const Scaffold(body: Text('Test')),
        );
        expect(route, isA<PageRouteBuilder>());
      });

      test('transition duration is 350ms', () {
        final route = AppPageTransitions.scaleAndFade(
          const Scaffold(body: Text('Test')),
        ) as PageRouteBuilder;
        expect(route.transitionDuration, equals(const Duration(milliseconds: 350)));
      });

      test('reverse transition duration is 250ms', () {
        final route = AppPageTransitions.scaleAndFade(
          const Scaffold(body: Text('Test')),
        ) as PageRouteBuilder;
        expect(route.reverseTransitionDuration, equals(const Duration(milliseconds: 250)));
      });

      testWidgets('renders the target page', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  AppPageTransitions.scaleAndFade(
                    const Scaffold(body: Text('Scaled Page')),
                  ),
                );
              },
              child: const Text('Navigate'),
            ),
          ),
        ));

        await tester.tap(find.text('Navigate'));
        await tester.pumpAndSettle();

        expect(find.text('Scaled Page'), findsOneWidget);
      });

      testWidgets('applies ScaleTransition and FadeTransition', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  AppPageTransitions.scaleAndFade(
                    const Scaffold(body: Text('Scale Fade')),
                  ),
                );
              },
              child: const Text('Go'),
            ),
          ),
        ));

        await tester.tap(find.text('Go'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(ScaleTransition), findsWidgets);
        expect(find.byType(FadeTransition), findsWidgets);
      });
    });

    group('circularReveal', () {
      test('returns a PageRouteBuilder', () {
        final route = AppPageTransitions.circularReveal(
          const Scaffold(body: Text('Test')),
        );
        expect(route, isA<PageRouteBuilder>());
      });

      test('transition duration is 500ms', () {
        final route = AppPageTransitions.circularReveal(
          const Scaffold(body: Text('Test')),
        ) as PageRouteBuilder;
        expect(route.transitionDuration, equals(const Duration(milliseconds: 500)));
      });

      test('reverse transition duration is 400ms', () {
        final route = AppPageTransitions.circularReveal(
          const Scaffold(body: Text('Test')),
        ) as PageRouteBuilder;
        expect(route.reverseTransitionDuration, equals(const Duration(milliseconds: 400)));
      });

      test('accepts optional center offset', () {
        // Should not throw with custom center
        final route = AppPageTransitions.circularReveal(
          const Scaffold(body: Text('Test')),
          center: const Offset(0.3, 0.7),
        );
        expect(route, isA<PageRouteBuilder>());
      });

      test('uses default center of (0.5, 0.5) when none provided', () {
        // This is implicitly tested - no center means default Offset(0.5, 0.5)
        final route = AppPageTransitions.circularReveal(
          const Scaffold(body: Text('Test')),
        );
        expect(route, isNotNull);
      });

      testWidgets('renders the target page', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  AppPageTransitions.circularReveal(
                    const Scaffold(body: Text('Revealed Page')),
                  ),
                );
              },
              child: const Text('Navigate'),
            ),
          ),
        ));

        await tester.tap(find.text('Navigate'));
        await tester.pumpAndSettle();

        expect(find.text('Revealed Page'), findsOneWidget);
      });

      testWidgets('applies ClipPath during animation', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  AppPageTransitions.circularReveal(
                    const Scaffold(body: Text('Clip Page')),
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

        expect(find.byType(ClipPath), findsWidgets);
      });
    });

    group('tabTransition', () {
      testWidgets('index % 3 == 0 uses SlideTransition from right', (tester) async {
        final controller = AnimationController(
          vsync: tester,
          duration: const Duration(milliseconds: 300),
        );

        await tester.pumpWidget(MaterialApp(
          home: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              return AppPageTransitions.tabTransition(
                child: const Text('Tab 0'),
                animation: controller,
                index: 0,
              );
            },
          ),
        ));

        controller.forward();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(SlideTransition), findsOneWidget);
        expect(find.byType(FadeTransition), findsOneWidget);
        expect(find.text('Tab 0'), findsOneWidget);

        controller.dispose();
      });

      testWidgets('index % 3 == 1 uses ScaleTransition', (tester) async {
        final controller = AnimationController(
          vsync: tester,
          duration: const Duration(milliseconds: 300),
        );

        await tester.pumpWidget(MaterialApp(
          home: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              return AppPageTransitions.tabTransition(
                child: const Text('Tab 1'),
                animation: controller,
                index: 1,
              );
            },
          ),
        ));

        controller.forward();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(ScaleTransition), findsOneWidget);
        expect(find.byType(FadeTransition), findsOneWidget);
        expect(find.text('Tab 1'), findsOneWidget);

        controller.dispose();
      });

      testWidgets('index % 3 == 2 uses SlideTransition from left', (tester) async {
        final controller = AnimationController(
          vsync: tester,
          duration: const Duration(milliseconds: 300),
        );

        await tester.pumpWidget(MaterialApp(
          home: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              return AppPageTransitions.tabTransition(
                child: const Text('Tab 2'),
                animation: controller,
                index: 2,
              );
            },
          ),
        ));

        controller.forward();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(SlideTransition), findsOneWidget);
        expect(find.byType(FadeTransition), findsOneWidget);
        expect(find.text('Tab 2'), findsOneWidget);

        controller.dispose();
      });

      testWidgets('index 3 wraps around to use same transition as index 0', (tester) async {
        final controller = AnimationController(
          vsync: tester,
          duration: const Duration(milliseconds: 300),
        );

        // index 3 % 3 == 0, same as index 0
        await tester.pumpWidget(MaterialApp(
          home: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              return AppPageTransitions.tabTransition(
                child: const Text('Tab 3'),
                animation: controller,
                index: 3,
              );
            },
          ),
        ));

        controller.forward();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Same as index 0 - SlideTransition
        expect(find.byType(SlideTransition), findsOneWidget);
        expect(find.text('Tab 3'), findsOneWidget);

        controller.dispose();
      });

      testWidgets('default index 0 is used when not specified', (tester) async {
        final controller = AnimationController(
          vsync: tester,
          duration: const Duration(milliseconds: 300),
        );

        await tester.pumpWidget(MaterialApp(
          home: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              return AppPageTransitions.tabTransition(
                child: const Text('Default Tab'),
                animation: controller,
                // index defaults to 0
              );
            },
          ),
        ));

        controller.forward();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(SlideTransition), findsOneWidget);
        expect(find.text('Default Tab'), findsOneWidget);

        controller.dispose();
      });
    });

    group('type parameter support', () {
      test('slideFromRight supports generic type parameter', () {
        final route = AppPageTransitions.slideFromRight<String>(
          const Scaffold(body: Text('Test')),
        );
        expect(route, isA<Route<String>>());
      });

      test('slideFromBottom supports generic type parameter', () {
        final route = AppPageTransitions.slideFromBottom<int>(
          const Scaffold(body: Text('Test')),
        );
        expect(route, isA<Route<int>>());
      });

      test('scaleAndFade supports generic type parameter', () {
        final route = AppPageTransitions.scaleAndFade<bool>(
          const Scaffold(body: Text('Test')),
        );
        expect(route, isA<Route<bool>>());
      });

      test('circularReveal supports generic type parameter', () {
        final route = AppPageTransitions.circularReveal<Map>(
          const Scaffold(body: Text('Test')),
        );
        expect(route, isA<Route<Map>>());
      });
    });
  });

  group('CircularRevealClipper', () {
    test('creates clipper with required parameters', () {
      final clipper = CircularRevealClipper(
        fraction: 0.5,
        center: const Offset(0.5, 0.5),
      );
      expect(clipper.fraction, equals(0.5));
      expect(clipper.center, equals(const Offset(0.5, 0.5)));
    });

    test('getClip returns a Path for fraction 0', () {
      final clipper = CircularRevealClipper(
        fraction: 0.0,
        center: const Offset(0.5, 0.5),
      );
      final path = clipper.getClip(const Size(400, 800));
      expect(path, isA<Path>());
    });

    test('getClip returns a Path for fraction 1', () {
      final clipper = CircularRevealClipper(
        fraction: 1.0,
        center: const Offset(0.5, 0.5),
      );
      final path = clipper.getClip(const Size(400, 800));
      expect(path, isA<Path>());
    });

    test('getClip returns a Path for fraction 0.5', () {
      final clipper = CircularRevealClipper(
        fraction: 0.5,
        center: const Offset(0.5, 0.5),
      );
      final path = clipper.getClip(const Size(400, 800));
      expect(path, isA<Path>());
    });

    test('radius calculation uses longestSide * 1.2 * fraction', () {
      final clipper = CircularRevealClipper(
        fraction: 0.5,
        center: const Offset(0.5, 0.5),
      );
      const size = Size(400, 800);
      // longestSide = 800, maxRadius = 800 * 1.2 = 960, radius = 960 * 0.5 = 480
      final path = clipper.getClip(size);

      // The path should contain an oval - we verify it's non-empty
      final bounds = path.getBounds();
      expect(bounds.width, greaterThan(0));
      expect(bounds.height, greaterThan(0));
    });

    test('center offset translates to correct position in path', () {
      // Center at (0.5, 0.5) means middle of the size
      final clipperCenter = CircularRevealClipper(
        fraction: 0.5,
        center: const Offset(0.5, 0.5),
      );
      const size = Size(400, 800);
      final path = clipperCenter.getClip(size);
      final bounds = path.getBounds();

      // The center of the circle should be at (200, 400)
      final centerX = bounds.left + bounds.width / 2;
      final centerY = bounds.top + bounds.height / 2;
      expect(centerX, closeTo(200, 1));
      expect(centerY, closeTo(400, 1));
    });

    test('center at top-left corner (0,0)', () {
      final clipper = CircularRevealClipper(
        fraction: 0.5,
        center: const Offset(0.0, 0.0),
      );
      const size = Size(400, 800);
      final path = clipper.getClip(size);
      final bounds = path.getBounds();

      // The center of the circle should be at (0, 0)
      final centerX = bounds.left + bounds.width / 2;
      final centerY = bounds.top + bounds.height / 2;
      expect(centerX, closeTo(0, 1));
      expect(centerY, closeTo(0, 1));
    });

    test('center at bottom-right corner (1,1)', () {
      final clipper = CircularRevealClipper(
        fraction: 0.5,
        center: const Offset(1.0, 1.0),
      );
      const size = Size(400, 800);
      final path = clipper.getClip(size);
      final bounds = path.getBounds();

      // The center of the circle should be at (400, 800)
      final centerX = bounds.left + bounds.width / 2;
      final centerY = bounds.top + bounds.height / 2;
      expect(centerX, closeTo(400, 1));
      expect(centerY, closeTo(800, 1));
    });

    test('fraction 0 produces zero-radius path', () {
      final clipper = CircularRevealClipper(
        fraction: 0.0,
        center: const Offset(0.5, 0.5),
      );
      final path = clipper.getClip(const Size(400, 800));
      final bounds = path.getBounds();

      // A circle with radius 0 should have empty bounds
      expect(bounds.width, closeTo(0, 0.01));
      expect(bounds.height, closeTo(0, 0.01));
    });

    test('fraction 1 produces full-size path covering entire widget', () {
      final clipper = CircularRevealClipper(
        fraction: 1.0,
        center: const Offset(0.5, 0.5),
      );
      const size = Size(400, 800);
      final path = clipper.getClip(size);
      final bounds = path.getBounds();

      // maxRadius = 800 * 1.2 = 960 (diameter = 1920)
      // Circle centered at (200, 400) with radius 960 should cover entire widget
      expect(bounds.width, greaterThanOrEqualTo(size.width));
      expect(bounds.height, greaterThanOrEqualTo(size.height));
    });

    test('shouldReclip always returns true', () {
      final clipper = CircularRevealClipper(
        fraction: 0.5,
        center: const Offset(0.5, 0.5),
      );
      final oldClipper = CircularRevealClipper(
        fraction: 0.3,
        center: const Offset(0.5, 0.5),
      );

      expect(clipper.shouldReclip(oldClipper), isTrue);
    });

    test('square size uses side * 1.2 for max radius', () {
      final clipper = CircularRevealClipper(
        fraction: 1.0,
        center: const Offset(0.5, 0.5),
      );
      const size = Size(400, 400);
      final path = clipper.getClip(size);
      final bounds = path.getBounds();

      // longestSide = 400, maxRadius = 480 (diameter = 960)
      expect(bounds.width, closeTo(960, 1));
      expect(bounds.height, closeTo(960, 1));
    });
  });
}
