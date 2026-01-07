import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/user_preferences_repository.dart';
import '../../../../core/services/logging_service.dart';

/// Implementation of UserPreferencesRepository using SharedPreferences
/// Also syncs favorite teams to Firestore for Cloud Functions access
class UserPreferencesRepositoryImpl implements UserPreferencesRepository {
  static const String _preferencesKey = 'world_cup_user_preferences';
  static const String _logTag = 'UserPreferencesRepo';

  final SharedPreferences _sharedPreferences;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final StreamController<UserPreferences> _preferencesController =
      StreamController<UserPreferences>.broadcast();

  UserPreferences? _cachedPreferences;

  UserPreferencesRepositoryImpl({
    required SharedPreferences sharedPreferences,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _sharedPreferences = sharedPreferences,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<UserPreferences> getPreferences() async {
    if (_cachedPreferences != null) {
      return _cachedPreferences!;
    }

    final jsonString = _sharedPreferences.getString(_preferencesKey);
    if (jsonString != null) {
      try {
        final map = json.decode(jsonString) as Map<String, dynamic>;
        _cachedPreferences = UserPreferences.fromMap(map);
        return _cachedPreferences!;
      } catch (e) {
        // If parsing fails, return empty preferences
        return UserPreferences.empty();
      }
    }

    return UserPreferences.empty();
  }

  @override
  Future<void> savePreferences(UserPreferences preferences) async {
    _cachedPreferences = preferences;
    final jsonString = json.encode(preferences.toMap());
    await _sharedPreferences.setString(_preferencesKey, jsonString);
    _preferencesController.add(preferences);

    // Sync to Firestore for Cloud Functions access
    await _syncToFirestore(preferences);
  }

  /// Syncs favorite teams and notification settings to Firestore
  /// This allows Cloud Functions to query users with favorite teams
  Future<void> _syncToFirestore(UserPreferences preferences) async {
    final user = _auth.currentUser;
    if (user == null) {
      LoggingService.info('No user signed in, skipping Firestore sync', tag: _logTag);
      return;
    }

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'favoriteTeamCodes': preferences.favoriteTeamCodes,
        'notifyFavoriteTeamMatches': preferences.notifyFavoriteTeamMatches,
        'notifyLiveUpdates': preferences.notifyLiveUpdates,
        'notifyGoals': preferences.notifyGoals,
        'preferencesUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      LoggingService.info(
        'Synced preferences to Firestore: ${preferences.favoriteTeamCodes.length} teams',
        tag: _logTag,
      );
    } catch (e) {
      LoggingService.error('Error syncing preferences to Firestore: $e', tag: _logTag);
      // Don't throw - local save succeeded, Firestore sync is best-effort
    }
  }

  @override
  Stream<UserPreferences> watchPreferences() {
    // Emit current value immediately
    getPreferences().then((prefs) {
      _preferencesController.add(prefs);
    });
    return _preferencesController.stream;
  }

  @override
  Future<UserPreferences> addFavoriteTeam(String teamCode) async {
    final prefs = await getPreferences();
    final updated = prefs.addFavoriteTeam(teamCode);
    await savePreferences(updated);
    return updated;
  }

  @override
  Future<UserPreferences> removeFavoriteTeam(String teamCode) async {
    final prefs = await getPreferences();
    final updated = prefs.removeFavoriteTeam(teamCode);
    await savePreferences(updated);
    return updated;
  }

  @override
  Future<UserPreferences> toggleFavoriteTeam(String teamCode) async {
    final prefs = await getPreferences();
    final updated = prefs.toggleFavoriteTeam(teamCode);
    await savePreferences(updated);
    return updated;
  }

  @override
  Future<UserPreferences> addFavoriteMatch(String matchId) async {
    final prefs = await getPreferences();
    final updated = prefs.addFavoriteMatch(matchId);
    await savePreferences(updated);
    return updated;
  }

  @override
  Future<UserPreferences> removeFavoriteMatch(String matchId) async {
    final prefs = await getPreferences();
    final updated = prefs.removeFavoriteMatch(matchId);
    await savePreferences(updated);
    return updated;
  }

  @override
  Future<UserPreferences> toggleFavoriteMatch(String matchId) async {
    final prefs = await getPreferences();
    final updated = prefs.toggleFavoriteMatch(matchId);
    await savePreferences(updated);
    return updated;
  }

  @override
  Future<bool> isTeamFavorite(String teamCode) async {
    final prefs = await getPreferences();
    return prefs.isTeamFavorite(teamCode);
  }

  @override
  Future<bool> isMatchFavorite(String matchId) async {
    final prefs = await getPreferences();
    return prefs.isMatchFavorite(matchId);
  }

  @override
  Future<List<String>> getFavoriteTeamCodes() async {
    final prefs = await getPreferences();
    return prefs.favoriteTeamCodes;
  }

  @override
  Future<List<String>> getFavoriteMatchIds() async {
    final prefs = await getPreferences();
    return prefs.favoriteMatchIds;
  }

  @override
  Future<UserPreferences> updateNotificationSettings({
    bool? notifyFavoriteTeamMatches,
    bool? notifyLiveUpdates,
    bool? notifyGoals,
  }) async {
    final prefs = await getPreferences();
    final updated = prefs.copyWith(
      notifyFavoriteTeamMatches: notifyFavoriteTeamMatches,
      notifyLiveUpdates: notifyLiveUpdates,
      notifyGoals: notifyGoals,
      updatedAt: DateTime.now(),
    );
    await savePreferences(updated);
    return updated;
  }

  @override
  Future<void> clearPreferences() async {
    _cachedPreferences = null;
    await _sharedPreferences.remove(_preferencesKey);
    _preferencesController.add(UserPreferences.empty());
  }

  /// Dispose of resources
  void dispose() {
    _preferencesController.close();
  }
}
