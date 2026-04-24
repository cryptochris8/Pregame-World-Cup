import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../domain/entities/fan_zone_guide.dart';

/// Full-screen city guide for a 2026 tournament host city.
/// Shows stadium info, fan zones, transit, visa, weather, and local tips.
class CityGuidePage extends StatelessWidget {
  final FanZoneGuide guide;

  const CityGuidePage({super.key, required this.guide});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(guide.cityName),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: AppTheme.mainGradientDecoration,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CityHeader(guide: guide),
                const SizedBox(height: 20),
                _StadiumSection(stadium: guide.venueStadium),
                const SizedBox(height: 20),
                if (guide.fanZones.isNotEmpty) ...[
                  _FanZonesSection(fanZones: guide.fanZones),
                  const SizedBox(height: 20),
                ],
                _TransitSection(transit: guide.transit),
                const SizedBox(height: 20),
                _WeatherSection(weather: guide.weather),
                const SizedBox(height: 20),
                _VisaSection(visa: guide.visaRequirements),
                const SizedBox(height: 20),
                _LocalTipsSection(tips: guide.localTips),
                const SizedBox(height: 20),
                _QuickInfoSection(guide: guide),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CityHeader extends StatelessWidget {
  final FanZoneGuide guide;

  const _CityHeader({required this.guide});

  String get _countryFlag {
    switch (guide.country) {
      case 'USA':
        return '🇺🇸';
      case 'Mexico':
        return '🇲🇽';
      case 'Canada':
        return '🇨🇦';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'CITY GUIDE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$_countryFlag ${guide.cityName}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${guide.stateOrProvince}, ${guide.country}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(icon: Icons.access_time, label: guide.timezone),
              _InfoChip(icon: Icons.attach_money, label: guide.currency),
              _InfoChip(icon: Icons.language, label: guide.language),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// Gradient section header matching the Pregame article style
class _GradientSectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _GradientSectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Gradient-bordered card used throughout the page
class _GradientCard extends StatelessWidget {
  final Widget child;

  const _GradientCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPurple.withValues(alpha: 0.18),
            AppTheme.primaryBlue.withValues(alpha: 0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryPurple.withValues(alpha: 0.4),
        ),
      ),
      child: child,
    );
  }
}

class _StadiumSection extends StatelessWidget {
  final VenueStadium stadium;

  const _StadiumSection({required this.stadium});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GradientSectionTitle(title: 'Stadium', icon: Icons.stadium),
        _GradientCard(
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.stadium, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stadium.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Capacity: ${_formatNumber(stadium.capacity)}',
                      style: const TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
    }
    return n.toString();
  }
}

class _FanZonesSection extends StatelessWidget {
  final List<FanZone> fanZones;

  const _FanZonesSection({required this.fanZones});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GradientSectionTitle(title: 'Fan Zones', icon: Icons.celebration),
        ...fanZones.map((zone) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _GradientCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zone.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      zone.location,
                      style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      zone.description,
                      style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
                    ),
                    if (zone.features.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: zone.features.map((f) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.primaryPurple.withValues(alpha: 0.25),
                                    AppTheme.primaryBlue.withValues(alpha: 0.15),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                f,
                                style: const TextStyle(
                                  color: AppTheme.primaryBlue,
                                  fontSize: 11,
                                ),
                              ),
                            )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class _TransitSection extends StatelessWidget {
  final TransitInfo transit;

  const _TransitSection({required this.transit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GradientSectionTitle(title: 'Getting Around', icon: Icons.directions_transit),
        _GradientCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryOrange, AppTheme.accentGold],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.flight, color: Colors.white, size: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      transit.airports.join(', '),
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                transit.publicTransit,
                style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.5),
              ),
              if (transit.tips.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...transit.tips.map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.primaryOrange, AppTheme.accentGold],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.lightbulb, color: Colors.white, size: 12),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tip,
                              style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _WeatherSection extends StatelessWidget {
  final WeatherInfo weather;

  const _WeatherSection({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GradientSectionTitle(title: 'Weather', icon: Icons.thermostat),
        _GradientCard(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _WeatherMonth(
                      month: 'June',
                      high: weather.juneAvgHigh,
                      low: weather.juneAvgLow,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppTheme.primaryPurple.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _WeatherMonth(
                      month: 'July',
                      high: weather.julyAvgHigh,
                      low: weather.julyAvgLow,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                weather.rainySeasonNote,
                style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeatherMonth extends StatelessWidget {
  final String month;
  final int high;
  final int low;

  const _WeatherMonth({required this.month, required this.high, required this.low});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(month, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(
          '$high°F / $low°F',
          style: const TextStyle(color: AppTheme.primaryOrange, fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _VisaSection extends StatelessWidget {
  final VisaRequirements visa;

  const _VisaSection({required this.visa});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GradientSectionTitle(title: 'Visa & Entry', icon: Icons.card_travel),
        _GradientCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                visa.general,
                style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 12),
              _VisaRow(flag: '🇺🇸', label: 'US Citizens', info: visa.forUS),
              _VisaRow(flag: '🇨🇦', label: 'Canadians', info: visa.forCanada),
              _VisaRow(flag: '🇲🇽', label: 'Mexicans', info: visa.forMexico),
              _VisaRow(flag: '🇪🇺', label: 'EU Citizens', info: visa.forEU),
            ],
          ),
        ),
      ],
    );
  }
}

class _VisaRow extends StatelessWidget {
  final String flag;
  final String label;
  final String info;

  const _VisaRow({required this.flag, required this.label, required this.info});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(flag, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                Text(info, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocalTipsSection extends StatelessWidget {
  final List<String> tips;

  const _LocalTipsSection({required this.tips});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GradientSectionTitle(title: 'Local Tips', icon: Icons.lightbulb_outline),
        ...tips.asMap().entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _GradientCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryOrange, AppTheme.accentGold],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class _QuickInfoSection extends StatelessWidget {
  final FanZoneGuide guide;

  const _QuickInfoSection({required this.guide});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryRed.withValues(alpha: 0.20),
            AppTheme.primaryOrange.withValues(alpha: 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryRed.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primaryRed.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.emergency, color: AppTheme.primaryRed, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Emergency: ${guide.emergencyNumber}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
