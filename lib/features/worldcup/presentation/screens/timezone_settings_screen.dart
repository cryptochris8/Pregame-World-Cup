import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../utils/timezone_utils.dart';

/// Screen for configuring timezone display preferences
class TimezoneSettingsScreen extends StatefulWidget {
  const TimezoneSettingsScreen({super.key});

  @override
  State<TimezoneSettingsScreen> createState() => _TimezoneSettingsScreenState();
}

class _TimezoneSettingsScreenState extends State<TimezoneSettingsScreen> {
  TimezoneDisplayMode _selectedMode = TimezoneDisplayMode.local;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentPreference();
  }

  Future<void> _loadCurrentPreference() async {
    final mode = await TimezoneUtils.getTimezoneDisplayMode();
    if (mounted) {
      setState(() {
        _selectedMode = mode;
        _isLoading = false;
      });
    }
  }

  Future<void> _savePreference(TimezoneDisplayMode mode) async {
    await TimezoneUtils.setTimezoneDisplayMode(mode);
    if (mounted) {
      setState(() => _selectedMode = mode);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Timezone display updated to ${_getModeDisplayName(mode)}'),
          backgroundColor: AppTheme.secondaryEmerald,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getModeDisplayName(TimezoneDisplayMode mode) {
    switch (mode) {
      case TimezoneDisplayMode.local:
        return 'Your Local Time';
      case TimezoneDisplayMode.venue:
        return 'Venue Local Time';
      case TimezoneDisplayMode.both:
        return 'Both Times';
    }
  }

  String _getModeDescription(TimezoneDisplayMode mode) {
    switch (mode) {
      case TimezoneDisplayMode.local:
        return 'Show match times in your device\'s local timezone (e.g., 7:00 PM EDT)';
      case TimezoneDisplayMode.venue:
        return 'Show match times in the venue\'s local timezone (e.g., 4:00 PM PDT for LA matches)';
      case TimezoneDisplayMode.both:
        return 'Show both your local time and the venue\'s local time';
    }
  }

  IconData _getModeIcon(TimezoneDisplayMode mode) {
    switch (mode) {
      case TimezoneDisplayMode.local:
        return Icons.phone_android;
      case TimezoneDisplayMode.venue:
        return Icons.stadium;
      case TimezoneDisplayMode.both:
        return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.mainGradientDecoration,
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Timezone Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.public,
                      color: Colors.white54,
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryOrange,
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Info Card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.primaryBlue.withOpacity(0.5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: AppTheme.primaryBlue,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'World Cup 2026 matches are played across 3 countries and 6 timezones. Choose how you want match times displayed.',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Current timezone info
                            Text(
                              'Your Device Timezone',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: AppTheme.primaryOrange,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    TimezoneUtils.getLocalTimezoneName(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Display Mode Selection
                            Text(
                              'Time Display Mode',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Options
                            ...TimezoneDisplayMode.values.map((mode) {
                              return _buildModeOption(mode);
                            }),

                            const SizedBox(height: 24),

                            // Preview section
                            Text(
                              'Preview',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildPreviewCard(),
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

  Widget _buildModeOption(TimezoneDisplayMode mode) {
    final isSelected = _selectedMode == mode;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryOrange.withOpacity(0.2)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppTheme.primaryOrange
              : Colors.white.withOpacity(0.1),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _savePreference(mode),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryOrange
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getModeIcon(mode),
                    color: isSelected ? Colors.white : Colors.white54,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getModeDisplayName(mode),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getModeDescription(mode),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryOrange,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    // Create a sample UTC time for preview (e.g., a match at MetLife Stadium)
    final sampleUtcTime = DateTime.utc(2026, 6, 15, 1, 0); // 1:00 AM UTC = 9:00 PM EDT

    String previewText;
    switch (_selectedMode) {
      case TimezoneDisplayMode.local:
        previewText = TimezoneUtils.formatMatchDateTime(
          utcDateTime: sampleUtcTime,
          venueTimezone: 'America/New_York',
          mode: TimezoneDisplayMode.local,
        );
        break;
      case TimezoneDisplayMode.venue:
        previewText = TimezoneUtils.formatMatchDateTime(
          utcDateTime: sampleUtcTime,
          venueTimezone: 'America/New_York',
          mode: TimezoneDisplayMode.venue,
        );
        break;
      case TimezoneDisplayMode.both:
        previewText = TimezoneUtils.formatMatchDateTime(
          utcDateTime: sampleUtcTime,
          venueTimezone: 'America/New_York',
          mode: TimezoneDisplayMode.local,
        );
        // Add venue time if different
        final venueText = TimezoneUtils.formatMatchDateTime(
          utcDateTime: sampleUtcTime,
          venueTimezone: 'America/New_York',
          mode: TimezoneDisplayMode.venue,
        );
        if (previewText != venueText) {
          previewText += '\n(Venue: $venueText)';
        }
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Group A',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                'Match 15',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'USA',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'vs',
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(width: 16),
              const Text(
                'MEX',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.schedule,
                size: 14,
                color: Colors.white38,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  previewText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.stadium,
                size: 14,
                color: Colors.white38,
              ),
              const SizedBox(width: 4),
              const Text(
                'MetLife Stadium',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
