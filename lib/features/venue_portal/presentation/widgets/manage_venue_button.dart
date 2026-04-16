import '../../../../config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../recommendations/domain/entities/place.dart';
import '../../domain/entities/entities.dart';
import '../../domain/entities/venue_enhancement.dart';
import '../../domain/services/venue_enhancement_service.dart';
import '../bloc/venue_enhancement_cubit.dart';
import '../screens/venue_onboarding/venue_onboarding_screen.dart';
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

        // Current user owns this venue
        if (enhancement.ownerId == currentUserId) {
          if (enhancement.isClaimPending) {
            return _buildClaimPendingButton(context, enhancement);
          }
          return _buildOwnVenueButton(context);
        }

        // Someone else owns this venue
        return _buildAlreadyManagedButton(context, enhancement);
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
                colors: [AppTheme.primaryOrange, Color(0xFFFFA726)],
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

  Widget _buildClaimPendingButton(BuildContext context, VenueEnhancement enhancement) {
    final l10n = AppLocalizations.of(context);
    final statusText = enhancement.claimStatus == VenueClaimStatus.pendingVerification
        ? l10n.venuePortalPendingVerification
        : l10n.venuePortalPendingAdminReview;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(l10n.venuePortalClaimStatus),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.venuePortalVenueLabel(venue.name)),
                    const SizedBox(height: 8),
                    Text('${l10n.status}: $statusText'),
                    const SizedBox(height: 8),
                    if (enhancement.claimStatus == VenueClaimStatus.pendingVerification)
                      Text(l10n.venuePortalCompletePhoneVerification)
                    else
                      Text(l10n.venuePortalClaimUnderReview),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(l10n.ok),
                  ),
                ],
              ),
            );
          },
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
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
                  const Icon(Icons.hourglass_top, color: Colors.white, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    statusText,
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

  Widget _buildAlreadyManagedButton(BuildContext context, VenueEnhancement enhancement) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          Container(
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
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _showDisputeSheet(context, enhancement),
            icon: const Icon(Icons.flag_outlined, size: 16),
            label: Text(AppLocalizations.of(context).venuePortalReportDisputeClaim),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  void _showDisputeSheet(BuildContext context, VenueEnhancement enhancement) {
    String? selectedReason;
    final detailsController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).venuePortalDisputeVenueClaim,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).venuePortalReportIncorrectClaim(venue.name),
                style: const TextStyle(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 16),
              // Reason chips
              Wrap(
                spacing: 8,
                children: [
                  'I am the real owner',
                  'Venue is closed',
                  'Fraudulent claim',
                  'Other',
                ].map((reason) => ChoiceChip(
                      label: Text(reason),
                      selected: selectedReason == reason,
                      onSelected: (selected) {
                        setSheetState(() {
                          selectedReason = selected ? reason : null;
                        });
                      },
                      selectedColor: AppTheme.primaryOrange,
                      labelStyle: TextStyle(
                        color: selectedReason == reason ? Colors.white : Colors.white70,
                      ),
                      backgroundColor: const Color(0xFF334155),
                    ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: detailsController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).venuePortalAdditionalDetails,
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF334155),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedReason == null
                      ? null
                      : () async {
                          final service = sl<VenueEnhancementService>();
                          try {
                            await service.submitDispute(
                              venue.placeId,
                              selectedReason!,
                              detailsController.text,
                            );
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context).venuePortalDisputeSubmitted),
                                  backgroundColor: const Color(0xFF10B981),
                                ),
                              );
                            }
                          } catch (e) {
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.white12,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context).venuePortalSubmitDispute,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
