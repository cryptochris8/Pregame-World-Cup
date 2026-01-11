import 'package:flutter/material.dart';

import '../../domain/entities/game_prediction.dart';
import '../../../../services/prediction_service.dart';
import '../../../auth/domain/services/auth_service.dart';
import '../../../../injection_container.dart';
import '../../../../config/theme_helper.dart';
import '../../../worldcup/presentation/widgets/fan_pass_feature_gate.dart';

/// Screen showing prediction leaderboard and stats
class PredictionLeaderboardScreen extends StatefulWidget {
  const PredictionLeaderboardScreen({super.key});

  @override
  State<PredictionLeaderboardScreen> createState() => _PredictionLeaderboardScreenState();
}

class _PredictionLeaderboardScreenState extends State<PredictionLeaderboardScreen>
    with SingleTickerProviderStateMixin {
  final PredictionService _predictionService = PredictionService();
  final AuthService _authService = sl<AuthService>();
  
  late TabController _tabController;
  List<Map<String, dynamic>> _leaderboard = [];
  PredictionStats? _userStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load leaderboard
      final leaderboard = await _predictionService.getLeaderboard(limit: 50);
      
      // Load user stats if logged in
      PredictionStats? userStats;
      final user = _authService.currentUser;
      if (user != null) {
        userStats = await _predictionService.getUserStats(user.uid);
      }
      
      setState(() {
        _leaderboard = leaderboard;
        _userStats = userStats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading leaderboard: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          'Prediction Leaderboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: ThemeHelper.primaryColor(context),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: ThemeHelper.favoriteColor,
          unselectedLabelColor: Colors.white70,
          indicatorColor: ThemeHelper.favoriteColor,
          tabs: const [
            Tab(
              icon: Icon(Icons.leaderboard),
              text: 'Leaderboard',
            ),
            Tab(
              icon: Icon(Icons.person),
              text: 'My Stats',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLeaderboardTab(),
                _buildMyStatsTab(),
              ],
            ),
    );
  }

  Widget _buildLeaderboardTab() {
    // Gate leaderboard behind Fan Pass (advanced social features)
    return FanPassFeatureGate(
      feature: FanPassFeature.advancedSocialFeatures,
      customMessage: 'See how you rank against other fans! Unlock the full leaderboard with Fan Pass.',
      child: _buildLeaderboardContent(),
    );
  }

  Widget _buildLeaderboardContent() {
    if (_leaderboard.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard,
              size: 64,
              color: ThemeHelper.favoriteColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'No predictions yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Be the first to make predictions!',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _leaderboard.length,
        itemBuilder: (context, index) {
          final entry = _leaderboard[index];
          final stats = entry['stats'] as PredictionStats;
          final rank = entry['rank'] as int;
          final userId = entry['userId'] as String;

          return _buildLeaderboardEntry(rank, userId, stats);
        },
      ),
    );
  }

  Widget _buildLeaderboardEntry(int rank, String userId, PredictionStats stats) {
    final isCurrentUser = _authService.currentUser?.uid == userId;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCurrentUser
              ? [
                  ThemeHelper.favoriteColor.withValues(alpha: 0.2),
                  ThemeHelper.favoriteColor.withValues(alpha: 0.1),
                ]
              : [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.black.withValues(alpha: 0.2),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser
              ? ThemeHelper.favoriteColor
              : Colors.white.withValues(alpha: 0.1),
          width: isCurrentUser ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // User info and stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCurrentUser ? 'You' : 'User ${userId.substring(0, 8)}',
                  style: TextStyle(
                    color: isCurrentUser ? ThemeHelper.favoriteColor : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildStatChip(
                      '${stats.totalPoints} pts',
                      Icons.star,
                      Colors.amber,
                    ),
                    const SizedBox(width: 8),
                    _buildStatChip(
                      '${stats.accuracy.toStringAsFixed(1)}%',
                      Icons.track_changes,
                      Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildStatChip(
                      '${stats.correctPredictions}/${stats.totalPredictions}',
                      Icons.check_circle,
                      Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    if (stats.currentStreak > 0)
                      _buildStatChip(
                        '🔥${stats.currentStreak}',
                        Icons.local_fire_department,
                        Colors.orange,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return ThemeHelper.favoriteColor;
    }
  }

  Widget _buildMyStatsTab() {
    if (_userStats == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_football,
              size: 64,
              color: ThemeHelper.favoriteColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'Start Making Predictions!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your prediction stats will appear here\nonce you start making predictions.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final stats = _userStats!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Overview card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeHelper.favoriteColor.withValues(alpha: 0.2),
                  ThemeHelper.favoriteColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ThemeHelper.favoriteColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.psychology,
                  color: ThemeHelper.favoriteColor,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'Your Prediction Stats',
                  style: TextStyle(
                    color: ThemeHelper.favoriteColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMainStat('Total Points', stats.totalPoints.toString()),
                    _buildMainStat('Accuracy', '${stats.accuracy.toStringAsFixed(1)}%'),
                    _buildMainStat('Predictions', stats.totalPredictions.toString()),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Detailed stats
          _buildStatCard(
            'Performance',
            [
              _buildStatRow('Correct Predictions', stats.correctPredictions.toString()),
              _buildStatRow('Total Predictions', stats.totalPredictions.toString()),
              _buildStatRow('Wrong Predictions', (stats.totalPredictions - stats.correctPredictions).toString()),
              _buildStatRow('Accuracy Rate', '${stats.accuracy.toStringAsFixed(2)}%'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildStatCard(
            'Streaks',
            [
              _buildStatRow('Current Streak', stats.currentStreak.toString()),
              _buildStatRow('Longest Streak', stats.longestStreak.toString()),
              _buildStatRow('Points per Prediction', 
                  stats.totalPredictions > 0 
                      ? '${(stats.totalPoints / stats.totalPredictions).toStringAsFixed(1)}'
                      : '0.0'),
              _buildStatRow('Current Rank', stats.rank > 0 ? '#' + stats.rank.toString() : 'Unranked'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: ThemeHelper.favoriteColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
} 