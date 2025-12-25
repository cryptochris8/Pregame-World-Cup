import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/token_repository.dart';
import '../../data/services/token_service.dart';
import '../../domain/entities/token_entities.dart';

/// State for token operations
class TokenState extends Equatable {
  final WalletConnection? wallet;
  final TokenBalance balance;
  final List<TokenTransaction> transactions;
  final List<PendingReward> pendingRewards;
  final TokenStats stats;
  final StakingInfo stakingInfo;
  final bool isLoading;
  final bool isConnecting;
  final bool isRefreshing;
  final String? errorMessage;

  const TokenState({
    this.wallet,
    required this.balance,
    required this.transactions,
    required this.pendingRewards,
    required this.stats,
    required this.stakingInfo,
    this.isLoading = false,
    this.isConnecting = false,
    this.isRefreshing = false,
    this.errorMessage,
  });

  factory TokenState.initial() => TokenState(
        balance: TokenBalance.zero(),
        transactions: const [],
        pendingRewards: const [],
        stats: TokenStats.empty(),
        stakingInfo: StakingInfo.empty(),
      );

  bool get isConnected => wallet?.isConnected ?? false;
  bool get hasPendingRewards => pendingRewards.isNotEmpty;
  int get pendingRewardsTotal =>
      pendingRewards.fold(0, (sum, r) => sum + r.amount);

  TokenState copyWith({
    WalletConnection? wallet,
    TokenBalance? balance,
    List<TokenTransaction>? transactions,
    List<PendingReward>? pendingRewards,
    TokenStats? stats,
    StakingInfo? stakingInfo,
    bool? isLoading,
    bool? isConnecting,
    bool? isRefreshing,
    String? errorMessage,
    bool clearError = false,
    bool clearWallet = false,
  }) {
    return TokenState(
      wallet: clearWallet ? null : (wallet ?? this.wallet),
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      pendingRewards: pendingRewards ?? this.pendingRewards,
      stats: stats ?? this.stats,
      stakingInfo: stakingInfo ?? this.stakingInfo,
      isLoading: isLoading ?? this.isLoading,
      isConnecting: isConnecting ?? this.isConnecting,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        wallet,
        balance,
        transactions,
        pendingRewards,
        stats,
        stakingInfo,
        isLoading,
        isConnecting,
        isRefreshing,
        errorMessage,
      ];
}

/// Cubit for managing token state
class TokenCubit extends Cubit<TokenState> {
  final TokenService _tokenService;
  final TokenRepository _repository;

  StreamSubscription? _walletSubscription;
  StreamSubscription? _transactionsSubscription;
  StreamSubscription? _statsSubscription;
  StreamSubscription? _pendingRewardsSubscription;

  TokenCubit({
    required TokenService tokenService,
    required TokenRepository repository,
  })  : _tokenService = tokenService,
        _repository = repository,
        super(TokenState.initial());

  /// Initialize the cubit
  Future<void> init() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      // Initialize repository
      await _repository.init();

      // Set up streams
      _setupStreams();

      // Check for existing wallet session
      await _restoreSession();

      emit(state.copyWith(
        isLoading: false,
        transactions: _repository.transactions,
        stats: _repository.stats,
        pendingRewards: _repository.pendingRewards,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to initialize: $e',
      ));
    }
  }

  void _setupStreams() {
    _walletSubscription = _tokenService.walletStream.listen((wallet) {
      emit(state.copyWith(wallet: wallet, clearWallet: wallet == null));
      if (wallet != null) {
        refreshBalance();
        _claimPendingRewards();
      }
    });

    _transactionsSubscription = _repository.transactionsStream.listen((txs) {
      emit(state.copyWith(transactions: txs));
    });

    _statsSubscription = _repository.statsStream.listen((stats) {
      emit(state.copyWith(stats: stats));
    });

    _pendingRewardsSubscription =
        _repository.pendingRewardsStream.listen((rewards) {
      emit(state.copyWith(pendingRewards: rewards));
    });
  }

  Future<void> _restoreSession() async {
    final savedAddress = _repository.getSavedWalletAddress();
    if (savedAddress != null) {
      // Try to restore wallet connection
      await _tokenService.wallet.restoreSession();
    }
  }

  /// Connect wallet
  Future<void> connectWallet(WalletProvider provider) async {
    emit(state.copyWith(isConnecting: true, clearError: true));

    try {
      final wallet = await _tokenService.connectWallet(provider);
      await _repository.saveWalletAddress(wallet.address);
      emit(state.copyWith(
        wallet: wallet,
        isConnecting: false,
      ));

      // Refresh balance after connection
      await refreshBalance();

      // Claim any pending rewards
      await _claimPendingRewards();
    } catch (e) {
      emit(state.copyWith(
        isConnecting: false,
        errorMessage: 'Failed to connect wallet: $e',
      ));
    }
  }

  /// Disconnect wallet
  Future<void> disconnectWallet() async {
    try {
      await _tokenService.disconnectWallet();
      await _repository.clearSavedWallet();
      emit(state.copyWith(
        clearWallet: true,
        balance: TokenBalance.zero(),
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to disconnect: $e',
      ));
    }
  }

  /// Refresh token balance
  Future<void> refreshBalance() async {
    if (!state.isConnected) return;

    emit(state.copyWith(isRefreshing: true));

    try {
      final balance = await _tokenService.getBalance();
      emit(state.copyWith(
        balance: balance,
        isRefreshing: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isRefreshing: false,
        errorMessage: 'Failed to refresh balance: $e',
      ));
    }
  }

  /// Record a prediction reward
  Future<void> recordPredictionReward({
    required String matchId,
    required bool isCorrect,
    required bool isExactScore,
  }) async {
    if (!isCorrect) return;

    final amount = _tokenService.calculateReward(
      isExactScore
          ? TransactionReason.exactScorePrediction
          : TransactionReason.correctPrediction,
      multiplier: state.stakingInfo.bonusMultiplier,
    );

    await _repository.recordPredictionReward(
      matchId: matchId,
      isCorrect: isCorrect,
      isExactScore: isExactScore,
      amount: amount,
      walletAddress: state.wallet?.address,
    );

    if (state.isConnected) {
      await refreshBalance();
    }
  }

  /// Record daily check-in
  Future<void> recordDailyCheckIn() async {
    final amount = _tokenService.calculateReward(
      TransactionReason.dailyCheckIn,
      multiplier: state.stakingInfo.bonusMultiplier,
    );

    await _repository.recordDailyCheckIn(
      amount: amount,
      walletAddress: state.wallet?.address,
    );

    if (state.isConnected) {
      await refreshBalance();
    }
  }

  /// Earn tokens for any reason (called from external cubits like PredictionsCubit)
  Future<void> earnTokens({
    required int amount,
    required TransactionReason reason,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    // Apply staking bonus multiplier
    final actualAmount = (amount * state.stakingInfo.bonusMultiplier).round();

    await _repository.recordEarning(
      reason: reason,
      amount: actualAmount,
      description: description,
      metadata: metadata,
      walletAddress: state.wallet?.address,
    );

    if (state.isConnected) {
      await refreshBalance();
    }
  }

  /// Spend tokens on a feature
  Future<bool> spendTokens({
    required TransactionReason reason,
    String? description,
  }) async {
    if (!state.isConnected) {
      emit(state.copyWith(
        errorMessage: 'Connect wallet to spend tokens',
      ));
      return false;
    }

    final cost = _tokenService.getFeatureCost(reason);
    if (state.balance.balance < cost) {
      emit(state.copyWith(
        errorMessage: 'Insufficient balance',
      ));
      return false;
    }

    try {
      await _repository.recordSpend(
        reason: reason,
        amount: cost,
        description: description,
        walletAddress: state.wallet!.address,
      );
      await refreshBalance();
      return true;
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to spend tokens: $e',
      ));
      return false;
    }
  }

  /// Check if user can afford a feature
  bool canAfford(TransactionReason reason) {
    final cost = _tokenService.getFeatureCost(reason);
    return state.balance.balance >= cost;
  }

  /// Get cost for a feature
  int getFeatureCost(TransactionReason reason) {
    return _tokenService.getFeatureCost(reason);
  }

  Future<void> _claimPendingRewards() async {
    if (!state.isConnected || !state.hasPendingRewards) return;

    try {
      await _repository.claimPendingRewards(state.wallet!.address);
      await refreshBalance();
    } catch (e) {
      // Non-critical error, don't show to user
    }
  }

  /// Clear error message
  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  /// Get network info
  Map<String, dynamic> getNetworkInfo() => _tokenService.getNetworkInfo();

  /// Get explorer URL for transaction
  String getTxExplorerUrl(String txHash) =>
      _tokenService.getTxExplorerUrl(txHash);

  /// Get explorer URL for address
  String getAddressExplorerUrl(String address) =>
      _tokenService.getAddressExplorerUrl(address);

  @override
  Future<void> close() {
    _walletSubscription?.cancel();
    _transactionsSubscription?.cancel();
    _statsSubscription?.cancel();
    _pendingRewardsSubscription?.cancel();
    _tokenService.dispose();
    _repository.dispose();
    return super.close();
  }
}
