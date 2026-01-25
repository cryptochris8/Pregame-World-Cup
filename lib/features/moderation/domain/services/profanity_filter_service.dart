import 'dart:developer' as developer;

/// Result of content filtering
class ContentFilterResult {
  final bool containsProfanity;
  final String filteredText;
  final List<String> flaggedWords;
  final double severityScore;
  final bool shouldAutoReject;

  const ContentFilterResult({
    required this.containsProfanity,
    required this.filteredText,
    required this.flaggedWords,
    required this.severityScore,
    required this.shouldAutoReject,
  });

  factory ContentFilterResult.clean(String text) {
    return ContentFilterResult(
      containsProfanity: false,
      filteredText: text,
      flaggedWords: [],
      severityScore: 0.0,
      shouldAutoReject: false,
    );
  }
}

/// Service for filtering profanity and inappropriate content
class ProfanityFilterService {
  static ProfanityFilterService? _instance;

  ProfanityFilterService._();

  factory ProfanityFilterService() {
    _instance ??= ProfanityFilterService._();
    return _instance!;
  }

  /// Severe profanity that should be auto-rejected
  static const Set<String> _severeProfanity = {
    // Racial slurs and hate speech - auto-reject
    'n-word-variants', // Placeholder - actual words in production
    // Extreme violence terms
    // Terrorist content terms
  };

  /// Standard profanity list (common words to filter)
  static const Set<String> _profanityList = {
    // Common English profanity
    'fuck',
    'fucking',
    'fucked',
    'fucker',
    'fucks',
    'shit',
    'shits',
    'shitting',
    'shitty',
    'bullshit',
    'ass',
    'asshole',
    'assholes',
    'bastard',
    'bastards',
    'bitch',
    'bitches',
    'bitching',
    'damn',
    'damned',
    'dammit',
    'crap',
    'crappy',
    'hell',
    'piss',
    'pissed',
    'dick',
    'dicks',
    'cock',
    'cocks',
    'pussy',
    'cunt',
    'whore',
    'slut',
    'douche',
    'douchebag',
    // Spanish profanity (for Mexico market)
    'puta',
    'mierda',
    'cabron',
    'pendejo',
    'chingar',
    'chingada',
    'culero',
    'verga',
    'pinche',
    'joder',
    'coño',
    'marica',
    // Portuguese profanity (for Brazil fans)
    'porra',
    'merda',
    'caralho',
    'foda',
    'fodase',
    'buceta',
    'viado',
  };

  /// Words that are context-dependent
  static const Set<String> _contextualWords = {
    'kill',
    'murder',
    'attack',
    'bomb',
    'shoot',
    'die',
    'dead',
    'hate',
  };

  /// Scam/spam indicators
  static const Set<String> _scamIndicators = {
    'free money',
    'click here',
    'wire transfer',
    'nigerian prince',
    'lottery winner',
    'congratulations you won',
    'act now',
    'limited time',
    'send money',
    'crypto giveaway',
    'double your',
    'investment opportunity',
  };

  /// Check content for profanity and inappropriate content
  ContentFilterResult filterContent(String text) {
    if (text.isEmpty) {
      return ContentFilterResult.clean(text);
    }

    try {
      final lowerText = text.toLowerCase();
      final List<String> flaggedWords = [];
      String filteredText = text;
      double severityScore = 0.0;
      bool shouldAutoReject = false;

      // Check for severe profanity first (auto-reject)
      for (final word in _severeProfanity) {
        if (_containsWord(lowerText, word)) {
          flaggedWords.add(word);
          severityScore = 1.0;
          shouldAutoReject = true;
          filteredText = _censorWord(filteredText, word);
        }
      }

      // Check for standard profanity
      for (final word in _profanityList) {
        if (_containsWord(lowerText, word)) {
          flaggedWords.add(word);
          severityScore += 0.2;
          filteredText = _censorWord(filteredText, word);
        }
      }

      // Check for scam indicators
      for (final phrase in _scamIndicators) {
        if (lowerText.contains(phrase)) {
          flaggedWords.add(phrase);
          severityScore += 0.5;
          shouldAutoReject = true;
        }
      }

      // Check for contextual words (lower severity)
      int contextualCount = 0;
      for (final word in _contextualWords) {
        if (_containsWord(lowerText, word)) {
          contextualCount++;
        }
      }
      // Multiple violent words together are concerning
      if (contextualCount >= 3) {
        severityScore += 0.3;
        flaggedWords.add('multiple_violent_terms');
      }

      // Check for excessive caps (shouting)
      if (_hasExcessiveCaps(text)) {
        severityScore += 0.1;
      }

      // Check for repeated characters (spam indicator)
      if (_hasRepeatedCharacters(text)) {
        severityScore += 0.1;
      }

      // Cap severity at 1.0
      severityScore = severityScore.clamp(0.0, 1.0);

      return ContentFilterResult(
        containsProfanity: flaggedWords.isNotEmpty,
        filteredText: filteredText,
        flaggedWords: flaggedWords,
        severityScore: severityScore,
        shouldAutoReject: shouldAutoReject || severityScore >= 0.8,
      );
    } catch (e) {
      developer.log('Error filtering content: $e',
          name: 'ProfanityFilterService');
      return ContentFilterResult.clean(text);
    }
  }

  /// Check if text contains a word (with word boundaries)
  bool _containsWord(String text, String word) {
    // Create a regex pattern for word boundaries
    final pattern = RegExp(
      '\\b${RegExp.escape(word)}\\b',
      caseSensitive: false,
    );
    return pattern.hasMatch(text);
  }

  /// Censor a word by replacing middle characters with asterisks
  String _censorWord(String text, String word) {
    final pattern = RegExp(
      '\\b${RegExp.escape(word)}\\b',
      caseSensitive: false,
    );

    return text.replaceAllMapped(pattern, (match) {
      final matched = match.group(0)!;
      if (matched.length <= 2) {
        return '*' * matched.length;
      }
      // Keep first and last character, replace middle with asterisks
      return matched[0] +
          '*' * (matched.length - 2) +
          matched[matched.length - 1];
    });
  }

  /// Check for excessive caps (more than 50% uppercase)
  bool _hasExcessiveCaps(String text) {
    if (text.length < 10) return false;

    final letters = text.replaceAll(RegExp(r'[^a-zA-Z]'), '');
    if (letters.isEmpty) return false;

    final upperCount = letters.replaceAll(RegExp(r'[^A-Z]'), '').length;
    return upperCount / letters.length > 0.5;
  }

  /// Check for repeated characters (like "helloooooo" or "!!!!!!")
  bool _hasRepeatedCharacters(String text) {
    // Check for 4+ repeated characters
    return RegExp(r'(.)\1{3,}').hasMatch(text);
  }

  /// Quick check if content is clean (no filtering needed)
  bool isClean(String text) {
    return !filterContent(text).containsProfanity;
  }

  /// Get censored version of text
  String getCensoredText(String text) {
    return filterContent(text).filteredText;
  }

  /// Check if content should be auto-rejected
  bool shouldReject(String text) {
    return filterContent(text).shouldAutoReject;
  }

  /// Validate username for appropriateness
  ContentFilterResult validateUsername(String username) {
    final result = filterContent(username);

    // Additional username-specific checks
    final lowerName = username.toLowerCase();

    // Check for impersonation patterns
    final impersonationPatterns = [
      'admin',
      'moderator',
      'mod',
      'staff',
      'official',
      'fifa',
      'worldcup',
      'pregame_official',
      'support',
      'help',
    ];

    for (final pattern in impersonationPatterns) {
      if (lowerName.contains(pattern)) {
        return ContentFilterResult(
          containsProfanity: true,
          filteredText: result.filteredText,
          flaggedWords: [...result.flaggedWords, 'impersonation:$pattern'],
          severityScore: 0.7,
          shouldAutoReject: true,
        );
      }
    }

    return result;
  }

  /// Validate watch party name and description
  ContentFilterResult validateWatchPartyContent({
    required String name,
    required String description,
  }) {
    final nameResult = filterContent(name);
    final descResult = filterContent(description);

    final allFlaggedWords = [
      ...nameResult.flaggedWords,
      ...descResult.flaggedWords,
    ];

    final combinedScore = (nameResult.severityScore * 1.5 +
            descResult.severityScore) /
        2.5; // Name violations weighted higher

    return ContentFilterResult(
      containsProfanity: allFlaggedWords.isNotEmpty,
      filteredText: '${nameResult.filteredText}\n${descResult.filteredText}',
      flaggedWords: allFlaggedWords,
      severityScore: combinedScore.clamp(0.0, 1.0),
      shouldAutoReject:
          nameResult.shouldAutoReject || descResult.shouldAutoReject,
    );
  }
}
