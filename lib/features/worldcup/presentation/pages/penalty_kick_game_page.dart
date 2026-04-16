import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/app_theme.dart';

/// Full-screen page for the Penalty Kick Challenge mini-game.
///
/// Displays a visually appealing promotional screen with match context
/// and a "Play Now" button that launches the web-based penalty kick game.
class PenaltyKickGamePage extends StatelessWidget {
  /// Optional team names to show match context when navigated from a match.
  final String? homeTeamName;
  final String? awayTeamName;

  /// The URL where the penalty kick game is hosted.
  static const String gameUrl = 'https://pregameworldcup.com/penalty-kick-game';

  const PenaltyKickGamePage({
    super.key,
    this.homeTeamName,
    this.awayTeamName,
  });

  /// Launches the penalty kick game in an external browser.
  Future<void> _launchGame(BuildContext context) async {
    final uri = Uri.parse(gameUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the game. Please try again later.'),
          ),
        );
      }
    }
  }

  bool get _hasMatchContext =>
      homeTeamName != null && awayTeamName != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.mainGradientDecoration,
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              _buildAppBar(context),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildGameIcon(),
                      const SizedBox(height: 32),
                      _buildTitle(),
                      const SizedBox(height: 16),
                      _buildDescription(),
                      if (_hasMatchContext) ...[
                        const SizedBox(height: 24),
                        _buildMatchContext(),
                      ],
                      const SizedBox(height: 40),
                      _buildPlayButton(context),
                      const SizedBox(height: 24),
                      _buildHowToPlay(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Expanded(
            child: Text(
              'Penalty Kick Challenge',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Spacer to balance the back button
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildGameIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.accentGold.withValues(alpha: 0.5),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Icon(
        Icons.sports_soccer,
        size: 56,
        color: AppTheme.accentGold,
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Pregame Challenge',
      style: TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription() {
    return Text(
      'Test your skills before the match! Can you beat the goalkeeper?',
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.85),
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildMatchContext() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryPurple.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.sports,
            color: AppTheme.accentGold,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            '$homeTeamName vs $awayTeamName',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _launchGame(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
        decoration: AppTheme.buttonGradientDecoration,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 28,
            ),
            SizedBox(width: 8),
            Text(
              'Play Now',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowToPlay() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How to Play',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _buildHowToPlayStep(
            icon: Icons.touch_app,
            text: 'Touch and drag to aim at the goal',
          ),
          const SizedBox(height: 8),
          _buildHowToPlayStep(
            icon: Icons.front_hand,
            text: 'Hold to charge power, release to kick',
          ),
          const SizedBox(height: 8),
          _buildHowToPlayStep(
            icon: Icons.emoji_events,
            text: 'Score as many goals as you can!',
          ),
        ],
      ),
    );
  }

  Widget _buildHowToPlayStep({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accentGold, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
