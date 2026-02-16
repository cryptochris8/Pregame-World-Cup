import 'package:flutter/material.dart';
import 'package:pregame_world_cup/l10n/app_localizations.dart';

/// Wraps a widget with MaterialApp that includes localization support for testing.
///
/// Use this instead of `MaterialApp(home: ...)` when the widget under test
/// uses `AppLocalizations.of(context)`.
Widget buildTestableWidget(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

/// The localization delegates needed for tests.
///
/// Add these to an existing MaterialApp when you cannot use [buildTestableWidget]:
/// ```dart
/// MaterialApp(
///   localizationsDelegates: testLocalizationsDelegates,
///   supportedLocales: testSupportedLocales,
///   home: MyWidget(),
/// )
/// ```
const testLocalizationsDelegates = AppLocalizations.localizationsDelegates;

/// The supported locales needed for tests.
const testSupportedLocales = AppLocalizations.supportedLocales;
