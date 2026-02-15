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
          'Outstanding $wins-$losses season exceeded expectations with elite-level performance');
    } else if (wins >= 8) {
      insights.add(
          'Posted a successful $wins-$losses record with strong program development');
    } else if (wins >= 6) {
      insights.add(
          'Achieved bowl eligibility with a $wins-$losses record in a competitive season');
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
    if (avgScored > 35) {
      insights.add(
          'High-powered offense averaged $avgScored points per game, ranking among conference leaders');
    } else if (avgScored > avgAllowed + 7) {
      insights.add(
          'Balanced offensive attack averaged $avgScored points per game with efficient execution');
    } else if (avgAllowed < 20) {
      insights.add(
          'Stingy defense allowed only $avgAllowed points per game, creating short fields for offense');
    } else if (avgAllowed < avgScored + 7) {
      insights.add(
          'Defensive-minded team with solid $avgAllowed points allowed per game average');
    }

    // Conference performance
    final conference = seasonRecord['conference'];
    final confWins = conference['wins'];
    final confLosses = conference['losses'];
    if (confWins > confLosses) {
      insights.add(
          'Strong conference play with $confWins-$confLosses record against league competition');
    }

    // Home vs Away performance
    final home = seasonRecord['home'];
    final away = seasonRecord['away'];
    if (home['wins'] >= 5) {
      insights.add(
          'Dominated at home with ${home['wins']}-${home['losses']} record, making their stadium a fortress');
    } else if (away['wins'] >= 4) {
      insights.add(
          'Impressive road warriors with ${away['wins']}-${away['losses']} away record');
    }

    // Big wins highlight
    final bigWins = seasonRecord['bigWins'] as List;
    if (bigWins.isNotEmpty) {
      insights.add(
          'Secured ${bigWins.length} signature wins including victories over quality opponents');
    }

    // Add context for generated vs actual data
    if (isGenerated) {
      insights.add(
          'Season analysis based on program expectations and historical performance trends');
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
          '$teamName delivered an exceptional $season campaign, posting an impressive $wins-$losses record that exceeded all expectations and firmly established the program among the nation\'s elite.');
    } else if (wins >= 8) {
      narratives.add(
          'The $season season marked a significant step forward for $teamName, as they compiled a strong $wins-$losses record while averaging $avgScored points per game and demonstrating the program\'s upward trajectory.');
    } else if (wins == losses) {
      narratives.add(
          '$teamName battled through a challenging but character-building $season season, finishing $wins-$losses in a campaign defined by resilience and crucial lessons learned in tight contests.');
    } else if (wins >= 4) {
      narratives.add(
          'Despite facing adversity throughout the $season season, $teamName showed flashes of brilliance while finishing $wins-$losses, providing valuable building blocks for future success.');
    } else {
      narratives.add(
          'The $season season proved to be a developmental year for $teamName, finishing $wins-$losses while gaining invaluable experience against top-tier competition and laying groundwork for program growth.');
    }

    // Offensive/Defensive analysis with specific details
    if (avgScored >= 30) {
      narratives.add(
          'The offense was a consistent bright spot, averaging an impressive $avgScored points per game while showcasing explosive playmaking ability and balanced attack throughout the season.');
    } else if (pointDiff > 5) {
      narratives.add(
          'Strong offensive execution helped carry the team, with $avgScored points per game proving sufficient to outpace opponents while building confidence in key personnel.');
    }

    if (avgAllowed <= 20) {
      narratives.add(
          'The defense anchored the team\'s success, allowing just $avgAllowed points per game and consistently creating short fields for the offense through turnovers and defensive stops.');
    } else if (pointDiff < -5) {
      narratives.add(
          'Defensive struggles proved costly, as the unit allowed $avgAllowed points per game, creating additional pressure on the offense to keep pace in high-scoring affairs.');
    }

    // Game-by-game storytelling based on actual results
    if (blowouts.isNotEmpty) {
      narratives.add(
          'The season featured ${blowouts.length} dominant performances where the team showcased its full potential, including statement victories that demonstrated the program\'s capability against quality opponents.');
    }

    if (closeGames.length >= 4) {
      narratives.add(
          'Perhaps most telling were the ${closeGames.length} games decided by seven points or fewer, where $teamName demonstrated both competitiveness and areas for growth in crucial moments that define championship programs.');
    } else if (closeGames.length >= 2) {
      narratives.add(
          'The team\'s mettle was tested in ${closeGames.length} closely-contested battles, providing invaluable experience in high-pressure situations that will serve the program well moving forward.');
    }

    if (bigWins.isNotEmpty) {
      narratives.add(
          'Signature victories against elite competition highlighted the season, as $teamName proved capable of rising to the occasion and competing with the nation\'s best programs when executing at peak performance.');
    }

    // Forward-looking conclusion based on overall trajectory
    if (wins > losses) {
      narratives.add(
          'The foundation established in $season positions the program for continued success, with key personnel returning and recruiting momentum building toward even greater achievements ahead.');
    } else {
      narratives.add(
          'While the win-loss record may not reflect it, the experience gained and progress shown in key areas during $season provides optimism for the program\'s trajectory and future competitiveness.');
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
    String assessment = 'Solid season with room for improvement';

    if (wins >= 10) {
      grade = 'A';
      assessment = 'Outstanding season that exceeded expectations';
    } else if (wins >= 8) {
      grade = 'B+';
      assessment = 'Very good season with multiple highlights';
    } else if (wins >= 6) {
      grade = 'B';
      assessment = 'Good season with bowl eligibility achieved';
    } else if (wins >= 4) {
      grade = 'C+';
      assessment = 'Disappointing but showed flashes of potential';
    } else {
      grade = 'D';
      assessment = 'Challenging season but valuable experience gained';
    }

    // Delegate to stats generator for sub-sections
    // (imported by the orchestrating service, not here, to avoid circular deps)
    return {
      'seasonGrade': grade,
      'assessment': assessment,
    };
  }

  // ---------------------------------------------------------------------------
  // Conference analysis
  // ---------------------------------------------------------------------------

  /// Analyze conference performance
  static Map<String, dynamic> analyzeConferencePerformance(
      String teamName,
      String conference,
      Map<String, dynamic> seasonRecord,
      Map<String, dynamic> rivalryAnalysis) {
    final overall = seasonRecord['overall'];

    String conferenceStanding = 'Middle of Pack';
    if (overall['wins'] >= 10) {
      conferenceStanding = 'Conference Championship Contender';
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
