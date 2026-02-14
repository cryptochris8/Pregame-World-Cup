import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/entities.dart';

/// Firestore Data Source for World Cup 2026 data
/// Handles reading and writing to Firebase Firestore
class WorldCupFirestoreDataSource {
  final FirebaseFirestore _firestore;

  // Collection names
  static const String _matchesCollection = 'worldcup_matches';
  static const String _teamsCollection = 'worldcup_teams';
  static const String _groupsCollection = 'worldcup_groups';
  static const String _bracketCollection = 'worldcup_bracket';
  static const String _venuesCollection = 'worldcup_venues';
  static const String _headToHeadCollection = 'headToHead';
  static const String _worldCupHistoryCollection = 'worldCupHistory';
  static const String _worldCupRecordsCollection = 'worldCupRecords';
  static const String _matchSummariesCollection = 'matchSummaries';

  WorldCupFirestoreDataSource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  // ==================== MATCHES ====================

  /// Fetches all World Cup matches
  Future<List<WorldCupMatch>> getAllMatches() async {
    try {
      final snapshot = await _firestore
          .collection(_matchesCollection)
          .orderBy('matchNumber')
          .get();

      return snapshot.docs
          .map((doc) => WorldCupMatch.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      // Debug output removed
      return [];
    }
  }

  /// Fetches matches by stage
  Future<List<WorldCupMatch>> getMatchesByStage(MatchStage stage) async {
    try {
      final snapshot = await _firestore
          .collection(_matchesCollection)
          .where('stage', isEqualTo: stage.name)
          .orderBy('dateTimeUtc')
          .get();

      return snapshot.docs
          .map((doc) => WorldCupMatch.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      // Debug output removed
      return [];
    }
  }

  /// Fetches matches by group
  Future<List<WorldCupMatch>> getMatchesByGroup(String groupLetter) async {
    try {
      final snapshot = await _firestore
          .collection(_matchesCollection)
          .where('group', isEqualTo: groupLetter.toUpperCase())
          .orderBy('groupMatchDay')
          .get();

      return snapshot.docs
          .map((doc) => WorldCupMatch.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      // Debug output removed
      return [];
    }
  }

  /// Fetches matches by team
  Future<List<WorldCupMatch>> getMatchesByTeam(String teamCode) async {
    try {
      // Need to query both home and away
      final homeSnapshot = await _firestore
          .collection(_matchesCollection)
          .where('homeTeamCode', isEqualTo: teamCode.toUpperCase())
          .get();

      final awaySnapshot = await _firestore
          .collection(_matchesCollection)
          .where('awayTeamCode', isEqualTo: teamCode.toUpperCase())
          .get();

      final matches = <WorldCupMatch>[];
      matches.addAll(homeSnapshot.docs
          .map((doc) => WorldCupMatch.fromFirestore(doc.data(), doc.id)));
      matches.addAll(awaySnapshot.docs
          .map((doc) => WorldCupMatch.fromFirestore(doc.data(), doc.id)));

      // Sort by match number
      matches.sort((a, b) => a.matchNumber.compareTo(b.matchNumber));
      return matches;
    } catch (e) {
      // Debug output removed
      return [];
    }
  }

  /// Fetches a single match by ID
  Future<WorldCupMatch?> getMatchById(String matchId) async {
    try {
      final doc = await _firestore
          .collection(_matchesCollection)
          .doc(matchId)
          .get();

      if (doc.exists && doc.data() != null) {
        return WorldCupMatch.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      // Debug output removed
      return null;
    }
  }

  /// Fetches live matches
  Future<List<WorldCupMatch>> getLiveMatches() async {
    try {
      final snapshot = await _firestore
          .collection(_matchesCollection)
          .where('status', whereIn: [
            MatchStatus.inProgress.name,
            MatchStatus.halfTime.name,
            MatchStatus.extraTime.name,
            MatchStatus.penalties.name,
          ])
          .get();

      return snapshot.docs
          .map((doc) => WorldCupMatch.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      // Debug output removed
      return [];
    }
  }

  /// Fetches upcoming matches
  Future<List<WorldCupMatch>> getUpcomingMatches({int limit = 10}) async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection(_matchesCollection)
          .where('status', isEqualTo: MatchStatus.scheduled.name)
          .where('dateTimeUtc', isGreaterThan: Timestamp.fromDate(now))
          .orderBy('dateTimeUtc')
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => WorldCupMatch.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      // Debug output removed
      return [];
    }
  }

  /// Saves a match to Firestore
  Future<void> saveMatch(WorldCupMatch match) async {
    try {
      await _firestore
          .collection(_matchesCollection)
          .doc(match.matchId)
          .set(match.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      // Debug output removed
      throw Exception('Failed to save match: $e');
    }
  }

  /// Saves multiple matches in a batch
  Future<void> saveMatches(List<WorldCupMatch> matches) async {
    try {
      final batch = _firestore.batch();

      for (final match in matches) {
        final ref = _firestore.collection(_matchesCollection).doc(match.matchId);
        batch.set(ref, match.toFirestore(), SetOptions(merge: true));
      }

      await batch.commit();
    } catch (e) {
      // Debug output removed
      throw Exception('Failed to save matches: $e');
    }
  }

  /// Stream of live match updates
  Stream<List<WorldCupMatch>> watchLiveMatches() {
    return _firestore
        .collection(_matchesCollection)
        .where('status', whereIn: [
          MatchStatus.inProgress.name,
          MatchStatus.halfTime.name,
          MatchStatus.extraTime.name,
          MatchStatus.penalties.name,
        ])
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WorldCupMatch.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Stream of a specific match
  Stream<WorldCupMatch?> watchMatch(String matchId) {
    return _firestore
        .collection(_matchesCollection)
        .doc(matchId)
        .snapshots()
        .map((doc) {
          if (doc.exists && doc.data() != null) {
            return WorldCupMatch.fromFirestore(doc.data()!, doc.id);
          }
          return null;
        });
  }

  // ==================== TEAMS ====================

  /// Fetches all national teams
  Future<List<NationalTeam>> getAllTeams() async {
    try {
      final snapshot = await _firestore
          .collection(_teamsCollection)
          .orderBy('fifaRanking')
          .get();

      return snapshot.docs
          .map((doc) => NationalTeam.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      // Debug output removed
      return [];
    }
  }

  /// Fetches teams by group
  Future<List<NationalTeam>> getTeamsByGroup(String groupLetter) async {
    try {
      final snapshot = await _firestore
          .collection(_teamsCollection)
          .where('group', isEqualTo: groupLetter.toUpperCase())
          .get();

      return snapshot.docs
          .map((doc) => NationalTeam.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      // Debug output removed
      return [];
    }
  }

  /// Fetches a team by FIFA code
  Future<NationalTeam?> getTeamByCode(String fifaCode) async {
    try {
      final doc = await _firestore
          .collection(_teamsCollection)
          .doc(fifaCode.toUpperCase())
          .get();

      if (doc.exists && doc.data() != null) {
        return NationalTeam.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      // Debug output removed
      return null;
    }
  }

  /// Saves a team to Firestore
  Future<void> saveTeam(NationalTeam team) async {
    try {
      await _firestore
          .collection(_teamsCollection)
          .doc(team.fifaCode)
          .set(team.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      // Debug output removed
      throw Exception('Failed to save team: $e');
    }
  }

  /// Saves multiple teams in a batch
  Future<void> saveTeams(List<NationalTeam> teams) async {
    try {
      final batch = _firestore.batch();

      for (final team in teams) {
        final ref = _firestore.collection(_teamsCollection).doc(team.fifaCode);
        batch.set(ref, team.toFirestore(), SetOptions(merge: true));
      }

      await batch.commit();
    } catch (e) {
      // Debug output removed
      throw Exception('Failed to save teams: $e');
    }
  }

  /// Stream of team updates
  Stream<List<NationalTeam>> watchTeams() {
    return _firestore
        .collection(_teamsCollection)
        .orderBy('fifaRanking')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NationalTeam.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // ==================== GROUPS ====================

  /// Fetches all groups
  Future<List<WorldCupGroup>> getAllGroups() async {
    try {
      final snapshot = await _firestore
          .collection(_groupsCollection)
          .orderBy('groupLetter')
          .get();

      return snapshot.docs
          .map((doc) => WorldCupGroup.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      // Debug output removed
      return [];
    }
  }

  /// Fetches a single group by letter
  Future<WorldCupGroup?> getGroupByLetter(String groupLetter) async {
    try {
      final doc = await _firestore
          .collection(_groupsCollection)
          .doc(groupLetter.toUpperCase())
          .get();

      if (doc.exists && doc.data() != null) {
        return WorldCupGroup.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      // Debug output removed
      return null;
    }
  }

  /// Saves a group to Firestore
  Future<void> saveGroup(WorldCupGroup group) async {
    try {
      await _firestore
          .collection(_groupsCollection)
          .doc(group.groupLetter)
          .set(group.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      // Debug output removed
      throw Exception('Failed to save group: $e');
    }
  }

  /// Stream of group updates
  Stream<List<WorldCupGroup>> watchGroups() {
    return _firestore
        .collection(_groupsCollection)
        .orderBy('groupLetter')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WorldCupGroup.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Stream of a specific group
  Stream<WorldCupGroup?> watchGroup(String groupLetter) {
    return _firestore
        .collection(_groupsCollection)
        .doc(groupLetter.toUpperCase())
        .snapshots()
        .map((doc) {
          if (doc.exists && doc.data() != null) {
            return WorldCupGroup.fromFirestore(doc.data()!, doc.id);
          }
          return null;
        });
  }

  // ==================== BRACKET ====================

  /// Fetches the knockout bracket
  Future<WorldCupBracket?> getBracket() async {
    try {
      final doc = await _firestore
          .collection(_bracketCollection)
          .doc('2026')
          .get();

      if (doc.exists && doc.data() != null) {
        return WorldCupBracket.fromFirestore(doc.data()!);
      }
      return null;
    } catch (e) {
      // Debug output removed
      return null;
    }
  }

  /// Saves the bracket to Firestore
  Future<void> saveBracket(WorldCupBracket bracket) async {
    try {
      await _firestore
          .collection(_bracketCollection)
          .doc('2026')
          .set(bracket.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      // Debug output removed
      throw Exception('Failed to save bracket: $e');
    }
  }

  /// Stream of bracket updates
  Stream<WorldCupBracket?> watchBracket() {
    return _firestore
        .collection(_bracketCollection)
        .doc('2026')
        .snapshots()
        .map((doc) {
          if (doc.exists && doc.data() != null) {
            return WorldCupBracket.fromFirestore(doc.data()!);
          }
          return null;
        });
  }

  // ==================== VENUES ====================

  /// Fetches all venues
  Future<List<WorldCupVenue>> getAllVenues() async {
    try {
      final snapshot = await _firestore
          .collection(_venuesCollection)
          .get();

      if (snapshot.docs.isEmpty) {
        // Return static venue data if Firestore is empty
        return WorldCupVenues.all;
      }

      return snapshot.docs
          .map((doc) => WorldCupVenue.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      // Debug output removed
      // Return static venue data as fallback
      return WorldCupVenues.all;
    }
  }

  /// Fetches a venue by ID
  Future<WorldCupVenue?> getVenueById(String venueId) async {
    try {
      final doc = await _firestore
          .collection(_venuesCollection)
          .doc(venueId)
          .get();

      if (doc.exists && doc.data() != null) {
        return WorldCupVenue.fromFirestore(doc.data()!, doc.id);
      }

      // Try static data
      return WorldCupVenues.getById(venueId);
    } catch (e) {
      // Debug output removed
      return WorldCupVenues.getById(venueId);
    }
  }

  /// Saves venues to Firestore
  Future<void> saveVenues(List<WorldCupVenue> venues) async {
    try {
      final batch = _firestore.batch();

      for (final venue in venues) {
        final ref = _firestore.collection(_venuesCollection).doc(venue.venueId);
        batch.set(ref, venue.toFirestore(), SetOptions(merge: true));
      }

      await batch.commit();
    } catch (e) {
      // Debug output removed
      throw Exception('Failed to save venues: $e');
    }
  }

  // ==================== UTILITIES ====================

  /// Deletes all World Cup data (for testing/reset)
  Future<void> clearAllData() async {
    try {
      final collections = [
        _matchesCollection,
        _teamsCollection,
        _groupsCollection,
        _bracketCollection,
        _venuesCollection,
      ];

      for (final collection in collections) {
        final snapshot = await _firestore.collection(collection).get();
        final batch = _firestore.batch();

        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();
      }
    } catch (e) {
      // Debug output removed
      throw Exception('Failed to clear data: $e');
    }
  }

  // ==================== HEAD TO HEAD ====================

  /// Fetches head-to-head record between two teams
  Future<HeadToHead?> getHeadToHead(String team1Code, String team2Code) async {
    try {
      // Sort codes alphabetically for consistent document ID
      final codes = [team1Code.toUpperCase(), team2Code.toUpperCase()]..sort();
      final docId = '${codes[0]}_${codes[1]}';

      final doc = await _firestore
          .collection(_headToHeadCollection)
          .doc(docId)
          .get();

      if (doc.exists && doc.data() != null) {
        return HeadToHead.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      // Debug output removed
      return null;
    }
  }

  /// Fetches all head-to-head records for a team
  Future<List<HeadToHead>> getHeadToHeadForTeam(String teamCode) async {
    try {
      final code = teamCode.toUpperCase();

      // Query both team1Code and team2Code
      final team1Query = await _firestore
          .collection(_headToHeadCollection)
          .where('team1Code', isEqualTo: code)
          .get();

      final team2Query = await _firestore
          .collection(_headToHeadCollection)
          .where('team2Code', isEqualTo: code)
          .get();

      final results = <HeadToHead>[];
      for (final doc in team1Query.docs) {
        results.add(HeadToHead.fromMap(doc.data()));
            }
      for (final doc in team2Query.docs) {
        results.add(HeadToHead.fromMap(doc.data()));
            }

      return results;
    } catch (e) {
      // Debug output removed
      return [];
    }
  }

  /// Fetches all head-to-head records
  Future<List<HeadToHead>> getAllHeadToHead() async {
    try {
      final snapshot = await _firestore
          .collection(_headToHeadCollection)
          .get();

      return snapshot.docs
          .map((doc) => HeadToHead.fromMap(doc.data()))
          .toList();
    } catch (e) {
      // Debug output removed
      return [];
    }
  }

  // ==================== WORLD CUP HISTORY ====================

  /// Fetches all historical World Cup tournaments
  Future<List<WorldCupTournament>> getAllWorldCupHistory() async {
    try {
      final snapshot = await _firestore
          .collection(_worldCupHistoryCollection)
          .orderBy('year', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => WorldCupTournament.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      // Debug output removed
      return [];
    }
  }

  /// Fetches a specific World Cup tournament by year
  Future<WorldCupTournament?> getWorldCupByYear(int year) async {
    try {
      final doc = await _firestore
          .collection(_worldCupHistoryCollection)
          .doc('wc_$year')
          .get();

      if (doc.exists && doc.data() != null) {
        return WorldCupTournament.fromFirestore(doc.data()!);
      }
      return null;
    } catch (e) {
      // Debug output removed
      return null;
    }
  }

  /// Fetches World Cups won by a specific team
  Future<List<WorldCupTournament>> getWorldCupsByWinner(String teamCode) async {
    try {
      final snapshot = await _firestore
          .collection(_worldCupHistoryCollection)
          .where('winnerCode', isEqualTo: teamCode.toUpperCase())
          .orderBy('year', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => WorldCupTournament.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      // Debug output removed
      return [];
    }
  }

  // ==================== WORLD CUP RECORDS ====================

  /// Fetches all World Cup records
  Future<List<WorldCupRecord>> getAllWorldCupRecords() async {
    try {
      final snapshot = await _firestore
          .collection(_worldCupRecordsCollection)
          .get();

      return snapshot.docs
          .map((doc) => WorldCupRecord.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      // Debug output removed
      return [];
    }
  }

  /// Fetches World Cup records by holder type
  Future<List<WorldCupRecord>> getWorldCupRecordsByType(String holderType) async {
    try {
      final snapshot = await _firestore
          .collection(_worldCupRecordsCollection)
          .where('holderType', isEqualTo: holderType)
          .get();

      return snapshot.docs
          .map((doc) => WorldCupRecord.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      // Debug output removed
      return [];
    }
  }

  /// Fetches a specific World Cup record by category
  Future<WorldCupRecord?> getWorldCupRecordByCategory(String category) async {
    try {
      final docId = category.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
      final doc = await _firestore
          .collection(_worldCupRecordsCollection)
          .doc(docId)
          .get();

      if (doc.exists && doc.data() != null) {
        return WorldCupRecord.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      // Debug output removed
      return null;
    }
  }

  // ==================== MATCH SUMMARIES ====================

  /// Fetches AI match summary for a matchup between two teams
  Future<MatchSummary?> getMatchSummary(String team1Code, String team2Code) async {
    try {
      // Sort codes alphabetically for consistent document ID
      final codes = [team1Code.toUpperCase(), team2Code.toUpperCase()]..sort();
      final docId = '${codes[0]}_${codes[1]}';

      final doc = await _firestore
          .collection(_matchSummariesCollection)
          .doc(docId)
          .get();

      if (doc.exists && doc.data() != null) {
        return MatchSummary.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      // Debug output removed
      return null;
    }
  }

  /// Fetches all match summaries
  Future<List<MatchSummary>> getAllMatchSummaries() async {
    try {
      final snapshot = await _firestore
          .collection(_matchSummariesCollection)
          .get();

      return snapshot.docs
          .map((doc) => MatchSummary.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      // Debug output removed
      return [];
    }
  }
}
