import 'dart:async';
import 'package:flutter/material.dart';
import '../services/logging_service.dart';

/// Helper class for managing widget lifecycle and preventing setState after dispose errors
class LifecycleHelper {
  /// Execute a setState operation safely, checking if the widget is mounted
  static void safeSetState(State state, VoidCallback fn, {String? debugTag}) {
    if (state.mounted) {
      // ignore: invalid_use_of_protected_member
      state.setState(fn);
    } else {
      LoggingService.warning(
        '${debugTag ?? 'Widget'}: Attempted setState on unmounted widget',
        tag: debugTag ?? 'LifecycleHelper',
      );
    }
  }

  /// Execute an async operation with proper error handling and lifecycle checks
  static Future<T?> safeAsyncOperation<T>(
    State state,
    Future<T> Function() operation, {
    String? debugTag,
    VoidCallback? onStart,
    void Function(T result)? onSuccess,
    void Function(Object error)? onError,
    VoidCallback? onComplete,
  }) async {
    final tag = debugTag ?? 'LifecycleHelper';
    
    try {
      // Check if widget is still mounted before starting
      if (!state.mounted) {
        LoggingService.warning('$tag: Widget unmounted before async operation', tag: tag);
        return null;
      }

      // Execute start callback
      if (onStart != null) {
        safeSetState(state, onStart, debugTag: tag);
      }

      // Execute the operation
      final result = await operation();

      // Check if widget is still mounted after operation
      if (!state.mounted) {
        LoggingService.warning('$tag: Widget unmounted after async operation', tag: tag);
        return null;
      }

      // Execute success callback
      if (onSuccess != null) {
        safeSetState(state, () => onSuccess(result), debugTag: tag);
      }

      return result;
    } catch (error) {
      LoggingService.error('$tag: Async operation failed: $error', tag: tag);
      
      // Check if widget is still mounted before handling error
      if (state.mounted && onError != null) {
        safeSetState(state, () => onError(error), debugTag: tag);
      }
      
      return null;
    } finally {
      // Execute complete callback if widget is still mounted
      if (state.mounted && onComplete != null) {
        safeSetState(state, onComplete, debugTag: tag);
      }
    }
  }

  /// Create a debounced function that prevents rapid successive calls
  static VoidCallback debounce(
    VoidCallback function,
    Duration delay, {
    String? debugTag,
  }) {
    Timer? timer;
    
    return () {
      timer?.cancel();
      timer = Timer(delay, () {
        try {
          function();
        } catch (e) {
          LoggingService.error(
            '${debugTag ?? 'Debounced'}: Function execution failed: $e',
            tag: debugTag ?? 'LifecycleHelper',
          );
        }
      });
    };
  }

  /// Create a throttled function that limits execution frequency
  static VoidCallback throttle(
    VoidCallback function,
    Duration interval, {
    String? debugTag,
  }) {
    bool canExecute = true;
    
    return () {
      if (canExecute) {
        canExecute = false;
        try {
          function();
        } catch (e) {
          LoggingService.error(
            '${debugTag ?? 'Throttled'}: Function execution failed: $e',
            tag: debugTag ?? 'LifecycleHelper',
          );
        }
        
        Timer(interval, () {
          canExecute = true;
        });
      }
    };
  }

  /// Safely dispose of resources with error handling
  static void safeDispose(List<dynamic> resources, {String? debugTag}) {
    final tag = debugTag ?? 'LifecycleHelper';
    
    for (final resource in resources) {
      try {
        if (resource is StreamSubscription) {
          resource.cancel();
        } else if (resource is AnimationController) {
          resource.dispose();
        } else if (resource is TextEditingController) {
          resource.dispose();
        } else if (resource is ScrollController) {
          resource.dispose();
        } else if (resource is FocusNode) {
          resource.dispose();
        } else if (resource is PageController) {
          resource.dispose();
        } else if (resource is TabController) {
          resource.dispose();
        } else if (resource is Timer) {
          resource.cancel();
        } else if (resource?.dispose != null) {
          resource.dispose();
        }
      } catch (e) {
        LoggingService.error('$tag: Error disposing resource: $e', tag: tag);
      }
    }
  }

  /// Create a safe stream subscription that automatically handles disposal
  static StreamSubscription<T> safeStreamSubscription<T>(
    Stream<T> stream,
    void Function(T) onData, {
    State? state,
    Function? onError,
    VoidCallback? onDone,
    String? debugTag,
  }) {
    final tag = debugTag ?? 'LifecycleHelper';
    
    return stream.listen(
      (data) {
        try {
          if (state == null || state.mounted) {
            onData(data);
          }
        } catch (e) {
          LoggingService.error('$tag: Stream data handler failed: $e', tag: tag);
        }
      },
      onError: (error) {
        LoggingService.error('$tag: Stream error: $error', tag: tag);
        if (onError != null) {
          try {
            onError(error);
          } catch (e) {
            LoggingService.error('$tag: Stream error handler failed: $e', tag: tag);
          }
        }
      },
      onDone: () {
        try {
          onDone?.call();
        } catch (e) {
          LoggingService.error('$tag: Stream done handler failed: $e', tag: tag);
        }
      },
    );
  }

  /// Check if a widget is safe to update (mounted and not disposed)
  static bool isSafeToUpdate(State state) {
    return state.mounted;
  }

  /// Execute a function with error handling and logging
  static T? safeExecute<T>(
    T Function() function, {
    String? debugTag,
    T? defaultValue,
  }) {
    final tag = debugTag ?? 'LifecycleHelper';
    
    try {
      return function();
    } catch (e) {
      LoggingService.error('$tag: Safe execution failed: $e', tag: tag);
      return defaultValue;
    }
  }
}

/// Mixin to provide lifecycle management capabilities to StatefulWidget states
mixin LifecycleMixin<T extends StatefulWidget> on State<T> {
  final List<StreamSubscription> _subscriptions = [];
  final List<Timer> _timers = [];
  bool _isDisposed = false;

  /// Check if the widget is disposed
  bool get isDisposed => _isDisposed;

  /// Safely execute setState
  void safeSetState(VoidCallback fn) {
    LifecycleHelper.safeSetState(this, fn, debugTag: widget.runtimeType.toString());
  }

  /// Add a stream subscription that will be automatically disposed
  void addSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  /// Add a timer that will be automatically cancelled
  void addTimer(Timer timer) {
    _timers.add(timer);
  }

  /// Execute an async operation safely
  Future<R?> safeAsync<R>(
    Future<R> Function() operation, {
    VoidCallback? onStart,
    void Function(R result)? onSuccess,
    void Function(Object error)? onError,
    VoidCallback? onComplete,
  }) {
    return LifecycleHelper.safeAsyncOperation<R>(
      this,
      operation,
      debugTag: widget.runtimeType.toString(),
      onStart: onStart,
      onSuccess: onSuccess,
      onError: onError,
      onComplete: onComplete,
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    
    // Cancel all subscriptions
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    // Cancel all timers
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();

    super.dispose();
  }
} 