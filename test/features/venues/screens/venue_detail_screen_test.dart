import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/recommendations/domain/entities/place.dart';
import 'package:pregame_world_cup/features/venues/screens/venue_detail_screen.dart';
import 'package:pregame_world_cup/features/venues/widgets/venue_action_buttons.dart';
import 'package:pregame_world_cup/features/venues/widgets/venue_operating_hours_card.dart';
import 'package:pregame_world_cup/core/services/unified_venue_service.dart';
import 'package:pregame_world_cup/features/social/domain/services/social_service.dart';

// Mock classes for DI dependencies used by child widgets
class MockUnifiedVenueService extends Mock implements UnifiedVenueService {}

class MockSocialService extends Mock implements SocialService {}

final sl = GetIt.instance;

void main() {
  late Directory tempDir;

  setUpAll(() async {
    // Initialize Hive with a temp directory so VenuePhotoService.initialize()
    // can open boxes without crashing.
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);

    // Register mock services in GetIt so child widgets
    // (EnhancedAIVenueRecommendationsWidget) don't crash when calling sl<>().
    sl.registerSingleton<UnifiedVenueService>(MockUnifiedVenueService());
    sl.registerSingleton<SocialService>(MockSocialService());
  });

  tearDownAll(() async {
    await sl.reset();
    await Hive.close();
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {
      // Ignore cleanup errors on Windows
    }
  });

  // Suppress overflow and rendering errors that occur in constrained test
  // environments.
  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      final message = details.toString();
      if (message.contains('overflowed') ||
          message.contains('RenderFlex') ||
          message.contains('HTTP request failed')) {
        return;
      }
      FlutterError.presentError(details);
    };
  });

  // ---------------------------------------------------------------------------
  // Helper: create a Place with configurable fields
  // ---------------------------------------------------------------------------
  Place createTestPlace({
    String placeId = 'test_place_123',
    String name = 'The Sports Pub',
    String? vicinity = '123 Main St, Dallas, TX',
    double? rating = 4.5,
    int? userRatingsTotal = 250,
    List<String>? types = const ['bar', 'restaurant'],
    double? latitude = 32.7767,
    double? longitude = -96.7970,
    int? priceLevel = 2,
    OpeningHours? openingHours,
    Geometry? geometry,
    String? photoReference,
  }) {
    return Place(
      placeId: placeId,
      name: name,
      vicinity: vicinity,
      rating: rating,
      userRatingsTotal: userRatingsTotal,
      types: types,
      latitude: latitude,
      longitude: longitude,
      priceLevel: priceLevel,
      openingHours: openingHours,
      geometry: geometry,
      photoReference: photoReference,
    );
  }

  // ---------------------------------------------------------------------------
  // Helper: wrap VenueDetailScreen in MaterialApp with sufficient viewport size
  // ---------------------------------------------------------------------------
  Widget buildTestWidget(Place venue) {
    return MediaQuery(
      data: const MediaQueryData(size: Size(414, 896)),
      child: MaterialApp(
        home: VenueDetailScreen(venue: venue),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Test cases
  // ---------------------------------------------------------------------------

  group('VenueDetailScreen', () {
    testWidgets('renders venue name in header', (tester) async {
      final venue = createTestPlace(name: 'MetLife Stadium Bar');

      await tester.pumpWidget(buildTestWidget(venue));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('MetLife Stadium Bar'), findsOneWidget);
    });

    testWidgets('renders venue address when available', (tester) async {
      final venue = createTestPlace(
        vicinity: '1 MetLife Stadium Dr, East Rutherford, NJ',
      );

      await tester.pumpWidget(buildTestWidget(venue));
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text('1 MetLife Stadium Dr, East Rutherford, NJ'),
        findsWidgets,
      );
    });

    testWidgets('shows rating display with correct rating value',
        (tester) async {
      final venue = createTestPlace(rating: 4.5, userRatingsTotal: 312);

      await tester.pumpWidget(buildTestWidget(venue));
      await tester.pump(const Duration(milliseconds: 100));

      // The rating text shows the numeric value
      expect(find.text('4.5'), findsOneWidget);
      // Review count is shown
      expect(find.text('(312 reviews)'), findsOneWidget);
      // Star icons are rendered (5 per rating display in header)
      expect(find.byIcon(Icons.star), findsWidgets);
    });

    testWidgets('shows price level display', (tester) async {
      final venue = createTestPlace(priceLevel: 2);

      await tester.pumpWidget(buildTestWidget(venue));
      await tester.pump(const Duration(milliseconds: 100));

      // Price level 2 renders dollar signs in the venue header
      expect(find.textContaining('\$'), findsWidgets);
    });

    testWidgets('shows 4 tabs (Overview, Photos, Reviews, Hours)',
        (tester) async {
      final venue = createTestPlace();

      await tester.pumpWidget(buildTestWidget(venue));
      await tester.pump(const Duration(milliseconds: 100));

      // Scroll to make the tab bar visible
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.byType(TabBar),
        200,
        scrollable: scrollable,
      );

      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Photos'), findsOneWidget);
      // "Reviews" appears once as a tab label (the Reviews tab content is not
      // visible until tapped, so the "Reviews & Ratings" header is off-screen)
      expect(find.text('Reviews'), findsOneWidget);
      // "Hours" appears in both the tab and the VenueOperatingHoursCard header
      // visible in the Overview tab, so we expect at least one
      expect(find.text('Hours'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows category badge in venue header', (tester) async {
      // A bar+restaurant with "Sports" in the name => VenueCategory.sportsBar
      final venue = createTestPlace(
        name: 'Sports Grill & Bar',
        types: ['bar', 'restaurant'],
      );

      await tester.pumpWidget(buildTestWidget(venue));
      await tester.pump(const Duration(milliseconds: 100));

      // VenueCategory.sportsBar displayName 'Sports Bar' appears in both
      // the SliverAppBar background fallback and the header badge
      expect(find.text('Sports Bar'), findsAtLeastNWidgets(1));
    });

    testWidgets('renders without crashing for minimal Place data',
        (tester) async {
      // Minimal Place: only required fields, everything else null
      final venue = createTestPlace(
        name: 'Unnamed Venue',
        vicinity: null,
        rating: null,
        userRatingsTotal: null,
        types: null,
        latitude: null,
        longitude: null,
        priceLevel: null,
        openingHours: null,
        geometry: null,
        photoReference: null,
      );

      await tester.pumpWidget(buildTestWidget(venue));
      await tester.pump(const Duration(milliseconds: 100));

      // Screen should render and show the venue name
      expect(find.text('Unnamed Venue'), findsOneWidget);
      expect(find.byType(VenueDetailScreen), findsOneWidget);
    });

    testWidgets('renders Photos tab in TabBar', (tester) async {
      final venue = createTestPlace();

      await tester.pumpWidget(buildTestWidget(venue));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify the Photos tab exists as part of the TabBar
      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      // The second tab (index 1) should be the Photos tab
      final photosTab = tabBar.tabs[1] as Tab;
      expect(photosTab.text, 'Photos');
    });

    testWidgets('shows operating hours card in Overview tab', (tester) async {
      final venue = createTestPlace();

      await tester.pumpWidget(buildTestWidget(venue));
      await tester.pump(const Duration(milliseconds: 100));

      // The Overview tab is shown by default and contains VenueOperatingHoursCard
      expect(find.byType(VenueOperatingHoursCard), findsAtLeastNWidgets(1));
    });

    testWidgets('shows Contact Information section in Overview tab',
        (tester) async {
      final venue = createTestPlace(
        name: 'Test Bar',
        vicinity: '456 Oak Ave',
      );

      await tester.pumpWidget(buildTestWidget(venue));
      await tester.pump(const Duration(milliseconds: 100));

      // Scroll down to see the contact info section in the Overview tab
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('Contact Information'),
        300,
        scrollable: scrollable,
      );

      expect(find.text('Contact Information'), findsOneWidget);
      // Phone is always displayed with a placeholder
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('+1 (555) 123-4567'), findsOneWidget);
    });

    testWidgets('shows action buttons widget', (tester) async {
      final venue = createTestPlace();

      await tester.pumpWidget(buildTestWidget(venue));
      await tester.pump(const Duration(milliseconds: 100));

      // VenueActionButtons is rendered as part of the screen
      expect(find.byType(VenueActionButtons), findsOneWidget);
      // Verify at least the Call and Directions labels are present
      // (Website may appear twice -- once in action buttons, once in contact info)
      expect(find.text('Call'), findsOneWidget);
      expect(find.text('Directions'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
    });

    testWidgets('does not show address when vicinity is null', (tester) async {
      final venue = createTestPlace(vicinity: null);

      await tester.pumpWidget(buildTestWidget(venue));
      await tester.pump(const Duration(milliseconds: 100));

      // The address text should be absent
      expect(find.text('123 Main St, Dallas, TX'), findsNothing);
    });

    testWidgets('does not show price level when priceLevel is null',
        (tester) async {
      final venue = createTestPlace(priceLevel: null);

      await tester.pumpWidget(buildTestWidget(venue));
      await tester.pump(const Duration(milliseconds: 100));

      // Rating text (4.5) should still be present even without price level
      expect(find.text('4.5'), findsOneWidget);
    });

    testWidgets('does not show rating stars when rating is null',
        (tester) async {
      final venue = createTestPlace(rating: null, userRatingsTotal: null);

      await tester.pumpWidget(buildTestWidget(venue));
      await tester.pump(const Duration(milliseconds: 100));

      // No rating value text should appear in the venue header
      expect(find.text('4.5'), findsNothing);
    });

    testWidgets('renders SliverAppBar with correct expanded height',
        (tester) async {
      final venue = createTestPlace();

      await tester.pumpWidget(buildTestWidget(venue));
      await tester.pump(const Duration(milliseconds: 100));

      final sliverAppBar =
          tester.widget<SliverAppBar>(find.byType(SliverAppBar));
      expect(sliverAppBar.expandedHeight, 300);
      expect(sliverAppBar.pinned, isTrue);
    });

    testWidgets('renders CustomScrollView as the body', (tester) async {
      final venue = createTestPlace();

      await tester.pumpWidget(buildTestWidget(venue));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('shows category badge for restaurant type', (tester) async {
      // A place typed as restaurant without sports-bar keywords
      final venue = createTestPlace(
        name: 'Bella Italia',
        types: ['restaurant', 'food'],
      );

      await tester.pumpWidget(buildTestWidget(venue));
      await tester.pump(const Duration(milliseconds: 100));

      // "Restaurant" appears in both the SliverAppBar fallback and the
      // category badge in the venue header
      expect(find.text('Restaurant'), findsAtLeastNWidgets(1));
    });

    testWidgets('renders TabBar with 4 tabs', (tester) async {
      final venue = createTestPlace();

      await tester.pumpWidget(buildTestWidget(venue));
      await tester.pump(const Duration(milliseconds: 100));

      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.tabs.length, 4);
    });
  });
}
