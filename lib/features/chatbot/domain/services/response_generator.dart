import '../entities/chat_intent.dart';
import '../entities/chat_response.dart';
import '../../data/services/chatbot_knowledge_base.dart';
import 'responses/common_responses.dart';
import 'responses/match_responses.dart';
import 'responses/prediction_responses.dart';
import 'responses/player_team_responses.dart';
import 'responses/venue_history_responses.dart';

/// Generates data-driven chatbot responses from classified intents.
///
/// Pulls real data from [ChatbotKnowledgeBase] and formats natural-sounding
/// answers with contextual suggestion chips.
///
/// This class acts as a router, delegating to specialized response generators.
class ResponseGenerator {
  final ChatbotKnowledgeBase _kb;
  late final CommonResponses _commonResponses;
  late final MatchResponses _matchResponses;
  late final PredictionResponses _predictionResponses;
  late final PlayerTeamResponses _playerTeamResponses;
  late final VenueHistoryResponses _venueHistoryResponses;

  ResponseGenerator({required ChatbotKnowledgeBase knowledgeBase})
      : _kb = knowledgeBase {
    _commonResponses = const CommonResponses();
    _matchResponses = MatchResponses(_kb);
    _predictionResponses = PredictionResponses(_kb);
    _playerTeamResponses = PlayerTeamResponses(_kb);
    _venueHistoryResponses = VenueHistoryResponses(_kb);
  }

  /// Generate a response for the given classified intent.
  Future<ChatResponse> generate(ChatIntent intent) async {
    switch (intent.type) {
      case ChatIntentType.greeting:
        return _commonResponses.greeting(intent);
      case ChatIntentType.thanks:
        return _commonResponses.thanks(intent);
      case ChatIntentType.appHelp:
        return _commonResponses.appHelp(intent);
      case ChatIntentType.schedule:
        return await _matchResponses.schedule(intent);
      case ChatIntentType.headToHead:
        return await _matchResponses.headToHead(intent);
      case ChatIntentType.matchPreview:
        return await _matchResponses.matchPreview(intent);
      case ChatIntentType.prediction:
        return await _predictionResponses.prediction(intent);
      case ChatIntentType.player:
        return await _playerTeamResponses.player(intent);
      case ChatIntentType.injury:
        return await _playerTeamResponses.injury(intent);
      case ChatIntentType.manager:
        return await _playerTeamResponses.manager(intent);
      case ChatIntentType.team:
        return await _playerTeamResponses.team(intent);
      case ChatIntentType.venue:
        return _venueHistoryResponses.venue(intent);
      case ChatIntentType.history:
        return _venueHistoryResponses.history(intent);
      case ChatIntentType.odds:
        return _matchResponses.odds(intent);
      case ChatIntentType.standings:
        return _matchResponses.standings(intent);
      case ChatIntentType.squadValue:
        return await _playerTeamResponses.squadValue(intent);
      case ChatIntentType.recentForm:
        return await _predictionResponses.recentForm(intent);
      case ChatIntentType.playerComparison:
        return await _playerTeamResponses.playerComparison(intent);
      case ChatIntentType.countdown:
        return _commonResponses.countdown(intent);
      case ChatIntentType.tournamentFacts:
        return _commonResponses.tournamentFacts(intent);
      case ChatIntentType.unknown:
        return _commonResponses.unknown(intent);
    }
  }
}
