import 'dart:collection';
import 'dart:async';
import 'logging_service.dart';

/// Rate limiting service to prevent API abuse
/// Implements token bucket algorithm with per-endpoint limits
class RateLimitService {
  static const String _logTag = 'RateLimitService';
  
  // Define rate limits for different API endpoints (requests per minute)
  static const Map<String, int> _rateLimits = {
    'openai_completion': 20,      // OpenAI completions: 20 per minute
    'openai_embedding': 50,       // OpenAI embeddings: 50 per minute  
    'google_places': 100,         // Google Places: 100 per minute
    'sportsdata': 60,            // SportsData.io: 60 per minute
    'firebase_function': 200,     // Firebase functions: 200 per minute
    'default': 30,               // Default limit: 30 per minute
  };
  
  // Token buckets for each endpoint
  static final Map<String, _TokenBucket> _buckets = {};
  
  /// Check if request is allowed for given endpoint
  /// Returns true if request can proceed, false if rate limited
  static bool isAllowed(String endpoint) {
    final bucket = _getBucket(endpoint);
    final allowed = bucket.tryConsume();
    
    if (!allowed) {
      LoggingService.warning(
        'Rate limit exceeded for endpoint: $endpoint',
        tag: _logTag,
      );
    }
    
    return allowed;
  }
  
  /// Wait until request is allowed (with timeout)
  /// Returns true if request can proceed, false if timeout reached
  static Future<bool> waitForSlot(String endpoint, {Duration timeout = const Duration(seconds: 30)}) async {
    final bucket = _getBucket(endpoint);
    final completer = Completer<bool>();
    
    // Set up timeout
    Timer? timeoutTimer;
    timeoutTimer = Timer(timeout, () {
      if (!completer.isCompleted) {
        LoggingService.warning(
          'Rate limit wait timeout for endpoint: $endpoint',
          tag: _logTag,
        );
        completer.complete(false);
      }
      timeoutTimer?.cancel();
    });
    
    // Try to get a slot
    void tryGetSlot() {
      if (completer.isCompleted) return;
      
      if (bucket.tryConsume()) {
        timeoutTimer?.cancel();
        completer.complete(true);
      } else {
        // Wait for next refill and try again
        Timer(const Duration(seconds: 1), tryGetSlot);
      }
    }
    
    tryGetSlot();
    return completer.future;
  }
  
  /// Get remaining tokens for endpoint
  static int getRemainingTokens(String endpoint) {
    return _getBucket(endpoint).tokens;
  }
  
  /// Get time until next token is available
  static Duration getTimeUntilNextToken(String endpoint) {
    return _getBucket(endpoint).timeUntilNextRefill;
  }
  
  /// Reset rate limits for endpoint (useful for testing)
  static void reset(String endpoint) {
    _buckets.remove(endpoint);
    LoggingService.info('Reset rate limit for endpoint: $endpoint', tag: _logTag);
  }
  
  /// Get or create token bucket for endpoint
  static _TokenBucket _getBucket(String endpoint) {
    if (!_buckets.containsKey(endpoint)) {
      final limit = _rateLimits[endpoint] ?? _rateLimits['default']!;
      _buckets[endpoint] = _TokenBucket(
        capacity: limit,
        refillRate: limit, // Refill to capacity every minute
        refillInterval: const Duration(minutes: 1),
      );
      LoggingService.info(
        'Created rate limiter for $endpoint: $limit requests/minute',
        tag: _logTag,
      );
    }
    return _buckets[endpoint]!;
  }
  
  /// Get rate limit status for all endpoints
  static Map<String, Map<String, dynamic>> getStatus() {
    final status = <String, Map<String, dynamic>>{};
    
    for (final entry in _buckets.entries) {
      final endpoint = entry.key;
      final bucket = entry.value;
      
      status[endpoint] = {
        'limit': _rateLimits[endpoint] ?? _rateLimits['default'],
        'remaining': bucket.tokens,
        'resetTime': bucket.timeUntilNextRefill.inSeconds,
      };
    }
    
    return status;
  }
}

/// Token bucket implementation for rate limiting
class _TokenBucket {
  final int capacity;
  final int refillRate;
  final Duration refillInterval;
  
  int _tokens;
  DateTime _lastRefill;
  Timer? _refillTimer;
  
  _TokenBucket({
    required this.capacity,
    required this.refillRate,
    required this.refillInterval,
  }) : _tokens = capacity, _lastRefill = DateTime.now() {
    _scheduleRefill();
  }
  
  /// Current number of tokens
  int get tokens => _tokens;
  
  /// Time until next refill
  Duration get timeUntilNextRefill {
    final nextRefill = _lastRefill.add(refillInterval);
    final remaining = nextRefill.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }
  
  /// Try to consume a token
  bool tryConsume({int count = 1}) {
    _refillIfNeeded();
    
    if (_tokens >= count) {
      _tokens -= count;
      return true;
    }
    
    return false;
  }
  
  /// Check if refill is needed and do it
  void _refillIfNeeded() {
    final now = DateTime.now();
    final timeSinceRefill = now.difference(_lastRefill);
    
    if (timeSinceRefill >= refillInterval) {
      _tokens = capacity;
      _lastRefill = now;
    }
  }
  
  /// Schedule automatic refill
  void _scheduleRefill() {
    _refillTimer?.cancel();
    _refillTimer = Timer.periodic(refillInterval, (_) {
      _refillIfNeeded();
    });
  }
  
  /// Clean up timer
  void dispose() {
    _refillTimer?.cancel();
  }
} 