import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/watch_party/presentation/screens/invite_friends_screen.dart';

void main() {
  group('InviteFriendsScreen construction and type tests', () {
    test('can be constructed with required watchPartyId', () {
      const widget = InviteFriendsScreen(
        watchPartyId: 'wp_123',
      );

      expect(widget, isNotNull);
      expect(widget, isA<InviteFriendsScreen>());
      expect(widget.watchPartyId, equals('wp_123'));
    });

    test('is a StatefulWidget', () {
      const widget = InviteFriendsScreen(
        watchPartyId: 'wp_123',
      );

      expect(widget, isA<StatefulWidget>());
    });

    test('stores watchPartyId correctly', () {
      const widget = InviteFriendsScreen(
        watchPartyId: 'custom_party_456',
      );

      expect(widget.watchPartyId, equals('custom_party_456'));
    });

    test('multiple instances are independent', () {
      const widget1 = InviteFriendsScreen(
        watchPartyId: 'party_1',
      );

      const widget2 = InviteFriendsScreen(
        watchPartyId: 'party_2',
      );

      expect(widget1.watchPartyId, equals('party_1'));
      expect(widget2.watchPartyId, equals('party_2'));
    });

    test('watchPartyId can be any string value', () {
      const testIds = [
        'wp_123',
        'party_abc',
        'test-party-id',
        '12345',
        'watch_party_long_id_format',
      ];

      for (final id in testIds) {
        final widget = InviteFriendsScreen(watchPartyId: id);
        expect(widget.watchPartyId, equals(id));
      }
    });

    test('can create multiple instances', () {
      const widget1 = InviteFriendsScreen(watchPartyId: 'wp_1');
      const widget2 = InviteFriendsScreen(watchPartyId: 'wp_2');
      const widget3 = InviteFriendsScreen(watchPartyId: 'wp_3');

      expect(widget1, isNotNull);
      expect(widget2, isNotNull);
      expect(widget3, isNotNull);
      expect(widget1.watchPartyId, isNot(equals(widget2.watchPartyId)));
      expect(widget2.watchPartyId, isNot(equals(widget3.watchPartyId)));
    });

    test('widget key is optional', () {
      const widgetWithoutKey = InviteFriendsScreen(
        watchPartyId: 'wp_123',
      );

      const widgetWithKey = InviteFriendsScreen(
        key: Key('invite_screen'),
        watchPartyId: 'wp_123',
      );

      expect(widgetWithoutKey.key, isNull);
      expect(widgetWithKey.key, isNotNull);
    });

    test('widget type is correct', () {
      const widget = InviteFriendsScreen(
        watchPartyId: 'wp_123',
      );

      expect(widget.runtimeType.toString(), equals('InviteFriendsScreen'));
    });
  });
}
