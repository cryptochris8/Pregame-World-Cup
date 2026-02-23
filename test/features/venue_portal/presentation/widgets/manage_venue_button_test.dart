import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';

import 'package:pregame_world_cup/features/recommendations/domain/entities/place.dart';
import 'package:pregame_world_cup/features/venue_portal/domain/entities/venue_enhancement.dart';
import 'package:pregame_world_cup/features/venue_portal/domain/services/venue_enhancement_service.dart';
import 'package:pregame_world_cup/features/venue_portal/presentation/bloc/venue_enhancement_cubit.dart';
import 'package:pregame_world_cup/features/venue_portal/presentation/widgets/manage_venue_button.dart';
import 'package:pregame_world_cup/l10n/app_localizations.dart';

// Mocks
class MockVenueEnhancementService extends Mock
    implements VenueEnhancementService {}

void main() {
  late MockVenueEnhancementService mockService;
  final sl = GetIt.instance;

  final now = DateTime(2026, 6, 15, 12, 0, 0);

  const testVenue = Place(
    placeId: 'venue_123',
    name: 'Sports Bar Downtown',
  );

  VenueEnhancement createEnhancement({
    String venueId = 'venue_123',
    String ownerId = 'current_user_id',
    VenueClaimStatus claimStatus = VenueClaimStatus.approved,
    DateTime? claimedAt,
    String? venuePhoneNumber,
  }) {
    return VenueEnhancement(
      venueId: venueId,
      ownerId: ownerId,
      claimStatus: claimStatus,
      claimedAt: claimedAt,
      venuePhoneNumber: venuePhoneNumber,
      createdAt: now,
      updatedAt: now,
    );
  }

  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    );
  }

  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  setUp(() {
    mockService = MockVenueEnhancementService();

    // Register mock service in GetIt
    if (sl.isRegistered<VenueEnhancementService>()) {
      sl.unregister<VenueEnhancementService>();
    }
    sl.registerSingleton<VenueEnhancementService>(mockService);

    // Register mock cubit factory in GetIt
    if (sl.isRegistered<VenueEnhancementCubit>()) {
      sl.unregister<VenueEnhancementCubit>();
    }
    sl.registerFactory<VenueEnhancementCubit>(
      () => VenueEnhancementCubit(service: mockService),
    );
  });

  tearDown(() {
    if (sl.isRegistered<VenueEnhancementService>()) {
      sl.unregister<VenueEnhancementService>();
    }
    if (sl.isRegistered<VenueEnhancementCubit>()) {
      sl.unregister<VenueEnhancementCubit>();
    }
  });

  group('ManageVenueButton', () {
    // =========================================================================
    // 1. Loading state - uses a Completer that never completes so the
    //    FutureBuilder stays in ConnectionState.waiting
    // =========================================================================
    testWidgets('shows loading indicator while fetching enhancement',
        (tester) async {
      // Use a Completer that is never completed - no pending timers
      final completer = Completer<VenueEnhancement?>();
      when(() => mockService.getVenueEnhancement('venue_123'))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        buildTestWidget(const ManageVenueButton(venue: testVenue)),
      );
      // Only pump once to stay in loading/waiting state
      await tester.pump();

      // Should show a CircularProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // =========================================================================
    // 2. Unclaimed state - no enhancement exists
    // =========================================================================
    testWidgets(
        'shows "Manage This Venue" button when venue has no enhancement',
        (tester) async {
      when(() => mockService.getVenueEnhancement('venue_123'))
          .thenAnswer((_) async => null);

      await tester.pumpWidget(
        buildTestWidget(const ManageVenueButton(venue: testVenue)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Manage This Venue'), findsOneWidget);
      expect(find.byIcon(Icons.storefront), findsOneWidget);
    });

    // =========================================================================
    // 3. Unclaimed state - enhancement exists but ownerId is empty
    // =========================================================================
    testWidgets('shows "Manage This Venue" button when ownerId is empty',
        (tester) async {
      final enhancement = createEnhancement(ownerId: '');
      when(() => mockService.getVenueEnhancement('venue_123'))
          .thenAnswer((_) async => enhancement);

      await tester.pumpWidget(
        buildTestWidget(const ManageVenueButton(venue: testVenue)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Manage This Venue'), findsOneWidget);
      expect(find.byIcon(Icons.storefront), findsOneWidget);
    });

    // =========================================================================
    // 4. Already managed by another user - shows "Venue Already Managed"
    //    Note: In test environment, FirebaseAuth.instance.currentUser is null.
    //    When enhancement.ownerId is set and does not match null, the widget
    //    renders _buildAlreadyManagedButton with dispute option.
    // =========================================================================
    testWidgets(
        'shows "Venue Already Managed" with dispute button when venue has an owner',
        (tester) async {
      final enhancement = createEnhancement(
        ownerId: 'other_user_id',
        claimStatus: VenueClaimStatus.approved,
      );
      when(() => mockService.getVenueEnhancement('venue_123'))
          .thenAnswer((_) async => enhancement);

      await tester.pumpWidget(
        buildTestWidget(const ManageVenueButton(venue: testVenue)),
      );
      await tester.pumpAndSettle();

      // Should show the already managed button
      expect(find.text('Venue Already Managed'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);

      // Should show the dispute button
      expect(find.text('Report / Dispute Claim'), findsOneWidget);
      expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
    });

    // =========================================================================
    // 5. Dispute button opens dispute bottom sheet
    // =========================================================================
    testWidgets('tapping dispute button opens dispute bottom sheet',
        (tester) async {
      final enhancement = createEnhancement(
        ownerId: 'other_user_id',
        claimStatus: VenueClaimStatus.approved,
      );
      when(() => mockService.getVenueEnhancement('venue_123'))
          .thenAnswer((_) async => enhancement);

      await tester.pumpWidget(
        buildTestWidget(const ManageVenueButton(venue: testVenue)),
      );
      await tester.pumpAndSettle();

      // Tap the dispute button
      await tester.tap(find.text('Report / Dispute Claim'));
      await tester.pumpAndSettle();

      // Should show the dispute sheet
      expect(find.text('Dispute Venue Claim'), findsOneWidget);
      expect(find.text('I am the real owner'), findsOneWidget);
      expect(find.text('Venue is closed'), findsOneWidget);
      expect(find.text('Fraudulent claim'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);
      expect(find.text('Submit Dispute'), findsOneWidget);
    });

    // =========================================================================
    // 6. Dispute sheet submit button is disabled until reason selected
    // =========================================================================
    testWidgets(
        'dispute submit button is disabled until a reason is selected',
        (tester) async {
      final enhancement = createEnhancement(
        ownerId: 'other_user_id',
      );
      when(() => mockService.getVenueEnhancement('venue_123'))
          .thenAnswer((_) async => enhancement);

      await tester.pumpWidget(
        buildTestWidget(const ManageVenueButton(venue: testVenue)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Report / Dispute Claim'));
      await tester.pumpAndSettle();

      // Submit button should be disabled (no reason selected)
      final submitButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Submit Dispute'),
      );
      expect(submitButton.onPressed, isNull);

      // Select a reason
      await tester.tap(find.text('I am the real owner'));
      await tester.pumpAndSettle();

      // Now submit button should be enabled
      final enabledButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Submit Dispute'),
      );
      expect(enabledButton.onPressed, isNotNull);
    });

    // =========================================================================
    // 7. Venue with pending claim from another user shows "Already Managed"
    // =========================================================================
    testWidgets(
        'venue with pendingVerification from another user shows "Already Managed"',
        (tester) async {
      final enhancement = createEnhancement(
        ownerId: 'other_user_id',
        claimStatus: VenueClaimStatus.pendingVerification,
      );
      when(() => mockService.getVenueEnhancement('venue_123'))
          .thenAnswer((_) async => enhancement);

      await tester.pumpWidget(
        buildTestWidget(const ManageVenueButton(venue: testVenue)),
      );
      await tester.pumpAndSettle();

      // Since currentUser is null and ownerId is set, this shows "Already Managed"
      expect(find.text('Venue Already Managed'), findsOneWidget);
      expect(find.text('Report / Dispute Claim'), findsOneWidget);
    });

    // =========================================================================
    // 8. Venue with pending review from another user shows "Already Managed"
    // =========================================================================
    testWidgets(
        'venue with pendingReview from another user shows "Already Managed"',
        (tester) async {
      final enhancement = createEnhancement(
        ownerId: 'other_user_id',
        claimStatus: VenueClaimStatus.pendingReview,
      );
      when(() => mockService.getVenueEnhancement('venue_123'))
          .thenAnswer((_) async => enhancement);

      await tester.pumpWidget(
        buildTestWidget(const ManageVenueButton(venue: testVenue)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Venue Already Managed'), findsOneWidget);
    });

    // =========================================================================
    // 9. Unclaimed button has correct visual elements
    // =========================================================================
    testWidgets('unclaimed button has storefront icon and InkWell for tapping',
        (tester) async {
      when(() => mockService.getVenueEnhancement('venue_123'))
          .thenAnswer((_) async => null);

      await tester.pumpWidget(
        buildTestWidget(const ManageVenueButton(venue: testVenue)),
      );
      await tester.pumpAndSettle();

      // Verify the button text and icon are present
      expect(find.text('Manage This Venue'), findsOneWidget);
      expect(find.byIcon(Icons.storefront), findsOneWidget);

      // Verify the button is wrapped in an InkWell (tappable)
      expect(find.byType(InkWell), findsOneWidget);
    });
  });

  // ===========================================================================
  // Dispute sheet detailed interaction tests
  // ===========================================================================
  group('ManageVenueButton dispute sheet', () {
    testWidgets('shows venue name in dispute sheet description',
        (tester) async {
      final enhancement = createEnhancement(ownerId: 'other_user');
      when(() => mockService.getVenueEnhancement('venue_123'))
          .thenAnswer((_) async => enhancement);

      await tester.pumpWidget(
        buildTestWidget(const ManageVenueButton(venue: testVenue)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Report / Dispute Claim'));
      await tester.pumpAndSettle();

      expect(
        find.text('Report an incorrect claim on Sports Bar Downtown'),
        findsOneWidget,
      );
    });

    testWidgets('selecting a reason chip enables submit', (tester) async {
      final enhancement = createEnhancement(ownerId: 'other_user');
      when(() => mockService.getVenueEnhancement('venue_123'))
          .thenAnswer((_) async => enhancement);

      await tester.pumpWidget(
        buildTestWidget(const ManageVenueButton(venue: testVenue)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Report / Dispute Claim'));
      await tester.pumpAndSettle();

      // Select "Fraudulent claim"
      await tester.tap(find.text('Fraudulent claim'));
      await tester.pumpAndSettle();

      final submitButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Submit Dispute'),
      );
      expect(submitButton.onPressed, isNotNull);
    });

    testWidgets('has text field for additional details', (tester) async {
      final enhancement = createEnhancement(ownerId: 'other_user');
      when(() => mockService.getVenueEnhancement('venue_123'))
          .thenAnswer((_) async => enhancement);

      await tester.pumpWidget(
        buildTestWidget(const ManageVenueButton(venue: testVenue)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Report / Dispute Claim'));
      await tester.pumpAndSettle();

      // Should have a text field with hint text
      expect(find.text('Additional details...'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('submitting dispute calls service and shows snackbar',
        (tester) async {
      final enhancement = createEnhancement(ownerId: 'other_user');
      when(() => mockService.getVenueEnhancement('venue_123'))
          .thenAnswer((_) async => enhancement);
      when(() => mockService.submitDispute(
            'venue_123',
            'I am the real owner',
            'I have the lease',
          )).thenAnswer((_) async => true);

      await tester.pumpWidget(
        buildTestWidget(const ManageVenueButton(venue: testVenue)),
      );
      await tester.pumpAndSettle();

      // Open dispute sheet
      await tester.tap(find.text('Report / Dispute Claim'));
      await tester.pumpAndSettle();

      // Select a reason
      await tester.tap(find.text('I am the real owner'));
      await tester.pumpAndSettle();

      // Enter details
      await tester.enterText(find.byType(TextField), 'I have the lease');
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.text('Submit Dispute'));
      await tester.pumpAndSettle();

      // Verify service was called
      verify(() => mockService.submitDispute(
            'venue_123',
            'I am the real owner',
            'I have the lease',
          )).called(1);

      // Snackbar should appear
      expect(find.text('Dispute submitted for review.'), findsOneWidget);
    });
  });
}
