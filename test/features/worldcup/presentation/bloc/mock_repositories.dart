import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';

// Mock Repositories
class MockWorldCupMatchRepository extends Mock implements WorldCupMatchRepository {}
class MockNationalTeamRepository extends Mock implements NationalTeamRepository {}
class MockGroupRepository extends Mock implements GroupRepository {}
class MockBracketRepository extends Mock implements BracketRepository {}
class MockUserPreferencesRepository extends Mock implements UserPreferencesRepository {}

// Test Data Factories
class TestDataFactory {
  static WorldCupMatch createMatch({
    String matchId = 'match_1',
    int matchNumber = 1,
    MatchStage stage = MatchStage.groupStage,
    String? group = 'A',
    int? groupMatchDay = 1,
    String? homeTeamCode = 'USA',
    String homeTeamName = 'United States',
    String? awayTeamCode = 'MEX',
    String awayTeamName = 'Mexico',
    int? homeScore,
    int? awayScore,
    MatchStatus status = MatchStatus.scheduled,
    DateTime? dateTime,
    String? venueId = 'venue_1',
  }) {
    return WorldCupMatch(
      matchId: matchId,
      matchNumber: matchNumber,
      stage: stage,
      group: group,
      groupMatchDay: groupMatchDay,
      homeTeamCode: homeTeamCode,
      homeTeamName: homeTeamName,
      awayTeamCode: awayTeamCode,
      awayTeamName: awayTeamName,
      homeScore: homeScore,
      awayScore: awayScore,
      status: status,
      dateTime: dateTime ?? DateTime(2026, 6, 11, 18, 0),
      venueId: venueId,
    );
  }

  static NationalTeam createTeam({
    String teamCode = 'USA',
    String countryName = 'United States',
    String shortName = 'USA',
    Confederation confederation = Confederation.concacaf,
    int? worldRanking = 10,
    String? group = 'A',
    int worldCupTitles = 0,
    bool isHostNation = true,
  }) {
    return NationalTeam(
      teamCode: teamCode,
      countryName: countryName,
      shortName: shortName,
      flagUrl: '',
      confederation: confederation,
      worldRanking: worldRanking,
      group: group,
      worldCupTitles: worldCupTitles,
      isHostNation: isHostNation,
    );
  }

  static GroupTeamStanding createStanding({
    String teamCode = 'USA',
    String teamName = 'United States',
    int position = 1,
    int played = 3,
    int won = 2,
    int drawn = 1,
    int lost = 0,
    int goalsFor = 5,
    int goalsAgainst = 2,
  }) {
    return GroupTeamStanding(
      teamCode: teamCode,
      teamName: teamName,
      position: position,
      played: played,
      won: won,
      drawn: drawn,
      lost: lost,
      goalsFor: goalsFor,
      goalsAgainst: goalsAgainst,
      points: won * 3 + drawn,
    );
  }

  static WorldCupGroup createGroup({
    String groupLetter = 'A',
    List<GroupTeamStanding>? standings,
  }) {
    return WorldCupGroup(
      groupLetter: groupLetter,
      standings: standings ?? [
        createStanding(teamCode: 'USA', teamName: 'United States', position: 1),
        createStanding(teamCode: 'MEX', teamName: 'Mexico', position: 2, won: 1, drawn: 2, lost: 0),
        createStanding(teamCode: 'CAN', teamName: 'Canada', position: 3, won: 1, drawn: 1, lost: 1),
        createStanding(teamCode: 'JAM', teamName: 'Jamaica', position: 4, won: 0, drawn: 1, lost: 2),
      ],
    );
  }

  static BracketSlot createBracketSlot({
    String slotId = 'slot_1',
    MatchStage stage = MatchStage.roundOf16,
    int matchNumberInStage = 1,
    String? teamCode = 'USA',
    String teamNameOrPlaceholder = 'United States',
    int? score,
    bool isConfirmed = true,
  }) {
    return BracketSlot(
      slotId: slotId,
      stage: stage,
      matchNumberInStage: matchNumberInStage,
      teamCode: teamCode,
      teamNameOrPlaceholder: teamNameOrPlaceholder,
      score: score,
      isConfirmed: isConfirmed,
    );
  }

  static BracketMatch createBracketMatch({
    String matchId = 'bracket_1',
    int matchNumber = 1,
    MatchStage stage = MatchStage.roundOf16,
    int matchNumberInStage = 1,
    BracketSlot? homeSlot,
    BracketSlot? awaySlot,
    MatchStatus status = MatchStatus.scheduled,
    DateTime? dateTime,
  }) {
    return BracketMatch(
      matchId: matchId,
      matchNumber: matchNumber,
      stage: stage,
      matchNumberInStage: matchNumberInStage,
      homeSlot: homeSlot ?? createBracketSlot(
        slotId: '${matchId}_home',
        stage: stage,
        teamCode: 'USA',
        teamNameOrPlaceholder: 'United States',
      ),
      awaySlot: awaySlot ?? createBracketSlot(
        slotId: '${matchId}_away',
        stage: stage,
        teamCode: 'MEX',
        teamNameOrPlaceholder: 'Mexico',
      ),
      status: status,
      dateTime: dateTime ?? DateTime(2026, 7, 1, 18, 0),
    );
  }

  static WorldCupBracket createBracket() {
    return WorldCupBracket(
      roundOf32: List.generate(16, (i) => createBracketMatch(
        matchId: 'r32_$i',
        matchNumber: i + 1,
        stage: MatchStage.roundOf32,
        matchNumberInStage: i + 1,
      )),
      roundOf16: List.generate(8, (i) => createBracketMatch(
        matchId: 'r16_$i',
        matchNumber: i + 17,
        stage: MatchStage.roundOf16,
        matchNumberInStage: i + 1,
      )),
      quarterFinals: List.generate(4, (i) => createBracketMatch(
        matchId: 'qf_$i',
        matchNumber: i + 25,
        stage: MatchStage.quarterFinal,
        matchNumberInStage: i + 1,
      )),
      semiFinals: List.generate(2, (i) => createBracketMatch(
        matchId: 'sf_$i',
        matchNumber: i + 29,
        stage: MatchStage.semiFinal,
        matchNumberInStage: i + 1,
      )),
      thirdPlace: createBracketMatch(
        matchId: '3rd',
        matchNumber: 31,
        stage: MatchStage.thirdPlace,
        matchNumberInStage: 1,
      ),
      finalMatch: createBracketMatch(
        matchId: 'final',
        matchNumber: 32,
        stage: MatchStage.final_,
        matchNumberInStage: 1,
      ),
    );
  }

  static List<WorldCupMatch> createMatchList({int count = 5}) {
    return List.generate(count, (i) => createMatch(
      matchId: 'match_$i',
      matchNumber: i + 1,
      homeTeamCode: ['USA', 'BRA', 'GER', 'FRA', 'ARG'][i % 5],
      awayTeamCode: ['MEX', 'COL', 'ESP', 'ITA', 'URU'][i % 5],
    ));
  }

  static List<NationalTeam> createTeamList({int count = 48}) {
    final codes = [
      'USA', 'MEX', 'CAN', 'BRA', 'ARG', 'GER', 'FRA', 'ESP',
      'ITA', 'ENG', 'NED', 'POR', 'BEL', 'URU', 'COL', 'CHI',
    ];

    return List.generate(count.clamp(0, codes.length), (i) => createTeam(
      teamCode: codes[i],
      countryName: codes[i],
      worldRanking: i + 1,
      group: String.fromCharCode('A'.codeUnitAt(0) + (i ~/ 4)),
    ));
  }

  static List<WorldCupGroup> createGroupList({int count = 12}) {
    return List.generate(count, (i) => createGroup(
      groupLetter: String.fromCharCode('A'.codeUnitAt(0) + i),
    ));
  }

  static MatchPrediction createPrediction({
    String predictionId = 'pred_1',
    String matchId = 'match_1',
    int predictedHomeScore = 2,
    int predictedAwayScore = 1,
    PredictionOutcome predictedOutcome = PredictionOutcome.pending,
    PredictionOutcome? actualOutcome,
    int pointsEarned = 0,
    bool exactScoreCorrect = false,
    bool resultCorrect = false,
    String? homeTeamCode = 'USA',
    String? homeTeamName = 'United States',
    String? awayTeamCode = 'MEX',
    String? awayTeamName = 'Mexico',
    DateTime? matchDate,
    DateTime? createdAt,
  }) {
    return MatchPrediction(
      predictionId: predictionId,
      matchId: matchId,
      predictedHomeScore: predictedHomeScore,
      predictedAwayScore: predictedAwayScore,
      predictedOutcome: predictedOutcome,
      actualOutcome: actualOutcome,
      pointsEarned: pointsEarned,
      exactScoreCorrect: exactScoreCorrect,
      resultCorrect: resultCorrect,
      homeTeamCode: homeTeamCode,
      homeTeamName: homeTeamName,
      awayTeamCode: awayTeamCode,
      awayTeamName: awayTeamName,
      matchDate: matchDate ?? DateTime(2026, 6, 15),
      createdAt: createdAt ?? DateTime(2026, 6, 10),
    );
  }

  static UserPreferences createUserPreferences({
    List<String> favoriteTeamCodes = const ['USA', 'BRA'],
    List<String> favoriteMatchIds = const ['match_1'],
    bool notifyFavoriteTeamMatches = true,
    bool notifyLiveUpdates = true,
    bool notifyGoals = true,
    String? preferredTimezone,
  }) {
    return UserPreferences(
      favoriteTeamCodes: favoriteTeamCodes,
      favoriteMatchIds: favoriteMatchIds,
      notifyFavoriteTeamMatches: notifyFavoriteTeamMatches,
      notifyLiveUpdates: notifyLiveUpdates,
      notifyGoals: notifyGoals,
      preferredTimezone: preferredTimezone,
    );
  }

  static MatchReminder createMatchReminder({
    String reminderId = 'reminder_1',
    String userId = 'user_1',
    String matchId = 'match_1',
    String matchName = 'USA vs Mexico',
    DateTime? matchDateTimeUtc,
    DateTime? reminderDateTimeUtc,
    ReminderTiming timing = ReminderTiming.thirtyMinutes,
    bool isEnabled = true,
    bool isSent = false,
    String? homeTeamCode = 'USA',
    String? awayTeamCode = 'MEX',
  }) {
    final matchDt = matchDateTimeUtc ?? DateTime.utc(2026, 6, 15, 18, 0);
    return MatchReminder(
      reminderId: reminderId,
      userId: userId,
      matchId: matchId,
      matchName: matchName,
      matchDateTimeUtc: matchDt,
      reminderDateTimeUtc: reminderDateTimeUtc ??
          matchDt.subtract(Duration(minutes: timing.minutes)),
      timing: timing,
      isEnabled: isEnabled,
      isSent: isSent,
      createdAt: DateTime(2026, 6, 10),
      homeTeamCode: homeTeamCode,
      awayTeamCode: awayTeamCode,
    );
  }

  static WorldCupVenue createVenue({
    String venueId = 'venue_1',
    String name = 'MetLife Stadium',
    String city = 'East Rutherford',
    String? state = 'New Jersey',
    HostCountry country = HostCountry.usa,
    int capacity = 82500,
    List<String> keyMatches = const ['Final'],
  }) {
    return WorldCupVenue(
      venueId: venueId,
      name: name,
      city: city,
      state: state,
      country: country,
      capacity: capacity,
      keyMatches: keyMatches,
    );
  }

  static HeadToHead createHeadToHead({
    String team1Code = 'USA',
    String team2Code = 'MEX',
    int totalMatches = 77,
    int team1Wins = 22,
    int team2Wins = 36,
    int draws = 19,
    int team1Goals = 90,
    int team2Goals = 130,
    int worldCupMatches = 2,
  }) {
    return HeadToHead(
      team1Code: team1Code,
      team2Code: team2Code,
      totalMatches: totalMatches,
      team1Wins: team1Wins,
      team2Wins: team2Wins,
      draws: draws,
      team1Goals: team1Goals,
      team2Goals: team2Goals,
      worldCupMatches: worldCupMatches,
    );
  }

  static WorldCupTournament createTournament({
    int year = 2022,
    String winner = 'Argentina',
    String winnerCode = 'ARG',
  }) {
    return WorldCupTournament(
      year: year,
      hostCountries: const ['Qatar'],
      hostCodes: const ['QAT'],
      winner: winner,
      winnerCode: winnerCode,
      runnerUp: 'France',
      runnerUpCode: 'FRA',
      thirdPlace: 'Croatia',
      thirdPlaceCode: 'CRO',
      fourthPlace: 'Morocco',
      fourthPlaceCode: 'MAR',
      totalTeams: 32,
      totalMatches: 64,
      totalGoals: 172,
      topScorer: 'Kylian Mbappe',
      topScorerCountry: 'France',
      topScorerGoals: 8,
      finalScore: '3-3 (4-2 pen)',
      finalVenue: 'Lusail Stadium',
      finalCity: 'Lusail',
      finalAttendance: 88966,
      highlights: const ['Messi wins World Cup'],
    );
  }

  static WorldCupRecord createRecord({
    String id = 'record_1',
    String category = 'Most Goals',
    String record = 'Most goals in a single tournament',
    String holder = 'Just Fontaine',
    String holderType = 'player',
    dynamic value = 13,
  }) {
    return WorldCupRecord(
      id: id,
      category: category,
      record: record,
      holder: holder,
      holderType: holderType,
      value: value,
    );
  }

  static MatchSummary createMatchSummary({
    String id = 'USA_MEX',
    String team1Code = 'USA',
    String team2Code = 'MEX',
    String team1Name = 'United States',
    String team2Name = 'Mexico',
  }) {
    return MatchSummary(
      id: id,
      team1Code: team1Code,
      team2Code: team2Code,
      team1Name: team1Name,
      team2Name: team2Name,
      historicalAnalysis: 'Historic rivalry in CONCACAF.',
      keyStorylines: const ['Border rivalry', 'Host nation advantage'],
      playersToWatch: const [
        PlayerToWatch(
          name: 'Christian Pulisic',
          teamCode: 'USA',
          position: 'Forward',
          reason: 'Key creative force',
        ),
      ],
      tacticalPreview: 'USA expected to press high.',
      prediction: const MatchPredictionSummary(
        predictedOutcome: 'USA',
        predictedScore: '2-1',
        confidence: 65,
        reasoning: 'Home advantage and form favor USA.',
      ),
      funFacts: const ['100th meeting between these rivals'],
    );
  }
}
