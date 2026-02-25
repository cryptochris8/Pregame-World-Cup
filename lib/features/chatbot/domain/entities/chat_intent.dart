/// The type of question or request the user is making.
enum ChatIntentType {
  greeting,
  thanks,
  appHelp,
  schedule,
  headToHead,
  matchPreview,
  prediction,
  player,
  injury,
  manager,
  team,
  venue,
  history,
  odds,
  standings,
  squadValue,
  recentForm,
  playerComparison,
  countdown,
  tournamentFacts,
  unknown,
}

/// A classified user intent with extracted entities.
class ChatIntent {
  final ChatIntentType type;

  /// Confidence score from 0.0 to 1.0.
  final double confidence;

  /// Extracted entities (e.g. {"team": "USA", "player": "Messi"}).
  final Map<String, String> entities;

  const ChatIntent({
    required this.type,
    this.confidence = 1.0,
    this.entities = const {},
  });

  String? get team => entities['team'];
  String? get team1 => entities['team1'];
  String? get team2 => entities['team2'];
  String? get player => entities['player'];
  String? get player1 => entities['player1'];
  String? get player2 => entities['player2'];
  String? get venue => entities['venue'];
  String? get year => entities['year'];
  String? get group => entities['group'];

  @override
  String toString() =>
      'ChatIntent($type, confidence=$confidence, entities=$entities)';
}
