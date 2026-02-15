import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';
import 'team_flag.dart';

/// Dialog for entering or editing a match prediction
class PredictionDialog extends StatefulWidget {
  /// The match to predict
  final WorldCupMatch match;

  /// Existing prediction (if editing)
  final MatchPrediction? existingPrediction;

  /// Home team details (optional, for AI suggestions)
  final NationalTeam? homeTeam;

  /// Away team details (optional, for AI suggestions)
  final NationalTeam? awayTeam;

  /// Callback when prediction is saved
  final void Function(int homeScore, int awayScore)? onSave;

  const PredictionDialog({
    super.key,
    required this.match,
    this.existingPrediction,
    this.homeTeam,
    this.awayTeam,
    this.onSave,
  });

  /// Show the prediction dialog
  static Future<Map<String, int>?> show(
    BuildContext context, {
    required WorldCupMatch match,
    MatchPrediction? existingPrediction,
    NationalTeam? homeTeam,
    NationalTeam? awayTeam,
  }) async {
    return showDialog<Map<String, int>>(
      context: context,
      builder: (context) => PredictionDialog(
        match: match,
        existingPrediction: existingPrediction,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
      ),
    );
  }

  @override
  State<PredictionDialog> createState() => _PredictionDialogState();
}

class _PredictionDialogState extends State<PredictionDialog> {
  late int _homeScore;
  late int _awayScore;
  bool _isLoadingAI = false;
  String? _aiReasoning;
  String? _aiProvider;

  @override
  void initState() {
    super.initState();
    _homeScore = widget.existingPrediction?.predictedHomeScore ?? 0;
    _awayScore = widget.existingPrediction?.predictedAwayScore ?? 0;
  }

  Future<void> _fetchAISuggestion() async {
    // Check if AI cubit is available
    final aiCubit = context.read<WorldCupAICubit?>();
    if (aiCubit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI predictions not available')),
      );
      return;
    }

    setState(() {
      _isLoadingAI = true;
      _aiReasoning = null;
    });

    try {
      final suggestion = await aiCubit.getSuggestion(
        widget.match,
        homeTeam: widget.homeTeam,
        awayTeam: widget.awayTeam,
      );

      if (mounted) {
        setState(() {
          _homeScore = suggestion['homeScore'] as int? ?? _homeScore;
          _awayScore = suggestion['awayScore'] as int? ?? _awayScore;
          _aiReasoning = suggestion['reasoning'] as String?;
          _aiProvider = suggestion['provider'] as String?;
          _isLoadingAI = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAI = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI suggestion failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Text(
        widget.existingPrediction != null ? 'Edit Prediction' : 'Make Your Prediction',
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Match info
            if (widget.match.dateTime != null)
              Text(
                _formatDateTime(widget.match.dateTime!),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            if (widget.match.venueName != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.match.venueName!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Score entry
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Home team
                Expanded(
                  child: Column(
                    children: [
                      TeamFlag(
                        teamCode: widget.match.homeTeamCode,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.match.homeTeamName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _ScoreSelector(
                        value: _homeScore,
                        onChanged: (value) {
                          setState(() => _homeScore = value);
                        },
                      ),
                    ],
                  ),
                ),

                // VS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'VS',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),

                // Away team
                Expanded(
                  child: Column(
                    children: [
                      TeamFlag(
                        teamCode: widget.match.awayTeamCode,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.match.awayTeamName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _ScoreSelector(
                        value: _awayScore,
                        onChanged: (value) {
                          setState(() => _awayScore = value);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // AI Suggest button
            _buildAISuggestButton(theme, colorScheme),

            const SizedBox(height: 16),

            // AI reasoning (if available)
            if (_aiReasoning != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.purple.withValues(alpha:0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.psychology,
                      size: 16,
                      color: Colors.purple.shade400,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _aiReasoning!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.purple.shade700,
                            ),
                          ),
                          if (_aiProvider != null)
                            Text(
                              'Powered by $_aiProvider',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Predicted outcome
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getPredictedOutcome(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            widget.onSave?.call(_homeScore, _awayScore);
            Navigator.of(context).pop({
              'homeScore': _homeScore,
              'awayScore': _awayScore,
            });
          },
          child: const Text('Save Prediction'),
        ),
      ],
    );
  }

  String _getPredictedOutcome() {
    if (_homeScore > _awayScore) {
      return '${widget.match.homeTeamName} wins';
    } else if (_awayScore > _homeScore) {
      return '${widget.match.awayTeamName} wins';
    } else {
      return 'Draw';
    }
  }

  String _formatDateTime(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildAISuggestButton(ThemeData theme, ColorScheme colorScheme) {
    if (_isLoadingAI) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.purple.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.purple.withValues(alpha:0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.purple.shade400,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'AI thinking...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.purple.shade400,
              ),
            ),
          ],
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: _fetchAISuggestion,
      icon: Icon(
        Icons.psychology,
        size: 18,
        color: Colors.purple.shade400,
      ),
      label: Text(
        'AI Suggest',
        style: TextStyle(color: Colors.purple.shade400),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.purple.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}

/// Widget for selecting a score value
class _ScoreSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  static const int _maxValue = 20;

  const _ScoreSelector({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Increment button
        IconButton(
          onPressed: value < _maxValue ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add_circle_outline),
          iconSize: 32,
          color: colorScheme.primary,
        ),

        // Score display
        Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline,
              width: 2,
            ),
          ),
          child: Text(
            value.toString(),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),

        // Decrement button
        IconButton(
          onPressed: value > 0 ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
          iconSize: 32,
          color: colorScheme.primary,
        ),
      ],
    );
  }
}

/// Quick prediction button that can be added to match cards
class QuickPredictionButton extends StatelessWidget {
  /// The match to predict
  final WorldCupMatch match;

  /// Existing prediction (if any)
  final MatchPrediction? prediction;

  /// Callback when prediction is made/updated
  final void Function(int homeScore, int awayScore)? onPrediction;

  const QuickPredictionButton({
    super.key,
    required this.match,
    this.prediction,
    this.onPrediction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Don't show for completed matches
    if (match.status == MatchStatus.completed) {
      return const SizedBox.shrink();
    }

    // Don't show for live matches (can't change prediction)
    if (match.isLive) {
      if (prediction != null) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Your prediction: ${prediction!.predictionDisplay}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    if (prediction != null) {
      // Show existing prediction with edit option
      return InkWell(
        onTap: () => _showPredictionDialog(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.edit,
                size: 14,
                color: colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 4),
              Text(
                prediction!.predictionDisplay,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show prediction button
    return TextButton.icon(
      onPressed: () => _showPredictionDialog(context),
      icon: const Icon(Icons.sports_soccer, size: 16),
      label: const Text('Predict'),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }

  void _showPredictionDialog(BuildContext context) async {
    final result = await PredictionDialog.show(
      context,
      match: match,
      existingPrediction: prediction,
    );

    if (result != null && onPrediction != null) {
      onPrediction!(result['homeScore']!, result['awayScore']!);
    }
  }
}
