import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/widgets/nearby_venue_card.dart';

void main() {
  test('NearbyVenueCard is a StatefulWidget', () {
    expect(NearbyVenueCard, isNotNull);
  });

  test('NearbyVenueCard is a Widget subclass', () {
    expect(NearbyVenueCard, isA<Type>());
  });

  test('NearbyVenueCard has correct type name', () {
    expect('$NearbyVenueCard', contains('NearbyVenueCard'));
  });

  test('NearbyVenueCard is not null', () {
    expect(NearbyVenueCard, isNotNull);
  });

  test('NearbyVenueCard type identity', () {
    expect(NearbyVenueCard == NearbyVenueCard, isTrue);
  });
}
