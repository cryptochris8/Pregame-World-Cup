import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../recommendations/domain/entities/place.dart';
import '../../domain/entities/entities.dart';
import '../bloc/venue_enhancement_cubit.dart';
import '../bloc/venue_onboarding_cubit.dart';
import '../bloc/venue_onboarding_state.dart';
import 'venue_portal_home_screen.dart';
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

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _businessNameController = TextEditingController(text: widget.venue.name);
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
          if (state.isSuccess && state.enhancement != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => sl<VenueEnhancementCubit>()
                    ..loadEnhancement(
                      widget.venue.placeId,
                      venueName: widget.venue.name,
                    ),
                  child: VenuePortalHomeScreen(
                    venueId: widget.venue.placeId,
                    venueName: widget.venue.name,
                  ),
                ),
              ),
            );
          }
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
                  value: (state.currentStep + 1) / 3,
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

    switch (state.currentStep) {
      case 0:
        return _buildStep1(context, state);
      case 1:
        return _buildStep2(context, state);
      case 2:
        return _buildStep3(context, state);
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

  // Step 3: Review & Claim
  Widget _buildStep3(BuildContext context, VenueOnboardingState state) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<VenueOnboardingCubit>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            l10n.venueOnboardingStep3Title,
            l10n.venueOnboardingStep3Desc,
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
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed:
                      state.isSubmitting ? null : () => cubit.previousStep(),
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
                  onPressed: state.isSubmitting
                      ? null
                      : () => cubit.claimVenue(
                            widget.venue.placeId,
                            widget.venue.name,
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: state.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.claimThisVenue,
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
