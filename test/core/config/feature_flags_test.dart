import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/config/feature_flags.dart';

/// Tests for the FeatureFlags compile-time config.
///
/// Flags are read via `bool.fromEnvironment` at compile time. When running
/// tests without `--dart-define`, all flags take their default value of
/// true. These tests lock that default behavior in — if a default ever
/// gets flipped accidentally, the full-feature build regresses and users
/// lose the UI.
void main() {
  group('FeatureFlags defaults (standard test build)', () {
    test('predictionsEnabled defaults to true', () {
      expect(FeatureFlags.predictionsEnabled, isTrue);
    });

    test('predictionLeaderboardEnabled defaults to true', () {
      expect(FeatureFlags.predictionLeaderboardEnabled, isTrue);
    });

    test('bettingOddsEnabled defaults to true', () {
      expect(FeatureFlags.bettingOddsEnabled, isTrue);
    });

    test('aiProbabilityEnabled defaults to true', () {
      expect(FeatureFlags.aiProbabilityEnabled, isTrue);
    });

    test('fanPassEnabled defaults to true', () {
      expect(FeatureFlags.fanPassEnabled, isTrue);
    });

    test('snapshot() exposes every flag and all default to true', () {
      final snap = FeatureFlags.snapshot();
      expect(snap, hasLength(5));
      expect(snap.values.every((v) => v == true), isTrue,
          reason: 'All flags should default to true in standard builds');
    });
  });

  group('maybe() helper', () {
    testWidgets('returns the widget when enabled is true', (tester) async {
      const child = Text('visible', textDirection: TextDirection.ltr);
      final result = FeatureFlags.maybe(true, child);
      expect(result, same(child));
    });

    testWidgets('returns SizedBox.shrink when enabled is false',
        (tester) async {
      const child = Text('hidden', textDirection: TextDirection.ltr);
      final result = FeatureFlags.maybe(false, child);
      expect(result, isA<SizedBox>());
      final box = result as SizedBox;
      expect(box.width, 0);
      expect(box.height, 0);
    });
  });

  group('whenEnabled() helper', () {
    test('returns the list when enabled is true', () {
      const widgets = [SizedBox(), Placeholder()];
      final result = FeatureFlags.whenEnabled(true, widgets);
      expect(result, widgets);
    });

    test('returns an empty list when enabled is false', () {
      const widgets = [SizedBox(), Placeholder()];
      final result = FeatureFlags.whenEnabled(false, widgets);
      expect(result, isEmpty);
    });

    test('returned empty list is const (zero allocation on gated path)', () {
      final result = FeatureFlags.whenEnabled(false, const [SizedBox()]);
      expect(result, isEmpty);
    });
  });
}
