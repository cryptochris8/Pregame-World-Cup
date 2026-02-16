import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/venue_enhancement_cubit.dart';
import '../bloc/venue_enhancement_state.dart';
import '../widgets/premium_feature_gate.dart';
import 'match_broadcasting_screen.dart';
import 'tv_setup_screen.dart';
import 'game_day_specials_screen.dart';
import 'atmosphere_settings_screen.dart';
import 'capacity_update_screen.dart';
import 'venue_subscription_card.dart';
import 'venue_quick_stats.dart';
import 'shows_matches_toggle.dart';
import 'venue_premium_upgrade_dialog.dart';

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
                            .withValues(alpha: 0.7),
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
    return RefreshIndicator(
      onRefresh: () => context.read<VenueEnhancementCubit>().refresh(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VenueSubscriptionCard(
              state: state,
              onUpgrade: () => _showUpgradeDialog(context),
            ),

            if (state.isFree) ...[
              const SizedBox(height: 16),
              PremiumUpgradeBanner(
                onUpgradePressed: () => _showUpgradeDialog(context),
              ),
            ],

            const SizedBox(height: 24),

            VenueQuickStats(state: state),

            const SizedBox(height: 24),

            Text(
              'Broadcasting',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ShowsMatchesToggle(state: state),

            const SizedBox(height: 24),

            Text(
              'Premium Features',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
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

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => VenuePremiumUpgradeDialog(
        venueId: venueId,
        venueName: venueName,
        onPurchaseComplete: () {
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
