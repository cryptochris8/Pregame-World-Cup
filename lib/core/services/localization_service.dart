import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'logging_service.dart';

/// Supported app languages
enum AppLanguage {
  system('system', 'System Default', null),
  english('en', 'English', Locale('en')),
  spanish('es', 'Español', Locale('es')),
  portuguese('pt', 'Português', Locale('pt')),
  french('fr', 'Français', Locale('fr'));

  final String code;
  final String displayName;
  final Locale? locale;

  const AppLanguage(this.code, this.displayName, this.locale);

  /// Get language from code
  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.system,
    );
  }

  /// Get native name for each language
  String get nativeName {
    switch (this) {
      case AppLanguage.system:
        return 'System Default';
      case AppLanguage.english:
        return 'English';
      case AppLanguage.spanish:
        return 'Español';
      case AppLanguage.portuguese:
        return 'Português';
      case AppLanguage.french:
        return 'Français';
    }
  }

  /// Get flag emoji for each language
  String get flagEmoji {
    switch (this) {
      case AppLanguage.system:
        return '🌐';
      case AppLanguage.english:
        return '🇺🇸';
      case AppLanguage.spanish:
        return '🇲🇽';
      case AppLanguage.portuguese:
        return '🇧🇷';
      case AppLanguage.french:
        return '🇨🇦';
    }
  }
}

/// Service for managing app localization
class LocalizationService extends ChangeNotifier {
  static const String _logTag = 'LocalizationService';
  static const String _languageKey = 'app_language';
  static LocalizationService? _instance;

  final SharedPreferences _prefs;
  AppLanguage _currentLanguage = AppLanguage.system;
  Locale? _currentLocale;

  /// Supported locales for the app
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('es'), // Spanish
    Locale('pt'), // Portuguese
    Locale('fr'), // French
  ];

  LocalizationService._(this._prefs) {
    _loadSavedLanguage();
  }

  /// Get singleton instance
  static Future<LocalizationService> getInstance() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = LocalizationService._(prefs);
    }
    return _instance!;
  }

  /// Get instance synchronously (must call getInstance first)
  static LocalizationService get instance {
    if (_instance == null) {
      throw StateError('LocalizationService not initialized. Call getInstance() first.');
    }
    return _instance!;
  }

  /// Current selected language
  AppLanguage get currentLanguage => _currentLanguage;

  /// Current locale (resolved from language setting)
  Locale get currentLocale => _currentLocale ?? _getSystemLocale();

  /// Check if using system language
  bool get isUsingSystemLanguage => _currentLanguage == AppLanguage.system;

  /// Load saved language preference
  void _loadSavedLanguage() {
    final savedCode = _prefs.getString(_languageKey);
    if (savedCode != null) {
      _currentLanguage = AppLanguage.fromCode(savedCode);
      _currentLocale = _resolveLocale(_currentLanguage);
      LoggingService.debug(
        'Loaded saved language: ${_currentLanguage.displayName}',
        tag: _logTag,
      );
    } else {
      _currentLanguage = AppLanguage.system;
      _currentLocale = _getSystemLocale();
      LoggingService.debug(
        'Using system language: ${_currentLocale?.languageCode}',
        tag: _logTag,
      );
    }
  }

  /// Set app language
  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage == language) return;

    _currentLanguage = language;
    _currentLocale = _resolveLocale(language);

    await _prefs.setString(_languageKey, language.code);

    LoggingService.info(
      'Language changed to: ${language.displayName}',
      tag: _logTag,
    );

    notifyListeners();
  }

  /// Resolve locale from language setting
  Locale _resolveLocale(AppLanguage language) {
    if (language == AppLanguage.system) {
      return _getSystemLocale();
    }
    return language.locale ?? const Locale('en');
  }

  /// Get system locale, falling back to English if not supported
  Locale _getSystemLocale() {
    final systemLocale = ui.PlatformDispatcher.instance.locale;

    // Check if system locale is supported
    for (final supported in supportedLocales) {
      if (supported.languageCode == systemLocale.languageCode) {
        return supported;
      }
    }

    // Default to English
    return const Locale('en');
  }

  /// Detect language from device settings
  static AppLanguage detectSystemLanguage() {
    final systemLocale = ui.PlatformDispatcher.instance.locale;
    final languageCode = systemLocale.languageCode;

    for (final language in AppLanguage.values) {
      if (language.locale?.languageCode == languageCode) {
        return language;
      }
    }

    return AppLanguage.english;
  }

  /// Get display name for current locale
  String get currentLanguageDisplayName {
    if (_currentLanguage == AppLanguage.system) {
      final systemLanguage = detectSystemLanguage();
      return 'System (${systemLanguage.nativeName})';
    }
    return _currentLanguage.nativeName;
  }

  /// Locale resolution callback for MaterialApp
  static Locale? localeResolutionCallback(
    Locale? locale,
    Iterable<Locale> supportedLocales,
  ) {
    if (locale == null) {
      return supportedLocales.first;
    }

    // Check for exact match
    for (final supported in supportedLocales) {
      if (supported.languageCode == locale.languageCode &&
          supported.countryCode == locale.countryCode) {
        return supported;
      }
    }

    // Check for language match
    for (final supported in supportedLocales) {
      if (supported.languageCode == locale.languageCode) {
        return supported;
      }
    }

    // Default to first supported locale
    return supportedLocales.first;
  }

  /// Get all available languages for selection
  List<AppLanguage> get availableLanguages => AppLanguage.values.toList();

  /// Check if a locale is supported
  static bool isLocaleSupported(Locale locale) {
    return supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }
}
