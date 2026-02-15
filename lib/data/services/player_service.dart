import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/player.dart';

/// Service for fetching player data from Firestore
class PlayerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'players';

  // Caching
  List<Player>? _allPlayersCache;
  DateTime? _cacheTimestamp;
  static const Duration _cacheDuration = Duration(minutes: 30);

  /// Get all players (260 players total)
  /// With optional pagination support
  Future<List<Player>> getAllPlayers({int? limit, int? offset}) async {
    try {
      // Check cache first if no pagination is used
      if (limit == null && offset == null && _isCacheValid()) {
        return _allPlayersCache!;
      }

      Query query = _firestore.collection(_collectionName);

      // Apply pagination if specified
      if (offset != null && offset > 0) {
        // For offset, we need to get all documents up to offset + limit
        // Then skip the first offset items
        // Note: This is not the most efficient approach for large offsets
        // For production, consider using startAfter with DocumentSnapshot
        final allDocs = await query
            .limit(offset + (limit ?? 50))
            .get();

        final players = allDocs.docs
            .skip(offset)
            .map((doc) => Player.fromFirestore(doc))
            .toList();

        // Sort locally
        players.sort((a, b) {
          final codeCompare = a.fifaCode.compareTo(b.fifaCode);
          if (codeCompare != 0) return codeCompare;
          return a.jerseyNumber.compareTo(b.jerseyNumber);
        });

        return players;
      } else if (limit != null) {
        query = query.limit(limit);
      }

      final QuerySnapshot snapshot = await query.get();

      final players = snapshot.docs
          .map((doc) => Player.fromFirestore(doc))
          .toList();

      // Sort locally by fifaCode then jerseyNumber (no index required)
      players.sort((a, b) {
        final codeCompare = a.fifaCode.compareTo(b.fifaCode);
        if (codeCompare != 0) return codeCompare;
        return a.jerseyNumber.compareTo(b.jerseyNumber);
      });

      // Cache all players if no pagination
      if (limit == null && offset == null) {
        _allPlayersCache = players;
        _cacheTimestamp = DateTime.now();
      }

      return players;
    } catch (e) {
      return [];
    }
  }

  /// Check if cache is valid
  bool _isCacheValid() {
    if (_allPlayersCache == null || _cacheTimestamp == null) {
      return false;
    }
    return DateTime.now().difference(_cacheTimestamp!) < _cacheDuration;
  }

  /// Clear cache (useful for refresh)
  void clearCache() {
    _allPlayersCache = null;
    _cacheTimestamp = null;
  }

  /// Get players by team (FIFA code)
  /// Returns 26 players per team
  Future<List<Player>> getPlayersByTeam(String fifaCode) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('fifaCode', isEqualTo: fifaCode)
          .get();

      final players = snapshot.docs
          .map((doc) => Player.fromFirestore(doc))
          .toList();

      // Sort locally by jersey number (no index required)
      players.sort((a, b) => a.jerseyNumber.compareTo(b.jerseyNumber));

      return players;
    } catch (e) {
      // Error handled silently
      return [];
    }
  }

  /// Get players by position
  Future<List<Player>> getPlayersByPosition(String position) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('position', isEqualTo: position)
          .orderBy('marketValue', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Player.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Error handled silently
      return [];
    }
  }

  /// Get players by position category (Defender, Midfielder, Forward, Goalkeeper)
  Future<List<Player>> getPlayersByCategory(String category, {int? limit, int? offset}) async {
    try {
      List<String> positions;

      switch (category.toLowerCase()) {
        case 'goalkeeper':
          positions = ['GK'];
          break;
        case 'defender':
          positions = ['CB', 'LB', 'RB', 'LWB', 'RWB'];
          break;
        case 'midfielder':
          positions = ['CDM', 'CM', 'CAM', 'LM', 'RM'];
          break;
        case 'forward':
          positions = ['LW', 'RW', 'ST', 'CF'];
          break;
        default:
          return [];
      }

      Query query = _firestore
          .collection(_collectionName)
          .where('position', whereIn: positions)
          .orderBy('marketValue', descending: true);

      // Apply pagination
      if (offset != null && offset > 0) {
        final allDocs = await query.limit(offset + (limit ?? 50)).get();
        return allDocs.docs
            .skip(offset)
            .map((doc) => Player.fromFirestore(doc))
            .toList();
      } else if (limit != null) {
        query = query.limit(limit);
      }

      final QuerySnapshot snapshot = await query.get();

      return snapshot.docs
          .map((doc) => Player.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Error handled silently
      return [];
    }
  }

  /// Get single player by ID
  Future<Player?> getPlayerById(String playerId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_collectionName)
          .doc(playerId)
          .get();

      if (doc.exists) {
        return Player.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      // Error handled silently
      return null;
    }
  }

  /// Get top players by market value
  /// Useful for showing the most valuable players in the tournament
  Future<List<Player>> getTopPlayersByValue({int limit = 20}) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('marketValue', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Player.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Error handled silently
      return [];
    }
  }

  /// Get top goal scorers (international goals)
  Future<List<Player>> getTopScorers({int limit = 20}) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('goals', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Player.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Error handled silently
      return [];
    }
  }

  /// Get most experienced players (by caps)
  Future<List<Player>> getMostCappedPlayers({int limit = 20}) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('caps', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Player.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Error handled silently
      return [];
    }
  }

  /// Get youngest players in the tournament
  Future<List<Player>> getYoungestPlayers({int limit = 20}) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('age')
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Player.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Error handled silently
      return [];
    }
  }

  /// Get oldest players in the tournament
  Future<List<Player>> getOldestPlayers({int limit = 20}) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('age', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Player.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Error handled silently
      return [];
    }
  }

  /// Get World Cup veterans (players with most World Cup appearances)
  Future<List<Player>> getWorldCupVeterans({int limit = 20}) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('worldCupAppearances', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Player.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Error handled silently
      return [];
    }
  }

  /// Get top World Cup goal scorers (career World Cup goals)
  Future<List<Player>> getWorldCupTopScorers({int limit = 20}) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('worldCupGoals', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Player.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Error handled silently
      return [];
    }
  }

  /// Get top World Cup assist providers (career World Cup assists)
  Future<List<Player>> getWorldCupTopAssists({int limit = 20}) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('worldCupAssists', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Player.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Error handled silently
      return [];
    }
  }

  /// Get top players by goals per World Cup appearance ratio
  Future<List<Player>> getWorldCupBestRatios({int limit = 20}) async {
    try {
      // Fetch players with World Cup experience
      final allPlayers = await getAllPlayers();

      // Filter to players with at least 3 World Cup appearances
      final wcPlayers = allPlayers
          .where((p) => p.worldCupAppearances >= 3 && p.worldCupGoals > 0)
          .toList();

      // Sort by goals per appearance ratio
      wcPlayers.sort((a, b) {
        final ratioA = a.worldCupGoals / a.worldCupAppearances;
        final ratioB = b.worldCupGoals / b.worldCupAppearances;
        return ratioB.compareTo(ratioA);
      });

      return wcPlayers.take(limit).toList();
    } catch (e) {
      // Error handled silently
      return [];
    }
  }

  /// Get players by club
  /// Useful for showing which clubs are most represented
  Future<List<Player>> getPlayersByClub(String club) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('club', isEqualTo: club)
          .orderBy('marketValue', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Player.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Error handled silently
      return [];
    }
  }

  /// Search players by name
  /// Note: Firestore doesn't support full-text search natively
  /// This is a simple implementation - for production, consider using Algolia or similar
  Future<List<Player>> searchPlayers(String query) async {
    try {
      // Get all players and filter locally
      // For better performance, implement server-side search
      final allPlayers = await getAllPlayers();

      final lowerQuery = query.toLowerCase();
      return allPlayers.where((player) {
        return player.fullName.toLowerCase().contains(lowerQuery) ||
               player.commonName.toLowerCase().contains(lowerQuery) ||
               player.club.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      // Error handled silently
      return [];
    }
  }

  /// Stream all players (real-time updates)
  Stream<List<Player>> streamAllPlayers() {
    return _firestore
        .collection(_collectionName)
        .orderBy('fifaCode')
        .orderBy('jerseyNumber')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Player.fromFirestore(doc))
            .toList());
  }

  /// Stream players by team (real-time updates)
  Stream<List<Player>> streamPlayersByTeam(String fifaCode) {
    return _firestore
        .collection(_collectionName)
        .where('fifaCode', isEqualTo: fifaCode)
        .orderBy('jerseyNumber')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Player.fromFirestore(doc))
            .toList());
  }

  /// Get player statistics summary
  Future<Map<String, dynamic>> getPlayerStatistics() async {
    try {
      final players = await getAllPlayers();

      return {
        'totalPlayers': players.length,
        'totalMarketValue': players.fold<int>(
          0,
          (acc, player) => acc + player.marketValue
        ),
        'averageAge': players.fold<double>(
          0,
          (acc, player) => acc + player.age
        ) / players.length,
        'totalGoals': players.fold<int>(
          0,
          (acc, player) => acc + player.goals
        ),
        'totalCaps': players.fold<int>(
          0,
          (acc, player) => acc + player.caps
        ),
        'playersByPosition': _groupPlayersByPosition(players),
      };
    } catch (e) {
      // Error handled silently
      return {};
    }
  }

  /// Helper: Group players by position
  Map<String, int> _groupPlayersByPosition(List<Player> players) {
    final Map<String, int> positionCounts = {};

    for (final player in players) {
      positionCounts[player.position] =
          (positionCounts[player.position] ?? 0) + 1;
    }

    return positionCounts;
  }
}
