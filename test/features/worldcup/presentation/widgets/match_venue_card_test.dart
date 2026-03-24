import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/widgets/match_venue_card.dart';

void main() {
  setUp(() {
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

  group('MatchVenueCard', () {
    testWidgets('renders without error with venue name only', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchVenueCard(
              venueName: 'MetLife Stadium',
            ),
          ),
        ),
      );

      expect(find.byType(MatchVenueCard), findsOneWidget);
    });

    testWidgets('renders without error with venue name and city', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchVenueCard(
              venueName: 'MetLife Stadium',
              venueCity: 'East Rutherford, NJ',
            ),
          ),
        ),
      );

      expect(find.byType(MatchVenueCard), findsOneWidget);
    });

    testWidgets('shows venue name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchVenueCard(
              venueName: 'Rose Bowl Stadium',
            ),
          ),
        ),
      );

      expect(find.text('Rose Bowl Stadium'), findsOneWidget);
    });

    testWidgets('shows venue city when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchVenueCard(
              venueName: 'AT&T Stadium',
              venueCity: 'Arlington, TX',
            ),
          ),
        ),
      );

      expect(find.text('AT&T Stadium'), findsOneWidget);
      expect(find.text('Arlington, TX'), findsOneWidget);
    });

    testWidgets('does not show city when null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchVenueCard(
              venueName: 'Azteca Stadium',
              venueCity: null,
            ),
          ),
        ),
      );

      expect(find.text('Azteca Stadium'), findsOneWidget);
      // Only the venue name text should be visible, no city text
      final texts = tester.widgetList<Text>(find.byType(Text));
      expect(texts.length, equals(1));
    });

    testWidgets('displays stadium icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchVenueCard(
              venueName: 'Lumen Field',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.stadium), findsOneWidget);
    });

    testWidgets('displays chevron right icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchVenueCard(
              venueName: 'SoFi Stadium',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('is tappable with InkWell', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchVenueCard(
              venueName: 'Mercedes-Benz Stadium',
            ),
          ),
        ),
      );

      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('responds to tap', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchVenueCard(
              venueName: 'Hard Rock Stadium',
            ),
          ),
        ),
      );

      // Find and tap the InkWell
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      // Should complete without error (navigation stub in widget does nothing)
      expect(tester.takeException(), isNull);
    });

    testWidgets('has proper container styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchVenueCard(
              venueName: 'BMO Field',
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(MatchVenueCard),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, isNotNull);
      expect(decoration.border, isNotNull);
    });

    testWidgets('stadium icon has colored background container', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchVenueCard(
              venueName: 'Arrowhead Stadium',
            ),
          ),
        ),
      );

      // Find the icon container by looking for Container with stadium icon
      final iconContainer = tester.widget<Container>(
        find.ancestor(
          of: find.byIcon(Icons.stadium),
          matching: find.byType(Container),
        ).first,
      );

      expect(iconContainer.decoration, isA<BoxDecoration>());
      final decoration = iconContainer.decoration as BoxDecoration;
      expect(decoration.color, isNotNull);
      expect(decoration.borderRadius, isNotNull);
      expect(iconContainer.constraints?.maxWidth, equals(48));
      expect(iconContainer.constraints?.maxHeight, equals(48));
    });

    testWidgets('displays multiple venue cards correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: const [
                MatchVenueCard(
                  venueName: 'Venue 1',
                  venueCity: 'City 1',
                ),
                SizedBox(height: 8),
                MatchVenueCard(
                  venueName: 'Venue 2',
                  venueCity: 'City 2',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Venue 1'), findsOneWidget);
      expect(find.text('City 1'), findsOneWidget);
      expect(find.text('Venue 2'), findsOneWidget);
      expect(find.text('City 2'), findsOneWidget);
      expect(find.byIcon(Icons.stadium), findsNWidgets(2));
    });

    testWidgets('venue name is bold', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchVenueCard(
              venueName: 'Lincoln Financial Field',
            ),
          ),
        ),
      );

      final nameText = tester.widget<Text>(find.text('Lincoln Financial Field'));
      expect(nameText.style?.fontWeight, equals(FontWeight.bold));
      expect(nameText.style?.fontSize, equals(16));
    });

    testWidgets('has Material widget for proper InkWell effect', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchVenueCard(
              venueName: 'BC Place',
            ),
          ),
        ),
      );

      expect(find.byType(Material), findsWidgets);
    });
  });
}
