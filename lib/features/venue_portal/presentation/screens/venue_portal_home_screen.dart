import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/entities.dart';
import '../../../worldcup/domain/services/world_cup_payment_service.dart';
import '../bloc/venue_enhancement_cubit.dart';
import '../bloc/venue_enhancement_state.dart';
import '../widgets/premium_feature_gate.dart';
import 'match_broadcasting_screen.dart';
import 'tv_setup_screen.dart';
import 'game_day_specials_screen.dart';
import 'atmosphere_settings_screen.dart';
import 'capacity_update_screen.dart';

/// Main dashboard for venue owners to manage their venue enhancements
class VenuePortalHomeScreen extends StatelessWidget {
  final String venueId;
  final String venueName;

  const VenuePortalHomeScreen({
    super.key,
    required this.venueId,
    required this.venueName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VenueEnhancementCubit, VenueEnhancementState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venueName,
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  'Venue Portal',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                ),
              ],
            ),
            actions: [
              if (state.isLoading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () =>
                      context.read<VenueEnhancementCubit>().refresh(),
                ),
            ],
          ),
          body: state.isLoading && !state.hasEnhancement
              ? const Center(child: CircularProgressIndicator())
              : state.hasError
                  ? _buildErrorState(context, state)
                  : _buildDashboard(context, state),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, VenueEnhancementState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              state.errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () =>
                  context.read<VenueEnhancementCubit>().refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, VenueEnhancementState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: () => context.read<VenueEnhancementCubit>().refresh(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subscription Status Card
            _buildSubscriptionCard(context, state),

            // Premium Upgrade Banner (for free users)
            if (state.isFree) ...[
              const SizedBox(height: 16),
              PremiumUpgradeBanner(
                onUpgradePressed: () => _showUpgradeDialog(context),
              ),
            ],

            const SizedBox(height: 24),

            // Quick Stats
            _buildQuickStats(context, state),

            const SizedBox(height: 24),

            // FREE TIER - Shows Matches Toggle
            Text(
              'Broadcasting',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildShowsMatchesToggle(context, state),

            const SizedBox(height: 24),

            // PREMIUM FEATURES
            Text(
              'Premium Features',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            PremiumFeatureCard(
              title: 'Match Scheduling',
              description: 'Select specific matches you\'ll broadcast',
              icon: Icons.tv,
              currentTier: state.tier,
              onTap: () => _navigateToMatchBroadcasting(context),
              onUpgradePressed: () => _showUpgradeDialog(context),
            ),
            const SizedBox(height: 8),
            PremiumFeatureCard(
              title: 'TV & Screen Setup',
              description: 'Configure your screens and audio setup',
              icon: Icons.monitor,
              currentTier: state.tier,
              onTap: () => _navigateToTvSetup(context),
              onUpgradePressed: () => _showUpgradeDialog(context),
            ),
            const SizedBox(height: 8),
            PremiumFeatureCard(
              title: 'Game Day Specials',
              description: 'Create deals and specials for match days',
              icon: Icons.local_offer,
              currentTier: state.tier,
              onTap: () => _navigateToSpecials(context),
              onUpgradePressed: () => _showUpgradeDialog(context),
            ),
            const SizedBox(height: 8),
            PremiumFeatureCard(
              title: 'Atmosphere Settings',
              description: 'Set your vibe, noise level, and fan affiliations',
              icon: Icons.celebration,
              currentTier: state.tier,
              onTap: () => _navigateToAtmosphere(context),
              onUpgradePressed: () => _showUpgradeDialog(context),
            ),
            const SizedBox(height: 8),
            PremiumFeatureCard(
              title: 'Live Capacity',
              description: 'Real-time occupancy and wait time updates',
              icon: Icons.groups,
              currentTier: state.tier,
              onTap: () => _navigateToCapacity(context),
              onUpgradePressed: () => _showUpgradeDialog(context),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(
    BuildContext context,
    VenueEnhancementState state,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPremium = state.isPremium;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isPremium
                    ? Colors.amber.withOpacity(0.2)
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isPremium ? Icons.star : Icons.store,
                color: isPremium ? Colors.amber : colorScheme.onSurfaceVariant,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPremium ? 'Premium Venue' : 'Free Plan',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isPremium
                        ? 'All features unlocked'
                        : 'Basic features only',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (!isPremium)
              FilledButton.tonal(
                onPressed: () => _showUpgradeDialog(context),
                child: const Text('Upgrade'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, VenueEnhancementState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.tv,
            value: state.isPremium ? '${state.tvSetup?.totalScreens ?? 0}' : '-',
            label: 'TVs',
            isLocked: !state.isPremium,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.local_offer,
            value: state.isPremium ? '${state.activeSpecials.length}' : '-',
            label: 'Active Specials',
            isLocked: !state.isPremium,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.calendar_month,
            value: state.isPremium
                ? '${state.broadcastingSchedule?.matchIds.length ?? 0}'
                : '-',
            label: 'Scheduled',
            isLocked: !state.isPremium,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    bool isLocked = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(
              icon,
              color: isLocked
                  ? colorScheme.onSurfaceVariant.withOpacity(0.5)
                  : colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isLocked
                    ? colorScheme.onSurfaceVariant.withOpacity(0.5)
                    : null,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShowsMatchesToggle(
    BuildContext context,
    VenueEnhancementState state,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.sports_soccer,
              color: state.showsMatches
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Show World Cup Matches',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    state.showsMatches
                        ? 'Your venue is listed as showing matches'
                        : 'Toggle on to appear in match venue searches',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: state.showsMatches,
              onChanged: state.isSaving
                  ? null
                  : (value) {
                      context
                          .read<VenueEnhancementCubit>()
                          .updateShowsMatches(value);
                    },
            ),
          ],
        ),
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => _VenuePremiumUpgradeDialog(
        venueId: venueId,
        venueName: venueName,
        onPurchaseComplete: () {
          // Refresh the enhancement data after purchase
          context.read<VenueEnhancementCubit>().refresh();
        },
      ),
    );
  }

  void _navigateToMatchBroadcasting(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<VenueEnhancementCubit>(),
          child: MatchBroadcastingScreen(
            venueId: venueId,
            venueName: venueName,
          ),
        ),
      ),
    );
  }

  void _navigateToTvSetup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<VenueEnhancementCubit>(),
          child: TvSetupScreen(
            venueId: venueId,
            venueName: venueName,
          ),
        ),
      ),
    );
  }

  void _navigateToSpecials(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<VenueEnhancementCubit>(),
          child: GameDaySpecialsScreen(
            venueId: venueId,
            venueName: venueName,
          ),
        ),
      ),
    );
  }

  void _navigateToAtmosphere(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<VenueEnhancementCubit>(),
          child: AtmosphereSettingsScreen(
            venueId: venueId,
            venueName: venueName,
          ),
        ),
      ),
    );
  }

  void _navigateToCapacity(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<VenueEnhancementCubit>(),
          child: CapacityUpdateScreen(
            venueId: venueId,
            venueName: venueName,
          ),
        ),
      ),
    );
  }
}

class _FeatureListItem extends StatelessWidget {
  final String text;

  const _FeatureListItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}

/// Dialog for upgrading to Venue Premium
class _VenuePremiumUpgradeDialog extends StatefulWidget {
  final String venueId;
  final String venueName;
  final VoidCallback? onPurchaseComplete;

  const _VenuePremiumUpgradeDialog({
    required this.venueId,
    required this.venueName,
    this.onPurchaseComplete,
  });

  @override
  State<_VenuePremiumUpgradeDialog> createState() =>
      _VenuePremiumUpgradeDialogState();
}

class _VenuePremiumUpgradeDialogState
    extends State<_VenuePremiumUpgradeDialog> {
  final WorldCupPaymentService _paymentService = WorldCupPaymentService();
  bool _isPurchasing = false;
  WorldCupPricing? _pricing;

  @override
  void initState() {
    super.initState();
    _loadPricing();
  }

  Future<void> _loadPricing() async {
    final pricing = await _paymentService.getPricing();
    if (mounted) {
      setState(() => _pricing = pricing);
    }
  }

  Future<void> _startPurchase() async {
    setState(() => _isPurchasing = true);

    try {
      final success = await _paymentService.openVenuePremiumCheckout(
        venueId: widget.venueId,
        venueName: widget.venueName,
        context: context,
      );

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Complete your purchase in the browser. Return here when done.',
            ),
            duration: Duration(seconds: 5),
          ),
        );
        widget.onPurchaseComplete?.call();
      }
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final price = _pricing?.venuePremium.displayPrice ?? '\$99.00';

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.star, color: Colors.amber),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Upgrade to Premium'),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.tertiary,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    price,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'One-time payment for World Cup 2026',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Premium features include:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const _FeatureListItem(text: 'Specific match scheduling'),
            const _FeatureListItem(text: 'TV & screen configuration'),
            const _FeatureListItem(text: 'Game day specials & deals'),
            const _FeatureListItem(text: 'Atmosphere & vibe settings'),
            const _FeatureListItem(text: 'Real-time capacity updates'),
            const _FeatureListItem(text: 'Priority listing in searches'),
            const _FeatureListItem(text: 'Analytics dashboard'),

            const SizedBox(height: 16),

            // Tournament info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Valid for the entire tournament (June 11 - July 19, 2026)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isPurchasing ? null : () => Navigator.pop(context),
          child: const Text('Not Now'),
        ),
        FilledButton.icon(
          onPressed: _isPurchasing ? null : _startPurchase,
          icon: _isPurchasing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.shopping_cart, size: 18),
          label: Text(_isPurchasing ? 'Processing...' : 'Upgrade Now'),
        ),
      ],
    );
  }
}
