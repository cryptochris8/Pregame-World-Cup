import 'package:flutter/material.dart';
import '../../../../core/services/game_prediction_service.dart';
import '../../../../core/services/logging_service.dart';
import '../../../../config/theme_helper.dart';
import '../../../worldcup/presentation/widgets/fan_pass_feature_gate.dart';

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
                    _buildAIPerformanceTab(),
                    _buildUserStatsTab(),
                    _buildLeaderboardTab(),
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

  Widget _buildAIPerformanceTab() {
    // Gate AI Performance insights behind Superfan Pass
    return FanPassFeatureGate(
      feature: FanPassFeature.aiMatchInsights,
      customMessage: 'Unlock detailed AI prediction performance analysis and accuracy tracking with Superfan Pass.',
      child: _buildAIPerformanceContent(),
    );
  }

  Widget _buildAIPerformanceContent() {
    if (_accuracyStats?.aiAccuracy == null) {
      return _buildNoDataWidget('No AI prediction data available yet');
    }

    final aiStats = _accuracyStats!.aiAccuracy;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'AI Prediction Performance',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Track how well our AI system predicts game outcomes',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Overall Accuracy Card
          Card(
            color: Colors.brown[800],
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.psychology,
                        color: Colors.orange[300],
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Overall Accuracy',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Accuracy percentage circle
                  SizedBox(
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 120,
                          width: 120,
                          child: CircularProgressIndicator(
                            value: aiStats.overallAccuracy,
                            strokeWidth: 12,
                            backgroundColor: Colors.white30,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getAccuracyColor(aiStats.overallAccuracy),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${(aiStats.overallAccuracy * 100).round()}%',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'Correct',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(
                        'Total Predictions',
                        aiStats.totalPredictions.toString(),
                        Icons.analytics,
                      ),
                      _buildStatColumn(
                        'Correct Predictions',
                        aiStats.correctPredictions.toString(),
                        Icons.check_circle,
                      ),
                      _buildStatColumn(
                        'Score Accuracy',
                        '${(aiStats.averageScoreAccuracy * 100).round()}%',
                        Icons.sports_score,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Performance Insights
          Card(
            color: Colors.brown[700],
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.insights,
                        color: Colors.orange[300],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Performance Insights',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInsightRow(
                    'Accuracy Level',
                    _getAccuracyDescription(aiStats.overallAccuracy),
                    _getAccuracyColor(aiStats.overallAccuracy),
                  ),
                  _buildInsightRow(
                    'Prediction Volume',
                    _getVolumeDescription(aiStats.totalPredictions),
                    Colors.blue[300]!,
                  ),
                  _buildInsightRow(
                    'Score Precision',
                    _getScoreAccuracyDescription(aiStats.averageScoreAccuracy),
                    Colors.purple[300]!,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStatsTab() {
    if (_accuracyStats?.userAccuracy == null) {
      return _buildNoDataWidget('No personal predictions yet.\nMake some predictions to see your stats!');
    }

    final userStats = _accuracyStats!.userAccuracy!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Your Prediction Performance',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Track your prediction accuracy and see how you compare',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // User Accuracy Card
          Card(
            color: Colors.brown[800],
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: Colors.blue[300],
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Your Accuracy',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Accuracy percentage circle
                  SizedBox(
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 120,
                          width: 120,
                          child: CircularProgressIndicator(
                            value: userStats.overallAccuracy,
                            strokeWidth: 12,
                            backgroundColor: Colors.white30,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getAccuracyColor(userStats.overallAccuracy),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${(userStats.overallAccuracy * 100).round()}%',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'Correct',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(
                        'Total Predictions',
                        userStats.totalPredictions.toString(),
                        Icons.analytics,
                      ),
                      _buildStatColumn(
                        'Correct Predictions',
                        userStats.correctPredictions.toString(),
                        Icons.check_circle,
                      ),
                      _buildStatColumn(
                        'Score Accuracy',
                        '${(userStats.averageScoreAccuracy * 100).round()}%',
                        Icons.sports_score,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // AI vs User Comparison
          if (_accuracyStats!.aiAccuracy.totalPredictions > 0) ...[
            Card(
              color: Colors.brown[700],
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.compare,
                          color: Colors.orange[300],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'You vs AI',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildComparisonBar(
                      'Overall Accuracy',
                      userStats.overallAccuracy,
                      _accuracyStats!.aiAccuracy.overallAccuracy,
                    ),
                    const SizedBox(height: 12),
                    _buildComparisonBar(
                      'Score Accuracy',
                      userStats.averageScoreAccuracy,
                      _accuracyStats!.aiAccuracy.averageScoreAccuracy,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    // Gate leaderboard behind Fan Pass (advanced social features)
    return FanPassFeatureGate(
      feature: FanPassFeature.advancedSocialFeatures,
      customMessage: 'See how you rank against other predictors! Unlock the leaderboard with Fan Pass.',
      child: _buildLeaderboardContent(),
    );
  }

  Widget _buildLeaderboardContent() {
    if (_leaderboard.isEmpty) {
      return _buildNoDataWidget('No leaderboard data available yet.\nBe the first to make predictions!');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Top Predictors',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'See how you rank against other users',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Leaderboard
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _leaderboard.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final user = _leaderboard[index];
              final rank = index + 1;
              
              return Card(
                color: rank <= 3 ? Colors.orange[900] : Colors.brown[800],
                elevation: rank <= 3 ? 8 : 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Rank
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getRankColor(rank),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: rank <= 3
                              ? Icon(
                                  _getRankIcon(rank),
                                  color: Colors.white,
                                  size: 24,
                                )
                              : Text(
                                  '$rank',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // User info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Player', // We could show user names if available
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${user.totalPredictions} predictions',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Accuracy
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${(user.overallAccuracy * 100).round()}%',
                            style: TextStyle(
                              color: _getAccuracyColor(user.overallAccuracy),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const Text(
                            'Accuracy',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataWidget(String message) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.brown[800],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.brown[600]!),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.analytics_outlined,
              color: Colors.orange[300],
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.orange[300],
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInsightRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonBar(String label, double userValue, double aiValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text(
              'You: ',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Expanded(
              flex: (userValue * 100).round(),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.blue[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(userValue * 100).round()}%',
              style: TextStyle(
                color: Colors.blue[300],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Text(
              'AI: ',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Expanded(
              flex: (aiValue * 100).round(),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.orange[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(aiValue * 100).round()}%',
              style: TextStyle(
                color: Colors.orange[300],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 0.7) return Colors.green;
    if (accuracy >= 0.5) return Colors.orange;
    return Colors.red;
  }

  String _getAccuracyDescription(double accuracy) {
    if (accuracy >= 0.8) return 'Excellent';
    if (accuracy >= 0.7) return 'Good';
    if (accuracy >= 0.6) return 'Average';
    if (accuracy >= 0.5) return 'Below Average';
    return 'Needs Improvement';
  }

  String _getVolumeDescription(int total) {
    if (total >= 50) return 'High Volume';
    if (total >= 20) return 'Moderate Volume';
    if (total >= 10) return 'Getting Started';
    return 'Early Days';
  }

  String _getScoreAccuracyDescription(double accuracy) {
    if (accuracy >= 0.8) return 'Very Precise';
    if (accuracy >= 0.6) return 'Fairly Accurate';
    if (accuracy >= 0.4) return 'Room for Improvement';
    return 'Developing';
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[400]!;
      default:
        return Colors.blue[600]!;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events;
      case 2:
        return Icons.workspace_premium;
      case 3:
        return Icons.military_tech;
      default:
        return Icons.person;
    }
  }
} 