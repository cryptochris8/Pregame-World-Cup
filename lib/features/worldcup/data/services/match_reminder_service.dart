import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/match_reminder.dart';
import '../../domain/entities/world_cup_match.dart';
import '../../../../core/services/logging_service.dart';

/// Service for managing match reminders
class MatchReminderService {
  static const String _logTag = 'MatchReminder';
  static const String _collection = 'match_reminders';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // In-memory cache of user's reminders
  final Map<String, MatchReminder> _remindersCache = {};
  bool _cacheInitialized = false;

  /// Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  /// Initialize service and load user's reminders
  Future<void> initialize() async {
    if (_cacheInitialized) return;

    final userId = _currentUserId;
    if (userId == null) {
      LoggingService.info('No user logged in, skipping reminder init', tag: _logTag);
      return;
    }

    try {
      LoggingService.info('Loading reminders for user $userId', tag: _logTag);
      final reminders = await getUserReminders();
      for (final reminder in reminders) {
        _remindersCache[reminder.matchId] = reminder;
      }
      _cacheInitialized = true;
      LoggingService.info('Loaded ${reminders.length} reminders', tag: _logTag);
    } catch (e) {
      LoggingService.error('Error initializing reminders: $e', tag: _logTag);
    }
  }

  /// Set a reminder for a match
  Future<MatchReminder?> setReminder({
    required WorldCupMatch match,
    ReminderTiming timing = ReminderTiming.thirtyMinutes,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      LoggingService.error('Cannot set reminder: No user logged in', tag: _logTag);
      return null;
    }

    if (match.dateTimeUtc == null) {
      LoggingService.error('Cannot set reminder: Match has no date', tag: _logTag);
      return null;
    }

    // Check if match is in the past
    if (match.dateTimeUtc!.isBefore(DateTime.now().toUtc())) {
      LoggingService.info('Cannot set reminder: Match already started', tag: _logTag);
      return null;
    }

    try {
      // Check if reminder already exists
      final existingReminder = await getReminder(match.matchId);
      if (existingReminder != null) {
        // Update existing reminder
        return await updateReminder(
          existingReminder.reminderId,
          timing: timing,
          isEnabled: true,
        );
      }

      // Create new reminder
      final reminder = MatchReminder.create(
        userId: userId,
        matchId: match.matchId,
        matchName: '${match.homeTeamName} vs ${match.awayTeamName}',
        matchDateTimeUtc: match.dateTimeUtc!,
        timing: timing,
        homeTeamCode: match.homeTeamCode,
        awayTeamCode: match.awayTeamCode,
        homeTeamName: match.homeTeamName,
        awayTeamName: match.awayTeamName,
        venueName: match.venueName,
      );

      await _firestore
          .collection(_collection)
          .doc(reminder.reminderId)
          .set(reminder.toFirestore());

      _remindersCache[match.matchId] = reminder;
      LoggingService.info('Set reminder for ${reminder.matchName}', tag: _logTag);

      return reminder;
    } catch (e) {
      LoggingService.error('Error setting reminder: $e', tag: _logTag);
      return null;
    }
  }

  /// Get reminder for a specific match
  Future<MatchReminder?> getReminder(String matchId) async {
    // Check cache first
    if (_remindersCache.containsKey(matchId)) {
      return _remindersCache[matchId];
    }

    final userId = _currentUserId;
    if (userId == null) return null;

    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('matchId', isEqualTo: matchId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final reminder = MatchReminder.fromFirestore(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );
      _remindersCache[matchId] = reminder;
      return reminder;
    } catch (e) {
      LoggingService.error('Error getting reminder: $e', tag: _logTag);
      return null;
    }
  }

  /// Check if a reminder is set for a match
  Future<bool> hasReminder(String matchId) async {
    if (_remindersCache.containsKey(matchId)) {
      final reminder = _remindersCache[matchId]!;
      return reminder.isEnabled && !reminder.isSent;
    }
    final reminder = await getReminder(matchId);
    return reminder != null && reminder.isEnabled && !reminder.isSent;
  }

  /// Get all reminders for current user
  Future<List<MatchReminder>> getUserReminders() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('isEnabled', isEqualTo: true)
          .orderBy('matchDateTimeUtc')
          .get();

      return snapshot.docs
          .map((doc) => MatchReminder.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      LoggingService.error('Error getting user reminders: $e', tag: _logTag);
      return [];
    }
  }

  /// Get upcoming reminders (not yet sent, match not started)
  Future<List<MatchReminder>> getUpcomingReminders() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      final now = DateTime.now().toUtc();
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('isEnabled', isEqualTo: true)
          .where('isSent', isEqualTo: false)
          .where('matchDateTimeUtc', isGreaterThan: Timestamp.fromDate(now))
          .orderBy('matchDateTimeUtc')
          .get();

      return snapshot.docs
          .map((doc) => MatchReminder.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      LoggingService.error('Error getting upcoming reminders: $e', tag: _logTag);
      return [];
    }
  }

  /// Update a reminder
  Future<MatchReminder?> updateReminder(
    String reminderId, {
    ReminderTiming? timing,
    bool? isEnabled,
  }) async {
    try {
      // Get current reminder
      final doc = await _firestore.collection(_collection).doc(reminderId).get();
      if (!doc.exists) return null;

      final currentReminder = MatchReminder.fromFirestore(doc.data()!, doc.id);
      final updatedReminder = currentReminder.copyWith(
        timing: timing,
        isEnabled: isEnabled,
      );

      await _firestore
          .collection(_collection)
          .doc(reminderId)
          .update(updatedReminder.toFirestore());

      _remindersCache[updatedReminder.matchId] = updatedReminder;
      LoggingService.info('Updated reminder $reminderId', tag: _logTag);

      return updatedReminder;
    } catch (e) {
      LoggingService.error('Error updating reminder: $e', tag: _logTag);
      return null;
    }
  }

  /// Remove/disable a reminder
  Future<bool> removeReminder(String matchId) async {
    final userId = _currentUserId;
    if (userId == null) return false;

    try {
      // Find reminder by matchId
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('matchId', isEqualTo: matchId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return true;

      // Delete the reminder
      await _firestore
          .collection(_collection)
          .doc(snapshot.docs.first.id)
          .delete();

      _remindersCache.remove(matchId);
      LoggingService.info('Removed reminder for match $matchId', tag: _logTag);

      return true;
    } catch (e) {
      LoggingService.error('Error removing reminder: $e', tag: _logTag);
      return false;
    }
  }

  /// Toggle reminder for a match
  Future<MatchReminder?> toggleReminder({
    required WorldCupMatch match,
    ReminderTiming timing = ReminderTiming.thirtyMinutes,
  }) async {
    final hasExisting = await hasReminder(match.matchId);

    if (hasExisting) {
      await removeReminder(match.matchId);
      return null;
    } else {
      return await setReminder(match: match, timing: timing);
    }
  }

  /// Clear cache (call on logout)
  void clearCache() {
    _remindersCache.clear();
    _cacheInitialized = false;
  }

  /// Get cached reminder status (sync, for UI)
  bool hasReminderCached(String matchId) {
    final reminder = _remindersCache[matchId];
    return reminder != null && reminder.isEnabled && !reminder.isSent;
  }

  /// Get cached reminder timing
  ReminderTiming? getReminderTimingCached(String matchId) {
    return _remindersCache[matchId]?.timing;
  }
}
