import 'package:flutter/material.dart';

/// Horizontal scrollable row of suggestion chips.
///
/// Tapping a chip invokes [onChipTapped] with the chip text, which the parent
/// screen sends as a message (same as typing + send).
class SuggestionChips extends StatelessWidget {
  final List<String> chips;
  final ValueChanged<String> onChipTapped;

  const SuggestionChips({
    super.key,
    required this.chips,
    required this.onChipTapped,
  });

  @override
  Widget build(BuildContext context) {
    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ActionChip(
            label: Text(
              chips[index],
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onPressed: () => onChipTapped(chips[index]),
          );
        },
      ),
    );
  }
}
