import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../services/logging_service.dart';
import '../../../config/api_keys.dart';

/// Claude AI Service for enhanced sports analysis
/// 
/// This service provides integration with Anthropic's Claude API for:
/// - Deep sports analysis and strategic insights
/// - Game predictions with detailed reasoning
/// - Historical context analysis
/// - Tactical team comparisons
class ClaudeService {
  static const String _baseUrl = 'https://api.anthropic.com/v1';
  static const String _logTag = 'ClaudeService';
  static const String _model = 'claude-sonnet-4-20250514'; // Latest Claude Sonnet 4
  
  bool _isInitialized = false;
  
  /// Initialize the Claude service
  Future<void> initialize() async {
    try {
      LoggingService.info('Initializing Claude AI service...', tag: _logTag);
      
      if (ApiKeys.claude.isEmpty) {
        LoggingService.warning('Claude API key not configured - running in mock mode', tag: _logTag);
        _isInitialized = false;
        return;
      }
      
      // Test connection
      await _testConnection();
      _isInitialized = true;
      
      LoggingService.info('Claude AI service initialized successfully', tag: _logTag);
    } catch (e) {
      LoggingService.error('Failed to initialize Claude service: $e', tag: _logTag);
      _isInitialized = false;
    }
  }
  
  /// Generate completion using Claude
  Future<String> generateCompletion({
    required String prompt,
    String? systemMessage,
    int maxTokens = 1000,
    double temperature = 0.7,
  }) async {
    if (!_isInitialized) {
      LoggingService.warning('Claude service not initialized - using fallback', tag: _logTag);
      return _generateFallbackResponse(prompt);
    }
    
    try {
      final messages = <Map<String, dynamic>>[];
      
      // Add user message
      messages.add({
        'role': 'user',
        'content': systemMessage != null && systemMessage.isNotEmpty 
            ? 'System: $systemMessage\n\nUser: $prompt'
            : prompt,
      });
      
      final response = await _makeRequest(
        endpoint: '/messages',
        body: {
          'model': _model,
          'max_tokens': maxTokens,
          'temperature': temperature,
          'messages': messages,
        },
      );
      
      final content = response['content'] as List<dynamic>;
      final text = content.first['text'] as String;
      
      LoggingService.info('Claude completion generated successfully (${text.length} chars)', tag: _logTag);
      return text;
      
    } catch (e) {
      LoggingService.error('Claude completion failed: $e', tag: _logTag);
      return _generateFallbackResponse(prompt);
    }
  }
  
  /// Generate deep sports analysis using Claude's analytical capabilities
  Future<String> generateSportsAnalysis({
    required String homeTeam,
    required String awayTeam,
    required Map<String, dynamic> gameContext,
  }) async {
    const systemMessage = '''
You are an expert college football analyst with decades of experience covering SEC and major college football.
Provide comprehensive game analysis that goes beyond surface statistics to examine:

1. Strategic matchups and tactical considerations
2. Historical context and rivalry dynamics  
3. Key player matchups and coaching factors
4. Situational factors (weather, venue, timing)
5. Psychological and momentum factors

Your analysis should be insightful, well-reasoned, and accessible to both casual and serious fans.
Keep your response to 3-4 paragraphs maximum.
''';

    final prompt = '''
Analyze this upcoming college football matchup:

**Game**: $awayTeam @ $homeTeam

**Game Context**:
${_formatGameContext(gameContext)}

Provide a comprehensive analysis focusing on the strategic and tactical elements that will determine the outcome.
What are the key storylines, matchups, and factors that fans should watch for?
''';

    return await generateCompletion(
      prompt: prompt,
      systemMessage: systemMessage,
      maxTokens: 1200,
      temperature: 0.5, // Lower temperature for more focused analysis
    );
  }
  
  /// Generate game prediction with detailed reasoning
  Future<Map<String, dynamic>> generateGamePrediction({
    required String homeTeam,
    required String awayTeam,
    required Map<String, dynamic> gameStats,
  }) async {
    const systemMessage = '''
You are a college football expert making game predictions based on comprehensive analysis.
Provide a structured prediction with:
1. Predicted winner and score
2. Confidence level (0-100)
3. 3 key factors supporting your prediction
4. One potential upset factor to watch

Be analytical but concise. Base predictions on data and logical reasoning.
''';

    final prompt = '''
Predict the outcome of this college football game:

**Matchup**: $awayTeam @ $homeTeam

**Available Data**:
${gameStats.toString()}

Provide your prediction in this format:
PREDICTION: [Winner] [Score]
CONFIDENCE: [0-100]%
KEY FACTORS: 
1. [Factor 1]
2. [Factor 2] 
3. [Factor 3]
UPSET WATCH: [Potential upset factor]
''';

    try {
      final response = await generateCompletion(
        prompt: prompt,
        systemMessage: systemMessage,
        maxTokens: 800,
        temperature: 0.3,
      );
      
      return _parsePredictionResponse(response);
    } catch (e) {
      LoggingService.error('Claude prediction failed: $e', tag: _logTag);
      return {
        'prediction': 'Close game expected',
        'confidence': 50,
        'keyFactors': ['Game too close to call'],
        'analysis': 'Unable to generate detailed prediction at this time.',
      };
    }
  }
  
  /// Generate historical context analysis
  Future<String> generateHistoricalAnalysis({
    required String team1,
    required String team2,
    required Map<String, dynamic> historicalData,
  }) async {
    const systemMessage = '''
You are a college football historian providing context for team matchups.
Focus on meaningful historical patterns, rivalry dynamics, and recent trends
that could influence the upcoming game. Be engaging and informative.
''';

    final prompt = '''
Provide historical context for: $team1 vs $team2

Historical Data Available:
${historicalData.toString()}

What historical trends, rivalry elements, or patterns should fans know about this matchup?
''';

    return await generateCompletion(
      prompt: prompt,
      systemMessage: systemMessage,
      maxTokens: 800,
      temperature: 0.6,
    );
  }
  
  /// Format game context for Claude analysis
  String _formatGameContext(Map<String, dynamic> context) {
    final buffer = StringBuffer();
    
    context.forEach((key, value) {
      if (value != null) {
        buffer.writeln('- $key: $value');
      }
    });
    
    return buffer.toString();
  }
  
  /// Parse Claude's prediction response into structured data
  Map<String, dynamic> _parsePredictionResponse(String response) {
    try {
      final lines = response.split('\n');
      String prediction = 'Game analysis complete';
      int confidence = 50;
      List<String> keyFactors = [];
      String analysis = response;
      
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.startsWith('PREDICTION:')) {
          prediction = trimmed.substring(11).trim();
        } else if (trimmed.startsWith('CONFIDENCE:')) {
          final confStr = trimmed.substring(11).replaceAll('%', '').trim();
          confidence = int.tryParse(confStr) ?? 50;
        } else if (trimmed.startsWith('1.') || trimmed.startsWith('2.') || trimmed.startsWith('3.')) {
          keyFactors.add(trimmed.substring(2).trim());
        }
      }
      
      return {
        'prediction': prediction,
        'confidence': confidence,
        'keyFactors': keyFactors.isNotEmpty ? keyFactors : ['Detailed analysis provided'],
        'analysis': analysis,
      };
    } catch (e) {
      LoggingService.error('Failed to parse Claude prediction: $e', tag: _logTag);
      return {
        'prediction': 'Analysis complete',
        'confidence': 50,
        'keyFactors': ['Game analysis provided'],
        'analysis': response,
      };
    }
  }
  
  /// Test API connection
  Future<void> _testConnection() async {
    try {
      await _makeRequest(
        endpoint: '/messages',
        body: {
          'model': _model,
          'max_tokens': 10,
          'messages': [
            {'role': 'user', 'content': 'Test'}
          ],
        },
      );
      LoggingService.info('Claude API connection successful', tag: _logTag);
    } catch (e) {
      throw Exception('Failed to connect to Claude API: $e');
    }
  }
  
  /// Make HTTP request to Claude API
  Future<Map<String, dynamic>> _makeRequest({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': ApiKeys.claude,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode(body),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final errorBody = response.body;
      LoggingService.error('Claude API error ${response.statusCode}: $errorBody', tag: _logTag);
      throw HttpException(
        'Claude API request failed: ${response.statusCode} - $errorBody',
        uri: uri,
      );
    }
  }
  
  /// Generate fallback response when API is unavailable
  String _generateFallbackResponse(String prompt) {
    final lowerPrompt = prompt.toLowerCase();
    
    if (lowerPrompt.contains('analysis') || lowerPrompt.contains('matchup')) {
      return 'This should be an exciting matchup! Both teams bring unique strengths that could determine the outcome.';
    } else if (lowerPrompt.contains('prediction') || lowerPrompt.contains('score')) {
      return 'This game features competitive teams with the potential for an exciting finish. Check recent team performance for insights.';
    } else if (lowerPrompt.contains('historical') || lowerPrompt.contains('rivalry')) {
      return 'These teams have a rich history that adds extra intensity to their matchups.';
    } else {
      return 'Comprehensive game analysis will be available when Claude AI service is configured.';
    }
  }
  
  /// Check if the service is available (API key configured and initialized)
  bool get isAvailable => _isInitialized && ApiKeys.claude.isNotEmpty;
  
  /// Get current model being used
  String get currentModel => _model;
} 