import '../../../../../config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../l10n/app_localizations.dart';

import '../../../../recommendations/domain/entities/place.dart';
import '../../bloc/venue_onboarding_cubit.dart';
import '../../bloc/venue_onboarding_state.dart';
import '../../../../../injection_container.dart';
import 'already_claimed_view.dart';
import 'pending_review_view.dart';
import 'step1_business_info.dart';
import 'step2_venue_confirmation.dart';
import 'step3_review.dart';
import 'step4_phone_verification.dart';

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
                    AppTheme.primaryOrange,
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
        child: CircularProgressIndicator(color: AppTheme.primaryOrange),
      );
    }

    if (state.isClaimed) {
      return const AlreadyClaimedView();
    }

    if (state.isPendingReview) {
      return PendingReviewView(venueName: widget.venue.name);
    }

    return switch (state.currentStep) {
      0 => Step1BusinessInfo(
          formKey: _formKey,
          businessNameController: _businessNameController,
          emailController: _emailController,
          phoneController: _phoneController,
          state: state,
          syncClaimInfo: _syncClaimInfo,
        ),
      1 => Step2VenueConfirmation(venue: widget.venue, state: state),
      2 => Step3Review(venueName: widget.venue.name, state: state),
      3 => Step4PhoneVerification(
          placeId: widget.venue.placeId,
          venueName: widget.venue.name,
          verificationCodeController: _verificationCodeController,
          state: state,
        ),
      _ => Step1BusinessInfo(
          formKey: _formKey,
          businessNameController: _businessNameController,
          emailController: _emailController,
          phoneController: _phoneController,
          state: state,
          syncClaimInfo: _syncClaimInfo,
        ),
    };
  }

  void _syncClaimInfo(VenueOnboardingCubit cubit) {
    final current = cubit.state.claimInfo;
    cubit.updateClaimInfo(current.copyWith(
      businessName: _businessNameController.text,
      contactEmail: _emailController.text,
      contactPhone: _phoneController.text,
    ));
  }
}
