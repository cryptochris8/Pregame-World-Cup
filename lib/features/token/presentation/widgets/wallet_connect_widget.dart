import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_theme.dart';
import '../../domain/entities/token_entities.dart';
import '../bloc/token_cubit.dart';

/// Button to connect/disconnect wallet
class WalletConnectButton extends StatelessWidget {
  final bool showBalance;
  final bool compact;

  const WalletConnectButton({
    super.key,
    this.showBalance = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TokenCubit, TokenState>(
      builder: (context, state) {
        if (state.isConnecting) {
          return _buildConnectingState(context);
        }

        if (state.isConnected && state.wallet != null) {
          return _buildConnectedState(context, state);
        }

        return _buildDisconnectedState(context, state);
      },
    );
  }

  Widget _buildConnectingState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.5)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.primaryPurple,
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Connecting...',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedState(BuildContext context, TokenState state) {
    if (compact) {
      return InkWell(
        onTap: () => _showWalletOptions(context, state),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.secondaryEmerald.withOpacity(0.2),
                AppTheme.primaryPurple.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.secondaryEmerald.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.secondaryEmerald,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                state.balance.shortFormatted,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => _showWalletOptions(context, state),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.backgroundCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Wallet icon with status
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: AppTheme.primaryPurple,
                    size: 20,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryEmerald,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.backgroundCard,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // Balance and address
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showBalance) ...[
                    Text(
                      state.balance.formatted,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    state.wallet!.displayName,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white60,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisconnectedState(BuildContext context, TokenState state) {
    return InkWell(
      onTap: () => _showConnectDialog(context),
      borderRadius: BorderRadius.circular(compact ? 20 : 12),
      child: Container(
        padding: compact
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
          ),
          borderRadius: BorderRadius.circular(compact ? 20 : 12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryPurple.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              color: Colors.white,
              size: compact ? 16 : 20,
            ),
            SizedBox(width: compact ? 6 : 8),
            Text(
              compact ? 'Connect' : 'Connect Wallet',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: compact ? 13 : 14,
              ),
            ),
            if (state.hasPendingRewards && !compact) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+${state.pendingRewardsTotal}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showConnectDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const WalletConnectSheet(),
    );
  }

  void _showWalletOptions(BuildContext context, TokenState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => WalletOptionsSheet(state: state),
    );
  }
}

/// Bottom sheet for connecting wallet
class WalletConnectSheet extends StatelessWidget {
  const WalletConnectSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Connect Wallet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Connect your wallet to earn and spend \$PRE tokens',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Wallet options
              _buildWalletOption(
                context,
                provider: WalletProvider.coinbaseWallet,
                isRecommended: true,
              ),
              const SizedBox(height: 12),
              _buildWalletOption(
                context,
                provider: WalletProvider.metaMask,
              ),
              const SizedBox(height: 12),
              _buildWalletOption(
                context,
                provider: WalletProvider.walletConnect,
              ),

              const SizedBox(height: 24),

              // Network info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.white.withOpacity(0.5),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Connects to Base Network (Coinbase L2)',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletOption(
    BuildContext context, {
    required WalletProvider provider,
    bool isRecommended = false,
  }) {
    return InkWell(
      onTap: () {
        context.read<TokenCubit>().connectWallet(provider);
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRecommended
                ? AppTheme.primaryPurple.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            // Icon placeholder (would use actual wallet icons)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getWalletIcon(provider),
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  if (isRecommended)
                    const Text(
                      'Recommended',
                      style: TextStyle(
                        color: AppTheme.secondaryEmerald,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),

            // Arrow
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white38,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWalletIcon(WalletProvider provider) {
    switch (provider) {
      case WalletProvider.coinbaseWallet:
        return Icons.account_balance_wallet;
      case WalletProvider.metaMask:
        return Icons.pets; // Fox-like icon
      case WalletProvider.rainbow:
        return Icons.wb_twilight;
      case WalletProvider.walletConnect:
        return Icons.qr_code_scanner;
      case WalletProvider.unknown:
        return Icons.account_balance_wallet_outlined;
    }
  }
}

/// Bottom sheet for wallet options when connected
class WalletOptionsSheet extends StatelessWidget {
  final TokenState state;

  const WalletOptionsSheet({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Balance display
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryPurple.withOpacity(0.2),
                      AppTheme.primaryBlue.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      '\$PRE Balance',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.balance.formatted,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.wallet!.displayName,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Options
              _buildOption(
                icon: Icons.refresh,
                label: 'Refresh Balance',
                onTap: () {
                  context.read<TokenCubit>().refreshBalance();
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 12),
              _buildOption(
                icon: Icons.history,
                label: 'Transaction History',
                onTap: () {
                  Navigator.of(context).pop();
                  // Navigate to transaction history
                },
              ),
              const SizedBox(height: 12),
              _buildOption(
                icon: Icons.open_in_new,
                label: 'View on Explorer',
                onTap: () {
                  // Open block explorer
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 12),
              _buildOption(
                icon: Icons.logout,
                label: 'Disconnect Wallet',
                color: AppTheme.secondaryRose,
                onTap: () {
                  context.read<TokenCubit>().disconnectWallet();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? Colors.white70, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color ?? Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color?.withOpacity(0.5) ?? Colors.white38,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
