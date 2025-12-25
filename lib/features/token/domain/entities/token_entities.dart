import 'package:equatable/equatable.dart';

/// Represents a connected wallet
class WalletConnection extends Equatable {
  final String address;
  final String? ensName;
  final WalletProvider provider;
  final DateTime connectedAt;
  final bool isConnected;

  const WalletConnection({
    required this.address,
    this.ensName,
    required this.provider,
    required this.connectedAt,
    this.isConnected = true,
  });

  /// Shortened address for display (e.g., "0x1234...5678")
  String get shortAddress {
    if (address.length < 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  /// Display name (ENS name or short address)
  String get displayName => ensName ?? shortAddress;

  WalletConnection copyWith({
    String? address,
    String? ensName,
    WalletProvider? provider,
    DateTime? connectedAt,
    bool? isConnected,
  }) {
    return WalletConnection(
      address: address ?? this.address,
      ensName: ensName ?? this.ensName,
      provider: provider ?? this.provider,
      connectedAt: connectedAt ?? this.connectedAt,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  @override
  List<Object?> get props => [address, ensName, provider, connectedAt, isConnected];
}

/// Supported wallet providers
enum WalletProvider {
  coinbaseWallet,
  metaMask,
  rainbow,
  walletConnect,
  unknown;

  String get displayName {
    switch (this) {
      case WalletProvider.coinbaseWallet:
        return 'Coinbase Wallet';
      case WalletProvider.metaMask:
        return 'MetaMask';
      case WalletProvider.rainbow:
        return 'Rainbow';
      case WalletProvider.walletConnect:
        return 'WalletConnect';
      case WalletProvider.unknown:
        return 'Unknown Wallet';
    }
  }

  String get iconAsset {
    switch (this) {
      case WalletProvider.coinbaseWallet:
        return 'assets/icons/coinbase_wallet.png';
      case WalletProvider.metaMask:
        return 'assets/icons/metamask.png';
      case WalletProvider.rainbow:
        return 'assets/icons/rainbow.png';
      case WalletProvider.walletConnect:
        return 'assets/icons/walletconnect.png';
      case WalletProvider.unknown:
        return 'assets/icons/wallet_generic.png';
    }
  }
}

/// Token balance information
class TokenBalance extends Equatable {
  final BigInt rawBalance;
  final int decimals;
  final String symbol;
  final DateTime lastUpdated;

  const TokenBalance({
    required this.rawBalance,
    this.decimals = 18,
    this.symbol = 'PRE',
    required this.lastUpdated,
  });

  /// Balance as a human-readable double
  double get balance {
    if (rawBalance == BigInt.zero) return 0;
    final divisor = BigInt.from(10).pow(decimals);
    return rawBalance / divisor;
  }

  /// Formatted balance string (e.g., "1,234.56 PRE")
  String get formatted {
    final balanceStr = balance.toStringAsFixed(2);
    // Add thousands separator
    final parts = balanceStr.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$intPart.${parts[1]} $symbol';
  }

  /// Short formatted balance (e.g., "1.2K PRE")
  String get shortFormatted {
    if (balance >= 1000000) {
      return '${(balance / 1000000).toStringAsFixed(1)}M $symbol';
    } else if (balance >= 1000) {
      return '${(balance / 1000).toStringAsFixed(1)}K $symbol';
    } else {
      return '${balance.toStringAsFixed(0)} $symbol';
    }
  }

  static TokenBalance zero() => TokenBalance(
        rawBalance: BigInt.zero,
        lastUpdated: DateTime.now(),
      );

  @override
  List<Object?> get props => [rawBalance, decimals, symbol, lastUpdated];
}

/// A token transaction (earn or spend)
class TokenTransaction extends Equatable {
  final String id;
  final String? txHash;
  final TransactionType type;
  final TransactionReason reason;
  final BigInt amount;
  final int decimals;
  final String symbol;
  final DateTime timestamp;
  final TransactionStatus status;
  final String? description;
  final Map<String, dynamic>? metadata;

  const TokenTransaction({
    required this.id,
    this.txHash,
    required this.type,
    required this.reason,
    required this.amount,
    this.decimals = 18,
    this.symbol = 'PRE',
    required this.timestamp,
    required this.status,
    this.description,
    this.metadata,
  });

  /// Amount as human-readable double
  double get amountDouble {
    if (amount == BigInt.zero) return 0;
    final divisor = BigInt.from(10).pow(decimals);
    return amount / divisor;
  }

  /// Formatted amount with sign
  String get formattedAmount {
    final prefix = type == TransactionType.earn ? '+' : '-';
    return '$prefix${amountDouble.toStringAsFixed(0)} $symbol';
  }

  /// Whether this is a pending transaction
  bool get isPending => status == TransactionStatus.pending;

  /// Whether this is a confirmed transaction
  bool get isConfirmed => status == TransactionStatus.confirmed;

  /// Whether this transaction failed
  bool get isFailed => status == TransactionStatus.failed;

  @override
  List<Object?> get props => [
        id,
        txHash,
        type,
        reason,
        amount,
        decimals,
        symbol,
        timestamp,
        status,
        description,
        metadata,
      ];
}

/// Transaction type
enum TransactionType {
  earn,
  spend,
  stake,
  unstake,
  transfer;

  bool get isPositive => this == earn || this == unstake;
  bool get isNegative => this == spend || this == stake || this == transfer;
}

/// Reason for the transaction
enum TransactionReason {
  // Earning reasons
  correctPrediction,
  exactScorePrediction,
  dailyCheckIn,
  referral,
  leaderboardWin,
  tournamentWin,
  profileComplete,
  socialConnect,
  airdrop,
  bonus,

  // Spending reasons
  aiInsight,
  premiumStats,
  adFree,
  tournamentEntry,
  exclusiveContent,
  profileBadge,
  nftMint,

  // Staking
  stakeDeposit,
  stakeWithdraw,
  stakingReward,

  // Other
  transfer,
  other;

  String get displayName {
    switch (this) {
      case TransactionReason.correctPrediction:
        return 'Correct Prediction';
      case TransactionReason.exactScorePrediction:
        return 'Exact Score Prediction';
      case TransactionReason.dailyCheckIn:
        return 'Daily Check-in';
      case TransactionReason.referral:
        return 'Friend Referral';
      case TransactionReason.leaderboardWin:
        return 'Leaderboard Win';
      case TransactionReason.tournamentWin:
        return 'Tournament Win';
      case TransactionReason.profileComplete:
        return 'Profile Completed';
      case TransactionReason.socialConnect:
        return 'Social Connected';
      case TransactionReason.airdrop:
        return 'Airdrop';
      case TransactionReason.bonus:
        return 'Bonus Reward';
      case TransactionReason.aiInsight:
        return 'AI Match Insight';
      case TransactionReason.premiumStats:
        return 'Premium Stats';
      case TransactionReason.adFree:
        return 'Ad-Free Access';
      case TransactionReason.tournamentEntry:
        return 'Tournament Entry';
      case TransactionReason.exclusiveContent:
        return 'Exclusive Content';
      case TransactionReason.profileBadge:
        return 'Profile Badge';
      case TransactionReason.nftMint:
        return 'NFT Mint';
      case TransactionReason.stakeDeposit:
        return 'Stake Deposit';
      case TransactionReason.stakeWithdraw:
        return 'Stake Withdraw';
      case TransactionReason.stakingReward:
        return 'Staking Reward';
      case TransactionReason.transfer:
        return 'Transfer';
      case TransactionReason.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case TransactionReason.correctPrediction:
      case TransactionReason.exactScorePrediction:
        return '⚽';
      case TransactionReason.dailyCheckIn:
        return '📅';
      case TransactionReason.referral:
        return '👥';
      case TransactionReason.leaderboardWin:
      case TransactionReason.tournamentWin:
        return '🏆';
      case TransactionReason.profileComplete:
        return '✅';
      case TransactionReason.socialConnect:
        return '🔗';
      case TransactionReason.airdrop:
      case TransactionReason.bonus:
        return '🎁';
      case TransactionReason.aiInsight:
        return '🧠';
      case TransactionReason.premiumStats:
        return '📊';
      case TransactionReason.adFree:
        return '🚫';
      case TransactionReason.tournamentEntry:
        return '🎟️';
      case TransactionReason.exclusiveContent:
        return '⭐';
      case TransactionReason.profileBadge:
        return '🏅';
      case TransactionReason.nftMint:
        return '🖼️';
      case TransactionReason.stakeDeposit:
      case TransactionReason.stakeWithdraw:
      case TransactionReason.stakingReward:
        return '🔒';
      case TransactionReason.transfer:
        return '↔️';
      case TransactionReason.other:
        return '💰';
    }
  }
}

/// Transaction status
enum TransactionStatus {
  pending,
  confirmed,
  failed;

  String get displayName {
    switch (this) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.confirmed:
        return 'Confirmed';
      case TransactionStatus.failed:
        return 'Failed';
    }
  }
}

/// User's staking information
class StakingInfo extends Equatable {
  final BigInt stakedAmount;
  final BigInt pendingRewards;
  final String tierName;
  final double bonusMultiplier;
  final DateTime? stakedSince;
  final DateTime? lastRewardClaim;

  const StakingInfo({
    required this.stakedAmount,
    required this.pendingRewards,
    required this.tierName,
    required this.bonusMultiplier,
    this.stakedSince,
    this.lastRewardClaim,
  });

  double get stakedAmountDouble {
    if (stakedAmount == BigInt.zero) return 0;
    return stakedAmount / BigInt.from(10).pow(18);
  }

  double get pendingRewardsDouble {
    if (pendingRewards == BigInt.zero) return 0;
    return pendingRewards / BigInt.from(10).pow(18);
  }

  bool get isStaking => stakedAmount > BigInt.zero;

  static StakingInfo empty() => StakingInfo(
        stakedAmount: BigInt.zero,
        pendingRewards: BigInt.zero,
        tierName: 'Fan',
        bonusMultiplier: 1.0,
      );

  @override
  List<Object?> get props => [
        stakedAmount,
        pendingRewards,
        tierName,
        bonusMultiplier,
        stakedSince,
        lastRewardClaim,
      ];
}

/// Token statistics for the user
class TokenStats extends Equatable {
  final double totalEarned;
  final double totalSpent;
  final int transactionCount;
  final int correctPredictions;
  final int exactScorePredictions;
  final int referralCount;
  final String currentTier;
  final int currentRank;

  const TokenStats({
    required this.totalEarned,
    required this.totalSpent,
    required this.transactionCount,
    required this.correctPredictions,
    required this.exactScorePredictions,
    required this.referralCount,
    required this.currentTier,
    required this.currentRank,
  });

  double get netBalance => totalEarned - totalSpent;

  static TokenStats empty() => const TokenStats(
        totalEarned: 0,
        totalSpent: 0,
        transactionCount: 0,
        correctPredictions: 0,
        exactScorePredictions: 0,
        referralCount: 0,
        currentTier: 'Fan',
        currentRank: 0,
      );

  @override
  List<Object?> get props => [
        totalEarned,
        totalSpent,
        transactionCount,
        correctPredictions,
        exactScorePredictions,
        referralCount,
        currentTier,
        currentRank,
      ];
}
