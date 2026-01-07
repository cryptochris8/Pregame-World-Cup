import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/logging_service.dart';
import '../entities/entities.dart';

class VenueEnhancementService {
  static const String _logTag = 'VenueEnhancementService';
  static const String _collection = 'venue_enhancements';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // In-memory cache
  final Map<String, VenueEnhancement> _cache = {};

  /// Get venue enhancement by venue ID
  Future<VenueEnhancement?> getVenueEnhancement(String venueId) async {
    try {
      // Check cache first
      if (_cache.containsKey(venueId)) {
        return _cache[venueId];
      }

      final doc = await _firestore.collection(_collection).doc(venueId).get();

      if (!doc.exists) {
        return null;
      }

      final enhancement = VenueEnhancement.fromFirestore(doc.data()!, doc.id);
      _cache[venueId] = enhancement;
      return enhancement;
    } catch (e) {
      LoggingService.error('Error getting venue enhancement: $e', tag: _logTag);
      return null;
    }
  }

  /// Save venue enhancement
  Future<bool> saveVenueEnhancement(VenueEnhancement enhancement) async {
    try {
      final updatedEnhancement = enhancement.copyWith(updatedAt: DateTime.now());

      await _firestore
          .collection(_collection)
          .doc(enhancement.venueId)
          .set(updatedEnhancement.toFirestore());

      _cache[enhancement.venueId] = updatedEnhancement;

      LoggingService.info(
        'Saved venue enhancement for ${enhancement.venueId}',
        tag: _logTag,
      );
      return true;
    } catch (e) {
      LoggingService.error('Error saving venue enhancement: $e', tag: _logTag);
      return false;
    }
  }

  /// Create new venue enhancement for a venue
  Future<VenueEnhancement?> createVenueEnhancement({
    required String venueId,
    SubscriptionTier tier = SubscriptionTier.free,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final enhancement = VenueEnhancement.create(
        venueId: venueId,
        ownerId: user.uid,
        tier: tier,
      );

      final success = await saveVenueEnhancement(enhancement);
      return success ? enhancement : null;
    } catch (e) {
      LoggingService.error('Error creating venue enhancement: $e', tag: _logTag);
      return null;
    }
  }

  /// Update shows matches toggle (FREE tier)
  Future<bool> updateShowsMatches(String venueId, bool showsMatches) async {
    try {
      final enhancement = await getVenueEnhancement(venueId);
      if (enhancement == null) return false;

      final updated = enhancement.copyWith(showsMatches: showsMatches);
      return saveVenueEnhancement(updated);
    } catch (e) {
      LoggingService.error('Error updating shows matches: $e', tag: _logTag);
      return false;
    }
  }

  /// Update broadcasting schedule (PREMIUM tier)
  Future<bool> updateBroadcastingSchedule(
    String venueId,
    List<String> matchIds,
  ) async {
    try {
      final enhancement = await getVenueEnhancement(venueId);
      if (enhancement == null || !enhancement.isPremium) {
        LoggingService.warning(
          'Cannot update broadcasting schedule - not premium or not found',
          tag: _logTag,
        );
        return false;
      }

      final schedule = BroadcastingSchedule(
        matchIds: matchIds,
        lastUpdated: DateTime.now(),
        autoSelectByTeam:
            enhancement.broadcastingSchedule?.autoSelectByTeam ?? [],
      );

      final updated = enhancement.copyWith(broadcastingSchedule: schedule);
      return saveVenueEnhancement(updated);
    } catch (e) {
      LoggingService.error('Error updating broadcasting schedule: $e', tag: _logTag);
      return false;
    }
  }

  /// Update TV setup (PREMIUM tier)
  Future<bool> updateTvSetup(String venueId, TvSetup tvSetup) async {
    try {
      final enhancement = await getVenueEnhancement(venueId);
      if (enhancement == null || !enhancement.isPremium) {
        return false;
      }

      final updated = enhancement.copyWith(tvSetup: tvSetup);
      return saveVenueEnhancement(updated);
    } catch (e) {
      LoggingService.error('Error updating TV setup: $e', tag: _logTag);
      return false;
    }
  }

  /// Add game day special (PREMIUM tier)
  Future<bool> addGameSpecial(String venueId, GameDaySpecial special) async {
    try {
      final enhancement = await getVenueEnhancement(venueId);
      if (enhancement == null || !enhancement.isPremium) {
        return false;
      }

      final specials = [...enhancement.gameSpecials, special];
      final updated = enhancement.copyWith(gameSpecials: specials);
      return saveVenueEnhancement(updated);
    } catch (e) {
      LoggingService.error('Error adding game special: $e', tag: _logTag);
      return false;
    }
  }

  /// Update game day special
  Future<bool> updateGameSpecial(String venueId, GameDaySpecial special) async {
    try {
      final enhancement = await getVenueEnhancement(venueId);
      if (enhancement == null || !enhancement.isPremium) {
        return false;
      }

      final specials = enhancement.gameSpecials
          .map((s) => s.id == special.id ? special : s)
          .toList();
      final updated = enhancement.copyWith(gameSpecials: specials);
      return saveVenueEnhancement(updated);
    } catch (e) {
      LoggingService.error('Error updating game special: $e', tag: _logTag);
      return false;
    }
  }

  /// Delete game day special
  Future<bool> deleteGameSpecial(String venueId, String specialId) async {
    try {
      final enhancement = await getVenueEnhancement(venueId);
      if (enhancement == null || !enhancement.isPremium) {
        return false;
      }

      final specials =
          enhancement.gameSpecials.where((s) => s.id != specialId).toList();
      final updated = enhancement.copyWith(gameSpecials: specials);
      return saveVenueEnhancement(updated);
    } catch (e) {
      LoggingService.error('Error deleting game special: $e', tag: _logTag);
      return false;
    }
  }

  /// Update atmosphere settings (PREMIUM tier)
  Future<bool> updateAtmosphere(
    String venueId,
    AtmosphereSettings atmosphere,
  ) async {
    try {
      final enhancement = await getVenueEnhancement(venueId);
      if (enhancement == null || !enhancement.isPremium) {
        return false;
      }

      final updated = enhancement.copyWith(atmosphere: atmosphere);
      return saveVenueEnhancement(updated);
    } catch (e) {
      LoggingService.error('Error updating atmosphere: $e', tag: _logTag);
      return false;
    }
  }

  /// Update live capacity (PREMIUM tier)
  Future<bool> updateLiveCapacity(
    String venueId, {
    required int currentOccupancy,
    int? waitTimeMinutes,
    bool? reservationsAvailable,
  }) async {
    try {
      final enhancement = await getVenueEnhancement(venueId);
      if (enhancement == null || !enhancement.isPremium) {
        return false;
      }

      final capacity = (enhancement.liveCapacity ?? LiveCapacity.empty())
          .copyWith(
        currentOccupancy: currentOccupancy,
        waitTimeMinutes: waitTimeMinutes,
        reservationsAvailable: reservationsAvailable,
        lastUpdated: DateTime.now(),
      );

      final updated = enhancement.copyWith(liveCapacity: capacity);
      return saveVenueEnhancement(updated);
    } catch (e) {
      LoggingService.error('Error updating live capacity: $e', tag: _logTag);
      return false;
    }
  }

  /// Set max capacity for the venue
  Future<bool> setMaxCapacity(String venueId, int maxCapacity) async {
    try {
      final enhancement = await getVenueEnhancement(venueId);
      if (enhancement == null || !enhancement.isPremium) {
        return false;
      }

      final capacity = (enhancement.liveCapacity ?? LiveCapacity.empty())
          .copyWith(maxCapacity: maxCapacity);

      final updated = enhancement.copyWith(liveCapacity: capacity);
      return saveVenueEnhancement(updated);
    } catch (e) {
      LoggingService.error('Error setting max capacity: $e', tag: _logTag);
      return false;
    }
  }

  // =====================
  // QUERY METHODS
  // =====================

  /// Get venues showing a specific match
  Future<List<String>> getVenuesShowingMatch(String matchId) async {
    try {
      // Query venues with the match in their broadcasting schedule
      final premiumSnapshot = await _firestore
          .collection(_collection)
          .where('broadcastingSchedule.matchIds', arrayContains: matchId)
          .get();

      // Also get free tier venues with showsMatches = true
      final freeSnapshot = await _firestore
          .collection(_collection)
          .where('subscriptionTier', isEqualTo: 'free')
          .where('showsMatches', isEqualTo: true)
          .get();

      final venueIds = <String>{};
      for (final doc in premiumSnapshot.docs) {
        venueIds.add(doc.id);
      }
      for (final doc in freeSnapshot.docs) {
        venueIds.add(doc.id);
      }

      return venueIds.toList();
    } catch (e) {
      LoggingService.error('Error getting venues showing match: $e', tag: _logTag);
      return [];
    }
  }

  /// Get enhanced venue data with filtering
  Future<List<VenueEnhancement>> getEnhancedVenues({
    VenueFilterCriteria? filters,
    int limit = 50,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(_collection);

      // Note: Complex filtering may require client-side filtering
      // due to Firestore query limitations
      final snapshot = await query.limit(limit).get();

      var enhancements = snapshot.docs
          .map((doc) => VenueEnhancement.fromFirestore(doc.data(), doc.id))
          .toList();

      // Apply client-side filtering if criteria provided
      if (filters != null && filters.hasActiveFilters) {
        enhancements = _applyFilters(enhancements, filters);
      }

      // Cache results
      for (final e in enhancements) {
        _cache[e.venueId] = e;
      }

      return enhancements;
    } catch (e) {
      LoggingService.error('Error getting enhanced venues: $e', tag: _logTag);
      return [];
    }
  }

  /// Apply filters to venue enhancements (client-side)
  List<VenueEnhancement> _applyFilters(
    List<VenueEnhancement> venues,
    VenueFilterCriteria filters,
  ) {
    return venues.where((v) {
      // Filter by match
      if (filters.showsMatchId != null) {
        if (!v.isBroadcastingMatch(filters.showsMatchId!)) return false;
      }

      // Filter by TVs
      if (filters.hasTvs == true) {
        if (!v.hasTvInfo) return false;
      }

      // Filter by specials
      if (filters.hasSpecials == true) {
        if (!v.hasActiveSpecials) return false;
      }

      // Filter by atmosphere tags
      if (filters.atmosphereTags.isNotEmpty) {
        if (v.atmosphere == null) return false;
        final hasMatchingTag = filters.atmosphereTags
            .any((tag) => v.atmosphere!.hasTag(tag));
        if (!hasMatchingTag) return false;
      }

      // Filter by capacity info
      if (filters.hasCapacityInfo == true) {
        if (!v.hasCapacityInfo) return false;
      }

      // Filter by team affinity
      if (filters.teamAffinity != null) {
        if (v.atmosphere == null ||
            !v.atmosphere!.supportsTeam(filters.teamAffinity!)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Get enhancements for multiple venue IDs
  Future<Map<String, VenueEnhancement>> getEnhancementsForVenues(
    List<String> venueIds,
  ) async {
    if (venueIds.isEmpty) return {};

    LoggingService.debug(
      'Loading enhancements for ${venueIds.length} venues',
      tag: _logTag,
    );

    try {
      final results = <String, VenueEnhancement>{};

      // Check cache first
      final uncachedIds = <String>[];
      for (final id in venueIds) {
        if (_cache.containsKey(id)) {
          results[id] = _cache[id]!;
        } else {
          uncachedIds.add(id);
        }
      }

      LoggingService.debug(
        'Found ${results.length} cached, fetching ${uncachedIds.length} from Firestore',
        tag: _logTag,
      );

      // Fetch uncached items (Firestore limits whereIn to 10 items)
      for (var i = 0; i < uncachedIds.length; i += 10) {
        final batch = uncachedIds.skip(i).take(10).toList();
        final snapshot = await _firestore
            .collection(_collection)
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        LoggingService.debug(
          'Firestore batch query returned ${snapshot.docs.length} enhancements',
          tag: _logTag,
        );

        for (final doc in snapshot.docs) {
          final enhancement =
              VenueEnhancement.fromFirestore(doc.data(), doc.id);
          results[doc.id] = enhancement;
          _cache[doc.id] = enhancement;
        }
      }

      LoggingService.info(
        'Loaded ${results.length} venue enhancements total',
        tag: _logTag,
      );
      return results;
    } catch (e) {
      LoggingService.error('Error getting enhancements for venues: $e', tag: _logTag);
      return {};
    }
  }

  // =====================
  // REAL-TIME STREAMS
  // =====================

  /// Watch venue enhancement changes
  Stream<VenueEnhancement?> watchVenueEnhancement(String venueId) {
    return _firestore
        .collection(_collection)
        .doc(venueId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      final enhancement =
          VenueEnhancement.fromFirestore(snapshot.data()!, snapshot.id);
      _cache[venueId] = enhancement;
      return enhancement;
    });
  }

  /// Watch venues showing a specific match
  Stream<List<String>> watchVenuesShowingMatch(String matchId) {
    return _firestore
        .collection(_collection)
        .where('broadcastingSchedule.matchIds', arrayContains: matchId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  // =====================
  // SUBSCRIPTION TIER
  // =====================

  /// Update subscription tier (called from webhook or admin)
  Future<bool> updateSubscriptionTier(
    String venueId,
    SubscriptionTier tier,
  ) async {
    try {
      var enhancement = await getVenueEnhancement(venueId);

      if (enhancement == null) {
        // Create new enhancement with the tier
        enhancement = await createVenueEnhancement(
          venueId: venueId,
          tier: tier,
        );
        return enhancement != null;
      }

      final updated = enhancement.copyWith(subscriptionTier: tier);
      return saveVenueEnhancement(updated);
    } catch (e) {
      LoggingService.error('Error updating subscription tier: $e', tag: _logTag);
      return false;
    }
  }

  /// Check if venue has premium subscription
  Future<bool> isPremiumVenue(String venueId) async {
    final enhancement = await getVenueEnhancement(venueId);
    return enhancement?.isPremium ?? false;
  }

  // =====================
  // CACHE MANAGEMENT
  // =====================

  /// Clear cache for a venue
  void clearCache(String venueId) {
    _cache.remove(venueId);
  }

  /// Clear all caches
  void clearAllCaches() {
    _cache.clear();
  }

  /// Get service statistics
  Map<String, dynamic> getServiceStats() {
    return {
      'cacheSize': _cache.length,
    };
  }
}
