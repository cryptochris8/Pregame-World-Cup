import 'package:flutter/material.dart';
import '../../../features/recommendations/domain/entities/place.dart';
import '../widgets/venue_operating_hours_card.dart';
import '../widgets/enhanced_ai_venue_recommendations_widget.dart';

/// Overview tab content for the venue detail screen.
///
/// Shows AI recommendations, operating hours, contact info, and about section.
class VenueDetailOverviewTab extends StatelessWidget {
  final Place venue;
  final List<Place> nearbyVenues;

  const VenueDetailOverviewTab({
    super.key,
    required this.venue,
    required this.nearbyVenues,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EnhancedAIVenueRecommendationsWidget(
            nearbyVenues: nearbyVenues,
            customContext: 'Venue detail view for ${venue.name}',
          ),
          const SizedBox(height: 24),
          VenueOperatingHoursCard(venue: venue),
          const SizedBox(height: 24),
          _buildContactInfo(),
          const SizedBox(height: 24),
          if (venue.vicinity?.isNotEmpty == true) _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF475569)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          if (venue.vicinity?.isNotEmpty == true) ...[
            _buildContactRow(
              Icons.location_on,
              'Address',
              venue.vicinity!,
            ),
            const SizedBox(height: 12),
          ],
          _buildContactRow(
            Icons.phone,
            'Phone',
            '+1 (555) 123-4567',
          ),
          const SizedBox(height: 12),
          _buildContactRow(
            Icons.language,
            'Website',
            'www.${venue.name.toLowerCase().replaceAll(' ', '')}.com',
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: const Color(0xFFFF6B35),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF475569)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Great venue for game day! Located in the heart of the action with excellent food and atmosphere.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
