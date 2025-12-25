import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/smart_venue_recommendation_service.dart';
import '../../../../core/services/unified_venue_service.dart';
import '../../../../core/services/logging_service.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/place.dart';
import '../../../schedule/domain/entities/game_schedule.dart';

/// Enhanced venue discovery widget with AI-powered smart recommendations
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
    SmartVenueFilter('Smart Picks', 'smart', Icons.psychology, const Color(0xFF7C3AED)), // Vibrant purple from app theme
    SmartVenueFilter('Nearby', 'distance', Icons.location_on, const Color(0xFF3B82F6)), // Electric blue from app theme
    SmartVenueFilter('Highly Rated', 'rating', Icons.star, const Color(0xFFFBBF24)), // Championship gold from app theme
    SmartVenueFilter('Popular', 'popular', Icons.trending_up, const Color(0xFFEA580C)), // Warm orange from app theme
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

      // Convert to SmartVenueRecommendation format
      final recommendations = venueRecommendations.map((venueRec) {
        return SmartVenueRecommendation(
          venue: venueRec.venue,
          smartScore: venueRec.unifiedScore,
          aiScore: venueRec.aiAnalysis?.overallScore ?? 0.5,
          behaviorScore: venueRec.personalizationScore,
          contextScore: venueRec.contextScore,
          predictionScore: venueRec.basicScore, // Use basic score as prediction score
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
        // Sort by rating since distance isn't available on Place model
        distanceSorted.sort((a, b) => (b.venue.rating ?? 0.0).compareTo(a.venue.rating ?? 0.0));
        return distanceSorted;
      
      case 'rating':
        final ratingSorted = _recommendations.toList();
        ratingSorted.sort((a, b) => (b.venue.rating ?? 0.0).compareTo(a.venue.rating ?? 0.0));
        return ratingSorted;
      
      case 'popular':
        final popularSorted = _recommendations.toList();
        popularSorted.sort((a, b) => (b.venue.userRatingsTotal ?? 0).compareTo(a.venue.userRatingsTotal ?? 0));
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
            Color(0xFF7C3AED), // Vibrant purple
            Color(0xFF3B82F6), // Electric blue
            Color(0xFFEA580C), // Warm orange
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildFilterTabs(),
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
              color: Colors.white.withOpacity(0.2),
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
                    color: Colors.white.withOpacity(0.9),
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
              color: Colors.white.withOpacity(0.9),
            ),
            tooltip: 'Refresh recommendations',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = index == _selectedFilterIndex;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilterIndex = index;
                });
                
                HapticFeedback.lightImpact();
                
                // Track filter selection
                LoggingService.info('Filter selected: ${filter.name}', tag: 'SmartVenueDiscovery');
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? filter.color : const Color(0xFF475569), // Dark blue-gray for unselected
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? filter.color : const Color(0xFF64748B), // Lighter blue-gray border
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      filter.icon,
                      size: 18,
                      color: isSelected ? Colors.white : Colors.white70, // Light icon for dark background
                    ),
                    const SizedBox(width: 6),
                    Text(
                      filter.name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70, // Light text for dark background
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }
    
    if (_error != null) {
      return _buildErrorState();
    }
    
    if (_recommendations.isEmpty) {
      return _buildEmptyState();
    }
    
    return _buildRecommendationsList();
  }

  Widget _buildLoadingState() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFFFF6B35)), // Vibrant orange to match app theme
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Discovering perfect venues for you...',
            style: const TextStyle(
              color: Colors.white70, // Light text for dark background
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Using AI to analyze your preferences',
            style: const TextStyle(
              color: Colors.white60, // Lighter text for dark background
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.orange.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: const TextStyle(
              color: Colors.white, // White text for dark background
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unable to load recommendations',
            style: const TextStyle(
              color: Colors.white70, // Light text for dark background
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadRecommendations,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35), // Vibrant orange to match app theme
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No venues found',
            style: const TextStyle(
              color: Colors.white, // White text for dark background
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your location or search area',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsList() {
    final filteredRecommendations = _getFilteredRecommendations();
    
    return Container(
      height: 400,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredRecommendations.length,
        itemBuilder: (context, index) {
          final recommendation = filteredRecommendations[index];
          return _buildRecommendationCard(recommendation, index);
        },
      ),
    );
  }

  Widget _buildRecommendationCard(SmartVenueRecommendation recommendation, int index) {
    final venue = recommendation.venue;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: const Color(0xFF334155), // Dark blue-gray card background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _handleVenueSelection(recommendation),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Rank badge
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getRankGradient(index),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Venue info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          venue.name ?? 'Unknown Venue',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white, // White text for dark card
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (venue.rating != null) ...[
                              Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                              const SizedBox(width: 2),
                              Text(
                                venue.rating!.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white70, // Light text for dark card
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            // Distance info would go here when available
                            if (venue.rating != null) ...[
                              const SizedBox(width: 12),
                              Icon(Icons.star, size: 14, color: Colors.amber.shade600),
                              const SizedBox(width: 2),
                              Text(
                                '${venue.rating!.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  color: Colors.white60, // Light text for dark card
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Smart score
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getScoreColor(recommendation.smartScore),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(recommendation.smartScore * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Tags
              if (recommendation.tags.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: recommendation.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF475569), // Dark blue-gray for tags
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF64748B)), // Lighter border
                      ),
                                              child: Text(
                        tag,
                        style: const TextStyle(
                          color: Colors.white70, // Light text for dark tags
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              
              const SizedBox(height: 8),
              
              // Reasoning
              Text(
                recommendation.reasoning,
                style: const TextStyle(
                  color: Colors.white60, // Light text for dark card
                  fontSize: 13,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleVenueSelection(recommendation),
                      icon: const Icon(Icons.info_outline, size: 16, color: Color(0xFFFF6B35)), // Vibrant orange
                      label: const Text(
                        'View Details',
                        style: TextStyle(color: Color(0xFFFF6B35)), // Vibrant orange
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFF6B35)), // Vibrant orange border
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _handleVenueFavorite(recommendation),
                    icon: Icon(
                      Icons.favorite_border,
                      color: Colors.red.shade400,
                      size: 20,
                    ),
                    tooltip: 'Add to favorites',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getRankGradient(int index) {
    if (index == 0) {
      return [Colors.amber.shade600, Colors.orange.shade600]; // Gold
    } else if (index == 1) {
      return [Colors.grey.shade500, Colors.grey.shade600]; // Silver
    } else if (index == 2) {
      return [Colors.brown.shade400, Colors.brown.shade600]; // Bronze
    } else {
      return [Colors.blue.shade400, Colors.blue.shade600]; // Default
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 0.8) {
      return Colors.green.shade600;
    } else if (score >= 0.6) {
      return Colors.orange.shade600;
    } else {
      return Colors.grey.shade600;
    }
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

  void _handleVenueSelection(SmartVenueRecommendation recommendation) {
    // Track venue view
    LoggingService.info('Venue selected: ${recommendation.venue.name} (score: ${recommendation.smartScore})', tag: 'SmartVenueDiscovery');

    // Call parent callback
    widget.onVenueSelected?.call(recommendation.venue);

    HapticFeedback.lightImpact();
  }

  void _handleVenueFavorite(SmartVenueRecommendation recommendation) {
    // Track favorite action
    LoggingService.info('Venue favorited: ${recommendation.venue.name}', tag: 'SmartVenueDiscovery');

    // Call parent callback
    widget.onVenueFavorited?.call(recommendation.venue);

    HapticFeedback.mediumImpact();

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${recommendation.venue.name} to favorites!'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green.shade600,
      ),
    );
  }
}

/// Data class for venue filters
class SmartVenueFilter {
  final String name;
  final String type;
  final IconData icon;
  final Color color;

  SmartVenueFilter(this.name, this.type, this.icon, this.color);
} 