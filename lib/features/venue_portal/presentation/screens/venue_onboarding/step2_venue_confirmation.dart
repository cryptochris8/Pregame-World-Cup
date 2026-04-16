import '../../../../../config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../recommendations/domain/entities/place.dart';
import '../../../domain/entities/entities.dart';
import '../../bloc/venue_onboarding_cubit.dart';
import '../../bloc/venue_onboarding_state.dart';
import 'onboarding_form_components.dart';

/// Step 2: Venue Confirmation with type selection and authorization checkbox.
class Step2VenueConfirmation extends StatelessWidget {
  final Place venue;
  final VenueOnboardingState state;

  const Step2VenueConfirmation({
    super.key,
    required this.venue,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<VenueOnboardingCubit>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepHeader(
            title: l10n.venueOnboardingStep2Title,
            description: l10n.venueOnboardingStep2Desc,
          ),
          const SizedBox(height: 24),
          // Venue card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryOrange, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.store,
                    color: AppTheme.primaryOrange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        venue.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (venue.vicinity != null)
                        Text(
                          venue.vicinity!,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle, color: Color(0xFF4ADE80)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OnboardingDropdown<VenueType>(
            label: l10n.venueTypeLabel,
            icon: Icons.category,
            value: state.claimInfo.venueType,
            items: VenueType.values,
            itemLabel: (t) => t.displayName,
            onChanged: (type) {
              if (type != null) {
                cubit.updateClaimInfo(
                    state.claimInfo.copyWith(venueType: type));
              }
            },
          ),
          const SizedBox(height: 24),
          // Authorization checkbox
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: state.claimInfo.authorizedConfirmed,
                  onChanged: (v) {
                    cubit.updateClaimInfo(
                      state.claimInfo.copyWith(authorizedConfirmed: v ?? false),
                    );
                  },
                  activeColor: AppTheme.primaryOrange,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      l10n.venueAuthorizationConfirm,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => cubit.previousStep(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(l10n.back),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: NextButton(
                  enabled: state.canProceedFromStep2,
                  onPressed: () => cubit.nextStep(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
