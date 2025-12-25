/// Configuration for $PRE token on Base blockchain
class TokenConfig {
  TokenConfig._();

  // Token Details
  static const String tokenName = 'Pregame Token';
  static const String tokenSymbol = 'PRE';
  static const int tokenDecimals = 18;
  static const String totalSupply = '500000000'; // 500M

  // Contract Addresses (TBD - not yet deployed)
  static const String mainnetContractAddress = ''; // Base Mainnet
  static const String testnetContractAddress = ''; // Base Sepolia

  // Base Network Configuration
  static const baseMainnet = BaseNetworkConfig(
    name: 'Base Mainnet',
    chainId: 8453,
    rpcUrl: 'https://mainnet.base.org',
    blockExplorer: 'https://basescan.org',
    currencySymbol: 'ETH',
    isTestnet: false,
  );

  static const baseSepolia = BaseNetworkConfig(
    name: 'Base Sepolia',
    chainId: 84532,
    rpcUrl: 'https://sepolia.base.org',
    blockExplorer: 'https://sepolia.basescan.org',
    currencySymbol: 'ETH',
    isTestnet: true,
  );

  // Use testnet during development
  static const bool useTestnet = true;
  static BaseNetworkConfig get activeNetwork =>
      useTestnet ? baseSepolia : baseMainnet;

  static String get contractAddress =>
      useTestnet ? testnetContractAddress : mainnetContractAddress;

  // Token Rewards Configuration
  static const tokenRewards = TokenRewardsConfig(
    correctPrediction: 10,
    exactScorePrediction: 50,
    dailyCheckIn: 5,
    referral: 100,
    weeklyLeaderboardWin: 500,
    tournamentBracketWin: 5000,
    completeProfile: 25,
    connectSocial: 10,
  );

  // Token Costs Configuration
  static const tokenCosts = TokenCostsConfig(
    aiMatchInsight: 5,
    premiumStatsPack: 50,
    adFreeWeek: 25,
    tournamentEntry: 100,
    exclusiveContent: 20,
    profileBadge: 10,
    nftMoment: 200,
  );

  // Staking Tiers
  static const stakingTiers = [
    StakingTier(
      name: 'Fan',
      minStake: 0,
      bonusMultiplier: 1.0,
      benefits: ['Basic features'],
    ),
    StakingTier(
      name: 'Super Fan',
      minStake: 1000,
      bonusMultiplier: 1.1,
      benefits: ['10% bonus rewards', 'Priority support'],
    ),
    StakingTier(
      name: 'VIP Fan',
      minStake: 10000,
      bonusMultiplier: 1.25,
      benefits: ['25% bonus rewards', 'Exclusive content', 'Early access'],
    ),
    StakingTier(
      name: 'Legend',
      minStake: 100000,
      bonusMultiplier: 1.5,
      benefits: ['50% bonus rewards', 'Governance voting', 'NFT airdrops'],
    ),
  ];

  // ERC-20 ABI (minimal for balance and transfer)
  static const String erc20Abi = '''
[
  {
    "constant": true,
    "inputs": [{"name": "_owner", "type": "address"}],
    "name": "balanceOf",
    "outputs": [{"name": "balance", "type": "uint256"}],
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "decimals",
    "outputs": [{"name": "", "type": "uint8"}],
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "symbol",
    "outputs": [{"name": "", "type": "string"}],
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "name",
    "outputs": [{"name": "", "type": "string"}],
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "totalSupply",
    "outputs": [{"name": "", "type": "uint256"}],
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {"name": "_to", "type": "address"},
      {"name": "_value", "type": "uint256"}
    ],
    "name": "transfer",
    "outputs": [{"name": "", "type": "bool"}],
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      {"name": "_owner", "type": "address"},
      {"name": "_spender", "type": "address"}
    ],
    "name": "allowance",
    "outputs": [{"name": "", "type": "uint256"}],
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {"name": "_spender", "type": "address"},
      {"name": "_value", "type": "uint256"}
    ],
    "name": "approve",
    "outputs": [{"name": "", "type": "bool"}],
    "type": "function"
  },
  {
    "anonymous": false,
    "inputs": [
      {"indexed": true, "name": "from", "type": "address"},
      {"indexed": true, "name": "to", "type": "address"},
      {"indexed": false, "name": "value", "type": "uint256"}
    ],
    "name": "Transfer",
    "type": "event"
  }
]
''';
}

/// Base network configuration
class BaseNetworkConfig {
  final String name;
  final int chainId;
  final String rpcUrl;
  final String blockExplorer;
  final String currencySymbol;
  final bool isTestnet;

  const BaseNetworkConfig({
    required this.name,
    required this.chainId,
    required this.rpcUrl,
    required this.blockExplorer,
    required this.currencySymbol,
    required this.isTestnet,
  });

  String get chainIdHex => '0x${chainId.toRadixString(16)}';

  String txUrl(String txHash) => '$blockExplorer/tx/$txHash';
  String addressUrl(String address) => '$blockExplorer/address/$address';
  String tokenUrl(String contractAddress) => '$blockExplorer/token/$contractAddress';
}

/// Token rewards configuration
class TokenRewardsConfig {
  final int correctPrediction;
  final int exactScorePrediction;
  final int dailyCheckIn;
  final int referral;
  final int weeklyLeaderboardWin;
  final int tournamentBracketWin;
  final int completeProfile;
  final int connectSocial;

  const TokenRewardsConfig({
    required this.correctPrediction,
    required this.exactScorePrediction,
    required this.dailyCheckIn,
    required this.referral,
    required this.weeklyLeaderboardWin,
    required this.tournamentBracketWin,
    required this.completeProfile,
    required this.connectSocial,
  });
}

/// Token costs configuration
class TokenCostsConfig {
  final int aiMatchInsight;
  final int premiumStatsPack;
  final int adFreeWeek;
  final int tournamentEntry;
  final int exclusiveContent;
  final int profileBadge;
  final int nftMoment;

  const TokenCostsConfig({
    required this.aiMatchInsight,
    required this.premiumStatsPack,
    required this.adFreeWeek,
    required this.tournamentEntry,
    required this.exclusiveContent,
    required this.profileBadge,
    required this.nftMoment,
  });
}

/// Staking tier configuration
class StakingTier {
  final String name;
  final int minStake;
  final double bonusMultiplier;
  final List<String> benefits;

  const StakingTier({
    required this.name,
    required this.minStake,
    required this.bonusMultiplier,
    required this.benefits,
  });

  /// Check if user qualifies for this tier
  bool qualifies(int stakedAmount) => stakedAmount >= minStake;

  /// Get the highest tier for a staked amount
  static StakingTier getTier(int stakedAmount) {
    for (var i = TokenConfig.stakingTiers.length - 1; i >= 0; i--) {
      if (TokenConfig.stakingTiers[i].qualifies(stakedAmount)) {
        return TokenConfig.stakingTiers[i];
      }
    }
    return TokenConfig.stakingTiers.first;
  }
}
