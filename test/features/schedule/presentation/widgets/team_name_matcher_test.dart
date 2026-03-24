import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/schedule/presentation/widgets/team_name_matcher.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_schedule.dart';
import '../../schedule_test_factory.dart';

void main() {
  group('TeamNameMatcher', () {
    group('isTeamInFavorites', () {
      test('returns true for direct match', () {
        final favorites = ['Brazil', 'Argentina', 'Germany'];
        expect(TeamNameMatcher.isTeamInFavorites('Brazil', favorites), true);
        expect(TeamNameMatcher.isTeamInFavorites('Argentina', favorites), true);
      });

      test('returns true for USA alias matches', () {
        final favoritesWithFullName = ['United States'];
        expect(TeamNameMatcher.isTeamInFavorites('United States', favoritesWithFullName), true);

        final favoritesWithAlias = ['USA'];
        expect(TeamNameMatcher.isTeamInFavorites('USA', favoritesWithAlias), true);
        expect(TeamNameMatcher.isTeamInFavorites('United States', favoritesWithAlias), true);
        expect(TeamNameMatcher.isTeamInFavorites('USMNT', favoritesWithAlias), true);
      });

      test('returns true for Netherlands/Holland alias matches', () {
        final favoritesNetherlands = ['Netherlands'];
        expect(TeamNameMatcher.isTeamInFavorites('Holland', favoritesNetherlands), true);
        expect(TeamNameMatcher.isTeamInFavorites('Oranje', favoritesNetherlands), true);

        final favoritesHolland = ['Holland'];
        expect(TeamNameMatcher.isTeamInFavorites('Netherlands', favoritesHolland), true);
      });

      test('returns true for England/Three Lions alias match', () {
        final favoritesEngland = ['England'];
        expect(TeamNameMatcher.isTeamInFavorites('Three Lions', favoritesEngland), true);

        final favoritesThreeLions = ['Three Lions'];
        expect(TeamNameMatcher.isTeamInFavorites('England', favoritesThreeLions), true);
      });

      test('returns true for Mexico/El Tri alias match', () {
        final favoritesMexico = ['Mexico'];
        expect(TeamNameMatcher.isTeamInFavorites('El Tri', favoritesMexico), true);

        final favoritesElTri = ['El Tri'];
        expect(TeamNameMatcher.isTeamInFavorites('Mexico', favoritesElTri), true);
      });

      test('returns true for Brazil/Selecao alias match', () {
        final favoritesBrazil = ['Brazil'];
        expect(TeamNameMatcher.isTeamInFavorites('Selecao', favoritesBrazil), true);
      });

      test('returns false when team not in favorites', () {
        final favorites = ['Brazil', 'Argentina'];
        expect(TeamNameMatcher.isTeamInFavorites('Germany', favorites), false);
        expect(TeamNameMatcher.isTeamInFavorites('Spain', favorites), false);
      });

      test('returns false for empty favorites list', () {
        final favorites = <String>[];
        expect(TeamNameMatcher.isTeamInFavorites('Brazil', favorites), false);
      });

      test('is case insensitive', () {
        final favorites = ['brazil', 'ARGENTINA', 'GeRmAnY'];
        expect(TeamNameMatcher.isTeamInFavorites('Brazil', favorites), true);
        expect(TeamNameMatcher.isTeamInFavorites('argentina', favorites), true);
        expect(TeamNameMatcher.isTeamInFavorites('germany', favorites), true);
      });
    });

    group('isFavoriteTeamGame', () {
      test('returns true when home team is in favorites', () {
        final game = ScheduleTestFactory.createGameSchedule(
          homeTeamName: 'Brazil',
          awayTeamName: 'Argentina',
        );
        final favorites = ['Brazil'];
        expect(TeamNameMatcher.isFavoriteTeamGame(game, favorites), true);
      });

      test('returns true when away team is in favorites', () {
        final game = ScheduleTestFactory.createGameSchedule(
          homeTeamName: 'Brazil',
          awayTeamName: 'Argentina',
        );
        final favorites = ['Argentina'];
        expect(TeamNameMatcher.isFavoriteTeamGame(game, favorites), true);
      });

      test('returns true when both teams are in favorites', () {
        final game = ScheduleTestFactory.createGameSchedule(
          homeTeamName: 'Brazil',
          awayTeamName: 'Argentina',
        );
        final favorites = ['Brazil', 'Argentina'];
        expect(TeamNameMatcher.isFavoriteTeamGame(game, favorites), true);
      });

      test('returns true when home team matches via alias', () {
        final game = ScheduleTestFactory.createGameSchedule(
          homeTeamName: 'United States',
          awayTeamName: 'Mexico',
        );
        final favorites = ['USA'];
        expect(TeamNameMatcher.isFavoriteTeamGame(game, favorites), true);
      });

      test('returns true when away team matches via alias', () {
        final game = ScheduleTestFactory.createGameSchedule(
          homeTeamName: 'Germany',
          awayTeamName: 'Netherlands',
        );
        final favorites = ['Holland'];
        expect(TeamNameMatcher.isFavoriteTeamGame(game, favorites), true);
      });

      test('returns false when neither team is in favorites', () {
        final game = ScheduleTestFactory.createGameSchedule(
          homeTeamName: 'Brazil',
          awayTeamName: 'Argentina',
        );
        final favorites = ['Germany', 'Spain'];
        expect(TeamNameMatcher.isFavoriteTeamGame(game, favorites), false);
      });

      test('returns false for empty favorites list', () {
        final game = ScheduleTestFactory.createGameSchedule(
          homeTeamName: 'Brazil',
          awayTeamName: 'Argentina',
        );
        final favorites = <String>[];
        expect(TeamNameMatcher.isFavoriteTeamGame(game, favorites), false);
      });
    });

    group('teamNamesMatch', () {
      test('returns true for exact match', () {
        expect(TeamNameMatcher.teamNamesMatch('Brazil', 'Brazil'), true);
        expect(TeamNameMatcher.teamNamesMatch('Argentina', 'Argentina'), true);
      });

      test('returns true for case insensitive match', () {
        expect(TeamNameMatcher.teamNamesMatch('Brazil', 'brazil'), true);
        expect(TeamNameMatcher.teamNamesMatch('ARGENTINA', 'argentina'), true);
        expect(TeamNameMatcher.teamNamesMatch('GeRmAnY', 'germany'), true);
      });

      test('returns true for USA aliases', () {
        expect(TeamNameMatcher.teamNamesMatch('United States', 'USA'), true);
        expect(TeamNameMatcher.teamNamesMatch('USA', 'United States'), true);
        expect(TeamNameMatcher.teamNamesMatch('USMNT', 'USA'), true);
        expect(TeamNameMatcher.teamNamesMatch('USA', 'Stars and Stripes'), true);
      });

      test('returns true for Netherlands aliases', () {
        expect(TeamNameMatcher.teamNamesMatch('Netherlands', 'Holland'), true);
        expect(TeamNameMatcher.teamNamesMatch('Holland', 'Netherlands'), true);
        expect(TeamNameMatcher.teamNamesMatch('Oranje', 'Netherlands'), true);
      });

      test('returns true for England aliases', () {
        expect(TeamNameMatcher.teamNamesMatch('England', 'Three Lions'), true);
        expect(TeamNameMatcher.teamNamesMatch('Three Lions', 'England'), true);
      });

      test('returns true for France aliases', () {
        expect(TeamNameMatcher.teamNamesMatch('France', 'Les Bleus'), true);
      });

      test('returns true for Spain aliases', () {
        expect(TeamNameMatcher.teamNamesMatch('Spain', 'La Roja'), true);
      });

      test('returns true for Japan aliases', () {
        expect(TeamNameMatcher.teamNamesMatch('Japan', 'Samurai Blue'), true);
      });

      test('returns true for South Korea aliases', () {
        expect(TeamNameMatcher.teamNamesMatch('South Korea', 'Korea Republic'), true);
        expect(TeamNameMatcher.teamNamesMatch('South Korea', 'Taegeuk Warriors'), true);
      });

      test('returns true for Morocco aliases', () {
        expect(TeamNameMatcher.teamNamesMatch('Morocco', 'Atlas Lions'), true);
      });

      test('returns true for Croatia aliases', () {
        expect(TeamNameMatcher.teamNamesMatch('Croatia', 'Vatreni'), true);
      });

      test('returns false for non-matching teams', () {
        expect(TeamNameMatcher.teamNamesMatch('Brazil', 'Argentina'), false);
        expect(TeamNameMatcher.teamNamesMatch('Germany', 'Spain'), false);
        expect(TeamNameMatcher.teamNamesMatch('USA', 'Mexico'), false);
      });
    });
  });
}
