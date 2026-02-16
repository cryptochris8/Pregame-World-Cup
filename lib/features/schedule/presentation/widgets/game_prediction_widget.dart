import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/game_schedule.dart';
import '../../domain/entities/game_prediction.dart';
import '../../../../services/prediction_service.dart';
import '../../../auth/domain/services/auth_service.dart';
import '../../../../injection_container.dart';
import '../../../../config/theme_helper.dart';
import 'prediction_team_selector.dart';
import 'prediction_confidence_selector.dart';
import 'prediction_score_input.dart';
import 'prediction_action_buttons.dart';

/// Interactive widget for making game predictions
class GamePredictionWidget extends StatefulWidget {
  final GameSchedule game;
  final VoidCallback? onPredictionMade;

  const GamePredictionWidget({
    super.key,
    required this.game,
    this.onPredictionMade,
  });

  @override
  State<GamePredictionWidget> createState() => _GamePredictionWidgetState();
}

class _GamePredictionWidgetState extends State<GamePredictionWidget>
    with TickerProviderStateMixin {
  final PredictionService _predictionService = PredictionService();
  final AuthService _authService = sl<AuthService>();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  GamePrediction? _existingPrediction;
  String? _selectedWinner;
  int _confidenceLevel = 3;
  bool _showScorePrediction = false;
  bool _isLoading = false;
  bool _isExpanded = false;

  final TextEditingController _homeScoreController = TextEditingController();
  final TextEditingController _awayScoreController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _loadExistingPrediction();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _homeScoreController.dispose();
    _awayScoreController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingPrediction() async {
    final user = _authService.currentUser;
    if (user == null) return;

    final prediction = await _predictionService.getUserPrediction(
      user.uid,
      widget.game.gameId,
    );

    if (prediction != null) {
      setState(() {
        _existingPrediction = prediction;
        _selectedWinner = prediction.predictedWinner;
        _confidenceLevel = prediction.confidenceLevel;

        if (prediction.predictedHomeScore != null) {
          _homeScoreController.text = prediction.predictedHomeScore.toString();
        }
        if (prediction.predictedAwayScore != null) {
          _awayScoreController.text = prediction.predictedAwayScore.toString();
        }

        _showScorePrediction = prediction.predictedHomeScore != null ||
                              prediction.predictedAwayScore != null;
      });

      _animationController.forward();
    }
  }

  Future<void> _makePrediction() async {
    final user = _authService.currentUser;
    if (user == null || _selectedWinner == null) return;

    setState(() => _isLoading = true);

    try {
      // Parse score predictions if provided
      int? homeScore;
      int? awayScore;

      if (_showScorePrediction) {
        homeScore = int.tryParse(_homeScoreController.text);
        awayScore = int.tryParse(_awayScoreController.text);
      }

      await _predictionService.makePrediction(
        userId: user.uid,
        gameId: widget.game.gameId,
        predictedWinner: _selectedWinner!,
        predictedHomeScore: homeScore,
        predictedAwayScore: awayScore,
        confidenceLevel: _confidenceLevel,
      );

      // Provide haptic feedback
      HapticFeedback.lightImpact();

      // Reload the prediction to show updated state
      await _loadExistingPrediction();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[300]),
                const SizedBox(width: 8),
                const Text('Prediction saved! 🎯'),
              ],
            ),
            backgroundColor: ThemeHelper.primaryColor(context),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      widget.onPredictionMade?.call();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving prediction: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_existingPrediction == null && !_isExpanded) {
      // Collapsed state - show simple "Make Prediction" button
      return _buildCollapsedState();
    }

    // Expanded state - show full prediction interface
    return _buildExpandedState();
  }

  Widget _buildCollapsedState() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = true;
        });
        _animationController.forward();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ThemeHelper.favoriteColor.withValues(alpha: 0.1),
              ThemeHelper.favoriteColor.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ThemeHelper.favoriteColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_soccer,
              color: ThemeHelper.favoriteColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Make Prediction',
              style: TextStyle(
                color: ThemeHelper.favoriteColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              color: ThemeHelper.favoriteColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedState() {
    final canPredict = _predictionService.canMakePrediction(widget.game);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.psychology,
                        color: ThemeHelper.favoriteColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Game Prediction',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (_existingPrediction != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green),
                          ),
                          child: const Text(
                            'Predicted',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  PredictionTeamSelector(
                    homeTeamName: widget.game.homeTeamName,
                    awayTeamName: widget.game.awayTeamName,
                    selectedWinner: _selectedWinner,
                    onWinnerSelected: (winner) {
                      setState(() {
                        _selectedWinner = winner;
                      });
                    },
                  ),

                  if (_selectedWinner != null) ...[
                    const SizedBox(height: 16),
                    PredictionConfidenceSelector(
                      confidenceLevel: _confidenceLevel,
                      onConfidenceChanged: (level) {
                        setState(() {
                          _confidenceLevel = level;
                        });
                      },
                    ),
                  ],

                  if (_showScorePrediction && _selectedWinner != null) ...[
                    const SizedBox(height: 16),
                    PredictionScoreInput(
                      homeTeamName: widget.game.homeTeamName,
                      awayTeamName: widget.game.awayTeamName,
                      homeScoreController: _homeScoreController,
                      awayScoreController: _awayScoreController,
                    ),
                  ],

                  if (_selectedWinner != null) ...[
                    const SizedBox(height: 20),
                    PredictionActionButtons(
                      canPredict: canPredict,
                      showScorePrediction: _showScorePrediction,
                      isLoading: _isLoading,
                      selectedWinner: _selectedWinner,
                      existingPrediction: _existingPrediction,
                      onShowScorePrediction: () {
                        setState(() {
                          _showScorePrediction = true;
                        });
                      },
                      onMakePrediction: _makePrediction,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
