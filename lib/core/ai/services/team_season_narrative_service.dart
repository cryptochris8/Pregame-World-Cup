/// Generates narrative text, insights, and overall assessments for team season
/// summaries. Extracted from AITeamSeasonSummaryService to keep that class
/// focused on data collection and orchestration.
class TeamSeasonNarrativeService {
  // ---------------------------------------------------------------------------
  // Key insights
  // ---------------------------------------------------------------------------

  /// Generate key insights about the season
  static List<String> generateKeyInsights(
      String teamName,
      Map<String, dynamic> seasonRecord,
      List<dynamic> teamGames) {
    final insights = <String>[];
    final overall = seasonRecord['overall'];
    final wins = overall['wins'];
    final losses = overall['losses'];
    final scoring = seasonRecord['scoring'];
    final isGenerated = seasonRecord['isGenerated'] == true;

    // Win percentage insight
    if (wins >= 10) {
      insights.add(
          'Outstanding $wins-$losses campaign exceeded expectations with elite-level performance');
    } else if (wins >= 8) {
      insights.add(
          'Posted a successful $wins-$losses record with strong squad development');
    } else if (wins >= 6) {
      insights.add(
          'Advanced through the group stage with a $wins-$losses record in a competitive tournament');
    } else if (wins == losses) {
      insights.add(
          'Finished with an even $wins-$losses record showing resilience and growth');
    } else {
      insights.add(
          'Faced challenges with a $wins-$losses record but gained valuable experience for the future');
    }

    // Scoring analysis
    final avgScored = scoring['averageScored'];
    final avgAllowed = scoring['averageAllowed'];
    if (avgScored > 3) {
      insights.add(
          'Prolific attack averaged $avgScored goals per match, ranking among the tournament\'s top scoring sides');
    } else if (avgScored > avgAllowed + 1) {
      insights.add(
          'Balanced attacking play averaged $avgScored goals per match with clinical finishing');
    } else if (avgAllowed < 1) {
      insights.add(
          'Resolute defence conceded only $avgAllowed goals per match, creating a solid foundation');
    } else if (avgAllowed < avgScored + 1) {
      insights.add(
          'Defensively solid side with $avgAllowed goals conceded per match average');
    }

    // Confederation performance
    final conference = seasonRecord['conference'];
    final confWins = conference['wins'];
    final confLosses = conference['losses'];
    if (confWins > confLosses) {
      insights.add(
          'Strong performances with $confWins-$confLosses record against confederation rivals');
    }

    // Home vs Away performance
    final home = seasonRecord['home'];
    final away = seasonRecord['away'];
    if (home['wins'] >= 5) {
      insights.add(
          'Dominant at home with ${home['wins']}-${home['losses']} record, making their venues a fortress');
    } else if (away['wins'] >= 4) {
      insights.add(
          'Impressive road form with ${away['wins']}-${away['losses']} away record');
    }

    // Big wins highlight
    final bigWins = seasonRecord['bigWins'] as List;
    if (bigWins.isNotEmpty) {
      insights.add(
          'Secured ${bigWins.length} signature wins including victories over top-ranked opponents');
    }

    // Add context for generated vs actual data
    if (isGenerated) {
      insights.add(
          'Season analysis based on squad expectations and historical performance trends');
    }

    return insights;
  }

  // ---------------------------------------------------------------------------
  // Season narrative
  // ---------------------------------------------------------------------------

  /// Generate season narrative
  static String generateSeasonNarrative(
      String teamName,
      int season,
      Map<String, dynamic> seasonRecord,
      Map<String, dynamic> gameAnalysis) {
    final overall = seasonRecord['overall'];
    final wins = overall['wins'];
    final losses = overall['losses'];
    final scoring = seasonRecord['scoring'];
    final avgScored = scoring['averageScored'];
    final avgAllowed = scoring['averageAllowed'];
    final pointDiff = avgScored - avgAllowed;

    final bigWins = gameAnalysis['bigWins'] as List;
    final closeGames = gameAnalysis['closeGames'] as List;
    final blowouts = gameAnalysis['blowouts'] as List;

    final narratives = <String>[];

    // Enhanced season opening based on record and performance
    if (wins >= 10) {
      narratives.add(
          '$teamName delivered an exceptional $season campaign, posting an impressive $wins-$losses record that exceeded all expectations and firmly established the squad among international football\'s elite.');
    } else if (wins >= 8) {
      narratives.add(
          'The $season campaign marked a significant step forward for $teamName, as they compiled a strong $wins-$losses record while averaging $avgScored goals per match and demonstrating the squad\'s upward trajectory.');
    } else if (wins == losses) {
      narratives.add(
          '$teamName battled through a challenging but character-building $season campaign, finishing $wins-$losses in a tournament defined by resilience and crucial lessons learned in tight contests.');
    } else if (wins >= 4) {
      narratives.add(
          'Despite facing adversity throughout the $season campaign, $teamName showed flashes of brilliance while finishing $wins-$losses, providing valuable building blocks for future success.');
    } else {
      narratives.add(
          'The $season campaign proved to be a developmental period for $teamName, finishing $wins-$losses while gaining invaluable experience against top-tier international competition and laying groundwork for future tournaments.');
    }

    // Attacking/Defensive analysis with specific details
    if (avgScored >= 3) {
      narratives.add(
          'The attack was a consistent bright spot, averaging an impressive $avgScored goals per match while showcasing clinical finishing and creative playmaking throughout the tournament.');
    } else if (pointDiff > 1) {
      narratives.add(
          'Strong attacking execution helped carry the team, with $avgScored goals per match proving sufficient to outpace opponents while building confidence in key personnel.');
    }

    if (avgAllowed <= 1) {
      narratives.add(
          'The defence anchored the team\'s success, conceding just $avgAllowed goals per match and consistently providing a platform through disciplined shape and timely interventions.');
    } else if (pointDiff < -1) {
      narratives.add(
          'Defensive struggles proved costly, as the backline conceded $avgAllowed goals per match, creating additional pressure on the attack to keep pace in high-scoring encounters.');
    }

    // Game-by-game storytelling based on actual results
    if (blowouts.isNotEmpty) {
      narratives.add(
          'The campaign featured ${blowouts.length} dominant performances where the team showcased its full potential, including statement victories that demonstrated the squad\'s capability against quality opponents.');
    }

    if (closeGames.length >= 4) {
      narratives.add(
          'Perhaps most telling were the ${closeGames.length} matches decided by one goal or fewer, where $teamName demonstrated both competitiveness and areas for growth in crucial moments that define tournament contenders.');
    } else if (closeGames.length >= 2) {
      narratives.add(
          'The team\'s mettle was tested in ${closeGames.length} closely-contested battles, providing invaluable experience in high-pressure situations that will serve the squad well moving forward.');
    }

    if (bigWins.isNotEmpty) {
      narratives.add(
          'Signature victories against elite opposition highlighted the campaign, as $teamName proved capable of rising to the occasion and competing with the world\'s best when executing at peak performance.');
    }

    // Forward-looking conclusion based on overall trajectory
    if (wins > losses) {
      narratives.add(
          'The foundation established in $season positions the squad for continued success, with key players returning and tactical momentum building toward even greater achievements ahead.');
    } else {
      narratives.add(
          'While the win-loss record may not reflect it, the experience gained and progress shown in key areas during $season provides optimism for the team\'s trajectory and future competitiveness.');
    }

    return narratives.join(' ');
  }

  // ---------------------------------------------------------------------------
  // Overall assessment
  // ---------------------------------------------------------------------------

  /// Generate overall assessment
  static Map<String, dynamic> generateOverallAssessment(
      String teamName,
      Map<String, dynamic> seasonRecord,
      Map<String, dynamic> postseasonAnalysis) {
    final overall = seasonRecord['overall'];
    final wins = overall['wins'];

    String grade = 'C';
    String assessment = 'Solid campaign with room for improvement';

    if (wins >= 10) {
      grade = 'A';
      assessment = 'Outstanding campaign that exceeded expectations';
    } else if (wins >= 8) {
      grade = 'B+';
      assessment = 'Very good campaign with multiple highlights';
    } else if (wins >= 6) {
      grade = 'B';
      assessment = 'Good campaign with knockout stage advancement';
    } else if (wins >= 4) {
      grade = 'C+';
      assessment = 'Disappointing but showed flashes of potential';
    } else {
      grade = 'D';
      assessment = 'Challenging campaign but valuable experience gained';
    }

    // Delegate to stats generator for sub-sections
    // (imported by the orchestrating service, not here, to avoid circular deps)
    return {
      'seasonGrade': grade,
      'assessment': assessment,
    };
  }

  // ---------------------------------------------------------------------------
  // Confederation analysis
  // ---------------------------------------------------------------------------

  /// Analyze confederation performance
  static Map<String, dynamic> analyzeConferencePerformance(
      String teamName,
      String conference,
      Map<String, dynamic> seasonRecord,
      Map<String, dynamic> rivalryAnalysis) {
    final overall = seasonRecord['overall'];

    String conferenceStanding = 'Middle of Pack';
    if (overall['wins'] >= 10) {
      conferenceStanding = 'Tournament Contender';
    } else if (overall['wins'] >= 8) {
      conferenceStanding = 'Upper Tier';
    } else if (overall['wins'] <= 4) {
      conferenceStanding = 'Rebuilding';
    }

    return {
      'conference': conference,
      'standing': conferenceStanding,
      'conferenceRecord': seasonRecord['conference'],
      'rivalryGames': rivalryAnalysis,
    };
  }
}
