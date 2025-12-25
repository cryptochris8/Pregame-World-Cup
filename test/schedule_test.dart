import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_schedule.dart';

void main() {
  group('Schedule Filtering Tests', () {
    test('should only include games from August 2025 onwards', () {
      // Create test games with different dates
      final julyGame = GameSchedule(
        gameId: 'july-game',
        awayTeamName: 'Team A',
        homeTeamName: 'Team B',
        dateTimeUTC: DateTime(2025, 7, 15), // July 2025 - should be excluded
      );
      
      final augustGame = GameSchedule(
        gameId: 'august-game',
        awayTeamName: 'Team C',
        homeTeamName: 'Team D',
        dateTimeUTC: DateTime(2025, 8, 1), // August 1, 2025 - should be included
      );
      
      final septemberGame = GameSchedule(
        gameId: 'september-game',
        awayTeamName: 'Team E',
        homeTeamName: 'Team F',
        dateTimeUTC: DateTime(2025, 9, 15), // September 2025 - should be included
      );
      
      final allGames = [julyGame, augustGame, septemberGame];
      
      // Filter to only include games from August 2025 onwards
      final augustStart = DateTime(2025, 8, 1);
      final filteredGames = allGames.where((game) {
        if (game.dateTimeUTC != null) {
          final gameDate = game.dateTimeUTC!;
          return gameDate.isAfter(augustStart) || gameDate.isAtSameMomentAs(augustStart);
        }
        return false;
      }).toList();
      
      // Verify the filtering worked correctly
      expect(filteredGames.length, equals(2));
      expect(filteredGames.any((game) => game.gameId == 'july-game'), isFalse);
      expect(filteredGames.any((game) => game.gameId == 'august-game'), isTrue);
      expect(filteredGames.any((game) => game.gameId == 'september-game'), isTrue);
    });
  });
} 