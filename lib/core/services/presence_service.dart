import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'logging_service.dart';

class PresenceService {
  static const String _logTag = 'PresenceService';
  static const Duration _presenceTimeout = Duration(minutes: 5);
  
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  DatabaseReference? _presenceRef;
  DatabaseReference? _userStatusRef;
  StreamSubscription<DatabaseEvent>? _connectedSubscription;
  Timer? _heartbeatTimer;
  
  bool _isInitialized = false;
  bool _isOnline = false;

  /// Initialize presence service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      LoggingService.warning('Cannot initialize presence service: No authenticated user', tag: _logTag);
      return;
    }

    try {
      // Set up presence references
      _presenceRef = _database.ref('.info/connected');
      _userStatusRef = _database.ref('presence/${currentUser.uid}');
      
      // Listen to connection state
      _connectedSubscription = _presenceRef!.onValue.listen((event) {
        final isConnected = event.snapshot.value as bool? ?? false;
        _handleConnectionChange(isConnected);
      });
      
      // Start heartbeat timer
      _startHeartbeat();
      
      _isInitialized = true;
      LoggingService.info('Presence service initialized', tag: _logTag);
    } catch (e) {
      LoggingService.error('Error initializing presence service: $e', tag: _logTag);
      rethrow;
    }
  }

  /// Handle connection state changes
  void _handleConnectionChange(bool isConnected) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      if (isConnected) {
        // Set user as online
        await _setUserOnline();
        
        // Set up disconnect handler to mark user as offline
        await _userStatusRef!.onDisconnect().update({
          'isOnline': false,
          'lastSeenAt': ServerValue.timestamp,
        });
        
        _isOnline = true;
        LoggingService.info('User marked as online', tag: _logTag);
      } else {
        _isOnline = false;
        LoggingService.info('User disconnected', tag: _logTag);
      }
    } catch (e) {
      LoggingService.error('Error handling connection change: $e', tag: _logTag);
    }
  }

  /// Set user as online
  Future<void> _setUserOnline() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || _userStatusRef == null) return;

    try {
      await _userStatusRef!.update({
        'isOnline': true,
        'lastSeenAt': ServerValue.timestamp,
        'userId': currentUser.uid,
      });
    } catch (e) {
      LoggingService.error('Error setting user online: $e', tag: _logTag);
    }
  }

  /// Start heartbeat to maintain presence
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (_isOnline) {
        _updateHeartbeat();
      }
    });
  }

  /// Update heartbeat timestamp
  Future<void> _updateHeartbeat() async {
    if (_userStatusRef == null) return;

    try {
      await _userStatusRef!.update({
        'lastSeenAt': ServerValue.timestamp,
      });
    } catch (e) {
      LoggingService.error('Error updating heartbeat: $e', tag: _logTag);
    }
  }

  /// Get user's online status
  Future<Map<String, dynamic>?> getUserPresence(String userId) async {
    try {
      final snapshot = await _database.ref('presence/$userId').get();
      if (snapshot.exists && snapshot.value is Map) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return data;
      }
      return null;
    } catch (e) {
      LoggingService.error('Error getting user presence: $e', tag: _logTag);
      return null;
    }
  }

  /// Check if user is online
  Future<bool> isUserOnline(String userId) async {
    final presence = await getUserPresence(userId);
    if (presence == null) return false;
    
    final isOnline = presence['isOnline'] as bool? ?? false;
    final lastSeenAt = presence['lastSeenAt'] as int?;
    
    if (isOnline) return true;
    
    // Check if user was recently active (within timeout period)
    if (lastSeenAt != null) {
      final lastSeen = DateTime.fromMillisecondsSinceEpoch(lastSeenAt);
      final now = DateTime.now();
      return now.difference(lastSeen) < _presenceTimeout;
    }
    
    return false;
  }

  /// Get multiple users' online status
  Future<Map<String, bool>> getUsersOnlineStatus(List<String> userIds) async {
    final results = <String, bool>{};
    
    try {
      // Batch get presence data
      final futures = userIds.map((userId) => getUserPresence(userId));
      final presenceData = await Future.wait(futures);
      
      for (int i = 0; i < userIds.length; i++) {
        final userId = userIds[i];
        final presence = presenceData[i];
        
        if (presence != null) {
          final isOnline = presence['isOnline'] as bool? ?? false;
          final lastSeenAt = presence['lastSeenAt'] as int?;
          
          if (isOnline) {
            results[userId] = true;
          } else if (lastSeenAt != null) {
            final lastSeen = DateTime.fromMillisecondsSinceEpoch(lastSeenAt);
            final now = DateTime.now();
            results[userId] = now.difference(lastSeen) < _presenceTimeout;
          } else {
            results[userId] = false;
          }
        } else {
          results[userId] = false;
        }
      }
    } catch (e) {
      LoggingService.error('Error getting users online status: $e', tag: _logTag);
      // Return all false if error
      for (final userId in userIds) {
        results[userId] = false;
      }
    }
    
    return results;
  }

  /// Listen to user's presence changes
  Stream<bool> listenToUserPresence(String userId) {
    return _database.ref('presence/$userId').onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value is! Map) return false;
      
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final isOnline = data['isOnline'] as bool? ?? false;
      final lastSeenAt = data['lastSeenAt'] as int?;
      
      if (isOnline) return true;
      
      if (lastSeenAt != null) {
        final lastSeen = DateTime.fromMillisecondsSinceEpoch(lastSeenAt);
        final now = DateTime.now();
        return now.difference(lastSeen) < _presenceTimeout;
      }
      
      return false;
    });
  }

  /// Set user as offline (call when app goes to background)
  Future<void> setOffline() async {
    if (_userStatusRef == null) return;

    try {
      await _userStatusRef!.update({
        'isOnline': false,
        'lastSeenAt': ServerValue.timestamp,
      });
      _isOnline = false;
      LoggingService.info('User marked as offline', tag: _logTag);
    } catch (e) {
      LoggingService.error('Error setting user offline: $e', tag: _logTag);
    }
  }

  /// Set user as online (call when app comes to foreground)
  Future<void> setOnline() async {
    if (_userStatusRef == null) return;

    try {
      await _setUserOnline();
      _isOnline = true;
      LoggingService.info('User marked as online', tag: _logTag);
    } catch (e) {
      LoggingService.error('Error setting user online: $e', tag: _logTag);
    }
  }

  /// Dispose resources
  void dispose() {
    _connectedSubscription?.cancel();
    _heartbeatTimer?.cancel();
    _isInitialized = false;
    LoggingService.info('Presence service disposed', tag: _logTag);
  }

  /// Get current user's online status
  bool get isCurrentUserOnline => _isOnline;
} 