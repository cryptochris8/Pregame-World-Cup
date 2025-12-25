import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/token_entities.dart';

/// Repository for managing token transactions and user data locally
class TokenRepository {
  static const _transactionsKey = 'pre_token_transactions';
  static const _statsKey = 'pre_token_stats';
  static const _walletKey = 'pre_wallet_address';
  static const _pendingRewardsKey = 'pre_pending_rewards';

  final SharedPreferences? _prefs;
  final List<TokenTransaction> _transactions = [];
  TokenStats _stats = TokenStats.empty();
  final List<PendingReward> _pendingRewards = [];

  final _transactionsController =
      StreamController<List<TokenTransaction>>.broadcast();
  final _statsController = StreamController<TokenStats>.broadcast();
  final _pendingRewardsController =
      StreamController<List<PendingReward>>.broadcast();

  TokenRepository({SharedPreferences? prefs}) : _prefs = prefs;

  // Streams
  Stream<List<TokenTransaction>> get transactionsStream =>
      _transactionsController.stream;
  Stream<TokenStats> get statsStream => _statsController.stream;
  Stream<List<PendingReward>> get pendingRewardsStream =>
      _pendingRewardsController.stream;

  // Getters
  List<TokenTransaction> get transactions => List.unmodifiable(_transactions);
  TokenStats get stats => _stats;
  List<PendingReward> get pendingRewards => List.unmodifiable(_pendingRewards);

  /// Initialize repository and load cached data
  Future<void> init() async {
    await _loadTransactions();
    await _loadStats();
    await _loadPendingRewards();
  }

  /// Add a new transaction (local tracking)
  Future<void> addTransaction(TokenTransaction transaction) async {
    _transactions.insert(0, transaction);
    _updateStats(transaction);
    await _saveTransactions();
    await _saveStats();
    _transactionsController.add(_transactions);
    _statsController.add(_stats);
  }

  /// Add a pending reward (to be claimed when wallet connected)
  Future<void> addPendingReward(PendingReward reward) async {
    _pendingRewards.add(reward);
    await _savePendingRewards();
    _pendingRewardsController.add(_pendingRewards);
  }

  /// Claim all pending rewards (when wallet connected)
  Future<List<TokenTransaction>> claimPendingRewards(String walletAddress) async {
    final claimed = <TokenTransaction>[];

    for (final reward in _pendingRewards) {
      final transaction = TokenTransaction(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}_${claimed.length}',
        type: TransactionType.earn,
        reason: reward.reason,
        amount: BigInt.from(reward.amount) * BigInt.from(10).pow(18),
        timestamp: DateTime.now(),
        status: TransactionStatus.confirmed,
        description: reward.description,
        metadata: {'originalTimestamp': reward.earnedAt.toIso8601String()},
      );
      claimed.add(transaction);
      await addTransaction(transaction);
    }

    _pendingRewards.clear();
    await _savePendingRewards();
    _pendingRewardsController.add(_pendingRewards);

    return claimed;
  }

  /// Get transactions filtered by type
  List<TokenTransaction> getTransactionsByType(TransactionType type) {
    return _transactions.where((tx) => tx.type == type).toList();
  }

  /// Get transactions filtered by reason
  List<TokenTransaction> getTransactionsByReason(TransactionReason reason) {
    return _transactions.where((tx) => tx.reason == reason).toList();
  }

  /// Get transactions for a date range
  List<TokenTransaction> getTransactionsInRange(
    DateTime start,
    DateTime end,
  ) {
    return _transactions
        .where((tx) =>
            tx.timestamp.isAfter(start) && tx.timestamp.isBefore(end))
        .toList();
  }

  /// Get recent transactions
  List<TokenTransaction> getRecentTransactions({int limit = 10}) {
    return _transactions.take(limit).toList();
  }

  /// Get total earned
  double getTotalEarned() {
    return _transactions
        .where((tx) => tx.type == TransactionType.earn)
        .fold<double>(0, (sum, tx) => sum + tx.amountDouble);
  }

  /// Get total spent
  double getTotalSpent() {
    return _transactions
        .where((tx) => tx.type == TransactionType.spend)
        .fold<double>(0, (sum, tx) => sum + tx.amountDouble);
  }

  /// Record a prediction reward
  Future<void> recordPredictionReward({
    required String matchId,
    required bool isCorrect,
    required bool isExactScore,
    required int amount,
    String? walletAddress,
  }) async {
    if (walletAddress != null) {
      // Wallet connected - create transaction
      final transaction = TokenTransaction(
        id: 'pred_${matchId}_${DateTime.now().millisecondsSinceEpoch}',
        type: TransactionType.earn,
        reason: isExactScore
            ? TransactionReason.exactScorePrediction
            : TransactionReason.correctPrediction,
        amount: BigInt.from(amount) * BigInt.from(10).pow(18),
        timestamp: DateTime.now(),
        status: TransactionStatus.confirmed,
        description: isExactScore
            ? 'Exact score prediction!'
            : 'Correct prediction',
        metadata: {'matchId': matchId},
      );
      await addTransaction(transaction);
    } else {
      // No wallet - add to pending rewards
      await addPendingReward(PendingReward(
        id: 'pending_pred_${matchId}_${DateTime.now().millisecondsSinceEpoch}',
        reason: isExactScore
            ? TransactionReason.exactScorePrediction
            : TransactionReason.correctPrediction,
        amount: amount,
        earnedAt: DateTime.now(),
        description: isExactScore
            ? 'Exact score prediction!'
            : 'Correct prediction',
        metadata: {'matchId': matchId},
      ));
    }
  }

  /// Record daily check-in
  Future<void> recordDailyCheckIn({
    required int amount,
    String? walletAddress,
  }) async {
    if (walletAddress != null) {
      final transaction = TokenTransaction(
        id: 'checkin_${DateTime.now().millisecondsSinceEpoch}',
        type: TransactionType.earn,
        reason: TransactionReason.dailyCheckIn,
        amount: BigInt.from(amount) * BigInt.from(10).pow(18),
        timestamp: DateTime.now(),
        status: TransactionStatus.confirmed,
        description: 'Daily check-in reward',
      );
      await addTransaction(transaction);
    } else {
      await addPendingReward(PendingReward(
        id: 'pending_checkin_${DateTime.now().millisecondsSinceEpoch}',
        reason: TransactionReason.dailyCheckIn,
        amount: amount,
        earnedAt: DateTime.now(),
        description: 'Daily check-in reward',
      ));
    }
  }

  /// Record a spend transaction
  Future<void> recordSpend({
    required TransactionReason reason,
    required int amount,
    String? description,
    String? walletAddress,
  }) async {
    if (walletAddress == null) {
      throw RepositoryException('Cannot spend without wallet connected');
    }

    final transaction = TokenTransaction(
      id: 'spend_${DateTime.now().millisecondsSinceEpoch}',
      type: TransactionType.spend,
      reason: reason,
      amount: BigInt.from(amount) * BigInt.from(10).pow(18),
      timestamp: DateTime.now(),
      status: TransactionStatus.confirmed,
      description: description ?? reason.displayName,
    );
    await addTransaction(transaction);
  }

  /// Record a generic earning transaction
  Future<void> recordEarning({
    required TransactionReason reason,
    required int amount,
    String? description,
    Map<String, dynamic>? metadata,
    String? walletAddress,
  }) async {
    if (walletAddress != null) {
      // Wallet connected - create transaction
      final transaction = TokenTransaction(
        id: 'earn_${reason.name}_${DateTime.now().millisecondsSinceEpoch}',
        type: TransactionType.earn,
        reason: reason,
        amount: BigInt.from(amount) * BigInt.from(10).pow(18),
        timestamp: DateTime.now(),
        status: TransactionStatus.confirmed,
        description: description ?? reason.displayName,
        metadata: metadata,
      );
      await addTransaction(transaction);
    } else {
      // No wallet - add to pending rewards
      await addPendingReward(PendingReward(
        id: 'pending_${reason.name}_${DateTime.now().millisecondsSinceEpoch}',
        reason: reason,
        amount: amount,
        earnedAt: DateTime.now(),
        description: description ?? reason.displayName,
        metadata: metadata,
      ));
    }
  }

  /// Save wallet address
  Future<void> saveWalletAddress(String address) async {
    await _prefs?.setString(_walletKey, address);
  }

  /// Get saved wallet address
  String? getSavedWalletAddress() {
    return _prefs?.getString(_walletKey);
  }

  /// Clear saved wallet
  Future<void> clearSavedWallet() async {
    await _prefs?.remove(_walletKey);
  }

  /// Clear all data
  Future<void> clearAll() async {
    _transactions.clear();
    _stats = TokenStats.empty();
    _pendingRewards.clear();

    await _prefs?.remove(_transactionsKey);
    await _prefs?.remove(_statsKey);
    await _prefs?.remove(_pendingRewardsKey);
    await _prefs?.remove(_walletKey);

    _transactionsController.add(_transactions);
    _statsController.add(_stats);
    _pendingRewardsController.add(_pendingRewards);
  }

  // Private methods

  void _updateStats(TokenTransaction transaction) {
    final isEarn = transaction.type == TransactionType.earn;

    _stats = TokenStats(
      totalEarned: _stats.totalEarned +
          (isEarn ? transaction.amountDouble : 0),
      totalSpent: _stats.totalSpent +
          (!isEarn ? transaction.amountDouble : 0),
      transactionCount: _stats.transactionCount + 1,
      correctPredictions: _stats.correctPredictions +
          (transaction.reason == TransactionReason.correctPrediction ? 1 : 0),
      exactScorePredictions: _stats.exactScorePredictions +
          (transaction.reason == TransactionReason.exactScorePrediction
              ? 1
              : 0),
      referralCount: _stats.referralCount +
          (transaction.reason == TransactionReason.referral ? 1 : 0),
      currentTier: _stats.currentTier,
      currentRank: _stats.currentRank,
    );
  }

  Future<void> _loadTransactions() async {
    final json = _prefs?.getString(_transactionsKey);
    if (json != null) {
      try {
        final list = jsonDecode(json) as List;
        _transactions.clear();
        _transactions.addAll(list.map((e) => _transactionFromJson(e)));
        _transactionsController.add(_transactions);
      } catch (e) {
        // Invalid data, start fresh
      }
    }
  }

  Future<void> _saveTransactions() async {
    final list = _transactions.map((tx) => _transactionToJson(tx)).toList();
    await _prefs?.setString(_transactionsKey, jsonEncode(list));
  }

  Future<void> _loadStats() async {
    final json = _prefs?.getString(_statsKey);
    if (json != null) {
      try {
        final map = jsonDecode(json) as Map<String, dynamic>;
        _stats = TokenStats(
          totalEarned: (map['totalEarned'] as num).toDouble(),
          totalSpent: (map['totalSpent'] as num).toDouble(),
          transactionCount: map['transactionCount'] as int,
          correctPredictions: map['correctPredictions'] as int,
          exactScorePredictions: map['exactScorePredictions'] as int,
          referralCount: map['referralCount'] as int,
          currentTier: map['currentTier'] as String,
          currentRank: map['currentRank'] as int,
        );
        _statsController.add(_stats);
      } catch (e) {
        // Invalid data, start fresh
      }
    }
  }

  Future<void> _saveStats() async {
    await _prefs?.setString(
      _statsKey,
      jsonEncode({
        'totalEarned': _stats.totalEarned,
        'totalSpent': _stats.totalSpent,
        'transactionCount': _stats.transactionCount,
        'correctPredictions': _stats.correctPredictions,
        'exactScorePredictions': _stats.exactScorePredictions,
        'referralCount': _stats.referralCount,
        'currentTier': _stats.currentTier,
        'currentRank': _stats.currentRank,
      }),
    );
  }

  Future<void> _loadPendingRewards() async {
    final json = _prefs?.getString(_pendingRewardsKey);
    if (json != null) {
      try {
        final list = jsonDecode(json) as List;
        _pendingRewards.clear();
        _pendingRewards.addAll(list.map((e) => PendingReward.fromJson(e)));
        _pendingRewardsController.add(_pendingRewards);
      } catch (e) {
        // Invalid data, start fresh
      }
    }
  }

  Future<void> _savePendingRewards() async {
    final list = _pendingRewards.map((r) => r.toJson()).toList();
    await _prefs?.setString(_pendingRewardsKey, jsonEncode(list));
  }

  Map<String, dynamic> _transactionToJson(TokenTransaction tx) {
    return {
      'id': tx.id,
      'txHash': tx.txHash,
      'type': tx.type.index,
      'reason': tx.reason.index,
      'amount': tx.amount.toString(),
      'decimals': tx.decimals,
      'symbol': tx.symbol,
      'timestamp': tx.timestamp.toIso8601String(),
      'status': tx.status.index,
      'description': tx.description,
      'metadata': tx.metadata,
    };
  }

  TokenTransaction _transactionFromJson(Map<String, dynamic> json) {
    return TokenTransaction(
      id: json['id'] as String,
      txHash: json['txHash'] as String?,
      type: TransactionType.values[json['type'] as int],
      reason: TransactionReason.values[json['reason'] as int],
      amount: BigInt.parse(json['amount'] as String),
      decimals: json['decimals'] as int? ?? 18,
      symbol: json['symbol'] as String? ?? 'PRE',
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: TransactionStatus.values[json['status'] as int],
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  void dispose() {
    _transactionsController.close();
    _statsController.close();
    _pendingRewardsController.close();
  }
}

/// Pending reward (earned before wallet connected)
class PendingReward {
  final String id;
  final TransactionReason reason;
  final int amount;
  final DateTime earnedAt;
  final String? description;
  final Map<String, dynamic>? metadata;

  const PendingReward({
    required this.id,
    required this.reason,
    required this.amount,
    required this.earnedAt,
    this.description,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'reason': reason.index,
        'amount': amount,
        'earnedAt': earnedAt.toIso8601String(),
        'description': description,
        'metadata': metadata,
      };

  factory PendingReward.fromJson(Map<String, dynamic> json) => PendingReward(
        id: json['id'] as String,
        reason: TransactionReason.values[json['reason'] as int],
        amount: json['amount'] as int,
        earnedAt: DateTime.parse(json['earnedAt'] as String),
        description: json['description'] as String?,
        metadata: json['metadata'] as Map<String, dynamic>?,
      );
}

/// Exception for repository operations
class RepositoryException implements Exception {
  final String message;
  RepositoryException(this.message);

  @override
  String toString() => 'RepositoryException: $message';
}
