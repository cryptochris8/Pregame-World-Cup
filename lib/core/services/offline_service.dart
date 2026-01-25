import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'logging_service.dart';

/// Represents the current connectivity state
enum ConnectivityState {
  online,
  offline,
  syncing,
}

/// Represents a queued action to be executed when online
class QueuedAction {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;

  const QueuedAction({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
  });

  QueuedAction copyWith({int? retryCount}) {
    return QueuedAction(
      id: id,
      type: type,
      data: data,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
    };
  }

  factory QueuedAction.fromMap(Map<String, dynamic> map) {
    return QueuedAction(
      id: map['id'] as String,
      type: map['type'] as String,
      data: Map<String, dynamic>.from(map['data'] as Map),
      createdAt: DateTime.parse(map['createdAt'] as String),
      retryCount: map['retryCount'] as int? ?? 0,
    );
  }
}

/// Sync status information
class SyncStatus {
  final bool isSyncing;
  final int pendingActions;
  final int completedActions;
  final int failedActions;
  final DateTime? lastSyncTime;
  final String? currentAction;
  final String? errorMessage;

  const SyncStatus({
    this.isSyncing = false,
    this.pendingActions = 0,
    this.completedActions = 0,
    this.failedActions = 0,
    this.lastSyncTime,
    this.currentAction,
    this.errorMessage,
  });

  double get progress {
    final total = pendingActions + completedActions + failedActions;
    if (total == 0) return 1.0;
    return (completedActions + failedActions) / total;
  }

  bool get hasErrors => failedActions > 0;

  SyncStatus copyWith({
    bool? isSyncing,
    int? pendingActions,
    int? completedActions,
    int? failedActions,
    DateTime? lastSyncTime,
    String? currentAction,
    String? errorMessage,
  }) {
    return SyncStatus(
      isSyncing: isSyncing ?? this.isSyncing,
      pendingActions: pendingActions ?? this.pendingActions,
      completedActions: completedActions ?? this.completedActions,
      failedActions: failedActions ?? this.failedActions,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      currentAction: currentAction ?? this.currentAction,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Type definition for action handlers
typedef ActionHandler = Future<bool> Function(QueuedAction action);

/// Service for managing offline mode, connectivity, and action queuing
class OfflineService extends ChangeNotifier {
  static const String _logTag = 'OfflineService';
  static const String _queueKey = 'offline_action_queue';
  static const String _lastSyncKey = 'offline_last_sync';
  static const int _maxRetries = 3;
  static OfflineService? _instance;

  final Connectivity _connectivity;
  final SharedPreferences _prefs;

  ConnectivityState _state = ConnectivityState.online;
  SyncStatus _syncStatus = const SyncStatus();
  List<QueuedAction> _actionQueue = [];
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;

  // Registered action handlers
  final Map<String, ActionHandler> _actionHandlers = {};

  OfflineService._({
    required SharedPreferences prefs,
    Connectivity? connectivity,
  })  : _prefs = prefs,
        _connectivity = connectivity ?? Connectivity() {
    _initialize();
  }

  /// Get singleton instance
  static Future<OfflineService> getInstance() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = OfflineService._(prefs: prefs);
    }
    return _instance!;
  }

  /// Get instance synchronously (must call getInstance first)
  static OfflineService get instance {
    if (_instance == null) {
      throw StateError('OfflineService not initialized. Call getInstance() first.');
    }
    return _instance!;
  }

  /// Current connectivity state
  ConnectivityState get state => _state;

  /// Whether currently online
  bool get isOnline => _state == ConnectivityState.online;

  /// Whether currently offline
  bool get isOffline => _state == ConnectivityState.offline;

  /// Whether currently syncing
  bool get isSyncing => _state == ConnectivityState.syncing;

  /// Current sync status
  SyncStatus get syncStatus => _syncStatus;

  /// Number of pending actions in queue
  int get pendingActionsCount => _actionQueue.length;

  /// Whether there are pending actions
  bool get hasPendingActions => _actionQueue.isNotEmpty;

  /// Last successful sync time
  DateTime? get lastSyncTime {
    final timestamp = _prefs.getString(_lastSyncKey);
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }

  /// Initialize the service
  Future<void> _initialize() async {
    // Load queued actions from storage
    await _loadQueue();

    // Check initial connectivity
    await _checkConnectivity();

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );

    LoggingService.info(
      'OfflineService initialized. State: $_state, Pending: ${_actionQueue.length}',
      tag: _logTag,
    );
  }

  /// Check current connectivity
  Future<void> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateState(results);
    } catch (e) {
      LoggingService.error('Error checking connectivity: $e', tag: _logTag);
      _state = ConnectivityState.offline;
      notifyListeners();
    }
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final wasOffline = _state == ConnectivityState.offline;
    _updateState(results);

    // If we just came back online, sync pending actions
    if (wasOffline && _state == ConnectivityState.online && _actionQueue.isNotEmpty) {
      _syncPendingActions();
    }
  }

  /// Update state based on connectivity results
  void _updateState(List<ConnectivityResult> results) {
    final hasConnection = results.any(
      (r) => r != ConnectivityResult.none,
    );

    final newState = hasConnection
        ? (_isSyncing ? ConnectivityState.syncing : ConnectivityState.online)
        : ConnectivityState.offline;

    if (_state != newState) {
      _state = newState;
      LoggingService.info('Connectivity changed: $_state', tag: _logTag);
      notifyListeners();
    }
  }

  /// Register an action handler for a specific action type
  void registerActionHandler(String type, ActionHandler handler) {
    _actionHandlers[type] = handler;
    LoggingService.debug('Registered handler for action type: $type', tag: _logTag);
  }

  /// Unregister an action handler
  void unregisterActionHandler(String type) {
    _actionHandlers.remove(type);
  }

  /// Queue an action to be executed when online
  Future<void> queueAction({
    required String type,
    required Map<String, dynamic> data,
  }) async {
    final action = QueuedAction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      data: data,
      createdAt: DateTime.now(),
    );

    _actionQueue.add(action);
    await _saveQueue();

    _syncStatus = _syncStatus.copyWith(
      pendingActions: _actionQueue.length,
    );

    LoggingService.info('Queued action: ${action.type}', tag: _logTag);
    notifyListeners();

    // If online, execute immediately
    if (isOnline) {
      _syncPendingActions();
    }
  }

  /// Execute an action immediately if online, or queue it
  Future<bool> executeOrQueue({
    required String type,
    required Map<String, dynamic> data,
    required Future<bool> Function() onlineAction,
  }) async {
    if (isOnline) {
      try {
        return await onlineAction();
      } catch (e) {
        LoggingService.error('Action failed, queuing: $e', tag: _logTag);
        await queueAction(type: type, data: data);
        return false;
      }
    } else {
      await queueAction(type: type, data: data);
      return false;
    }
  }

  /// Sync all pending actions
  Future<void> _syncPendingActions() async {
    if (_isSyncing || _actionQueue.isEmpty) return;

    _isSyncing = true;
    _state = ConnectivityState.syncing;

    int completed = 0;
    int failed = 0;
    final actionsToRemove = <String>[];

    _syncStatus = _syncStatus.copyWith(
      isSyncing: true,
      pendingActions: _actionQueue.length,
      completedActions: 0,
      failedActions: 0,
    );
    notifyListeners();

    for (final action in List<QueuedAction>.from(_actionQueue)) {
      final handler = _actionHandlers[action.type];

      if (handler == null) {
        LoggingService.warning(
          'No handler for action type: ${action.type}',
          tag: _logTag,
        );
        failed++;
        continue;
      }

      _syncStatus = _syncStatus.copyWith(
        currentAction: action.type,
      );
      notifyListeners();

      try {
        final success = await handler(action);

        if (success) {
          completed++;
          actionsToRemove.add(action.id);
          LoggingService.info('Action completed: ${action.type}', tag: _logTag);
        } else {
          // Increment retry count
          final index = _actionQueue.indexWhere((a) => a.id == action.id);
          if (index != -1) {
            final updatedAction = action.copyWith(retryCount: action.retryCount + 1);

            if (updatedAction.retryCount >= _maxRetries) {
              failed++;
              actionsToRemove.add(action.id);
              LoggingService.warning(
                'Action failed after $_maxRetries retries: ${action.type}',
                tag: _logTag,
              );
            } else {
              _actionQueue[index] = updatedAction;
            }
          }
        }
      } catch (e) {
        LoggingService.error('Error executing action ${action.type}: $e', tag: _logTag);
        failed++;
      }

      _syncStatus = _syncStatus.copyWith(
        completedActions: completed,
        failedActions: failed,
      );
      notifyListeners();
    }

    // Remove completed/failed actions
    _actionQueue.removeWhere((a) => actionsToRemove.contains(a.id));
    await _saveQueue();

    // Update last sync time
    await _prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());

    _isSyncing = false;
    _state = ConnectivityState.online;

    _syncStatus = SyncStatus(
      isSyncing: false,
      pendingActions: _actionQueue.length,
      completedActions: completed,
      failedActions: failed,
      lastSyncTime: DateTime.now(),
    );

    LoggingService.info(
      'Sync complete. Completed: $completed, Failed: $failed, Pending: ${_actionQueue.length}',
      tag: _logTag,
    );
    notifyListeners();
  }

  /// Manually trigger sync
  Future<void> syncNow() async {
    if (isOnline && _actionQueue.isNotEmpty) {
      await _syncPendingActions();
    }
  }

  /// Clear all pending actions
  Future<void> clearQueue() async {
    _actionQueue.clear();
    await _saveQueue();

    _syncStatus = const SyncStatus();
    notifyListeners();

    LoggingService.info('Cleared action queue', tag: _logTag);
  }

  /// Load queue from storage
  Future<void> _loadQueue() async {
    try {
      final queueJson = _prefs.getString(_queueKey);
      if (queueJson != null) {
        final List<dynamic> decoded = json.decode(queueJson);
        _actionQueue = decoded
            .map((e) => QueuedAction.fromMap(e as Map<String, dynamic>))
            .toList();

        _syncStatus = _syncStatus.copyWith(
          pendingActions: _actionQueue.length,
        );

        LoggingService.debug(
          'Loaded ${_actionQueue.length} queued actions',
          tag: _logTag,
        );
      }
    } catch (e) {
      LoggingService.error('Error loading queue: $e', tag: _logTag);
      _actionQueue = [];
    }
  }

  /// Save queue to storage
  Future<void> _saveQueue() async {
    try {
      final queueJson = json.encode(_actionQueue.map((a) => a.toMap()).toList());
      await _prefs.setString(_queueKey, queueJson);
    } catch (e) {
      LoggingService.error('Error saving queue: $e', tag: _logTag);
    }
  }

  /// Dispose of resources
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

/// Common action types for queuing
class OfflineActionTypes {
  static const String createPrediction = 'create_prediction';
  static const String updatePrediction = 'update_prediction';
  static const String joinWatchParty = 'join_watch_party';
  static const String leaveWatchParty = 'leave_watch_party';
  static const String sendChatMessage = 'send_chat_message';
  static const String addFavorite = 'add_favorite';
  static const String removeFavorite = 'remove_favorite';
  static const String updateProfile = 'update_profile';
}
