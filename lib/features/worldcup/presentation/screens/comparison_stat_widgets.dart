import 'package:flutter/material.dart';

import '../../../../config/app_theme.dart';

/// Section header with a gold accent bar
class ComparisonSectionHeader extends StatelessWidget {
  final String title;

  const ComparisonSectionHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: AppTheme.accentGold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// A single comparison row showing a stat with bars for two players
class ComparisonStatRow extends StatelessWidget {
  final String label;
  final double value1;
  final double value2;
  final String unit;
  final bool lowerIsBetter;
  final int decimals;

  const ComparisonStatRow({
    super.key,
    required this.label,
    required this.value1,
    required this.value2,
    required this.unit,
    this.lowerIsBetter = false,
    this.decimals = 0,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = value1 > value2 ? value1 : value2;
    final bar1Width = maxValue > 0 ? value1 / maxValue : 0.0;
    final bar2Width = maxValue > 0 ? value2 / maxValue : 0.0;

    final player1Better =
        lowerIsBetter ? value1 < value2 : value1 > value2;
    final player2Better =
        lowerIsBetter ? value2 < value1 : value2 > value1;
    final tie = value1 == value2;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Player 1 value
              SizedBox(
                width: 50,
                child: Text(
                  '${_formatValue(value1)}${unit.isNotEmpty ? ' $unit' : ''}',
                  style: TextStyle(
                    color: _getColor(player1Better, tie),
                    fontSize: 14,
                    fontWeight: player1Better && !tie
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 8),

              // Player 1 bar
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FractionallySizedBox(
                          widthFactor: bar1Width,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: player1Better && !tie
                                  ? AppTheme.primaryOrange
                                  : Colors.white.withValues(alpha: 0.3),
                              borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(4)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              Container(
                width: 2,
                height: 20,
                color: Colors.white24,
                margin: const EdgeInsets.symmetric(horizontal: 4),
              ),

              // Player 2 bar
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: bar2Width,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: player2Better && !tie
                                  ? AppTheme.accentGold
                                  : Colors.white.withValues(alpha: 0.3),
                              borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(4)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              // Player 2 value
              SizedBox(
                width: 50,
                child: Text(
                  '${_formatValue(value2)}${unit.isNotEmpty ? ' $unit' : ''}',
                  style: TextStyle(
                    color: _getColor(player2Better, tie),
                    fontSize: 14,
                    fontWeight: player2Better && !tie
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getColor(bool isBetter, bool tie) {
    if (tie) return Colors.white60;
    return isBetter ? Colors.green.shade400 : Colors.white60;
  }

  String _formatValue(double value) {
    if (decimals > 0) {
      return value.toStringAsFixed(decimals);
    }
    return value.toInt().toString();
  }
}

/// Empty state widget when no players are selected
class ComparisonEmptyState extends StatelessWidget {
  const ComparisonEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.compare_arrows,
            size: 64,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Select two players to compare',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the cards above to choose players',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
