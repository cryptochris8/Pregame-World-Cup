import 'package:flutter/material.dart';

/// Inline emoji picker with categorized emoji rows
class MessageEmojiPicker extends StatelessWidget {
  final ValueChanged<String> onEmojiSelected;

  const MessageEmojiPicker({
    super.key,
    required this.onEmojiSelected,
  });

  static const List<String> recentEmojis = ['😀', '😂', '❤️', '👍', '🔥', '🎉', '😍', '👏'];
  static const List<String> sportsEmojis = ['🏈', '🏆', '🎯', '⚡', '🔥', '💪', '🙌', '🎊'];
  static const List<String> foodEmojis = ['🍕', '🍔', '🍟', '🌮', '🍗', '🥤', '🍺', '🎂'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.1),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha:0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEmojiRow('Recent', recentEmojis),
          const SizedBox(height: 16),
          _buildEmojiRow('Sports', sportsEmojis),
          const SizedBox(height: 16),
          _buildEmojiRow('Food & Drinks', foodEmojis),
        ],
      ),
    );
  }

  Widget _buildEmojiRow(String label, List<String> emojis) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: emojis.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => onEmojiSelected(emojis[index]),
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      emojis[index],
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
