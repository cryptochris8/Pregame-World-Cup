import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';
import '../widgets/widgets.dart';

/// Filter options for predictions list
enum PredictionsFilter {
  all,
  pending,
  correct,
  incorrect,
}

/// Page displaying all user predictions
class PredictionsPage extends StatefulWidget {
  const PredictionsPage({super.key});

  @override
  State<PredictionsPage> createState() => _PredictionsPageState();
}

class _PredictionsPageState extends State<PredictionsPage> {
  PredictionsFilter _filter = PredictionsFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.myPredictions, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          BlocBuilder<PredictionsCubit, PredictionsState>(
            builder: (context, state) {
              if (state.predictions.isEmpty) {
                return const SizedBox.shrink();
              }
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {
                  if (value == 'clear') {
                    _showClearConfirmation(context);
                  } else if (value == 'evaluate') {
                    context.read<PredictionsCubit>().evaluatePredictions();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'evaluate',
                    child: Row(
                      children: [
                        const Icon(Icons.refresh, size: 20),
                        const SizedBox(width: 8),
                        Text(l10n.updateResults),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(l10n.clearAll, style: const TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: AppTheme.mainGradientDecoration,
        child: SafeArea(
          child: BlocBuilder<PredictionsCubit, PredictionsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (state.predictions.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              // Stats card
              Padding(
                padding: const EdgeInsets.all(16),
                child: PredictionStatsCard(stats: state.stats),
              ),

              // Filter chips
              _buildFilterChips(state),

              // Predictions list
              Expanded(
                child: _buildPredictionsList(state),
              ),
            ],
          );
        },
      ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(PredictionsState state) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip(
            label: l10n.all,
            filter: PredictionsFilter.all,
            count: state.predictions.length,
            color: Colors.blue,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: l10n.pending,
            filter: PredictionsFilter.pending,
            count: state.upcomingPredictions.length,
            color: Colors.orange,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: l10n.correct,
            filter: PredictionsFilter.correct,
            count: state.correctPredictions.length,
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: l10n.incorrect,
            filter: PredictionsFilter.incorrect,
            count: state.completedPredictions.length - state.correctPredictions.length,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required PredictionsFilter filter,
    required int count,
    required Color color,
  }) {
    final isSelected = _filter == filter;

    return FilterChip(
      selected: isSelected,
      onSelected: (_) {
        setState(() => _filter = filter);
      },
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white70)),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? color : Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      backgroundColor: AppTheme.backgroundCard,
      selectedColor: color.withValues(alpha:0.3),
      checkmarkColor: color,
      side: BorderSide(
        color: isSelected ? color : Colors.white.withValues(alpha:0.2),
      ),
    );
  }

  Widget _buildPredictionsList(PredictionsState state) {
    List<MatchPrediction> filteredPredictions;

    switch (_filter) {
      case PredictionsFilter.pending:
        filteredPredictions = state.upcomingPredictions;
        break;
      case PredictionsFilter.correct:
        filteredPredictions = state.correctPredictions;
        break;
      case PredictionsFilter.incorrect:
        filteredPredictions = state.completedPredictions
            .where((p) => !p.isCorrect)
            .toList();
        break;
      case PredictionsFilter.all:
        filteredPredictions = state.predictions;
    }

    // Sort by match date (most recent first for pending, oldest first for completed)
    filteredPredictions.sort((a, b) {
      if (a.matchDate == null && b.matchDate == null) return 0;
      if (a.matchDate == null) return 1;
      if (b.matchDate == null) return -1;

      if (_filter == PredictionsFilter.pending) {
        return a.matchDate!.compareTo(b.matchDate!); // Upcoming first
      }
      return b.matchDate!.compareTo(a.matchDate!); // Most recent first
    });

    if (filteredPredictions.isEmpty) {
      return _buildEmptyFilterState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredPredictions.length,
      itemBuilder: (context, index) {
        final prediction = filteredPredictions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PredictionCard(
            prediction: prediction,
            onTap: () => _showPredictionDetails(context, prediction),
            onEdit: prediction.isPending
                ? () => _editPrediction(context, prediction)
                : null,
            onDelete: prediction.isPending
                ? () => _deletePrediction(context, prediction)
                : null,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withValues(alpha:0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sports_soccer,
                size: 64,
                color: AppTheme.primaryPurple.withValues(alpha:0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noPredictionsYet,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.makePredictionsPrompt,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white60,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.secondaryEmerald,
              ),
              icon: const Icon(Icons.arrow_back),
              label: Text(l10n.goToMatches),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFilterState() {
    final l10n = AppLocalizations.of(context);
    String message;
    IconData icon;

    switch (_filter) {
      case PredictionsFilter.pending:
        message = l10n.noPendingPredictions;
        icon = Icons.schedule;
        break;
      case PredictionsFilter.correct:
        message = l10n.noCorrectPredictions;
        icon = Icons.check_circle_outline;
        break;
      case PredictionsFilter.incorrect:
        message = l10n.noIncorrectPredictions;
        icon = Icons.cancel_outlined;
        break;
      default:
        message = l10n.noPredictions;
        icon = Icons.sports_soccer;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.white.withValues(alpha:0.3)),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  void _showPredictionDetails(BuildContext context, MatchPrediction prediction) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _PredictionDetailsSheet(prediction: prediction),
    );
  }

  void _editPrediction(BuildContext context, MatchPrediction prediction) async {
    // Create a minimal match object for the dialog
    final match = WorldCupMatch(
      matchId: prediction.matchId,
      matchNumber: 0,
      stage: MatchStage.groupStage,
      status: MatchStatus.scheduled,
      homeTeamCode: prediction.homeTeamCode,
      homeTeamName: prediction.homeTeamName ?? prediction.homeTeamCode ?? 'Home',
      awayTeamCode: prediction.awayTeamCode,
      awayTeamName: prediction.awayTeamName ?? prediction.awayTeamCode ?? 'Away',
      dateTime: prediction.matchDate,
    );

    final result = await PredictionDialog.show(
      context,
      match: match,
      existingPrediction: prediction,
    );

    if (result != null && context.mounted) {
      context.read<PredictionsCubit>().savePrediction(
            matchId: prediction.matchId,
            homeScore: result['homeScore']!,
            awayScore: result['awayScore']!,
            homeTeamCode: prediction.homeTeamCode,
            homeTeamName: prediction.homeTeamName,
            awayTeamCode: prediction.awayTeamCode,
            awayTeamName: prediction.awayTeamName,
            matchDate: prediction.matchDate,
          );
    }
  }

  void _deletePrediction(BuildContext context, MatchPrediction prediction) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deletePrediction),
        content: Text(
          l10n.deletePredictionConfirm(
            prediction.homeTeamName ?? prediction.homeTeamCode ?? '',
            prediction.awayTeamName ?? prediction.awayTeamCode ?? '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<PredictionsCubit>().deletePredictionForMatch(prediction.matchId);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearAllPredictions),
        content: Text(l10n.clearAllPredictionsConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<PredictionsCubit>().clearAllPredictions();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(l10n.clearAll),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet showing prediction details
class _PredictionDetailsSheet extends StatelessWidget {
  final MatchPrediction prediction;

  const _PredictionDetailsSheet({required this.prediction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Match info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (prediction.homeTeamCode != null)
                TeamFlag(teamCode: prediction.homeTeamCode!, size: 40),
              const SizedBox(width: 16),
              Column(
                children: [
                  Text(
                    'Your Prediction',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      prediction.predictionDisplay,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              if (prediction.awayTeamCode != null)
                TeamFlag(teamCode: prediction.awayTeamCode!, size: 40),
            ],
          ),

          const SizedBox(height: 24),

          // Teams
          Center(
            child: Text(
              '${prediction.homeTeamName ?? prediction.homeTeamCode ?? "Home"} vs ${prediction.awayTeamName ?? prediction.awayTeamCode ?? "Away"}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Match date
          if (prediction.matchDate != null) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                _formatDate(prediction.matchDate!),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Status
          if (!prediction.isPending) ...[
            // Result status
            _buildInfoRow(
              context,
              icon: prediction.exactScoreCorrect
                  ? Icons.check_circle
                  : prediction.resultCorrect
                      ? Icons.check
                      : Icons.close,
              label: AppLocalizations.of(context).result,
              value: prediction.exactScoreCorrect
                  ? AppLocalizations.of(context).exactScore
                  : prediction.resultCorrect
                      ? AppLocalizations.of(context).correctResult
                      : AppLocalizations.of(context).incorrect,
              valueColor: prediction.exactScoreCorrect
                  ? Colors.green
                  : prediction.resultCorrect
                      ? Colors.orange
                      : Colors.red,
            ),
            const SizedBox(height: 12),

            // Points earned
            _buildInfoRow(
              context,
              icon: Icons.emoji_events,
              label: AppLocalizations.of(context).pointsEarned,
              value: '${prediction.pointsEarned}',
              valueColor: prediction.pointsEarned > 0 ? Colors.amber.shade700 : null,
            ),
          ] else ...[
            _buildInfoRow(
              context,
              icon: Icons.schedule,
              label: AppLocalizations.of(context).status,
              value: AppLocalizations.of(context).pending,
              valueColor: Colors.orange,
            ),
          ],

          const SizedBox(height: 24),

          // Close button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: valueColor ?? theme.colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
