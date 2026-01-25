import 'package:flutter/material.dart';

/// Input widget for sending messages in match chat
class MatchChatInput extends StatefulWidget {
  final bool enabled;
  final Function(String message) onSend;
  final VoidCallback onLeave;

  const MatchChatInput({
    super.key,
    this.enabled = true,
    required this.onSend,
    required this.onLeave,
  });

  @override
  State<MatchChatInput> createState() => _MatchChatInputState();
}

class _MatchChatInputState extends State<MatchChatInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateCanSend);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateCanSend() {
    final canSend = _controller.text.trim().isNotEmpty;
    if (canSend != _canSend) {
      setState(() => _canSend = canSend);
    }
  }

  void _send() {
    if (!_canSend || !widget.enabled) return;

    final message = _controller.text.trim();
    if (message.isEmpty) return;

    widget.onSend(message);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Leave button
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: theme.colorScheme.error,
            ),
            onPressed: widget.onLeave,
            tooltip: 'Leave Chat',
          ),

          // Message input
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 100),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      enabled: widget.enabled,
                      maxLines: null,
                      maxLength: 500,
                      buildCounter: (context,
                              {required currentLength,
                              required isFocused,
                              maxLength}) =>
                          null,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: widget.enabled
                            ? 'Type a message...'
                            : 'Please wait...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  // Character count indicator
                  if (_controller.text.length > 400)
                    Padding(
                      padding: const EdgeInsets.only(right: 8, bottom: 12),
                      child: Text(
                        '${_controller.text.length}/500',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _controller.text.length > 480
                              ? theme.colorScheme.error
                              : theme.colorScheme.outline,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Send button
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: IconButton.filled(
              onPressed: _canSend && widget.enabled ? _send : null,
              icon: const Icon(Icons.send),
              style: IconButton.styleFrom(
                backgroundColor: _canSend && widget.enabled
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHigh,
                foregroundColor: _canSend && widget.enabled
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Emoji picker for message input
class EmojiPicker extends StatelessWidget {
  final Function(String emoji) onEmojiSelected;

  const EmojiPicker({
    super.key,
    required this.onEmojiSelected,
  });

  static const List<String> commonEmojis = [
    '😀', '😂', '🤣', '😊', '😍', '🥳', '😎', '🤔',
    '😱', '😤', '😢', '😭', '🙏', '👏', '👍', '👎',
    '🔥', '💪', '⚽', '🏆', '🎉', '❤️', '💔', '🙌',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: commonEmojis.length,
        itemBuilder: (context, index) {
          final emoji = commonEmojis[index];
          return InkWell(
            onTap: () => onEmojiSelected(emoji),
            borderRadius: BorderRadius.circular(8),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          );
        },
      ),
    );
  }
}
