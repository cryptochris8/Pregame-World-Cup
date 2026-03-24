import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/venues/screens/venue_detail_photos_tab.dart';

void main() {
  group('VenueDetailPhotosTab', () {
    testWidgets('can be constructed with required parameters', (tester) async {
      final widget = VenueDetailPhotosTab(
        venuePhotos: const ['url1', 'url2'],
        isLoading: false,
      );

      expect(widget, isNotNull);
      expect(widget.venuePhotos, ['url1', 'url2']);
      expect(widget.isLoading, false);
    });

    testWidgets('shows loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VenueDetailPhotosTab(
              venuePhotos: [],
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
    });

    testWidgets('shows empty state when no photos available', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VenueDetailPhotosTab(
              venuePhotos: [],
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.text('No photos available'), findsOneWidget);
      expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
    });

    test('displays photo grid when photos are available', () {
      const widget = VenueDetailPhotosTab(
        venuePhotos: [
          'https://example.com/photo1.jpg',
          'https://example.com/photo2.jpg',
          'https://example.com/photo3.jpg',
        ],
        isLoading: false,
      );

      expect(widget.venuePhotos.length, 3);
      expect(widget.isLoading, false);
    });

    test('stores photo URLs correctly', () {
      const urls = [
        'https://example.com/photo1.jpg',
        'https://example.com/photo2.jpg',
      ];
      const widget = VenueDetailPhotosTab(
        venuePhotos: urls,
        isLoading: false,
      );

      expect(widget.venuePhotos, urls);
      expect(widget.venuePhotos[0], 'https://example.com/photo1.jpg');
      expect(widget.venuePhotos[1], 'https://example.com/photo2.jpg');
    });

    testWidgets('handles empty photo list correctly', (tester) async {
      const widget = VenueDetailPhotosTab(
        venuePhotos: [],
        isLoading: false,
      );

      expect(widget.venuePhotos.isEmpty, true);
    });

    testWidgets('handles single photo', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VenueDetailPhotosTab(
              venuePhotos: const ['https://example.com/photo1.jpg'],
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(GestureDetector), findsOneWidget);
    });
  });
}
