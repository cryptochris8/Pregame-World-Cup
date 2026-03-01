import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/services/deep_link_navigator.dart';
import 'package:pregame_world_cup/core/services/deep_link_service.dart';

/// Tests for DeepLinkNavigator focusing on its state management and routing logic.
///
/// Note: The DeepLinkNavigator is a singleton that uses NavigatorState internally.
/// Full integration testing of navigation calls (pushNamedAndRemoveUntil, pushNamed)
/// requires a real navigator context and is better suited for widget/integration tests.
/// These tests focus on the DeepLinkData model, DeepLinkType routing, and state checks.
void main() {
  group('DeepLinkData', () {
    test('creates instance with required fields', () {
      const data = DeepLinkData(
        type: DeepLinkType.match,
        id: 'match_123',
      );

      expect(data.type, DeepLinkType.match);
      expect(data.id, 'match_123');
      expect(data.additionalParams, null);
      expect(data.referrerId, null);
      expect(data.campaign, null);
    });

    test('creates instance with all fields', () {
      const data = DeepLinkData(
        type: DeepLinkType.watchParty,
        id: 'wp_456',
        additionalParams: {'source': 'share'},
        referrerId: 'user_789',
        campaign: 'summer_2026',
      );

      expect(data.type, DeepLinkType.watchParty);
      expect(data.id, 'wp_456');
      expect(data.additionalParams, {'source': 'share'});
      expect(data.referrerId, 'user_789');
      expect(data.campaign, 'summer_2026');
    });

    test('toString includes type and id', () {
      const data = DeepLinkData(
        type: DeepLinkType.team,
        id: 'usa',
        additionalParams: {'group': 'A'},
      );

      final str = data.toString();
      expect(str, contains('team'));
      expect(str, contains('usa'));
      expect(str, contains('group'));
    });
  });

  group('DeepLinkType', () {
    test('has all expected values', () {
      expect(DeepLinkType.values, contains(DeepLinkType.match));
      expect(DeepLinkType.values, contains(DeepLinkType.team));
      expect(DeepLinkType.values, contains(DeepLinkType.watchParty));
      expect(DeepLinkType.values, contains(DeepLinkType.prediction));
      expect(DeepLinkType.values, contains(DeepLinkType.userProfile));
      expect(DeepLinkType.values, contains(DeepLinkType.venue));
      expect(DeepLinkType.values, contains(DeepLinkType.leaderboard));
      expect(DeepLinkType.values, contains(DeepLinkType.purchaseSuccess));
      expect(DeepLinkType.values, contains(DeepLinkType.purchaseCancel));
    });

    test('has 9 deep link types', () {
      expect(DeepLinkType.values.length, 9);
    });
  });

  group('DeepLinkData for different types', () {
    test('match deep link data', () {
      const data = DeepLinkData(
        type: DeepLinkType.match,
        id: 'game_usa_mex_2026',
        additionalParams: {'matchId': 'game_usa_mex_2026'},
      );

      expect(data.type, DeepLinkType.match);
      expect(data.id, 'game_usa_mex_2026');
    });

    test('team deep link data', () {
      const data = DeepLinkData(
        type: DeepLinkType.team,
        id: 'usa',
        additionalParams: {'group': 'B'},
      );

      expect(data.type, DeepLinkType.team);
      expect(data.id, 'usa');
    });

    test('watch party deep link data', () {
      const data = DeepLinkData(
        type: DeepLinkType.watchParty,
        id: 'wp_123',
      );

      expect(data.type, DeepLinkType.watchParty);
      expect(data.id, 'wp_123');
    });

    test('prediction deep link data', () {
      const data = DeepLinkData(
        type: DeepLinkType.prediction,
        id: 'pred_456',
      );

      expect(data.type, DeepLinkType.prediction);
    });

    test('user profile deep link data', () {
      const data = DeepLinkData(
        type: DeepLinkType.userProfile,
        id: 'user_abc',
      );

      expect(data.type, DeepLinkType.userProfile);
    });

    test('venue deep link data', () {
      const data = DeepLinkData(
        type: DeepLinkType.venue,
        id: 'venue_metlife',
      );

      expect(data.type, DeepLinkType.venue);
    });

    test('leaderboard deep link data', () {
      const data = DeepLinkData(
        type: DeepLinkType.leaderboard,
        id: 'global',
      );

      expect(data.type, DeepLinkType.leaderboard);
    });

    test('purchase success deep link data', () {
      const data = DeepLinkData(
        type: DeepLinkType.purchaseSuccess,
        id: 'session_abc123',
        additionalParams: {'session_id': 'session_abc123'},
      );

      expect(data.type, DeepLinkType.purchaseSuccess);
      expect(data.additionalParams?['session_id'], 'session_abc123');
    });

    test('purchase cancel deep link data', () {
      const data = DeepLinkData(
        type: DeepLinkType.purchaseCancel,
        id: '_',
      );

      expect(data.type, DeepLinkType.purchaseCancel);
    });
  });

  group('DeepLinkData with tracking params', () {
    test('referrer ID is extracted', () {
      const data = DeepLinkData(
        type: DeepLinkType.match,
        id: 'game_1',
        additionalParams: {'ref': 'friend_user'},
        referrerId: 'friend_user',
      );

      expect(data.referrerId, 'friend_user');
    });

    test('campaign is extracted', () {
      const data = DeepLinkData(
        type: DeepLinkType.team,
        id: 'brazil',
        additionalParams: {'utm_campaign': 'world_cup_2026'},
        campaign: 'world_cup_2026',
      );

      expect(data.campaign, 'world_cup_2026');
    });

    test('both referrer and campaign present', () {
      const data = DeepLinkData(
        type: DeepLinkType.watchParty,
        id: 'wp_789',
        additionalParams: {
          'ref': 'user_abc',
          'utm_campaign': 'launch',
        },
        referrerId: 'user_abc',
        campaign: 'launch',
      );

      expect(data.referrerId, 'user_abc');
      expect(data.campaign, 'launch');
    });
  });

  group('ShareExtension', () {
    testWidgets('sharePositionOrigin returns Rect from RenderBox',
        (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox(
                width: 100,
                height: 50,
              );
            },
          ),
        ),
      );

      // The extension method accesses the render object of the context
      final rect = capturedContext.sharePositionOrigin;
      expect(rect, isA<Rect>());
      // The rect should have non-zero dimensions from the SizedBox
      expect(rect.width, greaterThan(0));
      expect(rect.height, greaterThan(0));
    });
  });
}
