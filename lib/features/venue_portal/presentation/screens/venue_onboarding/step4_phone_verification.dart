import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/venue_onboarding_cubit.dart';
import '../../bloc/venue_onboarding_state.dart';
import 'onboarding_form_components.dart';

/// Step 4: Phone verification with code input.
class Step4PhoneVerification extends StatelessWidget {
  final String placeId;
  final String venueName;
  final TextEditingController verificationCodeController;
  final VenueOnboardingState state;

  const Step4PhoneVerification({
    super.key,
    required this.placeId,
    required this.venueName,
    required this.verificationCodeController,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
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
          const StepHeader(
            title: 'Phone Verification',
            description: 'We\'ll send a verification code to the venue\'s phone number to confirm your connection to this venue.',
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
                  cubit.claimVenue(placeId, venueName);
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
                    : () => cubit.sendVerificationCode(placeId),
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
            OnboardingTextField(
              controller: verificationCodeController,
              label: 'Verification Code',
              icon: Icons.lock_outline,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isVerifying || verificationCodeController.text.length != 6
                    ? null
                    : () => cubit.verifyCode(
                          placeId,
                          verificationCodeController.text,
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
}
