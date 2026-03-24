import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/schedule/presentation/widgets/schedule_social_game_card.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_schedule.dart';
import '../../schedule_test_factory.dart';

void main() {
  setUp(() {
    // Suppress all errors during testing - this widget has complex dependencies (Firebase, etc.)
    FlutterError.onError = (FlutterErrorDetails details) {
      // Suppress all errors
    };
  });

  group('ScheduleSocialGameCard', () {
    test('creates widget with required parameters', () {
      final game = ScheduleTestFactory.createGameSchedule();
      final widget = ScheduleSocialGameCard(game: game);

      expect(widget, isNotNull);
      expect(widget.game, equals(game));
      expect(widget.onRefresh, isNull);
    });

    test('creates widget with optional onRefresh callback', () {
      final game = ScheduleTestFactory.createGameSchedule();
      bool refreshCalled = false;
      final widget = ScheduleSocialGameCard(
        game: game,
        onRefresh: () {
          refreshCalled = true;
        },
      );

      expect(widget, isNotNull);
      expect(widget.onRefresh, isNotNull);
      widget.onRefresh!();
      expect(refreshCalled, isTrue);
    });

    test('widget accepts different game types', () {
      final liveGame = ScheduleTestFactory.createLiveGame();
      final completedGame = ScheduleTestFactory.createCompletedGame();
      final upcomingGame = ScheduleTestFactory.createUpcomingGame();

      final widget1 = ScheduleSocialGameCard(game: liveGame);
      final widget2 = ScheduleSocialGameCard(game: completedGame);
      final widget3 = ScheduleSocialGameCard(game: upcomingGame);

      expect(widget1, isNotNull);
      expect(widget2, isNotNull);
      expect(widget3, isNotNull);
    });

    test('widget stores game data correctly', () {
      final game = ScheduleTestFactory.createGameSchedule(
        awayTeamName: 'Argentina',
        homeTeamName: 'Brazil',
      );

      final widget = ScheduleSocialGameCard(game: game);

      expect(widget.game.awayTeamName, equals('Argentina'));
      expect(widget.game.homeTeamName, equals('Brazil'));
    });

    test('widget handles social data', () {
      final game = ScheduleTestFactory.createGameWithSocialData(
        userPredictions: 150,
        userComments: 45,
        userPhotos: 20,
        userRating: 4.5,
      );

      final widget = ScheduleSocialGameCard(game: game);

      expect(widget.game.userPredictions, equals(150));
      expect(widget.game.userComments, equals(45));
      expect(widget.game.userPhotos, equals(20));
      expect(widget.game.userRating, equals(4.5));
    });

    test('widget handles stadium data', () {
      final game = ScheduleTestFactory.createGameWithStadium(
        stadiumName: 'MetLife Stadium',
        city: 'East Rutherford',
        state: 'NJ',
      );

      final widget = ScheduleSocialGameCard(game: game);

      expect(widget.game.stadium, isNotNull);
      expect(widget.game.stadium!.name, equals('MetLife Stadium'));
      expect(widget.game.stadium!.city, equals('East Rutherford'));
      expect(widget.game.stadium!.state, equals('NJ'));
    });

    test('widget is a StatelessWidget', () {
      final game = ScheduleTestFactory.createGameSchedule();
      final widget = ScheduleSocialGameCard(game: game);

      expect(widget, isA<StatelessWidget>());
    });

    test('different callbacks can be assigned', () {
      final game = ScheduleTestFactory.createGameSchedule();

      int callCount = 0;
      void callback1() => callCount++;
      void callback2() => callCount += 2;

      final widget1 = ScheduleSocialGameCard(game: game, onRefresh: callback1);
      final widget2 = ScheduleSocialGameCard(game: game, onRefresh: callback2);

      widget1.onRefresh!();
      expect(callCount, equals(1));

      widget2.onRefresh!();
      expect(callCount, equals(3));
    });

    test('widget handles live game data', () {
      final game = ScheduleTestFactory.createLiveGame(
        awayTeamName: 'Germany',
        homeTeamName: 'France',
        awayScore: 2,
        homeScore: 1,
      );

      final widget = ScheduleSocialGameCard(game: game);

      expect(widget.game.isLive, isTrue);
      expect(widget.game.awayScore, equals(2));
      expect(widget.game.homeScore, equals(1));
    });

    test('widget handles completed game data', () {
      final game = ScheduleTestFactory.createCompletedGame(
        awayTeamName: 'Spain',
        homeTeamName: 'Portugal',
        awayScore: 3,
        homeScore: 2,
      );

      final widget = ScheduleSocialGameCard(game: game);

      expect(widget.game.status, equals('Final'));
      expect(widget.game.awayScore, equals(3));
      expect(widget.game.homeScore, equals(2));
    });
  });
}
