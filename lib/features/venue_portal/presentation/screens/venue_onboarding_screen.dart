import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../recommendations/domain/entities/place.dart';
import '../../domain/entities/entities.dart';
import '../bloc/venue_onboarding_cubit.dart';
import '../bloc/venue_onboarding_state.dart';
import '../../../../injection_container.dart';

class VenueOnboardingScreen extends StatefulWidget {
  final Place venue;

  const VenueOnboardingScreen({super.key, required this.venue});

  @override
  State<VenueOnboardingScreen> createState() => _VenueOnboardingScreenState();
}

class _VenueOnboardingScreenState extends State<VenueOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _businessNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _verificationCodeController;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _businessNameController = TextEditingController(text: widget.venue.name);
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController();
    _verificationCodeController = TextEditingController();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider(
      create: (_) => sl<VenueOnboardingCubit>()
        ..checkVenueAvailability(widget.venue.placeId),
      child: BlocConsumer<VenueOnboardingCubit, VenueOnboardingState>(
        listener: (context, state) {
          if (state.hasError && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red[700],
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFF1E293B),
            appBar: AppBar(
              backgroundColor: const Color(0xFF1E293B),
              foregroundColor: Colors.white,
              title: Text(l10n.venueOnboardingTitle),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(
                  value: (state.currentStep + 1) / 4,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFF6B35),
                  ),
                ),
              ),
            ),
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, VenueOnboardingState state) {
    if (state.isChecking) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
      );
    }

    if (state.isClaimed) {
      return _buildAlreadyClaimedView(context);
    }

    if (state.isPendingReview) {
      return _buildPendingReviewView(context);
    }

    switch (state.currentStep) {
      case 0:
        return _buildStep1(context, state);
      case 1:
        return _buildStep2(context, state);
      case 2:
        return _buildStep3Review(context, state);
      case 3:
        return _buildStep4PhoneVerification(context, state);
      default:
        return _buildStep1(context, state);
    }
  }

  Widget _buildAlreadyClaimedView(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 64, color: Colors.white38),
            const SizedBox(height: 16),
            Text(
              l10n.venueAlreadyManaged,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.venueAlreadyManagedDesc,
              style: const TextStyle(color: Colors.white60, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: Colors.white24),
              ),
              child: Text(l10n.goBack),
            ),
          ],
        ),
      ),
    );
  }

  // Step 1: Business Info
  Widget _buildStep1(BuildContext context, VenueOnboardingState state) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<VenueOnboardingCubit>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(
              l10n.venueOnboardingStep1Title,
              l10n.venueOnboardingStep1Desc,
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _businessNameController,
              label: l10n.businessName,
              icon: Icons.store,
              validator: (v) =>
                  (v == null || v.isEmpty) ? l10n.fieldRequired : null,
              onChanged: (_) => _syncClaimInfo(cubit),
            ),
            const SizedBox(height: 16),
            _buildDropdown<VenueOwnerRole>(
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
            _buildTextField(
              controller: _emailController,
              label: l10n.contactEmail,
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return l10n.fieldRequired;
                if (!v.contains('@')) return l10n.invalidEmail;
                return null;
              },
              onChanged: (_) => _syncClaimInfo(cubit),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: l10n.contactPhone,
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              onChanged: (_) => _syncClaimInfo(cubit),
            ),
            const SizedBox(height: 32),
            _buildNextButton(
              context,
              enabled: _businessNameController.text.isNotEmpty &&
                  _emailController.text.contains('@'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _syncClaimInfo(cubit);
                  cubit.nextStep();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Step 2: Venue Confirmation
  Widget _buildStep2(BuildContext context, VenueOnboardingState state) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<VenueOnboardingCubit>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            l10n.venueOnboardingStep2Title,
            l10n.venueOnboardingStep2Desc,
          ),
          const SizedBox(height: 24),
          // Venue card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFF6B35), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.store,
                    color: Color(0xFFFF6B35),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.venue.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.venue.vicinity != null)
                        Text(
                          widget.venue.vicinity!,
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
          _buildDropdown<VenueType>(
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
                  activeColor: const Color(0xFFFF6B35),
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
                child: _buildNextButton(
                  context,
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

  // Step 4: Phone Verification
  Widget _buildStep4PhoneVerification(BuildContext context, VenueOnboardingState state) {
    final cubit = context.read<VenueOnboardingCubit>();
    final isSending = state.isSendingCode;
    final isVerifying = state.isVerifying;
    final isPending = state.isPendingVerification;
    final hasSubmitted = isPending || isSending || isVerifying;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Phone Verification',
            'We\'ll send a verification code to the venue\'s phone number to confirm your connection to this venue.',
          ),
          const SizedBox(height: 24),
          // Phone number display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.phone, color: Color(0xFFFF6B35), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Venue Phone',
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        state.claimInfo.contactPhone.isNotEmpty
                            ? state.claimInfo.contactPhone
                            : 'No phone number provided',
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Send code button
          if (!hasSubmitted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  cubit.claimVenue(widget.venue.placeId, widget.venue.name);
                },
                icon: const Icon(Icons.send, size: 18),
                label: const Text('Submit Claim & Send Code'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          if (state.isSubmitting)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
              ),
            ),
          if (isPending) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isSending
                    ? null
                    : () => cubit.sendVerificationCode(widget.venue.placeId),
                icon: isSending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.refresh, size: 18),
                label: Text(isSending ? 'Sending...' : 'Send Verification Code'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Color(0xFFFF6B35)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Code input
            _buildTextField(
              controller: _verificationCodeController,
              label: 'Verification Code',
              icon: Icons.lock_outline,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isVerifying || _verificationCodeController.text.length != 6
                    ? null
                    : () => cubit.verifyCode(
                          widget.venue.placeId,
                          _verificationCodeController.text,
                        ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.white12,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isVerifying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Verify Code',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: state.isSubmitting ? null : () => cubit.previousStep(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Back'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Pending Review confirmation screen
  Widget _buildPendingReviewView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_top,
                size: 40,
                color: Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Claim Submitted',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Your venue claim has been verified and is now pending admin review. You\'ll be notified once your claim is approved.',
              style: TextStyle(color: Colors.white60, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF334155),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.store, color: Color(0xFFF59E0B), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.venue.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Pending Review',
                          style: TextStyle(
                            color: Color(0xFFF59E0B),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.pending, color: Color(0xFFF59E0B)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  // Step 3: Review & Continue to Verification
  Widget _buildStep3Review(BuildContext context, VenueOnboardingState state) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<VenueOnboardingCubit>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            l10n.venueOnboardingStep3Title,
            'Review your information before proceeding to phone verification.',
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
                _buildSummaryRow(
                    l10n.venue, widget.venue.name, Icons.store),
                const Divider(color: Colors.white12, height: 24),
                _buildSummaryRow(
                    l10n.businessName, state.claimInfo.businessName, Icons.business),
                const Divider(color: Colors.white12, height: 24),
                _buildSummaryRow(
                    l10n.yourRole, state.claimInfo.role.displayName, Icons.badge),
                const Divider(color: Colors.white12, height: 24),
                _buildSummaryRow(
                    l10n.contactEmail, state.claimInfo.contactEmail, Icons.email),
                if (state.claimInfo.contactPhone.isNotEmpty) ...[
                  const Divider(color: Colors.white12, height: 24),
                  _buildSummaryRow(
                      l10n.contactPhone, state.claimInfo.contactPhone, Icons.phone),
                ],
                const Divider(color: Colors.white12, height: 24),
                _buildSummaryRow(
                    l10n.venueTypeLabel,
                    state.claimInfo.venueType.displayName,
                    Icons.category),
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
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFFF59E0B), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Next, we\'ll verify your connection to this venue via phone.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
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
                  child: const Text(
                    'Continue to Verification',
                    style: TextStyle(
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

  // Helpers

  void _syncClaimInfo(VenueOnboardingCubit cubit) {
    final current = cubit.state.claimInfo;
    cubit.updateClaimInfo(current.copyWith(
      businessName: _businessNameController.text,
      contactEmail: _emailController.text,
      contactPhone: _phoneController.text,
    ));
  }

  Widget _buildStepHeader(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF334155),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF6B35)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      dropdownColor: const Color(0xFF334155),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF334155),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem<T>(
                value: item,
                child: Text(itemLabel(item)),
              ))
          .toList(),
    );
  }

  Widget _buildNextButton(
    BuildContext context, {
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B35),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.white12,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          l10n.next,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
