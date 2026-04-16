import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/data/services/enhanced_match_data_service.dart';

import '../../../chatbot/helpers/mock_knowledge_data.dart';

/// Tests that [EnhancedMatchDataService.initialize] completes without error
/// when loading JSON via the mock asset bundle.
///
/// This is in a separate file because `initialize()` mutates the singleton
/// and would break the "returns null when not initialized" tests in the main
/// test file.
void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupMockAssetBundle();
  });

  tearDownAll(() {
    tearDownMockAssetBundle();
  });

  group('EnhancedMatchDataService.initialize', () {
    test('completes without error', () async {
      final service = EnhancedMatchDataService.instance;
      await expectLater(service.initialize(), completes);
    });

    test('loads squad values after initialization', () {
      final service = EnhancedMatchDataService.instance;
      // USA is in the mock data
      final sv = service.getSquadValue('USA');
      expect(sv, isNotNull);
      expect(sv!['totalValueFormatted'], '\$500M');
    });

    test('loads betting odds after initialization', () {
      final service = EnhancedMatchDataService.instance;
      final odds = service.getBettingOdds('ARG');
      expect(odds, isNotNull);
      expect(odds!['odds_american'], '+700');
    });

    test('loads injury tracker after initialization', () {
      final service = EnhancedMatchDataService.instance;
      final injuries = service.getInjuryConcerns('USA');
      expect(injuries, isNotEmpty);
      expect(injuries.first['playerName'], 'Christian Pulisic');
    });

    test('loads recent form after initialization', () {
      final service = EnhancedMatchDataService.instance;
      final form = service.getRecentFormSummary('USA');
      expect(form, isNotNull);
      expect(form, contains('W'));
    });

    test('loads teams metadata after initialization', () {
      final service = EnhancedMatchDataService.instance;
      // teams_metadata not in mock, so getTeamConfederation returns null
      // but the service should still be initialized without error
      expect(service.getTeamConfederation('USA'), isNull);
    });

    test('loads elo ratings after initialization', () {
      final service = EnhancedMatchDataService.instance;
      final elo = service.getEloRating('ARG');
      expect(elo, isNotNull);
      expect(elo!['eloRating'], 2073);
    });

    test('second initialize call returns immediately', () async {
      final service = EnhancedMatchDataService.instance;
      // Should be a no-op since already initialized
      await expectLater(service.initialize(), completes);
    });
  });
}
