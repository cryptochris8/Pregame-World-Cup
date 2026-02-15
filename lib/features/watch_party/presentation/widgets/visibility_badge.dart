import 'package:flutter/material.dart';

import '../../domain/entities/watch_party.dart';

/// Badge showing watch party visibility (public/private)
class VisibilityBadge extends StatelessWidget {
  final WatchPartyVisibility visibility;
  final bool compact;

  const VisibilityBadge({
    super.key,
    required this.visibility,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPublic = visibility == WatchPartyVisibility.public;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: isPublic
            ? const Color(0xFF059669).withValues(alpha:0.1)
            : const Color(0xFFF59E0B).withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPublic
              ? const Color(0xFF059669).withValues(alpha:0.3)
              : const Color(0xFFF59E0B).withValues(alpha:0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPublic ? Icons.public : Icons.lock,
            size: compact ? 10 : 12,
            color: isPublic ? const Color(0xFF059669) : const Color(0xFFF59E0B),
          ),
          const SizedBox(width: 4),
          Text(
            isPublic ? 'Public' : 'Private',
            style: TextStyle(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w500,
              color:
                  isPublic ? const Color(0xFF059669) : const Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }
}

/// Toggle button for selecting visibility
class VisibilityToggle extends StatelessWidget {
  final WatchPartyVisibility value;
  final ValueChanged<WatchPartyVisibility> onChanged;

  const VisibilityToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<WatchPartyVisibility>(
      segments: const [
        ButtonSegment(
          value: WatchPartyVisibility.public,
          label: Text('Public'),
          icon: Icon(Icons.public),
        ),
        ButtonSegment(
          value: WatchPartyVisibility.private,
          label: Text('Private'),
          icon: Icon(Icons.lock),
        ),
      ],
      selected: {value},
      onSelectionChanged: (selection) {
        if (selection.isNotEmpty) {
          onChanged(selection.first);
        }
      },
    );
  }
}
