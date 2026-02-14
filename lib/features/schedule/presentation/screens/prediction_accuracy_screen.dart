import 'package:flutter/material.dart';
import '../../../../core/services/game_prediction_service.dart';
import '../../../../core/services/logging_service.dart';
import '../../../../config/theme_helper.dart';
import '../widgets/ai_performance_tab.dart';
import '../widgets/user_stats_tab.dart';
import '../widgets/prediction_leaderboard_tab.dart';

/// Screen displaying prediction accuracy statistics and leaderboards
class PredictionAccuracyScreen extends StatefulWidget {
  const PredictionAccuracyScreen({super.key});

  @override
  State<PredictionAccuracyScreen> createState() => _PredictionAccuracyScreenState();
}

class _PredictionAccuracyScreenState extends State<PredictionAccuracyScreen>
    with SingleTickerProviderStateMixin {
  final GamePredictionService _predictionService = GamePredictionService();

  late TabController _tabController;

  PredictionAccuracyStats? _accuracyStats;
  List<UserAccuracyStats> _leaderboard = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAccuracyData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAccuracyData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load accuracy stats and leaderboard in parallel
      final results = await Future.wait([
        _predictionService.getPredictionAccuracyStats(),
        _predictionService.getPredictionLeaderboard(limit: 20),
      ]);

      if (mounted) {
        setState(() {
          _accuracyStats = results[0] as PredictionAccuracyStats;
          _leaderboard = results[1] as List<UserAccuracyStats>;
          _isLoading = false;
        });
      }
    } catch (e) {
      LoggingService.error('Error loading accuracy data: $e', tag: 'PredictionAccuracyScreen');

      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeHelper.backgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Prediction Accuracy',
          style: ThemeHelper.h2(context),
        ),
        backgroundColor: ThemeHelper.surfaceColor(context),
        foregroundColor: ThemeHelper.textColor(context),
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.auto_awesome),
              text: 'AI Performance',
            ),
            Tab(
              icon: Icon(Icons.person),
              text: 'My Stats',
            ),
            Tab(
              icon: Icon(Icons.leaderboard),
              text: 'Leaderboard',
            ),
          ],
          labelColor: ThemeHelper.favoriteColor,
          unselectedLabelColor: ThemeHelper.textSecondaryColor(context),
          indicatorColor: ThemeHelper.favoriteColor,
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: ThemeHelper.favoriteColor),
            )
          : _error != null
              ? _buildErrorWidget()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    AIPerformanceTab(accuracyStats: _accuracyStats),
                    UserStatsTab(accuracyStats: _accuracyStats),
                    PredictionLeaderboardTab(leaderboard: _leaderboard),
                  ],
                ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error Loading Data',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAccuracyData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[300],
                foregroundColor: Colors.brown[800],
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
