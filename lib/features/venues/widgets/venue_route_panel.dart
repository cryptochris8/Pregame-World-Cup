import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../features/recommendations/domain/entities/place.dart';
import '../../../core/services/venue_recommendation_service.dart';

class VenueRoutePanel extends StatefulWidget {
  final Place venue;
  final LatLng? stadiumLocation;
  final VoidCallback onClose;

  const VenueRoutePanel({
    super.key,
    required this.venue,
    this.stadiumLocation,
    required this.onClose,
  });

  @override
  State<VenueRoutePanel> createState() => _VenueRoutePanelState();
}

class _VenueRoutePanelState extends State<VenueRoutePanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  
  RouteOption _selectedRoute = RouteOption.walking;
  bool _isLoadingRoute = false;
  RouteDetails? _routeDetails;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    _calculateRoute();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _calculateRoute() {
    if (widget.stadiumLocation == null) return;
    
    setState(() {
      _isLoadingRoute = true;
    });
    
    // Simulate route calculation
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        final venueLat = widget.venue.latitude ?? widget.venue.geometry?.location?.lat;
        final venueLng = widget.venue.longitude ?? widget.venue.geometry?.location?.lng;
        
        if (venueLat != null && venueLng != null) {
          final distance = VenueRecommendationService.calculateWalkingDistance(
            widget.stadiumLocation!.latitude,
            widget.stadiumLocation!.longitude,
            venueLat,
            venueLng,
          );
          
          final walkTime = VenueRecommendationService.estimateWalkingTime(distance);
          final driveTime = (walkTime * 0.3).round(); // Driving is ~3x faster
          
          setState(() {
            _routeDetails = RouteDetails(
              walkingTime: walkTime,
              drivingTime: driveTime,
              distance: distance,
              steps: _generateRouteSteps(),
            );
            _isLoadingRoute = false;
          });
        } else {
          setState(() {
            _isLoadingRoute = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, MediaQuery.of(context).size.height * _slideAnimation.value),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Handle and header
                _buildHeader(),
                
                // Route options
                _buildRouteOptions(),
                
                // Route details
                if (_routeDetails != null && !_isLoadingRoute)
                  Expanded(child: _buildRouteDetails())
                else if (_isLoadingRoute)
                  Expanded(child: _buildLoadingState())
                else
                  Expanded(child: _buildErrorState()),
                
                // Action buttons
                _buildActionButtons(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Header content
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Directions to',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.venue.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D1810),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Close button
              GestureDetector(
                onTap: () => _closePanel(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 20,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteOptions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildRouteOptionChip(
            RouteOption.walking,
            Icons.directions_walk,
            'Walking',
            _routeDetails?.walkingTime,
          ),
          const SizedBox(width: 12),
          _buildRouteOptionChip(
            RouteOption.driving,
            Icons.directions_car,
            'Driving',
            _routeDetails?.drivingTime,
          ),
          const SizedBox(width: 12),
          _buildRouteOptionChip(
            RouteOption.transit,
            Icons.directions_transit,
            'Transit',
            null, // Transit time not calculated in this demo
          ),
        ],
      ),
    );
  }

  Widget _buildRouteOptionChip(
    RouteOption option,
    IconData icon,
    String label,
    int? estimatedTime,
  ) {
    final isSelected = _selectedRoute == option;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRoute = option;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected 
                ? const Color(0xFF8B4513) 
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? const Color(0xFF8B4513) 
                  : Colors.grey.withValues(alpha:0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
              if (estimatedTime != null) ...[
                const SizedBox(height: 2),
                Text(
                  VenueRecommendationService.formatWalkingTime(estimatedTime),
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? Colors.white.withValues(alpha:0.8) : Colors.grey[500],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF8B4513).withValues(alpha:0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF8B4513).withValues(alpha:0.1)),
            ),
            child: Row(
              children: [
                Icon(
                  _getRouteIcon(),
                  color: const Color(0xFF8B4513),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getEstimatedTime(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D1810),
                        ),
                      ),
                      Text(
                        '${(_routeDetails!.distance / 1000).toStringAsFixed(1)} km via ${_getRouteDescription()}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D6A4F).withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Fastest',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D6A4F),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Route steps
          const Text(
            'Directions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D1810),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Expanded(
            child: ListView.builder(
              itemCount: _routeDetails!.steps.length,
              itemBuilder: (context, index) {
                final step = _routeDetails!.steps[index];
                return _buildRouteStep(step, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteStep(RouteStep step, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step indicator
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: index == 0 
                  ? const Color(0xFF2D6A4F) 
                  : index == _routeDetails!.steps.length - 1
                      ? const Color(0xFFD32F2F)
                      : Colors.grey[400],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: index == 0 
                  ? const Icon(Icons.my_location, color: Colors.white, size: 16)
                  : index == _routeDetails!.steps.length - 1
                      ? const Icon(Icons.location_on, color: Colors.white, size: 16)
                      : Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Step content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.instruction,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2D1810),
                  ),
                ),
                if (step.distance != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    step.distance!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Calculating route...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Unable to calculate route',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          // Start navigation button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () => _startNavigation(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B4513),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.navigation, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Start ${_selectedRoute.displayName}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Share route button
          OutlinedButton(
            onPressed: () => _shareRoute(),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF8B4513),
              side: const BorderSide(color: Color(0xFF8B4513)),
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Icon(Icons.share, size: 20),
          ),
        ],
      ),
    );
  }

  // Helper methods
  IconData _getRouteIcon() {
    switch (_selectedRoute) {
      case RouteOption.walking:
        return Icons.directions_walk;
      case RouteOption.driving:
        return Icons.directions_car;
      case RouteOption.transit:
        return Icons.directions_transit;
    }
  }

  String _getEstimatedTime() {
    if (_routeDetails == null) return '';
    
    switch (_selectedRoute) {
      case RouteOption.walking:
        return VenueRecommendationService.formatWalkingTime(_routeDetails!.walkingTime);
      case RouteOption.driving:
        return VenueRecommendationService.formatWalkingTime(_routeDetails!.drivingTime);
      case RouteOption.transit:
        return '15 min'; // Placeholder
    }
  }

  String _getRouteDescription() {
    switch (_selectedRoute) {
      case RouteOption.walking:
        return 'sidewalks and paths';
      case RouteOption.driving:
        return 'city streets';
      case RouteOption.transit:
        return 'public transit';
    }
  }

  List<RouteStep> _generateRouteSteps() {
    // Generate mock route steps based on venue location
    return [
      RouteStep(
        instruction: 'Start at Stadium',
        distance: null,
      ),
      RouteStep(
        instruction: 'Head north on Stadium Drive',
        distance: '0.2 mi',
      ),
      RouteStep(
        instruction: 'Turn right on Main Street',
        distance: '0.3 mi',
      ),
      RouteStep(
        instruction: 'Continue straight for 2 blocks',
        distance: '0.4 mi',
      ),
      RouteStep(
        instruction: 'Arrive at ${widget.venue.name}',
        distance: null,
      ),
    ];
  }

  void _closePanel() async {
    await _animationController.reverse();
    widget.onClose();
  }

  void _startNavigation() async {
    final venueLat = widget.venue.latitude ?? widget.venue.geometry?.location?.lat;
    final venueLng = widget.venue.longitude ?? widget.venue.geometry?.location?.lng;
    
    if (venueLat == null || venueLng == null) return;
    
    final url = _selectedRoute == RouteOption.walking
        ? 'https://www.google.com/maps/dir/?api=1&destination=$venueLat,$venueLng&travelmode=walking'
        : _selectedRoute == RouteOption.driving
            ? 'https://www.google.com/maps/dir/?api=1&destination=$venueLat,$venueLng&travelmode=driving'
            : 'https://www.google.com/maps/dir/?api=1&destination=$venueLat,$venueLng&travelmode=transit';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _shareRoute() {
    // Implementation for sharing route
    HapticFeedback.lightImpact();
    // Share route action
  }
}

// Data models
enum RouteOption {
  walking,
  driving,
  transit,
}

extension RouteOptionExtension on RouteOption {
  String get displayName {
    switch (this) {
      case RouteOption.walking:
        return 'Walking';
      case RouteOption.driving:
        return 'Driving';
      case RouteOption.transit:
        return 'Transit';
    }
  }
}

class RouteDetails {
  final int walkingTime;
  final int drivingTime;
  final double distance;
  final List<RouteStep> steps;

  RouteDetails({
    required this.walkingTime,
    required this.drivingTime,
    required this.distance,
    required this.steps,
  });
}

class RouteStep {
  final String instruction;
  final String? distance;

  RouteStep({
    required this.instruction,
    this.distance,
  });
} 