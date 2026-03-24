import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/widgets/sync_status_indicator.dart';

void main() {
  group('SyncStatusIndicator', () {
    test('is a StatelessWidget', () {
      const indicator = SyncStatusIndicator();
      expect(indicator, isA<StatelessWidget>());
    });

    test('showLabel defaults to true', () {
      const indicator = SyncStatusIndicator();
      expect(indicator.showLabel, isTrue);
    });

    test('compact defaults to false', () {
      const indicator = SyncStatusIndicator();
      expect(indicator.compact, isFalse);
    });

    test('can be constructed with custom values', () {
      const indicator = SyncStatusIndicator(
        showLabel: false,
        compact: true,
      );

      expect(indicator.showLabel, isFalse);
      expect(indicator.compact, isTrue);
    });

    test('can be constructed with default values', () {
      const indicator = SyncStatusIndicator();

      expect(indicator.showLabel, isTrue);
      expect(indicator.compact, isFalse);
    });

    test('stores showLabel value', () {
      const indicator = SyncStatusIndicator(showLabel: false);
      expect(indicator.showLabel, isFalse);
    });

    test('stores compact value', () {
      const indicator = SyncStatusIndicator(compact: true);
      expect(indicator.compact, isTrue);
    });
  });

  group('SyncFAB', () {
    test('is a StatelessWidget', () {
      const fab = SyncFAB();
      expect(fab, isA<StatelessWidget>());
    });

    test('stores optional onPressed callback', () {
      void onPressed() {}

      final fab = SyncFAB(onPressed: onPressed);

      expect(fab.onPressed, equals(onPressed));
    });

    test('defaults onPressed to null', () {
      const fab = SyncFAB();

      expect(fab.onPressed, isNull);
    });

    test('can be constructed without onPressed', () {
      const fab = SyncFAB();

      expect(fab, isNotNull);
      expect(fab.onPressed, isNull);
    });

    test('can be constructed with onPressed', () {
      void onPressed() {}

      final fab = SyncFAB(onPressed: onPressed);

      expect(fab, isNotNull);
      expect(fab.onPressed, isNotNull);
    });
  });

  group('SyncStatusTile', () {
    test('is a StatelessWidget', () {
      const tile = SyncStatusTile();
      expect(tile, isA<StatelessWidget>());
    });

    test('can be constructed', () {
      const tile = SyncStatusTile();

      expect(tile, isNotNull);
    });
  });
}
