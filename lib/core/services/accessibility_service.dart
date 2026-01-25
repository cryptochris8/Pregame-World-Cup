import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'logging_service.dart';

/// User accessibility preferences
class AccessibilitySettings {
  /// Whether to use high contrast colors
  final bool highContrast;

  /// Whether to reduce motion/animations
  final bool reduceMotion;

  /// Whether to use larger touch targets
  final bool largerTouchTargets;

  /// Custom text scale factor (null = use system default)
  final double? textScaleFactor;

  /// Whether to show screen reader hints
  final bool screenReaderOptimized;

  /// Whether bold text is preferred
  final bool boldText;

  const AccessibilitySettings({
    this.highContrast = false,
    this.reduceMotion = false,
    this.largerTouchTargets = false,
    this.textScaleFactor,
    this.screenReaderOptimized = false,
    this.boldText = false,
  });

  /// Create settings that respect system accessibility preferences
  factory AccessibilitySettings.fromMediaQuery(MediaQueryData mediaQuery) {
    return AccessibilitySettings(
      highContrast: mediaQuery.highContrast,
      reduceMotion: mediaQuery.disableAnimations,
      boldText: mediaQuery.boldText,
    );
  }

  AccessibilitySettings copyWith({
    bool? highContrast,
    bool? reduceMotion,
    bool? largerTouchTargets,
    double? textScaleFactor,
    bool? screenReaderOptimized,
    bool? boldText,
  }) {
    return AccessibilitySettings(
      highContrast: highContrast ?? this.highContrast,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      largerTouchTargets: largerTouchTargets ?? this.largerTouchTargets,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      screenReaderOptimized: screenReaderOptimized ?? this.screenReaderOptimized,
      boldText: boldText ?? this.boldText,
    );
  }

  Map<String, dynamic> toJson() => {
        'highContrast': highContrast,
        'reduceMotion': reduceMotion,
        'largerTouchTargets': largerTouchTargets,
        'textScaleFactor': textScaleFactor,
        'screenReaderOptimized': screenReaderOptimized,
        'boldText': boldText,
      };

  factory AccessibilitySettings.fromJson(Map<String, dynamic> json) {
    return AccessibilitySettings(
      highContrast: json['highContrast'] as bool? ?? false,
      reduceMotion: json['reduceMotion'] as bool? ?? false,
      largerTouchTargets: json['largerTouchTargets'] as bool? ?? false,
      textScaleFactor: json['textScaleFactor'] as double?,
      screenReaderOptimized: json['screenReaderOptimized'] as bool? ?? false,
      boldText: json['boldText'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccessibilitySettings &&
          runtimeType == other.runtimeType &&
          highContrast == other.highContrast &&
          reduceMotion == other.reduceMotion &&
          largerTouchTargets == other.largerTouchTargets &&
          textScaleFactor == other.textScaleFactor &&
          screenReaderOptimized == other.screenReaderOptimized &&
          boldText == other.boldText;

  @override
  int get hashCode =>
      highContrast.hashCode ^
      reduceMotion.hashCode ^
      largerTouchTargets.hashCode ^
      textScaleFactor.hashCode ^
      screenReaderOptimized.hashCode ^
      boldText.hashCode;
}

/// Service for managing accessibility settings and features
class AccessibilityService extends ChangeNotifier {
  static AccessibilityService? _instance;

  AccessibilitySettings _settings = const AccessibilitySettings();
  bool _isInitialized = false;
  SharedPreferences? _prefs;

  // Keys for SharedPreferences
  static const String _keyHighContrast = 'accessibility_high_contrast';
  static const String _keyReduceMotion = 'accessibility_reduce_motion';
  static const String _keyLargerTouchTargets = 'accessibility_larger_touch_targets';
  static const String _keyTextScaleFactor = 'accessibility_text_scale_factor';
  static const String _keyScreenReaderOptimized = 'accessibility_screen_reader_optimized';
  static const String _keyBoldText = 'accessibility_bold_text';

  AccessibilityService._();

  factory AccessibilityService() {
    _instance ??= AccessibilityService._();
    return _instance!;
  }

  /// Current accessibility settings
  AccessibilitySettings get settings => _settings;

  /// Whether the service is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the service and load saved preferences
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadSettings();
      _isInitialized = true;
      LoggingService.info('AccessibilityService initialized', tag: 'Accessibility');
    } catch (e) {
      LoggingService.error('Failed to initialize AccessibilityService: $e', tag: 'Accessibility');
    }
  }

  /// Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    if (_prefs == null) return;

    _settings = AccessibilitySettings(
      highContrast: _prefs!.getBool(_keyHighContrast) ?? false,
      reduceMotion: _prefs!.getBool(_keyReduceMotion) ?? false,
      largerTouchTargets: _prefs!.getBool(_keyLargerTouchTargets) ?? false,
      textScaleFactor: _prefs!.getDouble(_keyTextScaleFactor),
      screenReaderOptimized: _prefs!.getBool(_keyScreenReaderOptimized) ?? false,
      boldText: _prefs!.getBool(_keyBoldText) ?? false,
    );
  }

  /// Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    if (_prefs == null) return;

    await _prefs!.setBool(_keyHighContrast, _settings.highContrast);
    await _prefs!.setBool(_keyReduceMotion, _settings.reduceMotion);
    await _prefs!.setBool(_keyLargerTouchTargets, _settings.largerTouchTargets);
    if (_settings.textScaleFactor != null) {
      await _prefs!.setDouble(_keyTextScaleFactor, _settings.textScaleFactor!);
    } else {
      await _prefs!.remove(_keyTextScaleFactor);
    }
    await _prefs!.setBool(_keyScreenReaderOptimized, _settings.screenReaderOptimized);
    await _prefs!.setBool(_keyBoldText, _settings.boldText);
  }

  /// Update accessibility settings
  Future<void> updateSettings(AccessibilitySettings newSettings) async {
    if (_settings == newSettings) return;

    _settings = newSettings;
    await _saveSettings();
    notifyListeners();
    LoggingService.debug('Accessibility settings updated: ${_settings.toJson()}', tag: 'Accessibility');
  }

  /// Set high contrast mode
  Future<void> setHighContrast(bool enabled) async {
    await updateSettings(_settings.copyWith(highContrast: enabled));
  }

  /// Set reduce motion preference
  Future<void> setReduceMotion(bool enabled) async {
    await updateSettings(_settings.copyWith(reduceMotion: enabled));
  }

  /// Set larger touch targets preference
  Future<void> setLargerTouchTargets(bool enabled) async {
    await updateSettings(_settings.copyWith(largerTouchTargets: enabled));
  }

  /// Set custom text scale factor (null to use system default)
  Future<void> setTextScaleFactor(double? factor) async {
    await updateSettings(_settings.copyWith(textScaleFactor: factor));
  }

  /// Set screen reader optimization
  Future<void> setScreenReaderOptimized(bool enabled) async {
    await updateSettings(_settings.copyWith(screenReaderOptimized: enabled));
  }

  /// Set bold text preference
  Future<void> setBoldText(bool enabled) async {
    await updateSettings(_settings.copyWith(boldText: enabled));
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    await updateSettings(const AccessibilitySettings());
  }

  /// Merge user preferences with system accessibility settings
  AccessibilitySettings mergeWithSystem(MediaQueryData mediaQuery) {
    return AccessibilitySettings(
      highContrast: _settings.highContrast || mediaQuery.highContrast,
      reduceMotion: _settings.reduceMotion || mediaQuery.disableAnimations,
      largerTouchTargets: _settings.largerTouchTargets,
      textScaleFactor: _settings.textScaleFactor,
      screenReaderOptimized: _settings.screenReaderOptimized,
      boldText: _settings.boldText || mediaQuery.boldText,
    );
  }

  /// Get the minimum touch target size based on settings
  double get minimumTouchTargetSize {
    return _settings.largerTouchTargets ? 56.0 : 48.0;
  }

  /// Get animation duration based on reduce motion setting
  Duration getAnimationDuration(Duration defaultDuration) {
    if (_settings.reduceMotion) {
      return Duration.zero;
    }
    return defaultDuration;
  }

  /// Check if animations should be shown
  bool get shouldShowAnimations => !_settings.reduceMotion;

  /// Announce a message to screen readers
  static void announce(String message, {TextDirection textDirection = TextDirection.ltr}) {
    SemanticsService.announce(message, textDirection);
  }

  /// Announce a polite message (queued after current announcements)
  static void announcePolite(String message) {
    SemanticsService.announce(message, TextDirection.ltr, assertiveness: Assertiveness.polite);
  }

  /// Announce an assertive message (interrupts current announcements)
  static void announceAssertive(String message) {
    SemanticsService.announce(message, TextDirection.ltr, assertiveness: Assertiveness.assertive);
  }
}

/// InheritedWidget to provide accessibility settings down the widget tree
class AccessibilityProvider extends InheritedNotifier<AccessibilityService> {
  const AccessibilityProvider({
    super.key,
    required AccessibilityService service,
    required super.child,
  }) : super(notifier: service);

  static AccessibilityService of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AccessibilityProvider>();
    return provider?.notifier ?? AccessibilityService();
  }

  static AccessibilitySettings settingsOf(BuildContext context) {
    return of(context).settings;
  }

  static bool shouldReduceMotion(BuildContext context) {
    final service = of(context);
    final mediaQuery = MediaQuery.of(context);
    return service.settings.reduceMotion || mediaQuery.disableAnimations;
  }

  static bool isHighContrast(BuildContext context) {
    final service = of(context);
    final mediaQuery = MediaQuery.of(context);
    return service.settings.highContrast || mediaQuery.highContrast;
  }

  static double minimumTouchTarget(BuildContext context) {
    return of(context).minimumTouchTargetSize;
  }
}
