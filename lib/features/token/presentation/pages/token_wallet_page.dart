import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_theme.dart';
import '../bloc/token_cubit.dart';
import '../widgets/widgets.dart';

/// Main page for $PRE token wallet
class TokenWalletPage extends StatelessWidget {
  const TokenWalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('\$PRE Wallet', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          BlocBuilder<TokenCubit, TokenState>(
            builder: (context, state) {
              if (state.isRefreshing) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => context.read<TokenCubit>().refreshBalance(),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: AppTheme.mainGradientDecoration,
        child: SafeArea(
          child: BlocBuilder<TokenCubit, TokenState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              return RefreshIndicator(
                color: AppTheme.secondaryEmerald,
                onRefresh: () => context.read<TokenCubit>().refreshBalance(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Balance card
                      const TokenBalanceCard(),

                      const SizedBox(height: 24),

                      // Wallet connection
                      if (!state.isConnected) ...[
                        _buildConnectPrompt(context, state),
                        const SizedBox(height: 24),
                      ],

                      // Quick actions
                      if (state.isConnected) ...[
                        _buildQuickActions(context),
                        const SizedBox(height: 24),
                      ],

                      // Earning opportunities
                      _buildEarningOpportunities(context),

                      const SizedBox(height: 24),

                      // Transaction summary
                      const TransactionSummaryCard(),

                      const SizedBox(height: 24),

                      // Recent transactions
                      const TransactionHistoryList(limit: 5),

                      const SizedBox(height: 24),

                      // Network info
                      _buildNetworkInfo(context),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildConnectPrompt(BuildContext context, TokenState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPurple.withOpacity(0.2),
            AppTheme.primaryBlue.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            color: AppTheme.primaryPurple,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Connect Your Wallet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Connect a wallet to earn and spend \$PRE tokens. Your rewards are waiting!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
          if (state.hasPendingRewards) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.card_giftcard, color: AppTheme.accentGold, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '+${state.pendingRewardsTotal} PRE pending',
                    style: const TextStyle(
                      color: AppTheme.accentGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          const WalletConnectButton(),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.arrow_downward,
            label: 'Receive',
            color: AppTheme.secondaryEmerald,
            onTap: () => _showReceiveDialog(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.arrow_upward,
            label: 'Send',
            color: AppTheme.primaryPurple,
            onTap: () => _showSendDialog(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.lock,
            label: 'Stake',
            color: AppTheme.accentGold,
            onTap: () => _showStakeDialog(context),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningOpportunities(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.emoji_events, color: AppTheme.accentGold, size: 20),
              SizedBox(width: 8),
              Text(
                'Ways to Earn',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildEarningItem(
            icon: '⚽',
            title: 'Correct Prediction',
            reward: '+10 PRE',
            description: 'Predict match results correctly',
          ),
          _buildEarningItem(
            icon: '🎯',
            title: 'Exact Score',
            reward: '+50 PRE',
            description: 'Predict the exact final score',
          ),
          _buildEarningItem(
            icon: '📅',
            title: 'Daily Check-in',
            reward: '+5 PRE',
            description: 'Open the app daily',
          ),
          _buildEarningItem(
            icon: '👥',
            title: 'Refer Friends',
            reward: '+100 PRE',
            description: 'Invite friends to join',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildEarningItem({
    required String icon,
    required String title,
    required String reward,
    required String description,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.secondaryEmerald.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              reward,
              style: const TextStyle(
                color: AppTheme.secondaryEmerald,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkInfo(BuildContext context) {
    final cubit = context.read<TokenCubit>();
    final networkInfo = cubit.getNetworkInfo();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('🔵', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  networkInfo['name'] ?? 'Base Network',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  networkInfo['isTestnet'] == true ? 'Testnet' : 'Mainnet',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.secondaryEmerald.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: AppTheme.secondaryEmerald, size: 14),
                SizedBox(width: 4),
                Text(
                  'Connected',
                  style: TextStyle(
                    color: AppTheme.secondaryEmerald,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReceiveDialog(BuildContext context) {
    final state = context.read<TokenCubit>().state;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.backgroundCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Receive \$PRE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.qr_code, size: 150, color: Colors.black),
              ),
              const SizedBox(height: 16),
              Text(
                state.wallet?.address ?? '',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Copy address
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy Address'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSendDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Send feature coming soon!'),
        backgroundColor: AppTheme.primaryPurple,
      ),
    );
  }

  void _showStakeDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Staking feature coming soon!'),
        backgroundColor: AppTheme.accentGold,
      ),
    );
  }
}
