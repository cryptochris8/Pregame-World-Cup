import 'dart:io';

import 'package:flutter/services.dart';

import '../../features/match_chat/domain/entities/match_chat.dart';
import 'logging_service.dart';

/// Service for providing haptic feedback during World Cup match events.
///
/// Creates distinct vibration patterns for different match moments:
/// goals, cards, penalties, whistles, etc. Only triggers on iOS/Android.
class HapticService {
  static const String _logTag = 'Haptic';

  /// Whether haptic feedback is enabled by the user.
  bool _enabled = true;
  bool get enabled => _enabled;

  /// Toggle haptic feedback on or off.
  set enabled(bool value) {
    _enabled = value;
    LoggingService.debug(
      'Haptic feedback ${value ? "enabled" : "disabled"}',
      tag: _logTag,
    );
  }

  /// Whether the current platform supports haptic feedback.
  bool get _isSupported {
    try {
      return Platform.isIOS || Platform.isAndroid;
    } catch (_) {
      return false;
    }
  }

  /// Goal scored — the most intense pattern: heavy + medium + heavy.
  Future<void> onGoal() async {
    if (!_shouldTrigger) return;
    LoggingService.debug('Haptic: goal', tag: _logTag);
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  /// Red card — sharp double vibration.
  Future<void> onRedCard() async {
    if (!_shouldTrigger) return;
    LoggingService.debug('Haptic: red card', tag: _logTag);
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.vibrate();
  }

  /// Penalty awarded — medium impact with a pause then a light tap.
  Future<void> onPenaltyAwarded() async {
    if (!_shouldTrigger) return;
    LoggingService.debug('Haptic: penalty awarded', tag: _logTag);
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await HapticFeedback.lightImpact();
  }

  /// Final whistle — celebratory triple medium pattern.
  Future<void> onFinalWhistle() async {
    if (!_shouldTrigger) return;
    LoggingService.debug('Haptic: final whistle', tag: _logTag);
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    await HapticFeedback.mediumImpact();
  }

  /// Match start / kickoff — single medium impact.
  Future<void> onMatchStart() async {
    if (!_shouldTrigger) return;
    LoggingService.debug('Haptic: match start', tag: _logTag);
    await HapticFeedback.mediumImpact();
  }

  /// Yellow card — single light impact.
  Future<void> onYellowCard() async {
    if (!_shouldTrigger) return;
    LoggingService.debug('Haptic: yellow card', tag: _logTag);
    await HapticFeedback.lightImpact();
  }

  /// Substitution — subtle selection click.
  Future<void> onSubstitution() async {
    if (!_shouldTrigger) return;
    LoggingService.debug('Haptic: substitution', tag: _logTag);
    await HapticFeedback.selectionClick();
  }

  /// Route a [MatchEventType] to the appropriate haptic pattern.
  Future<void> onMatchEvent(MatchEventType event) async {
    switch (event) {
      case MatchEventType.goal:
      case MatchEventType.ownGoal:
        return onGoal();
      case MatchEventType.redCard:
        return onRedCard();
      case MatchEventType.penalty:
      case MatchEventType.penaltyMissed:
        return onPenaltyAwarded();
      case MatchEventType.fulltime:
        return onFinalWhistle();
      case MatchEventType.kickoff:
        return onMatchStart();
      case MatchEventType.yellowCard:
        return onYellowCard();
      case MatchEventType.substitution:
        return onSubstitution();
      case MatchEventType.halftime:
        return onMatchStart();
      case MatchEventType.varReview:
      case MatchEventType.injury:
      case MatchEventType.other:
        return onYellowCard();
    }
  }

  /// Whether haptic feedback should fire right now.
  bool get _shouldTrigger => _enabled && _isSupported;
}
