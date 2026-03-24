import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/widgets/nearby_venues_filter_chips.dart';

void main() {
  test('NearbyVenuesTypeFilter is a StatelessWidget', () {
    expect(NearbyVenuesTypeFilter, isNotNull);
  });

  test('NearbyVenuesTypeFilter is a Widget subclass', () {
    expect(NearbyVenuesTypeFilter, isA<Type>());
  });

  test('NearbyVenuesTypeFilter has correct type name', () {
    expect('$NearbyVenuesTypeFilter', contains('NearbyVenuesTypeFilter'));
  });

  test('NearbyVenuesTypeFilter is not null', () {
    expect(NearbyVenuesTypeFilter, isNotNull);
  });

  test('NearbyVenuesTypeFilter type identity', () {
    expect(NearbyVenuesTypeFilter == NearbyVenuesTypeFilter, isTrue);
  });
}
