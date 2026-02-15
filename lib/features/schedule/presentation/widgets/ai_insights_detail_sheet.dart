import 'package:flutter/material.dart';
import '../../domain/entities/game_schedule.dart';
import 'enhanced_ai_insights_widget.dart';

/// Shows the full detailed AI insights view in a draggable bottom sheet.
void showAIInsightsDetailSheet(BuildContext context, GameSchedule game) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1E3A8A).withValues(alpha: 0.9),
              Colors.purple[800]!.withValues(alpha: 0.7),
              Colors.orange[800]!.withValues(alpha: 0.5),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: EnhancedAIInsightsWidget(
          game: game,
          isCompact: false,
        ),
      ),
    ),
  );
}
