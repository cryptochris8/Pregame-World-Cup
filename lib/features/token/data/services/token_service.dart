import 'dart:async';
import '../../../../config/token_config.dart';
import '../../domain/entities/token_entities.dart';
import 'base_blockchain_service.dart';

/// Service for $PRE token operations
class TokenService {
  final BaseBlockchainService _blockchainService;
  final WalletConnectionService _walletService;

  TokenService({
    BaseBlockchainService? blockchainService,
    WalletConnectionService? walletService,
  })  : _blockchainService = blockchainService ?? BaseBlockchainService(),
        _walletService = walletService ?? WalletConnectionService();

  // Getters for underlying services
  BaseBlockchainService get blockchain => _blockchainService;
  WalletConnectionService get wallet => _walletService;

  /// Get current wallet connection
  WalletConnection? get currentWallet => _walletService.currentConnection;

  /// Check if wallet is connected
  bool get isWalletConnected => _walletService.isConnected;

  /// Stream of wallet connection changes
  Stream<WalletConnection?> get walletStream => _walletService.connectionStream;

  /// Connect wallet
  Future<WalletConnection> connectWallet(WalletProvider provider) async {
    switch (provider) {
      case WalletProvider.coinbaseWallet:
        return _walletService.connectCoinbaseWallet();
      case WalletProvider.metaMask:
        return _walletService.connectMetaMask();
      case WalletProvider.walletConnect:
      case WalletProvider.rainbow:
      case WalletProvider.unknown:
        return _walletService.connectWalletConnect();
    }
  }

  /// Disconnect wallet
  Future<void> disconnectWallet() => _walletService.disconnect();

  /// Get token balance for current wallet
  Future<TokenBalance> getBalance() async {
    final wallet = _walletService.currentConnection;
    if (wallet == null) {
      return TokenBalance.zero();
    }
    return _blockchainService.getTokenBalance(wallet.address);
  }

  /// Get token balance for any address
  Future<TokenBalance> getBalanceFor(String address) async {
    return _blockchainService.getTokenBalance(address);
  }

  /// Get ETH balance (for gas)
  Future<BigInt> getEthBalance() async {
    final wallet = _walletService.currentConnection;
    if (wallet == null) {
      return BigInt.zero;
    }
    return _blockchainService.getEthBalance(wallet.address);
  }

  /// Check if user has enough ETH for gas
  Future<bool> hasEnoughGas({BigInt? minAmount}) async {
    final ethBalance = await getEthBalance();
    final minRequired = minAmount ?? BigInt.from(10).pow(15); // 0.001 ETH
    return ethBalance >= minRequired;
  }

  /// Calculate reward for an action
  int calculateReward(TransactionReason reason, {double multiplier = 1.0}) {
    final rewards = TokenConfig.tokenRewards;
    int baseReward;

    switch (reason) {
      case TransactionReason.correctPrediction:
        baseReward = rewards.correctPrediction;
        break;
      case TransactionReason.exactScorePrediction:
        baseReward = rewards.exactScorePrediction;
        break;
      case TransactionReason.dailyCheckIn:
        baseReward = rewards.dailyCheckIn;
        break;
      case TransactionReason.referral:
        baseReward = rewards.referral;
        break;
      case TransactionReason.leaderboardWin:
        baseReward = rewards.weeklyLeaderboardWin;
        break;
      case TransactionReason.tournamentWin:
        baseReward = rewards.tournamentBracketWin;
        break;
      case TransactionReason.profileComplete:
        baseReward = rewards.completeProfile;
        break;
      case TransactionReason.socialConnect:
        baseReward = rewards.connectSocial;
        break;
      default:
        baseReward = 0;
    }

    return (baseReward * multiplier).round();
  }

  /// Get cost for a feature
  int getFeatureCost(TransactionReason reason) {
    final costs = TokenConfig.tokenCosts;

    switch (reason) {
      case TransactionReason.aiInsight:
        return costs.aiMatchInsight;
      case TransactionReason.premiumStats:
        return costs.premiumStatsPack;
      case TransactionReason.adFree:
        return costs.adFreeWeek;
      case TransactionReason.tournamentEntry:
        return costs.tournamentEntry;
      case TransactionReason.exclusiveContent:
        return costs.exclusiveContent;
      case TransactionReason.profileBadge:
        return costs.profileBadge;
      case TransactionReason.nftMint:
        return costs.nftMoment;
      default:
        return 0;
    }
  }

  /// Check if user can afford a feature
  Future<bool> canAfford(TransactionReason reason) async {
    final balance = await getBalance();
    final cost = getFeatureCost(reason);
    return balance.balance >= cost;
  }

  /// Get user's staking tier based on staked amount
  StakingTier getStakingTier(int stakedAmount) {
    return StakingTier.getTier(stakedAmount);
  }

  /// Get bonus multiplier for current tier
  double getBonusMultiplier(int stakedAmount) {
    return getStakingTier(stakedAmount).bonusMultiplier;
  }

  /// Get network information
  Map<String, dynamic> getNetworkInfo() => _blockchainService.getNetworkInfo();

  /// Check if network is available
  Future<bool> isNetworkAvailable() => _blockchainService.isNetworkAvailable();

  /// Validate address
  bool isValidAddress(String address) => _blockchainService.isValidAddress(address);

  /// Get explorer URL for transaction
  String getTxExplorerUrl(String txHash) =>
      _blockchainService.getTxExplorerUrl(txHash);

  /// Get explorer URL for address
  String getAddressExplorerUrl(String address) =>
      _blockchainService.getAddressExplorerUrl(address);

  void dispose() {
    _blockchainService.dispose();
    _walletService.dispose();
  }
}

/// Reward calculator utility
class RewardCalculator {
  /// Calculate prediction reward
  static int predictionReward({
    required bool isCorrect,
    required bool isExactScore,
    double tierMultiplier = 1.0,
  }) {
    if (!isCorrect) return 0;

    final rewards = TokenConfig.tokenRewards;
    int baseReward;

    if (isExactScore) {
      baseReward = rewards.exactScorePrediction;
    } else {
      baseReward = rewards.correctPrediction;
    }

    return (baseReward * tierMultiplier).round();
  }

  /// Calculate leaderboard rewards
  static int leaderboardReward({
    required int rank,
    required int totalParticipants,
    double tierMultiplier = 1.0,
  }) {
    final rewards = TokenConfig.tokenRewards;

    if (rank == 1) {
      return (rewards.weeklyLeaderboardWin * tierMultiplier).round();
    } else if (rank <= 3) {
      return (rewards.weeklyLeaderboardWin * 0.5 * tierMultiplier).round();
    } else if (rank <= 10) {
      return (rewards.weeklyLeaderboardWin * 0.2 * tierMultiplier).round();
    } else if (rank <= totalParticipants * 0.1) {
      // Top 10%
      return (rewards.weeklyLeaderboardWin * 0.1 * tierMultiplier).round();
    }

    return 0;
  }

  /// Calculate tournament bracket reward
  static int tournamentReward({
    required int correctPicks,
    required int totalPicks,
    required bool isWinner,
    double tierMultiplier = 1.0,
  }) {
    final rewards = TokenConfig.tokenRewards;

    if (isWinner) {
      return (rewards.tournamentBracketWin * tierMultiplier).round();
    }

    // Partial rewards based on correct picks
    final correctPercentage = correctPicks / totalPicks;
    if (correctPercentage >= 0.75) {
      return (rewards.tournamentBracketWin * 0.3 * tierMultiplier).round();
    } else if (correctPercentage >= 0.5) {
      return (rewards.tournamentBracketWin * 0.1 * tierMultiplier).round();
    }

    return 0;
  }

  /// Calculate referral reward with potential bonus
  static int referralReward({
    required int totalReferrals,
    double tierMultiplier = 1.0,
  }) {
    final rewards = TokenConfig.tokenRewards;
    var reward = rewards.referral;

    // Milestone bonuses
    if (totalReferrals == 5) {
      reward += 100; // Bonus for 5 referrals
    } else if (totalReferrals == 10) {
      reward += 250; // Bonus for 10 referrals
    } else if (totalReferrals == 25) {
      reward += 500; // Bonus for 25 referrals
    }

    return (reward * tierMultiplier).round();
  }
}
