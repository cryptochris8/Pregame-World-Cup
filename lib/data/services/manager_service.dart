import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/manager.dart';

/// Service for fetching manager data from Firestore
class ManagerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'managers';

  // Caching
  List<Manager>? _allManagersCache;
  DateTime? _cacheTimestamp;
  static const Duration _cacheDuration = Duration(minutes: 30);

  /// Get all managers (48 managers total)
  /// With optional pagination support
  Future<List<Manager>> getAllManagers({int? limit, int? offset}) async {
    try {
      // Check cache first if no pagination is used
      if (limit == null && offset == null && _isCacheValid()) {
        return _allManagersCache!;
      }

      Query query = _firestore
          .collection(_collectionName)
          .orderBy('fifaCode');

      // Apply pagination if specified
      if (offset != null && offset > 0) {
        final allDocs = await query
            .limit(offset + (limit ?? 20))
            .get();

        return allDocs.docs
            .skip(offset)
            .map((doc) => Manager.fromFirestore(doc))
            .toList();
      } else if (limit != null) {
        query = query.limit(limit);
      }

      final QuerySnapshot snapshot = await query.get();

      final managers = snapshot.docs
          .map((doc) => Manager.fromFirestore(doc))
          .toList();

      // Cache all managers if no pagination
      if (limit == null && offset == null) {
        _allManagersCache = managers;
        _cacheTimestamp = DateTime.now();
      }

      return managers;
    } catch (e) {
      return [];
    }
  }

  /// Check if cache is valid
  bool _isCacheValid() {
    if (_allManagersCache == null || _cacheTimestamp == null) {
      return false;
    }
    return DateTime.now().difference(_cacheTimestamp!) < _cacheDuration;
  }

  /// Clear cache (useful for refresh)
  void clearCache() {
    _allManagersCache = null;
    _cacheTimestamp = null;
  }

  /// Get manager by team (FIFA code)
  Future<Manager?> getManagerByTeam(String fifaCode) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('fifaCode', isEqualTo: fifaCode)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Manager.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      // Error handled silently
      return null;
    }
  }

  /// Get single manager by ID
  Future<Manager?> getManagerById(String managerId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_collectionName)
          .doc(managerId)
          .get();

      if (doc.exists) {
        return Manager.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      // Error handled silently
      return null;
    }
  }

  /// Get most experienced managers (by years of experience)
  Future<List<Manager>> getMostExperiencedManagers({int limit = 10}) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('yearsOfExperience', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Manager.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Error handled silently
      return [];
    }
  }

  /// Get youngest managers
  Future<List<Manager>> getYoungestManagers({int limit = 10}) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('age')
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Manager.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Error handled silently
      return [];
    }
  }

  /// Get oldest managers
  Future<List<Manager>> getOldestManagers({int limit = 10}) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('age', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Manager.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Error handled silently
      return [];
    }
  }

  /// Get managers with highest win percentage
  Future<List<Manager>> getTopWinningManagers({int limit = 10}) async {
    try {
      final managers = await getAllManagers();

      // Sort by win percentage locally since we need to access nested field
      managers.sort((a, b) =>
          b.stats.winPercentage.compareTo(a.stats.winPercentage));

      return managers.take(limit).toList();
    } catch (e) {
      // Error handled silently
      return [];
    }
  }

  /// Get managers with most titles
  Future<List<Manager>> getMostSuccessfulManagers({int limit = 10}) async {
    try {
      final managers = await getAllManagers();

      // Sort by titles won locally
      managers.sort((a, b) =>
          b.stats.titlesWon.compareTo(a.stats.titlesWon));

      return managers.take(limit).toList();
    } catch (e) {
      // Error handled silently
      return [];
    }
  }

  /// Get managers with most matches managed
  Future<List<Manager>> getMostExperiencedByMatches({int limit = 10}) async {
    try {
      final managers = await getAllManagers();

      // Sort by matches managed locally
      managers.sort((a, b) =>
          b.stats.matchesManaged.compareTo(a.stats.matchesManaged));

      return managers.take(limit).toList();
    } catch (e) {
      // Error handled silently
      return [];
    }
  }

  /// Get managers by nationality
  Future<List<Manager>> getManagersByNationality(String nationality) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('nationality', isEqualTo: nationality)
          .get();

      return snapshot.docs
          .map((doc) => Manager.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Error handled silently
      return [];
    }
  }

  /// Get controversial managers (those with controversies)
  Future<List<Manager>> getControversialManagers() async {
    try {
      final managers = await getAllManagers();

      // Filter managers with controversies
      return managers.where((m) => m.isControversial).toList();
    } catch (e) {
      // Error handled silently
      return [];
    }
  }

  /// Search managers by name
  Future<List<Manager>> searchManagers(String query) async {
    try {
      // Get all managers and filter locally
      final allManagers = await getAllManagers();

      final lowerQuery = query.toLowerCase();
      return allManagers.where((manager) {
        return manager.fullName.toLowerCase().contains(lowerQuery) ||
               manager.commonName.toLowerCase().contains(lowerQuery) ||
               manager.currentTeam.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      // Error handled silently
      return [];
    }
  }

  /// Stream all managers (real-time updates)
  Stream<List<Manager>> streamAllManagers() {
    return _firestore
        .collection(_collectionName)
        .orderBy('fifaCode')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Manager.fromFirestore(doc))
            .toList());
  }

  /// Stream manager by team (real-time updates)
  Stream<Manager?> streamManagerByTeam(String fifaCode) {
    return _firestore
        .collection(_collectionName)
        .where('fifaCode', isEqualTo: fifaCode)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            return Manager.fromFirestore(snapshot.docs.first);
          }
          return null;
        });
  }

  /// Get manager statistics summary
  Future<Map<String, dynamic>> getManagerStatistics() async {
    try {
      final managers = await getAllManagers();

      return {
        'totalManagers': managers.length,
        'averageAge': managers.fold<double>(
          0,
          (acc, manager) => acc + manager.age
        ) / managers.length,
        'averageExperience': managers.fold<double>(
          0,
          (acc, manager) => acc + manager.yearsOfExperience
        ) / managers.length,
        'totalMatches': managers.fold<int>(
          0,
          (acc, manager) => acc + manager.stats.matchesManaged
        ),
        'totalTitles': managers.fold<int>(
          0,
          (acc, manager) => acc + manager.stats.titlesWon
        ),
        'averageWinPercentage': managers.fold<double>(
          0,
          (acc, manager) => acc + manager.stats.winPercentage
        ) / managers.length,
        'managersWithControversies': managers.where((m) => m.isControversial).length,
        'managersByNationality': _groupManagersByNationality(managers),
      };
    } catch (e) {
      // Error handled silently
      return {};
    }
  }

  /// Helper: Group managers by nationality
  Map<String, int> _groupManagersByNationality(List<Manager> managers) {
    final Map<String, int> nationalityCounts = {};

    for (final manager in managers) {
      nationalityCounts[manager.nationality] =
          (nationalityCounts[manager.nationality] ?? 0) + 1;
    }

    return nationalityCounts;
  }

  /// Get managers by tactical style
  Future<List<Manager>> getManagersByTacticalStyle(String style) async {
    try {
      final managers = await getAllManagers();

      // Simple contains search for tactical style
      return managers.where((manager) =>
          manager.tacticalStyle.toLowerCase().contains(style.toLowerCase()))
          .toList();
    } catch (e) {
      // Error handled silently
      return [];
    }
  }

  /// Get World Cup winning managers
  Future<List<Manager>> getWorldCupWinningManagers() async {
    try {
      final managers = await getAllManagers();

      // Filter managers with World Cup in their honors
      return managers.where((manager) =>
          manager.honors.any((honor) =>
              honor.toLowerCase().contains('world cup') &&
              !honor.toLowerCase().contains('runner') &&
              !honor.toLowerCase().contains('place')))
          .toList();
    } catch (e) {
      // Error handled silently
      return [];
    }
  }
}
