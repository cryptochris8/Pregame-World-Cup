import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/services/venue_recommendation_service.dart';
import 'package:pregame_world_cup/features/venues/widgets/venue_card_photo_section.dart';

void main() {
  // Suppress overflow and network errors in constrained test environments
  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      final message = details.toString();
      if (message.contains('overflowed') ||
          message.contains('RenderFlex') ||
          message.contains('HTTP request failed') ||
          message.contains('NetworkImage')) {
        return;
      }
      FlutterError.presentError(details);
    };
  });

  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 414,
          height: 400,
          child: child,
        ),
      ),
    );
  }

  group('VenueCardPhotoSection', () {
    testWidgets('renders fallback when no photos are available',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const VenueCardPhotoSection(
            category: VenueCategory.sportsBar,
            isPopular: false,
            loadingPhotos: false,
            photoUrls: [],
            placeId: 'test_place',
          ),
        ),
      );

      // Fallback shows category display name
      expect(find.text('Sports Bar'), findsWidgets);
    });

    testWidgets('renders loading indicator when loading photos',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const VenueCardPhotoSection(
            category: VenueCategory.restaurant,
            isPopular: false,
            loadingPhotos: true,
            photoUrls: [],
            placeId: 'test_place',
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders category badge', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const VenueCardPhotoSection(
            category: VenueCategory.brewery,
            isPopular: false,
            loadingPhotos: false,
            photoUrls: [],
            placeId: 'test_place',
          ),
        ),
      );

      expect(find.text('Brewery'), findsWidgets);
    });

    testWidgets('renders Popular badge when isPopular is true',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const VenueCardPhotoSection(
            category: VenueCategory.sportsBar,
            isPopular: true,
            loadingPhotos: false,
            photoUrls: [],
            placeId: 'test_place',
          ),
        ),
      );

      expect(find.text('Popular'), findsOneWidget);
    });

    testWidgets('does not render Popular badge when isPopular is false',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const VenueCardPhotoSection(
            category: VenueCategory.sportsBar,
            isPopular: false,
            loadingPhotos: false,
            photoUrls: [],
            placeId: 'test_place',
          ),
        ),
      );

      expect(find.text('Popular'), findsNothing);
    });

    testWidgets('shows photo count indicator for multiple photos',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const VenueCardPhotoSection(
            category: VenueCategory.restaurant,
            isPopular: false,
            loadingPhotos: false,
            photoUrls: [
              'https://example.com/1.jpg',
              'https://example.com/2.jpg',
              'https://example.com/3.jpg',
            ],
            placeId: 'test_place',
          ),
        ),
      );

      // Photo count indicator should show count
      expect(find.text('3'), findsOneWidget);
      expect(find.byIcon(Icons.photo_library), findsOneWidget);
    });

    testWidgets('does not show photo count indicator for single photo',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const VenueCardPhotoSection(
            category: VenueCategory.restaurant,
            isPopular: false,
            loadingPhotos: false,
            photoUrls: ['https://example.com/1.jpg'],
            placeId: 'test_place',
          ),
        ),
      );

      expect(find.byIcon(Icons.photo_library), findsNothing);
    });

    testWidgets('renders with cafe category', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const VenueCardPhotoSection(
            category: VenueCategory.cafe,
            isPopular: false,
            loadingPhotos: false,
            photoUrls: [],
            placeId: 'test_place',
          ),
        ),
      );

      expect(find.text('Caf\u00e9'), findsWidgets);
    });

    testWidgets('renders with unknown category', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const VenueCardPhotoSection(
            category: VenueCategory.unknown,
            isPopular: false,
            loadingPhotos: false,
            photoUrls: [],
            placeId: 'test_place',
          ),
        ),
      );

      expect(find.text('Venue'), findsWidgets);
    });

    testWidgets('has 200px height', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const VenueCardPhotoSection(
            category: VenueCategory.sportsBar,
            isPopular: false,
            loadingPhotos: false,
            photoUrls: [],
            placeId: 'test_place',
          ),
        ),
      );

      // The outermost SizedBox in VenueCardPhotoSection has height 200
      final sizedBoxes = find.descendant(
        of: find.byType(VenueCardPhotoSection),
        matching: find.byType(SizedBox),
      );
      final firstSizedBox = tester.widget<SizedBox>(sizedBoxes.first);
      expect(firstSizedBox.height, equals(200));
    });
  });
}
