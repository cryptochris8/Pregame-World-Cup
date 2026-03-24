import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/widgets/offline_indicator.dart';

void main() {
  group('OfflineBanner', () {
    test('is a StatelessWidget', () {
      const banner = OfflineBanner();
      expect(banner, isA<StatelessWidget>());
    });

    test('stores optional onRetry callback', () {
      void onRetry() {}

      final banner = OfflineBanner(onRetry: onRetry);

      expect(banner.onRetry, equals(onRetry));
    });

    test('can be constructed without onRetry', () {
      const banner = OfflineBanner();

      expect(banner.onRetry, isNull);
    });

    test('can be constructed with onRetry', () {
      void onRetry() {}

      final banner = OfflineBanner(onRetry: onRetry);

      expect(banner.onRetry, isNotNull);
      expect(banner.onRetry, equals(onRetry));
    });
  });

  group('OfflineChip', () {
    test('is a StatelessWidget', () {
      const chip = OfflineChip();
      expect(chip, isA<StatelessWidget>());
    });

    test('can be constructed', () {
      const chip = OfflineChip();
      expect(chip, isNotNull);
    });
  });

  group('OfflineStatusIcon', () {
    test('is a StatelessWidget', () {
      const icon = OfflineStatusIcon();
      expect(icon, isA<StatelessWidget>());
    });

    test('stores optional onTap callback', () {
      void onTap() {}

      final icon = OfflineStatusIcon(onTap: onTap);

      expect(icon.onTap, equals(onTap));
    });

    test('can be constructed without onTap', () {
      const icon = OfflineStatusIcon();

      expect(icon.onTap, isNull);
    });

    test('can be constructed with onTap', () {
      void onTap() {}

      final icon = OfflineStatusIcon(onTap: onTap);

      expect(icon.onTap, isNotNull);
      expect(icon.onTap, equals(onTap));
    });
  });

  group('OfflineStatusDialog', () {
    test('is a StatelessWidget', () {
      const dialog = OfflineStatusDialog();
      expect(dialog, isA<StatelessWidget>());
    });

    test('can be constructed', () {
      const dialog = OfflineStatusDialog();
      expect(dialog, isNotNull);
    });
  });

  group('OfflineWrapper', () {
    test('is a StatelessWidget', () {
      const wrapper = OfflineWrapper(
        child: Text('Test'),
      );
      expect(wrapper, isA<StatelessWidget>());
    });

    test('stores required child widget', () {
      const child = Text('Test');

      const wrapper = OfflineWrapper(child: child);

      expect(wrapper.child, equals(child));
    });

    test('stores optional onRetry callback', () {
      void onRetry() {}

      final wrapper = OfflineWrapper(
        child: const Text('Test'),
        onRetry: onRetry,
      );

      expect(wrapper.onRetry, equals(onRetry));
    });

    test('can be constructed with required parameters only', () {
      const wrapper = OfflineWrapper(
        child: Text('Test'),
      );

      expect(wrapper.child, isNotNull);
      expect(wrapper.onRetry, isNull);
    });

    test('can be constructed with all parameters', () {
      void onRetry() {}
      const child = Text('Test');

      final wrapper = OfflineWrapper(
        child: child,
        onRetry: onRetry,
      );

      expect(wrapper.child, equals(child));
      expect(wrapper.onRetry, equals(onRetry));
    });
  });
}
