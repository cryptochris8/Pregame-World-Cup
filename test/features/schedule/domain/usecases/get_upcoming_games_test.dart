import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_schedule.dart';
import 'package:pregame_world_cup/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:pregame_world_cup/features/schedule/domain/usecases/get_upcoming_games.dart';

class MockScheduleRepository extends Mock implements ScheduleRepository {}

void main() {
  late MockScheduleRepository mockRepository;
  late GetUpcomingGames useCase;

  setUp(() {
    mockRepository = MockScheduleRepository();
    useCase = GetUpcomingGames(mockRepository);
  });

  final testGames = [
    GameSchedule(
      gameId: 'game_1',
      awayTeamName: 'Brazil',
      homeTeamName: 'Germany',
    ),
    GameSchedule(
      gameId: 'game_2',
      awayTeamName: 'Argentina',
      homeTeamName: 'France',
    ),
  ];

  group('GetUpcomingGames', () {
    test('calls repository with default limit', () async {
      when(() => mockRepository.getUpcomingGames(limit: 10))
          .thenAnswer((_) async => testGames);

      final result = await useCase();

      expect(result.length, equals(2));
      verify(() => mockRepository.getUpcomingGames(limit: 10)).called(1);
    });

    test('calls repository with custom limit', () async {
      when(() => mockRepository.getUpcomingGames(limit: 5))
          .thenAnswer((_) async => testGames);

      final result = await useCase(limit: 5);

      expect(result.length, equals(2));
      verify(() => mockRepository.getUpcomingGames(limit: 5)).called(1);
    });

    test('returns empty list when repository returns empty', () async {
      when(() => mockRepository.getUpcomingGames(limit: 10))
          .thenAnswer((_) async => []);

      final result = await useCase();

      expect(result, isEmpty);
    });

    test('propagates exception from repository', () async {
      when(() => mockRepository.getUpcomingGames(limit: 10))
          .thenThrow(Exception('API error'));

      expect(
        () => useCase(),
        throwsA(isA<Exception>()),
      );
    });

    test('returns games in order from repository', () async {
      final orderedGames = [
        GameSchedule(
          gameId: 'game_a',
          awayTeamName: 'USA',
          homeTeamName: 'Canada',
          dateTimeUTC: DateTime(2026, 6, 11, 18, 0),
        ),
        GameSchedule(
          gameId: 'game_b',
          awayTeamName: 'Mexico',
          homeTeamName: 'Jamaica',
          dateTimeUTC: DateTime(2026, 6, 12, 20, 0),
        ),
        GameSchedule(
          gameId: 'game_c',
          awayTeamName: 'Brazil',
          homeTeamName: 'Serbia',
          dateTimeUTC: DateTime(2026, 6, 13, 15, 0),
        ),
      ];

      when(() => mockRepository.getUpcomingGames(limit: 10))
          .thenAnswer((_) async => orderedGames);

      final result = await useCase();

      expect(result.length, equals(3));
      expect(result[0].gameId, equals('game_a'));
      expect(result[1].gameId, equals('game_b'));
      expect(result[2].gameId, equals('game_c'));
    });

    test('handles large limit value', () async {
      when(() => mockRepository.getUpcomingGames(limit: 1000))
          .thenAnswer((_) async => testGames);

      final result = await useCase(limit: 1000);

      expect(result, isNotNull);
      verify(() => mockRepository.getUpcomingGames(limit: 1000)).called(1);
    });
  });
}
