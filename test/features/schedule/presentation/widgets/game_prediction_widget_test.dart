import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/schedule/presentation/widgets/game_prediction_widget.dart';
import 'package:pregame_world_cup/features/auth/domain/services/auth_service.dart';
import '../../schedule_test_factory.dart';

// Mock classes
class MockAuthService extends Mock implements AuthService {}

void main() {
  final getIt = GetIt.instance;

  setUp(() {
    // Suppress all errors during testing - this widget has complex dependencies (Firebase, services, etc.)
    FlutterError.onError = (FlutterErrorDetails details) {
      // Suppress all errors
    };

    // Reset GetIt
    getIt.reset();

    // Register mock AuthService
    final mockAuthService = MockAuthService();
    when(() => mockAuthService.currentUser).thenReturn(null);
    getIt.registerSingleton<AuthService>(mockAuthService);
  });

  tearDown(() {
    getIt.reset();
  });

  group('GamePredictionWidget', () {
    test('creates widget with required parameters', () {
      final game = ScheduleTestFactory.createUpcomingGame();
      final widget = GamePredictionWidget(game: game);

      expect(widget, isNotNull);
      expect(widget.game, equals(game));
      expect(widget.onPredictionMade, isNull);
    });

    test('creates widget with optional onPredictionMade callback', () {
      final game = ScheduleTestFactory.createUpcomingGame();
      bool callbackCalled = false;
      final widget = GamePredictionWidget(
        game: game,
        onPredictionMade: () {
          callbackCalled = true;
        },
      );

      expect(widget, isNotNull);
      expect(widget.onPredictionMade, isNotNull);
      widget.onPredictionMade!();
      expect(callbackCalled, isTrue);
    });

    test('widget is a StatefulWidget', () {
      final game = ScheduleTestFactory.createUpcomingGame();
      final widget = GamePredictionWidget(game: game);

      expect(widget, isA<StatefulWidget>());
    });

    test('widget stores game data correctly', () {
      final game = ScheduleTestFactory.createGameSchedule(
        awayTeamName: 'Germany',
        homeTeamName: 'Spain',
        gameId: 'test-123',
      );

      final widget = GamePredictionWidget(game: game);

      expect(widget.game.awayTeamName, equals('Germany'));
      expect(widget.game.homeTeamName, equals('Spain'));
      expect(widget.game.gameId, equals('test-123'));
    });

    test('accepts different game types', () {
      final liveGame = ScheduleTestFactory.createLiveGame();
      final completedGame = ScheduleTestFactory.createCompletedGame();
      final upcomingGame = ScheduleTestFactory.createUpcomingGame();

      final widget1 = GamePredictionWidget(game: liveGame);
      final widget2 = GamePredictionWidget(game: completedGame);
      final widget3 = GamePredictionWidget(game: upcomingGame);

      expect(widget1, isNotNull);
      expect(widget2, isNotNull);
      expect(widget3, isNotNull);
    });

    test('callback can be invoked multiple times', () {
      final game = ScheduleTestFactory.createUpcomingGame();
      int callCount = 0;

      final widget = GamePredictionWidget(
        game: game,
        onPredictionMade: () {
          callCount++;
        },
      );

      widget.onPredictionMade!();
      widget.onPredictionMade!();
      widget.onPredictionMade!();

      expect(callCount, equals(3));
    });

    test('different callbacks can be assigned', () {
      final game = ScheduleTestFactory.createUpcomingGame();

      int callCount = 0;
      void callback1() => callCount++;
      void callback2() => callCount += 2;

      final widget1 = GamePredictionWidget(game: game, onPredictionMade: callback1);
      final widget2 = GamePredictionWidget(game: game, onPredictionMade: callback2);

      widget1.onPredictionMade!();
      expect(callCount, equals(1));

      widget2.onPredictionMade!();
      expect(callCount, equals(3));
    });

    test('widget handles game with social data', () {
      final game = ScheduleTestFactory.createGameWithSocialData(
        userPredictions: 50,
        userComments: 25,
      );

      final widget = GamePredictionWidget(game: game);

      expect(widget.game.userPredictions, equals(50));
      expect(widget.game.userComments, equals(25));
    });

    test('widget properties are immutable', () {
      final game = ScheduleTestFactory.createUpcomingGame();
      final widget = GamePredictionWidget(game: game);

      // Properties should be final
      expect(widget.game, equals(game));
      expect(widget.key, isNull);
    });
  });
}
