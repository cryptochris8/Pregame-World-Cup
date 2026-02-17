import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../domain/entities/entities.dart';

/// Expanded card-style AI insight with full prediction details.
///
/// Displays one of three states:
/// - Loading: gradient card with spinner
/// - Prediction available: full card with score, confidence, key factors,
///   and a detailed analysis button
/// - No prediction: call-to-action button to load prediction
class AIInsightsExpandedCard extends StatelessWidget {
  final WorldCupMatch match;
  final AIMatchPrediction? prediction;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onTap;
  final VoidCallback onRefresh;

  const AIInsightsExpandedCard({
    super.key,
    required this.match,
    this.prediction,
    this.isLoading = false,
    this.hasError = false,
    required this.onTap,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      return _buildLoadingCard();
    }

    if (prediction != null) {
      return _buildPredictionCard(prediction!);
    }

    return _buildLoadButton(theme, colorScheme);
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: _buildCardDecoration(),
      child: Column(
        children: [
          _buildEnhancedHeader(isLoading: true),
          const SizedBox(height: 20),
          const CircularProgressIndicator(
            color: AppTheme.primaryOrange,
            strokeWidth: 3,
          ),
          const SizedBox(height: 12),
          const Text(
            'Generating AI prediction...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionCard(AIMatchPrediction prediction) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEnhancedHeader(),
          const SizedBox(height: 16),
          _PredictionSummary(match: match, prediction: prediction),
          const SizedBox(height: 16),
          if (prediction.keyFactors.isNotEmpty)
            _KeyFactorsPreview(keyFactors: prediction.keyFactors),
          const SizedBox(height: 16),
          _ViewDetailedAnalysisButton(onPressed: onRefresh),
        ],
      ),
    );
  }

  Widget _buildLoadButton(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: _buildCardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('\u{1F9E0}', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 6),
                    Text(
                      'Enhanced AI Analysis',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppTheme.buttonGradient,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryOrange.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.psychology, size: 20),
              label: Text(
                hasError ? 'Retry AI Prediction' : 'Get AI Prediction',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppTheme.primaryPurple.withValues(alpha: 0.8),
          AppTheme.primaryBlue.withValues(alpha: 0.6),
          AppTheme.primaryOrange.withValues(alpha: 0.4),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppTheme.accentGold, width: 2),
      boxShadow: [
        BoxShadow(
          color: AppTheme.primaryOrange.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildEnhancedHeader({bool isLoading = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('\u{1F9E0}', style: TextStyle(fontSize: 16)),
              SizedBox(width: 6),
              Text(
                'Enhanced AI Analysis',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (!isLoading)
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, color: AppTheme.primaryOrange, size: 20),
            tooltip: 'Refresh Analysis',
          ),
        if (isLoading)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
            ),
          ),
      ],
    );
  }
}

/// Prediction score and confidence display.
class _PredictionSummary extends StatelessWidget {
  final WorldCupMatch match;
  final AIMatchPrediction prediction;

  const _PredictionSummary({
    required this.match,
    required this.prediction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sports_soccer, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              const Text(
                'AI Prediction:',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(width: 8),
              Text(
                '${match.homeTeamName} vs ${match.awayTeamName}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                prediction.scoreDisplay,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(prediction.confidence).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getConfidenceColor(prediction.confidence).withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  '${prediction.confidence}% confidence',
                  style: TextStyle(
                    color: _getConfidenceColor(prediction.confidence),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(int confidence) {
    if (confidence >= 75) return Colors.green;
    if (confidence >= 50) return Colors.orange;
    return Colors.red;
  }
}

/// Preview of key factors from the AI analysis (top 2 items).
class _KeyFactorsPreview extends StatelessWidget {
  final List<String> keyFactors;

  const _KeyFactorsPreview({required this.keyFactors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: AppTheme.accentGold, size: 18),
              SizedBox(width: 8),
              Text(
                'Key Factors',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...keyFactors.take(2).map(
            (factor) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '\u2022 ',
                    style: TextStyle(color: AppTheme.primaryOrange, fontSize: 14),
                  ),
                  Expanded(
                    child: Text(
                      factor,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (keyFactors.length > 2)
            Text(
              '+${keyFactors.length - 2} more factors...',
              style: TextStyle(
                color: AppTheme.accentGold.withValues(alpha: 0.8),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}

/// Gradient button to view detailed AI analysis.
class _ViewDetailedAnalysisButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ViewDetailedAnalysisButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppTheme.buttonGradient,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryOrange.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.analytics_outlined, size: 20),
        label: const Text(
          'View Detailed Analysis',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
