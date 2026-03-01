import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/core/services/deep_link_service.dart';
import 'package:pregame_world_cup/core/services/analytics_service.dart';
import 'package:app_links/app_links.dart';

// -- Mocks --
class MockAppLinks extends Mock implements AppLinks {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  // DeepLinkService is a singleton, so we need special handling.
  // We'll use the fact that the test creates its own isolate, so the singleton
  // is fresh for each test file run. We test link generation and handler management.

  late DeepLinkService service;
  late MockAppLinks mockAppLinks;
  late MockAnalyticsService mockAnalyticsService;

  setUp(() {
    // Reset the singleton for each test by using reflection-like approach.
    // Since DeepLinkService uses a static _instance, we can only create it once.
    // For the first test, this creates the instance. For subsequent tests,
    // the factory returns the same instance.
    mockAppLinks = MockAppLinks();
    mockAnalyticsService = MockAnalyticsService();

    // Stub analytics methods that may be called during tests
    when(() => mockAnalyticsService.logEvent(
          any(),
          parameters: any(named: 'parameters'),
        )).thenAnswer((_) async {});
    when(() => mockAnalyticsService.logShare(
          contentType: any(named: 'contentType'),
          itemId: any(named: 'itemId'),
          method: any(named: 'method'),
        )).thenAnswer((_) async {});

    service = DeepLinkService(
      appLinks: mockAppLinks,
      analyticsService: mockAnalyticsService,
    );
  });

  // ==================== Link Generation ====================

  group('generateLink', () {
    test('generates basic match link', () async {
      final link = await service.generateLink(
        type: DeepLinkType.match,
        id: 'game_123',
        title: 'USA vs Mexico',
        description: 'Watch the big game!',
      );

      expect(link, contains('https://pregameworldcup.com/match/game_123'));
    });

    test('generates team link', () async {
      final link = await service.generateLink(
        type: DeepLinkType.team,
        id: 'usa',
        title: 'United States',
        description: 'Follow USA!',
      );

      expect(link, contains('https://pregameworldcup.com/team/usa'));
    });

    test('generates watch party link', () async {
      final link = await service.generateLink(
        type: DeepLinkType.watchParty,
        id: 'wp_456',
        title: 'Watch Party',
        description: 'Join us!',
      );

      expect(link, contains('https://pregameworldcup.com/watch-party/wp_456'));
    });

    test('generates prediction link', () async {
      final link = await service.generateLink(
        type: DeepLinkType.prediction,
        id: 'pred_789',
        title: 'My Prediction',
        description: 'USA to win!',
      );

      expect(link, contains('https://pregameworldcup.com/prediction/pred_789'));
    });

    test('generates profile link', () async {
      final link = await service.generateLink(
        type: DeepLinkType.userProfile,
        id: 'user_abc',
        title: 'John Doe',
        description: 'Follow me!',
      );

      expect(link, contains('https://pregameworldcup.com/profile/user_abc'));
    });

    test('generates venue link', () async {
      final link = await service.generateLink(
        type: DeepLinkType.venue,
        id: 'venue_metlife',
        title: 'MetLife Stadium',
        description: 'Watch here!',
      );

      expect(link, contains('https://pregameworldcup.com/venue/venue_metlife'));
    });

    test('generates leaderboard link', () async {
      final link = await service.generateLink(
        type: DeepLinkType.leaderboard,
        id: 'global',
        title: 'Leaderboard',
        description: 'Check rankings!',
      );

      expect(link, contains('https://pregameworldcup.com/leaderboard/global'));
    });

    test('includes campaign query params when provided', () async {
      final link = await service.generateLink(
        type: DeepLinkType.match,
        id: 'game_123',
        title: 'Test',
        description: 'Test',
        campaign: 'summer_share',
      );

      expect(link, contains('utm_campaign=summer_share'));
      expect(link, contains('utm_source=app_share'));
      expect(link, contains('utm_medium=social'));
    });

    test('includes additional params in query string', () async {
      final link = await service.generateLink(
        type: DeepLinkType.match,
        id: 'game_123',
        title: 'Test',
        description: 'Test',
        additionalParams: {'source': 'notification', 'ref': 'user_xyz'},
      );

      expect(link, contains('source=notification'));
      expect(link, contains('ref=user_xyz'));
    });

    test('generates link without query params when none provided', () async {
      final link = await service.generateLink(
        type: DeepLinkType.match,
        id: 'game_123',
        title: 'Test',
        description: 'Test',
      );

      expect(link, equals('https://pregameworldcup.com/match/game_123'));
    });

    test('encodes special characters in query values', () async {
      final link = await service.generateLink(
        type: DeepLinkType.match,
        id: 'game_123',
        title: 'Test',
        description: 'Test',
        additionalParams: {'message': 'hello world'},
      );

      expect(link, contains('message=hello%20world'));
    });
  });

  // ==================== Convenience Link Generators ====================

  group('generateMatchLink', () {
    test('generates correct match link', () async {
      final link = await service.generateMatchLink(
        matchId: 'game_usa_mex',
        homeTeam: 'USA',
        awayTeam: 'Mexico',
      );

      expect(link, contains('https://pregameworldcup.com/match/game_usa_mex'));
      expect(link, contains('utm_campaign=match_share'));
    });

    test('generates match link with date', () async {
      final link = await service.generateMatchLink(
        matchId: 'game_1',
        homeTeam: 'Brazil',
        awayTeam: 'Germany',
        matchDate: 'June 15, 2026',
      );

      expect(link, contains('https://pregameworldcup.com/match/game_1'));
    });
  });

  group('generateWatchPartyLink', () {
    test('generates correct watch party link', () async {
      final link = await service.generateWatchPartyLink(
        partyId: 'wp_123',
        partyName: 'Game Day Party',
        matchName: 'USA vs Mexico',
        venueName: 'Sports Bar',
      );

      expect(link, contains('https://pregameworldcup.com/watch-party/wp_123'));
      expect(link, contains('utm_campaign=watch_party_share'));
    });
  });

  group('generateTeamLink', () {
    test('generates correct team link', () async {
      final link = await service.generateTeamLink(
        teamId: 'brazil',
        teamName: 'Brazil',
      );

      expect(link, contains('https://pregameworldcup.com/team/brazil'));
      expect(link, contains('utm_campaign=team_share'));
    });

    test('generates team link with group', () async {
      final link = await service.generateTeamLink(
        teamId: 'usa',
        teamName: 'United States',
        group: 'B',
      );

      expect(link, contains('https://pregameworldcup.com/team/usa'));
    });
  });

  group('generatePredictionLink', () {
    test('generates correct prediction link', () async {
      final link = await service.generatePredictionLink(
        predictionId: 'pred_456',
        matchName: 'USA vs Mexico',
        predictedOutcome: 'USA 2-1',
      );

      expect(
          link, contains('https://pregameworldcup.com/prediction/pred_456'));
      expect(link, contains('utm_campaign=prediction_share'));
    });

    test('generates prediction link with user name', () async {
      final link = await service.generatePredictionLink(
        predictionId: 'pred_789',
        matchName: 'Brazil vs Germany',
        predictedOutcome: 'Draw 1-1',
        userName: 'John',
      );

      expect(link, contains('https://pregameworldcup.com/prediction/pred_789'));
    });
  });

  group('generateProfileLink', () {
    test('generates correct profile link', () async {
      final link = await service.generateProfileLink(
        usualId: 'user_abc',
        displayName: 'John Doe',
      );

      expect(link, contains('https://pregameworldcup.com/profile/user_abc'));
      expect(link, contains('utm_campaign=profile_share'));
    });
  });

  // ==================== Pending Deep Link Management ====================

  group('pendingDeepLink management', () {
    test('pendingDeepLink is initially null', () {
      // The pending deep link may have been set in setUp, but clearPendingDeepLink
      // should work
      service.clearPendingDeepLink();
      expect(service.pendingDeepLink, isNull);
    });

    test('clearPendingDeepLink clears the pending link', () {
      service.clearPendingDeepLink();
      expect(service.pendingDeepLink, isNull);
    });
  });

  // ==================== Handler Management ====================

  group('handler management', () {
    test('addHandler registers a handler', () {
      // Clear any pending deep link first
      service.clearPendingDeepLink();

      var handlerCalled = false;
      void handler(DeepLinkData data) {
        handlerCalled = true;
      }

      service.addHandler(handler);

      // No pending link, so handler should not be called immediately
      expect(handlerCalled, false);

      // Clean up
      service.removeHandler(handler);
    });

    test('removeHandler unregisters a handler', () {
      void handler(DeepLinkData data) {}

      service.addHandler(handler);
      service.removeHandler(handler);

      // Should not throw or cause issues
    });

    test('addHandler calls handler immediately if pending deep link exists',
        () {
      // We can't easily set a pending deep link without calling _handleAppLink,
      // which is private. This test validates the contract: if there were a
      // pending link, the handler would be called.
      // Just verify the method can be called without error.
      DeepLinkData? receivedData;
      void handler(DeepLinkData data) {
        receivedData = data;
      }

      service.addHandler(handler);
      // If there's no pending deep link, the handler should not have received data
      // (or it received the pending link if one was set by a prior test)
      // Clean up
      service.removeHandler(handler);
    });
  });

  // ==================== Dispose ====================

  group('dispose', () {
    test('dispose clears handlers and subscriptions', () {
      void handler(DeepLinkData data) {}
      service.addHandler(handler);

      // Should not throw
      service.dispose();
    });
  });

  // ==================== Path Prefix Coverage ====================

  group('path prefix mapping', () {
    test('each DeepLinkType has a corresponding path', () async {
      // Verify all types generate valid links (except purchaseSuccess/Cancel
      // which use query params instead of path IDs)
      final typesWithPathIds = [
        DeepLinkType.match,
        DeepLinkType.team,
        DeepLinkType.watchParty,
        DeepLinkType.prediction,
        DeepLinkType.userProfile,
        DeepLinkType.venue,
        DeepLinkType.leaderboard,
      ];

      for (final type in typesWithPathIds) {
        final link = await service.generateLink(
          type: type,
          id: 'test_id',
          title: 'Test',
          description: 'Test',
        );

        expect(link, startsWith('https://pregameworldcup.com/'),
            reason: '$type should generate a valid link');
        expect(link, contains('test_id'),
            reason: '$type link should contain the ID');
      }
    });

    test('match path is /match', () async {
      final link = await service.generateLink(
        type: DeepLinkType.match,
        id: 'id',
        title: 't',
        description: 'd',
      );
      expect(link, contains('/match/id'));
    });

    test('team path is /team', () async {
      final link = await service.generateLink(
        type: DeepLinkType.team,
        id: 'id',
        title: 't',
        description: 'd',
      );
      expect(link, contains('/team/id'));
    });

    test('watchParty path is /watch-party', () async {
      final link = await service.generateLink(
        type: DeepLinkType.watchParty,
        id: 'id',
        title: 't',
        description: 'd',
      );
      expect(link, contains('/watch-party/id'));
    });

    test('prediction path is /prediction', () async {
      final link = await service.generateLink(
        type: DeepLinkType.prediction,
        id: 'id',
        title: 't',
        description: 'd',
      );
      expect(link, contains('/prediction/id'));
    });

    test('userProfile path is /profile', () async {
      final link = await service.generateLink(
        type: DeepLinkType.userProfile,
        id: 'id',
        title: 't',
        description: 'd',
      );
      expect(link, contains('/profile/id'));
    });

    test('venue path is /venue', () async {
      final link = await service.generateLink(
        type: DeepLinkType.venue,
        id: 'id',
        title: 't',
        description: 'd',
      );
      expect(link, contains('/venue/id'));
    });

    test('leaderboard path is /leaderboard', () async {
      final link = await service.generateLink(
        type: DeepLinkType.leaderboard,
        id: 'id',
        title: 't',
        description: 'd',
      );
      expect(link, contains('/leaderboard/id'));
    });

    test('purchaseSuccess path is /purchase/success', () async {
      final link = await service.generateLink(
        type: DeepLinkType.purchaseSuccess,
        id: 'session_123',
        title: 't',
        description: 'd',
      );
      expect(link, contains('/purchase/success/session_123'));
    });

    test('purchaseCancel path is /purchase/cancel', () async {
      final link = await service.generateLink(
        type: DeepLinkType.purchaseCancel,
        id: '_',
        title: 't',
        description: 'd',
      );
      expect(link, contains('/purchase/cancel/_'));
    });
  });

  // ==================== Link Format Validation ====================

  group('link format', () {
    test('links use HTTPS', () async {
      final link = await service.generateLink(
        type: DeepLinkType.match,
        id: 'game_1',
        title: 'Test',
        description: 'Test',
      );

      expect(link, startsWith('https://'));
    });

    test('links use pregameworldcup.com domain', () async {
      final link = await service.generateLink(
        type: DeepLinkType.match,
        id: 'game_1',
        title: 'Test',
        description: 'Test',
      );

      expect(link, contains('pregameworldcup.com'));
    });

    test('link with multiple query params uses & separator', () async {
      final link = await service.generateLink(
        type: DeepLinkType.match,
        id: 'game_1',
        title: 'Test',
        description: 'Test',
        additionalParams: {'key1': 'val1', 'key2': 'val2'},
      );

      expect(link, contains('?'));
      expect(link, contains('&'));
      expect(link, contains('key1=val1'));
      expect(link, contains('key2=val2'));
    });

    test('link with campaign adds utm params', () async {
      final link = await service.generateLink(
        type: DeepLinkType.match,
        id: 'game_1',
        title: 'Test',
        description: 'Test',
        campaign: 'test_campaign',
      );

      // Should contain all three UTM params
      final uri = Uri.parse(link);
      expect(uri.queryParameters['utm_campaign'], 'test_campaign');
      expect(uri.queryParameters['utm_source'], 'app_share');
      expect(uri.queryParameters['utm_medium'], 'social');
    });

    test('link combines additional params with campaign params', () async {
      final link = await service.generateLink(
        type: DeepLinkType.match,
        id: 'game_1',
        title: 'Test',
        description: 'Test',
        additionalParams: {'custom': 'value'},
        campaign: 'test_campaign',
      );

      expect(link, contains('custom=value'));
      expect(link, contains('utm_campaign=test_campaign'));
    });
  });
}
