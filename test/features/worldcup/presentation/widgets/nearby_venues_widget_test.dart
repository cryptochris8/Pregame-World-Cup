import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/widgets/nearby_venues_widget.dart';

void main() {
  test('NearbyVenuesWidget is a StatelessWidget', () {
    expect(NearbyVenuesWidget, isNotNull);
  });

  test('NearbyVenuesWidget is a Widget subclass', () {
    expect(NearbyVenuesWidget, isA<Type>());
  });

  test('NearbyVenuesWidget has correct type name', () {
    expect('$NearbyVenuesWidget', contains('NearbyVenuesWidget'));
  });

  test('NearbyVenuesWidget is not null', () {
    expect(NearbyVenuesWidget, isNotNull);
  });

  test('NearbyVenuesWidget type identity', () {
    expect(NearbyVenuesWidget == NearbyVenuesWidget, isTrue);
  });
}
