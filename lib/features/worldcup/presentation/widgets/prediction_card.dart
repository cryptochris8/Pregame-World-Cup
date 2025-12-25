import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../domain/entities/entities.dart';
import 'team_flag.dart';

/// Card displaying a user's prediction for a match
class PredictionCard extends StatelessWidget {
  /// The prediction to display
  final MatchPrediction prediction;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  /// Callback when edit is requested
  final VoidCallback? onEdit;

  /// Callback when delete is requested
  final VoidCallback? onDelete;

  /// Whether to show the match date
  final bool showDate;

  /// Whether to show the result (if evaluated)
  final bool showResult;

  const PredictionCard({
    super.key,
    required this.prediction,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showDate = true,
    this.showResult = true,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = AppTheme.backgroundCard;
    Color? borderColor;

    if (!prediction.isPending && showResult) {
      if (prediction.exactScoreCorrect) {
        backgroundColor = AppTheme.secondaryEmerald.withOpacity(0.15);
        borderColor = AppTheme.secondaryEmerald;
      } else if (prediction.resultCorrect) {
        backgroundColor = AppTheme.primaryOrange.withOpacity(0.15);
        borderColor = AppTheme.primaryOrange;
      } else {
        backgroundColor = AppTheme.secondaryRose.withOpacity(0.15);
        borderColor = AppTheme.secondaryRose;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor ?? Colors.white.withOpacity(0.1),
          width: borderColor != null ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and status row
                if (showDate || !prediction.isPending) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (showDate && prediction.matchDate != null)
                        Text(
                          _formatDate(prediction.matchDate!),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                        ),
                      if (!prediction.isPending && showResult)
                        _buildResultBadge(context),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // Teams and prediction
                Row(
                  children: [
                    // Home team
                    Expanded(
                      child: Row(
                        children: [
                          if (prediction.homeTeamCode != null)
                            TeamFlag(
                              teamCode: prediction.homeTeamCode,
                              size: 24,
                            ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              prediction.homeTeamName ?? prediction.homeTeamCode ?? 'Home',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Prediction score
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        prediction.predictionDisplay,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // Away team
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              prediction.awayTeamName ?? prediction.awayTeamCode ?? 'Away',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (prediction.awayTeamCode != null)
                            TeamFlag(
                              teamCode: prediction.awayTeamCode,
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Points earned (if evaluated)
                if (!prediction.isPending && showResult) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: 16,
                        color: prediction.pointsEarned > 0
                            ? AppTheme.accentGold
                            : Colors.white38,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${prediction.pointsEarned} ${prediction.pointsEarned == 1 ? 'point' : 'points'}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: prediction.pointsEarned > 0
                              ? AppTheme.accentGold
                              : Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ],

                // Action buttons (if pending)
                if (prediction.isPending && (onEdit != null || onDelete != null)) ...[
                  Divider(height: 16, color: Colors.white.withOpacity(0.1)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onEdit != null)
                        TextButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit, size: 16, color: AppTheme.secondaryEmerald),
                          label: const Text('Edit', style: TextStyle(color: AppTheme.secondaryEmerald)),
                        ),
                      if (onDelete != null)
                        TextButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete, size: 16, color: AppTheme.secondaryRose),
                          label: const Text('Delete', style: TextStyle(color: AppTheme.secondaryRose)),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultBadge(BuildContext context) {
    String label;
    Color color;
    IconData icon;

    if (prediction.exactScoreCorrect) {
      label = 'Exact Score!';
      color = Colors.green;
      icon = Icons.check_circle;
    } else if (prediction.resultCorrect) {
      label = 'Correct Result';
      color = Colors.orange;
      icon = Icons.check;
    } else {
      label = 'Incorrect';
      color = Colors.red;
      icon = Icons.close;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
}

/// Summary card for prediction statistics
class PredictionStatsCard extends StatelessWidget {
  /// The statistics to display
  final PredictionStats stats;

  const PredictionStatsCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: AppTheme.primaryPurple),
                SizedBox(width: 8),
                Text(
                  'Your Predictions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Main stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  label: 'Total',
                  value: stats.totalPredictions.toString(),
                  color: AppTheme.primaryBlue,
                ),
                _buildStatItem(
                  label: 'Correct',
                  value: stats.correctResults.toString(),
                  color: AppTheme.secondaryEmerald,
                ),
                _buildStatItem(
                  label: 'Exact',
                  value: stats.exactScores.toString(),
                  color: AppTheme.accentGold,
                ),
                _buildStatItem(
                  label: 'Points',
                  value: stats.totalPoints.toString(),
                  color: AppTheme.primaryPurple,
                ),
              ],
            ),

            // Accuracy
            if (stats.totalPredictions > stats.pendingPredictions) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: stats.correctPercentage / 100,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.secondaryEmerald),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${stats.correctPercentage.toStringAsFixed(1)}% accuracy',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white60,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }
}
