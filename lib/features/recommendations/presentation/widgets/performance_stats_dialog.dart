import 'package:flutter/material.dart';
import '../../../../core/services/performance_monitor.dart';

/// Dialog displaying performance statistics dashboard.
class PerformanceStatsDialog extends StatelessWidget {
  const PerformanceStatsDialog({super.key});

  /// Show the performance stats dialog.
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const PerformanceStatsDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = PerformanceMonitor.getStats();

    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      title: Text(
        '📊 Performance Dashboard',
        style: TextStyle(color: Colors.orange[300]),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Cache Hits', '${stats['cache_hits']}', Colors.green),
            _buildStatRow('Cache Misses', '${stats['cache_misses']}', Colors.red),
            _buildStatRow('Hit Rate', '${stats['cache_hit_rate']}%', Colors.blue),
            const SizedBox(height: 8),
            _buildStatRow('API Calls', '${stats['api_calls']}', Colors.orange),
            _buildStatRow('Avg Response', '${stats['average_api_time_ms']}ms', Colors.purple),
            _buildStatRow('Pending', '${stats['pending_calls']}', Colors.yellow),
            const SizedBox(height: 16),
            Text(
              '🎯 Performance Grade',
              style: TextStyle(
                color: Colors.orange[300],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            _buildPerformanceGrade(stats),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Performance test feature has been removed for production.'),
                backgroundColor: Colors.orange,
              ),
            );
          },
          child: Text('Run Full Test', style: TextStyle(color: Colors.green[300])),
        ),
        TextButton(
          onPressed: () {
            PerformanceMonitor.printSummary();
            Navigator.of(context).pop();
          },
          child: Text('Print Summary', style: TextStyle(color: Colors.orange[300])),
        ),
        TextButton(
          onPressed: () {
            PerformanceMonitor.reset();
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Performance stats reset')),
            );
          },
          child: Text('Reset', style: TextStyle(color: Colors.red[300])),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close', style: TextStyle(color: Colors.orange[300])),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceGrade(Map<String, dynamic> stats) {
    final hitRate = double.tryParse(stats['cache_hit_rate']) ?? 0.0;
    final avgTime = double.tryParse(stats['average_api_time_ms']) ?? 0.0;

    Color gradeColor = Colors.red;
    String gradeText = 'Needs Improvement';
    IconData gradeIcon = Icons.trending_down;

    if (hitRate >= 80 && avgTime <= 1000) {
      gradeColor = Colors.green;
      gradeText = 'Excellent 🚀';
      gradeIcon = Icons.trending_up;
    } else if (hitRate >= 60 && avgTime <= 2000) {
      gradeColor = Colors.orange;
      gradeText = 'Good 👍';
      gradeIcon = Icons.trending_flat;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: gradeColor.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: gradeColor),
      ),
      child: Row(
        children: [
          Icon(gradeIcon, color: gradeColor),
          const SizedBox(width: 8),
          Text(
            gradeText,
            style: TextStyle(
              color: gradeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
