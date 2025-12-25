import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/game_schedule.dart';
import '../../domain/entities/game_prediction.dart';
import '../../../../services/prediction_service.dart';
import '../../../auth/domain/services/auth_service.dart';
import '../../../../injection_container.dart';
import '../../../../config/theme_helper.dart';

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

  Widget _buildTeamSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.sports_football,
                color: ThemeHelper.favoriteColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Who will win?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTeamOption(widget.game.homeTeamName, true),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTeamOption(widget.game.awayTeamName, false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamOption(String teamName, bool isHome) {
    final isSelected = _selectedWinner == teamName;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedWinner = teamName;
        });
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? ThemeHelper.favoriteColor.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? ThemeHelper.favoriteColor
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              isHome ? 'HOME' : 'AWAY',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              teamName,
              style: TextStyle(
                color: isSelected ? ThemeHelper.favoriteColor : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (isSelected) ...[
              const SizedBox(height: 8),
              Icon(
                Icons.check_circle,
                color: ThemeHelper.favoriteColor,
                size: 18,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.star,
                color: Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Confidence Level: $_confidenceLevel/5',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final level = index + 1;
              final isSelected = level == _confidenceLevel;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _confidenceLevel = level;
                  });
                  HapticFeedback.selectionClick();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Colors.amber.withValues(alpha: 0.2)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    Icons.star,
                    color: level <= _confidenceLevel
                        ? Colors.amber
                        : Colors.white.withValues(alpha: 0.3),
                    size: 24,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            _getConfidenceText(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getConfidenceText() {
    switch (_confidenceLevel) {
      case 1: return 'Not very confident';
      case 2: return 'Slightly confident';
      case 3: return 'Moderately confident';
      case 4: return 'Very confident';
      case 5: return 'Absolutely certain!';
      default: return '';
    }
  }

  Widget _buildScorePrediction() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.scoreboard,
                color: ThemeHelper.favoriteColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Predict Final Score (Optional)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      widget.game.homeTeamName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _homeScoreController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                '-',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      widget.game.awayTeamName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _awayScoreController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final canPredict = _predictionService.canMakePrediction(widget.game);
    
    return Column(
      children: [
        if (!_showScorePrediction && canPredict) ...[
          TextButton.icon(
            onPressed: () {
              setState(() {
                _showScorePrediction = true;
              });
            },
            icon: const Icon(Icons.add, color: Colors.white70),
            label: const Text(
              'Add Score Prediction',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        if (canPredict)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedWinner != null && !_isLoading
                  ? _makePrediction
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeHelper.favoriteColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.sports_football, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _existingPrediction != null
                              ? 'Update Prediction'
                              : 'Make Prediction',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, color: Colors.white70, size: 20),
                SizedBox(width: 8),
                Text(
                  'Predictions Locked',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_existingPrediction == null && !_isExpanded) {
      // Collapsed state - show simple "Make Prediction" button
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
                Icons.sports_football,
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

    // Expanded state - show full prediction interface
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
                  
                  _buildTeamSelector(),
                  
                  if (_selectedWinner != null) ...[
                    const SizedBox(height: 16),
                    _buildConfidenceSelector(),
                  ],
                  
                  if (_showScorePrediction && _selectedWinner != null) ...[
                    const SizedBox(height: 16),
                    _buildScorePrediction(),
                  ],
                  
                  if (_selectedWinner != null) ...[
                    const SizedBox(height: 20),
                    _buildActionButtons(),
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