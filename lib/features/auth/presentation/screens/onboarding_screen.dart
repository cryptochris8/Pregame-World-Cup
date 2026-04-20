import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/app_theme.dart';
import '../../../../injection_container.dart' as di;

/// Key used to store the onboarding-seen flag in SharedPreferences.
const String kHasSeenOnboardingKey = 'hasSeenOnboarding';

/// A 3-screen onboarding flow shown to new users after their first login.
///
/// Pages:
/// 1. "Welcome to Pregame" — app intro with both pillars
/// 2. "Match Intelligence" — AI predictions, analysis, city guides
/// 3. "Connect with Fans" — watch parties, venues, social features
///
/// Stores a [kHasSeenOnboardingKey] flag in SharedPreferences so it only
/// shows once per device.
class OnboardingScreen extends StatefulWidget {
  /// Called when the user completes onboarding (taps "Get Started").
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  /// Returns `true` if the user has already seen onboarding.
  static Future<bool> hasBeenSeen() async {
    final prefs = di.sl<SharedPreferences>();
    return prefs.getBool(kHasSeenOnboardingKey) ?? false;
  }

  /// Marks onboarding as seen.
  static Future<void> markAsSeen() async {
    final prefs = di.sl<SharedPreferences>();
    await prefs.setBool(kHasSeenOnboardingKey, true);
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const int _totalPages = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  Future<void> _onGetStarted() async {
    await OnboardingScreen.markAsSeen();
    widget.onComplete();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() async {
    await OnboardingScreen.markAsSeen();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 16),
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    _currentPage < _totalPages - 1 ? 'Skip' : '',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: const [
                  _WelcomePage(),
                  _MatchIntelligencePage(),
                  _ConnectWithFansPage(),
                ],
              ),
            ),

            // Dot indicators
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _totalPages,
                  (index) => _DotIndicator(isActive: index == _currentPage),
                ),
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: _currentPage == _totalPages - 1
                    ? _GradientButton(
                        text: 'Get Started',
                        onPressed: _onGetStarted,
                      )
                    : _GradientButton(
                        text: 'Next',
                        onPressed: _nextPage,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page 1: Welcome to Pregame
// ---------------------------------------------------------------------------

class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: const Image(
              image: AssetImage('assets/logos/pregame_logo.png'),
              height: 120,
              width: 120,
            ),
          ),
          const SizedBox(height: 32),

          // Title
          ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.cardGradient.createShader(bounds),
            child: const Text(
              'Welcome to Pregame',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Description
          const Text(
            'Your ultimate companion for soccer\'s biggest summer.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textLight,
              fontSize: 17,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Expert match analysis meets the social pregame '
            '— everything you need before kickoff.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.85),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page 2: Match Intelligence
// ---------------------------------------------------------------------------

class _MatchIntelligencePage extends StatelessWidget {
  const _MatchIntelligencePage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppTheme.cardGradient,
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.analytics_outlined,
              size: 52,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),

          ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.cardGradient.createShader(bounds),
            child: const Text(
              'Match Intelligence',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 20),

          const _FeatureRow(
            icon: Icons.psychology_outlined,
            text: 'AI-powered predictions for every match',
          ),
          const SizedBox(height: 14),
          const _FeatureRow(
            icon: Icons.article_outlined,
            text: 'Expert pregame analysis and insights',
          ),
          const SizedBox(height: 14),
          const _FeatureRow(
            icon: Icons.location_city_outlined,
            text: 'City guides for all host venues',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page 3: Connect with Fans
// ---------------------------------------------------------------------------

class _ConnectWithFansPage extends StatelessWidget {
  const _ConnectWithFansPage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppTheme.buttonGradient,
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.groups_outlined,
              size: 52,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),

          ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.buttonGradient.createShader(bounds),
            child: const Text(
              'Connect with Fans',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 20),

          const _FeatureRow(
            icon: Icons.celebration_outlined,
            text: 'Find watch parties near you',
          ),
          const SizedBox(height: 14),
          const _FeatureRow(
            icon: Icons.sports_bar_outlined,
            text: 'Discover bars, restaurants, and fan zones',
          ),
          const SizedBox(height: 14),
          const _FeatureRow(
            icon: Icons.people_outlined,
            text: 'Connect with fans from around the world',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.backgroundCard,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryOrange, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppTheme.textLight,
              fontSize: 15,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _DotIndicator extends StatelessWidget {
  final bool isActive;

  const _DotIndicator({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryOrange : AppTheme.backgroundElevated,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _GradientButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.buttonGradientDecoration,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
