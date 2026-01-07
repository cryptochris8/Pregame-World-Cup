import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/entities.dart';
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
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 8),
            const Text('Upgrade to Premium'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Premium features include:'),
            SizedBox(height: 12),
            _FeatureListItem(text: 'Specific match scheduling'),
            _FeatureListItem(text: 'TV & screen configuration'),
            _FeatureListItem(text: 'Game day specials & deals'),
            _FeatureListItem(text: 'Atmosphere & vibe settings'),
            _FeatureListItem(text: 'Real-time capacity updates'),
            _FeatureListItem(text: 'Priority listing in searches'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not Now'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to payment/subscription flow
            },
            child: const Text('Upgrade'),
          ),
        ],
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
