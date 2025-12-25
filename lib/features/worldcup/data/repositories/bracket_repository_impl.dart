import 'package:flutter/foundation.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/bracket_repository.dart';
import '../datasources/world_cup_firestore_datasource.dart';
import '../datasources/world_cup_cache_datasource.dart';

/// Implementation of BracketRepository
class BracketRepositoryImpl implements BracketRepository {
  final WorldCupFirestoreDataSource _firestoreDataSource;
  final WorldCupCacheDataSource _cacheDataSource;

  BracketRepositoryImpl({
    required WorldCupFirestoreDataSource firestoreDataSource,
    required WorldCupCacheDataSource cacheDataSource,
  })  : _firestoreDataSource = firestoreDataSource,
        _cacheDataSource = cacheDataSource;

  @override
  Future<WorldCupBracket> getBracket() async {
    try {
      // Try cache first
      final cached = await _cacheDataSource.getCachedBracket();
      if (cached != null) {
        debugPrint('Returning bracket from cache');
        return cached;
      }

      // Try Firestore
      final firestoreBracket = await _firestoreDataSource.getBracket();
      if (firestoreBracket != null) {
        await _cacheDataSource.cacheBracket(firestoreBracket);
        debugPrint('Returning bracket from Firestore');
        return firestoreBracket;
      }

      // Return empty bracket
      return const WorldCupBracket();
    } catch (e) {
      debugPrint('Error getting bracket: $e');
      return await _cacheDataSource.getCachedBracket() ?? const WorldCupBracket();
    }
  }

  @override
  Future<List<BracketMatch>> getMatchesByStage(MatchStage stage) async {
    try {
      final bracket = await getBracket();
      return bracket.getMatchesByStage(stage);
    } catch (e) {
      debugPrint('Error getting matches by stage: $e');
      return [];
    }
  }

  @override
  Future<BracketMatch?> getBracketMatchById(String matchId) async {
    try {
      final bracket = await getBracket();
      return bracket.getMatchById(matchId);
    } catch (e) {
      debugPrint('Error getting bracket match by ID: $e');
      return null;
    }
  }

  @override
  Future<List<BracketMatch>> getTeamKnockoutPath(String teamCode) async {
    try {
      final bracket = await getBracket();
      final path = <BracketMatch>[];

      for (final match in bracket.allMatches) {
        if (match.homeSlot.teamCode == teamCode ||
            match.awaySlot.teamCode == teamCode) {
          path.add(match);
        }
      }

      // Sort by stage order
      path.sort((a, b) {
        final stageOrder = {
          MatchStage.roundOf32: 0,
          MatchStage.roundOf16: 1,
          MatchStage.quarterFinal: 2,
          MatchStage.semiFinal: 3,
          MatchStage.thirdPlace: 4,
          MatchStage.final_: 5,
        };
        return (stageOrder[a.stage] ?? 0).compareTo(stageOrder[b.stage] ?? 0);
      });

      return path;
    } catch (e) {
      debugPrint('Error getting team knockout path: $e');
      return [];
    }
  }

  @override
  Future<List<BracketMatch>> getUpcomingKnockoutMatches({int limit = 8}) async {
    try {
      final bracket = await getBracket();
      final upcoming = bracket.allMatches
          .where((m) => m.status == MatchStatus.scheduled && m.dateTime != null)
          .toList();

      upcoming.sort((a, b) => a.dateTime!.compareTo(b.dateTime!));
      return upcoming.take(limit).toList();
    } catch (e) {
      debugPrint('Error getting upcoming knockout matches: $e');
      return [];
    }
  }

  @override
  Future<List<BracketMatch>> getLiveKnockoutMatches() async {
    try {
      final bracket = await getBracket();
      return bracket.liveMatches;
    } catch (e) {
      debugPrint('Error getting live knockout matches: $e');
      return [];
    }
  }

  @override
  Future<List<BracketMatch>> getCompletedKnockoutMatches() async {
    try {
      final bracket = await getBracket();
      return bracket.allMatches
          .where((m) => m.isComplete)
          .toList();
    } catch (e) {
      debugPrint('Error getting completed knockout matches: $e');
      return [];
    }
  }

  @override
  Future<BracketMatch?> getNextMatch(String matchId) async {
    try {
      final match = await getBracketMatchById(matchId);
      if (match?.advancesToSlotId == null) return null;

      final bracket = await getBracket();
      return bracket.allMatches.firstWhere(
        (m) => m.homeSlot.slotId == match!.advancesToSlotId ||
               m.awaySlot.slotId == match.advancesToSlotId,
      );
    } catch (e) {
      debugPrint('Error getting next match: $e');
      return null;
    }
  }

  @override
  Future<List<BracketMatch>> getSemiFinals() async {
    return getMatchesByStage(MatchStage.semiFinal);
  }

  @override
  Future<BracketMatch?> getFinalMatch() async {
    try {
      final bracket = await getBracket();
      return bracket.finalMatch;
    } catch (e) {
      debugPrint('Error getting final match: $e');
      return null;
    }
  }

  @override
  Future<BracketMatch?> getThirdPlaceMatch() async {
    try {
      final bracket = await getBracket();
      return bracket.thirdPlace;
    } catch (e) {
      debugPrint('Error getting third place match: $e');
      return null;
    }
  }

  @override
  Future<void> updateBracketMatch(BracketMatch match) async {
    try {
      final bracket = await getBracket();

      // Find and update the match in the appropriate stage
      List<BracketMatch> updateStage(List<BracketMatch> matches) {
        return matches.map((m) => m.matchId == match.matchId ? match : m).toList();
      }

      final updated = bracket.copyWith(
        roundOf32: updateStage(bracket.roundOf32),
        roundOf16: updateStage(bracket.roundOf16),
        quarterFinals: updateStage(bracket.quarterFinals),
        semiFinals: updateStage(bracket.semiFinals),
        thirdPlace: bracket.thirdPlace?.matchId == match.matchId
            ? match
            : bracket.thirdPlace,
        finalMatch: bracket.finalMatch?.matchId == match.matchId
            ? match
            : bracket.finalMatch,
        updatedAt: DateTime.now(),
      );

      await updateBracket(updated);
    } catch (e) {
      debugPrint('Error updating bracket match: $e');
      throw Exception('Failed to update bracket match: $e');
    }
  }

  @override
  Future<void> advanceTeam(String matchId, String winnerCode) async {
    try {
      final match = await getBracketMatchById(matchId);
      if (match == null || match.advancesToSlotId == null) return;

      final bracket = await getBracket();

      // Find the next match and update the appropriate slot
      WorldCupBracket updatedBracket = bracket;

      void updateNextMatch(List<BracketMatch> matches) {
        for (int i = 0; i < matches.length; i++) {
          final m = matches[i];
          if (m.homeSlot.slotId == match.advancesToSlotId) {
            // Update home slot with winner
            final winnerTeam = match.homeSlot.teamCode == winnerCode
                ? match.homeSlot
                : match.awaySlot;

            matches[i] = BracketMatch(
              matchId: m.matchId,
              matchNumber: m.matchNumber,
              stage: m.stage,
              matchNumberInStage: m.matchNumberInStage,
              homeSlot: winnerTeam.copyWith(
                slotId: m.homeSlot.slotId,
                isConfirmed: true,
                hasAdvanced: null,
              ),
              awaySlot: m.awaySlot,
              advancesToSlotId: m.advancesToSlotId,
              status: m.status,
              venueId: m.venueId,
              dateTime: m.dateTime,
            );
          } else if (m.awaySlot.slotId == match.advancesToSlotId) {
            // Update away slot with winner
            final winnerTeam = match.homeSlot.teamCode == winnerCode
                ? match.homeSlot
                : match.awaySlot;

            matches[i] = BracketMatch(
              matchId: m.matchId,
              matchNumber: m.matchNumber,
              stage: m.stage,
              matchNumberInStage: m.matchNumberInStage,
              homeSlot: m.homeSlot,
              awaySlot: winnerTeam.copyWith(
                slotId: m.awaySlot.slotId,
                isConfirmed: true,
                hasAdvanced: null,
              ),
              advancesToSlotId: m.advancesToSlotId,
              status: m.status,
              venueId: m.venueId,
              dateTime: m.dateTime,
            );
          }
        }
      }

      // Update the appropriate stage
      final r32 = List<BracketMatch>.from(bracket.roundOf32);
      final r16 = List<BracketMatch>.from(bracket.roundOf16);
      final qf = List<BracketMatch>.from(bracket.quarterFinals);
      final sf = List<BracketMatch>.from(bracket.semiFinals);

      updateNextMatch(r32);
      updateNextMatch(r16);
      updateNextMatch(qf);
      updateNextMatch(sf);

      updatedBracket = bracket.copyWith(
        roundOf32: r32,
        roundOf16: r16,
        quarterFinals: qf,
        semiFinals: sf,
        updatedAt: DateTime.now(),
      );

      await updateBracket(updatedBracket);
    } catch (e) {
      debugPrint('Error advancing team: $e');
      throw Exception('Failed to advance team: $e');
    }
  }

  @override
  Future<void> updateBracket(WorldCupBracket bracket) async {
    try {
      await _firestoreDataSource.saveBracket(bracket);
      await _cacheDataSource.cacheBracket(bracket);
    } catch (e) {
      debugPrint('Error updating bracket: $e');
      throw Exception('Failed to update bracket: $e');
    }
  }

  @override
  Future<WorldCupBracket> refreshBracket() async {
    try {
      debugPrint('Refreshing bracket from Firestore...');
      await clearCache();

      final bracket = await _firestoreDataSource.getBracket();
      if (bracket != null) {
        await _cacheDataSource.cacheBracket(bracket);
        return bracket;
      }

      return const WorldCupBracket();
    } catch (e) {
      debugPrint('Error refreshing bracket: $e');
      throw Exception('Failed to refresh bracket: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    await _cacheDataSource.clearCache('worldcup_bracket');
  }

  @override
  Stream<WorldCupBracket> watchBracket() {
    return _firestoreDataSource.watchBracket().map((b) => b ?? const WorldCupBracket());
  }

  @override
  Stream<BracketMatch?> watchBracketMatch(String matchId) {
    return watchBracket().map((bracket) => bracket.getMatchById(matchId));
  }
}
