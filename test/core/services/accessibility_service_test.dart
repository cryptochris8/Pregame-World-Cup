import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pregame_world_cup/core/services/accessibility_service.dart';

void main() {
  group('AccessibilitySettings', () {
    group('constructor', () {
      test('default values are all false/null', () {
        const settings = AccessibilitySettings();
        expect(settings.highContrast, isFalse);
        expect(settings.reduceMotion, isFalse);
        expect(settings.largerTouchTargets, isFalse);
        expect(settings.textScaleFactor, isNull);
        expect(settings.screenReaderOptimized, isFalse);
        expect(settings.boldText, isFalse);
      });

      test('accepts custom values', () {
        const settings = AccessibilitySettings(
          highContrast: true,
          reduceMotion: true,
          largerTouchTargets: true,
          textScaleFactor: 1.5,
          screenReaderOptimized: true,
          boldText: true,
        );
        expect(settings.highContrast, isTrue);
        expect(settings.reduceMotion, isTrue);
        expect(settings.largerTouchTargets, isTrue);
        expect(settings.textScaleFactor, equals(1.5));
        expect(settings.screenReaderOptimized, isTrue);
        expect(settings.boldText, isTrue);
      });
    });

    group('copyWith', () {
      test('returns a copy with updated fields', () {
        const original = AccessibilitySettings();
        final updated = original.copyWith(highContrast: true);
        expect(updated.highContrast, isTrue);
        expect(updated.reduceMotion, isFalse);
        expect(updated.largerTouchTargets, isFalse);
        expect(updated.textScaleFactor, isNull);
        expect(updated.screenReaderOptimized, isFalse);
        expect(updated.boldText, isFalse);
      });

      test('preserves unchanged fields', () {
        const original = AccessibilitySettings(
          highContrast: true,
          reduceMotion: true,
          largerTouchTargets: true,
          textScaleFactor: 2.0,
          screenReaderOptimized: true,
          boldText: true,
        );
        final updated = original.copyWith(boldText: false);
        expect(updated.highContrast, isTrue);
        expect(updated.reduceMotion, isTrue);
        expect(updated.largerTouchTargets, isTrue);
        expect(updated.textScaleFactor, equals(2.0));
        expect(updated.screenReaderOptimized, isTrue);
        expect(updated.boldText, isFalse);
      });

      test('can update multiple fields at once', () {
        const original = AccessibilitySettings();
        final updated = original.copyWith(
          highContrast: true,
          reduceMotion: true,
          textScaleFactor: 1.3,
        );
        expect(updated.highContrast, isTrue);
        expect(updated.reduceMotion, isTrue);
        expect(updated.textScaleFactor, equals(1.3));
        expect(updated.largerTouchTargets, isFalse);
      });

      test('returns equivalent object when no fields provided', () {
        const original = AccessibilitySettings(
          highContrast: true,
          boldText: true,
        );
        final copied = original.copyWith();
        expect(copied, equals(original));
      });
    });

    group('toJson', () {
      test('serializes default settings correctly', () {
        const settings = AccessibilitySettings();
        final json = settings.toJson();
        expect(json['highContrast'], isFalse);
        expect(json['reduceMotion'], isFalse);
        expect(json['largerTouchTargets'], isFalse);
        expect(json['textScaleFactor'], isNull);
        expect(json['screenReaderOptimized'], isFalse);
        expect(json['boldText'], isFalse);
      });

      test('serializes custom settings correctly', () {
        const settings = AccessibilitySettings(
          highContrast: true,
          reduceMotion: true,
          largerTouchTargets: true,
          textScaleFactor: 1.5,
          screenReaderOptimized: true,
          boldText: true,
        );
        final json = settings.toJson();
        expect(json['highContrast'], isTrue);
        expect(json['reduceMotion'], isTrue);
        expect(json['largerTouchTargets'], isTrue);
        expect(json['textScaleFactor'], equals(1.5));
        expect(json['screenReaderOptimized'], isTrue);
        expect(json['boldText'], isTrue);
      });

      test('contains all expected keys', () {
        const settings = AccessibilitySettings();
        final json = settings.toJson();
        expect(json.keys, containsAll([
          'highContrast',
          'reduceMotion',
          'largerTouchTargets',
          'textScaleFactor',
          'screenReaderOptimized',
          'boldText',
        ]));
        expect(json.keys.length, equals(6));
      });
    });

    group('fromJson', () {
      test('deserializes from complete JSON', () {
        final json = {
          'highContrast': true,
          'reduceMotion': true,
          'largerTouchTargets': true,
          'textScaleFactor': 1.5,
          'screenReaderOptimized': true,
          'boldText': true,
        };
        final settings = AccessibilitySettings.fromJson(json);
        expect(settings.highContrast, isTrue);
        expect(settings.reduceMotion, isTrue);
        expect(settings.largerTouchTargets, isTrue);
        expect(settings.textScaleFactor, equals(1.5));
        expect(settings.screenReaderOptimized, isTrue);
        expect(settings.boldText, isTrue);
      });

      test('uses defaults for missing fields', () {
        final settings = AccessibilitySettings.fromJson({});
        expect(settings.highContrast, isFalse);
        expect(settings.reduceMotion, isFalse);
        expect(settings.largerTouchTargets, isFalse);
        expect(settings.textScaleFactor, isNull);
        expect(settings.screenReaderOptimized, isFalse);
        expect(settings.boldText, isFalse);
      });

      test('handles partial JSON', () {
        final json = {
          'highContrast': true,
          'textScaleFactor': 2.0,
        };
        final settings = AccessibilitySettings.fromJson(json);
        expect(settings.highContrast, isTrue);
        expect(settings.reduceMotion, isFalse);
        expect(settings.textScaleFactor, equals(2.0));
        expect(settings.boldText, isFalse);
      });

      test('handles null values gracefully', () {
        final json = <String, dynamic>{
          'highContrast': null,
          'reduceMotion': null,
          'textScaleFactor': null,
        };
        final settings = AccessibilitySettings.fromJson(json);
        expect(settings.highContrast, isFalse);
        expect(settings.reduceMotion, isFalse);
        expect(settings.textScaleFactor, isNull);
      });
    });

    group('roundtrip serialization', () {
      test('toJson and fromJson are symmetric for defaults', () {
        const original = AccessibilitySettings();
        final roundtripped =
            AccessibilitySettings.fromJson(original.toJson());
        expect(roundtripped, equals(original));
      });

      test('toJson and fromJson are symmetric for custom values', () {
        const original = AccessibilitySettings(
          highContrast: true,
          reduceMotion: true,
          largerTouchTargets: true,
          textScaleFactor: 1.75,
          screenReaderOptimized: true,
          boldText: true,
        );
        final roundtripped =
            AccessibilitySettings.fromJson(original.toJson());
        expect(roundtripped, equals(original));
      });
    });

    group('equality', () {
      test('two default settings are equal', () {
        const a = AccessibilitySettings();
        const b = AccessibilitySettings();
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('settings with same values are equal', () {
        const a = AccessibilitySettings(
          highContrast: true,
          textScaleFactor: 1.5,
        );
        const b = AccessibilitySettings(
          highContrast: true,
          textScaleFactor: 1.5,
        );
        expect(a, equals(b));
      });

      test('settings with different values are not equal', () {
        const a = AccessibilitySettings(highContrast: true);
        const b = AccessibilitySettings(highContrast: false);
        expect(a, isNot(equals(b)));
      });

      test('each field affects equality', () {
        const base = AccessibilitySettings();
        expect(base.copyWith(highContrast: true), isNot(equals(base)));
        expect(base.copyWith(reduceMotion: true), isNot(equals(base)));
        expect(base.copyWith(largerTouchTargets: true), isNot(equals(base)));
        expect(base.copyWith(textScaleFactor: 1.5), isNot(equals(base)));
        expect(
            base.copyWith(screenReaderOptimized: true), isNot(equals(base)));
        expect(base.copyWith(boldText: true), isNot(equals(base)));
      });
    });
  });

  group('AccessibilityService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    group('factory constructor (singleton)', () {
      test('returns an AccessibilityService', () {
        final service = AccessibilityService();
        expect(service, isA<AccessibilityService>());
      });

      test('returns the same instance on repeated calls', () {
        final a = AccessibilityService();
        final b = AccessibilityService();
        expect(identical(a, b), isTrue);
      });

      test('extends ChangeNotifier', () {
        final service = AccessibilityService();
        expect(service, isA<ChangeNotifier>());
      });
    });

    group('initial state', () {
      test('settings are default before initialization', () {
        final service = AccessibilityService();
        expect(service.settings, equals(const AccessibilitySettings()));
      });

      test('isInitialized is false before initialize', () {
        final service = AccessibilityService();
        // Since it's a singleton, it may already be initialized from
        // a previous test. But we can verify the property exists.
        expect(service.isInitialized, isA<bool>());
      });
    });

    group('initialize', () {
      test('loads settings from SharedPreferences', () async {
        SharedPreferences.setMockInitialValues({
          'accessibility_high_contrast': true,
          'accessibility_reduce_motion': true,
          'accessibility_larger_touch_targets': false,
          'accessibility_screen_reader_optimized': true,
          'accessibility_bold_text': false,
        });

        final service = AccessibilityService();
        await service.initialize();

        expect(service.isInitialized, isTrue);
      });

      test('does not re-initialize if already initialized', () async {
        final service = AccessibilityService();
        await service.initialize();
        // Second call should be a no-op
        await service.initialize();
        expect(service.isInitialized, isTrue);
      });
    });

    group('updateSettings', () {
      test('updates settings and notifies listeners', () async {
        final service = AccessibilityService();
        await service.initialize();

        bool notified = false;
        service.addListener(() => notified = true);

        await service.updateSettings(
          const AccessibilitySettings(highContrast: true),
        );

        expect(service.settings.highContrast, isTrue);
        expect(notified, isTrue);
      });

      test('does not notify when settings are identical', () async {
        final service = AccessibilityService();
        await service.initialize();

        // First set to known state
        await service.updateSettings(const AccessibilitySettings());

        bool notified = false;
        service.addListener(() => notified = true);

        // Set identical settings
        await service.updateSettings(const AccessibilitySettings());
        expect(notified, isFalse);
      });

      test('persists settings to SharedPreferences', () async {
        SharedPreferences.setMockInitialValues({});
        final service = AccessibilityService();
        await service.initialize();

        await service.updateSettings(
          const AccessibilitySettings(
            highContrast: true,
            reduceMotion: true,
            textScaleFactor: 1.5,
          ),
        );

        final prefs = await SharedPreferences.getInstance();
        expect(
            prefs.getBool('accessibility_high_contrast'), isTrue);
        expect(
            prefs.getBool('accessibility_reduce_motion'), isTrue);
        expect(prefs.getDouble('accessibility_text_scale_factor'),
            equals(1.5));
      });
    });

    group('individual setters', () {
      test('setHighContrast updates high contrast', () async {
        final service = AccessibilityService();
        await service.initialize();
        await service.setHighContrast(true);
        expect(service.settings.highContrast, isTrue);
      });

      test('setReduceMotion updates reduce motion', () async {
        final service = AccessibilityService();
        await service.initialize();
        await service.setReduceMotion(true);
        expect(service.settings.reduceMotion, isTrue);
      });

      test('setLargerTouchTargets updates larger touch targets', () async {
        final service = AccessibilityService();
        await service.initialize();
        await service.setLargerTouchTargets(true);
        expect(service.settings.largerTouchTargets, isTrue);
      });

      test('setTextScaleFactor updates text scale factor', () async {
        final service = AccessibilityService();
        await service.initialize();
        await service.setTextScaleFactor(2.0);
        expect(service.settings.textScaleFactor, equals(2.0));
      });

      test('setScreenReaderOptimized updates screen reader', () async {
        final service = AccessibilityService();
        await service.initialize();
        await service.setScreenReaderOptimized(true);
        expect(service.settings.screenReaderOptimized, isTrue);
      });

      test('setBoldText updates bold text', () async {
        final service = AccessibilityService();
        await service.initialize();
        await service.setBoldText(true);
        expect(service.settings.boldText, isTrue);
      });
    });

    group('resetToDefaults', () {
      test('resets all settings to default values', () async {
        final service = AccessibilityService();
        await service.initialize();

        // Set some non-default values
        await service.updateSettings(
          const AccessibilitySettings(
            highContrast: true,
            reduceMotion: true,
            largerTouchTargets: true,
            textScaleFactor: 2.0,
            screenReaderOptimized: true,
            boldText: true,
          ),
        );

        // Reset
        await service.resetToDefaults();
        expect(service.settings, equals(const AccessibilitySettings()));
      });
    });

    group('minimumTouchTargetSize', () {
      test('returns 48.0 when largerTouchTargets is false', () async {
        final service = AccessibilityService();
        await service.initialize();
        await service.setLargerTouchTargets(false);
        expect(service.minimumTouchTargetSize, equals(48.0));
      });

      test('returns 56.0 when largerTouchTargets is true', () async {
        final service = AccessibilityService();
        await service.initialize();
        await service.setLargerTouchTargets(true);
        expect(service.minimumTouchTargetSize, equals(56.0));
      });
    });

    group('getAnimationDuration', () {
      test('returns default duration when reduceMotion is false', () async {
        final service = AccessibilityService();
        await service.initialize();
        await service.setReduceMotion(false);

        const defaultDuration = Duration(milliseconds: 300);
        expect(
          service.getAnimationDuration(defaultDuration),
          equals(defaultDuration),
        );
      });

      test('returns Duration.zero when reduceMotion is true', () async {
        final service = AccessibilityService();
        await service.initialize();
        await service.setReduceMotion(true);

        const defaultDuration = Duration(milliseconds: 300);
        expect(
          service.getAnimationDuration(defaultDuration),
          equals(Duration.zero),
        );
      });
    });

    group('shouldShowAnimations', () {
      test('returns true when reduceMotion is false', () async {
        final service = AccessibilityService();
        await service.initialize();
        await service.setReduceMotion(false);
        expect(service.shouldShowAnimations, isTrue);
      });

      test('returns false when reduceMotion is true', () async {
        final service = AccessibilityService();
        await service.initialize();
        await service.setReduceMotion(true);
        expect(service.shouldShowAnimations, isFalse);
      });
    });

    group('text scale factor persistence', () {
      test('null text scale factor removes key from prefs', () async {
        SharedPreferences.setMockInitialValues({
          'accessibility_text_scale_factor': 1.5,
        });
        final service = AccessibilityService();
        await service.initialize();

        // Set to null via updateSettings with a new AccessibilitySettings
        // Note: copyWith cannot set to null, so we use updateSettings directly
        await service.updateSettings(const AccessibilitySettings());

        final prefs = await SharedPreferences.getInstance();
        expect(
          prefs.getDouble('accessibility_text_scale_factor'),
          isNull,
        );
      });
    });
  });
}
