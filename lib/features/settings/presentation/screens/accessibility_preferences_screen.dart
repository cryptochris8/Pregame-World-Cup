import 'package:flutter/material.dart';

import '../../../../core/services/accessibility_service.dart';
import '../../../../config/app_theme.dart';

/// Screen for managing accessibility preferences
class AccessibilityPreferencesScreen extends StatefulWidget {
  const AccessibilityPreferencesScreen({super.key});

  @override
  State<AccessibilityPreferencesScreen> createState() =>
      _AccessibilityPreferencesScreenState();
}

class _AccessibilityPreferencesScreenState
    extends State<AccessibilityPreferencesScreen> {
  final AccessibilityService _accessibilityService = AccessibilityService();
  late AccessibilitySettings _settings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _accessibilityService.initialize();
    setState(() {
      _settings = _accessibilityService.settings;
      _isLoading = false;
    });
  }

  Future<void> _updateSetting(AccessibilitySettings newSettings) async {
    setState(() => _settings = newSettings);
    await _accessibilityService.updateSettings(newSettings);

    // Announce change to screen readers
    AccessibilityService.announcePolite('Setting updated');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Accessibility'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: AppTheme.mainGradientDecoration,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibility'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Semantics(
            label: 'Reset all accessibility settings to defaults',
            button: true,
            child: TextButton(
              onPressed: () async {
                await _accessibilityService.resetToDefaults();
                setState(() => _settings = _accessibilityService.settings);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Settings reset to defaults'),
                    ),
                  );
                  AccessibilityService.announceAssertive(
                    'All accessibility settings reset to defaults',
                  );
                }
              },
              child: Text(
                'Reset',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: AppTheme.mainGradientDecoration,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Introduction Card
              _buildIntroCard(theme),

              const SizedBox(height: 24),

              // Vision Section
              _buildVisionSection(theme),

              const SizedBox(height: 24),

              // Motion Section
              _buildMotionSection(theme),

              const SizedBox(height: 24),

              // Interaction Section
              _buildInteractionSection(theme),

              const SizedBox(height: 24),

              // Text Size Section
              _buildTextSizeSection(theme),

              const SizedBox(height: 24),

              // Screen Reader Section
              _buildScreenReaderSection(theme),

              const SizedBox(height: 32),

              // System Settings Info
              _buildSystemSettingsInfo(theme),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha:0.2),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.accessibility_new,
            size: 48,
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          Text(
            'Accessibility Settings',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customize your experience to make Pregame World Cup easier to use.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha:0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisionSection(ThemeData theme) {
    return _buildSection(
      theme: theme,
      title: 'Vision',
      icon: Icons.visibility,
      children: [
        Semantics(
          label: 'High contrast mode',
          hint: _settings.highContrast
              ? 'Currently enabled. Tap to disable high contrast colors'
              : 'Currently disabled. Tap to enable high contrast colors for better visibility',
          child: _buildSwitchTile(
            title: 'High Contrast',
            subtitle: 'Use high contrast colors for better visibility',
            value: _settings.highContrast,
            onChanged: (value) => _updateSetting(
              _settings.copyWith(highContrast: value),
            ),
            icon: Icons.contrast,
          ),
        ),
        const Divider(color: Colors.white24, indent: 56),
        Semantics(
          label: 'Bold text',
          hint: _settings.boldText
              ? 'Currently enabled. Tap to disable bold text'
              : 'Currently disabled. Tap to make all text bolder',
          child: _buildSwitchTile(
            title: 'Bold Text',
            subtitle: 'Make all text bolder and easier to read',
            value: _settings.boldText,
            onChanged: (value) => _updateSetting(
              _settings.copyWith(boldText: value),
            ),
            icon: Icons.format_bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMotionSection(ThemeData theme) {
    return _buildSection(
      theme: theme,
      title: 'Motion',
      icon: Icons.animation,
      children: [
        Semantics(
          label: 'Reduce motion',
          hint: _settings.reduceMotion
              ? 'Currently enabled. Animations are disabled'
              : 'Currently disabled. Tap to reduce or disable animations',
          child: _buildSwitchTile(
            title: 'Reduce Motion',
            subtitle: 'Minimize animations and motion effects',
            value: _settings.reduceMotion,
            onChanged: (value) => _updateSetting(
              _settings.copyWith(reduceMotion: value),
            ),
            icon: Icons.motion_photos_off,
          ),
        ),
      ],
    );
  }

  Widget _buildInteractionSection(ThemeData theme) {
    return _buildSection(
      theme: theme,
      title: 'Interaction',
      icon: Icons.touch_app,
      children: [
        Semantics(
          label: 'Larger touch targets',
          hint: _settings.largerTouchTargets
              ? 'Currently enabled. Buttons and controls are larger'
              : 'Currently disabled. Tap to make buttons and controls larger',
          child: _buildSwitchTile(
            title: 'Larger Touch Targets',
            subtitle: 'Make buttons and controls easier to tap',
            value: _settings.largerTouchTargets,
            onChanged: (value) => _updateSetting(
              _settings.copyWith(largerTouchTargets: value),
            ),
            icon: Icons.crop_square,
          ),
        ),
      ],
    );
  }

  Widget _buildTextSizeSection(ThemeData theme) {
    final currentScale = _settings.textScaleFactor ?? 1.0;
    final scaleLabel = _getScaleLabel(currentScale);

    return _buildSection(
      theme: theme,
      title: 'Text Size',
      icon: Icons.text_fields,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Text Scale',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha:0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      scaleLabel,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Adjust the size of text throughout the app',
                style: TextStyle(
                  color: Colors.white.withValues(alpha:0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              // Preview Text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Sample Text Preview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16 * currentScale,
                    fontWeight:
                        _settings.boldText ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Scale Slider
              Semantics(
                label: 'Text size slider',
                value: scaleLabel,
                hint: 'Slide to adjust text size from small to extra large',
                child: Row(
                  children: [
                    Icon(
                      Icons.text_decrease,
                      color: Colors.white.withValues(alpha:0.7),
                      size: 20,
                    ),
                    Expanded(
                      child: Slider(
                        value: currentScale,
                        min: 0.8,
                        max: 2.0,
                        divisions: 6,
                        activeColor: Colors.orange,
                        inactiveColor: Colors.white.withValues(alpha:0.3),
                        onChanged: (value) {
                          _updateSetting(
                            _settings.copyWith(textScaleFactor: value),
                          );
                        },
                      ),
                    ),
                    Icon(
                      Icons.text_increase,
                      color: Colors.white.withValues(alpha:0.7),
                      size: 24,
                    ),
                  ],
                ),
              ),
              // Scale Options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildScaleOption(theme, 0.8, 'S'),
                  _buildScaleOption(theme, 1.0, 'M'),
                  _buildScaleOption(theme, 1.2, 'L'),
                  _buildScaleOption(theme, 1.5, 'XL'),
                  _buildScaleOption(theme, 2.0, 'XXL'),
                ],
              ),
              const SizedBox(height: 8),
              // Reset to System Default
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    _updateSetting(
                      AccessibilitySettings(
                        highContrast: _settings.highContrast,
                        reduceMotion: _settings.reduceMotion,
                        largerTouchTargets: _settings.largerTouchTargets,
                        textScaleFactor: null, // Reset to system default
                        screenReaderOptimized: _settings.screenReaderOptimized,
                        boldText: _settings.boldText,
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.refresh,
                    color: Colors.white.withValues(alpha:0.7),
                    size: 18,
                  ),
                  label: Text(
                    'Use System Default',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha:0.7),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScaleOption(ThemeData theme, double scale, String label) {
    final isSelected = (_settings.textScaleFactor ?? 1.0) == scale;
    return Semantics(
      label: 'Set text size to $label',
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: () => _updateSetting(
          _settings.copyWith(textScaleFactor: scale),
        ),
        child: Container(
          width: 48,
          height: 36,
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.orange
                : Colors.white.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? Colors.orange
                  : Colors.white.withValues(alpha:0.3),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withValues(alpha:0.7),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getScaleLabel(double scale) {
    if (scale <= 0.8) return 'Small';
    if (scale <= 1.0) return 'Default';
    if (scale <= 1.2) return 'Large';
    if (scale <= 1.5) return 'Extra Large';
    return 'Maximum';
  }

  Widget _buildScreenReaderSection(ThemeData theme) {
    return _buildSection(
      theme: theme,
      title: 'Screen Reader',
      icon: Icons.record_voice_over,
      children: [
        Semantics(
          label: 'Screen reader optimization',
          hint: _settings.screenReaderOptimized
              ? 'Currently enabled. App is optimized for screen readers'
              : 'Currently disabled. Tap to optimize for VoiceOver and TalkBack',
          child: _buildSwitchTile(
            title: 'Screen Reader Optimized',
            subtitle: 'Enhance compatibility with VoiceOver and TalkBack',
            value: _settings.screenReaderOptimized,
            onChanged: (value) => _updateSetting(
              _settings.copyWith(screenReaderOptimized: value),
            ),
            icon: Icons.speaker_notes,
          ),
        ),
      ],
    );
  }

  Widget _buildSystemSettingsInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withValues(alpha:0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue[300],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'System Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'These settings work alongside your device\'s accessibility settings. For more options, visit your device\'s Settings > Accessibility.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha:0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha:0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withValues(alpha:0.7),
          fontSize: 13,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.orange,
      secondary: Icon(
        icon,
        color: value ? Colors.orange : Colors.white.withValues(alpha:0.5),
      ),
    );
  }
}
