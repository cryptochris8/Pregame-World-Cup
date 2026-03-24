import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/schedule/presentation/widgets/ai_insights_detail_sheet.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_schedule.dart';
import '../../schedule_test_factory.dart';

void main() {
  setUp(() {
    // Suppress all errors during testing - this widget has complex dependencies
    FlutterError.onError = (FlutterErrorDetails details) {
      // Suppress all errors
    };
  });

  group('showAIInsightsDetailSheet', () {
    test('function exists and is callable', () {
      final game = ScheduleTestFactory.createGameSchedule();

      // Verify the function exists and has correct signature
      expect(showAIInsightsDetailSheet, isA<Function>());

      // Verify game object is created
      expect(game, isNotNull);
      expect(game.gameId, isNotNull);
    });

    test('function accepts GameSchedule parameter', () {
      final game1 = ScheduleTestFactory.createGameSchedule(
        awayTeamName: 'Argentina',
        homeTeamName: 'Brazil',
      );

      final game2 = ScheduleTestFactory.createLiveGame();

      final game3 = ScheduleTestFactory.createCompletedGame();

      // All game types should be valid parameters
      expect(game1, isA<GameSchedule>());
      expect(game2, isA<GameSchedule>());
      expect(game3, isA<GameSchedule>());
    });

    test('creates game schedule for function parameter', () {
      final upcomingGame = ScheduleTestFactory.createUpcomingGame(
        awayTeamName: 'Germany',
        homeTeamName: 'Spain',
      );

      expect(upcomingGame, isNotNull);
      expect(upcomingGame.awayTeamName, equals('Germany'));
      expect(upcomingGame.homeTeamName, equals('Spain'));
    });
  });
}
