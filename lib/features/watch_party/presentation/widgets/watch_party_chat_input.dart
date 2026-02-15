import 'package:flutter/material.dart';

/// Chat input widget for watch party messaging
class WatchPartyChatInput extends StatefulWidget {
  final Function(String) onSend;
  final bool enabled;
  final String? replyingTo;
  final VoidCallback? onCancelReply;
  final String? disabledMessage;

  const WatchPartyChatInput({
    super.key,
    required this.onSend,
    this.enabled = true,
    this.replyingTo,
    this.onCancelReply,
    this.disabledMessage,
  });

  @override
  State<WatchPartyChatInput> createState() => _WatchPartyChatInputState();
}

class _WatchPartyChatInputState extends State<WatchPartyChatInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return _buildDisabledState();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reply indicator
            if (widget.replyingTo != null) _buildReplyIndicator(),

            // Emoji picker
            if (_showEmojiPicker) _buildEmojiPicker(),

            // Input row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // Emoji button
                  IconButton(
                    onPressed: () {
                      setState(() => _showEmojiPicker = !_showEmojiPicker);
                      if (_showEmojiPicker) {
                        _focusNode.unfocus();
                      }
                    },
                    icon: Icon(_showEmojiPicker
                        ? Icons.keyboard
                        : Icons.emoji_emotions_outlined),
                    color: _showEmojiPicker
                        ? const Color(0xFF1E3A8A)
                        : Colors.grey[600],
                  ),

                  // Text field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 4,
                        minLines: 1,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        onSubmitted: (_) => _handleSend(),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Send button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: IconButton(
                      onPressed: _hasText ? _handleSend : null,
                      icon: Icon(
                        Icons.send_rounded,
                        color: _hasText
                            ? const Color(0xFF1E3A8A)
                            : Colors.grey[400],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiPicker() {
    const emojis = [
      '⚽', '🏆', '🥅', '🎯', '🔥', '💪', '👏', '🙌',
      '😀', '😂', '🤣', '😍', '🥳', '😎', '🤔', '😱',
      '👍', '👎', '❤️', '💔', '🎉', '🏟️', '⭐', '🌟',
      '🇺🇸', '🇲🇽', '🇨🇦', '🇧🇷', '🇦🇷', '🇫🇷', '🇩🇪', '🇪🇸',
    ];

    return Container(
      height: 160,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: emojis.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              final text = _controller.text;
              final selection = _controller.selection;
              final newText = text.replaceRange(
                selection.start,
                selection.end,
                emojis[index],
              );
              _controller.text = newText;
              _controller.selection = TextSelection.collapsed(
                offset: selection.start + emojis[index].length,
              );
            },
            child: Center(
              child: Text(
                emojis[index],
                style: const TextStyle(fontSize: 24),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReplyIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Replying to',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF1E3A8A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.replyingTo!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onCancelReply,
            icon: const Icon(Icons.close, size: 18),
            color: Colors.grey[500],
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 16, color: Colors.grey[500]),
            const SizedBox(width: 8),
            Text(
              widget.disabledMessage ?? 'You cannot send messages',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick reaction bar for chat
class QuickReactionBar extends StatelessWidget {
  final Function(String) onReact;
  final List<String> reactions;

  const QuickReactionBar({
    super.key,
    required this.onReact,
    this.reactions = const ['👍', '❤️', '😂', '😮', '😢', '👏'],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: reactions
            .map((emoji) => GestureDetector(
                  onTap: () => onReact(emoji),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
