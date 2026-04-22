/// Compile-time feature flags for gating gambling-adjacent features.
///
/// All flags default to **true** so standard (full-feature) builds behave
/// unchanged. The stripped iOS WC build passes `--dart-define=FEATURE_X=false`
/// for each flag in `codemagic.yaml`, which disables the gated UI at
/// compile time.
///
/// WHY THIS EXISTS
/// Apple rejected Pregame World Cup under the 2026 policy that restricts
/// apps with prediction/contest/odds features to Organization accounts.
/// Until our LLC's Organization account is approved, the Pregame WC
/// submission strips these features via these flags. The underlying
/// feature code is preserved so the Pregame-Template can still light
/// them up for future Organization-account apps (CFB, NFL, etc.).
///
/// USAGE
/// ```dart
/// if (FeatureFlags.predictionsEnabled) {
///   // Predictions UI here
/// }
/// ```
///
/// For widget returns, prefer the convenience helpers:
/// ```dart
/// FeatureFlags.maybe(FeatureFlags.predictionsEnabled, MyPredictionWidget())
/// ```
///
/// Or for a list of children, `FeatureFlags.whenEnabled` filters nulls out:
/// ```dart
/// Column(children: [
///   const HeaderWidget(),
///   ...FeatureFlags.whenEnabled(FeatureFlags.predictionsEnabled, [
///     const PredictionCard(),
///   ]),
/// ])
/// ```
library;

import 'package:flutter/material.dart';

/// Central registry of compile-time feature toggles. Flipping one of these
/// via `--dart-define` produces a different build variant with the gated
/// feature compiled out.
class FeatureFlags {
  FeatureFlags._();

  /// Gate: user-submitted predictions / "Make Your Prediction" modal,
  /// save-prediction flow, saved-pick indicators, prediction cards.
  static const bool predictionsEnabled = bool.fromEnvironment(
    'FEATURE_PREDICTIONS',
    defaultValue: true,
  );

  /// Gate: prediction leaderboard, rankings, transaction history,
  /// prediction statistics screens.
  static const bool predictionLeaderboardEnabled = bool.fromEnvironment(
    'FEATURE_PREDICTION_LEADERBOARD',
    defaultValue: true,
  );

  /// Gate: any third-party bookmaker odds (DraftKings, BetMGM, bet365, etc.),
  /// implied probability % from betting markets, power rankings, dark horse
  /// picks, analyst predictions sourced from betting markets.
  static const bool bettingOddsEnabled = bool.fromEnvironment(
    'FEATURE_BETTING_ODDS',
    defaultValue: true,
  );

  /// Gate: AI-generated win-probability percentages (Home/Draw/Away %).
  /// Even though these come from our own prediction engine and not from
  /// betting markets, they can be read as handicapping. Disable for
  /// non-gambling submissions.
  static const bool aiProbabilityEnabled = bool.fromEnvironment(
    'FEATURE_AI_PROBABILITY',
    defaultValue: true,
  );

  /// Gate: Fan Pass / Superfan premium subscription tiers, the paid-features
  /// upgrade flow, IAP product buttons. When disabled, the app operates as
  /// an entirely free experience.
  static const bool fanPassEnabled = bool.fromEnvironment(
    'FEATURE_FAN_PASS',
    defaultValue: true,
  );

  /// Returns [widget] if [enabled] is true, otherwise a zero-sized
  /// [SizedBox.shrink]. Useful for inline conditional rendering in
  /// widget trees without restructuring `children:` lists.
  static Widget maybe(bool enabled, Widget widget) {
    return enabled ? widget : const SizedBox.shrink();
  }

  /// Returns [widgets] when [enabled] is true, otherwise an empty list.
  /// Spread into a children list with `...FeatureFlags.whenEnabled(...)`.
  static List<Widget> whenEnabled(bool enabled, List<Widget> widgets) {
    return enabled ? widgets : const <Widget>[];
  }

  /// Minimal Scaffold shown when a gated standalone screen is reached
  /// via deep-link / direct navigation even though its entry points are
  /// hidden. Gives the user a back button and a non-committal message
  /// instead of a crash or a half-rendered screen.
  static Widget unavailableScaffold() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'This feature is not available in this version of the app.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      ),
    );
  }

  /// Dump all flag states. Useful for debug logs and diagnostic screens.
  static Map<String, bool> snapshot() {
    return {
      'predictionsEnabled': predictionsEnabled,
      'predictionLeaderboardEnabled': predictionLeaderboardEnabled,
      'bettingOddsEnabled': bettingOddsEnabled,
      'aiProbabilityEnabled': aiProbabilityEnabled,
      'fanPassEnabled': fanPassEnabled,
    };
  }
}
