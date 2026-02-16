import 'package:pregame_world_cup/core/entities/game_intelligence.dart';

/// Generates venue recommendations for watch parties and sports bars
/// based on World Cup match analysis data.
class ESPNVenueRecommendationGenerator {
  /// Generate venue recommendations for watch parties and sports bars
  VenueRecommendations generateVenueRecommendations({
    required double crowdFactor,
    required bool isRivalry,
    required bool hasChampImplications,
    required String homeTeam,
    required String awayTeam,
  }) {
    // Calculate expected traffic increase
    double trafficIncrease = (crowdFactor - 1.0) * 100; // Convert to percentage

    // Generate staffing recommendations
    String staffingRec = _generateStaffingRecommendation(crowdFactor);

    // Suggest specials based on match type
    List<String> specials = _suggestSpecials(isRivalry, hasChampImplications, homeTeam, awayTeam);

    // Inventory advice
    String inventoryAdvice = _generateInventoryAdvice(crowdFactor, isRivalry);

    // Marketing opportunity
    String marketingOpp = _generateMarketingOpportunity(isRivalry, hasChampImplications, homeTeam, awayTeam);

    // Revenue projection (assuming average customer spends $30 at a watch party)
    double revenueProjection = trafficIncrease * 0.01 * 30 * 50; // Estimate for 50-person baseline

    return VenueRecommendations(
      expectedTrafficIncrease: trafficIncrease,
      staffingRecommendation: staffingRec,
      suggestedSpecials: specials,
      inventoryAdvice: inventoryAdvice,
      marketingOpportunity: marketingOpp,
      revenueProjection: revenueProjection,
    );
  }

  String _generateStaffingRecommendation(double crowdFactor) {
    if (crowdFactor >= 2.5) {
      return 'Schedule 3x normal staff - expect exceptional crowds for this World Cup match';
    } else if (crowdFactor >= 2.0) {
      return 'Schedule 2x normal staff - high crowd expected for this match';
    } else if (crowdFactor >= 1.5) {
      return 'Schedule 1.5x normal staff - above average crowd expected';
    } else {
      return 'Normal staffing should be sufficient';
    }
  }

  List<String> _suggestSpecials(bool isRivalry, bool hasChampImplications, String homeTeam, String awayTeam) {
    List<String> specials = [];

    if (isRivalry) {
      specials.add('Rivalry Special: Wear your team colors for 10% off');
      specials.add('$homeTeam vs $awayTeam Watch Party Platter');
    }

    if (hasChampImplications) {
      specials.add('Knockout Round Special: Premium beer buckets & shareables');
      specials.add('World Cup Final Watch Party Package');
    }

    specials.add('Match Day Brunch - catch morning kickoffs with breakfast specials');
    specials.add('Goal Celebration Shot Special - free shot on every goal');
    specials.add('Half-Time Happy Hour - drink specials during the break');

    return specials;
  }

  String _generateInventoryAdvice(double crowdFactor, bool isRivalry) {
    List<String> advice = [];

    if (crowdFactor >= 2.0) {
      advice.add('Stock 3x normal beer & cocktail inventory');
      advice.add('Extra appetizer platters - nachos, wings, sliders');
    }

    if (isRivalry) {
      advice.add('Country flags and team scarves for decoration');
      advice.add('Premium drinks for celebration toasts');
    }

    advice.add('Consider international food specials matching the teams playing');

    return advice.join(', ');
  }

  String _generateMarketingOpportunity(bool isRivalry, bool hasChampImplications, String homeTeam, String awayTeam) {
    if (isRivalry && hasChampImplications) {
      return 'HUGE OPPORTUNITY: Historic rivalry in a knockout match - host a mega watch party, social media blitz, reservation-only VIP seating';
    } else if (isRivalry) {
      return 'Major international rivalry - promote as THE place to watch, themed decorations with both countries\' flags, fan contests';
    } else if (hasChampImplications) {
      return 'Knockout stage drama - position as "the place to watch World Cup history unfold"';
    } else {
      return 'Group stage match - promote World Cup atmosphere with international food & drink specials';
    }
  }
}
