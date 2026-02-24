import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/entities.dart';
import '../../bloc/venue_onboarding_cubit.dart';
import '../../bloc/venue_onboarding_state.dart';
import 'onboarding_form_components.dart';

/// Step 1: Business Info collection.
class Step1BusinessInfo extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController businessNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final VenueOnboardingState state;
  final void Function(VenueOnboardingCubit cubit) syncClaimInfo;

  const Step1BusinessInfo({
    super.key,
    required this.formKey,
    required this.businessNameController,
    required this.emailController,
    required this.phoneController,
    required this.state,
    required this.syncClaimInfo,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<VenueOnboardingCubit>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StepHeader(
              title: l10n.venueOnboardingStep1Title,
              description: l10n.venueOnboardingStep1Desc,
            ),
            const SizedBox(height: 24),
            OnboardingTextField(
              controller: businessNameController,
              label: l10n.businessName,
              icon: Icons.store,
              validator: (v) =>
                  (v == null || v.isEmpty) ? l10n.fieldRequired : null,
              onChanged: (_) => syncClaimInfo(cubit),
            ),
            const SizedBox(height: 16),
            OnboardingDropdown<VenueOwnerRole>(
              label: l10n.yourRole,
              icon: Icons.badge,
              value: state.claimInfo.role,
              items: VenueOwnerRole.values,
              itemLabel: (r) => r.displayName,
              onChanged: (role) {
                if (role != null) {
                  cubit.updateClaimInfo(state.claimInfo.copyWith(role: role));
                }
              },
            ),
            const SizedBox(height: 16),
            OnboardingTextField(
              controller: emailController,
              label: l10n.contactEmail,
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return l10n.fieldRequired;
                if (!v.contains('@')) return l10n.invalidEmail;
                return null;
              },
              onChanged: (_) => syncClaimInfo(cubit),
            ),
            const SizedBox(height: 16),
            OnboardingTextField(
              controller: phoneController,
              label: l10n.contactPhone,
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              onChanged: (_) => syncClaimInfo(cubit),
            ),
            const SizedBox(height: 32),
            NextButton(
              enabled: businessNameController.text.isNotEmpty &&
                  emailController.text.contains('@'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  syncClaimInfo(cubit);
                  cubit.nextStep();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
