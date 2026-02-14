# 🤖 AI Integration for Pregame App

This module provides AI-powered features for the Pregame app using OpenAI's GPT and embedding models.

## 🚀 Features

- **Intelligent Venue Recommendations**: AI-powered venue suggestions based on user preferences and game context
- **Match Predictions**: AI-generated predictions for World Cup matches
- **Semantic Search**: Use embeddings to find similar venues and content
- **Natural Language Processing**: Convert user preferences into actionable insights
- **Rate Limiting**: Built-in protection against API limits
- **Fallback Modes**: Graceful degradation when API is unavailable

## Architecture (Consolidated)

The AI service layer follows a 3-tier architecture:

### Tier 1: Core Providers (Low-level API wrappers)
- `ai_service.dart` - OpenAI GPT/embedding API integration
- `claude_service.dart` - Anthropic Claude API integration

### Tier 2: Router (Multi-provider orchestration)
- `multi_provider_ai_service.dart` - Routes requests to optimal provider (Claude for deep analysis, OpenAI for embeddings/quick responses), with automatic fallback

### Tier 3: Domain Services (Feature-specific logic)
- `ai_game_analysis_service.dart` - Game analysis using historical knowledge + AI
- `enhanced_ai_game_analysis_service.dart` - Enhanced analysis with team mapping and real data
- `ai_historical_knowledge_service.dart` - Historical data cache and retrieval
- `ai_team_season_summary_service.dart` - Team season summaries and narratives
- `ai_venue_recommendation_service.dart` - Venue recommendations with embeddings
- `user_preference_learning_service.dart` - User preference learning

### Removed (consolidated)
- ~~`enhanced_ai_prediction_service.dart`~~ - Merged into EnhancedAIGameAnalysisService
- ~~`enhanced_game_summary_service.dart`~~ - Merged into EnhancedAIGameAnalysisService
- ~~`enhanced_player_service.dart`~~ - Merged into EnhancedAIGameAnalysisService
- ~~`claude_sports_integration_service.dart`~~ - Merged into MultiProviderAIService + EnhancedAIGameAnalysisService

```
lib/core/ai/
├── services/
│   ├── ai_service.dart                          # Tier 1: OpenAI provider
│   ├── claude_service.dart                      # Tier 1: Claude provider
│   ├── multi_provider_ai_service.dart           # Tier 2: Provider router
│   ├── ai_game_analysis_service.dart            # Tier 3: Game analysis
│   ├── enhanced_ai_game_analysis_service.dart   # Tier 3: Enhanced analysis
│   ├── ai_historical_knowledge_service.dart     # Tier 3: Historical data
│   ├── ai_team_season_summary_service.dart      # Tier 3: Season summaries
│   ├── ai_venue_recommendation_service.dart     # Tier 3: Venue AI
│   └── user_preference_learning_service.dart    # Tier 3: User learning
├── entities/
│   └── ai_recommendation.dart                   # Data models
└── README.md                                    # This file
```

## ⚙️ Setup

### 1. Get OpenAI API Key

1. Visit [OpenAI Platform](https://platform.openai.com/account/api-keys)
2. Create an account or sign in
3. Generate a new API key
4. Copy the key (it starts with `sk-`)

### 2. Configure API Key

Edit `lib/config/api_keys.dart`:

```dart
class ApiKeys {
  // Replace with your actual OpenAI API key
  static const String openAI = 'sk-your-actual-api-key-here';
  
  // ... other keys
}
```

⚠️ **Security Note**: In production, use environment variables instead of hardcoding keys.

### 3. Initialize AI Service

```dart
import 'package:pregame_world_cup/core/ai/services/ai_service.dart';

final aiService = AIService();
await aiService.initialize();

if (aiService.isAvailable) {
  // AI features are ready
} else {
  // Running in mock mode
}
```

## 🎯 Usage Examples

### Venue Recommendations

```dart
import 'package:pregame_world_cup/core/ai/services/ai_venue_recommendation_service.dart';

final venueService = AIVenueRecommendationService(aiService);

final recommendations = await venueService.generateVenueRecommendations(
  venues: nearbyVenues,
  userPreferences: 'I love sports bars with big screens and great food',
  gameContext: 'Alabama vs Georgia - SEC Championship',
  maxRecommendations: 3,
);

for (final rec in recommendations) {
  print('${rec.title}: ${rec.description}');
  print('Confidence: ${(rec.confidence * 100).toInt()}%');
  print('Reasons: ${rec.reasons.join(', ')}');
}
```

### Game Predictions

```dart
final prediction = await aiService.generateGamePrediction(
  homeTeam: 'Georgia Bulldogs',
  awayTeam: 'Alabama Crimson Tide',
  gameStats: {
    'homeRecord': '11-1',
    'awayRecord': '10-2',
    'homeRanking': 1,
    'awayRanking': 4,
    'venue': 'Mercedes-Benz Stadium',
  },
);

print('AI Prediction: $prediction');
```

### Embeddings & Similarity

```dart
// Generate embeddings for text
final embedding1 = await aiService.generateEmbeddings('sports bar atmosphere');
final embedding2 = await aiService.generateEmbeddings('quiet fine dining');

// Calculate similarity
final similarity = aiService.calculateCosineSimilarity(embedding1, embedding2);
print('Similarity: ${(similarity * 100).toStringAsFixed(1)}%');
```

### Custom AI Completions

```dart
final response = await aiService.generateCompletion(
  prompt: 'What makes a great game day venue?',
  systemMessage: 'You are a helpful sports venue expert.',
  maxTokens: 150,
  temperature: 0.7,
);

print('AI Response: $response');
```

## 🛡️ Error Handling & Fallbacks

The AI service includes robust error handling:

- **Rate Limiting**: Automatically manages API request limits
- **Network Errors**: Graceful handling of connection issues
- **API Errors**: Proper error messages for API failures
- **Mock Mode**: Fallback responses when API key is not configured
- **Timeout Handling**: Prevents hanging requests

```dart
try {
  final recommendations = await venueService.generateVenueRecommendations(
    venues: venues,
    userPreferences: preferences,
  );
  
  if (recommendations.isEmpty) {
    // Handle no recommendations case
    showFallbackVenues();
  } else {
    // Display AI recommendations
    displayRecommendations(recommendations);
  }
} catch (e) {
  // Handle error gracefully
  LoggingService.error('AI recommendation failed: $e');
  showFallbackVenues();
}
```

## 📊 Performance Monitoring

The AI service integrates with the app's performance monitoring:

```dart
// Monitor API performance
PerformanceMonitor.startApiCall('openai_completion');
// ... make API call
PerformanceMonitor.endApiCall('openai_completion', success: true);

// View performance stats
final stats = PerformanceMonitor.getStats();
print('AI API calls: ${stats['api_calls']}');
print('Average response time: ${stats['average_api_time_ms']}ms');
```

## 🔧 Configuration Options

### Model Selection

```dart
// Use different GPT models
final response = await aiService.generateCompletion(
  prompt: 'Your prompt here',
  model: 'gpt-4',           // More capable but slower/expensive
  // model: 'gpt-3.5-turbo', // Faster and cheaper (default)
);

// Use different embedding models
final embeddings = await aiService.generateEmbeddings(
  'your text here',
  model: 'text-embedding-3-large', // More dimensions, better quality
  // model: 'text-embedding-3-small', // Faster, smaller (default)
);
```

### Rate Limiting

```dart
// Built-in rate limiting (60 requests per minute by default)
// Automatically handles:
// - Request queuing when limits are reached
// - Fallback responses during rate limit periods
// - Error handling for 429 responses
```

## 🧪 Testing & Development

### Run AI Demos

```dart
import 'package:pregame_world_cup/core/ai/examples/ai_usage_example.dart';

final demo = AIUsageExample();
await demo.runAllDemos(); // Runs all AI feature demonstrations
```

### Mock Mode

When no API key is configured, the service runs in mock mode:

- Returns realistic but static responses
- Allows development without API costs
- Maintains the same interface for easy switching

## 🚀 Advanced Features

### Custom System Messages

```dart
final venueResponse = await aiService.generateCompletion(
  prompt: 'Recommend a venue for the big game',
  systemMessage: '''
    You are a local sports venue expert. Consider:
    - Atmosphere and crowd energy
    - Food quality and variety  
    - TV screen visibility
    - Parking and accessibility
    Provide specific, actionable recommendations.
  ''',
);
```

### Batch Processing

```dart
// Generate scores for multiple venues efficiently
final scores = await venueService.generateVenueScores(
  venues: allVenues,
  userPreferences: userPrefs,
);

// Sort venues by AI score
venues.sort((a, b) {
  final scoreA = scores[a.placeId] ?? 0.0;
  final scoreB = scores[b.placeId] ?? 0.0;
  return scoreB.compareTo(scoreA);
});
```

## 💰 Cost Management

- **Model Selection**: Use gpt-3.5-turbo for most tasks (cheaper than gpt-4)
- **Token Limits**: Set appropriate maxTokens to control costs
- **Caching**: Implement caching for repeated requests
- **Rate Limiting**: Built-in protection against excessive usage
- **Fallbacks**: Reduce API dependency with smart fallbacks

## 🔍 Troubleshooting

### Common Issues

1. **"Invalid API key" error**
   - Check that your API key is correctly set in `api_keys.dart`
   - Ensure the key starts with `sk-`
   - Verify the key is valid on OpenAI platform

2. **"Rate limit exceeded" error**  
   - The service automatically handles this with fallbacks
   - Consider upgrading your OpenAI plan for higher limits
   - Check your usage on OpenAI dashboard

3. **Mock mode instead of real API**
   - Verify API key is set correctly
   - Check internet connection
   - Look for initialization errors in logs

4. **Slow response times**
   - Consider using gpt-3.5-turbo instead of gpt-4
   - Reduce maxTokens parameter
   - Implement response caching

### Debug Logging

Enable detailed logging to troubleshoot issues:

```dart
// Check service status
print('AI Service available: ${aiService.isAvailable}');
print('Mock mode: ${aiService.isMockMode}');

// Monitor API calls in logs
LoggingService.info('Making AI request...', tag: 'AIService');
```

## 📈 Future Enhancements

- **Fine-tuned Models**: Custom models trained on sports venue data
- **Real-time Updates**: Live game context integration
- **Multi-modal AI**: Image analysis for venue photos
- **Personalization**: Learning from user feedback
- **Offline Mode**: Local AI models for basic features

## 🤝 Contributing

When adding new AI features:

1. Follow existing error handling patterns
2. Include proper logging with tags
3. Add fallback responses for reliability
4. Update this README with new features
5. Add usage examples in the examples directory

---

Happy coding with AI! 🎉 