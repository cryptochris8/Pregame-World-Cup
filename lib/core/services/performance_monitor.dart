import 'dart:developer' as developer;

class PerformanceMonitor {
  static const String _logTag = 'PregamePerformance';
  
  static int _cacheHits = 0;
  static int _cacheMisses = 0;
  static int _apiCalls = 0;
  static final List<Duration> _apiCallTimes = [];
  static final Map<String, DateTime> _pendingCalls = {};

  // Track cache performance
  static void recordCacheHit(String key) {
    _cacheHits++;
    developer.log(
      'Cache HIT: $key (Total hits: $_cacheHits)',
      name: _logTag,
    );
  }

  static void recordCacheMiss(String key) {
    _cacheMisses++;
    developer.log(
      'Cache MISS: $key (Total misses: $_cacheMisses)',
      name: _logTag,
    );
  }

  // Track API call performance
  static void startApiCall(String callId) {
    _pendingCalls[callId] = DateTime.now();
    developer.log(
      'API Call STARTED: $callId',
      name: _logTag,
    );
  }

  static void endApiCall(String callId, {bool success = true}) {
    final startTime = _pendingCalls.remove(callId);
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _apiCallTimes.add(duration);
      _apiCalls++;
      
      developer.log(
        'API Call ${success ? 'COMPLETED' : 'FAILED'}: $callId in ${duration.inMilliseconds}ms',
        name: _logTag,
      );
    }
  }

  // Get performance statistics
  static Map<String, dynamic> getStats() {
    final totalRequests = _cacheHits + _cacheMisses;
    final cacheHitRate = totalRequests > 0 ? (_cacheHits / totalRequests * 100) : 0.0;
    
    double averageApiTime = 0.0;
    if (_apiCallTimes.isNotEmpty) {
      final totalTime = _apiCallTimes.fold<int>(0, (sum, duration) => sum + duration.inMilliseconds);
      averageApiTime = totalTime / _apiCallTimes.length;
    }

    return {
      'cache_hits': _cacheHits,
      'cache_misses': _cacheMisses,
      'cache_hit_rate': cacheHitRate.toStringAsFixed(1),
      'api_calls': _apiCalls,
      'average_api_time_ms': averageApiTime.toStringAsFixed(1),
      'pending_calls': _pendingCalls.length,
    };
  }

  // Print comprehensive performance summary
  static void printSummary() {
    final stats = getStats();
    developer.log(
      '''
📊 PREGAME PERFORMANCE SUMMARY 📊
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 Cache Performance:
   • Cache Hits: ${stats['cache_hits']}
   • Cache Misses: ${stats['cache_misses']}
   • Hit Rate: ${stats['cache_hit_rate']}%

⚡ API Performance:
   • Total API Calls: ${stats['api_calls']}
   • Average Response Time: ${stats['average_api_time_ms']}ms
   • Pending Calls: ${stats['pending_calls']}

💡 Performance Impact:
   • API Calls Avoided: ${stats['cache_hits']} 
   • Estimated Time Saved: ${(double.parse(stats['cache_hit_rate']) * double.parse(stats['average_api_time_ms']) / 100).toStringAsFixed(0)}ms per hit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''',
      name: _logTag,
    );
  }

  // Reset statistics
  static void reset() {
    _cacheHits = 0;
    _cacheMisses = 0;
    _apiCalls = 0;
    _apiCallTimes.clear();
    _pendingCalls.clear();
    developer.log('Performance statistics reset', name: _logTag);
  }
} 