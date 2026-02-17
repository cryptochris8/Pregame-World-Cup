import 'package:flutter/material.dart';
import '../../../../core/services/smart_venue_recommendation_service.dart';
import '../../../../core/services/unified_venue_service.dart';
import '../../../../core/services/logging_service.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/place.dart';
import '../../../schedule/domain/entities/game_schedule.dart';
import 'venue_recommendation_card.dart';
import 'venue_discovery_state_widgets.dart';
import 'venue_discovery_filter_tabs.dart';

/// Enhanced venue discovery widget with AI-powered smart recommendations.
///
/// Orchestrates filter tabs, loading/error/empty states, and a scrollable
/// list of [VenueRecommendationCard] widgets.
class SmartVenueDiscoveryWidget extends StatefulWidget {
  final List<Place> venues;
  final GameSchedule? game;
  final String context; // 'pre_game', 'post_game', 'general', 'exploration'
  final Function(Place)? onVenueSelected;
  final Function(Place)? onVenueFavorited;

  const SmartVenueDiscoveryWidget({
    super.key,
    required this.venues,
    this.game,
    this.context = 'general',
    this.onVenueSelected,
    this.onVenueFavorited,
  });

  @override
  State<SmartVenueDiscoveryWidget> createState() => _SmartVenueDiscoveryWidgetState();
}

class _SmartVenueDiscoveryWidgetState extends State<SmartVenueDiscoveryWidget>
    with SingleTickerProviderStateMixin {
  final UnifiedVenueService _unifiedVenueService = sl<UnifiedVenueService>();

  List<SmartVenueRecommendation> _recommendations = [];
  bool _isLoading = true;
  String? _error;

  late TabController _tabController;
  int _selectedFilterIndex = 0;

  final List<SmartVenueFilter> _filters = [
    SmartVenueFilter('Smart Picks', 'smart', Icons.psychology, const Color(0xFF7C3AED)),
    SmartVenueFilter('Nearby', 'distance', Icons.location_on, const Color(0xFF3B82F6)),
    SmartVenueFilter('Highly Rated', 'rating', Icons.star, const Color(0xFFFBBF24)),
    SmartVenueFilter('Popular', 'popular', Icons.trending_up, const Color(0xFFEA580C)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filters.length, vsync: this);
    _loadRecommendations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRecommendations() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final venueRecommendations = await _unifiedVenueService.getRecommendations(
        venues: widget.venues,
        game: widget.game,
        context: widget.context,
        limit: 20,
        includeAIAnalysis: true,
        includePersonalization: true,
      );

      final recommendations = venueRecommendations.map((venueRec) {
        return SmartVenueRecommendation(
          venue: venueRec.venue,
          smartScore: venueRec.unifiedScore,
          aiScore: venueRec.aiAnalysis?.overallScore ?? 0.5,
          behaviorScore: venueRec.personalizationScore,
          contextScore: venueRec.contextScore,
          predictionScore: venueRec.basicScore,
          reasoning: venueRec.reasoning,
          tags: venueRec.tags,
          confidence: venueRec.confidence,
          personalizationLevel: venueRec.personalizationScore,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _recommendations = recommendations;
          _isLoading = false;
        });
      }
    } catch (e) {
      LoggingService.error('Error loading recommendations: $e', tag: 'SmartVenueDiscovery');

      if (mounted) {
        setState(() {
          _error = 'Failed to load recommendations';
          _isLoading = false;
        });
      }
    }
  }

  List<SmartVenueRecommendation> _getFilteredRecommendations() {
    final filter = _filters[_selectedFilterIndex];

    switch (filter.type) {
      case 'smart':
        return _recommendations;
      case 'distance':
        final distanceSorted = _recommendations.toList();
        distanceSorted.sort((a, b) => (b.venue.rating ?? 0.0).compareTo(a.venue.rating ?? 0.0));
        return distanceSorted;
      case 'rating':
        final ratingSorted = _recommendations.toList();
        ratingSorted.sort((a, b) => (b.venue.rating ?? 0.0).compareTo(a.venue.rating ?? 0.0));
        return ratingSorted;
      case 'popular':
        final popularSorted = _recommendations.toList();
        popularSorted.sort(
          (a, b) => (b.venue.userRatingsTotal ?? 0).compareTo(a.venue.userRatingsTotal ?? 0),
        );
        return popularSorted;
      default:
        return _recommendations;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7C3AED),
            Color(0xFF3B82F6),
            Color(0xFFEA580C),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          VenueDiscoveryFilterTabs(
            filters: _filters,
            selectedFilterIndex: _selectedFilterIndex,
            onFilterSelected: (index) {
              setState(() {
                _selectedFilterIndex = index;
              });
            },
          ),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.explore,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Smart Venue Discovery',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getContextDescription(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadRecommendations,
            icon: Icon(
              Icons.refresh,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            tooltip: 'Refresh recommendations',
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const VenueDiscoveryLoadingWidget();
    }

    if (_error != null) {
      return VenueDiscoveryErrorWidget(
        error: _error,
        onRetry: _loadRecommendations,
      );
    }

    if (_recommendations.isEmpty) {
      return const VenueDiscoveryEmptyWidget();
    }

    return _buildRecommendationsList();
  }

  Widget _buildRecommendationsList() {
    final filteredRecommendations = _getFilteredRecommendations();

    return SizedBox(
      height: 400,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredRecommendations.length,
        itemBuilder: (context, index) {
          final recommendation = filteredRecommendations[index];
          return VenueRecommendationCard(
            recommendation: recommendation,
            index: index,
            onVenueSelected: widget.onVenueSelected,
            onVenueFavorited: widget.onVenueFavorited,
          );
        },
      ),
    );
  }

  String _getContextDescription() {
    switch (widget.context) {
      case 'pre_game':
        return 'Perfect spots before the game';
      case 'post_game':
        return 'Great places to celebrate or unwind';
      case 'exploration':
        return 'Discover new favorite places';
      default:
        return 'AI-powered venue recommendations';
    }
  }
}
