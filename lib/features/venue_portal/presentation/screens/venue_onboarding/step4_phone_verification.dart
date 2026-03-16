import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../bloc/venue_onboarding_cubit.dart';
import '../../bloc/venue_onboarding_state.dart';
import 'onboarding_form_components.dart';

/// Step 4: Phone verification with code input.
class Step4PhoneVerification extends StatefulWidget {
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
  State<Step4PhoneVerification> createState() => _Step4PhoneVerificationState();
}

class _Step4PhoneVerificationState extends State<Step4PhoneVerification> {
  bool _isCodeValid = false;
  DateTime? _lastVerifyTap;
  static const _debounceDuration = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    widget.verificationCodeController.addListener(_onCodeChanged);
    _isCodeValid = widget.verificationCodeController.text.length == 6;
  }

  @override
  void dispose() {
    widget.verificationCodeController.removeListener(_onCodeChanged);
    super.dispose();
  }

  void _onCodeChanged() {
    final valid = widget.verificationCodeController.text.length == 6;
    if (valid != _isCodeValid) {
      setState(() => _isCodeValid = valid);
    }
  }

  bool get _isDebounced {
    if (_lastVerifyTap == null) return false;
    return DateTime.now().difference(_lastVerifyTap!) < _debounceDuration;
  }

  void _onVerifyTap(VenueOnboardingCubit cubit) {
    if (_isDebounced) return;
    setState(() => _lastVerifyTap = DateTime.now());
    cubit.verifyCode(widget.placeId, widget.verificationCodeController.text);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<VenueOnboardingCubit>();
    final state = widget.state;
    final isSending = state.isSendingCode;
    final isVerifying = state.isVerifying;
    final isPending = state.isPendingVerification;
    final hasSubmitted = isPending || isSending || isVerifying;

    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepHeader(
            title: l10n.phoneVerificationTitle,
            description: l10n.phoneVerificationDesc,
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
                      Text(
                        l10n.venuePhone,
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        state.claimInfo.contactPhone.isNotEmpty
                            ? state.claimInfo.contactPhone
                            : l10n.noPhoneProvided,
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
                  cubit.claimVenue(widget.placeId, widget.venueName);
                },
                icon: const Icon(Icons.send, size: 18),
                label: Text(l10n.submitClaimAndSendCode),
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
                    : () => cubit.sendVerificationCode(widget.placeId),
                icon: isSending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.refresh, size: 18),
                label: Text(isSending ? l10n.sendingEllipsis : l10n.sendVerificationCode),
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
              controller: widget.verificationCodeController,
              label: l10n.verificationCode,
              icon: Icons.lock_outline,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.digitCounter(widget.verificationCodeController.text.length),
              style: TextStyle(
                color: _isCodeValid ? const Color(0xFF10B981) : Colors.white38,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isVerifying || !_isCodeValid || _isDebounced
                    ? null
                    : () => _onVerifyTap(cubit),
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
                    : Text(
                        l10n.verifyCode,
                        style: const TextStyle(
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
                  onPressed: state.isSubmitting || isVerifying ? null : () => cubit.previousStep(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(l10n.back),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
