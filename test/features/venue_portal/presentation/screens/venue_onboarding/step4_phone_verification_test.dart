import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/venue_portal/domain/entities/entities.dart';
import 'package:pregame_world_cup/features/venue_portal/presentation/bloc/venue_onboarding_cubit.dart';
import 'package:pregame_world_cup/features/venue_portal/presentation/bloc/venue_onboarding_state.dart';
import 'package:pregame_world_cup/features/venue_portal/presentation/screens/venue_onboarding/step4_phone_verification.dart';
import 'package:pregame_world_cup/l10n/app_localizations.dart';

class MockVenueOnboardingCubit extends MockCubit<VenueOnboardingState>
    implements VenueOnboardingCubit {}

void main() {
  late MockVenueOnboardingCubit mockCubit;
  late TextEditingController codeController;

  setUp(() {
    mockCubit = MockVenueOnboardingCubit();
    codeController = TextEditingController();
  });

  tearDown(() {
    codeController.dispose();
  });

  Widget buildTestWidget({
    required VenueOnboardingState state,
    String placeId = 'place_1',
    String venueName = 'Test Venue',
  }) {
    when(() => mockCubit.state).thenReturn(state);
    whenListen(mockCubit, Stream<VenueOnboardingState>.empty(),
        initialState: state);

    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: BlocProvider<VenueOnboardingCubit>.value(
          value: mockCubit,
          child: Step4PhoneVerification(
            placeId: placeId,
            venueName: venueName,
            verificationCodeController: codeController,
            state: state,
          ),
        ),
      ),
    );
  }

  group('Step4PhoneVerification - Structure', () {
    testWidgets('renders step header with Phone Verification title',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        state: const VenueOnboardingState(
          status: VenueOnboardingStatus.initial,
        ),
      ));

      expect(find.text('Phone Verification'), findsOneWidget);
    });

    testWidgets('renders venue phone display section', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        state: const VenueOnboardingState(
          status: VenueOnboardingStatus.initial,
          claimInfo: VenueClaimInfo(contactPhone: '+15551234567'),
        ),
      ));

      expect(find.text('Venue Phone'), findsOneWidget);
      expect(find.text('+15551234567'), findsOneWidget);
    });

    testWidgets('shows "No phone number provided" when phone is empty',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        state: const VenueOnboardingState(
          status: VenueOnboardingStatus.initial,
          claimInfo: VenueClaimInfo(contactPhone: ''),
        ),
      ));

      expect(find.text('No phone number provided'), findsOneWidget);
    });

    testWidgets('renders Back button', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        state: const VenueOnboardingState(
          status: VenueOnboardingStatus.initial,
        ),
      ));

      expect(find.text('Back'), findsOneWidget);
    });
  });

  group('Step4PhoneVerification - Initial state (before claim)', () {
    testWidgets('shows Submit Claim & Send Code button initially',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        state: const VenueOnboardingState(
          status: VenueOnboardingStatus.initial,
        ),
      ));

      expect(find.text('Submit Claim & Send Code'), findsOneWidget);
    });

    testWidgets('tapping Submit calls cubit.claimVenue', (tester) async {
      when(() => mockCubit.claimVenue(any(), any()))
          .thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget(
        state: const VenueOnboardingState(
          status: VenueOnboardingStatus.initial,
        ),
      ));

      await tester.tap(find.text('Submit Claim & Send Code'));
      await tester.pump();

      verify(() => mockCubit.claimVenue('place_1', 'Test Venue')).called(1);
    });
  });

  group('Step4PhoneVerification - Pending verification state', () {
    testWidgets('shows Send Verification Code button', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        state: const VenueOnboardingState(
          status: VenueOnboardingStatus.pendingVerification,
        ),
      ));

      expect(find.text('Send Verification Code'), findsOneWidget);
    });

    testWidgets('shows verification code input field', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        state: const VenueOnboardingState(
          status: VenueOnboardingStatus.pendingVerification,
        ),
      ));

      expect(find.text('Verification Code'), findsOneWidget);
    });

    testWidgets('shows digit counter', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        state: const VenueOnboardingState(
          status: VenueOnboardingStatus.pendingVerification,
        ),
      ));

      expect(find.text('0/6 digits'), findsOneWidget);
    });

    testWidgets('shows Verify Code button', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        state: const VenueOnboardingState(
          status: VenueOnboardingStatus.pendingVerification,
        ),
      ));

      expect(find.text('Verify Code'), findsOneWidget);
    });

    testWidgets('Verify Code button is disabled when code is incomplete',
        (tester) async {
      codeController.text = '123'; // only 3 digits

      await tester.pumpWidget(buildTestWidget(
        state: const VenueOnboardingState(
          status: VenueOnboardingStatus.pendingVerification,
        ),
      ));
      await tester.pump();

      // Find the Verify Code ElevatedButton
      final verifyButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Verify Code'),
      );
      expect(verifyButton.onPressed, isNull);
    });

    testWidgets('tapping Send Code calls cubit.sendVerificationCode',
        (tester) async {
      when(() => mockCubit.sendVerificationCode(any()))
          .thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget(
        state: const VenueOnboardingState(
          status: VenueOnboardingStatus.pendingVerification,
        ),
      ));

      await tester.tap(find.text('Send Verification Code'));
      await tester.pump();

      verify(() => mockCubit.sendVerificationCode('place_1')).called(1);
    });
  });

  group('Step4PhoneVerification - Sending code state', () {
    // Note: sendingCode is a transient state where isPendingVerification=false,
    // so the code input section (including Sending... label) is not rendered.
    // The submit button is also hidden (hasSubmitted=true).
    testWidgets('hides submit button during sendingCode', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        state: const VenueOnboardingState(
          status: VenueOnboardingStatus.sendingCode,
        ),
      ));

      expect(find.text('Submit Claim & Send Code'), findsNothing);
    });

    testWidgets('still renders Back button during sendingCode', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        state: const VenueOnboardingState(
          status: VenueOnboardingStatus.sendingCode,
        ),
      ));

      expect(find.text('Back'), findsOneWidget);
    });
  });

  group('Step4PhoneVerification - Verifying state', () {
    // Note: verifying is a transient state where isPendingVerification=false,
    // so the code input section is not rendered. Back button is disabled.
    testWidgets('hides submit button during verifying', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        state: const VenueOnboardingState(
          status: VenueOnboardingStatus.verifying,
        ),
      ));

      expect(find.text('Submit Claim & Send Code'), findsNothing);
    });

    testWidgets('Back button is disabled while verifying', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        state: const VenueOnboardingState(
          status: VenueOnboardingStatus.verifying,
        ),
      ));

      final backButton = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Back'),
      );
      expect(backButton.onPressed, isNull);
    });
  });

  group('Step4PhoneVerification - Submitting state', () {
    testWidgets('shows loading indicator while submitting claim',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        state: const VenueOnboardingState(
          status: VenueOnboardingStatus.submitting,
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('Back button is disabled while submitting', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        state: const VenueOnboardingState(
          status: VenueOnboardingStatus.submitting,
        ),
      ));

      final backButton = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Back'),
      );
      expect(backButton.onPressed, isNull);
    });
  });

  group('Step4PhoneVerification - Code validation', () {
    testWidgets('digit counter shows 0/6 initially', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        state: const VenueOnboardingState(
          status: VenueOnboardingStatus.pendingVerification,
        ),
      ));

      expect(find.text('0/6 digits'), findsOneWidget);
    });

    testWidgets('digit counter updates when code reaches 6 digits',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        state: const VenueOnboardingState(
          status: VenueOnboardingStatus.pendingVerification,
        ),
      ));

      expect(find.text('0/6 digits'), findsOneWidget);

      // Enter 6 digits - this changes _isCodeValid triggering setState
      codeController.text = '123456';
      await tester.pump();

      expect(find.text('6/6 digits'), findsOneWidget);
    });

    testWidgets('6-digit code enables Verify Code button', (tester) async {
      codeController.text = '123456';

      await tester.pumpWidget(buildTestWidget(
        state: const VenueOnboardingState(
          status: VenueOnboardingStatus.pendingVerification,
        ),
      ));
      await tester.pump();

      final verifyButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Verify Code'),
      );
      expect(verifyButton.onPressed, isNotNull);
    });
  });

  group('Step4PhoneVerification - Debounce', () {
    testWidgets('verify button calls cubit.verifyCode on first tap',
        (tester) async {
      codeController.text = '123456';
      when(() => mockCubit.verifyCode(any(), any()))
          .thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget(
        state: const VenueOnboardingState(
          status: VenueOnboardingStatus.pendingVerification,
        ),
      ));
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Verify Code'));
      await tester.pump();

      verify(() => mockCubit.verifyCode('place_1', '123456')).called(1);
    });

    testWidgets('second tap within 3 seconds is debounced', (tester) async {
      codeController.text = '123456';
      when(() => mockCubit.verifyCode(any(), any()))
          .thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget(
        state: const VenueOnboardingState(
          status: VenueOnboardingStatus.pendingVerification,
        ),
      ));
      await tester.pump();

      // First tap
      await tester.tap(find.widgetWithText(ElevatedButton, 'Verify Code'));
      await tester.pump();

      // Second tap within debounce window - the button should be disabled
      // due to _isDebounced returning true
      await tester.pump(const Duration(seconds: 1));
      // Button should be disabled due to debounce
      final verifyButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Verify Code'),
      );
      expect(verifyButton.onPressed, isNull);

      // Only called once (the second tap was debounced)
      verify(() => mockCubit.verifyCode('place_1', '123456')).called(1);
    });
  });

  group('Step4PhoneVerification - Widget type', () {
    testWidgets('is a StatefulWidget', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        state: const VenueOnboardingState(
          status: VenueOnboardingStatus.initial,
        ),
      ));

      final widget = tester.widget<Step4PhoneVerification>(
        find.byType(Step4PhoneVerification),
      );
      expect(widget, isA<StatefulWidget>());
    });
  });
}
