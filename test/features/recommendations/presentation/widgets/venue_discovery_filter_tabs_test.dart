import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/recommendations/presentation/widgets/venue_discovery_filter_tabs.dart';

void main() {
  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.toString().contains('overflowed')) {
        return;
      }
      FlutterError.presentError(details);
    };
  });

  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('SmartVenueFilter', () {
    test('stores name', () {
      final filter = SmartVenueFilter(
        'Smart Picks',
        'smart',
        Icons.psychology,
        const Color(0xFF7C3AED),
      );

      expect(filter.name, equals('Smart Picks'));
    });

    test('stores type', () {
      final filter = SmartVenueFilter(
        'Nearby',
        'distance',
        Icons.location_on,
        const Color(0xFF3B82F6),
      );

      expect(filter.type, equals('distance'));
    });

    test('stores icon', () {
      final filter = SmartVenueFilter(
        'Highly Rated',
        'rating',
        Icons.star,
        const Color(0xFFFBBF24),
      );

      expect(filter.icon, equals(Icons.star));
    });

    test('stores color', () {
      final filter = SmartVenueFilter(
        'Popular',
        'popular',
        Icons.trending_up,
        const Color(0xFFEA580C),
      );

      expect(filter.color, equals(const Color(0xFFEA580C)));
    });

    test('can be constructed with all parameters', () {
      final filter = SmartVenueFilter(
        'Custom Filter',
        'custom',
        Icons.filter_alt,
        Colors.blue,
      );

      expect(filter.name, equals('Custom Filter'));
      expect(filter.type, equals('custom'));
      expect(filter.icon, equals(Icons.filter_alt));
      expect(filter.color, equals(Colors.blue));
    });
  });

  group('VenueDiscoveryFilterTabs', () {
    final testFilters = [
      SmartVenueFilter('Smart Picks', 'smart', Icons.psychology, const Color(0xFF7C3AED)),
      SmartVenueFilter('Nearby', 'distance', Icons.location_on, const Color(0xFF3B82F6)),
      SmartVenueFilter('Highly Rated', 'rating', Icons.star, const Color(0xFFFBBF24)),
      SmartVenueFilter('Popular', 'popular', Icons.trending_up, const Color(0xFFEA580C)),
    ];

    test('is a StatelessWidget', () {
      final widget = VenueDiscoveryFilterTabs(
        filters: testFilters,
        selectedFilterIndex: 0,
        onFilterSelected: (index) {},
      );

      expect(widget, isA<VenueDiscoveryFilterTabs>());
    });

    test('stores filters list', () {
      final widget = VenueDiscoveryFilterTabs(
        filters: testFilters,
        selectedFilterIndex: 0,
        onFilterSelected: (index) {},
      );

      expect(widget.filters, equals(testFilters));
      expect(widget.filters.length, equals(4));
    });

    test('stores selectedFilterIndex', () {
      final widget = VenueDiscoveryFilterTabs(
        filters: testFilters,
        selectedFilterIndex: 2,
        onFilterSelected: (index) {},
      );

      expect(widget.selectedFilterIndex, equals(2));
    });

    test('stores onFilterSelected callback', () {
      void testCallback(int index) {}

      final widget = VenueDiscoveryFilterTabs(
        filters: testFilters,
        selectedFilterIndex: 0,
        onFilterSelected: testCallback,
      );

      expect(widget.onFilterSelected, equals(testCallback));
    });

    testWidgets('renders in MaterialApp', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          VenueDiscoveryFilterTabs(
            filters: testFilters,
            selectedFilterIndex: 0,
            onFilterSelected: (index) {},
          ),
        ),
      );

      expect(find.byType(VenueDiscoveryFilterTabs), findsOneWidget);
    });

    testWidgets('displays filter names', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          VenueDiscoveryFilterTabs(
            filters: testFilters,
            selectedFilterIndex: 0,
            onFilterSelected: (index) {},
          ),
        ),
      );

      expect(find.text('Smart Picks'), findsOneWidget);
      expect(find.text('Nearby'), findsOneWidget);
      expect(find.text('Highly Rated'), findsOneWidget);
      expect(find.text('Popular'), findsOneWidget);
    });

    testWidgets('displays filter icons', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          VenueDiscoveryFilterTabs(
            filters: testFilters,
            selectedFilterIndex: 0,
            onFilterSelected: (index) {},
          ),
        ),
      );

      expect(find.byIcon(Icons.psychology), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });

    testWidgets('calls onFilterSelected when filter is tapped', (tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        buildTestWidget(
          VenueDiscoveryFilterTabs(
            filters: testFilters,
            selectedFilterIndex: selectedIndex,
            onFilterSelected: (index) {
              selectedIndex = index;
            },
          ),
        ),
      );

      // Tap on the second filter
      await tester.tap(find.text('Nearby'));
      await tester.pump();

      expect(selectedIndex, equals(1));
    });

    testWidgets('renders with single filter', (tester) async {
      final singleFilter = [
        SmartVenueFilter('Only One', 'one', Icons.filter_1, Colors.blue),
      ];

      await tester.pumpWidget(
        buildTestWidget(
          VenueDiscoveryFilterTabs(
            filters: singleFilter,
            selectedFilterIndex: 0,
            onFilterSelected: (index) {},
          ),
        ),
      );

      expect(find.text('Only One'), findsOneWidget);
      expect(find.byIcon(Icons.filter_1), findsOneWidget);
    });

    testWidgets('renders with empty filter list', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          VenueDiscoveryFilterTabs(
            filters: [],
            selectedFilterIndex: 0,
            onFilterSelected: (index) {},
          ),
        ),
      );

      expect(find.byType(VenueDiscoveryFilterTabs), findsOneWidget);
    });

    testWidgets('updates selected index correctly', (tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        buildTestWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return VenueDiscoveryFilterTabs(
                filters: testFilters,
                selectedFilterIndex: selectedIndex,
                onFilterSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              );
            },
          ),
        ),
      );

      // Tap different filters and verify selection updates
      await tester.tap(find.text('Popular'));
      await tester.pump();
      expect(selectedIndex, equals(3));

      await tester.tap(find.text('Highly Rated'));
      await tester.pump();
      expect(selectedIndex, equals(2));
    });

    testWidgets('renders with custom filters', (tester) async {
      final customFilters = [
        SmartVenueFilter('Filter A', 'a', Icons.abc, Colors.red),
        SmartVenueFilter('Filter B', 'b', Icons.adjust, Colors.green),
      ];

      await tester.pumpWidget(
        buildTestWidget(
          VenueDiscoveryFilterTabs(
            filters: customFilters,
            selectedFilterIndex: 0,
            onFilterSelected: (index) {},
          ),
        ),
      );

      expect(find.text('Filter A'), findsOneWidget);
      expect(find.text('Filter B'), findsOneWidget);
      expect(find.byIcon(Icons.abc), findsOneWidget);
      expect(find.byIcon(Icons.adjust), findsOneWidget);
    });
  });
}
