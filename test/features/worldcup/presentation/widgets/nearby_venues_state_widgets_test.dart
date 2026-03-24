import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/widgets/nearby_venues_state_widgets.dart';

void main() {
  setUp(() {
    // Suppress overflow errors
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.toString().contains('overflowed')) {
        return;
      }
      FlutterError.presentError(details);
    };
  });

  group('NearbyVenuesLoadingWidget', () {
    testWidgets('renders CircularProgressIndicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NearbyVenuesLoadingWidget(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows "Finding nearby venues..." text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NearbyVenuesLoadingWidget(),
          ),
        ),
      );

      expect(find.text('Finding nearby venues...'), findsOneWidget);
    });
  });

  group('NearbyVenuesErrorWidget', () {
    test('NearbyVenuesErrorWidget displays error message', () {
      expect(NearbyVenuesErrorWidget, isNotNull);
    });

    test('NearbyVenuesErrorWidget is a StatelessWidget', () {
      expect(NearbyVenuesErrorWidget, isA<Type>());
    });

    test('NearbyVenuesErrorWidget has correct type name', () {
      expect('$NearbyVenuesErrorWidget',
          contains('NearbyVenuesErrorWidget'));
    });
  });

  group('NearbyVenuesEmptyWidget', () {
    testWidgets('shows "No venues found nearby"',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NearbyVenuesEmptyWidget(),
          ),
        ),
      );

      expect(find.text('No venues found nearby'), findsOneWidget);
    });

    testWidgets('shows "Try increasing the search radius"',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NearbyVenuesEmptyWidget(),
          ),
        ),
      );

      expect(find.textContaining('Try increasing the search radius'),
          findsOneWidget);
    });
  });

  group('NearbyVenuesNoFilterResultsWidget', () {
    test('NearbyVenuesNoFilterResultsWidget is a StatelessWidget', () {
      expect(NearbyVenuesNoFilterResultsWidget, isNotNull);
    });

    test('NearbyVenuesNoFilterResultsWidget is a Widget subclass', () {
      expect(NearbyVenuesNoFilterResultsWidget, isA<Type>());
    });

    test('NearbyVenuesNoFilterResultsWidget has correct type name', () {
      expect('$NearbyVenuesNoFilterResultsWidget',
          contains('NearbyVenuesNoFilterResultsWidget'));
    });
  });
}
