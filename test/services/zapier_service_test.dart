import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/services/zapier_service.dart';

// -- Mocks --
class MockDio extends Mock implements Dio {}

// -- Fakes --
class FakeRequestOptions extends Fake implements RequestOptions {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRequestOptions());
  });

  // ============================================================================
  // Constructor
  // ============================================================================
  group('ZapierService - constructor', () {
    test('creates with default Dio', () {
      final service = ZapierService();
      expect(service, isA<ZapierService>());
    });

    test('creates with injected Dio', () {
      final mockDio = MockDio();
      final service = ZapierService(dio: mockDio);
      expect(service, isA<ZapierService>());
    });
  });

  // ============================================================================
  // isEnabled
  // ============================================================================
  group('ZapierService - isEnabled', () {
    test('returns true (enabled in both debug and production)', () {
      final service = ZapierService();
      // In test environment (debug mode), _enabledInDebug is true
      expect(service.isEnabled, isTrue);
    });
  });

  // ============================================================================
  // triggerZap
  // ============================================================================
  group('ZapierService - triggerZap', () {
    late MockDio mockDio;
    late ZapierService service;

    setUp(() {
      mockDio = MockDio();
      service = ZapierService(dio: mockDio);
    });

    test('sends POST request to Zapier MCP URL', () async {
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
          ));

      await service.triggerZap('test-zap', {'key': 'value'});

      verify(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).called(1);
    });

    test('enriches data with metadata fields', () async {
      Map<String, dynamic>? capturedData;

      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((invocation) async {
        capturedData = invocation.namedArguments[#data] as Map<String, dynamic>?;
        return Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        );
      });

      await service.triggerZap('test-zap', {'custom_field': 'test'});

      // Wait briefly for the fire-and-forget async call to complete
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(capturedData, isNotNull);
      final payload = capturedData!['payload'] as Map<String, dynamic>;
      expect(payload['custom_field'], 'test');
      expect(payload['app_version'], '1.0.0');
      expect(payload['platform'], 'flutter');
      expect(payload['timestamp'], isNotNull);
      expect(payload['environment'], isNotNull);
    });

    test('includes zap_name in request data', () async {
      Map<String, dynamic>? capturedData;

      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((invocation) async {
        capturedData = invocation.namedArguments[#data] as Map<String, dynamic>?;
        return Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        );
      });

      await service.triggerZap('venue-signup', {});

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(capturedData, isNotNull);
      expect(capturedData!['zap_name'], 'venue-signup');
    });

    test('does not throw on network error', () async {
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
        message: 'Connection timeout',
      ));

      // Should not throw - fire-and-forget pattern
      await service.triggerZap('test-zap', {'key': 'value'});
      // If we get here without throwing, the test passes
    });

    test('does not throw on server error (500)', () async {
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 500,
          ));

      await service.triggerZap('test-zap', {'key': 'value'});
      // Should complete without throwing
    });
  });

  // ============================================================================
  // triggerVenueSignup
  // ============================================================================
  group('ZapierService - triggerVenueSignup', () {
    late MockDio mockDio;
    late ZapierService service;

    setUp(() {
      mockDio = MockDio();
      service = ZapierService(dio: mockDio);
    });

    test('sends venue signup data with all required fields', () async {
      Map<String, dynamic>? capturedData;

      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((invocation) async {
        capturedData = invocation.namedArguments[#data] as Map<String, dynamic>?;
        return Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        );
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
      expect(capturedData!['zap_name'], 'venue-signup');
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

      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((invocation) async {
        capturedData = invocation.namedArguments[#data] as Map<String, dynamic>?;
        return Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        );
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
    late MockDio mockDio;
    late ZapierService service;

    setUp(() {
      mockDio = MockDio();
      service = ZapierService(dio: mockDio);
    });

    test('sends payment event with required fields', () async {
      Map<String, dynamic>? capturedData;

      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((invocation) async {
        capturedData = invocation.namedArguments[#data] as Map<String, dynamic>?;
        return Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        );
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
      expect(capturedData!['zap_name'], 'payment-event');
      final payload = capturedData!['payload'] as Map<String, dynamic>;
      expect(payload['event_type'], 'subscription_created');
      expect(payload['customer_id'], 'user_123');
      expect(payload['amount'], '\$14.99');
      expect(payload['plan_name'], 'Fan Pass');
      expect(payload['metadata'], {'source': 'mobile'});
    });

    test('sends payment event without optional fields', () async {
      Map<String, dynamic>? capturedData;

      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((invocation) async {
        capturedData = invocation.namedArguments[#data] as Map<String, dynamic>?;
        return Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        );
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
    late MockDio mockDio;
    late ZapierService service;

    setUp(() {
      mockDio = MockDio();
      service = ZapierService(dio: mockDio);
    });

    test('sends user engagement event with all fields', () async {
      Map<String, dynamic>? capturedData;

      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((invocation) async {
        capturedData = invocation.namedArguments[#data] as Map<String, dynamic>?;
        return Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        );
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
      expect(capturedData!['zap_name'], 'user-engagement');
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
    late MockDio mockDio;
    late ZapierService service;

    setUp(() {
      mockDio = MockDio();
      service = ZapierService(dio: mockDio);
    });

    test('sends AI recommendation data', () async {
      Map<String, dynamic>? capturedData;

      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((invocation) async {
        capturedData = invocation.namedArguments[#data] as Map<String, dynamic>?;
        return Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        );
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
      expect(capturedData!['zap_name'], 'ai-recommendation-success');
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
    late MockDio mockDio;
    late ZapierService service;

    setUp(() {
      mockDio = MockDio();
      service = ZapierService(dio: mockDio);
    });

    test('sends game day surge data', () async {
      Map<String, dynamic>? capturedData;

      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((invocation) async {
        capturedData = invocation.namedArguments[#data] as Map<String, dynamic>?;
        return Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        );
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
      expect(capturedData!['zap_name'], 'game-day-surge');
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
    late MockDio mockDio;
    late ZapierService service;

    setUp(() {
      mockDio = MockDio();
      service = ZapierService(dio: mockDio);
    });

    test('sends business metrics with all fields', () async {
      Map<String, dynamic>? capturedData;

      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((invocation) async {
        capturedData = invocation.namedArguments[#data] as Map<String, dynamic>?;
        return Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        );
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
      expect(capturedData!['zap_name'], 'business-metrics');
      final payload = capturedData!['payload'] as Map<String, dynamic>;
      expect(payload['active_users'], 5000);
      expect(payload['total_venues'], 150);
      expect(payload['total_revenue'], 45000.50);
      expect(payload['ai_success_rate'], 0.87);
      expect(payload['report_period'], 'weekly');
    });

    test('uses default report period of weekly', () async {
      Map<String, dynamic>? capturedData;

      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((invocation) async {
        capturedData = invocation.namedArguments[#data] as Map<String, dynamic>?;
        return Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        );
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
    late MockDio mockDio;
    late ZapierService service;

    setUp(() {
      mockDio = MockDio();
      service = ZapierService(dio: mockDio);
    });

    test('sends support ticket with all fields', () async {
      Map<String, dynamic>? capturedData;

      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((invocation) async {
        capturedData = invocation.namedArguments[#data] as Map<String, dynamic>?;
        return Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        );
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
      expect(capturedData!['zap_name'], 'support-ticket');
      final payload = capturedData!['payload'] as Map<String, dynamic>;
      expect(payload['user_id'], 'user_1');
      expect(payload['issue_type'], 'payment');
      expect(payload['description'], 'Cannot complete checkout');
      expect(payload['priority'], 'high');
      expect(payload['category'], 'billing');
    });

    test('uses default medium priority when not specified', () async {
      Map<String, dynamic>? capturedData;

      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((invocation) async {
        capturedData = invocation.namedArguments[#data] as Map<String, dynamic>?;
        return Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        );
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
    late MockDio mockDio;
    late ZapierService service;

    setUp(() {
      mockDio = MockDio();
      service = ZapierService(dio: mockDio);
    });

    test('sends marketing event data', () async {
      Map<String, dynamic>? capturedData;

      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((invocation) async {
        capturedData = invocation.namedArguments[#data] as Map<String, dynamic>?;
        return Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        );
      });

      await service.triggerMarketingEvent(
        eventType: 'milestone',
        eventData: {'users_reached': 10000},
        targetAudience: ['premium_users', 'venue_owners'],
        campaignId: 'campaign_001',
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(capturedData, isNotNull);
      expect(capturedData!['zap_name'], 'marketing-event');
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
      // disable() just logs a warning, should not throw
      expect(() => ZapierService.disable(), returnsNormally);
    });
  });
}
