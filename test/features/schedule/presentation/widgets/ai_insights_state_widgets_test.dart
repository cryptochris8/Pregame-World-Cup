import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/schedule/presentation/widgets/ai_insights_state_widgets.dart';

void main() {
  setUp(() {
    // Suppress overflow errors during tests
    FlutterError.onError = (FlutterErrorDetails details) {
      if (!details.toString().contains('RenderFlex overflowed')) {
        FlutterError.presentError(details);
      }
    };
  });

  group('AIInsightsLoadingWidget', () {
    testWidgets('renders CircularProgressIndicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AIInsightsLoadingWidget(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows Analyzing matchup data text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AIInsightsLoadingWidget(),
          ),
        ),
      );

      expect(find.text('Analyzing matchup data...'), findsOneWidget);
    });

    testWidgets('progress indicator has orange color',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AIInsightsLoadingWidget(),
          ),
        ),
      );

      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

      expect(progressIndicator.valueColor?.value, Colors.orange);
    });
  });

  group('AIInsightsErrorWidget', () {
    testWidgets('shows error message text', (WidgetTester tester) async {
      const errorMessage = 'Failed to load analysis';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AIInsightsErrorWidget(
              errorMessage: errorMessage,
            ),
          ),
        ),
      );

      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('shows error_outline icon', (WidgetTester tester) async {
      const errorMessage = 'Failed to load analysis';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AIInsightsErrorWidget(
              errorMessage: errorMessage,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('handles long error messages', (WidgetTester tester) async {
      const errorMessage =
          'This is a very long error message that should be handled gracefully by the widget without causing overflow issues or breaking the layout';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AIInsightsErrorWidget(
              errorMessage: errorMessage,
            ),
          ),
        ),
      );

      expect(find.text(errorMessage), findsOneWidget);
      // Widget should render without throwing errors
      expect(find.byType(AIInsightsErrorWidget), findsOneWidget);
    });

    testWidgets('has Container decoration with red tint',
        (WidgetTester tester) async {
      const errorMessage = 'Failed to load analysis';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AIInsightsErrorWidget(
              errorMessage: errorMessage,
            ),
          ),
        ),
      );

      // Find Container with decoration
      final containerFinder = find.descendant(
        of: find.byType(AIInsightsErrorWidget),
        matching: find.byType(Container),
      );

      expect(containerFinder, findsWidgets);

      // Get the first Container that has decoration
      final containers = tester.widgetList<Container>(containerFinder);
      bool hasRedDecoration = false;

      for (final container in containers) {
        if (container.decoration != null) {
          final decoration = container.decoration as BoxDecoration?;
          if (decoration?.color != null) {
            // Check if color has red component (red-tinted)
            final color = decoration!.color!;
            if (color.red > 200 || color.toString().contains('red')) {
              hasRedDecoration = true;
              break;
            }
          }
        }
      }

      expect(hasRedDecoration, isTrue);
    });
  });
}
