import '../../domain/entities/entities.dart';
import '../../domain/repositories/national_team_repository.dart';
import '../datasources/world_cup_api_datasource.dart';
import '../datasources/world_cup_firestore_datasource.dart';
import '../datasources/world_cup_cache_datasource.dart';
import '../mock/world_cup_mock_data.dart';

/// Implementation of NationalTeamRepository
class NationalTeamRepositoryImpl implements NationalTeamRepository {
  final WorldCupApiDataSource _apiDataSource;
  final WorldCupFirestoreDataSource _firestoreDataSource;
  final WorldCupCacheDataSource _cacheDataSource;

  NationalTeamRepositoryImpl({
    required WorldCupApiDataSource apiDataSource,
    required WorldCupFirestoreDataSource firestoreDataSource,
    required WorldCupCacheDataSource cacheDataSource,
  })  : _apiDataSource = apiDataSource,
        _firestoreDataSource = firestoreDataSource,
        _cacheDataSource = cacheDataSource;

  @override
  Future<List<NationalTeam>> getAllTeams() async {
    try {
      // Try cache first
      final cached = await _cacheDataSource.getCachedTeams();
      if (cached != null && cached.isNotEmpty) {
        // Debug output removed
        return cached;
      }

      // Try Firestore
      try {
        final firestoreTeams = await _firestoreDataSource.getAllTeams();
        if (firestoreTeams.isNotEmpty) {
          await _cacheDataSource.cacheTeams(firestoreTeams);
          // Debug output removed
          return firestoreTeams;
        }
      } catch (e) {
        // Debug output removed
      }

      // Fetch from API
      try {
        final apiTeams = await refreshTeams();
        if (apiTeams.isNotEmpty) {
          return apiTeams;
        }
      } catch (e) {
        // Debug output removed
      }

      // Fallback to mock data for development/testing
      // Debug output removed
      final mockTeams = WorldCupMockData.teams;
      await _cacheDataSource.cacheTeams(mockTeams);
      return mockTeams;
    } catch (e) {
      // Debug output removed
      // Return mock data as final fallback
      return WorldCupMockData.teams;
    }
  }

  @override
  Future<List<NationalTeam>> getTeamsByConfederation(Confederation confederation) async {
    try {
      final allTeams = await getAllTeams();
      return allTeams.where((t) => t.confederation == confederation).toList();
    } catch (e) {
      // Debug output removed
      return [];
    }
  }

  @override
  Future<List<NationalTeam>> getTeamsByGroup(String groupLetter) async {
    try {
      final cached = await _cacheDataSource.getCachedTeamsByGroup(groupLetter);
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }

      return await _firestoreDataSource.getTeamsByGroup(groupLetter);
    } catch (e) {
      // Debug output removed
      return [];
    }
  }

  @override
  Future<NationalTeam?> getTeamByCode(String fifaCode) async {
    try {
      // Try cache first
      final cached = await _cacheDataSource.getCachedTeam(fifaCode);
      if (cached != null) {
        return cached;
      }

      return await _firestoreDataSource.getTeamByCode(fifaCode);
    } catch (e) {
      // Debug output removed
      return null;
    }
  }

  @override
  Future<List<NationalTeam>> getHostNations() async {
    try {
      final allTeams = await getAllTeams();
      return allTeams.where((t) => t.isHostNation).toList();
    } catch (e) {
      // Debug output removed
      return [];
    }
  }

  @override
  Future<List<NationalTeam>> getTeamsByRanking() async {
    try {
      final allTeams = await getAllTeams();
      final teamsWithRanking = allTeams.where((t) => t.fifaRanking != null).toList();
      teamsWithRanking.sort((a, b) => (a.fifaRanking ?? 999).compareTo(b.fifaRanking ?? 999));
      return teamsWithRanking;
    } catch (e) {
      // Debug output removed
      return [];
    }
  }

  @override
  Future<List<NationalTeam>> searchTeams(String query) async {
    try {
      final allTeams = await getAllTeams();
      final lowerQuery = query.toLowerCase();
      return allTeams.where((t) =>
        t.countryName.toLowerCase().contains(lowerQuery) ||
        t.shortName.toLowerCase().contains(lowerQuery) ||
        t.fifaCode.toLowerCase().contains(lowerQuery) ||
        (t.nickname?.toLowerCase().contains(lowerQuery) ?? false)
      ).toList();
    } catch (e) {
      // Debug output removed
      return [];
    }
  }

  @override
  Future<List<NationalTeam>> getPreviousChampions() async {
    try {
      final allTeams = await getAllTeams();
      return allTeams.where((t) => t.worldCupTitles > 0).toList()
        ..sort((a, b) => b.worldCupTitles.compareTo(a.worldCupTitles));
    } catch (e) {
      // Debug output removed
      return [];
    }
  }

  @override
  Future<void> updateTeam(NationalTeam team) async {
    try {
      await _firestoreDataSource.saveTeam(team);
      await _cacheDataSource.clearCache('worldcup_teams');
    } catch (e) {
      // Debug output removed
      throw Exception('Failed to update team: $e');
    }
  }

  @override
  Future<List<NationalTeam>> refreshTeams() async {
    try {
      // Debug output removed
      final apiTeams = await _apiDataSource.fetchAllTeams();

      if (apiTeams.isNotEmpty) {
        await _firestoreDataSource.saveTeams(apiTeams);
        await _cacheDataSource.cacheTeams(apiTeams);
        // Debug output removed
        return apiTeams;
      }

      return [];
    } catch (e) {
      // Debug output removed
      throw Exception('Failed to refresh teams: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    await _cacheDataSource.clearCache('worldcup_teams');
  }

  @override
  Stream<List<NationalTeam>> watchTeams() {
    return _firestoreDataSource.watchTeams();
  }

  @override
  Stream<NationalTeam?> watchTeam(String fifaCode) {
    return watchTeams().map((teams) {
      try {
        return teams.firstWhere(
          (t) => t.fifaCode.toUpperCase() == fifaCode.toUpperCase(),
        );
      } catch (_) {
        return null;
      }
    });
  }
}
