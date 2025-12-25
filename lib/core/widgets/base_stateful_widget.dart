import 'package:flutter/material.dart';
import '../services/logging_service.dart';

/// Base StatefulWidget that provides common patterns and error handling
/// Reduces boilerplate code across widget implementations
abstract class BaseStatefulWidget extends StatefulWidget {
  const BaseStatefulWidget({super.key});
}

/// Base State class with common functionality and lifecycle management
abstract class BaseStatefulWidgetState<T extends BaseStatefulWidget> extends State<T>
    with SingleTickerProviderStateMixin {
  
  // Common state variables
  bool _isLoading = false;
  bool _isDisposed = false;
  String? _error;
  late AnimationController _animationController;
  
  // Abstract methods that must be implemented
  String get logTag;
  Widget buildContent(BuildContext context);
  
  // Optional lifecycle methods
  Future<void> onInitialize() async {}
  Future<void> onLoadData() async {}
  void onDispose() {}

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _initializeWithErrorHandling();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _animationController.dispose();
    onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _buildErrorState();
    }
    
    if (_isLoading) {
      return _buildLoadingState();
    }
    
    return buildContent(context);
  }

  // Common utility methods

  /// Safe setState that checks if widget is mounted and not disposed
  void safeSetState(VoidCallback fn) {
    if (mounted && !_isDisposed) {
      setState(fn);
    } else {
      LoggingService.warning(
        '$logTag: Attempted setState on disposed/unmounted widget',
        tag: logTag,
      );
    }
  }

  /// Set loading state with optional callback
  void setLoading(bool loading, [VoidCallback? callback]) {
    safeSetState(() {
      _isLoading = loading;
      if (callback != null) callback();
    });
  }

  /// Set error state with logging
  void setError(String error, [Object? exception]) {
    LoggingService.error('$logTag: $error', tag: logTag);
    if (exception != null) {
      LoggingService.error('Exception details: $exception', tag: logTag);
    }
    
    safeSetState(() {
      _error = error;
      _isLoading = false;
    });
  }

  /// Clear error state
  void clearError() {
    safeSetState(() {
      _error = null;
    });
  }

  /// Execute async operation with error handling and lifecycle safety
  Future<void> executeWithErrorHandling(
    Future<void> Function() operation, {
    String? loadingMessage,
    bool showLoading = true,
  }) async {
    if (_isDisposed) {
      LoggingService.warning(
        '$logTag: Attempted async operation on disposed widget',
        tag: logTag,
      );
      return;
    }

    try {
      if (showLoading) {
        setLoading(true);
      }
      
      await operation();
      
      if (showLoading && !_isDisposed) {
        setLoading(false);
      }
    } catch (e) {
      if (!_isDisposed) {
        setError('Operation failed: ${e.toString()}', e);
      }
    }
  }

  /// Execute async operation with result and lifecycle safety
  Future<R?> executeWithErrorHandlingResult<R>(
    Future<R> Function() operation, {
    String? loadingMessage,
    bool showLoading = true,
  }) async {
    if (_isDisposed) {
      LoggingService.warning(
        '$logTag: Attempted async operation on disposed widget',
        tag: logTag,
      );
      return null;
    }

    try {
      if (showLoading) {
        setLoading(true);
      }
      
      final result = await operation();
      
      if (showLoading && !_isDisposed) {
        setLoading(false);
      }
      
      return result;
    } catch (e) {
      if (!_isDisposed) {
        setError('Operation failed: ${e.toString()}', e);
      }
      return null;
    }
  }

  /// Animate widget entrance
  void animateIn() {
    if (!_isDisposed && _animationController.status != AnimationStatus.forward) {
      _animationController.forward();
    }
  }

  /// Animate widget exit
  void animateOut() {
    if (!_isDisposed && _animationController.status != AnimationStatus.reverse) {
      _animationController.reverse();
    }
  }

  /// Check if widget is safe to update
  bool get isSafeToUpdate => mounted && !_isDisposed;

  // Private methods

  void _initializeWithErrorHandling() async {
    try {
      await onInitialize();
      if (!_isDisposed) {
        await onLoadData();
        animateIn();
      }
    } catch (e) {
      if (!_isDisposed) {
        setError('Failed to initialize: ${e.toString()}', e);
      }
    }
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              _error ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                clearError();
                _initializeWithErrorHandling();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Specialized base class for widgets that display lists
abstract class BaseListWidget extends BaseStatefulWidget {
  const BaseListWidget({super.key});
}

/// Enhanced state class for list widgets with pagination support
abstract class BaseListWidgetState<T extends BaseListWidget> extends BaseStatefulWidgetState<T> {
  final ScrollController scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  
  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_isDisposed) return;
    
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreData();
      }
    }
  }
  
  Future<void> _loadMoreData() async {
    if (_isDisposed) return;
    
    safeSetState(() => _isLoadingMore = true);
    
    try {
      final hasMore = await loadMoreItems();
      if (!_isDisposed) {
        safeSetState(() {
          _isLoadingMore = false;
          _hasMoreData = hasMore;
        });
      }
    } catch (e) {
      if (!_isDisposed) {
        safeSetState(() => _isLoadingMore = false);
        LoggingService.error('$logTag: Error loading more data: $e', tag: logTag);
      }
    }
  }
  
  /// Override this method to implement pagination
  Future<bool> loadMoreItems() async {
    return false; // Return true if more data is available
  }
  
  /// Check if currently loading more data
  bool get isLoadingMore => _isLoadingMore;
  
  /// Check if more data is available
  bool get hasMoreData => _hasMoreData;
} 