import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/venue_portal/domain/entities/entities.dart';
import 'package:pregame_world_cup/features/venue_portal/domain/services/venue_enhancement_service.dart';
import 'package:pregame_world_cup/features/venue_portal/presentation/bloc/venue_onboarding_cubit.dart';
import 'package:pregame_world_cup/features/venue_portal/presentation/bloc/venue_onboarding_state.dart';

class MockVenueEnhancementService extends Mock
    implements VenueEnhancementService {}

void main() {
  late MockVenueEnhancementService mockService;
  late VenueOnboardingCubit cubit;

  final now = DateTime(2026, 6, 15, 12, 0, 0);

  VenueEnhancement createEnhancement({
    String venueId = 'venue_1',
    String ownerId = 'owner_1',
    VenueClaimStatus claimStatus = VenueClaimStatus.pendingVerification,
    String? venuePhoneNumber = '+15551234567',
  }) {
    return VenueEnhancement(
      venueId: venueId,
      ownerId: ownerId,
      claimStatus: claimStatus,
      venuePhoneNumber: venuePhoneNumber,
      createdAt: now,
      updatedAt: now,
    );
  }

  setUp(() {
    mockService = MockVenueEnhancementService();
    cubit = VenueOnboardingCubit(service: mockService);
  });

  tearDown(() {
    cubit.close();
  });

  group('VenueOnboardingCubit', () {
    // =========================================================================
    // 1. Initial state
    // =========================================================================
    test('initial state is correct', () {
      expect(cubit.state, equals(const VenueOnboardingState()));
      expect(cubit.state.status, equals(VenueOnboardingStatus.initial));
      expect(cubit.state.currentStep, equals(0));
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.enhancement, isNull);
    });

    // =========================================================================
    // 2. checkVenueAvailability - venue available
    // =========================================================================
    blocTest<VenueOnboardingCubit, VenueOnboardingState>(
      'checkVenueAvailability emits available when venue is not claimed',
      build: () {
        when(() => mockService.isVenueClaimed('venue_1'))
            .thenAnswer((_) async => false);
        return cubit;
      },
      act: (cubit) => cubit.checkVenueAvailability('venue_1'),
      expect: () => [
        isA<VenueOnboardingState>()
            .having((s) => s.status, 'status',
                VenueOnboardingStatus.checkingAvailability)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        isA<VenueOnboardingState>().having(
            (s) => s.status, 'status', VenueOnboardingStatus.available),
      ],
      verify: (_) {
        verify(() => mockService.isVenueClaimed('venue_1')).called(1);
      },
    );

    // =========================================================================
    // 3. checkVenueAvailability - already claimed
    // =========================================================================
    blocTest<VenueOnboardingCubit, VenueOnboardingState>(
      'checkVenueAvailability emits alreadyClaimed when venue is claimed',
      build: () {
        when(() => mockService.isVenueClaimed('venue_1'))
            .thenAnswer((_) async => true);
        return cubit;
      },
      act: (cubit) => cubit.checkVenueAvailability('venue_1'),
      expect: () => [
        isA<VenueOnboardingState>().having((s) => s.status, 'status',
            VenueOnboardingStatus.checkingAvailability),
        isA<VenueOnboardingState>().having(
            (s) => s.status, 'status', VenueOnboardingStatus.alreadyClaimed),
      ],
    );

    // =========================================================================
    // 4. checkVenueAvailability - error
    // =========================================================================
    blocTest<VenueOnboardingCubit, VenueOnboardingState>(
      'checkVenueAvailability emits error on exception',
      build: () {
        when(() => mockService.isVenueClaimed('venue_1'))
            .thenThrow(Exception('Network error'));
        return cubit;
      },
      act: (cubit) => cubit.checkVenueAvailability('venue_1'),
      expect: () => [
        isA<VenueOnboardingState>().having((s) => s.status, 'status',
            VenueOnboardingStatus.checkingAvailability),
        isA<VenueOnboardingState>()
            .having(
                (s) => s.status, 'status', VenueOnboardingStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull)
            .having((s) => s.errorMessage, 'errorMessage',
                contains('Failed to check venue availability')),
      ],
    );

    // =========================================================================
    // 5. updateClaimInfo
    // =========================================================================
    blocTest<VenueOnboardingCubit, VenueOnboardingState>(
      'updateClaimInfo emits state with new claimInfo',
      build: () => cubit,
      act: (cubit) => cubit.updateClaimInfo(
        const VenueClaimInfo(
          businessName: 'My Sports Bar',
          contactEmail: 'owner@bar.com',
          contactPhone: '+15559999999',
          role: VenueOwnerRole.owner,
          venueType: VenueType.sportsBar,
        ),
      ),
      expect: () => [
        isA<VenueOnboardingState>()
            .having((s) => s.claimInfo.businessName, 'businessName',
                'My Sports Bar')
            .having((s) => s.claimInfo.contactEmail, 'contactEmail',
                'owner@bar.com')
            .having((s) => s.claimInfo.contactPhone, 'contactPhone',
                '+15559999999')
            .having((s) => s.claimInfo.role, 'role', VenueOwnerRole.owner)
            .having((s) => s.claimInfo.venueType, 'venueType',
                VenueType.sportsBar),
      ],
    );

    // =========================================================================
    // 6. nextStep / previousStep
    // =========================================================================
    blocTest<VenueOnboardingCubit, VenueOnboardingState>(
      'nextStep increments currentStep',
      build: () => cubit,
      act: (cubit) {
        cubit.nextStep();
        cubit.nextStep();
      },
      expect: () => [
        isA<VenueOnboardingState>()
            .having((s) => s.currentStep, 'currentStep', 1),
        isA<VenueOnboardingState>()
            .having((s) => s.currentStep, 'currentStep', 2),
      ],
    );

    blocTest<VenueOnboardingCubit, VenueOnboardingState>(
      'nextStep does not exceed step 3',
      build: () => cubit,
      seed: () => const VenueOnboardingState(currentStep: 3),
      act: (cubit) => cubit.nextStep(),
      expect: () => [],
    );

    blocTest<VenueOnboardingCubit, VenueOnboardingState>(
      'previousStep decrements currentStep',
      build: () => cubit,
      seed: () => const VenueOnboardingState(currentStep: 2),
      act: (cubit) => cubit.previousStep(),
      expect: () => [
        isA<VenueOnboardingState>()
            .having((s) => s.currentStep, 'currentStep', 1),
      ],
    );

    blocTest<VenueOnboardingCubit, VenueOnboardingState>(
      'previousStep does not go below 0',
      build: () => cubit,
      seed: () => const VenueOnboardingState(currentStep: 0),
      act: (cubit) => cubit.previousStep(),
      expect: () => [],
    );

    // =========================================================================
    // 7. claimVenue - success -> pendingVerification
    // =========================================================================
    blocTest<VenueOnboardingCubit, VenueOnboardingState>(
      'claimVenue emits submitting then pendingVerification on success',
      build: () {
        final enhancement = createEnhancement();
        when(() => mockService.claimVenue(
              venueId: 'venue_1',
              venueName: 'Test Bar',
              businessName: 'My Bar',
              contactEmail: 'owner@bar.com',
              contactPhone: '+15551234567',
              ownerRole: 'owner',
              venueType: 'sportsBar',
              venuePhoneNumber: '+15551234567',
            )).thenAnswer((_) async => enhancement);
        return cubit;
      },
      seed: () => const VenueOnboardingState(
        claimInfo: VenueClaimInfo(
          businessName: 'My Bar',
          contactEmail: 'owner@bar.com',
          contactPhone: '+15551234567',
          role: VenueOwnerRole.owner,
          venueType: VenueType.sportsBar,
        ),
      ),
      act: (cubit) => cubit.claimVenue('venue_1', 'Test Bar'),
      expect: () => [
        // First: submitting
        isA<VenueOnboardingState>()
            .having((s) => s.status, 'status',
                VenueOnboardingStatus.submitting)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        // Second: pendingVerification with enhancement
        isA<VenueOnboardingState>()
            .having((s) => s.status, 'status',
                VenueOnboardingStatus.pendingVerification)
            .having((s) => s.enhancement, 'enhancement', isNotNull)
            .having((s) => s.enhancement!.venueId, 'venueId', 'venue_1'),
      ],
    );

    // =========================================================================
    // 8. claimVenue - returns null (already claimed)
    // =========================================================================
    blocTest<VenueOnboardingCubit, VenueOnboardingState>(
      'claimVenue emits error when service returns null',
      build: () {
        when(() => mockService.claimVenue(
              venueId: any(named: 'venueId'),
              venueName: any(named: 'venueName'),
              businessName: any(named: 'businessName'),
              contactEmail: any(named: 'contactEmail'),
              contactPhone: any(named: 'contactPhone'),
              ownerRole: any(named: 'ownerRole'),
              venueType: any(named: 'venueType'),
              venuePhoneNumber: any(named: 'venuePhoneNumber'),
            )).thenAnswer((_) async => null);
        return cubit;
      },
      seed: () => const VenueOnboardingState(
        claimInfo: VenueClaimInfo(
          businessName: 'My Bar',
          contactEmail: 'owner@bar.com',
          contactPhone: '+15551234567',
        ),
      ),
      act: (cubit) => cubit.claimVenue('venue_1', 'Test Bar'),
      expect: () => [
        isA<VenueOnboardingState>().having(
            (s) => s.status, 'status', VenueOnboardingStatus.submitting),
        isA<VenueOnboardingState>()
            .having(
                (s) => s.status, 'status', VenueOnboardingStatus.error)
            .having((s) => s.errorMessage, 'errorMessage',
                contains('Failed to claim venue')),
      ],
    );

    // =========================================================================
    // 9. claimVenue - exception
    // =========================================================================
    blocTest<VenueOnboardingCubit, VenueOnboardingState>(
      'claimVenue emits error on exception',
      build: () {
        when(() => mockService.claimVenue(
              venueId: any(named: 'venueId'),
              venueName: any(named: 'venueName'),
              businessName: any(named: 'businessName'),
              contactEmail: any(named: 'contactEmail'),
              contactPhone: any(named: 'contactPhone'),
              ownerRole: any(named: 'ownerRole'),
              venueType: any(named: 'venueType'),
              venuePhoneNumber: any(named: 'venuePhoneNumber'),
            )).thenThrow(Exception('Cloud Function failed'));
        return cubit;
      },
      seed: () => const VenueOnboardingState(
        claimInfo: VenueClaimInfo(
          businessName: 'My Bar',
          contactEmail: 'owner@bar.com',
          contactPhone: '+15551234567',
        ),
      ),
      act: (cubit) => cubit.claimVenue('venue_1', 'Test Bar'),
      expect: () => [
        isA<VenueOnboardingState>().having(
            (s) => s.status, 'status', VenueOnboardingStatus.submitting),
        isA<VenueOnboardingState>()
            .having(
                (s) => s.status, 'status', VenueOnboardingStatus.error)
            .having((s) => s.errorMessage, 'errorMessage',
                contains('Error claiming venue')),
      ],
    );

    // =========================================================================
    // 10. sendVerificationCode - success
    // =========================================================================
    blocTest<VenueOnboardingCubit, VenueOnboardingState>(
      'sendVerificationCode emits sendingCode then pendingVerification on success',
      build: () {
        when(() => mockService.sendVerificationCode('venue_1'))
            .thenAnswer((_) async => true);
        return cubit;
      },
      act: (cubit) => cubit.sendVerificationCode('venue_1'),
      expect: () => [
        // First: sendingCode
        isA<VenueOnboardingState>()
            .having((s) => s.status, 'status',
                VenueOnboardingStatus.sendingCode)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        // Second: back to pendingVerification
        isA<VenueOnboardingState>().having((s) => s.status, 'status',
            VenueOnboardingStatus.pendingVerification),
      ],
      verify: (_) {
        verify(() => mockService.sendVerificationCode('venue_1')).called(1);
      },
    );

    // =========================================================================
    // 11. sendVerificationCode - service returns false
    // =========================================================================
    blocTest<VenueOnboardingCubit, VenueOnboardingState>(
      'sendVerificationCode emits error when service returns false',
      build: () {
        when(() => mockService.sendVerificationCode('venue_1'))
            .thenAnswer((_) async => false);
        return cubit;
      },
      act: (cubit) => cubit.sendVerificationCode('venue_1'),
      expect: () => [
        isA<VenueOnboardingState>().having(
            (s) => s.status, 'status', VenueOnboardingStatus.sendingCode),
        isA<VenueOnboardingState>()
            .having(
                (s) => s.status, 'status', VenueOnboardingStatus.error)
            .having((s) => s.errorMessage, 'errorMessage',
                contains('Failed to send verification code')),
      ],
    );

    // =========================================================================
    // 12. sendVerificationCode - exception
    // =========================================================================
    blocTest<VenueOnboardingCubit, VenueOnboardingState>(
      'sendVerificationCode emits error on exception',
      build: () {
        when(() => mockService.sendVerificationCode('venue_1'))
            .thenThrow(Exception('SMS service down'));
        return cubit;
      },
      act: (cubit) => cubit.sendVerificationCode('venue_1'),
      expect: () => [
        isA<VenueOnboardingState>().having(
            (s) => s.status, 'status', VenueOnboardingStatus.sendingCode),
        isA<VenueOnboardingState>()
            .having(
                (s) => s.status, 'status', VenueOnboardingStatus.error)
            .having((s) => s.errorMessage, 'errorMessage',
                contains('Error sending code')),
      ],
    );

    // =========================================================================
    // 13. verifyCode - success -> pendingReview
    // =========================================================================
    blocTest<VenueOnboardingCubit, VenueOnboardingState>(
      'verifyCode emits verifying then pendingReview on success',
      build: () {
        when(() => mockService.verifyCode('venue_1', '123456'))
            .thenAnswer((_) async => true);
        return cubit;
      },
      act: (cubit) => cubit.verifyCode('venue_1', '123456'),
      expect: () => [
        // First: verifying
        isA<VenueOnboardingState>()
            .having((s) => s.status, 'status',
                VenueOnboardingStatus.verifying)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        // Second: pendingReview
        isA<VenueOnboardingState>().having(
            (s) => s.status, 'status', VenueOnboardingStatus.pendingReview),
      ],
      verify: (_) {
        verify(() => mockService.verifyCode('venue_1', '123456')).called(1);
      },
    );

    // =========================================================================
    // 14. verifyCode - wrong code (service returns false)
    // =========================================================================
    blocTest<VenueOnboardingCubit, VenueOnboardingState>(
      'verifyCode emits error when verification fails',
      build: () {
        when(() => mockService.verifyCode('venue_1', '000000'))
            .thenAnswer((_) async => false);
        return cubit;
      },
      act: (cubit) => cubit.verifyCode('venue_1', '000000'),
      expect: () => [
        isA<VenueOnboardingState>().having(
            (s) => s.status, 'status', VenueOnboardingStatus.verifying),
        isA<VenueOnboardingState>()
            .having(
                (s) => s.status, 'status', VenueOnboardingStatus.error)
            .having((s) => s.errorMessage, 'errorMessage',
                contains('Verification failed')),
      ],
    );

    // =========================================================================
    // 15. verifyCode - exception
    // =========================================================================
    blocTest<VenueOnboardingCubit, VenueOnboardingState>(
      'verifyCode emits error on exception',
      build: () {
        when(() => mockService.verifyCode('venue_1', '123456'))
            .thenThrow(Exception('Server error'));
        return cubit;
      },
      act: (cubit) => cubit.verifyCode('venue_1', '123456'),
      expect: () => [
        isA<VenueOnboardingState>().having(
            (s) => s.status, 'status', VenueOnboardingStatus.verifying),
        isA<VenueOnboardingState>()
            .having(
                (s) => s.status, 'status', VenueOnboardingStatus.error)
            .having((s) => s.errorMessage, 'errorMessage',
                contains('Error verifying code')),
      ],
    );

    // =========================================================================
    // 16. Full claiming flow: claim -> sendCode -> verify
    // =========================================================================
    blocTest<VenueOnboardingCubit, VenueOnboardingState>(
      'full claiming flow: claimVenue -> sendVerificationCode -> verifyCode',
      build: () {
        final enhancement = createEnhancement();
        when(() => mockService.claimVenue(
              venueId: any(named: 'venueId'),
              venueName: any(named: 'venueName'),
              businessName: any(named: 'businessName'),
              contactEmail: any(named: 'contactEmail'),
              contactPhone: any(named: 'contactPhone'),
              ownerRole: any(named: 'ownerRole'),
              venueType: any(named: 'venueType'),
              venuePhoneNumber: any(named: 'venuePhoneNumber'),
            )).thenAnswer((_) async => enhancement);
        when(() => mockService.sendVerificationCode('venue_1'))
            .thenAnswer((_) async => true);
        when(() => mockService.verifyCode('venue_1', '123456'))
            .thenAnswer((_) async => true);
        return cubit;
      },
      seed: () => const VenueOnboardingState(
        claimInfo: VenueClaimInfo(
          businessName: 'My Bar',
          contactEmail: 'owner@bar.com',
          contactPhone: '+15551234567',
        ),
      ),
      act: (cubit) async {
        await cubit.claimVenue('venue_1', 'Test Bar');
        await cubit.sendVerificationCode('venue_1');
        await cubit.verifyCode('venue_1', '123456');
      },
      expect: () => [
        // claimVenue: submitting
        isA<VenueOnboardingState>().having(
            (s) => s.status, 'status', VenueOnboardingStatus.submitting),
        // claimVenue: pendingVerification
        isA<VenueOnboardingState>().having((s) => s.status, 'status',
            VenueOnboardingStatus.pendingVerification),
        // sendVerificationCode: sendingCode
        isA<VenueOnboardingState>().having(
            (s) => s.status, 'status', VenueOnboardingStatus.sendingCode),
        // sendVerificationCode: pendingVerification
        isA<VenueOnboardingState>().having((s) => s.status, 'status',
            VenueOnboardingStatus.pendingVerification),
        // verifyCode: verifying
        isA<VenueOnboardingState>().having(
            (s) => s.status, 'status', VenueOnboardingStatus.verifying),
        // verifyCode: pendingReview
        isA<VenueOnboardingState>().having(
            (s) => s.status, 'status', VenueOnboardingStatus.pendingReview),
      ],
    );

    // =========================================================================
    // 17. Error clears on subsequent action
    // =========================================================================
    blocTest<VenueOnboardingCubit, VenueOnboardingState>(
      'sendVerificationCode clears previous error before proceeding',
      build: () {
        when(() => mockService.sendVerificationCode('venue_1'))
            .thenAnswer((_) async => true);
        return cubit;
      },
      seed: () => const VenueOnboardingState(
        status: VenueOnboardingStatus.error,
        errorMessage: 'Previous error',
      ),
      act: (cubit) => cubit.sendVerificationCode('venue_1'),
      expect: () => [
        // Error is cleared
        isA<VenueOnboardingState>()
            .having((s) => s.status, 'status',
                VenueOnboardingStatus.sendingCode)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        isA<VenueOnboardingState>().having((s) => s.status, 'status',
            VenueOnboardingStatus.pendingVerification),
      ],
    );

    blocTest<VenueOnboardingCubit, VenueOnboardingState>(
      'verifyCode clears previous error before proceeding',
      build: () {
        when(() => mockService.verifyCode('venue_1', '123456'))
            .thenAnswer((_) async => true);
        return cubit;
      },
      seed: () => const VenueOnboardingState(
        status: VenueOnboardingStatus.error,
        errorMessage: 'Previous verification error',
      ),
      act: (cubit) => cubit.verifyCode('venue_1', '123456'),
      expect: () => [
        isA<VenueOnboardingState>()
            .having((s) => s.status, 'status',
                VenueOnboardingStatus.verifying)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        isA<VenueOnboardingState>().having(
            (s) => s.status, 'status', VenueOnboardingStatus.pendingReview),
      ],
    );

    // =========================================================================
    // 18. claimVenue clears error on start
    // =========================================================================
    blocTest<VenueOnboardingCubit, VenueOnboardingState>(
      'claimVenue clears previous error before proceeding',
      build: () {
        when(() => mockService.claimVenue(
              venueId: any(named: 'venueId'),
              venueName: any(named: 'venueName'),
              businessName: any(named: 'businessName'),
              contactEmail: any(named: 'contactEmail'),
              contactPhone: any(named: 'contactPhone'),
              ownerRole: any(named: 'ownerRole'),
              venueType: any(named: 'venueType'),
              venuePhoneNumber: any(named: 'venuePhoneNumber'),
            )).thenAnswer((_) async => createEnhancement());
        return cubit;
      },
      seed: () => const VenueOnboardingState(
        status: VenueOnboardingStatus.error,
        errorMessage: 'Previous error',
        claimInfo: VenueClaimInfo(
          businessName: 'Bar',
          contactEmail: 'x@y.com',
          contactPhone: '+15551234567',
        ),
      ),
      act: (cubit) => cubit.claimVenue('venue_1', 'Test Bar'),
      expect: () => [
        isA<VenueOnboardingState>()
            .having((s) => s.status, 'status',
                VenueOnboardingStatus.submitting)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        isA<VenueOnboardingState>().having((s) => s.status, 'status',
            VenueOnboardingStatus.pendingVerification),
      ],
    );
  });
}
