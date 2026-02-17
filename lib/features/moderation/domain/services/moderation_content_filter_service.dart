import 'profanity_filter_service.dart';
import 'moderation_action_service.dart';

/// Handles content filtering, message validation, and watch party validation.
class ModerationContentFilterService {
  final ProfanityFilterService _profanityFilter;
  final ModerationActionService _actionService;

  ModerationContentFilterService({
    required ProfanityFilterService profanityFilter,
    required ModerationActionService actionService,
  })  : _profanityFilter = profanityFilter,
        _actionService = actionService;

  /// Filter content before posting
  ContentFilterResult filterContent(String text) {
    return _profanityFilter.filterContent(text);
  }

  /// Check if content is appropriate
  bool isContentAppropriate(String text) {
    return _profanityFilter.isClean(text);
  }

  /// Get censored version of content
  String getCensoredContent(String text) {
    return _profanityFilter.getCensoredText(text);
  }

  /// Validate and filter message before sending
  Future<MessageValidationResult> validateMessage(String message) async {
    // Check profanity
    final filterResult = _profanityFilter.filterContent(message);

    // Check if user is muted
    final isMuted = await _actionService.isCurrentUserMuted();
    if (isMuted) {
      return const MessageValidationResult(
        isValid: false,
        errorMessage: 'You are currently muted and cannot send messages',
        filteredMessage: null,
      );
    }

    // Auto-reject severely inappropriate content
    if (filterResult.shouldAutoReject) {
      return const MessageValidationResult(
        isValid: false,
        errorMessage: 'This message contains inappropriate content',
        filteredMessage: null,
      );
    }

    // Return filtered message if it contains mild profanity
    if (filterResult.containsProfanity) {
      return MessageValidationResult(
        isValid: true,
        errorMessage: null,
        filteredMessage: filterResult.filteredText,
        wasFiltered: true,
      );
    }

    return MessageValidationResult(
      isValid: true,
      errorMessage: null,
      filteredMessage: message,
      wasFiltered: false,
    );
  }

  /// Validate watch party content
  Future<WatchPartyValidationResult> validateWatchParty({
    required String name,
    required String description,
  }) async {
    // Check if user is suspended
    final isSuspended = await _actionService.isCurrentUserSuspended();
    if (isSuspended) {
      return const WatchPartyValidationResult(
        isValid: false,
        errorMessage:
            'You are currently suspended and cannot create watch parties',
      );
    }

    final filterResult = _profanityFilter.validateWatchPartyContent(
      name: name,
      description: description,
    );

    if (filterResult.shouldAutoReject) {
      return const WatchPartyValidationResult(
        isValid: false,
        errorMessage: 'Watch party content contains inappropriate language',
      );
    }

    if (filterResult.containsProfanity) {
      final parts = filterResult.filteredText.split('\n');
      return WatchPartyValidationResult(
        isValid: true,
        filteredName: parts[0],
        filteredDescription: parts.length > 1 ? parts[1] : '',
        wasFiltered: true,
      );
    }

    return WatchPartyValidationResult(
      isValid: true,
      filteredName: name,
      filteredDescription: description,
      wasFiltered: false,
    );
  }
}

/// Result of message validation
class MessageValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? filteredMessage;
  final bool wasFiltered;

  const MessageValidationResult({
    required this.isValid,
    this.errorMessage,
    this.filteredMessage,
    this.wasFiltered = false,
  });
}

/// Result of watch party validation
class WatchPartyValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? filteredName;
  final String? filteredDescription;
  final bool wasFiltered;

  const WatchPartyValidationResult({
    required this.isValid,
    this.errorMessage,
    this.filteredName,
    this.filteredDescription,
    this.wasFiltered = false,
  });
}
