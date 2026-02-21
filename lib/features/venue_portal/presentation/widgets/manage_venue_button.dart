import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../recommendations/domain/entities/place.dart';
import '../../domain/entities/entities.dart';
import '../../domain/services/venue_enhancement_service.dart';
import '../bloc/venue_enhancement_cubit.dart';
import '../screens/venue_onboarding_screen.dart';
import '../screens/venue_portal_home_screen.dart';
import '../../../../injection_container.dart';

class ManageVenueButton extends StatelessWidget {
  final Place venue;

  const ManageVenueButton({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    final service = sl<VenueEnhancementService>();

    return FutureBuilder<VenueEnhancement?>(
      future: service.getVenueEnhancement(venue.placeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingButton();
        }

        final enhancement = snapshot.data;
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;

        if (enhancement == null || enhancement.ownerId.isEmpty) {
          return _buildUnclaimedButton(context);
        }

        if (enhancement.ownerId == currentUserId) {
          return _buildOwnVenueButton(context);
        }

        return _buildAlreadyManagedButton(context);
      },
    );
  }

  Widget _buildLoadingButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF334155),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white38,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnclaimedButton(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VenueOnboardingScreen(venue: venue),
              ),
            );
          },
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFFA726)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.storefront, color: Colors.white, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    l10n.manageThisVenue,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOwnVenueButton(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => sl<VenueEnhancementCubit>()
                    ..loadEnhancement(
                      venue.placeId,
                      venueName: venue.name,
                    ),
                  child: VenuePortalHomeScreen(
                    venueId: venue.placeId,
                    venueName: venue.name,
                  ),
                ),
              ),
            );
          },
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF34D399)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.dashboard, color: Colors.white, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    l10n.openVenuePortal,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlreadyManagedButton(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF334155),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, color: Colors.white38, size: 22),
            const SizedBox(width: 12),
            Text(
              l10n.venueAlreadyManaged,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
