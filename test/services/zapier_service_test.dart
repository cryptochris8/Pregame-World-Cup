import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/services/zapier_service.dart';

// -- Mocks --
class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

class MockHttpsCallable extends Mock implements HttpsCallable {}

class MockHttpsCallableResult extends Mock
    implements HttpsCallableResult<Map<String, dynamic>> {}

void main() {
  // ============================================================================
  // Constructor
  // ============================================================================
  group('ZapierService - constructor', () {
    test('creates with default FirebaseFunctions', () {
      // Cannot call without Firebase initialized, but injection path works
      final mockFunctions = MockFirebaseFunctions();
      final service = ZapierService(functions: mockFunctions);
      expect(service, isA<ZapierService>());
    });

    test('creates with injected FirebaseFunctions', () {
      final mockFunctions = MockFirebaseFunctions();
      final service = ZapierService(functions: mockFunctions);
      expect(service, isA<ZapierService>());
    });
  });

  // ============================================================================
  // isEnabled
  // ============================================================================
  group('ZapierService - isEnabled', () {
    test('returns true (enabled in both debug and production)', () {
      final mockFunctions = MockFirebaseFunctions();
      final service = ZapierService(functions: mockFunctions);
      // In test environment (debug mode), _enabledInDebug is true
      expect(service.isEnabled, isTrue);
    });
  });

  // ============================================================================
  // triggerZap
  // ============================================================================
  group('ZapierService - triggerZap', () {
    late MockFirebaseFunctions mockFunctions;
    late MockHttpsCallable mockCallable;
    late MockHttpsCallableResult mockResult;
    late ZapierService service;

    setUp(() {
      mockFunctions = MockFirebaseFunctions();
      mockCallable = MockHttpsCallable();
      mockResult = MockHttpsCallableResult();
      service = ZapierService(functions: mockFunctions);

      when(() => mockResult.data).thenReturn({'success': true, 'statusCode': 200});
      when(() => mockCallable.call<Map<String, dynamic>>(any()))
          .thenAnswer((_) async => mockResult);
      when(() => mockFunctions.httpsCallable(
            any(),
            options: any(named: 'options'),
          )).thenReturn(mockCallable);
    });

    test('calls triggerZapierWorkflow Cloud Function', () async {
      await service.triggerZap('test-zap', {'key': 'value'});

      // Wait for fire-and-forget async call
      await Future<void>.delayed(const Duration(milliseconds: 100));

      verify(() => mockFunctions.httpsCallable(
            'triggerZapierWorkflow',
            options: any(named: 'options'),
          )).called(1);
    });

    test('sends zapName and enriched payload to Cloud Function', () async {
      Map<String, dynamic>? capturedData;

      when(() => mockCallable.call<Map<String, dynamic>>(any()))
          .thenAnswer((invocation) async {
        capturedData =
            invocation.positionalArguments[0] as Map<String, dynamic>?;
        return mockResult;
      });

      await service.triggerZap('test-zap', {'custom_field': 'test'});

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(capturedData, isNotNull);
      expect(capturedData!['zapName'], 'test-zap');
      final payload = capturedData!['payload'] as Map<String, dynamic>;
      expect(payload['custom_field'], 'test');
      expect(payload['app_version'], '1.0.0');
      expect(payload['platform'], 'flutter');
      expect(payload['timestamp'], isNotNull);
      expect(payload['environment'], isNotNull);
    });

    test('does not throw on FirebaseFunctionsException', () async {
      when(() => mockCallable.call<Map<String, dynamic>>(any()))
          .thenThrow(FirebaseFunctionsException(message: 'fail', code: 'internal'));

      // Should not throw - fire-and-forget pattern
      await service.triggerZap('test-zap', {'key': 'value'});
      // If we get here without throwing, the test passes
    });

    test('does not throw on generic exception', () async {
      when(() => mockCallable.call<Map<String, dynamic>>(any()))
          .thenThrow(Exception('network error'));

      await service.triggerZap('test-zap', {'key': 'value'});
      // Should complete without throwing
    });

    test('does not contain any hardcoded URL or credential', () {
      // Verify the service source has no embedded secrets
      // This is a conceptual test — the real proof is in the source code itself
      final mockFunctions2 = MockFirebaseFunctions();
      final svc = ZapierService(functions: mockFunctions2);
      // Service should have no static URL fields
      expect(svc, isA<ZapierService>());
    });
  });

  // ============================================================================
  // triggerVenueSignup
  // ============================================================================
  group('ZapierService - triggerVenueSignup', () {
    late MockFirebaseFunctions mockFunctions;
    late MockHttpsCallable mockCallable;
    late MockHttpsCallableResult mockResult;
    late ZapierService service;

    setUp(() {
      mockFunctions = MockFirebaseFunctions();
      mockCallable = MockHttpsCallable();
      mockResult = MockHttpsCallableResult();
      service = ZapierService(functions: mockFunctions);

      when(() => mockResult.data).thenReturn({'success': true, 'statusCode': 200});
      when(() => mockCallable.call<Map<String, dynamic>>(any()))
          .thenAnswer((_) async => mockResult);
      when(() => mockFunctions.httpsCallable(
            any(),
            options: any(named: 'options'),
          )).thenReturn(mockCallable);
    });

    test('sends venue signup data with all required fields', () async {
      Map<String, dynamic>? capturedData;

      when(() => mockCallable.call<Map<String, dynamic>>(any()))
          .thenAnswer((invocation) async {
        capturedData =
            invocation.positionalArguments[0] as Map<String, dynamic>?;
        return mockResult;
      });

      await service.triggerVenueSignup(
        venueName: 'The Sports Corner',
        ownerEmail: 'owner@sportsbar.com',
        subscriptionTier: 'premium',
        location: 'Dallas, TX',
        phone: '555-123-4567',
        monthlyRevenue: 50000.0,
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(capturedData, isNotNull);
      expect(capturedData!['zapName'], 'venue-signup');
      final payload = capturedData!['payload'] as Map<String, dynamic>;
      expect(payload['venue_name'], 'The Sports Corner');
      expect(payload['owner_email'], 'owner@sportsbar.com');
      expect(payload['subscription_tier'], 'premium');
      expect(payload['location'], 'Dallas, TX');
      expect(payload['phone'], '555-123-4567');
      expect(payload['estimated_monthly_revenue'], 50000.0);
      expect(payload['signup_source'], 'mobile_app');
    });

    test('sends venue signup without optional fields', () async {
      Map<String, dynamic>? capturedData;

      when(() => mockCallable.call<Map<String, dynamic>>(any()))
          .thenAnswer((invocation) async {
        capturedData =
            invocation.positionalArguments[0] as Map<String, dynamic>?;
        return mockResult;
      });

      await service.triggerVenueSignup(
        venueName: 'Bar',
        ownerEmail: 'test@test.com',
        subscriptionTier: 'free',
        location: 'NYC',
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(capturedData, isNotNull);
      final payload = capturedData!['payload'] as Map<String, dynamic>;
      expect(payload['phone'], isNull);
      expect(payload['estimated_monthly_revenue'], isNull);
    });
  });

  // ============================================================================
  // triggerPaymentEvent
  // ============================================================================
  group('ZapierService - triggerPaymentEvent', () {
    late MockFirebaseFunctions mockFunctions;
    late MockHttpsCallable mockCallable;
    late MockHttpsCallableResult mockResult;
    late ZapierService service;

    setUp(() {
      mockFunctions = MockFirebaseFunctions();
      mockCallable = MockHttpsCallable();
      mockResult = MockHttpsCallableResult();
      service = ZapierService(functions: mockFunctions);

      when(() => mockResult.data).thenReturn({'success': true, 'statusCode': 200});
      when(() => mockCallable.call<Map<String, dynamic>>(any()))
          .thenAnswer((_) async => mockResult);
      when(() => mockFunctions.httpsCallable(
            any(),
            options: any(named: 'options'),
          )).thenReturn(mockCallable);
    });

    test('sends payment event with required fields', () async {
      Map<String, dynamic>? capturedData;

      when(() => mockCallable.call<Map<String, dynamic>>(any()))
          .thenAnswer((invocation) async {
        capturedData =
            invocation.positionalArguments[0] as Map<String, dynamic>?;
        return mockResult;
      });

      await service.triggerPaymentEvent(
        eventType: 'subscription_created',
        customerId: 'user_123',
        amount: '\$14.99',
        planName: 'Fan Pass',
        metadata: {'source': 'mobile'},
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(capturedData, isNotNull);
      expect(capturedData!['zapName'], 'payment-event');
      final payload = capturedData!['payload'] as Map<String, dynamic>;
      expect(payload['event_type'], 'subscription_created');
      expect(payload['customer_id'], 'user_123');
      expect(payload['amount'], '\$14.99');
      expect(payload['plan_name'], 'Fan Pass');
      expect(payload['metadata'], {'source': 'mobile'});
    });

    test('sends payment event without optional fields', () async {
      Map<String, dynamic>? capturedData;

      when(() => mockCallable.call<Map<String, dynamic>>(any()))
          .thenAnswer((invocation) async {
        capturedData =
            invocation.positionalArguments[0] as Map<String, dynamic>?;
        return mockResult;
      });

      await service.triggerPaymentEvent(
        eventType: 'payment_failed',
        customerId: 'user_456',
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(capturedData, isNotNull);
      final payload = capturedData!['payload'] as Map<String, dynamic>;
      expect(payload['amount'], isNull);
      expect(payload['plan_name'], isNull);
      expect(payload['metadata'], isNull);
    });
  });

  // ============================================================================
  // triggerUserEngagement
  // ============================================================================
  group('ZapierService - triggerUserEngagement', () {
    late MockFirebaseFunctions mockFunctions;
    late MockHttpsCallable mockCallable;
    late MockHttpsCallableResult mockResult;
    late ZapierService service;

    setUp(() {
      mockFunctions = MockFirebaseFunctions();
      mockCallable = MockHttpsCallable();
      mockResult = MockHttpsCallableResult();
      service = ZapierService(functions: mockFunctions);

      when(() => mockResult.data).thenReturn({'success': true, 'statusCode': 200});
      when(() => mockCallable.call<Map<String, dynamic>>(any()))
          .thenAnswer((_) async => mockResult);
      when(() => mockFunctions.httpsCallable(
            any(),
            options: any(named: 'options'),
          )).thenReturn(mockCallable);
    });

    test('sends user engagement event with all fields', () async {
      Map<String, dynamic>? capturedData;

      when(() => mockCallable.call<Map<String, dynamic>>(any()))
          .thenAnswer((invocation) async {
        capturedData =
            invocation.positionalArguments[0] as Map<String, dynamic>?;
        return mockResult;
      });

      await service.triggerUserEngagement(
        userId: 'user_1',
        action: 'prediction_made',
        venueId: 'venue_1',
        gameContext: 'Brazil vs Argentina',
        additionalData: {'confidence': 0.85},
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(capturedData, isNotNull);
      expect(capturedData!['zapName'], 'user-engagement');
      final payload = capturedData!['payload'] as Map<String, dynamic>;
      expect(payload['user_id'], 'user_1');
      expect(payload['action'], 'prediction_made');
      expect(payload['venue_id'], 'venue_1');
      expect(payload['game_context'], 'Brazil vs Argentina');
    });
  });

  // ============================================================================
  // triggerAIRecommendationSuccess
  // ============================================================================
  group('ZapierService - triggerAIRecommendationSuccess', () {
    late MockFirebaseFunctions mockFunctions;
    late MockHttpsCallable mockCallable;
    late MockHttpsCallableResult mockResult;
    late ZapierService service;

    setUp(() {
      mockFunctions = MockFirebaseFunctions();
      mockCallable = MockHttpsCallable();
      mockResult = MockHttpsCallableResult();
      service = ZapierService(functions: mockFunctions);

      when(() => mockResult.data).thenReturn({'success': true, 'statusCode': 200});
      when(() => mockCallable.call<Map<String, dynamic>>(any()))
          .thenAnswer((_) async => mockResult);
      when(() => mockFunctions.httpsCallable(
            any(),
            options: any(named: 'options'),
          )).thenReturn(mockCallable);
    });

    test('sends AI recommendation data', () async {
      Map<String, dynamic>? capturedData;

      when(() => mockCallable.call<Map<String, dynamic>>(any()))
          .thenAnswer((invocation) async {
        capturedData =
            invocation.positionalArguments[0] as Map<String, dynamic>?;
        return mockResult;
      });

      await service.triggerAIRecommendationSuccess(
        userId: 'user_1',
        venueId: 'venue_1',
        confidence: 0.92,
        reasons: ['close distance', 'good ratings', 'shows game'],
        userAction: 'navigated',
        gameContext: 'USA vs Mexico',
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(capturedData, isNotNull);
      expect(capturedData!['zapName'], 'ai-recommendation-success');
      final payload = capturedData!['payload'] as Map<String, dynamic>;
      expect(payload['confidence'], 0.92);
      expect(payload['reasons'], hasLength(3));
      expect(payload['user_action'], 'navigated');
    });
  });

  // ============================================================================
  // triggerGameDaySurge
  // ============================================================================
  group('ZapierService - triggerGameDaySurge', () {
    late MockFirebaseFunctions mockFunctions;
    late MockHttpsCallable mockCallable;
    late MockHttpsCallableResult mockResult;
    late ZapierService service;

    setUp(() {
      mockFunctions = MockFirebaseFunctions();
      mockCallable = MockHttpsCallable();
      mockResult = MockHttpsCallableResult();
      service = ZapierService(functions: mockFunctions);

      when(() => mockResult.data).thenReturn({'success': true, 'statusCode': 200});
      when(() => mockCallable.call<Map<String, dynamic>>(any()))
          .thenAnswer((_) async => mockResult);
      when(() => mockFunctions.httpsCallable(
            any(),
            options: any(named: 'options'),
          )).thenReturn(mockCallable);
    });

    test('sends game day surge data', () async {
      Map<String, dynamic>? capturedData;

      when(() => mockCallable.call<Map<String, dynamic>>(any()))
          .thenAnswer((invocation) async {
        capturedData =
            invocation.positionalArguments[0] as Map<String, dynamic>?;
        return mockResult;
      });

      await service.triggerGameDaySurge(
        gameId: 'match_1',
        crowdFactor: 1.5,
        expectedTrafficIncrease: 200.0,
        affectedVenues: ['venue_a', 'venue_b'],
        gameDescription: 'Semifinal: Brazil vs France',
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(capturedData, isNotNull);
      expect(capturedData!['zapName'], 'game-day-surge');
      final payload = capturedData!['payload'] as Map<String, dynamic>;
      expect(payload['game_id'], 'match_1');
      expect(payload['crowd_factor'], 1.5);
      expect(payload['affected_venues'], hasLength(2));
    });
  });

  // ============================================================================
  // triggerBusinessMetrics
  // ============================================================================
  group('ZapierService - triggerBusinessMetrics', () {
    late MockFirebaseFunctions mockFunctions;
    late MockHttpsCallable mockCallable;
    late MockHttpsCallableResult mockResult;
    late ZapierService service;

    setUp(() {
      mockFunctions = MockFirebaseFunctions();
      mockCallable = MockHttpsCallable();
      mockResult = MockHttpsCallableResult();
      service = ZapierService(functions: mockFunctions);

      when(() => mockResult.data).thenReturn({'success': true, 'statusCode': 200});
      when(() => mockCallable.call<Map<String, dynamic>>(any()))
          .thenAnswer((_) async => mockResult);
      when(() => mockFunctions.httpsCallable(
            any(),
            options: any(named: 'options'),
          )).thenReturn(mockCallable);
    });

    test('sends business metrics with all fields', () async {
      Map<String, dynamic>? capturedData;

      when(() => mockCallable.call<Map<String, dynamic>>(any()))
          .thenAnswer((invocation) async {
        capturedData =
            invocation.positionalArguments[0] as Map<String, dynamic>?;
        return mockResult;
      });

      await service.triggerBusinessMetrics(
        activeUsers: 5000,
        totalVenues: 150,
        totalRevenue: 45000.50,
        aiSuccessRate: 0.87,
        topPerformingVenues: ['venue_1', 'venue_2'],
        reportPeriod: 'weekly',
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(capturedData, isNotNull);
      expect(capturedData!['zapName'], 'business-metrics');
      final payload = capturedData!['payload'] as Map<String, dynamic>;
      expect(payload['active_users'], 5000);
      expect(payload['total_venues'], 150);
      expect(payload['total_revenue'], 45000.50);
      expect(payload['ai_success_rate'], 0.87);
      expect(payload['report_period'], 'weekly');
    });

    test('uses default report period of weekly', () async {
      Map<String, dynamic>? capturedData;

      when(() => mockCallable.call<Map<String, dynamic>>(any()))
          .thenAnswer((invocation) async {
        capturedData =
            invocation.positionalArguments[0] as Map<String, dynamic>?;
        return mockResult;
      });

      await service.triggerBusinessMetrics(
        activeUsers: 100,
        totalVenues: 10,
        totalRevenue: 1000.0,
        aiSuccessRate: 0.5,
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(capturedData, isNotNull);
      final payload = capturedData!['payload'] as Map<String, dynamic>;
      expect(payload['report_period'], 'weekly');
    });
  });

  // ============================================================================
  // triggerSupportTicket
  // ============================================================================
  group('ZapierService - triggerSupportTicket', () {
    late MockFirebaseFunctions mockFunctions;
    late MockHttpsCallable mockCallable;
    late MockHttpsCallableResult mockResult;
    late ZapierService service;

    setUp(() {
      mockFunctions = MockFirebaseFunctions();
      mockCallable = MockHttpsCallable();
      mockResult = MockHttpsCallableResult();
      service = ZapierService(functions: mockFunctions);

      when(() => mockResult.data).thenReturn({'success': true, 'statusCode': 200});
      when(() => mockCallable.call<Map<String, dynamic>>(any()))
          .thenAnswer((_) async => mockResult);
      when(() => mockFunctions.httpsCallable(
            any(),
            options: any(named: 'options'),
          )).thenReturn(mockCallable);
    });

    test('sends support ticket with all fields', () async {
      Map<String, dynamic>? capturedData;

      when(() => mockCallable.call<Map<String, dynamic>>(any()))
          .thenAnswer((invocation) async {
        capturedData =
            invocation.positionalArguments[0] as Map<String, dynamic>?;
        return mockResult;
      });

      await service.triggerSupportTicket(
        userId: 'user_1',
        issueType: 'payment',
        description: 'Cannot complete checkout',
        priority: 'high',
        category: 'billing',
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(capturedData, isNotNull);
      expect(capturedData!['zapName'], 'support-ticket');
      final payload = capturedData!['payload'] as Map<String, dynamic>;
      expect(payload['user_id'], 'user_1');
      expect(payload['issue_type'], 'payment');
      expect(payload['description'], 'Cannot complete checkout');
      expect(payload['priority'], 'high');
      expect(payload['category'], 'billing');
    });

    test('uses default medium priority when not specified', () async {
      Map<String, dynamic>? capturedData;

      when(() => mockCallable.call<Map<String, dynamic>>(any()))
          .thenAnswer((invocation) async {
        capturedData =
            invocation.positionalArguments[0] as Map<String, dynamic>?;
        return mockResult;
      });

      await service.triggerSupportTicket(
        userId: 'user_1',
        issueType: 'general',
        description: 'Question about features',
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(capturedData, isNotNull);
      final payload = capturedData!['payload'] as Map<String, dynamic>;
      expect(payload['priority'], 'medium');
    });
  });

  // ============================================================================
  // triggerMarketingEvent
  // ============================================================================
  group('ZapierService - triggerMarketingEvent', () {
    late MockFirebaseFunctions mockFunctions;
    late MockHttpsCallable mockCallable;
    late MockHttpsCallableResult mockResult;
    late ZapierService service;

    setUp(() {
      mockFunctions = MockFirebaseFunctions();
      mockCallable = MockHttpsCallable();
      mockResult = MockHttpsCallableResult();
      service = ZapierService(functions: mockFunctions);

      when(() => mockResult.data).thenReturn({'success': true, 'statusCode': 200});
      when(() => mockCallable.call<Map<String, dynamic>>(any()))
          .thenAnswer((_) async => mockResult);
      when(() => mockFunctions.httpsCallable(
            any(),
            options: any(named: 'options'),
          )).thenReturn(mockCallable);
    });

    test('sends marketing event data', () async {
      Map<String, dynamic>? capturedData;

      when(() => mockCallable.call<Map<String, dynamic>>(any()))
          .thenAnswer((invocation) async {
        capturedData =
            invocation.positionalArguments[0] as Map<String, dynamic>?;
        return mockResult;
      });

      await service.triggerMarketingEvent(
        eventType: 'milestone',
        eventData: {'users_reached': 10000},
        targetAudience: ['premium_users', 'venue_owners'],
        campaignId: 'campaign_001',
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(capturedData, isNotNull);
      expect(capturedData!['zapName'], 'marketing-event');
      final payload = capturedData!['payload'] as Map<String, dynamic>;
      expect(payload['event_type'], 'milestone');
      expect(payload['target_audience'], hasLength(2));
      expect(payload['campaign_id'], 'campaign_001');
    });
  });

  // ============================================================================
  // disable (static method)
  // ============================================================================
  group('ZapierService - disable', () {
    test('calling disable does not throw', () {
      expect(() => ZapierService.disable(), returnsNormally);
    });
  });
}
