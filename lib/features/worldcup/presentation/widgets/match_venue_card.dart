import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../../../injection_container.dart' as di;
import '../../data/services/fan_zone_guide_service.dart';
import '../pages/city_guide_page.dart';

/// Displays the match venue (stadium) in a tappable card.
/// Tapping navigates to the full City Guide for that venue's host city.
class MatchVenueCard extends StatelessWidget {
  final String venueName;
  final String? venueCity;

  const MatchVenueCard({
    super.key,
    required this.venueName,
    this.venueCity,
  });

  Future<void> _openCityGuide(BuildContext context) async {
    final service = di.sl<FanZoneGuideService>();
    final guide = await service.getCityByVenueName(venueName);

    if (guide != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CityGuidePage(guide: guide)),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('City guide coming soon'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha:0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openCityGuide(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha:0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.stadium,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        venueName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      if (venueCity != null)
                        Row(
                          children: [
                            Text(
                              venueCity!,
                              style: const TextStyle(
                                color: Colors.white60,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'City Guide',
                              style: TextStyle(
                                color: AppTheme.primaryBlue.withValues(alpha: 0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white38,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
