import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/venue_portal/domain/entities/entities.dart';
import 'package:pregame_world_cup/features/venue_portal/presentation/bloc/venue_onboarding_state.dart';

void main() {
  final now = DateTime(2026, 6, 15, 12, 0, 0);

  group('VenueOnboardingStatus', () {
    test('has exactly 11 values', () {
      expect(VenueOnboardingStatus.values, hasLength(11));
    });

    test('contains all expected status values', () {
      expect(VenueOnboardingStatus.values,
          contains(VenueOnboardingStatus.initial));
      expect(VenueOnboardingStatus.values,
          contains(VenueOnboardingStatus.checkingAvailability));
      expect(VenueOnboardingStatus.values,
          contains(VenueOnboardingStatus.available));
      expect(VenueOnboardingStatus.values,
          contains(VenueOnboardingStatus.alreadyClaimed));
      expect(VenueOnboardingStatus.values,
          contains(VenueOnboardingStatus.submitting));
      expect(VenueOnboardingStatus.values,
          contains(VenueOnboardingStatus.pendingVerification));
      expect(VenueOnboardingStatus.values,
          contains(VenueOnboardingStatus.sendingCode));
      expect(VenueOnboardingStatus.values,
          contains(VenueOnboardingStatus.verifying));
      expect(VenueOnboardingStatus.values,
          contains(VenueOnboardingStatus.pendingReview));
      expect(VenueOnboardingStatus.values,
          contains(VenueOnboardingStatus.success));
      expect(VenueOnboardingStatus.values,
          contains(VenueOnboardingStatus.error));
    });
  });

  group('VenueOnboardingState', () {
    // =========================================================================
    // 1. Default state
    // =========================================================================
    test('default state has correct initial values', () {
      const state = VenueOnboardingState();

      expect(state.status, equals(VenueOnboardingStatus.initial));
      expect(state.currentStep, equals(0));
      expect(state.claimInfo, equals(const VenueClaimInfo()));
      expect(state.errorMessage, isNull);
      expect(state.enhancement, isNull);
    });

    // =========================================================================
    // 2. Status getters for original statuses
    // =========================================================================
    group('original status getters', () {
      test('isChecking returns true only for checkingAvailability', () {
        const state = VenueOnboardingState(
          status: VenueOnboardingStatus.checkingAvailability,
        );
        expect(state.isChecking, isTrue);
        expect(state.isAvailable, isFalse);
        expect(state.isClaimed, isFalse);
        expect(state.isSubmitting, isFalse);
      });

      test('isAvailable returns true only for available', () {
        const state = VenueOnboardingState(
          status: VenueOnboardingStatus.available,
        );
        expect(state.isAvailable, isTrue);
        expect(state.isChecking, isFalse);
      });

      test('isClaimed returns true only for alreadyClaimed', () {
        const state = VenueOnboardingState(
          status: VenueOnboardingStatus.alreadyClaimed,
        );
        expect(state.isClaimed, isTrue);
        expect(state.isAvailable, isFalse);
      });

      test('isSubmitting returns true only for submitting', () {
        const state = VenueOnboardingState(
          status: VenueOnboardingStatus.submitting,
        );
        expect(state.isSubmitting, isTrue);
        expect(state.isAvailable, isFalse);
      });

      test('isSuccess returns true only for success', () {
        const state = VenueOnboardingState(
          status: VenueOnboardingStatus.success,
        );
        expect(state.isSuccess, isTrue);
        expect(state.hasError, isFalse);
      });

      test('hasError returns true only for error', () {
        const state = VenueOnboardingState(
          status: VenueOnboardingStatus.error,
          errorMessage: 'something failed',
        );
        expect(state.hasError, isTrue);
        expect(state.isSuccess, isFalse);
      });
    });

    // =========================================================================
    // 3. New verification-flow status getters
    // =========================================================================
    group('new verification-flow status getters', () {
      test('isPendingVerification returns true only for pendingVerification',
          () {
        const state = VenueOnboardingState(
          status: VenueOnboardingStatus.pendingVerification,
        );
        expect(state.isPendingVerification, isTrue);
        expect(state.isSendingCode, isFalse);
        expect(state.isVerifying, isFalse);
        expect(state.isPendingReview, isFalse);
        expect(state.isSuccess, isFalse);
        expect(state.hasError, isFalse);
      });

      test('isSendingCode returns true only for sendingCode', () {
        const state = VenueOnboardingState(
          status: VenueOnboardingStatus.sendingCode,
        );
        expect(state.isSendingCode, isTrue);
        expect(state.isPendingVerification, isFalse);
        expect(state.isVerifying, isFalse);
        expect(state.isPendingReview, isFalse);
      });

      test('isVerifying returns true only for verifying', () {
        const state = VenueOnboardingState(
          status: VenueOnboardingStatus.verifying,
        );
        expect(state.isVerifying, isTrue);
        expect(state.isPendingVerification, isFalse);
        expect(state.isSendingCode, isFalse);
        expect(state.isPendingReview, isFalse);
      });

      test('isPendingReview returns true only for pendingReview', () {
        const state = VenueOnboardingState(
          status: VenueOnboardingStatus.pendingReview,
        );
        expect(state.isPendingReview, isTrue);
        expect(state.isPendingVerification, isFalse);
        expect(state.isSendingCode, isFalse);
        expect(state.isVerifying, isFalse);
      });
    });

    // =========================================================================
    // 4. Each getter returns false for all other statuses
    // =========================================================================
    group('each getter is exclusive', () {
      for (final status in VenueOnboardingStatus.values) {
        test('only correct getter returns true for $status', () {
          final state = VenueOnboardingState(status: status);

          expect(state.isChecking,
              equals(status == VenueOnboardingStatus.checkingAvailability));
          expect(state.isAvailable,
              equals(status == VenueOnboardingStatus.available));
          expect(state.isClaimed,
              equals(status == VenueOnboardingStatus.alreadyClaimed));
          expect(state.isSubmitting,
              equals(status == VenueOnboardingStatus.submitting));
          expect(state.isPendingVerification,
              equals(status == VenueOnboardingStatus.pendingVerification));
          expect(state.isSendingCode,
              equals(status == VenueOnboardingStatus.sendingCode));
          expect(state.isVerifying,
              equals(status == VenueOnboardingStatus.verifying));
          expect(state.isPendingReview,
              equals(status == VenueOnboardingStatus.pendingReview));
          expect(state.isSuccess,
              equals(status == VenueOnboardingStatus.success));
          expect(
              state.hasError, equals(status == VenueOnboardingStatus.error));
        });
      }
    });

    // =========================================================================
    // 5. canProceedFromStep1 and canProceedFromStep2
    // =========================================================================
    group('step validation getters', () {
      test('canProceedFromStep1 delegates to claimInfo.isStep1Valid', () {
        const stateValid = VenueOnboardingState(
          claimInfo: VenueClaimInfo(
            businessName: 'My Bar',
            contactEmail: 'test@example.com',
          ),
        );
        const stateInvalid = VenueOnboardingState(
          claimInfo: VenueClaimInfo(
            businessName: '',
            contactEmail: '',
          ),
        );

        expect(stateValid.canProceedFromStep1, isTrue);
        expect(stateInvalid.canProceedFromStep1, isFalse);
      });

      test('canProceedFromStep2 delegates to claimInfo.isStep2Valid', () {
        const stateValid = VenueOnboardingState(
          claimInfo: VenueClaimInfo(authorizedConfirmed: true),
        );
        const stateInvalid = VenueOnboardingState(
          claimInfo: VenueClaimInfo(authorizedConfirmed: false),
        );

        expect(stateValid.canProceedFromStep2, isTrue);
        expect(stateInvalid.canProceedFromStep2, isFalse);
      });
    });

    // =========================================================================
    // 6. copyWith
    // =========================================================================
    group('copyWith', () {
      test('copies status', () {
        const original = VenueOnboardingState(
          status: VenueOnboardingStatus.initial,
        );
        final copy = original.copyWith(
          status: VenueOnboardingStatus.pendingVerification,
        );

        expect(
            copy.status, equals(VenueOnboardingStatus.pendingVerification));
      });

      test('copies currentStep', () {
        const original = VenueOnboardingState(currentStep: 0);
        final copy = original.copyWith(currentStep: 2);

        expect(copy.currentStep, equals(2));
      });

      test('copies claimInfo', () {
        const original = VenueOnboardingState();
        final copy = original.copyWith(
          claimInfo: const VenueClaimInfo(businessName: 'Test Bar'),
        );

        expect(copy.claimInfo.businessName, equals('Test Bar'));
      });

      test('copies errorMessage', () {
        const original = VenueOnboardingState();
        final copy = original.copyWith(errorMessage: 'Something went wrong');

        expect(copy.errorMessage, equals('Something went wrong'));
      });

      test('copies enhancement', () {
        const original = VenueOnboardingState();
        final enhancement = VenueEnhancement(
          venueId: 'venue_1',
          ownerId: 'owner_1',
          createdAt: now,
          updatedAt: now,
        );
        final copy = original.copyWith(enhancement: enhancement);

        expect(copy.enhancement, equals(enhancement));
      });

      test('clearError removes errorMessage', () {
        const original = VenueOnboardingState(
          errorMessage: 'Old error',
        );
        final copy = original.copyWith(clearError: true);

        expect(copy.errorMessage, isNull);
      });

      test('clearError takes precedence over errorMessage', () {
        const original = VenueOnboardingState(
          errorMessage: 'Old error',
        );
        final copy = original.copyWith(
          errorMessage: 'New error',
          clearError: true,
        );

        expect(copy.errorMessage, isNull);
      });

      test('preserves existing fields when not specified', () {
        final enhancement = VenueEnhancement(
          venueId: 'venue_1',
          ownerId: 'owner_1',
          createdAt: now,
          updatedAt: now,
        );
        final original = VenueOnboardingState(
          status: VenueOnboardingStatus.pendingVerification,
          currentStep: 2,
          claimInfo: const VenueClaimInfo(businessName: 'Test'),
          errorMessage: 'error',
          enhancement: enhancement,
        );
        final copy = original.copyWith();

        expect(copy.status, equals(original.status));
        expect(copy.currentStep, equals(original.currentStep));
        expect(copy.claimInfo, equals(original.claimInfo));
        expect(copy.errorMessage, equals(original.errorMessage));
        expect(copy.enhancement, equals(original.enhancement));
      });
    });

    // =========================================================================
    // 7. Equatable
    // =========================================================================
    group('Equatable', () {
      test('two states with same values are equal', () {
        const a = VenueOnboardingState(
          status: VenueOnboardingStatus.pendingVerification,
          currentStep: 1,
        );
        const b = VenueOnboardingState(
          status: VenueOnboardingStatus.pendingVerification,
          currentStep: 1,
        );

        expect(a, equals(b));
      });

      test('two states with different status are not equal', () {
        const a = VenueOnboardingState(
          status: VenueOnboardingStatus.pendingVerification,
        );
        const b = VenueOnboardingState(
          status: VenueOnboardingStatus.verifying,
        );

        expect(a, isNot(equals(b)));
      });

      test('props includes all fields', () {
        const state = VenueOnboardingState();
        expect(state.props, hasLength(5));
      });
    });
  });
}
