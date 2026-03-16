import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/entities.dart';
import '../../bloc/venue_onboarding_cubit.dart';
import '../../bloc/venue_onboarding_state.dart';
import 'onboarding_form_components.dart';

/// Step 3: Review information before phone verification.
class Step3Review extends StatelessWidget {
  final String venueName;
  final VenueOnboardingState state;

  const Step3Review({
    super.key,
    required this.venueName,
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
            title: l10n.venueOnboardingStep3Title,
            description: l10n.reviewInfoDesc,
          ),
          const SizedBox(height: 24),
          // Summary card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SummaryRow(
                    label: l10n.venue, value: venueName, icon: Icons.store),
                const Divider(color: Colors.white12, height: 24),
                SummaryRow(
                    label: l10n.businessName, value: state.claimInfo.businessName, icon: Icons.business),
                const Divider(color: Colors.white12, height: 24),
                SummaryRow(
                    label: l10n.yourRole, value: state.claimInfo.role.displayName, icon: Icons.badge),
                const Divider(color: Colors.white12, height: 24),
                SummaryRow(
                    label: l10n.contactEmail, value: state.claimInfo.contactEmail, icon: Icons.email),
                if (state.claimInfo.contactPhone.isNotEmpty) ...[
                  const Divider(color: Colors.white12, height: 24),
                  SummaryRow(
                      label: l10n.contactPhone, value: state.claimInfo.contactPhone, icon: Icons.phone),
                ],
                const Divider(color: Colors.white12, height: 24),
                SummaryRow(
                    label: l10n.venueTypeLabel,
                    value: state.claimInfo.venueType.displayName,
                    icon: Icons.category),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Info about next step
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFFF59E0B), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.nextStepPhoneHint,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
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
                child: ElevatedButton(
                  onPressed: () => cubit.nextStep(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.continueToVerification,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
